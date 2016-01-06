From: Stephen Hemminger <shemming@brocade.com>
Subject: header conflict introduced by change to netfilter_ipv4/ip_tables.h
Date: Wed, 6 Jan 2016 09:20:07 -0800
Message-ID: <20160106092007.1c5a0c75@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <netfilter-devel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:30935 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751582AbcAFRUJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 12:20:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit breaks compilation of iproute2 with net-next.

commit 1ffad83dffd675cd742286ae82dca7d746cb0da8
Author: Mikko Rapeli <mikko.rapeli@iki.fi>
Date:   Thu Oct 15 07:56:30 2015 +0200

    netfilter: fix include files for compilation
   =20
    Add missing header dependencies and other small changes so that eac=
h file
    compiles alone in userspace.
   =20
    Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

=46or iproute2, a copy of kernel headers (from make install_headers) is=
 used.
After this change. the build of x_tables.c fails because IFNAMSIZ is al=
ready
defined in net/if.h

gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarati=
ons -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HOST=
NAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SOUR=
CE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  =
-DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=3D=
\"/lib/xtables\" -DYY_NO_INPUT -Wl,-export-dynamic -shared -fpic -o q_a=
tm.so q_atm.c -latm
gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarati=
ons -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HOST=
NAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SOUR=
CE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  =
-DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DIR=3D=
\"/lib/xtables\" -DYY_NO_INPUT -Wl,-export-dynamic -shared -fpic -o m_x=
t.so m_xt.c $(pkg-config xtables --cflags --libs)
In file included from ../include/linux/netfilter_ipv4/ip_tables.h:20:0,
                 from m_xt.c:20:
=2E./include/linux/if.h:26:0: warning: "IFNAMSIZ" redefined
 #define IFNAMSIZ 16
 ^
In file included from m_xt.c:17:0:
/usr/include/net/if.h:129:0: note: this is the location of the previous=
 definition
 # define IFNAMSIZ IF_NAMESIZE
 ^
=2E./include/linux/if.h:71:2: error: redeclaration of enumerator =E2=80=
=98IFF_UP=E2=80=99
  IFF_UP    =3D 1<<0,  /* sysfs */
  ^
/usr/include/net/if.h:44:5: note: previous definition of =E2=80=98IFF_U=
P=E2=80=99 was here
     IFF_UP =3D 0x1,  /* Interface is up.  */
     ^
=2E./include/linux/if.h:72:2: error: redeclaration of enumerator =E2=80=
=98IFF_BROADCAST=E2=80=99
  IFF_BROADCAST   =3D 1<<1,  /* __volatile__ */
  ^
/usr/include/net/if.h:46:5: note: previous definition of =E2=80=98IFF_B=
ROADCAST=E2=80=99 was here
     IFF_BROADCAST =3D 0x2, /* Broadcast address valid.  */
     ^
=2E./include/linux/if.h:73:2: error: redeclaration of enumerator =E2=80=
=98IFF_DEBUG=E2=80=99
  IFF_DEBUG   =3D 1<<2,  /* sysfs */
