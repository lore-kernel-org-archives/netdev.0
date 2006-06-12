From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH 5/5] bcm43xx-d80211: fix sending of fragments
Date: Mon, 12 Jun 2006 21:35:16 +0200
Message-ID: <200606122135.17198.mb@bu3sch.de>
References: <20060612191606.7AA8E48391@silver.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:49595
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1752254AbWFLTgm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 15:36:42 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060612191606.7AA8E48391@silver.suse.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 12 June 2006 21:16, Jiri Benc wrote:
> This makes fragmentation work with bcm43xx.
> 
> Signed-off-by: Jiri Benc <jbenc@suse.cz>

Signed-off-by: Michael Buesch <mb@bu3sch.de>

The other patch will get my sign-off tomorrow (I think modified, though).
I don't have time to look at it more close, now.

> ---
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c |    2 +-
>  drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> --- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
> +++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
> @@ -703,7 +703,7 @@ static int dma_tx_fragment(struct bcm43x
>  	bcm43xx_generate_txhdr(ring->bcm,
>  			       (struct bcm43xx_txhdr *)hdr_skb->data,
>  			       skb->data, skb->len,
> -			       1,//FIXME
> +			       ctl->first_fragment,
>  			       generate_cookie(ring, slot),
>  			       ctl);
>  
> --- dscape.orig/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
> +++ dscape/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
> @@ -183,7 +183,7 @@ static void pio_tx_write_fragment(struct
>  	assert(skb_shinfo(skb)->nr_frags == 0);
>  	bcm43xx_generate_txhdr(queue->bcm,
>  			       &txhdr, skb->data, skb->len,
> -			       1,//FIXME
> +			       packet->ctl->first_fragment,
>  			       generate_cookie(queue, pio_txpacket_getindex(packet)),
>  			       packet->ctl);
>  
> 

-- 
Greetings Michael.
