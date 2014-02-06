From: Shradha Shah <sshah@solarflare.com>
Subject: Re: [PATCH-net] drivers/net: fix build warning in ethernet/sfc/tx.c
Date: Thu, 6 Feb 2014 16:59:59 +0000
Message-ID: <52F3BF8F.4080506@solarflare.com>
References: <1391705112-27869-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Jon Cooper <jcooper@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41610 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbaBFRAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 12:00:04 -0500
In-Reply-To: <1391705112-27869-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2014 04:45 PM, Paul Gortmaker wrote:
> Commit ee45fd92c739db5b7950163d91dfe5f016af6d24 ("sfc: Use TX PIO
> for sufficiently small packets") introduced the following warning:
> 
> drivers/net/ethernet/sfc/tx.c: In function 'efx_enqueue_skb':
> drivers/net/ethernet/sfc/tx.c:432:1: warning: label 'finish_packet' defined but not used
> 
> Stick the label inside the same #ifdef that the code which calls
> it uses.  Note that this is only seen for arch that do not set
> ARCH_HAS_IOREMAP_WC, such as arm, mips, sparc, ..., as the others
> enable the write combining code and hence use the label.
> 
> Cc: Jon Cooper <jcooper@solarflare.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Acked-by: Shradha Shah <sshah@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/tx.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index c49d1fb16965..75d11fa4eb0a 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -429,7 +429,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>  	}
>  
>  	/* Transfer ownership of the skb to the final buffer */
> +#ifdef EFX_USE_PIO
>  finish_packet:
> +#endif
>  	buffer->skb = skb;
>  	buffer->flags = EFX_TX_BUF_SKB | dma_flags;
>  
> 
