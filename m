From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 18:36:49 +0800
Message-ID: <E1JrW9h-0001tI-00@gondolin.me.apana.org.au>
References: <20080501.024320.212547875.davem@davemloft.net>
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org (David Miller)
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080501.024320.212547875.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> 
> diff --git a/net/mac80211/main.c b/net/mac80211/main.c
> index 9ad4e36..de2e904 100644
> --- a/net/mac80211/main.c
> +++ b/net/mac80211/main.c
> @@ -1485,6 +1485,9 @@ void ieee80211_tx_status(struct ieee80211_hw *hw, struct sk_buff *skb,
>        rthdr = (struct ieee80211_tx_status_rtap_hdr*)
>                                skb_push(skb, sizeof(*rthdr));
> ^M
> +       /* This is safe because the buffer has been orphaned.  */
> +       skb->truesize += sizeof(*rthdr);

skb->truesize should always account the skb->head area in its
entirety so we should never need to adjust it when pushing or
pulling.  So I suggest we find the place that expanded the head
area and make the adjustment there.  Alternative we could adjust
it right after the orphan call if the expansion occurs where we
can't adjust the truesize.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
