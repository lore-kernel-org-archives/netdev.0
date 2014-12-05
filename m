From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] net: avoid to call skb_queue_len again
Date: Fri, 05 Dec 2014 05:24:41 -0800
Message-ID: <1417785881.4322.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:33569 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaLENYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 08:24:46 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so755638igi.3
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 05:24:45 -0800 (PST)
In-Reply-To: <1417772948-17909-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-12-05 at 17:49 +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> the queue length of sd->input_pkt_queue has been putted into qlen,
> and impossible to change, since hold the lock
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/core/dev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0814a56..b954400 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3297,7 +3297,7 @@ static int enqueue_to_backlog(struct sk_buff *skb, int cpu,
>  	rps_lock(sd);
>  	qlen = skb_queue_len(&sd->input_pkt_queue);
>  	if (qlen <= netdev_max_backlog && !skb_flow_limit(skb, qlen)) {
> -		if (skb_queue_len(&sd->input_pkt_queue)) {
> +		if (qlen) {
>  enqueue:
>  			__skb_queue_tail(&sd->input_pkt_queue, skb);
>  			input_queue_tail_incr_save(sd, qtail);

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
