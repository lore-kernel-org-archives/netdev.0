From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOM when adding ipv6 route:  How to make available more
 per-cpu memory?
Date: Sat, 06 Nov 2010 08:26:32 +0100
Message-ID: <1289028392.2665.2418.camel@edumazet-laptop>
References: <4CD43C87.5040403@candelatech.com>
	 <1288980361.2882.1070.camel@edumazet-laptop>
	 <4CD449A5.5070305@candelatech.com>
	 <1288988403.2665.268.camel@edumazet-laptop>
	 <1288995103.2665.653.camel@edumazet-laptop>
	 <4CD49C2F.3060904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46637 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab0KFH0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Nov 2010 03:26:38 -0400
In-Reply-To: <4CD49C2F.3060904@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 17:07 -0700, Ben Greear a =C3=A9cri=
t :

> We just tried creating 1000 macvlans with IPv6 addrs on a 64-bit mach=
ine
> with 12GB RAM.  Only around 520 interfaces properly set their IPs, an=
d
> again there are errors about of-of-memory from 'ip', but no obvious
> splats in dmesg.
>=20
> 'top' shows 10G or so free.
>=20
> It will take some time to figure out what exactly is returning
> the ENOMEM....

At least, nothing to do with percpu stuff ?

On my 4GB machine, 16 'cpus' (but 32 possible cpus), I was able to
allocate.
8192 percpu 8192 bytes structures

(total : 32 * 8192 * 8192 =3D 2 Gbytes)

setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:32 nr_node_ids:2
PERCPU: Embedded 26 pages/cpu @ffff88007fc00000 s76032 r8192 d22272 u13=
1072
pcpu-alloc: s76032 r8192 d22272 u131072 alloc=3D1*2097152
pcpu-alloc: [0] 00 02 04 06 08 10 12 14 17 19 21 23 25 27 29 31=20
pcpu-alloc: [1] 01 03 05 07 09 11 13 15 16 18 20 22 24 26 28 30=20

grep Vmalloc /proc/meminfo=20
VmallocTotal:   34359738367 kB
VmallocUsed:     2202592 kB
VmallocChunk:   34356996456 kB

Make sure udev / hotplug is not the problem, if you create your devices
very fast.

(modprobe dummy numdummies=3D2000) can be very slow because of that.
All tasks are fighting for RTNL or sysfs mutex.



