From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Mon, 30 Apr 2012 20:24:23 -0700
Message-ID: <1335842663.26217.10.camel@joe2Laptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:49596 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753410Ab2EADYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 23:24:25 -0400
In-Reply-To: <1335838029.11396.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 04:07 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> TCP or UDP stacks have big enough latencies that prefetching next
> pointer is worth it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/core/sock.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 836bca6..1a88351 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1700,6 +1700,7 @@ static void __release_sock(struct sock *sk)
>  		do {
>  			struct sk_buff *next = skb->next;
>  
> +			prefetch(next);
>  			WARN_ON_ONCE(skb_dst_is_noref(skb));
>  			skb->next = NULL;
>  			sk_backlog_rcv(sk, skb);

Hi Eric.

Why should next be "prefetch"ed when
two lines below it's set to null and
the only use is as a pointer not as
an apparently undereferenced pointer?
