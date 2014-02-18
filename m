From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: remove unneeded dependency of mvneta and
 update help text
Date: Tue, 18 Feb 2014 14:23:22 -0300
Message-ID: <20140218172321.GB10691@localhost>
References: <1392719391-8851-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <20140218122952.GM7862@titan.lakedaemon.net>
 <20140218134532.7607a616@skate>
 <20140218125206.GN7862@titan.lakedaemon.net>
 <20140218141303.77c77272@skate>
 <20140218135809.GD17984@lunn.ch>
 <20140218151027.710ab2f3@skate>
 <20140218154512.GA10691@localhost>
 <20140218165128.5535a9ef@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:47125 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751221AbaBRRX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 12:23:29 -0500
Content-Disposition: inline
In-Reply-To: <20140218165128.5535a9ef@skate>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 04:51:28PM +0100, Thomas Petazzoni wrote:
> On Tue, 18 Feb 2014 12:45:12 -0300, Ezequiel Garcia wrote:
>=20
> > > At the very end of the clean up, when even Orion5x support will b=
e
> > > merged in mach-mvebu/, then we can certainly replace these depend=
encies
> > > by a "depends on ARCH_MVEBU". But for the time being, PLAT_ORION =
seems
> > > like the right common denominator for all these platforms.
> > >=20
> >=20
> > Last time we talked about this with Sebastian and Andrew it was dec=
ided
> > that the right choice is:
> >=20
> >   MACH_KIRKWOOD || MACH_DOVE || MACH_ARMADA_370_XP
>=20
> And why not Orion5x and MV78xx0 ?
>=20

Ouch, I confused s/MARCH/ARCH. What I meant to say is that instead of
PLAT_ORION, it was agreed to use:

  ARCH_ORION5X || ARCH_KIRKWOOD || ARCH_DOVE || ARCH_MVEBU

See here for the previous discussion:

http://www.spinics.net/lists/devicetree/msg19091.html

We discussed the issue on its own thread:

http://www.spinics.net/lists/devicetree/msg19159.html

> >=20
> > Which would become MACH_MVEBU.
> >=20
> > Of course, this is near the nitpick boundary, so AFAIC you can leav=
e
> > PLAT_ORION as in v2, if you feel like.
>=20
> As I suggested previously, PLAT_ORION is what *today* controls the
> visibility of all Marvell EBU drivers. Please grep for PLAT_ORION in
> your kernel tree.

Again, it has been agreed that those are all wrong and should all
be replaced by proper ARCH_whatever. Then, we'll probably be able to
stop selecting PLAT_ORION from ARCH_MVEBU.

> So why on earth would we invent something completely
> different for mvneta?
>=20

I don't have a strong opinion, it just feels wrong to have a different
rule each time. If you look at the watchdog patches, you'll notice we'v=
e
changed it to depend on ARCH_whatever.

So now you propose to go with PLAT_ORION. I'm fine with either of them;
but I think we should decide between one of them and stick to it, inste=
ad
of each of us having its own rule.
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
