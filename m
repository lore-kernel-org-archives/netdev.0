From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: a problem tcp_v4_err()
Date: Fri, 12 Nov 2010 22:18:38 +0100
Message-ID: <1289596718.2743.2.camel@edumazet-laptop>
References: <1289585578.3185.268.camel@edumazet-laptop>
	 <20101112182959.GA20459@ms2.inr.ac.ru>
	 <1289586803.3185.275.camel@edumazet-laptop>
	 <20101112.112224.112610807.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kuznet@ms2.inr.ac.ru, kaber@trash.net, equinox@diac24.net,
	eparis@redhat.com, hzhong@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, paul.moore@hp.com,
	damian@tvk.rwth-aachen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49947 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756991Ab0KLVSo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 16:18:44 -0500
In-Reply-To: <20101112.112224.112610807.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 12 novembre 2010 =C3=A0 11:22 -0800, David Miller a =C3=A9c=
rit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 12 Nov 2010 19:33:23 +0100
>=20
> > I CC Damian Lukowski in my previous answer (and this one too)
>=20
> Probably the safest fix is this:
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 8f8527d..69ccbc1 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -415,6 +415,9 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 inf=
o)
>  		    !icsk->icsk_backoff)
>  			break;
> =20
> +		if (sock_owned_by_user(sk))
> +			break;
> +
>  		icsk->icsk_backoff--;
>  		inet_csk(sk)->icsk_rto =3D __tcp_set_rto(tp) <<
>  					 icsk->icsk_backoff;
> @@ -429,11 +432,6 @@ void tcp_v4_err(struct sk_buff *icmp_skb, u32 in=
fo)
>  		if (remaining) {
>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
>  						  remaining, TCP_RTO_MAX);
> -		} else if (sock_owned_by_user(sk)) {
> -			/* RTO revert clocked out retransmission,
> -			 * but socket is locked. Will defer. */
> -			inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
> -						  HZ/20, TCP_RTO_MAX);
>  		} else {
>  			/* RTO revert clocked out retransmission.
>  			 * Will retransmit now */


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



