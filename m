From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 02/54] 3c509: Call dev_consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:03:17 -0700
Message-ID: <1395752597.12610.109.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-2-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:65363 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbaCYNDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:03:21 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so404885pdj.34
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:03:21 -0700 (PDT)
In-Reply-To: <1395727540-12148-2-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Replace dev_kfree_skb with dev_consume_skb_any in el3_start_xmit
> as it can be called in hard irq and other contexts.
> 
> dev_consume_skb_any is used as on this simple hardware the
> skb is consumed directly by the start_xmit function.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/3com/3c509.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
> index c53384d41c96..35df0b9e6848 100644
> --- a/drivers/net/ethernet/3com/3c509.c
> +++ b/drivers/net/ethernet/3com/3c509.c
> @@ -749,7 +749,7 @@ el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	spin_unlock_irqrestore(&lp->lock, flags);
>  
> -	dev_kfree_skb (skb);
> +	dev_consume_skb_any (skb);
>  

Please remove the space ?

Acked-by: Eric Dumazet <edumazet@google.com>
