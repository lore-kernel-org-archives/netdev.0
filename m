From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 13:27:32 -0700
Message-ID: <20100517132732.2b7fc1a1@nehalam>
References: <4BF192F9.8000008@candelatech.com>
	<4BF1A352.5020500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38170 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782Ab0EQU1f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 May 2010 16:27:35 -0400
In-Reply-To: <4BF1A352.5020500@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 May 2010 13:13:06 -0700
Ben Greear <greearb@candelatech.com> wrote:

> On 05/17/2010 12:03 PM, Ben Greear wrote:
> > On older releases, you can do this with iproute:
> >
> > # ip ru add from 9.9.9.2/32 table 226 pref 400
> > #
> >
> > But, in latest git, it returns an error:
> > # ip ru add from 9.9.9.2/32 table 226 pref 400
> > Error: an inet prefix is expected rather than "9.9.9.2/32".
> >
> > Is that on purpose?
>=20
> I was thinking maybe this was a library issue, since I compiled
> on one machine and ran the 'ip' exe on another.  So, I tried compilin=
g
> on the test system.
>=20
> But, iproute will not compile, apparently because it finds the
> /usr/include/linux header files before whatever is packaged with
> iproute:
>=20
> gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLV=
E_HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ipaddress.o ipaddress.c
> ipaddress.c: In function =91print_linkinfo=92:
> ipaddress.c:334: error: =91IFLA_VFINFO=92 undeclared (first use in th=
is function)
> ipaddress.c:334: error: (Each undeclared identifier is reported only =
once
> ipaddress.c:334: error: for each function it appears in.)
> make[1]: *** [ipaddress.o] Error 1
> make[1]: Leaving directory `/root/git/iproute2/ip'
> make: *** [all] Error 2
>=20
>=20
> I tried moving /usr/include/linux out of the way, but then it blows u=
p
> even worse (can't find errno.h, etc)
>=20
> Are we supposed to be able to compile iproute2 on a system with moder=
ately
> outdated kernel headers?
>=20
> If not, why bother with the iproute/include/linux directory at all?

The issue is the last minute VF changes in 2.6.34 are not supported
in iproute util yet. Please wait until it is fixed.
