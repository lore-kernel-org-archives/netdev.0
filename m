From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Problem with sockets an 2.6.21-rc5 kernel
Date: Tue, 27 Mar 2007 18:46:59 +0400
Message-ID: <20070327144658.GA25125@2ka.mipt.ru>
References: <200703262303.21448.jareguero@telefonica.net> <20070327131256.GA7513@2ka.mipt.ru> <200703271629.11814.jareguero@telefonica.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: Jose Alberto Reguero <jareguero@telefonica.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:56957 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932112AbXC0Orq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 10:47:46 -0400
Content-Disposition: inline
In-Reply-To: <200703271629.11814.jareguero@telefonica.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 27, 2007 at 04:29:11PM +0200, Jose Alberto Reguero (jaregue=
ro@telefonica.net) wrote:
> El Martes, 27 de Marzo de 2007, Evgeniy Polyakov escribi=C3=B3:
> > On Mon, Mar 26, 2007 at 11:03:21PM +0200, Jose Alberto Reguero=20
> (jareguero@telefonica.net) wrote:
> > > I had two python programs, server.py and client.py(attached)
> > >
> > > With server.py in  a kernel 2.6.21-rc5 x86_64 and client.py in th=
e same
> > > machine,  server.py get the message.
> > >
> > > With server.py in  a kerner 2.6.21-rc5 x86_64 and client.py in an=
other
> > > machine, server.py don't get the message.
> > >
> > > The same with the programs in c(attached).
> > >
> > > With kernel 2.6.20.3 the programs work well.
> > >
> > > There are something wrong in the programs?
> >
> > Besides full absence of error checks and coding style issues it doe=
s not
> > seem to contain errors.
> >
> > And, btw, C program work with 2.6.21-rc5 (git tree
> > e0f2e3a06be513352cb4955313ed7e55909acd84) on x86_64.
> >
> > server.c application compiled with Debian 4.1.1-21 compiler on x86_=
64
> > sucessfully received message from 2.6.18-3 machine.
>=20
> Thanks. I thought it was a kernel BUG. It is a alt1 driver BUG(Attans=
ic(R) L1=20
> Ethernet Network Driver). The error happens with the atl1 driver that=
 comes=20
> with kernel 2.6.21-rc5. With he original driver from ASUS for M2V mot=
herboard=20
> modified to compile with kernel 2.6.21-rc5 there is no problems.

Did it work with in-kernel driver?
There is only one remotely related change in the driver:

-	mta =3D ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
+	mta =3D ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2))=
;

If it worked before, then spurious ioread() from outside of our
univercity could lead to good/bad mta value (likely zero or ~0), so app=
ropriate=20
multicast list update could succeed.

If your programs never worked with this new driver, then it can not be
easily solved without hardware specifications.

I added Jay Cliburn who submitted the driver to Cc list.

> Jose Alberto

--=20
	Evgeniy Polyakov
