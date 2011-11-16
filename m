From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [rfc 00/18] slub: irqless/lockless slow allocation paths
Date: Wed, 16 Nov 2011 18:45:34 +0100
Message-ID: <1321465534.4182.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111111200711.156817886@linux.com>
	 <1321465198.4182.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, Pekka Enberg
 <penberg@cs.helsinki.fi>,  David Rientjes <rientjes@google.com>, Andi Kleen
 <andi@firstfloor.org>, tj@kernel.org, Metathronius Galabant
 <m.galabant@googlemail.com>, Matt Mackall <mpm@selenic.com>, Adrian
 Drzewiecki <z@drze.net>, Shaohua Li <shaohua.li@intel.com>, Alex Shi
 <alex.shi@intel.com>,  linux-mm@kvack.org, netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1321465198.4182.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mercredi 16 novembre 2011 =C3=A0 18:39 +0100, Eric Dumazet a =C3=A9cri=
t :

> Adding SLUB_STATS gives :
>=20
> $ cd /sys/kernel/slab/skbuff_head_cache ; grep . *
> aliases:6
> align:8
> grep: alloc_calls: Function not implemented
> alloc_fastpath:89181782 C0=3D89173048 C1=3D1599 C2=3D1357 C3=3D2140 C4=3D=
802 C5=3D675 C6=3D638 C7=3D1523
> alloc_from_partial:412658 C0=3D412658
> alloc_node_mismatch:0
> alloc_refill:593417 C0=3D593189 C1=3D19 C2=3D15 C3=3D24 C4=3D51 C5=3D18=
 C6=3D17 C7=3D84
> alloc_slab:2831313 C0=3D2831285 C1=3D2 C2=3D2 C3=3D2 C4=3D2 C5=3D12 C6=3D=
4 C7=3D4
> alloc_slowpath:4430371 C0=3D4430112 C1=3D20 C2=3D17 C3=3D25 C4=3D57 C5=3D=
31 C6=3D21 C7=3D88
> cache_dma:0
> cmpxchg_double_cpu_fail:0
> cmpxchg_double_fail:1 C0=3D1
> cpu_partial:30
> cpu_partial_alloc:592991 C0=3D592981 C2=3D1 C4=3D5 C5=3D2 C6=3D1 C7=3D1
> cpu_partial_free:4429836 C0=3D592981 C1=3D25 C2=3D19 C3=3D23 C4=3D38367=
67 C5=3D6 C6=3D8 C7=3D7
> cpuslab_flush:0
> cpu_slabs:107
> deactivate_bypass:3836954 C0=3D3836923 C1=3D1 C2=3D2 C3=3D1 C4=3D6 C5=3D=
13 C6=3D4 C7=3D4
> deactivate_empty:2831168 C4=3D2831168
> deactivate_full:0
> deactivate_remote_frees:0
> deactivate_to_head:0
> deactivate_to_tail:0
> destroy_by_rcu:0
> free_add_partial:0
> grep: free_calls: Function not implemented
> free_fastpath:21192924 C0=3D21186268 C1=3D1420 C2=3D1204 C3=3D1966 C4=3D=
572 C5=3D349 C6=3D380 C7=3D765
> free_frozen:67988498 C0=3D516 C1=3D121 C2=3D85 C3=3D841 C4=3D67986468 C=
5=3D215 C6=3D76 C7=3D176
> free_remove_partial:18 C4=3D18
> free_slab:2831186 C4=3D2831186
> free_slowpath:71825749 C0=3D609 C1=3D146 C2=3D104 C3=3D864 C4=3D7182353=
8 C5=3D221 C6=3D84 C7=3D183
> hwcache_align:0
> min_partial:5
> objects:2494
> object_size:192
> objects_partial:121
> objs_per_slab:21
> order:0
> order_fallback:0
> partial:14
> poison:0
> reclaim_account:0
> red_zone:0
> reserved:0
> sanity_checks:0
> slabs:127
> slabs_cpu_partial:99(99) C1=3D25(25) C2=3D18(18) C3=3D23(23) C4=3D16(16=
) C5=3D4(4) C6=3D7(7) C7=3D6(6)
> slab_size:192
> store_user:0
> total_objects:2667
> trace:0
>=20

And the SLUB stats for the 2048 bytes slab is even worse : About every
alloc/free is slow path

$ cd /sys/kernel/slab/:t-0002048 ; grep . *
aliases:0
align:8
grep: alloc_calls: Function not implemented
alloc_fastpath:8199220 C0=3D8196915 C1=3D306 C2=3D63 C3=3D297 C4=3D319 C5=
=3D550
C6=3D722 C7=3D48
alloc_from_partial:13931406 C0=3D13931401 C3=3D1 C5=3D4
alloc_node_mismatch:0
alloc_refill:70871657 C0=3D70871629 C1=3D2 C3=3D3 C4=3D9 C5=3D11 C6=3D3
alloc_slab:1335 C0=3D1216 C1=3D17 C2=3D2 C3=3D15 C4=3D17 C5=3D22 C6=3D44 =
C7=3D2
alloc_slowpath:155455299 C0=3D155455144 C1=3D18 C2=3D1 C3=3D21 C4=3D27 C5=
=3D40 C6=3D47
C7=3D1
cache_dma:0
cmpxchg_double_cpu_fail:0
cmpxchg_double_fail:27341 C0=3D12769 C4=3D14572
cpu_partial:6
cpu_partial_alloc:70650909 C0=3D70650899 C3=3D3 C4=3D2 C5=3D4 C6=3D1
cpu_partial_free:136279924 C0=3D71504388 C1=3D13 C2=3D1 C3=3D52 C4=3D6477=
5461 C5=3D6
C6=3D2 C7=3D1
cpuslab_flush:0
cpu_slabs:29
deactivate_bypass:84583642 C0=3D84583515 C1=3D16 C2=3D1 C3=3D18 C4=3D18 C=
5=3D29
C6=3D44 C7=3D1
deactivate_empty:570 C0=3D80 C3=3D34 C4=3D456
deactivate_full:0
deactivate_remote_frees:0
deactivate_to_head:0
deactivate_to_tail:0
destroy_by_rcu:0
free_add_partial:0
grep: free_calls: Function not implemented
free_fastpath:89153 C0=3D88972 C1=3D34 C2=3D35 C3=3D27 C4=3D12 C5=3D23 C6=
=3D30 C7=3D20
free_frozen:5971363 C0=3D554097 C1=3D196 C2=3D14 C3=3D730 C4=3D5416278 C5=
=3D16 C6=3D19
C7=3D13
free_remove_partial:401 C1=3D1 C4=3D400
free_slab:971 C0=3D80 C1=3D1 C3=3D34 C4=3D856
free_slowpath:92913113 C0=3D21090357 C1=3D212 C2=3D15 C3=3D784 C4=3D71821=
691 C5=3D19
C6=3D21 C7=3D14
hwcache_align:0
min_partial:5
objects:1873
object_size:2048
objects_partial:945
objs_per_slab:16
order:3
order_fallback:0
partial:306
poison:0
reclaim_account:0
red_zone:0
reserved:0
sanity_checks:0
slabs:364
slabs_cpu_partial:21(21) C0=3D3(3) C1=3D6(6) C2=3D1(1) C3=3D7(7) C5=3D2(2=
) C6=3D1(1)
C7=3D1(1)
slab_size:2048
store_user:0
total_objects:5824
trace:0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
