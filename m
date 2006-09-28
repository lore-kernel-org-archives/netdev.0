From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [GIT PATCH] NET: Fixes for net-2.6.19
Date: Thu, 28 Sep 2006 16:27:04 -0700
Message-ID: <20060928162704.55e863ca@freekitty>
References: <20060928083645.786b1ab1@freekitty>
	<20060928.143304.83622307.davem@davemloft.net>
	<20060928155052.63ed5ce8@freekitty>
	<20060928.160458.00452499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36743 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751061AbWI1X12 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 19:27:28 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060928.160458.00452499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 28 Sep 2006 16:04:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Thu, 28 Sep 2006 15:50:52 -0700
>=20
> > On Thu, 28 Sep 2006 14:33:04 -0700 (PDT)
> > David Miller <davem@davemloft.net> wrote:
> >=20
> > > From: Stephen Hemminger <shemminger@osdl.org>
> > > Date: Thu, 28 Sep 2006 08:36:45 -0700
> > >=20
> > > > Please figure out how to keep rtnetlink.h useful from user spac=
e.
> > > > I tried putting the current sanitized version of rtnetlink.h in=
to
> > > > iproute2 and the build fails.=20
> > >=20
> > > Please give the error so I have a chance of fixing this.
> >=20
> > If I put 2.6.19 headers in:
> >=20
> >=20
> > In file included from ../include/linux/rtnetlink.h:5,
> >                  from ../include/libnetlink.h:6,
> >                  from ll_map.c:23:
> > /usr/include/linux/if.h:117: error: redefinition of $,1rxstruct ifm=
ap$,1ry
> > /usr/include/linux/if.h:153: error: redefinition of $,1rxstruct ifr=
eq$,1ry
> > /usr/include/linux/if.h:203: error: redefinition of $,1rxstruct ifc=
onf$,1ry
>=20
> Hmmm... we explicitly removed the "linux/if.h" inclusion from
> rtnetlink.h so this is weird.  Where is the linux/if.h include coming
> from?
>=20

It got added by this:

commit 0844565fb8a9418f5a860aa480c1aef70319c9a2
Author: Thomas Graf <tgraf@suug.ch>
Date:   Fri Aug 4 23:05:56 2006 -0700

    [NET]: Move netlink interface bits to linux/if.h
   =20
    Signed-off-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 890c4d4..84f3eb4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -2,6 +2,7 @@ #ifndef __LINUX_RTNETLINK_H
 #define __LINUX_RTNETLINK_H
=20
 #include <linux/netlink.h>
+#include <linux/if.h>
=20
 /****
  *		Routing/neighbour discovery messages.

Note: if I put a santized version if linux/if.h in the iproute2, then i=
t
gets more errors as well:

In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:26:1: warning: "IFNAMSIZ" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:130:1: warning: this is the location of the previ=
ous definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:30:1: warning: "IFF_UP" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:46:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:31:1: warning: "IFF_BROADCAST" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:48:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:32:1: warning: "IFF_DEBUG" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:50:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:33:1: warning: "IFF_LOOPBACK" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:52:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:34:1: warning: "IFF_POINTOPOINT" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:54:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:35:1: warning: "IFF_NOTRAILERS" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:56:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:36:1: warning: "IFF_RUNNING" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:58:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:37:1: warning: "IFF_NOARP" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:60:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:38:1: warning: "IFF_PROMISC" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:62:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:39:1: warning: "IFF_ALLMULTI" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:66:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:41:1: warning: "IFF_MASTER" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:69:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:42:1: warning: "IFF_SLAVE" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:71:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:44:1: warning: "IFF_MULTICAST" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:74:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:46:1: warning: "IFF_PORTSEL" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:77:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:47:1: warning: "IFF_AUTOMEDIA" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:79:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:48:1: warning: "IFF_DYNAMIC" redefined
In file included from ll_map.c:20:
/usr/include/net/if.h:81:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ll_map.c:23:
=2E./include/linux/if.h:120: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
=2E./include/linux/if.h:156: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
=2E./include/linux/if.h:206: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
ll_map.c: In function =E2=80=98ll_remember_index=E2=80=99:
ll_map.c:55: warning: implicit declaration of function =E2=80=98IFLA_RT=
A=E2=80=99
ll_map.c:55: warning: implicit declaration of function =E2=80=98IFLA_PA=
YLOAD=E2=80=99
ll_map.c:55: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=80=
=99 makes pointer from integer without a cast
make[1]: *** [ll_map.o] Error 1
ipaddress.c: In function =E2=80=98print_linkinfo=E2=80=99:
ipaddress.c:151: warning: implicit declaration of function =E2=80=98IFL=
A_RTA=E2=80=99
ipaddress.c:151: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c: In function =E2=80=98print_addrinfo=E2=80=99:
ipaddress.c:285: error: =E2=80=98IFA_MAX=E2=80=99 undeclared (first use=
 in this function)
ipaddress.c:285: error: (Each undeclared identifier is reported only on=
ce
ipaddress.c:285: error: for each function it appears in.)
ipaddress.c:291: error: dereferencing pointer to incomplete type
ipaddress.c:300: warning: implicit declaration of function =E2=80=98IFA=
_RTA=E2=80=99
ipaddress.c:300: error: dereferencing pointer to incomplete type
ipaddress.c:300: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c:302: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:303: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:307: error: dereferencing pointer to incomplete type
ipaddress.c:309: error: dereferencing pointer to incomplete type
ipaddress.c:311: error: dereferencing pointer to incomplete type
ipaddress.c:316: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:319: error: dereferencing pointer to incomplete type
ipaddress.c:327: error: dereferencing pointer to incomplete type
ipaddress.c:334: error: dereferencing pointer to incomplete type
ipaddress.c:358: error: dereferencing pointer to incomplete type
ipaddress.c:358: error: dereferencing pointer to incomplete type
ipaddress.c:359: error: dereferencing pointer to incomplete type
ipaddress.c:361: error: dereferencing pointer to incomplete type
ipaddress.c:363: error: dereferencing pointer to incomplete type
ipaddress.c:365: error: dereferencing pointer to incomplete type
ipaddress.c:368: error: dereferencing pointer to incomplete type
ipaddress.c:371: error: dereferencing pointer to incomplete type
ipaddress.c:378: error: dereferencing pointer to incomplete type
ipaddress.c:381: error: dereferencing pointer to incomplete type
ipaddress.c:385: error: dereferencing pointer to incomplete type
ipaddress.c:389: error: =E2=80=98IFA_BROADCAST=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:391: error: dereferencing pointer to incomplete type
ipaddress.c:396: error: =E2=80=98IFA_ANYCAST=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:398: error: dereferencing pointer to incomplete type
ipaddress.c:403: error: dereferencing pointer to incomplete type
ipaddress.c:404: error: dereferencing pointer to incomplete type
ipaddress.c:404: error: =E2=80=98IFA_F_SECONDARY=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:405: error: dereferencing pointer to incomplete type
ipaddress.c:408: error: dereferencing pointer to incomplete type
ipaddress.c:408: error: =E2=80=98IFA_F_TENTATIVE=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:409: error: dereferencing pointer to incomplete type
ipaddress.c:412: error: dereferencing pointer to incomplete type
ipaddress.c:412: error: =E2=80=98IFA_F_DEPRECATED=E2=80=99 undeclared (=
first use in this function)
ipaddress.c:413: error: dereferencing pointer to incomplete type
ipaddress.c:416: error: dereferencing pointer to incomplete type
ipaddress.c:416: error: =E2=80=98IFA_F_PERMANENT=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:419: error: dereferencing pointer to incomplete type
ipaddress.c:420: error: dereferencing pointer to incomplete type
ipaddress.c:421: error: dereferencing pointer to incomplete type
ipaddress.c:424: error: =E2=80=98IFA_CACHEINFO=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:428: error: dereferencing pointer to incomplete type
ipaddress.c:431: error: dereferencing pointer to incomplete type
ipaddress.c:432: error: dereferencing pointer to incomplete type
ipaddress.c:435: error: dereferencing pointer to incomplete type
ipaddress.c:285: warning: unused variable =E2=80=98rta_tb=E2=80=99
ipaddress.c: In function =E2=80=98print_selected_addrinfo=E2=80=99:
ipaddress.c:462: error: dereferencing pointer to incomplete type
ipaddress.c:463: error: dereferencing pointer to incomplete type
ipaddress.c: In function =E2=80=98ipaddr_list_or_flush=E2=80=99:
ipaddress.c:538: error: =E2=80=98IFA_F_PERMANENT=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:544: error: =E2=80=98IFA_F_SECONDARY=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:550: error: =E2=80=98IFA_F_TENTATIVE=E2=80=99 undeclared (f=
irst use in this function)
ipaddress.c:553: error: =E2=80=98IFA_F_DEPRECATED=E2=80=99 undeclared (=
first use in this function)
ipaddress.c:655: error: dereferencing pointer to incomplete type
ipaddress.c:656: error: dereferencing pointer to incomplete type
ipaddress.c:658: error: dereferencing pointer to incomplete type
ipaddress.c:660: error: dereferencing pointer to incomplete type
ipaddress.c:663: error: =E2=80=98IFA_MAX=E2=80=99 undeclared (first use=
 in this function)
ipaddress.c:664: warning: implicit declaration of function =E2=80=98IFA=
_PAYLOAD=E2=80=99
ipaddress.c:664: warning: passing argument 3 of =E2=80=98parse_rtattr=E2=
=80=99 makes pointer from integer without a cast
ipaddress.c:665: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:666: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:671: error: dereferencing pointer to incomplete type
ipaddress.c:679: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:682: error: dereferencing pointer to incomplete type
ipaddress.c:663: warning: unused variable =E2=80=98tb=E2=80=99
ipaddress.c: In function =E2=80=98ipaddr_modify=E2=80=99:
ipaddress.c:738: error: field =E2=80=98ifa=E2=80=99 has incomplete type
ipaddress.c:754: error: invalid application of =E2=80=98sizeof=E2=80=99=
 to incomplete type =E2=80=98struct ifaddrmsg=E2=80=99=20
ipaddress.c:770: error: =E2=80=98IFA_ADDRESS=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:786: error: =E2=80=98IFA_BROADCAST=E2=80=99 undeclared (fir=
st use in this function)
ipaddress.c:797: error: =E2=80=98IFA_ANYCAST=E2=80=99 undeclared (first=
 use in this function)
ipaddress.c:812: error: =E2=80=98IFA_LABEL=E2=80=99 undeclared (first u=
se in this function)
ipaddress.c:825: error: =E2=80=98IFA_LOCAL=E2=80=99 undeclared (first u=
se in this function)
make[1]: *** [ipaddress.o] Error 1
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:26:1: warning: "IFNAMSIZ" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:130:1: warning: this is the location of the previ=
ous definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:30:1: warning: "IFF_UP" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:46:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:31:1: warning: "IFF_BROADCAST" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:48:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:32:1: warning: "IFF_DEBUG" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:50:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:33:1: warning: "IFF_LOOPBACK" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:52:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:34:1: warning: "IFF_POINTOPOINT" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:54:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:35:1: warning: "IFF_NOTRAILERS" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:56:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:36:1: warning: "IFF_RUNNING" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:58:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:37:1: warning: "IFF_NOARP" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:60:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:38:1: warning: "IFF_PROMISC" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:62:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:39:1: warning: "IFF_ALLMULTI" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:66:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:41:1: warning: "IFF_MASTER" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:69:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:42:1: warning: "IFF_SLAVE" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:71:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:44:1: warning: "IFF_MULTICAST" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:74:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:46:1: warning: "IFF_PORTSEL" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:77:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:47:1: warning: "IFF_AUTOMEDIA" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:79:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:48:1: warning: "IFF_DYNAMIC" redefined
In file included from tc_filter.c:18:
/usr/include/net/if.h:81:1: warning: this is the location of the previo=
us definition
In file included from ../include/linux/rtnetlink.h:5,
                 from ../include/libnetlink.h:6,
                 from ../include/utils.h:7,
                 from tc_filter.c:27:
=2E./include/linux/if.h:120: error: redefinition of =E2=80=98struct ifm=
ap=E2=80=99
=2E./include/linux/if.h:156: error: redefinition of =E2=80=98struct ifr=
eq=E2=80=99
=2E./include/linux/if.h:206: error: redefinition of =E2=80=98struct ifc=
onf=E2=80=99
make[1]: *** [tc_filter.o] Error 1
/usr/bin/ld: cannot find -lnetlink
collect2: ld returned 1 exit status
make[1]: *** [ss] Error 1
make[1]: *** No rule to make target `../lib/libnetlink.a', needed by `g=
enl'.  Stop.
make: *** [all] Error 2




--=20
Stephen Hemminger <shemminger@osdl.org>
