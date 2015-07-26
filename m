From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next] r8169: correct size from ... (snip)
Date: Mon, 27 Jul 2015 00:58:01 +0200
Message-ID: <20150726225801.GA14837@electric-eye.fr.zoreil.com>
References: <1437945567-2495-1-git-send-email-corcodel.marian@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Corcodel Marian <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:41517 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753303AbbGZW6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 18:58:18 -0400
Content-Disposition: inline
In-Reply-To: <1437945567-2495-1-git-send-email-corcodel.marian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corcodel Marian <corcodel.marian@gmail.com> :
[...]
> @@ -7594,7 +7595,7 @@ static int rtl_open(struct net_device *dev)
>  	if (!tp->TxDescArray)
>  		goto err_pm_runtime_put;
>  
> -	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, R8169_RX_RING_BYTES,
> +	tp->RxDescArray = dma_alloc_coherent(&pdev->dev, rx_buf_sz,
>  					     &tp->RxPhyAddr, GFP_KERNEL);

1. RxDescArray is the descriptor ring. It does not care about rx_buf_sz.

2. I don't see how R8169_RX_RING_BYTES could reach 17000:

#define NUM_RX_DESC     256U    /* Number of Rx descriptor registers */
[...]
#define R8169_RX_RING_BYTES     (NUM_RX_DESC * sizeof(struct RxDesc))
[...]
struct RxDesc {
        __le32 opts1;
        __le32 opts2;   
        __le64 addr;
};

256 * 16 = 4096

3. The Subject: field should not include the verbose change description.

-- 
Ueimor
