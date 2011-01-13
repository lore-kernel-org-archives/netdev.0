From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: remove duplicate th = tcp_hdr(skb)
Date: Thu, 13 Jan 2011 16:59:03 +0100
Message-ID: <1294934343.3570.253.camel@edumazet-laptop>
References: <1294933302-28469-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57700 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab1AMP7J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 10:59:09 -0500
Received: by wyb28 with SMTP id 28so1848644wyb.19
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 07:59:08 -0800 (PST)
In-Reply-To: <1294933302-28469-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 16:41 +0100, Christoph Paasch a =C3=A9c=
rit :
> th is already set some lines before to be th =3D tcp_hdr(skb).
>=20
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/ipv4/tcp_ipv4.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 856f684..7fe29c6 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1644,7 +1644,6 @@ int tcp_v4_rcv(struct sk_buff *skb)
>  	if (!skb_csum_unnecessary(skb) && tcp_v4_checksum_init(skb))
>  		goto bad_packet;
> =20

Well... no please.

> -	th =3D tcp_hdr(skb);
>  	iph =3D ip_hdr(skb);
>  	TCP_SKB_CB(skb)->seq =3D ntohl(th->seq);
>  	TCP_SKB_CB(skb)->end_seq =3D (TCP_SKB_CB(skb)->seq + th->syn + th->=
fin +

Hint : pskb_may_pull() can change tcp_hdr(skb) result.


