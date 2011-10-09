From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: tpacket_destruct_skb, deref skb after
 BUG_ON assertion
Date: Sun, 09 Oct 2011 22:57:46 +0200
Message-ID: <1318193866.21116.3.camel@edumazet-laptop>
References: <20111009171919.10922hrx8qjm2f7b@webmail.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43295 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751537Ab1JIU5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 16:57:53 -0400
Received: by wyg34 with SMTP id 34so5331049wyg.19
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2011 13:57:52 -0700 (PDT)
In-Reply-To: <20111009171919.10922hrx8qjm2f7b@webmail.your-server.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 09 octobre 2011 =C3=A0 17:19 +0200, danborkmann@iogearbox.n=
et a
=C3=A9crit :
> This tiny patch derefs the skb only after BUG_ON(skb=3D=3DNULL) was e=
valuated
> and not before. Patched against latest Linus tree.
>=20
> Thanks,
> Daniel
>=20
> Signed-off-by: Daniel Borkmann <danborkmann@iogearbox.net>
>=20
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index fabb4fa..d9d833b 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1167,11 +1167,12 @@ ring_is_full:
>=20
>   static void tpacket_destruct_skb(struct sk_buff *skb)
>   {
> -	struct packet_sock *po =3D pkt_sk(skb->sk);
> +	struct packet_sock *po;
>   	void *ph;
>=20
>   	BUG_ON(skb =3D=3D NULL);
>=20
> +	po =3D pkt_sk(skb->sk);
>   	if (likely(po->tx_ring.pg_vec)) {
>   		ph =3D skb_shinfo(skb)->destructor_arg;
>   		BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDING);
>=20
>=20

Well, to be honest, this BUG_ON(!skb) is absolutely useless for two
reasons.

1) If skb happens to be NULL, the NULL dereference is trapped and stack
trace dumped as well.

2) Of course, tpacket_destruct_skb() being an skb destructor, skb canno=
t
be NULL at this point by design.

Please remove the BUG_ON() instead of trying to move it ;)

Thanks
