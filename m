From: =?UTF-8?Q?Kolbj=C3=B8rn_Barmen?= <kolbjorn.barmen@uninett.no>
Subject: Re: [PATCH v2] IPv6: Add 'autoconf' and 'disable_ipv6' module
 parameters
Date: Sun, 21 Jun 2009 06:04:22 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.0906210557500.11635@firda.kolla.no>
References: <4A204A31.4010105@hp.com> <20090601.030835.261332360.davem@davemloft.net> <4A23E014.4040909@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux@kolla.no, vladislav.yasevich@hp.com
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regensburg.uninett.no ([158.38.180.100]:32899 "EHLO
	regensburg.uninett.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbZFUEMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 00:12:12 -0400
In-Reply-To: <4A23E014.4040909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Jun 2009, Brian Haley wrote:

> David Miller wrote:
> > Applied, but really it is tiring fixing up all of the corruptions
> > your email client made to this patch.
> >=20
> > I've had this problem so many times with you that I've totally
> > lost any hope that you'll be able to submit patches cleanly and
> > thus I'm resigned to just fix them up every time from now on. :-/
>=20
> Sorry, I'll start sending them to myself first in the future.  Just r=
eject it
> next time and force me to do the work to fix it up as it was my fault=
=2E

I also had to edit the patch for linebreaks etc :)

Anyways... when I apply the patch and try too compile, I get:

net/ipv6/addrconf.c: In function 'addrconf_disable_ipv6':
net/ipv6/addrconf.c:4029: error: implicit declaration of function 'rest=
art_syscall'
make[2]: *** [net/ipv6/addrconf.o] Error 1
make[1]: *** [net/ipv6] Error 2


The relevant line is pointed out (->) below:

----
   static int addrconf_disable_ipv6(struct ctl_table *table, int *p, in=
t old)
   {
           struct net *net;
  =20
           net =3D (struct net *)table->extra2;
  =20
           if (p =3D=3D &net->ipv6.devconf_dflt->disable_ipv6)
                   return 0;
  =20
           if (!rtnl_trylock())
->                 return restart_syscall();
  =20
           if (p =3D=3D &net->ipv6.devconf_all->disable_ipv6) {
                   __s32 newf =3D net->ipv6.devconf_all->disable_ipv6;
                   net->ipv6.devconf_dflt->disable_ipv6 =3D newf;
                   addrconf_disable_change(net, newf);
           } else if ((!*p) ^ (!old))
                   dev_disable_change((struct inet6_dev *)table->extra1=
);
  =20
           rtnl_unlock();
           return 0;
   }
----

=46or what it's worth, I'm using gcc 4.3.3.

--=20
Kolbj=C3=B8rn Barmen
UNINETT Driftsenter
