From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Unexpected loss recovery in TLP
Date: Wed, 02 Sep 2015 06:34:53 -0700
Message-ID: <1441200893.8932.191.camel@edumazet-glaptop2.roam.corp.google.com>
References: <3D743BF2-C02D-4E89-91AE-7E7F1D95AED5@kau.se>
	 <1441110692.8932.168.camel@edumazet-glaptop2.roam.corp.google.com>
	 <607F6E96-FABE-4C4E-8383-D9F27DD3C0E8@kau.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Mohammad Rajiullah <mohammad.rajiullah@kau.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32862 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbIBNe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 09:34:56 -0400
Received: by pacex6 with SMTP id ex6so6923103pac.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 06:34:56 -0700 (PDT)
In-Reply-To: <607F6E96-FABE-4C4E-8383-D9F27DD3C0E8@kau.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-02 at 10:54 +0200, Mohammad Rajiullah wrote:
> Hi Eric!
>=20
> Thanks for the direction. I tried packet drill locally (with the same=
 kernel Linux 3.18.5 to start with)
> with the following script. And it doesn=E2=80=99t show the problem I =
mentioned.=20
> So the fast retransmit happens after getting the dupack.
> It would be good if I could get some information from the calls=20
> from the TCP stack (I have some printk there), but using packet drill=
 I don=E2=80=99t know at the moment,
> how to get that.=20
>=20

Please do not top post on netdev mailing list.

You could try nstat before/after the failure and report anomalies here.

> \
> Mohammad
>=20
>=20
> // Establish a connection.
> 0   socket(..., SOCK_STREAM, IPPROTO_TCP) =3D 3
> +0  setsockopt(3, SOL_SOCKET, SO_REUSEADDR, [1], 4) =3D 0
> +0  setsockopt(3, SOL_SOCKET, TCP_NODELAY, [1], 4) =3D 0
>=20
> +0  bind(3, ..., ...) =3D 0
> +0  listen(3, 1) =3D 0
>=20
> +0  < S 0:0(0) win 32792 <mss 1000,sackOK,nop,nop,nop,wscale 7>
> +0  > S. 0:0(0) ack 1 <...>
>=20
> +.03 < . 1:1(0) ack 1 win 257
> +0  accept(3, ..., ...) =3D 4
>=20
> // Send 1 data segment and get an ACK with DATA
> +0  write(4, ..., 1000) =3D 1000

Note the original tcpdump you gave seemed to use len=3D250, could you t=
ry
the exact same lengths ?

Thanks !
