From: "Gautam (Gautam Kumar) Shukla" <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 1/1] linux-wireless: Added psk in struct
 cfg80211_connect_params needed for offloading 4way handshake to driver
Date: Tue, 11 Nov 2014 05:56:11 +0000
Message-ID: <DF163EE1A432BF4BBE6B2088220663A67437BD@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jithu Jance <jithu-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Sreenath S <sreenats-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


=46or offloading 4 way handshake to driver, currently we don't have any=
 member=A0 of struct cfg80211_connect_params to pass PSK from supplican=
t to driver. I have added psk for the same and added rest of the code n=
eeded in nl80211.h and nl80211.c to parse and make it available to driv=
er.
=46rom supplicant, we already have psk member field in assoc_params to =
use .

Tested on x86 linux.

Signed-off-by: Gautam kumar shukla <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
include/net/cfg80211.h=A0=A0=A0=A0=A0=A0 | 2 ++
=A0include/uapi/linux/nl80211.h | 8 +++++++-
=A0net/wireless/nl80211.c=A0=A0=A0=A0=A0=A0 | 4 ++++
=A03 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h index a2dd=
cf2..6f744e0 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1758,6 +1758,7 @@ struct cfg80211_ibss_params {
=A0 *=A0=A0=A0 allowed to ignore this @bssid_hint if it has knowledge o=
f a better BSS
=A0 *=A0=A0=A0 to use.
=A0 * @ssid: SSID
+ * @psk:preshared key for WPA2-PSK connection or %NULL if not specifie=
d
=A0 * @ssid_len: Length of ssid in octets
=A0 * @auth_type: Authentication type (algorithm)
=A0 * @ie: IEs for association request
@@ -1783,6 +1784,7 @@ struct cfg80211_connect_params {
=A0=A0=A0=A0 const u8 *bssid;
=A0=A0=A0=A0 const u8 *bssid_hint;
=A0=A0=A0=A0 const u8 *ssid;
+=A0=A0=A0 const u8 *psk;
=A0=A0=A0=A0 size_t ssid_len;
=A0=A0=A0=A0 enum nl80211_auth_type auth_type;
=A0=A0=A0=A0 const u8 *ie;
diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.=
h index 4b28dc0..b01d5dd 100644
--- a/include/uapi/linux/nl80211.h
+++ b/include/uapi/linux/nl80211.h
@@ -421,7 +421,7 @@
=A0 *=A0=A0=A0 %NL80211_ATTR_MAC, %NL80211_ATTR_WIPHY_FREQ, %NL80211_AT=
TR_CONTROL_PORT,
=A0 *=A0=A0=A0 %NL80211_ATTR_CONTROL_PORT_ETHERTYPE,
=A0 *=A0=A0=A0 %NL80211_ATTR_CONTROL_PORT_NO_ENCRYPT, %NL80211_ATTR_MAC=
_HINT, and
- *=A0=A0=A0 %NL80211_ATTR_WIPHY_FREQ_HINT.
+ *=A0=A0=A0 %NL80211_ATTR_WIPHY_FREQ_HINT, and %NL80211_ATTR_PSK.
=A0 *=A0=A0=A0 If included, %NL80211_ATTR_MAC and %NL80211_ATTR_WIPHY_F=
REQ are
=A0 *=A0=A0=A0 restrictions on BSS selection, i.e., they effectively pr=
event roaming
=A0 *=A0=A0=A0 within the ESS. %NL80211_ATTR_MAC_HINT and %NL80211_ATTR=
_WIPHY_FREQ_HINT @@ -1638,6 +1638,10 @@ enum nl80211_commands {
=A0 * @NL80211_ATTR_SMPS_MODE: SMPS mode to use (ap mode). see
=A0 *=A0=A0=A0 &enum nl80211_smps_mode.
=A0 *
+ *=A0=A0=A0 @NL80211_ATTR_PSK: a PSK value (u8 attribute).This is 32-o=
ctet=20
+ (256-bit)
+ *=A0=A0=A0 PSK.
+ *
+ *
=A0 * @NL80211_ATTR_MAX: highest attribute number currently defined
=A0 * @__NL80211_ATTR_AFTER_LAST: internal use
=A0 */
@@ -1990,6 +1994,8 @@ enum nl80211_attrs {
=A0
=A0=A0=A0=A0 NL80211_ATTR_SMPS_MODE,
=A0
+=A0=A0=A0 NL80211_ATTR_PSK,
+
=A0=A0=A0=A0 /* add attributes here, update the policy in nl80211.c */
=A0
=A0=A0=A0=A0 __NL80211_ATTR_AFTER_LAST,
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c index 5839=
c85..91c24b1 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -395,6 +395,7 @@ static const struct nla_policy nl80211_policy[NL802=
11_ATTR_MAX+1] =3D {
=A0=A0=A0=A0 [NL80211_ATTR_USER_PRIO] =3D { .type =3D NLA_U8 },
=A0=A0=A0=A0 [NL80211_ATTR_ADMITTED_TIME] =3D { .type =3D NLA_U16 },
=A0=A0=A0=A0 [NL80211_ATTR_SMPS_MODE] =3D { .type =3D NLA_U8 },
+=A0=A0=A0 [NL80211_ATTR_PSK] =3D { .type =3D NLA_BINARY, .len =3D 32 }=
,
=A0};
=A0
=A0/* policy for the key attributes */
@@ -7310,6 +7311,9 @@ static int nl80211_connect(struct sk_buff *skb, s=
truct genl_info *info)
=A0=A0=A0=A0 =A0=A0=A0 connect.flags |=3D ASSOC_REQ_USE_RRM;
=A0=A0=A0=A0 }
=A0
+=A0=A0=A0 if (info->attrs[NL80211_ATTR_PSK])
+=A0=A0=A0 =A0=A0=A0 connect.psk =3D nla_data(info->attrs[NL80211_ATTR_=
PSK]);
+
=A0=A0=A0=A0 wdev_lock(dev->ieee80211_ptr);
=A0=A0=A0=A0 err =3D cfg80211_connect(rdev, dev, &connect, connkeys, NU=
LL);
=A0=A0=A0=A0 wdev_unlock(dev->ieee80211_ptr);
--
1.9.1
