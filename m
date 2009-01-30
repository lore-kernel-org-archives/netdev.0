From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: 2.6.28 headers break kbd and net-tools userspace builds
Date: Fri, 30 Jan 2009 05:12:32 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901300510310.22910@fbirervta.pbzchgretzou.qr>
References: <20090122191239.GA16347@uranus.ravnborg.org> <20090126.210835.181389836.davem@davemloft.net> <alpine.LSU.2.00.0901271143490.3147@fbirervta.pbzchgretzou.qr> <20090128.122924.106238702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sam@ravnborg.org, andrew@walrond.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:53451 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752050AbZA3EMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 23:12:35 -0500
In-Reply-To: <20090128.122924.106238702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wednesday 2009-01-28 21:29, David Miller wrote:
>> On Tuesday 2009-01-27 06:08, David Miller wrote:
>> >The fly in the ointment is linux/if_tunnel.h
>> >
>> >We export a structure there for a userland interface which
>> >uses "struct iphdr".
>> >
>> >Because of that, we are faced with the difficult choice between
>> >defining the structure (as we do) in linux/ip.h or using some ugly
>> >__KERNEL__ ifdefs in linux/if_tunnel.h to conditionally include
>> >netinet/ip.h instead. :-/
>> >
>> >Really, I have no idea what to do about this as the problem has
>> >existed for so long.
>>=20
>> I think in the long term, exported structs should probably
>> have a "kernel_" prefix, much like userspace libraries use
>> such prefixes to (try to) guard against simple name clashes.
>
>This is a reasonable rule for future interfaces, but won't
>help us here on this one.[...]
>Really, we page a huge price these days because the relationship
>between glibc's and the kernel's userland header exports in the
>past has been anti-social at best.
>
Yeah I just had to notice >:-(

IPPROTO_MH is only defined in linux/in6.h, but inclusion of it:

/usr/include/linux/in6.h:31: error: redefinition of =E2=96=A0struct in6=
_addr=E2=96=A0
/usr/include/linux/in6.h:52: error: redefinition of =E2=96=A0struct soc=
kaddr_in6=E2=96=A0
/usr/include/linux/in6.h:60: error: redefinition of =E2=96=A0struct ipv=
6_mreq=E2=96=A0

Ick. That's even worse than tunnels.
