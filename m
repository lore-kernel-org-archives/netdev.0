From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH -next] net: macb: fix missing unlock on error in
 macb_start_xmit()
Date: Mon, 12 Sep 2016 09:38:06 +0200
Message-ID: <38d7d9ba-bb2e-53d0-8a61-0e0e0ad97c38@atmel.com>
References: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.242]:22654 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754396AbcILHiI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 03:38:08 -0400
In-Reply-To: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/09/2016 à 13:17, Wei Yongjun a écrit :
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix missing unlock before return from function macb_start_xmit()
> in the error handling case.
> 
> Fixes: 007e4ba3ee13 ("net: macb: initialize checksum when using
> checksum offloading")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Yes,
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks. Best regards,

> ---
>  drivers/net/ethernet/cadence/macb.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 0294b6a..63144bb 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -1398,7 +1398,7 @@ static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	if (macb_clear_csum(skb)) {
>  		dev_kfree_skb_any(skb);
> -		return NETDEV_TX_OK;
> +		goto unlock;
>  	}
>  
>  	/* Map socket buffer for DMA transfer */
> 
> 


-- 
Nicolas Ferre
