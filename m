From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 2/4] xfrm: simplify xfrm_address_t use
Date: Tue, 7 Apr 2015 09:01:33 -0700
Message-ID: <20150407090133.0cb6cf4b@urahara>
References: <cover.1427639592.git.jbenc@redhat.com>
	<e70181767cd48da03733b6817466085c4629ff9a.1427639592.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Chapman <jchapman@katalix.com>,
	Paul Moore <paul@paul-moore.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35491 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbbDGQBa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 12:01:30 -0400
Received: by pddn5 with SMTP id n5so83257206pdd.2
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 09:01:29 -0700 (PDT)
In-Reply-To: <e70181767cd48da03733b6817466085c4629ff9a.1427639592.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Mar 2015 16:59:24 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> In many places, the a6 field is typecasted to struct in6_addr. As the
> fields are in union anyway, just add in6_addr type to the union and
> get rid of the typecasting.
>=20
> Modifying the uapi header is okay, the union has still the same size.
>=20
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

This change to the uapi header ends up breaking the iproute2 build
when the headers are used.

gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarati=
ons -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HOST=
NAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SOUR=
CE -DHAVE_SETNS   -c -o xfrm_monitor.o xfrm_monitor.c
In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_monitor.c:30:
=2E./include/linux/in6.h:131:26: error: expected identifier before nume=
ric constant
 #define IPPROTO_HOPOPTS  0 /* IPv6 hop-by-hop options */
                          ^
In file included from /usr/include/resolv.h:57:0,
                 from ../include/utils.h:6,
                 from xfrm_monitor.c:31:
/usr/include/netinet/in.h:209:8: error: redefinition of =E2=80=98struct=
 in6_addr=E2=80=99
 struct in6_addr
        ^
In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_monitor.c:30:
=2E./include/linux/in6.h:32:8: note: originally defined here
 struct in6_addr {
        ^
In file included from /usr/include/resolv.h:57:0,
                 from ../include/utils.h:6,
                 from xfrm_monitor.c:31:
/usr/include/netinet/in.h:252:8: error: redefinition of =E2=80=98struct=
 sockaddr_in6=E2=80=99
 struct sockaddr_in6
        ^
In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_monitor.c:30:
=2E./include/linux/in6.h:49:8: note: originally defined here
 struct sockaddr_in6 {
        ^
In file included from /usr/include/resolv.h:57:0,
                 from ../include/utils.h:6,
                 from xfrm_monitor.c:31:
/usr/include/netinet/in.h:288:8: error: redefinition of =E2=80=98struct=
 ipv6_mreq=E2=80=99
 struct ipv6_mreq
        ^
In file included from ../include/linux/xfrm.h:4:0,
                 from xfrm_monitor.c:30:
=2E./include/linux/in6.h:59:8: note: originally defined here
 struct ipv6_mreq {
        ^
<builtin>: recipe for target 'xfrm_monitor.o' failed
make[1]: *** [xfrm_monitor.o] Error 1
make[1]: Leaving directory '/var/src/iproute2/ip'
Makefile:48: recipe for target 'all' failed
