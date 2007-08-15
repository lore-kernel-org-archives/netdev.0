From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] nl80211: remove VLAN type
Date: Wed, 15 Aug 2007 11:18:37 +0200
Message-ID: <1187169518.3960.0.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

There is no point in trying to handle source MAC address based VLANs in
the wireless stack, something like "smacvlan" modeled after macvlan
should be sufficient.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
We could just not keep the hole as well since people can't really be
using that header yet, but the version we have in previous kernels could
still be shipped somewhere so I think it should be kept compatible.

 include/linux/nl80211.h |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

--- wireless-dev.orig/include/linux/nl80211.h	2007-08-15 00:43:06.290200043 +0200
+++ wireless-dev/include/linux/nl80211.h	2007-08-15 00:45:51.860200043 +0200
@@ -207,7 +207,6 @@ enum nl80211_attrs {
  * @NL80211_IFTYPE_ADHOC: independent BSS member
  * @NL80211_IFTYPE_STATION: managed BSS member
  * @NL80211_IFTYPE_AP: access point
- * @NL80211_IFTYPE_AP_VLAN: VLAN interface for access points
  * @NL80211_IFTYPE_WDS: wireless distribution interface
  * @NL80211_IFTYPE_MONITOR: monitor interface receiving all frames
  * @__NL80211_IFTYPE_AFTER_LAST: internal use
@@ -217,13 +216,17 @@ enum nl80211_attrs {
  *
  */
 enum nl80211_iftype {
-	NL80211_IFTYPE_UNSPECIFIED,
-	NL80211_IFTYPE_ADHOC,
-	NL80211_IFTYPE_STATION,
-	NL80211_IFTYPE_AP,
-	NL80211_IFTYPE_AP_VLAN,
-	NL80211_IFTYPE_WDS,
-	NL80211_IFTYPE_MONITOR,
+	NL80211_IFTYPE_UNSPECIFIED = 0,
+	NL80211_IFTYPE_ADHOC = 1,
+	NL80211_IFTYPE_STATION = 2,
+	NL80211_IFTYPE_AP = 3,
+	/*
+	 * there was AP_VLAN here but it was never used
+	 * keep the number unallocated for the benefit
+	 * of those people using old headers
+	 */
+	NL80211_IFTYPE_WDS = 5,
+	NL80211_IFTYPE_MONITOR = 6,
 
 	/* keep last */
 	__NL80211_IFTYPE_AFTER_LAST
