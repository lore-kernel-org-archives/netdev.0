From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: Section conflict compile failures in net
Date: Fri, 27 May 2011 18:04:37 -0500
Message-ID: <1306537477.12244.13.camel@mulgrave.site>
References: <1306445993.4048.58.camel@mulgrave.site>
	 <20110527080728.GA2108@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:41457 "EHLO
	bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755239Ab1E0XEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 May 2011 19:04:40 -0400
In-Reply-To: <20110527080728.GA2108@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-05-27 at 10:07 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> On Thu, May 26, 2011 at 04:39:53PM -0500, James Bottomley wrote:
> > I'm now getting a ton of errors like this in git head:
> >=20
> >   CC [M]  drivers/net/3c59x.o
> >   CC [M]  drivers/net/hp100.o
> >   CC [M]  drivers/net/ne3210.o
> >   CC [M]  drivers/net/3c509.o
> >   CC [M]  drivers/net/depca.o
> > drivers/net/ne3210.c:83: error: irq_map causes a section type confl=
ict
> > drivers/net/ne3210.c:85: error: shmem_map causes a section type con=
flict
> > drivers/net/ne3210.c:89: error: ifmap_val causes a section type con=
flict
> > drivers/net/ne3210.c:319: error: ne3210_ids causes a section type c=
onflict
> > make[2]: *** [drivers/net/ne3210.o] Error 1
> > make[2]: *** Waiting for unfinished jobs....
> > drivers/net/hp100.c:198: error: hp100_eisa_tbl causes a section typ=
e conflict
> > drivers/net/hp100.c:211: error: hp100_pci_tbl causes a section type=
 conflict
> > make[2]: *** [drivers/net/hp100.o] Error 1
> > drivers/net/depca.c:544: error: de1xx_irq causes a section type con=
flict
> > drivers/net/depca.c:545: error: de2xx_irq causes a section type con=
flict
> > drivers/net/depca.c:546: error: de422_irq causes a section type con=
flict
> [...]
>=20
> Those three are only used in depca_hw_init() marked __devinit. What c=
ompiler
> [flags] do you use to build this?

It's a standard debian one.

jejb@ion> hppa64-linux-gnu-gcc -v
Using built-in specs.
Target: hppa64-linux-gnu
Configured with: ../src/configure --enable-languages=3Dc --prefix=3D/us=
r
--libexecdir=3D/usr/lib --disable-shared --disable-nls --disable-thread=
s
--disable-libffi --disable-libgomp --disable-libmudflap --disable-libss=
p
--with-as=3D/usr/bin/hppa64-linux-gnu-as
--with-ld=3D/usr/bin/hppa64-linux-gnu-ld
--includedir=3D/usr/hppa64-linux-gnu/include --host=3Dhppa-linux-gnu
--build=3Dhppa-linux-gnu --target=3Dhppa64-linux-gnu
Thread model: single
gcc version 4.2.4 (Debian 4.2.4-6)

the problem is definitely the depca_irq[i] in the loop ... replace that
with a constant and the error goes away.

James


