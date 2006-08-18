From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/7] [I/OAT] Push pending transactions to hardware more frequently
Date: Fri, 18 Aug 2006 07:11:57 +0000
Message-ID: <20060818071157.GA7516@ucw.cz>
References: <20060816005337.8634.70033.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:21262 "EHLO
	spitz.ucw.cz") by vger.kernel.org with ESMTP id S1751078AbWHRIPk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 04:15:40 -0400
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060816005337.8634.70033.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> Every 20 descriptors turns out to be to few append commands with
> newer/faster CPUs.  Pushing every 4 still cuts down on MMIO writes to an
> acceptable level without letting the DMA engine run out of work.
> 
> Signed-off-by: Chris Leech <christopher.leech@intel.com>
> ---
> 
>  drivers/dma/ioatdma.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
> index dbd4d6c..be4fdd7 100644
> --- a/drivers/dma/ioatdma.c
> +++ b/drivers/dma/ioatdma.c
> @@ -310,7 +310,7 @@ static dma_cookie_t do_ioat_dma_memcpy(s
>  	list_splice_init(&new_chain, ioat_chan->used_desc.prev);
>  
>  	ioat_chan->pending += desc_count;
> -	if (ioat_chan->pending >= 20) {
> +	if (ioat_chan->pending >= 4) {
>  		append = 1;
>  		ioat_chan->pending = 0;
>  	}
> @@ -818,7 +818,7 @@ static void __devexit ioat_remove(struct
>  }
>  
>  /* MODULE API */
> -MODULE_VERSION("1.7");
> +MODULE_VERSION("1.9");
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Intel Corporation");

Huh, two version bumps for... ONE ONE-LINER :-).

Could we get rid of embedded version? It helps no one.

-- 
Thanks for all the (sleeping) penguins.
