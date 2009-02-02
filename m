From: Andrew Walrond <andrew@walrond.org>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Mon, 02 Feb 2009 10:35:25 +0000
Message-ID: <4986CC6D.4090904@walrond.org>
References: <20090122191239.GA16347@uranus.ravnborg.org> <20090126.210835.181389836.davem@davemloft.net> <alpine.LSU.2.00.0901271143490.3147@fbirervta.pbzchgretzou.qr> <20090128.122924.106238702.davem@davemloft.net> <alpine.LSU.2.00.0901300510310.22910@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, sam@ravnborg.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755363AbZBBKfo@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0901300510310.22910@fbirervta.pbzchgretzou.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey guys. A gentle nudge...

My distro scripts build the

    glibc
    iproute2
    iputils
    kbd
    lm_sensors
    net-tools
    strace

packages and others against every new release of linux and linux-stable=
,=20
(hence my initial report).
Right now I'm stalled at the 2.6.27.? headers so can't do any more=20
testing until this is resolved.

Andrew Walrond

Jan Engelhardt wrote:
> On Wednesday 2009-01-28 21:29, David Miller wrote:
>  =20
>>> On Tuesday 2009-01-27 06:08, David Miller wrote:
>>>      =20
>>>> The fly in the ointment is linux/if_tunnel.h
>>>>
>>>> We export a structure there for a userland interface which
>>>> uses "struct iphdr".
>>>>
>>>> Because of that, we are faced with the difficult choice between
>>>> defining the structure (as we do) in linux/ip.h or using some ugly
>>>> __KERNEL__ ifdefs in linux/if_tunnel.h to conditionally include
>>>> netinet/ip.h instead. :-/
>>>>
>>>> Really, I have no idea what to do about this as the problem has
>>>> existed for so long.
>>>>        =20
>>> I think in the long term, exported structs should probably
>>> have a "kernel_" prefix, much like userspace libraries use
>>> such prefixes to (try to) guard against simple name clashes.
>>>      =20
>> This is a reasonable rule for future interfaces, but won't
>> help us here on this one.[...]
>> Really, we page a huge price these days because the relationship
>> between glibc's and the kernel's userland header exports in the
>> past has been anti-social at best.
>>
>>    =20
> Yeah I just had to notice >:-(
>
> IPPROTO_MH is only defined in linux/in6.h, but inclusion of it:
>
> /usr/include/linux/in6.h:31: error: redefinition of =E2=96=A0struct i=
n6_addr=E2=96=A0
> /usr/include/linux/in6.h:52: error: redefinition of =E2=96=A0struct s=
ockaddr_in6=E2=96=A0
> /usr/include/linux/in6.h:60: error: redefinition of =E2=96=A0struct i=
pv6_mreq=E2=96=A0
>
> Ick. That's even worse than tunnels.
>
>  =20
