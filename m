From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: Re: [RFC] Patch to Abstract Ethernet PHY support (using driver model)
Date: Mon, 17 Jan 2005 18:17:16 +0100
Message-ID: <20050117171715.GA21744@wohnheim.fh-wedel.de>
References: <FC6D9B81-5514-11D9-8D51-000393C30512@freescale.com> <A3A281FF-5525-11D9-80ED-000393C30512@freescale.com> <20050106070245.GA6539@gate.ebshome.net> <61A37C72-659C-11D9-8D70-000393C30512@freescale.com> <20050113212152.GA16041@gate.ebshome.net> <20050113215808.GA15124@wohnheim.fh-wedel.de> <20050114010016.GA16635@gate.ebshome.net> <20050114145518.GA21418@wohnheim.fh-wedel.de> <4D217F72-666F-11D9-8D70-000393C30512@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Kumar Gala <kumar.gala@freescale.com>, Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
Content-Disposition: inline
In-Reply-To: <4D217F72-666F-11D9-8D70-000393C30512@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 January 2005 15:00:20 -0600, Andy Fleming wrote:
> >
> >Wrt. the proposed PHY lib, I agree.  Didn't even bother to look at the
> >code, it's mere size said enough.

Ok, this time I did bother to look at the code...

> Hmm... Before I spend too much time revising based on previous comments=
=20
> ebs made, is there a general consensus that the code is much too large?=
=20
>  I know there's a lot in there, but the goal is to simplify PHY=20
> management for all ethernet drivers, new and old, and thus reduce code=20
> size, overall.  Is this code heading in the right direction?  Does it=20
> do too much?  Too little?

 drivers/net/Kconfig          |   33 +-
 drivers/net/Makefile         |    3=20
 drivers/net/phy/Kconfig      |   45 +++
 drivers/net/phy/Makefile     |    9=20
 drivers/net/phy/cicada.c     |  165 +++++++++++
 drivers/net/phy/davicom.c    |  277 +++++++++++++++++++
 drivers/net/phy/lxt.c        |  237 +++++++++++++++++
 drivers/net/phy/marvell.c    |  173 ++++++++++++
 drivers/net/phy/mdio_bus.c   |  173 ++++++++++++
 drivers/net/phy/phy.c        |  512 ++++++++++++++++++++++++++++++++++++
 drivers/net/phy/phy_device.c |  598 ++++++++++++++++++++++++++++++++++++=
+++++++
 drivers/net/phy/qsemi.c      |  183 +++++++++++++
 include/linux/phy.h          |  355 +++++++++++++++++++++++++
 13 files changed, 2743 insertions(+), 20 deletions(-)

Imo, the general idea to combine phy code makes sense - to a degree.
Advantage is less code copied over most existing drivers.  But few
people have more than one driver compiled in (or loaded, in case of
modules) at a time, so that bloat is source code only.  The big danger
here is that real compiled kernels will actually grow.

As an example, drivers that don't bother with suspend/resume should
have a slightly smaller binary, compared to generic code that supports
it.  There are valid reasons why people might want such a device, so
no size fits 'em all.

If you manage to convert existing drivers to your new proposed model,
you can show some numbers.  Is the compiled kernel smaller or bigger
after your changes.  About the same?

If there is significant growth, I'm pretty unexcited about the idea.
If it shrinks, you're a genius and sure, the patch should go in.  With
roughly the same binary size, you can point to code size and show how
that has decreased.

Right now, all I see is more code and I get this feeling that binary
size will grow as well.  So please try to prove me wrong.

J=F6rn

--=20
Time? What's that? Time is only worth what you do with it.
-- Theo de Raadt
