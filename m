From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] tcp: unalias tcp_skb_cb flags and ip_dsfield
Date: Tue, 27 Sep 2011 12:28:44 +0300
Message-ID: <201109271228.44232.christoph.paasch@uclouvain.be>
References: <1317103249.2796.25.camel@edumazet-laptop> <201109271138.00318.christoph.paasch@uclouvain.be> <1317115409.2541.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hkchu@google.com, ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:44522 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594Ab1I0J2t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 05:28:49 -0400
In-Reply-To: <1317115409.2541.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric,

On Tuesday 27 September 2011 wrote Eric Dumazet:
> Le mardi 27 septembre 2011 =C3=A0 11:38 +0300, Christoph Paasch a =C3=
=A9crit :
> > On Tuesday 27 September 2011 wrote David Miller:
> > This two-byte hole, is it because "flags" and "sacked" are both __u=
8 and=20
> > fields are aligned to 32-bit ?
>=20
> Not exactly.
>=20
> Reason for the hole is the following :
>=20
> struct whatever {
>         u8   first;
>         u8   second;
>         u32  third;
> };
>=20
> "third" field has an alignement requirement of 4 bytes on most arches=
=2E
>=20
> Compiler inserts a 2 bytes hole before "third" to respect this
> requirement.
>=20
> There is no hole between "first" and "second", since second has no
> alignment requirement.
>=20
> sizeof(struct whatever) =3D 8


Ok, I understand.
Thanks for the info. I didn't knew this...

It's good news...
Maybe we win now a little bit of space in MultiPath TCP by rearranging =
our=20
fields... :-)


Cheers,
Christoph


--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=C3=A9 Catholique de Louvain

www.rollerbulls.be
--
