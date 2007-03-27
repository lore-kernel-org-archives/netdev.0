From: Jose Alberto Reguero <jareguero@telefonica.net>
Subject: Re: Problem with sockets an 2.6.21-rc5 kernel
Date: Wed, 28 Mar 2007 00:06:14 +0200
Message-ID: <200703280006.14791.jareguero@telefonica.net>
References: <200703262303.21448.jareguero@telefonica.net> <200703271741.09949.jareguero@telefonica.net> <200703272030.37843.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.telefonica.net ([213.4.149.66]:46972 "EHLO
	ctsmtpout2.frontal.correo" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932778AbXC0WJg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 18:09:36 -0400
In-Reply-To: <200703272030.37843.jareguero@telefonica.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

El Martes, 27 de Marzo de 2007, Jose Alberto Reguero escribi=F3:
> El Martes, 27 de Marzo de 2007, Jose Alberto Reguero escribi=F3:
> > El Martes, 27 de Marzo de 2007, Evgeniy Polyakov escribi=F3:
> > > On Tue, Mar 27, 2007 at 04:29:11PM +0200, Jose Alberto Reguero
> >
> > (jareguero@telefonica.net) wrote:
> > > > El Martes, 27 de Marzo de 2007, Evgeniy Polyakov escribi=C3=B3:
> > > > > On Mon, Mar 26, 2007 at 11:03:21PM +0200, Jose Alberto Reguer=
o
> > > >
> > > > (jareguero@telefonica.net) wrote:
> > > > > > I had two python programs, server.py and client.py(attached=
)
> > > > > >
> > > > > > With server.py in  a kernel 2.6.21-rc5 x86_64 and client.py=
 in
> > > > > > the same machine,  server.py get the message.
> > > > > >
> > > > > > With server.py in  a kerner 2.6.21-rc5 x86_64 and client.py=
 in
> > > > > > another machine, server.py don't get the message.
> > > > > >
> > > > > > The same with the programs in c(attached).
> > > > > >
> > > > > > With kernel 2.6.20.3 the programs work well.
> > > > > >
> > > > > > There are something wrong in the programs?
> > > > >
> > > > > Besides full absence of error checks and coding style issues =
it
> > > > > does not seem to contain errors.
> > > > >
> > > > > And, btw, C program work with 2.6.21-rc5 (git tree
> > > > > e0f2e3a06be513352cb4955313ed7e55909acd84) on x86_64.
> > > > >
> > > > > server.c application compiled with Debian 4.1.1-21 compiler o=
n
> > > > > x86_64 sucessfully received message from 2.6.18-3 machine.
> > > >
> > > > Thanks. I thought it was a kernel BUG. It is a alt1 driver
> > > > BUG(Attansic(R) L1 Ethernet Network Driver). The error happens =
with
> > > > the atl1 driver that comes with kernel 2.6.21-rc5. With he orig=
inal
> > > > driver from ASUS for M2V motherboard modified to compile with k=
ernel
> > > > 2.6.21-rc5 there is no problems.
> > >
> > > Did it work with in-kernel driver?
> > > There is only one remotely related change in the driver:
> > >
> > > -	mta =3D ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
> > > +	mta =3D ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg =
<< 2));
> > >
> > > If it worked before, then spurious ioread() from outside of our
> > > univercity could lead to good/bad mta value (likely zero or ~0), =
so
> > > appropriate multicast list update could succeed.
> > >
> > > If your programs never worked with this new driver, then it can n=
ot be
> > > easily solved without hardware specifications.
> > >
> > > I added Jay Cliburn who submitted the driver to Cc list.
> > >
> > > > Jose Alberto
> >
> > The first time i try the kernel driver was with kernel 2.6.21-rc4, =
and
> > don't work.  I can help to debug the problem, with some help.
> >
> > I have a M2V motherboard with built-in Attansic(R) L1 Ethernet Netw=
ork
> > Driver and a Athlon 64 X2 Dual Core processor.
> >
> > Jose Alberto
>
> I found that the original driver has its own ether_crc_le function, t=
hat
> return the value inverted. The attached patch solve the problem.
>
> Jose Alberto

if yu you want to apply it in the case that you need it:

Signed-off-by: Jose Alberto Reguero <jareguero@telefonica.net>

Jose Alberto
