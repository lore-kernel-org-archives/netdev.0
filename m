From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] ath9k: fix a memory leak in ath_rx_tasklet()
Date: Fri, 16 Mar 2012 10:00:10 -0400
Message-ID: <20120316140010.GB2563@tuxdriver.com>
References: <1331844209.19406.11.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Trond Wuellner <trond@chromium.org>,
	Grant Grundler <grundler@chromium.org>,
	Paul Stewart <pstew@chromium.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39729 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758476Ab2CPORM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 10:17:12 -0400
Content-Disposition: inline
In-Reply-To: <1331844209.19406.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 15, 2012 at 01:43:29PM -0700, Eric Dumazet wrote:
> commit 0d95521ea7 (ath9k: use split rx buffers to get rid of order-1 skb
> allocations) added in memory leak in error path.
> 
> sc->rx.frag should be cleared after the pskb_expand_head() call, or else
> we jump to requeue_drop_frag and leak an skb.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jouni Malinen <jouni@qca.qualcomm.com>
> Cc: Felix Fietkau <nbd@openwrt.org>
> Cc: John W. Linville <linville@tuxdriver.com>
> Cc: Trond Wuellner <trond@chromium.org>
> Cc: Grant Grundler <grundler@chromium.org>
> Cc: Paul Stewart <pstew@chromium.org>
> Cc: David Miller <davem@davemloft.net>

Acked-by: John W. Linville <linville@tuxdriver.com>

Dave, will you pick this up yourself?  Or should I take it around the bend?

John

> ---
>  drivers/net/wireless/ath/ath9k/recv.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
> index 7e1a91a..e74fc99 100644
> --- a/drivers/net/wireless/ath/ath9k/recv.c
> +++ b/drivers/net/wireless/ath/ath9k/recv.c
> @@ -1917,13 +1917,13 @@ int ath_rx_tasklet(struct ath_softc *sc, int flush, bool hp)
>  		if (sc->rx.frag) {
>  			int space = skb->len - skb_tailroom(hdr_skb);
>  
> -			sc->rx.frag = NULL;
> -
>  			if (pskb_expand_head(hdr_skb, 0, space, GFP_ATOMIC) < 0) {
>  				dev_kfree_skb(skb);
>  				goto requeue_drop_frag;
>  			}
>  
> +			sc->rx.frag = NULL;
> +
>  			skb_copy_from_linear_data(skb, skb_put(hdr_skb, skb->len),
>  						  skb->len);
>  			dev_kfree_skb_any(skb);
> 
> 
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
