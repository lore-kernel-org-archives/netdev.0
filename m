From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Fri, 14 Jan 2005 16:49:51 +0100
Message-ID: <20050114154951.GC21418@wohnheim.fh-wedel.de>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net> <20050113215808.GA15124@wohnheim.fh-wedel.de> <20050114010016.GA16635@gate.ebshome.net> <20050114145518.GA21418@wohnheim.fh-wedel.de> <20050114152518.GB23768@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>,
        Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20050114152518.GB23768@gate.ebshome.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 January 2005 07:25:18 -0800, Eugene Surovegin wrote:
> On Fri, Jan 14, 2005 at 03:55:18PM +0100, J?rn Engel wrote:
> > Wrt. the proposed PHY lib, I agree.  Didn't even bother to look at th=
e
> > code, it's mere size said enough.
> >=20
> > But an abstraction different from drivers/net/mii.c is needed to
> > handle the 5325 chip.  Or, you could have the special cases all over
> > in your code, but that's a) ugly and b) more code.  I used to have
> > such a mess and after doing the proper abstraction, it line count wen=
t
> > down.
>=20
> Well, I still fail to see what is so _special_ about this chip that it=20
> needs "proper abstraction". Could you elaborate, please?
>=20
> The way I handled this in my drivers was clean and simple -=20
> "there-is-no-PHY". And this wasn't in any case chip-specific and was=20
> set up through OCP in board support code. So I'm kinda puzzled what=20
> "ugliness and more code" you are talking about.
>=20
> We can also make a fake PHY which will always indicate link, will have=20
> fixed speed/duplex capabilities and will not support autoneg. If you=20
> think this is more elegant, OK, I might even agree with you :).

Exactly.  You need link status, speed and duplex status at the least.
Put query functions for those three into a struct phy_ops or whatever
it may be called and you're done.

Depending on your hardware, you may also need something more
complicated for various fixups, etc.  But it's mostly those three
functions.

> Please, note that wrt current discussion we are interested only in CPU=20
> port, not other 5 ports which aren't connected to the CPU at all. This=20
> is completely different stuff and yes, if we want to expose them in=20
> some way we need another abstraction. But abstraction of switch chips=20
> is a big and complex thing - they are very different, and frankly this=20
> one you mentioned is quite "feature-challenged" and will not make=20
> a good "model" chip IMHO :).

Well, it's one of the few I've had to worry about so far.  I'm a big
non-believer in abstractions I just don't need yet.  The one outlined
above I already needed.

J=F6rn

--=20
To announce that there must be no criticism of the President, or that we
are to stand by the President, right or wrong, is not only unpatriotic
and servile, but is morally treasonable to the American public.
-- Theodore Roosevelt, Kansas City Star, 1918
