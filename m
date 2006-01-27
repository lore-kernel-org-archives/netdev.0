From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Fri, 27 Jan 2006 09:53:53 +0100
Message-ID: <43D9DFA1.9070802@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751438AbWA0IyN@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060126190357.GE3651@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai a =E9crit :
> Change the atomic_t sockets_allocated member of struct proto to a=20
> per-cpu counter.
>=20
> Signed-off-by: Pravin B. Shelar <pravins@calsoftinc.com>
> Signed-off-by: Ravikiran Thirumalai <kiran@scalex86.org>
> Signed-off-by: Shai Fultheim <shai@scalex86.org>
>=20
Hi Ravikiran

If I correctly read this patch, I think there is a scalability problem.

On a big SMP machine, read_sockets_allocated() is going to be a real ki=
ller.

Say we have 128 Opterons CPUS in a box.

You'll need to bring 128 cache lines (plus 8*128 bytes to read the 128=20
pointers inside percpu structure)

I think a solution 'a la percpu_counter' is preferable, or even better =
a=20
dedicated per_cpu with a threshold management (see mm/swap.c , function=
=20
vm_acct_memory() to see how vm_committed_space is updated without too b=
ad SMP=20
scalability)

Thank you

Eric
