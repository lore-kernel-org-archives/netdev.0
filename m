From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: make ip_rt_acct a normal percpu var
Date: Thu, 20 Nov 2008 00:23:48 +0100
Message-ID: <4924A004.2050105@cosmosbay.com>
References: <200811172050.31308.rusty@rustcorp.com.au> <200811190208.11346.rusty@rustcorp.com.au> <20081119.142023.117741600.davem@davemloft.net> <200811200943.21410.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:33432 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbYKSXX4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:23:56 -0500
In-Reply-To: <200811200943.21410.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell a =E9crit :
> On Thursday 20 November 2008 08:50:23 David Miller wrote:
>> Do you really need this to forward some work you are doing?  If not
>> can we just let sleeping dogs lie on this one? :)
>=20
> Yes, I have patches to convert the dynamic percpu data to use the sam=
e=20
> mechanism as static percpu data.  Unfortunately we don't have a mecha=
nism for=20
> enlarging the percpu region (which is why this wasn't done earlier), =
so we use=20
> a heuristic to figure out how much extra percpu region to allocate at=
 boot.
>=20
> And 4k makes this one of the Big Pigs in dynamic per-cpu allocations.
>=20
> (SNMP mibs are even worse, but that's a separate debate...)
>=20
> I can try to implement a bss-like DEFINE_PER_CPU_ZERO(), but it seems=
 silly to=20
> talk about tight boot loader size restrictions for SMP kernels.
>=20

Then, if we really want to run 4096 cpus on a machine, we dont want to =
allocate
16 MBytes of memory for these ip_rt_acct counters, or even more for SNM=
P mibs.

Maybe its time to design a new mechanism, to avoid the basic "one varia=
ble" shared
by all cpus, and avoid the overkill "one separate variable for each cpu=
", and loop
4096 times to do the sum of this variable...

Something that would allocate a maximum of eight blocs.

Then atomic ops would be necessary for updates of SNMP counters (only i=
f NR_CPUS > 8)


