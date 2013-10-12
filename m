From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Sat, 12 Oct 2013 18:58:40 +0200
Message-ID: <52597FC0.4090801@cogentembedded.com>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp> <1381127365-6521-2-git-send-email-nh-ky@jinso.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nguyen Hong Ky <nh-ky@jinso.co.jp>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Ryusuke Sakato <ryusuke.sakato.bx@renesas.com>,
	Simon Horman <horms@verge.net.au>
To: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:65216 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752157Ab3JLP7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 11:59:53 -0400
Received: by mail-wg0-f46.google.com with SMTP id k14so5668637wgh.25
        for <netdev@vger.kernel.org>; Sat, 12 Oct 2013 08:59:51 -0700 (PDT)
In-Reply-To: <1381127365-6521-2-git-send-email-nh-ky@jinso.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07-10-2013 8:29, Nguyen Hong Ky wrote:

> This patch will fix RX packets errors when receiving big size
> of data by set bit RNC = 1.

> RNC - Receive Enable Control

> 0: Upon completion of reception of one frame, the E-DMAC writes
> the receive status to the descriptor and clears the RR bit in
> EDRRR to 0.

> 1: Upon completion of reception of one frame, the E-DMAC writes
> (writes back) the receive status to the descriptor. In addition,
> the E-DMAC reads the next descriptor and prepares for reception
> of the next frame.

> In addition, for get more stable when receiving packets, I set
> maximum size for the transmit/receive FIFO and inserts padding
> in receive data.

> Signed-off-by: Nguyen Hong Ky <nh-ky@jinso.co.jp>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |    4 ++++
>   1 files changed, 4 insertions(+), 0 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index a753928..11d34f0 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -649,12 +649,16 @@ static struct sh_eth_cpu_data r8a7740_data = {
>   	.eesr_err_check	= EESR_TWB1 | EESR_TWB | EESR_TABT | EESR_RABT |
>   			  EESR_RFE | EESR_RDE | EESR_RFRMER | EESR_TFE |
>   			  EESR_TDE | EESR_ECI,
> +	.fdr_value	= 0x0000070f,
> +	.rmcr_value	= 0x00000001,
>
>   	.apr		= 1,
>   	.mpr		= 1,
>   	.tpauser	= 1,
>   	.bculr		= 1,
>   	.hw_swap	= 1,
> +	.rpadir		= 1,
> +	.rpadir_value   = 2 << 16,
>   	.no_trimd	= 1,
>   	.no_ade		= 1,
>   	.tsu		= 1,

    Guennadi, could you check if this patch fixes your issue with NFS. Make 
sure it applies to 'r8a7740_data' (it was misapplied to DaveM's tree).

WBR, Sergei
