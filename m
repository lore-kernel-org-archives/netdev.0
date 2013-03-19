From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/4][net-next] gianfar: Remove redundant programming of
 [rt]xic registers
Date: Tue, 19 Mar 2013 21:49:27 +0400
Message-ID: <5148A527.7050206@cogentembedded.com>
References: <1363714805-9142-1-git-send-email-claudiu.manoil@freescale.com> <1363714805-9142-4-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:64032 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab3CSRuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 13:50:20 -0400
Received: by mail-la0-f46.google.com with SMTP id fq12so1482098lab.19
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 10:50:18 -0700 (PDT)
In-Reply-To: <1363714805-9142-4-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-03-2013 21:40, Claudiu Manoil wrote:

> For Multi Q Multi Group (MQ_MG_MODE) mode, the Rx/Tx colescing registers [rt]xic
> are aliased with the [rt]xic0 registers (coalescing setting regs for Q0). This
> avoids programming twice in a row the coalescing registers for the Rx/Tx hw Q0.

> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> ---
>   drivers/net/ethernet/freescale/gianfar.c | 24 ++++++++++++------------
>   1 file changed, 12 insertions(+), 12 deletions(-)

> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
> index 3f07dbd..e28b3e6 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1821,20 +1821,9 @@ void gfar_configure_coalescing(struct gfar_private *priv,
[...]
>   	if (priv->mode == MQ_MG_MODE) {
> +		int i = 0;

    Empty line wouldn't hurt here, after declaration.

>   		baddr = &regs->txic0;
>   		for_each_set_bit(i, &tx_mask, priv->num_tx_queues) {
>   			gfar_write(baddr + i, 0);
> @@ -1848,6 +1837,17 @@ void gfar_configure_coalescing(struct gfar_private *priv,
>   			if (likely(priv->rx_queue[i]->rxcoalescing))
>   				gfar_write(baddr + i, priv->rx_queue[i]->rxic);
>   		}
> +	} else {
> +		/* Backward compatible case ---- even if we enable

    s/----/--/

WBR, Sergei
