From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: cpsw: fix usage of cpdma_check_free_tx_desc()
Date: Wed, 13 Mar 2013 01:17:44 +0530
Message-ID: <513F8660.2010602@ti.com>
References: <1363105879-26921-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <andreas.fenkart@streamunlimited.com>,
	<davem@davemloft.net>, <s.neumann@raumfeld.com>,
	<koen@dominion.thruhere.net>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47169 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab3CLTr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 15:47:58 -0400
In-Reply-To: <1363105879-26921-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/2013 10:01 PM, Daniel Mack wrote:
> Commit fae50823d0 ("net: ethernet: davinci_cpdma: Add boundary for rx
> and tx descriptors") introduced a function to check the current
> allocation state of tx packets. The return value is taken into account
> to stop the netqork queue on the adapter in case there are no free
> slots.
>
> However, cpdma_check_free_tx_desc() returns 'true' if there is room in
> the bitmap, not 'false', so the usage of the function is wrong.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Reported-by: Sven Neumann <s.neumann@raumfeld.com>
> Reported-by: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
> ---
>   drivers/net/ethernet/ti/cpsw.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 01ffbc4..75c4855 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -905,7 +905,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
>   	/* If there is no more tx desc left free then we need to
>   	 * tell the kernel to stop sending us tx frames.
>   	 */
> -	if (unlikely(cpdma_check_free_tx_desc(priv->txch)))
> +	if (unlikely(!cpdma_check_free_tx_desc(priv->txch)))
>   		netif_stop_queue(ndev);
>   
>   	return NETDEV_TX_OK;
Tested-by: Mugunthan V N <mugunthanvnm@ti.com>
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
