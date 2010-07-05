From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Possible bug in net/ipv4/route.c?
Date: Mon, 05 Jul 2010 22:18:07 +0200
Message-ID: <1278361087.2466.107.camel@edumazet-laptop>
References: <20100705120617.GA6267@gondor.apana.org.au>
	 <1278334754.2877.173.camel@edumazet-laptop>
	 <20100705132245.GA6876@gondor.apana.org.au>
	 <1278336898.2877.212.camel@edumazet-laptop>
	 <20100705200728.GB11096@khazad-dum.debian.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:46412 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab0GEUSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 16:18:13 -0400
In-Reply-To: <20100705200728.GB11096@khazad-dum.debian.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 17:07 -0300, Henrique de Moraes Holschu=
h a
=C3=A9crit :
> On Mon, 05 Jul 2010, Eric Dumazet wrote:
> > Le lundi 05 juillet 2010 =C3=A0 21:22 +0800, Herbert Xu a =C3=A9cri=
t :
> > > On Mon, Jul 05, 2010 at 02:59:14PM +0200, Eric Dumazet wrote:
> > > >
> > > > Why do we clear full 48 bytes skb->cb[] in skb_alloc(), if no p=
rotocol
> > > > stack should rely it being zero ?
> > >=20
> > > Unless a protocol is allocating the skb itself, then the fact
> > > that skb_alloc clears skb->cb is no guarantee that the skb->cb
> > > will be zero.
> >=20
> > I see. We could :
> >=20
> > Avoid this memset(skb->cb, 0, sizeof(skb->cb)) in fastpath.
>=20
> Any chances of skb->cb being leaked to userspace or the network, due =
to
> driver bugs or other such oddities?
>=20

Not "a priori", but a bug is always possible ;)

cb[] is internal use only, should not be sent to network or user land.



