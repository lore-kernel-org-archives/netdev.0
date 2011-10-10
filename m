From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: tpacket_destruct_skb, deref skb after
 BUG_ON assertion
Date: Mon, 10 Oct 2011 18:06:24 +0200
Message-ID: <1318262784.3227.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111009171919.10922hrx8qjm2f7b@webmail.your-server.de>
	 <1318193866.21116.3.camel@edumazet-laptop>
	 <20111010100203.15066m7nvqod58cb@webmail.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:64226 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab1JJQGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:06:09 -0400
Received: by gyg10 with SMTP id 10so5474543gyg.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 09:06:08 -0700 (PDT)
In-Reply-To: <20111010100203.15066m7nvqod58cb@webmail.your-server.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 10:02 +0200, danborkmann@iogearbox.net =
a
=C3=A9crit :

> Thanks, you're absolutely right! Here's the trivial patch:
>=20
> af_packet: removed unnecessary BUG_ON assertion in tpacket_destruct_s=
kb
>=20

OK but a proper title should be=20

[PATCH] af_packet: remove unnecessary BUG_ON() in tpacket_destruct_skb


> If skb is NULL, then stack trace is thrown on anyway on dereference. =
=20
> Therefore,
> the stack trace triggered by BUG_ON is duplicate.
>=20
> Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>
>=20

missing "---" separator

> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index fabb4fa..886ae50 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -1170,8 +1170,6 @@ static void tpacket_destruct_skb(struct sk_buff=
 *skb)
>   	struct packet_sock *po =3D pkt_sk(skb->sk);
>   	void *ph;
>=20
> -	BUG_ON(skb =3D=3D NULL);
> -
>   	if (likely(po->tx_ring.pg_vec)) {
>   		ph =3D skb_shinfo(skb)->destructor_arg;
>   		BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SENDING);
>=20
>=20

Please send a complete new mail without any history.
