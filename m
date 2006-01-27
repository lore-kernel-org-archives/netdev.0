From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables -- proto.sockets_allocated
Date: Sat, 28 Jan 2006 00:21:07 +0100
Message-ID: <43DAAAE3.2030107@cosmosbay.com>
References: <20060126185649.GB3651@localhost.localdomain> <20060126190357.GE3651@localhost.localdomain> <43D9DFA1.9070802@cosmosbay.com> <20060127195227.GA3565@localhost.localdomain> <20060127121602.18bc3f25.akpm@osdl.org> <43DA9EFF.1020200@cosmosbay.com> <20060127225036.GC3565@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422677AbWA0XVK@vger.kernel.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
In-Reply-To: <20060127225036.GC3565@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ravikiran G Thirumalai a =E9crit :
> On Fri, Jan 27, 2006 at 11:30:23PM +0100, Eric Dumazet wrote:
>> There are several issues here :
>>
>> alloc_percpu() current implementation is a a waste of ram. (because =
it uses=20
>> slab allocations that have a minimum size of 32 bytes)
>=20
> Oh there was a solution for that :). =20
>=20
> http://lwn.net/Articles/119532/
>=20
> I can quickly revive it if there is interest.
>=20

Well, nice work ! :)

Maybe a litle bit complicated if expected percpu space is 50 KB per cpu=
 ?

Why not use a boot time allocated percpu area (as done today in=20
setup_per_cpu_areas()), but instead of reserving extra space for module=
's=20
percpu data, being able to serve alloc_percpu() from this reserved area=
 (ie no=20
kmalloced data anymore), and keeping your

#define per_cpu_ptr(ptr, cpu)  ((__typeof__(ptr))         \
	(RELOC_HIDE(ptr,  PCPU_BLKSIZE * cpu)))

Some code from kernel/module.c could be reworked to serve both as an al=
locator=20
when a module percpudata must be relocated (insmod)/freed (rmmod), and =
serve=20
alloc_percpu() for 'dynamic allocations'

Eric
