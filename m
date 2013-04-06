From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: PROBLEM: IPv6 TCP-Connections resetting
Date: Sat, 06 Apr 2013 21:43:36 +0400
Message-ID: <51605EC8.7090900@cogentembedded.com>
References: <20130405174828.310a02c3@trediske.ws.office.manitu.net> <20130406043534.GC30194@order.stressinduktion.org> <1460015.zN3jPXiAbD@cpaasch-mac> <4796401.BXlLaoS7qO@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tetja Rediske <tetja@tetja.de>, djduanjiong@gmail.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:35668 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753542Ab3DFRoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Apr 2013 13:44:38 -0400
Received: by mail-lb0-f176.google.com with SMTP id y8so4559903lbh.7
        for <netdev@vger.kernel.org>; Sat, 06 Apr 2013 10:44:36 -0700 (PDT)
In-Reply-To: <4796401.BXlLaoS7qO@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-04-2013 13:18, Christoph Paasch wrote:

> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Sat, 6 Apr 2013 10:21:01 +0200
> Subject: [PATCH] ipv6/tcp: Stop processing ICMPv6 redirect messages

> Upon reception of an ICMPv6 Redirect message, we should not continue
> inside tcp_v6_err. Otherwise, an error will be reported or request-so=
cks
> will be closed.

> Adds also some parantheses to respect codingstyle guidelines.

    When you say "=E4lso", it's often a good indicator there should be =
another=20
patch -- like in this case.

> Reported-by: Tetja Rediske <tetja@tetja.de>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>   net/ipv6/tcp_ipv6.c | 7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)

> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 1033d2b..24434c5 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -386,6 +386,7 @@ static void tcp_v6_err(struct sk_buff *skb, struc=
t inet6_skb_parm *opt,
>
>   		if (dst)
>   			dst->ops->redirect(dst, sk, skb);
> +		goto out;
>   	}
>
>   	if (type =3D=3D ICMPV6_PKT_TOOBIG) {
> @@ -441,16 +442,18 @@ static void tcp_v6_err(struct sk_buff *skb, str=
uct inet6_skb_parm *opt,
>   			sk->sk_error_report(sk);		/* Wake people up to see the error (se=
e connect in sock.c) */
>
>   			tcp_done(sk);
> -		} else
> +		} else {
>   			sk->sk_err_soft =3D err;
> +		}
>   		goto out;
>   	}
>
>   	if (!sock_owned_by_user(sk) && np->recverr) {
>   		sk->sk_err =3D err;
>   		sk->sk_error_report(sk);
> -	} else
> +	} else {
>   		sk->sk_err_soft =3D err;
> +	}
>
>   out:
>   	bh_unlock_sock(sk);

WBR, Sergei
