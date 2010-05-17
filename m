From: Ben Greear <greearb@candelatech.com>
Subject: Re: iproute2 issue with adding rules.
Date: Mon, 17 May 2010 13:13:06 -0700
Message-ID: <4BF1A352.5020500@candelatech.com>
References: <4BF192F9.8000008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49892 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752656Ab0EQUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 16:13:08 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o4HKD651032444
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 May 2010 13:13:06 -0700
In-Reply-To: <4BF192F9.8000008@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/17/2010 12:03 PM, Ben Greear wrote:
> On older releases, you can do this with iproute:
>
> # ip ru add from 9.9.9.2/32 table 226 pref 400
> #
>
> But, in latest git, it returns an error:
> # ip ru add from 9.9.9.2/32 table 226 pref 400
> Error: an inet prefix is expected rather than "9.9.9.2/32".
>
> Is that on purpose?

I was thinking maybe this was a library issue, since I compiled
on one machine and ran the 'ip' exe on another.  So, I tried compiling
on the test system.

But, iproute will not compile, apparently because it finds the
/usr/include/linux header files before whatever is packaged with
iproute:

gcc -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall -I../include -DRESOLVE_=
HOSTNAMES -DLIBDIR=3D\"/usr/lib/\"   -c -o ipaddress.o ipaddress.c
ipaddress.c: In function =91print_linkinfo=92:
ipaddress.c:334: error: =91IFLA_VFINFO=92 undeclared (first use in this=
 function)
ipaddress.c:334: error: (Each undeclared identifier is reported only on=
ce
ipaddress.c:334: error: for each function it appears in.)
make[1]: *** [ipaddress.o] Error 1
make[1]: Leaving directory `/root/git/iproute2/ip'
make: *** [all] Error 2


I tried moving /usr/include/linux out of the way, but then it blows up
even worse (can't find errno.h, etc)

Are we supposed to be able to compile iproute2 on a system with moderat=
ely
outdated kernel headers?

If not, why bother with the iproute/include/linux directory at all?

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

