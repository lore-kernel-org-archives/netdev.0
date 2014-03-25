From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 03/54] 3c59x: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:04:19 -0700
Message-ID: <1395752659.12610.110.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-3-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61558 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbaCYNEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:04:21 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so422356pad.7
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:04:21 -0700 (PDT)
In-Reply-To: <1395727540-12148-3-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in vortex_start_xmit
> as it can be called in hard irq and other contexts.
> 
> dev_consume_skb_any is used when vortext_start_xmit directly consumes
> the packet instead of dmaing it to the device.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/3com/3c59x.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
> index 238ccea965c8..61477b8e8d24 100644
> --- a/drivers/net/ethernet/3com/3c59x.c
> +++ b/drivers/net/ethernet/3com/3c59x.c
> @@ -2086,7 +2086,7 @@ vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		/* ... and the packet rounded to a doubleword. */
>  		skb_tx_timestamp(skb);
>  		iowrite32_rep(ioaddr + TX_FIFO, skb->data, (skb->len + 3) >> 2);
> -		dev_kfree_skb (skb);
> +		dev_consume_skb_any (skb);
>  		if (ioread16(ioaddr + TxFree) > 1536) {
>  			netif_start_queue (dev);	/* AKPM: redundant? */
>  		} else {

remove the extra space ?

Acked-by: Eric Dumazet <edumazet@google.com>
