From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, netfilter] NUMA aware ipv4/netfilter/ip_tables.c
Date: Mon, 19 Sep 2005 21:09:14 +0200
Message-ID: <432F0CDA.40207@cosmosbay.com>
References: <432EF0C5.5090908@cosmosbay.com> <200509191948.55333.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Eric dumazet <abuse@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200509191948.55333.ak@suse.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Andi Kleen a =C3=A9crit :
> On Monday 19 September 2005 19:09, Eric dumazet wrote:
>=20
>>Hi
>>
>>Part of the performance problem we have with netfilter  is memory
>>allocation is not NUMA aware, but 'only' SMP aware.
>=20
>=20
> How do you know? Did you measure it somehow?=20

Well, it seems that even a 1MB cache is not enough for this workload, on =
a=20
dual Opterons 275 machine.

CPU: AMD64 processors, speed 2205.54 MHz (estimated)
Counted DATA_CACHE_MISSES events (Data cache misses) with a unit mask of =
0x00=20
(No unit mask) count 5000
samples  %        symbol name
86104    13.3027  ipt_do_table
21508     3.3229  copy_user_generic_c
18618     2.8764  try_to_wake_up
18180     2.8087  memset
18085     2.7941  tcp_v4_rcv
16949     2.6185  schedule

# iptables -nvL | wc -l
     190



>=20
> Normally I would expect fire wall state to mostly fit=20
> into caches (1MB+) of modern Opterons and other NUMA systems.
>=20
>=20
>>What do you think of this patch ?
>>
>>Note : The allocation function is quite complex (copied from
>>drivers/pci/pci-driver.c pci_call_probe())
>>because current kernel doesnt have a NUMA aware vmalloc() wrapper
>=20
>=20
> Normal vmalloc is NUMA aware and allocates on the local node.
> Like all memory allocations

Yes, but I want to allocate percpu (and per node) data, using vmalloc(), =
not=20
memory on the local node.

>=20
>=20
>>, maybe=20
>>a future kernel will export
>>such a common function ?
>=20
>=20
> BTW if you want to put data onto a specific node you don't need
> to schedule there - it is enough to set the process mempolicy
> with sys_set_mempolicy. This is fine from kernel too, as long
> as you save/restore the old one (current->mempolicy)=20

OK thanks, I will try this.

Eric
