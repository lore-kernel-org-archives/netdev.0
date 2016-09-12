From: Helmut Buchsbaum <helmut.buchsbaum@gmail.com>
Subject: Re: [PATCH -next] net: macb: fix missing unlock on error in
 macb_start_xmit()
Date: Mon, 12 Sep 2016 19:40:27 +0200
Message-ID: <1119c72d-2731-4bb4-bc52-316a5611c48b@gmail.com>
References: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>,
        Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34028 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755691AbcILRkg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 13:40:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id g141so3659059wmd.1
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 10:40:36 -0700 (PDT)
In-Reply-To: <1473506277-31304-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/10/2016 01:17 PM, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
>
> Fix missing unlock before return from function macb_start_xmit()
> in the error handling case.
>
> Fixes: 007e4ba3ee13 ("net: macb: initialize checksum when using
> checksum offloading")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
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
You are definitely right. Sorry I missed that obvious point and for 
causing any inconveniences.

BTW, I see there are obviously quite a few users of MACB 
implementations. I'm just curious if anybody else ever encountered the 
checksum problem or if this a matter of Zynq implementation only.

Regards,
Helmut
