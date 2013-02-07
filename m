From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH iproute-3.8 0/6] ip netns bug fixes and enhancements
Date: Thu, 07 Feb 2013 00:57:56 -0800
Message-ID: <87obfw5wmj.fsf@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
	<CAGK4HS_nZ-fk5628wgHke0491ESLaZumSj1ALqDamd4bzBYfBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:54833 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754130Ab3BGI6L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 03:58:11 -0500
In-Reply-To: <CAGK4HS_nZ-fk5628wgHke0491ESLaZumSj1ALqDamd4bzBYfBg@mail.gmail.com>
	(Vijay Subramanian's message of "Wed, 6 Feb 2013 16:56:27 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vijay Subramanian <subramanian.vijay@gmail.com> writes:

>>
>> Eric W. Biederman (6):
>>       iproute2: Don't propogate mounts out of ip netns exec.
>>       iproute2: Normalize return codes in "ip netns"
>>       iproute2: Improve "ip netns add" failure error message
>>       iproute2: Make "ip netns delete" more likely to succeed
>>       iproute2: Fill in the ip-netns.8 manpage
>>       iproute2: Add "ip netns pids" and "ip netns identify"
>>
>
>
> Eric,
> With these patches applied, I am getting the following errors:
>
>
> make[1]: Entering directory `/root/tools/iproute2/ip'
> gcc -Wall -Wstrict-prototypes -Werror -O2 -I../include
> -DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iprout=
e2\"
> -D_GNU_SOURCE   -c -o ipaddress.o ipaddress.c
> gcc -Wall -Wstrict-prototypes -Werror -O2 -I../include
> -DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iprout=
e2\"
> -D_GNU_SOURCE   -c -o ipnetns.o ipnetns.c
> ipnetns.c: In function =E2=80=98netns_exec=E2=80=99:
> ipnetns.c:156: error: =E2=80=98MS_SLAVE=E2=80=99 undeclared (first us=
e in this function)
> ipnetns.c:156: error: (Each undeclared identifier is reported only on=
ce
> ipnetns.c:156: error: for each function it appears in.)
> ipnetns.c:156: error: =E2=80=98MS_REC=E2=80=99 undeclared (first use =
in this function)
> ipnetns.c: In function =E2=80=98netns_add=E2=80=99:
> ipnetns.c:372: error: =E2=80=98MS_SHARED=E2=80=99 undeclared (first u=
se in this function)
> ipnetns.c:372: error: =E2=80=98MS_REC=E2=80=99 undeclared (first use =
in this function)
> make[1]: *** [ipnetns.o] Error 1
> make[1]: Leaving directory `/root/tools/iproute2/ip'
> make: *** [all] Error 2

On my system those defines are coming out of sys/mount.h and date back
to 2.6.5 or so.  You should have them available on your system.

What weird system are you on that doesn't export those?

I don't have a clue on where to start at a practical level.  It wouldn'=
t
be hard to provide some #ifndef compat glue but I can't imagine why tha=
t
would be needed.

Eric
