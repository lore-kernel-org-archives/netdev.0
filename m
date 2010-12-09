From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] net/ipv6/udp.c: fix typo in flush_stack()
Date: Thu, 09 Dec 2010 14:48:08 +0100
Message-ID: <1291902488.4063.28.camel@edumazet-laptop>
References: <20101209134029.GB2820@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58112 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755065Ab0LINsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 08:48:12 -0500
Received: by wyb28 with SMTP id 28so2293786wyb.19
        for <netdev@vger.kernel.org>; Thu, 09 Dec 2010 05:48:11 -0800 (PST)
In-Reply-To: <20101209134029.GB2820@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 d=C3=A9cembre 2010 =C3=A0 14:40 +0100, Jiri Pirko a =C3=A9c=
rit :
> skb1 should be passed as parameter to sk_rcvqueues_full() here.
>=20
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>=20
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 91def93..d2b268e 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -602,7 +602,7 @@ static void flush_stack(struct sock **stack, unsi=
gned int count,
> =20
>  		sk =3D stack[i];
>  		if (skb1) {
> -			if (sk_rcvqueues_full(sk, skb)) {
> +			if (sk_rcvqueues_full(sk, skb1)) {
>  				kfree_skb(skb1);
>  				goto drop;
>  			}

net-2.6 ? Its the same truesize anyway...

So it's not a bug, but a cosmetic change.
(I am ok with it, but for net-next-2.6)

/*
 * Take into account size of receive queue and backlog queue
 */
static inline bool sk_rcvqueues_full(const struct sock *sk, const struc=
t sk_buff *skb)
{
        unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk=
_rmem_alloc);

        return qsize + skb->truesize > sk->sk_rcvbuf;
}


