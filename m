From: =?iso-8859-15?q?Lothar_Wa=DFmann?= <LW@KARO-electronics.de>
Subject: Re: use after free bug in socket code
Date: Wed, 8 Jul 2009 08:37:37 +0200
Message-ID: <19028.16049.907160.45293@ipc1.ka-ro>
References: <19020.39270.408816.360526@ipc1.ka-ro>
	<20090706.190709.214907244.davem@davemloft.net>
	<19026.62063.501414.659047@ipc1.ka-ro>
	<20090707.081930.92299470.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:49994 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755829AbZGHGhn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 02:37:43 -0400
In-Reply-To: <20090707.081930.92299470.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

David Miller writes:
> From: Lothar Wa=DFmann <LW@KARO-electronics.de>
> Date: Tue, 7 Jul 2009 08:59:59 +0200
>=20
> > To me it seems much more logical to invalidate any references from
> > some object 'B' (struct sock) to some object 'A' (struct socket) wh=
en
> > object 'A' is being released rather than invalidating them when obj=
ect
> > 'B' is being released.
>=20
> Because B should hold a reference to A in that situation.
>=20
> If one object refers to another, it should grab and hold a reference
> to that object.
>
So, could you point me to the place where the reference count of the
socket object is being incremented when a struct sock is associated
with it?
In sock_init_data() where the pointers in question are being
initialized I don't see anything like that:
|	sk_set_socket(sk, sock);
|
|	sock_set_flag(sk, SOCK_ZAPPED);
|
|	if (sock) {
|		sk->sk_type	=3D	sock->type;
|		sk->sk_sleep	=3D	&sock->wait;
|		sock->sk	=3D	sk;
|	} else
|		sk->sk_sleep	=3D	NULL;

with sk_set_socket() being:
|static inline void sk_set_socket(struct sock *sk, struct socket *sock)
|{
|	sk->sk_socket =3D sock;
|}



Lothar Wa=DFmann
--=20
___________________________________________________________

Ka-Ro electronics GmbH | Pascalstra=DFe 22 | D - 52076 Aachen
Phone: +49 2408 1402-0 | Fax: +49 2408 1402-10
Gesch=E4ftsf=FChrer: Matthias Kaussen
Handelsregistereintrag: Amtsgericht Aachen, HRB 4996

www.karo-electronics.de | info@karo-electronics.de
___________________________________________________________
