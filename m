From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [ANNOUNCE]: Release of iptables-1.4.11
Date: Fri, 27 May 2011 13:55:22 +0200
Message-ID: <4DDF912A.5070003@netfilter.org>
References: <4DDE857E.40807@trash.net> <4DDE8814.7090201@trash.net> <201105270952.44811.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@osdl.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, NetDev <netdev@vger.kernel.org>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46380 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696Ab1E0Lzd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 May 2011 07:55:33 -0400
In-Reply-To: <201105270952.44811.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/05/11 09:52, Arkadiusz Miskiewicz wrote:
> On Thursday 26 of May 2011, Patrick McHardy wrote:
>> Am 26.05.2011 18:53, schrieb Patrick McHardy:
>>> The netfilter coreteam presents:
>>>     iptables version 1.4.10
>>
>> That's supposed to read 1.4.11 of course :)
>=20
> Too bad it breaks iproute2 build, hope to see fixed iproute2 release =
then
>=20
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -
> DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\" -DCONFIG_GACT -DCONFIG_GA=
CT_PROB -
> DIPT_LIB_DIR=3D\"/usr/lib64/xtables\" -Wl,-export-dynamic -shared -fp=
ic -o=20
> q_atm.so q_atm.c -latm
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -
> DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\" -DCONFIG_GACT -DCONFIG_GA=
CT_PROB -
> DIPT_LIB_DIR=3D\"/usr/lib64/xtables\" -Wl,-export-dynamic -shared -fp=
ic -o=20
> m_xt.so m_xt.c -lxtables
> m_xt.c: In function =E2=80=98parse_ipt=E2=80=99:
> m_xt.c:167:31: warning: passing argument 2 of =E2=80=98xtables_merge_=
options=E2=80=99 discards=20
> =E2=80=98const=E2=80=99 qualifier from pointer target type [enabled b=
y default]
> /usr/include/xtables.h:395:23: note: expected =E2=80=98struct option =
*=E2=80=99 but argument=20
> is of type =E2=80=98const struct option *=E2=80=99
> m_xt.c:167:31: warning: passing argument 3 of =E2=80=98xtables_merge_=
options=E2=80=99 from=20
> incompatible pointer type [enabled by default]
> /usr/include/xtables.h:395:23: note: expected =E2=80=98const struct o=
ption *=E2=80=99 but=20
> argument is of type =E2=80=98unsigned int *=E2=80=99
> m_xt.c:167:31: error: too few arguments to function =E2=80=98xtables_=
merge_options=E2=80=99
> /usr/include/xtables.h:395:23: note: declared here
> m_xt.c:127:6: warning: variable =E2=80=98res=E2=80=99 set but not use=
d [-Wunused-but-set-
> variable]
> m_xt.c: In function =E2=80=98print_ipt=E2=80=99:
> m_xt.c:312:30: warning: passing argument 2 of =E2=80=98xtables_merge_=
options=E2=80=99 discards=20
> =E2=80=98const=E2=80=99 qualifier from pointer target type [enabled b=
y default]
> /usr/include/xtables.h:395:23: note: expected =E2=80=98struct option =
*=E2=80=99 but argument=20
> is of type =E2=80=98const struct option *=E2=80=99
> m_xt.c:312:30: warning: passing argument 3 of =E2=80=98xtables_merge_=
options=E2=80=99 from=20
> incompatible pointer type [enabled by default]
> /usr/include/xtables.h:395:23: note: expected =E2=80=98const struct o=
ption *=E2=80=99 but=20
> argument is of type =E2=80=98unsigned int *=E2=80=99
> m_xt.c:312:30: error: too few arguments to function =E2=80=98xtables_=
merge_options=E2=80=99
> /usr/include/xtables.h:395:23: note: declared here
> make[1]: *** [m_xt.so] B=C5=82=C4=85d 1
> rm emp_ematch.lex.c emp_ematch.yacc.c

Backward compatibility was broken in the following iptables commit:

=46rom 600f38db82548a683775fd89b6e136673e924097 Mon Sep 17 00:00:00 200=
1
=46rom: Jan Engelhardt <jengelh@medozas.de>
Date: Fri, 29 Oct 2010 18:57:42 +0200
Subject: [PATCH] libxtables: change option precedence order to be intui=
tive
