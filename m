From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH] inet, inet6: make tcp_sendmsg() and tcp_sendpage() through
 inet_sendmsg() and inet_sendpage()
Date: Sat, 10 Jul 2010 21:45:18 -0700
Message-ID: <4C394C5E.2000805@chelsio.com>
References: <1278819894-2861-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23289 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767Ab0GKEqS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 00:46:18 -0400
In-Reply-To: <1278819894-2861-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:

> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index 3ceb025..1e5bad1 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -727,28 +727,31 @@ int inet_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
>  	sock_rps_record_flow(sk);
>  
>  	/* We may need to bind the socket. */
> -	if (!inet_sk(sk)->inet_num && inet_autobind(sk))
> +	if (!sk->sk_prot->no_autobind &&
> +	    !inet_sk(sk)->inet_num && inet_autobind(sk))
>  		return -EAGAIN;

I think it's better to test inet_num first since usually it's not 0.  With 
the above ordering protocols with no_autobind==false end up making two 
comparisons.
