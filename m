From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 2/7] net: add dst_pending_confirm flag to
 skbuff
Date: Mon, 19 Dec 2016 08:17:32 -0800
Message-ID: <1482164252.1521.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>
         <1482094596-26046-3-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        YueHaibing <yuehaibing@huawei.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36014 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933782AbcLSQRt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 11:17:49 -0500
In-Reply-To: <1482094596-26046-3-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-12-18 at 22:56 +0200, Julian Anastasov wrote:

>  
> +static inline void sock_confirm_neigh(struct sk_buff *skb, struct neighbour *n)
> +{
> +	if (unlikely(skb->dst_pending_confirm)) {
> +		struct sock *sk = skb->sk;
> +		unsigned long now = jiffies;
> +
> +		/* avoid dirtying neighbour */
> +		if (n->confirmed != now)
> +			n->confirmed = now;
> +		if (sk && sk->sk_dst_pending_confirm)
> +			sk->sk_dst_pending_confirm = 0;
> +	}
> +}
> +

I am still digesting this awesome patch series ;)

Not sure why you used an unlikely() here. TCP for example would hit this
path quite often.

So considering sk_dst_pending_confirm might be dirtied quite often,

I am not sure why you placed it in the cache line that contains
sk_rx_dst (in 1st patch)

Thanks.
