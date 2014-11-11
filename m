From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 1/1] linux-wireless: Added psk in struct cfg80211_connect_params
 needed for offloading 4way handshake to driver
Date: Tue, 11 Nov 2014 10:44:08 +0100
Message-ID: <5461DA68.9030607@broadcom.com>
References: <DF163EE1A432BF4BBE6B2088220663A67437BD@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jithu Jance <jithu-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Sreenath S <sreenats-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: "Gautam (Gautam Kumar) Shukla" <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <DF163EE1A432BF4BBE6B2088220663A67437BD-HXj2mutaA2pmqaqore1TH5r/X4hKkxxPpWgKQ6/u3Fg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-11-14 06:56, Gautam (Gautam Kumar) Shukla wrote:
>

Hi Gautam,

Good to see more upstream contributions, but it might be useful to have
a driver implementation as well in this series. Maybe we can take a shot
with brcmfmac for obvious reasons. Would you happen to have
wpa_supplicant changes as well?

I added some inline comments below.

Regards,
Arend

> For offloading 4 way handshake to driver, currently we don't have any member  of struct cfg80211_connect_params to pass PSK from supplicant to driver. I have added psk for the same and added rest of the code needed in nl80211.h and nl80211.c to parse and make it available to driver.
> From supplicant, we already have psk member field in assoc_params to use .

In the commit message you should not describe what you did, but what
problem you are trying to solve and/or what functional change the patch
provides.

> Tested on x86 linux.
> 
> Signed-off-by: Gautam kumar shukla <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
> include/net/cfg80211.h       | 2 ++
>  include/uapi/linux/nl80211.h | 8 +++++++-
>  net/wireless/nl80211.c       | 4 ++++
>  3 files changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h index a2ddcf2..6f744e0 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -1758,6 +1758,7 @@ struct cfg80211_ibss_params {
>   *    allowed to ignore this @bssid_hint if it has knowledge of a better BSS
>   *    to use.
>   * @ssid: SSID
> + * @psk:preshared key for WPA2-PSK connection or %NULL if not specified

add space after the colon sign.

>   * @ssid_len: Length of ssid in octets
>   * @auth_type: Authentication type (algorithm)
>   * @ie: IEs for association request
> @@ -1783,6 +1784,7 @@ struct cfg80211_connect_params {
>      const u8 *bssid;
>      const u8 *bssid_hint;
>      const u8 *ssid;
> +    const u8 *psk;
>      size_t ssid_len;
>      enum nl80211_auth_type auth_type;
>      const u8 *ie;
> diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h index 4b28dc0..b01d5dd 100644
> --- a/include/uapi/linux/nl80211.h
> +++ b/include/uapi/linux/nl80211.h
> @@ -421,7 +421,7 @@
>   *    %NL80211_ATTR_MAC, %NL80211_ATTR_WIPHY_FREQ, %NL80211_ATTR_CONTROL_PORT,
>   *    %NL80211_ATTR_CONTROL_PORT_ETHERTYPE,
>   *    %NL80211_ATTR_CONTROL_PORT_NO_ENCRYPT, %NL80211_ATTR_MAC_HINT, and
> - *    %NL80211_ATTR_WIPHY_FREQ_HINT.
> + *    %NL80211_ATTR_WIPHY_FREQ_HINT, and %NL80211_ATTR_PSK.
>   *    If included, %NL80211_ATTR_MAC and %NL80211_ATTR_WIPHY_FREQ are
>   *    restrictions on BSS selection, i.e., they effectively prevent roaming
>   *    within the ESS. %NL80211_ATTR_MAC_HINT and %NL80211_ATTR_WIPHY_FREQ_HINT @@ -1638,6 +1638,10 @@ enum nl80211_commands {
>   * @NL80211_ATTR_SMPS_MODE: SMPS mode to use (ap mode). see
>   *    &enum nl80211_smps_mode.
>   *
> + *    @NL80211_ATTR_PSK: a PSK value (u8 attribute).This is 32-octet 
> + (256-bit)
> + *    PSK.
> + *

Some indentation gone haywire here. I would remove '(u8 attribute)'. The
mention of 32-octet seems sufficient to me.

>   * @NL80211_ATTR_MAX: highest attribute number currently defined
>   * @__NL80211_ATTR_AFTER_LAST: internal use
>   */
> @@ -1990,6 +1994,8 @@ enum nl80211_attrs {
>  
>      NL80211_ATTR_SMPS_MODE,
>  
> +    NL80211_ATTR_PSK,
> +
>      /* add attributes here, update the policy in nl80211.c */
>  
>      __NL80211_ATTR_AFTER_LAST,
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c index 5839c85..91c24b1 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -395,6 +395,7 @@ static const struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] = {
>      [NL80211_ATTR_USER_PRIO] = { .type = NLA_U8 },
>      [NL80211_ATTR_ADMITTED_TIME] = { .type = NLA_U16 },
>      [NL80211_ATTR_SMPS_MODE] = { .type = NLA_U8 },
> +    [NL80211_ATTR_PSK] = { .type = NLA_BINARY, .len = 32 },
>  };
>  
>  /* policy for the key attributes */
> @@ -7310,6 +7311,9 @@ static int nl80211_connect(struct sk_buff *skb, struct genl_info *info)
>          connect.flags |= ASSOC_REQ_USE_RRM;
>      }
>  
> +    if (info->attrs[NL80211_ATTR_PSK])
> +        connect.psk = nla_data(info->attrs[NL80211_ATTR_PSK]);
> +
>      wdev_lock(dev->ieee80211_ptr);
>      err = cfg80211_connect(rdev, dev, &connect, connkeys, NULL);
>      wdev_unlock(dev->ieee80211_ptr);
> --
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
