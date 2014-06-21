From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] net/wireless/brcm80211/brcmfmac: Make return type reflect
 actual semantics
Date: Sat, 21 Jun 2014 12:20:40 +0200
Message-ID: <53A55C78.1030706@broadcom.com>
References: <1403299923-21533-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Brett Rudley <brudley@broadcom.com>,
	<linux-wireless@vger.kernel.org>,
	<brcm80211-dev-list@broadcom.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403299923-21533-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/20/14 23:32, Rasmus Villemoes wrote:
> Applying ++ to a bool is equivalent to setting it true, regardless of
> its initial value (bools are not uint1_t). Hence the function
> wl_get_vif_state_all can only ever return true/false. The only
> in-tree caller uses its return value as a boolean. So update its
> return type, and since the list traversal and bit testing have no side
> effects, just return true immediately.

Hi Rasmus,

At the moment the function is indeed only used to determine whether any 
vif is in connected state. I am ok with your patch if you would also 
rename the function to brcmf_get_vif_state_any(). You may add 
'Reviewed-by: Arend van Spriel <arend@broadcom.com>' to the patch.

Regards,
Arend

> Signed-off-by: Rasmus Villemoes<linux@rasmusvillemoes.dk>
> ---
>
> Notes:
>      Alternatively, if the function is supposed to return a count, the
>      one-line fix would be
>
>      -	bool result = 0;
>      +	u32 result = 0;
>
>   drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c | 7 +++----
>   drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h | 2 +-
>   2 files changed, 4 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> index d8fa276..ec5f8c5 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
> @@ -5625,16 +5625,15 @@ enum nl80211_iftype brcmf_cfg80211_get_iftype(struct brcmf_if *ifp)
>   	return wdev->iftype;
>   }
>
> -u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state)
> +bool wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state)
>   {
>   	struct brcmf_cfg80211_vif *vif;
> -	bool result = 0;
>
>   	list_for_each_entry(vif,&cfg->vif_list, list) {
>   		if (test_bit(state,&vif->sme_state))
> -			result++;
> +			return true;
>   	}
> -	return result;
> +	return false;
>   }
>
>   static inline bool vif_event_equals(struct brcmf_cfg80211_vif_event *event,
> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
> index 283c525..c702e4e 100644
> --- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
> +++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
> @@ -477,7 +477,7 @@ const struct brcmf_tlv *
>   brcmf_parse_tlvs(const void *buf, int buflen, uint key);
>   u16 channel_to_chanspec(struct brcmu_d11inf *d11inf,
>   			struct ieee80211_channel *ch);
> -u32 wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state);
> +bool wl_get_vif_state_all(struct brcmf_cfg80211_info *cfg, unsigned long state);
>   void brcmf_cfg80211_arm_vif_event(struct brcmf_cfg80211_info *cfg,
>   				  struct brcmf_cfg80211_vif *vif);
>   bool brcmf_cfg80211_vif_event_armed(struct brcmf_cfg80211_info *cfg);
