From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: inet_diag: always export IPV6_V6ONLY sockopt
Date: Thu, 09 Jul 2015 14:57:57 +0200
Message-ID: <1436446677.24939.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1436431347-720-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Eric Dumazet <edumazet@google.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:35229 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbbGIM6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 08:58:02 -0400
Received: by wiga1 with SMTP id a1so312267075wig.0
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 05:58:01 -0700 (PDT)
In-Reply-To: <1436431347-720-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-09 at 10:42 +0200, Phil Sutter wrote:
> Reconsidering my commit 20462155 "net: inet_diag: export IPV6_V6ONLY
> sockopt", I am not happy with the limitations it causes for socket
> analysing code in userspace. Exporting the value only if it is set makes
> it hard for userspace to decide whether the option is not set or the
> kernel does not support exporting the option at all.
> 
> From an auditor's perspective, the interesting question for AF_INET6
> sockets is: "Does it NOT have IPV6_V6ONLY set?" Because it is the
> unexpected case. This patch allows to answer this question reliably.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> Cc: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/inet_diag.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
> index 9bc2667..e622d2e 100644
> --- a/net/ipv4/inet_diag.c
> +++ b/net/ipv4/inet_diag.c
> @@ -152,8 +152,7 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
>  				       inet6_sk(sk)->tclass) < 0)
>  				goto errout;
>  
> -		if (ipv6_only_sock(sk) &&
> -		    nla_put_u8(skb, INET_DIAG_SKV6ONLY, 1))
> +		if (nla_put_u8(skb, INET_DIAG_SKV6ONLY, ipv6_only_sock(sk)))
>  			goto errout;
>  	}
>  #endif

Okay, I guess you don't dump millions of sockets.

Can you remind me why this attribute is useful for non listening
sockets ?

It looks you are interested to know if a _listener_ is v6 only or not.
