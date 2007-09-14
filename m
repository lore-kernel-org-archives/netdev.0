From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] ucc_geth: fix compilation
Date: Fri, 14 Sep 2007 09:07:34 -0500
Message-ID: <C844988E-F6B9-44B9-AB78-C44E19A2E605@kernel.crashing.org>
References: <20070912112456.GA15556@localhost.localdomain> <20070913152333.GA2381@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>,
	netdev <netdev@vger.kernel.org>,
	Anton Vorontsov <avorontsov@ru.mvista.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49568 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286AbXINOEv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 10:04:51 -0400
In-Reply-To: <20070913152333.GA2381@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 13, 2007, at 10:23 AM, Anton Vorontsov wrote:

> Currently qe_bd_t is used in the macro call -- dma_unmap_single,
> which is a no-op on PPC32, thus error is hidden today. Starting
> with 2.6.24, macro will be replaced by the empty static function,
> and erroneous use of qe_bd_t will trigger compilation error.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---

Jeff, I'm going to pick this up via the powerpc.git tree since its  
currently only broken in our for-2.6.24 branch (because of other  
changes in there).  Any issues?

- k

>
> Reposting this to include netdev in Cc.
>
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 12e01b2..9a38dfe 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -2148,7 +2148,7 @@ static void ucc_geth_memclean(struct  
> ucc_geth_private *ugeth)
>  		for (j = 0; j < ugeth->ug_info->bdRingLenTx[i]; j++) {
>  			if (ugeth->tx_skbuff[i][j]) {
>  				dma_unmap_single(NULL,
> -						 ((qe_bd_t *)bd)->buf,
> +						 ((struct qe_bd *)bd)->buf,
>  						 (in_be32((u32 *)bd) &
>  						  BD_LENGTH_MASK),
>  						 DMA_TO_DEVICE);
> -- 
> 1.5.0.6
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

