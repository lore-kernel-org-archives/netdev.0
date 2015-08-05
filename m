From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] r8169:Fill with zero Tx descriptors
Date: Wed, 5 Aug 2015 15:42:36 +0200
Message-ID: <55C212CC.8060305@redhat.com>
References: <1438771604-17621-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Corcodel Marian <corcodel.marian@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752162AbbHENmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Aug 2015 09:42:37 -0400
In-Reply-To: <1438771604-17621-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5.8.2015 12:46, Corcodel Marian wrote:
>   This patch fill with zero Tx descriptors before use.Is only
>   on    part by more patches but is critical.(critical)
>
>
> Signed-off-by: Corcodel Marian <corcodel.marian@gmail.com>
>
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 3df51fa..bf78f94 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -7589,7 +7589,7 @@ static int rtl_open(struct net_device *dev)
>   	 * Rx and Tx descriptors needs 256 bytes alignment.
>   	 * dma_alloc_coherent provides more.
>   	 */
> -	tp->TxDescArray = dma_alloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
> +	tp->TxDescArray = dma_zalloc_coherent(&pdev->dev, R8169_TX_RING_BYTES,
>   					     &tp->TxPhyAddr, GFP_KERNEL);
>   	if (!tp->TxDescArray)
>   		goto err_pm_runtime_put;
>
Why? Why is zero-filling of tx-ring critical???

Ivan
