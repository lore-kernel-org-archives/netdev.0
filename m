From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: how to tweak ARP timer on kernel 2.6.9
Date: Tue, 09 Mar 2010 23:10:14 +0100
Message-ID: <1268172614.2872.122.camel@edumazet-laptop>
References: <4B96A24A.6060405@utah.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Tom Ammon <tom.ammon@utah.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B96A24A.6060405@utah.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 09 mars 2010 =C3=A0 12:32 -0700, Tom Ammon a =C3=A9crit :
> Hi,
>=20
> I've been trying to figure out how to adjust the ARP timeout on kerne=
l=20
> 2.6.9 and I found the following in /proc/sys/net/ipv4/neigh/ib0 (its =
an=20
> IB interface I am interested in changing) with the following values.=20
> This is on kernel 2.6.9-89ELsmp (RHEL4) :
>=20

> When I test this, along with per-flow ECMP (using the iproute2 utils)=
, I=20
> see that the ARP cache is timing out about every 10 minutes (I observ=
e=20
> this by load balancing an iperf flow between two different gateway=20
> machines and then graphing the interface traffic)
>=20

10 minutes seems out of specs.

> On a newer kernel, 2.6.18-164.11.1.el5 (RHEL5), I see mostly the same=
=20
> parms available, but a few new ones have been added. However, all of =
the=20
> parms that are the same name between the two kernels are the same val=
ues:
>=20

> Yet when I observe the same traffic flow with this machine, the ARP=20
> cache times out about once per minute.
>=20

This seems normal, old kernels were a bit lazy about arp.


> Is there another set of parameters somewhere that govern how often th=
e=20
> kernel times out the ARP cache? If so, where might I find that? Is th=
ere=20
> any kernel documentation that talks about changing ARP timers on the=20
> linux kernel?
>=20

I would suggest :

man 7 arp

http://linux.die.net/man/7/arp



base_reachable_time
        Once a neighbour has been found, the entry is considered to be
        valid for at least a random value between base_reachable_time/2
        and 3*base_reachable_time/2. An entry's validity will be
        extended if it receives positive feedback from higher level
        protocols. Defaults to 30 seconds.

gc_interval
        How frequently the garbage collector for neighbour entries
        should attempt to run. Defaults to 30 seconds.

gc_stale_time
        Determines how often to check for stale neighbour entries. When
        a neighbour entry is considered stale it is resolved again
        before sending data to it. Defaults to 60 seconds.
       =20


and "ip -s neigh"
