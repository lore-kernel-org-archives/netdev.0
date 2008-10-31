From: David Miller <davem@davemloft.net>
Subject: Re: tbench wrt. loopback TSO
Date: Fri, 31 Oct 2008 02:47:39 -0700 (PDT)
Message-ID: <20081031.024739.30392024.davem@davemloft.net>
References: <Pine.LNX.4.64.0810272113280.13973@wrl-59.cs.helsinki.fi>
	<20081031.011411.238617852.davem@davemloft.net>
	<Pine.LNX.4.64.0810311106140.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zbr@ioremap.net, netdev@vger.kernel.org, efault@gmx.de,
	mingo@elte.hu, a.p.zijlstra@chello.nl, herbert@gondor.apana.org.au
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751668AbYJaJsG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 05:48:06 -0400
In-Reply-To: <Pine.LNX.4.64.0810311106140.7072@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 31 Oct 2008 11:16:21 +0200 (EET)

> On Fri, 31 Oct 2008, David Miller wrote:
>=20
> > From: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
> > Date: Tue, 28 Oct 2008 00:17:00 +0200 (EET)
> >=20
> > > > Another modulo sits in tcp_mss_split_point().
> > >=20
> > > I know it's there but it should occur not that often.
> >=20
> > It happens every sendmsg() call, and all tbench does is small send,
> > small recv, repeat.
>=20
> This is not true for the mss_split_point case which I was speaking of=
, I=20
> even explained this in the part following that first sentence which y=
ou=20
> choose to snip away:
>=20
> If you have pcount =3D=3D 1 (len <=3D mss implies that) that won't ev=
en execute=20
> and rest of the cases involve handling rwin limited & nagle. I suppos=
e we=20
> could make nagle to work without splitting the skb to sub-mss (needs =
some=20
> auditting to find out if something else than snd_sml setting assumes=20
> skb->len < mss, nagle check probably as well but I don't remember w/o=
=20
> looking).
>=20
> To reiterate, with small send you have pcount =3D=3D 1 and that won't=
 execute=20
> any of the mss_split_point code!
>=20
> The tcp_current_mss code is a different beast (if you meant that, I=20
> didn't :-)), yes it executes every so often but I was under impressio=
n=20
> that we agreed on it already. :-)

My bad, tcp_current_mss() is what I thought your first sentence was abo=
ut.

> > So with TSO on, a small increase in performance is no surprise, as
> > we will save some cycles often enough.
>=20
> Also tcp_send_fin seems to do tcp_current_mss(sk, 1) so it's at least=
 two=20
> modulos per transaction...

True, but not for tbench. :-)

=46or tbench that one is benign as this will only execute once for each
thread during the entire benchmark.  Each thread starts up immediately,
opens up the connection, and then goes back and forth send/recv over
and over again for each SAMBA transaction being simulated.  Then at
the end each per-thread socket is closed.
