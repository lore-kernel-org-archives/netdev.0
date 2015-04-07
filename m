From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next 2/4] xfrm: simplify xfrm_address_t use
Date: Tue, 7 Apr 2015 18:29:58 +0200
Message-ID: <20150407182958.51a7b13f@griffin>
References: <cover.1427639592.git.jbenc@redhat.com>
	<e70181767cd48da03733b6817466085c4629ff9a.1427639592.git.jbenc@redhat.com>
	<20150407090133.0cb6cf4b@urahara>
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
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55423 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818AbbDGQaF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 12:30:05 -0400
In-Reply-To: <20150407090133.0cb6cf4b@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Apr 2015 09:01:33 -0700, Stephen Hemminger wrote:
> This change to the uapi header ends up breaking the iproute2 build
> when the headers are used.
>=20
> gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declara=
tions -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HO=
STNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SO=
URCE -DHAVE_SETNS   -c -o xfrm_monitor.o xfrm_monitor.c
> In file included from ../include/linux/xfrm.h:4:0,
>                  from xfrm_monitor.c:30:
> ../include/linux/in6.h:131:26: error: expected identifier before nume=
ric constant
>  #define IPPROTO_HOPOPTS  0 /* IPv6 hop-by-hop options */
>                           ^
> In file included from /usr/include/resolv.h:57:0,
>                  from ../include/utils.h:6,
>                  from xfrm_monitor.c:31:
> /usr/include/netinet/in.h:209:8: error: redefinition of =E2=80=98stru=
ct in6_addr=E2=80=99

This was fixed by commit cfd280c91253c ("net: sync some IP headers with
glibc"). The obvious problem is that you need glibc with its part of
the fix applied, too:
https://sourceware.org/git/gitweb.cgi?p=3Dglibc.git;a=3Dcommitdiff;h=3D=
6c82a2f8

Seems to be present in glibc 2.19. I agree this is unfortunate.

What could be done that should work with earlier glibc versions is
including "utils.h" before <linux/xfrm.h> in xfrm_monitor.c. Could you
try that? Would it be an acceptable workaround?

Thanks,

 Jiri

--=20
Jiri Benc
