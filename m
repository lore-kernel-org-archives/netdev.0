From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: 2.6.24-rc5-mm1 - IPv6 throws section mismatches.
Date: Tue, 18 Dec 2007 16:12:42 +0100
Message-ID: <4767E36A.1030700@fr.ibm.com>
References: <20071213024050.7d6e5f3e.akpm@linux-foundation.org> <4509.1197958248@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:7494 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbXLRPRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2007 10:17:44 -0500
In-Reply-To: <4509.1197958248@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Valdis.Kletnieks@vt.edu wrote:
> On Thu, 13 Dec 2007 02:40:50 PST, Andrew Morton said:
>> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.24=
-rc5/2.6.24-rc5-mm1/
>=20
> git-net.patch (I'm guessing one of Daniel's commits, but not sure whi=
ch one)
> causes some complaints:
>=20
>   LD      vmlinux.o
>   MODPOST vmlinux.o
> WARNING: vmlinux.o(.init.text+0x2263f): Section mismatch: reference t=
o .exit.text:tcpv6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x22644): Section mismatch: reference t=
o .exit.text:udplitev6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x22649): Section mismatch: reference t=
o .exit.text:udpv6_exit (between 'inet6_init' and 'ac6_proc_init')
> WARNING: vmlinux.o(.init.text+0x22658): Section mismatch: reference t=
o .exit.text:addrconf_cleanup (between 'inet6_init' and 'ac6_proc_init'=
)
> WARNING: vmlinux.o(.init.text+0x226bc): Section mismatch: reference t=
o .exit.text:rawv6_exit (between 'inet6_init' and 'ac6_proc_init')
>=20
> Looks like the problem is that tcpv6_exit and friends are called from
> net/ipv6/af_inet6.c:inet6_init() - which is declared as:
>=20
> static int __init inet6_init(void)
>=20
> I can see how calling an __exit from an __init would be Bad Juju...
>=20

Yep, thanks Valdis for pointing that.

I sent a patch several days ago which fix that to DaveM and he applied=20
it to the latest net-2.6.25

--=20






















































Sauf indication contraire ci-dessus:
Compagnie IBM France
Si=E8ge Social : Tour Descartes, 2, avenue Gambetta, La D=E9fense 5, 92=
400
Courbevoie
RCS Nanterre 552 118 465
=46orme Sociale : S.A.S.
Capital Social : 542.737.118 ?
SIREN/SIRET : 552 118 465 02430
