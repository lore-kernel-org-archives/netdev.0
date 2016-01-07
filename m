From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: Re: header conflict introduced by change to
 netfilter_ipv4/ip_tables.h
Date: Thu, 7 Jan 2016 09:29:50 +0200
Message-ID: <20160107072950.GB6104@lakka.kapsi.fi>
References: <20160106092007.1c5a0c75@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:42012 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbcAGH35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 02:29:57 -0500
Content-Disposition: inline
In-Reply-To: <20160106092007.1c5a0c75@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 06, 2016 at 09:20:07AM -0800, Stephen Hemminger wrote:
> This commit breaks compilation of iproute2 with net-next.

Ok, linux/if.h and libc net/if.h have overlapping defines, and this is =
not
the only one. I saw lots of them in the core dump headers.

How should we handle them? Another ifndef for IFNAMSIZ into kernel uapi
headers?

-Mikko

> commit 1ffad83dffd675cd742286ae82dca7d746cb0da8
> Author: Mikko Rapeli <mikko.rapeli@iki.fi>
> Date:   Thu Oct 15 07:56:30 2015 +0200
>=20
>     netfilter: fix include files for compilation
>    =20
>     Add missing header dependencies and other small changes so that e=
ach file
>     compiles alone in userspace.
>    =20
>     Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
>=20
> For iproute2, a copy of kernel headers (from make install_headers) is=
 used.
> After this change. the build of x_tables.c fails because IFNAMSIZ is =
already
> defined in net/if.h
>=20
> gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declara=
tions -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HO=
STNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SO=
URCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE=
  -DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DI=
R=3D\"/lib/xtables\" -DYY_NO_INPUT -Wl,-export-dynamic -shared -fpic -o=
 q_atm.so q_atm.c -latm
> gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declara=
tions -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HO=
STNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SO=
URCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE=
  -DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DI=
R=3D\"/lib/xtables\" -DYY_NO_INPUT -Wl,-export-dynamic -shared -fpic -o=
 m_xt.so m_xt.c $(pkg-config xtables --cflags --libs)
> In file included from ../include/linux/netfilter_ipv4/ip_tables.h:20:=
0,
>                  from m_xt.c:20:
> ../include/linux/if.h:26:0: warning: "IFNAMSIZ" redefined
>  #define IFNAMSIZ 16
>  ^
> In file included from m_xt.c:17:0:
> /usr/include/net/if.h:129:0: note: this is the location of the previo=
us definition
>  # define IFNAMSIZ IF_NAMESIZE
>  ^
> ../include/linux/if.h:71:2: error: redeclaration of enumerator =E2=80=
=98IFF_UP=E2=80=99
>   IFF_UP    =3D 1<<0,  /* sysfs */
>   ^
> /usr/include/net/if.h:44:5: note: previous definition of =E2=80=98IFF=
_UP=E2=80=99 was here
>      IFF_UP =3D 0x1,  /* Interface is up.  */
>      ^
> ../include/linux/if.h:72:2: error: redeclaration of enumerator =E2=80=
=98IFF_BROADCAST=E2=80=99
>   IFF_BROADCAST   =3D 1<<1,  /* __volatile__ */
>   ^
> /usr/include/net/if.h:46:5: note: previous definition of =E2=80=98IFF=
_BROADCAST=E2=80=99 was here
>      IFF_BROADCAST =3D 0x2, /* Broadcast address valid.  */
>      ^
> ../include/linux/if.h:73:2: error: redeclaration of enumerator =E2=80=
=98IFF_DEBUG=E2=80=99
>   IFF_DEBUG   =3D 1<<2,  /* sysfs */
