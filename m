From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fixed a TFO server bug that crashed kernel by raw
 sockets
Date: Wed, 19 Sep 2012 07:12:06 +0200
Message-ID: <1348031526.26523.278.camel@edumazet-glaptop>
References: <1348011351-13882-1-git-send-email-hkchu@google.com>
	 <4380003.jOHRfqhomY@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "H.K. Jerry Chu" <hkchu@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:55815 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab2ISFMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 01:12:09 -0400
Received: by wgbdr13 with SMTP id dr13so519432wgb.1
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 22:12:08 -0700 (PDT)
In-Reply-To: <4380003.jOHRfqhomY@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 02:19 +0200, Christoph Paasch wrote:

> Why not moving the TCP-code out of inet_sock_destruct by modifying the sk_destruct
> callback when TFO is in use? Like the below (only compile-tested) patch. That
> way inet_sock_destruct stays TFO-free.
> 
> 
> Cheers,
> Christoph
> 
> ---------
> 
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Wed, 19 Sep 2012 02:06:53 +0200
> Subject: [PATCH] Don't add TCP-code in inet_sock_destruct
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  include/linux/tcp.h |    4 ++++
>  net/ipv4/af_inet.c  |    2 --
>  net/ipv4/tcp.c      |    7 +++++++
>  3 files changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index ae46df5..67c789a 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -574,6 +574,8 @@ static inline bool fastopen_cookie_present(struct tcp_fastopen_cookie *foc)
>  	return foc->len != -1;
>  }
>  
> +extern void tcp_sock_destruct(struct sock *sk);
> +
>  static inline int fastopen_init_queue(struct sock *sk, int backlog)
>  {
>  	struct request_sock_queue *queue =
> @@ -585,6 +587,8 @@ static inline int fastopen_init_queue(struct sock *sk, int backlog)
>  		    sk->sk_allocation);
>  		if (queue->fastopenq == NULL)
>  			return -ENOMEM;
> +
> +		sk->sk_destruct = tcp_sock_destruct;
>  		spin_lock_init(&queue->fastopenq->lock);

Yes, it seems much better, thanks !

Acked-by: Eric Dumazet <edumazet@google.com>
