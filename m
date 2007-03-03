From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/9] ioatdma: Push pending transactions to hardware more
 frequently
Date: Fri, 02 Mar 2007 22:14:39 -0500
Message-ID: <45E8E81F.8070805@garzik.org>
References: <20070303022238.31033.84558.stgit@gitlost.site> <20070303022417.31033.72244.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56301 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992961AbXCCDOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 22:14:42 -0500
In-Reply-To: <20070303022417.31033.72244.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech wrote:
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
> index 8e87261..0f77a9d 100644
> --- a/drivers/dma/ioatdma.c
> +++ b/drivers/dma/ioatdma.c
> @@ -310,7 +310,7 @@ static dma_cookie_t do_ioat_dma_memcpy(struct ioat_dma_chan *ioat_chan,
>  	list_splice_init(&new_chain, ioat_chan->used_desc.prev);
>  
>  	ioat_chan->pending += desc_count;
> -	if (ioat_chan->pending >= 20) {
> +	if (ioat_chan->pending >= 4) {

This sounds like something that will always be wrong -- or in other 
words, always be right for only the latest CPUs.  Can this be made 
dynamic, based on some timing factor?

	Jeff



