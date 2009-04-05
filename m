From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Regression caused by commit "netfilter: iptables: lock free counters"
Date: Sun, 05 Apr 2009 12:30:17 +0200
Message-ID: <49D88839.4090902@cosmosbay.com>
References: <20090329234702.4988017f@desktop.r000n.info>	<8763hja8cy.fsf@newton.gmurray.org.uk>	<20090405.012237.198610462.davem@davemloft.net>	<49D88162.5040809@cosmosbay.com> <87ws9z8l4c.fsf@newton.gmurray.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Graham Murray <graham@gmurray.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39006 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757681AbZDEKa3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 06:30:29 -0400
In-Reply-To: <87ws9z8l4c.fsf@newton.gmurray.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Graham Murray a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>>>>> 784544739a25c30637397ace5489eeb6e15d7d49 is first bad commit
>>>>> commit 784544739a25c30637397ace5489eeb6e15d7d49            =20
>>>> I am seeing a different problem which also bisects to this commit.=
 There are
>>>> no kernel messages but ip6tables fails to run.
>>>>
>>>> newton ~ # ip6tables -L -v
>>>> FATAL: Module ip6_tables not found.
>>>> ip6tables v1.4.3.1: can't initialize ip6tables table `filter': Mem=
ory allocation problem
>>>> Perhaps ip6tables or your kernel needs to be upgraded.
>>>>
>>>> I get this error no matter which ip6tables sub-command I run. Ip6t=
ables
>>>> is built into the kernel, not as modules.
>>>>
>>>> An strace shows the failure to be=20
>>>> socket(PF_INET6, SOCK_RAW, IPPROTO_RAW) =3D 3
>>>> getsockopt(3, SOL_IPV6, 0x40 /* IPV6_??? */, "filter\0\305\0w~\300=
\0wb\305P\24\312\t\0009b\305\216\23\0\0\310\341/g\16"..., [84]) =3D 0
>>>> brk(0)                                  =3D 0x8273000
>>>> brk(0x8294000)                          =3D 0x8294000
>> so ip6tables allocates about 128 Kbytes of ram in order to get rules=
 from kernel.
>>
>>>> getsockopt(3, SOL_IPV6, 0x41 /* IPV6_??? */, 0x8273090, 0xbfd23628=
) =3D -1 ENOMEM (Cannot allocate memory)
>>>> close(3)                                =3D 0
>>>>
>>
>> This is a big problem yes, since "iptables|ip6tables" -L needs to al=
locate kernel memory
>> to perform the momentary swap.
>>
>> On x86, this is potentially a problem if vmalloc space is exhausted =
or fragmented,
>> (or lowmem exhausted) and/or many cpus are online/possible.
>=20
> iptables gives me no problems at all, it is just ip6tables that
> fails. The first indication of this is during the init scripts when
> ip6tables-restore fails.

I see, its a plain bug in net/ipv6/netfilter/ip6_tables.c
function alloc_counters() always returns -ENOMEM

Unfortunatly , its Sunday here and I have to run for lunch time with fa=
mily :)

If nobody beats me, I will do the fix in a couple of hours...

Thank you

