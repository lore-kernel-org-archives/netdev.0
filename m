From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] linux-wireless:Added wiphy capability flag for offloading
 4way handshake to driver
Date: Tue, 11 Nov 2014 10:49:00 +0100
Message-ID: <5461DB8C.2020201@broadcom.com>
References: <DF163EE1A432BF4BBE6B2088220663A6743890@SJEXCHMB06.corp.ad.broadcom.com>
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
In-Reply-To: <DF163EE1A432BF4BBE6B2088220663A6743890-HXj2mutaA2pmqaqore1TH5r/X4hKkxxPpWgKQ6/u3Fg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-11-14 07:27, Gautam (Gautam Kumar) Shukla wrote:
> 
> For offloading 4 way handshake to driver , currently we don't have WIPHY capability flag to communicate same to supplicant.
> I have added the flag NL80211_ATTR_4WAY_KEY_HANDSHAKE  and rest of the code for the same.
> 
> Tested on x86 linux machine
> 
> Signed-off-by: Gautam kumar shukla <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
> ---
>  include/net/cfg80211.h       | 4 ++++
>  include/uapi/linux/nl80211.h | 5 ++++-
>  net/wireless/nl80211.c       | 4 ++++
>  3 files changed, 12 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
> index 6f744e0..b37de0a 100644
> --- a/include/net/cfg80211.h
> +++ b/include/net/cfg80211.h
> @@ -2629,7 +2629,10 @@ struct cfg80211_ops {
>   *	TSPEC sessions (TID aka TSID 0-7) with the NL80211_CMD_ADD_TX_TS
>   *	command. Standard IEEE 802.11 TSPEC setup is not yet supported, it
>   *	needs to be able to handle Block-Ack agreements and other things.
> + *	@WIPHY_FLAG_SUPPORTS_4WAY_HANDHSHAKE:the device supports 4way handshake

Indentation seems wrong here. Also add space after the colon sign.

> + *	in the driver/firmware.
>   */
> +
>  enum wiphy_flags {
>  	WIPHY_FLAG_SUPPORTS_WMM_ADMISSION	= BIT(0),
>  	/* use hole at 1 */
> @@ -2654,6 +2657,7 @@ enum wiphy_flags {
>  	WIPHY_FLAG_HAS_REMAIN_ON_CHANNEL	= BIT(21),
>  	WIPHY_FLAG_SUPPORTS_5_10_MHZ		= BIT(22),
>  	WIPHY_FLAG_HAS_CHANNEL_SWITCH		= BIT(23),
> +	WIPHY_FLAG_SUPPORTS_4WAY_HANDSHAKE	= BIT(24),
>  };
>  
>  /**
> diff --git a/include/uapi/linux/nl80211.h b/include/uapi/linux/nl80211.h
> index b01d5dd..2c474a3 100644
> --- a/include/uapi/linux/nl80211.h
> +++ b/include/uapi/linux/nl80211.h
> @@ -1640,9 +1640,11 @@ enum nl80211_commands {
>   *
>   *	@NL80211_ATTR_PSK: a PSK value (u8 attribute).This is 32-octet (256-bit)
>   *	PSK.
> + * @NL80211_ATTR_4WAY_KEY_HANDSHAKE: Indicates whether the driver is capable
> + * of 4way key handshake

convention is to have a tab in the continuing line.

>   *
>   *
> - * @NL80211_ATTR_MAX: highest attribute number currently defined
> + * * @NL80211_ATTR_MAX: highest attribute number currently defined

huh?

>   * @__NL80211_ATTR_AFTER_LAST: internal use
>   */
>  enum nl80211_attrs {
> @@ -1995,6 +1997,7 @@ enum nl80211_attrs {
>  	NL80211_ATTR_SMPS_MODE,
>  
>  	NL80211_ATTR_PSK,
> +	NL80211_ATTR_4WAY_KEY_HANDSHAKE,
>  
>  	/* add attributes here, update the policy in nl80211.c */
>  
> diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
> index 91c24b1..5f85c41 100644
> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -396,6 +396,7 @@ static const struct nla_policy nl80211_policy[NL80211_ATTR_MAX+1] = {
>  	[NL80211_ATTR_ADMITTED_TIME] = { .type = NLA_U16 },
>  	[NL80211_ATTR_SMPS_MODE] = { .type = NLA_U8 },
>  	[NL80211_ATTR_PSK] = { .type = NLA_BINARY, .len = 32 },
> +	[NL80211_ATTR_4WAY_KEY_HANDSHAKE] = { .type = NLA_FLAG },
>  };
>  
>  /* policy for the key attributes */
> @@ -1303,6 +1304,9 @@ static int nl80211_send_wiphy(struct cfg80211_registered_device *rdev,
>  		if ((rdev->wiphy.flags & WIPHY_FLAG_SUPPORTS_FW_ROAM) &&
>  		    nla_put_flag(msg, NL80211_ATTR_ROAM_SUPPORT))
>  			goto nla_put_failure;
> +		if ((rdev->wiphy.flags & WIPHY_FLAG_SUPPORTS_4WAY_HANDSHAKE) &&
> +			nla_put_flag(msg,NL80211_ATTR_4WAY_KEY_HANDSHAKE))
> +			goto nla_put_failure;
>  		if ((rdev->wiphy.flags & WIPHY_FLAG_SUPPORTS_TDLS) &&
>  		    nla_put_flag(msg, NL80211_ATTR_TDLS_SUPPORT))
>  			goto nla_put_failure;
> 
