From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [slab poison overwritten] Re: [GIT] Networking
Date: Mon, 21 Mar 2011 19:07:18 +0100
Message-ID: <1300730838.2884.578.camel@edumazet-laptop>
References: <20110320.195156.226769634.davem@davemloft.net>
	 <20110321125320.GA23490@elte.hu>
	 <1300714346.2884.284.camel@edumazet-laptop>
	 <20110321161528.GA28580@elte.hu> <20110321164238.GA5303@elte.hu>
	 <20110321173941.GB3892@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Arnd Bergmann <arnd@arndb.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Simon Horman <horms@verge.net.au>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110321173941.GB3892@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 21 mars 2011 =C3=A0 18:39 +0100, Ingo Molnar a =C3=A9crit :
> here's the same but with kallsyms enabled.
>=20
> Thanks,
>=20
> 	Ingo
>=20
> [    9.585627] initcall 0xffffffff81d5b806 returned 0 after 0 usecs
> [    9.588960] calling  0xffffffff81d5b9da @ 1
> [    9.592303] IPVS: Creating netns size=3D1272 id=3D0
> [    9.595646] IPVS: __ip_vs_control_init(): alloc_percpu.
> [    9.602298] IPVS: cannot register namespace.
> [    9.605627] IPVS: can't setup control

It seems IPVS is busted in case of memory allocation error in=20
__ip_vs_control_init()

IPVS deinits its "struct netns_ipvs" space, but something (in IPVS) use=
s
it after free.

__ip_vs_init() seems to be called before ip_vs_init() completes
correctly. We then keep in net->ipvs a pointer to some freed memory.

Commit 14e405461e664b7 did some changes in this area

Simon, any idea ?
