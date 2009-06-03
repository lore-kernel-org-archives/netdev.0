From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Fwd: swapper: page allocation failure. order:0, was: Weird (after
   try of use arping2)
Date: Wed, 03 Jun 2009 22:30:44 +0200
Message-ID: <4A26DD74.7050903@gmail.com>
References: <4A26DB2F.4080801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:26233 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbZFCUaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 16:30:52 -0400
In-Reply-To: <4A26DB2F.4080801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 06/03/2009 10:21 PM:

> Looks like -mm puzzle.

Resend with Cc's.

Sorry,

Jarek P.


>=20
> -------- Original Message --------
> Subject: Weird (after try of use arping2)
> Date: Mon, 01 Jun 2009 15:20:55 +0200
> From: Pawe=B3 Staszewski <pstaszewski@itcare.pl>
> To: Linux Network Development list <netdev@vger.kernel.org>
>=20
>=20
> Hello all.
> I dont know is this a bug but when i try to use arping:
>=20
> arping -s <mac-address>
> arping2 -v
> ARPing 2.06
>=20
> dmesg shows:
>=20
> swapper: page allocation failure. order:0, mode:0x20
> Pid: 0, comm: swapper Not tainted 2.6.29.1 #3
> Call Trace:
>  [<c024f6d4>] __alloc_pages_internal+0x342/0x356
> swapper: page allocation failure. order:0, mode:0x20
> Pid: 0, comm: swapper Not tainted 2.6.29.1 #3
>  [<c026a053>] cache_alloc_refill+0x260/0x442
> kswapd0: page allocation failure. order:0, mode:0x20
>  [<c026a2ae>] __kmalloc+0x79/0xb3
>  [<c040925f>] pskb_expand_head+0x55/0x153
> swapper: page allocation failure. order:0, mode:0x20
> Call Trace:
>  [<c04093cd>] __pskb_pull_tail+0x3f/0x211
> Pid: 0, comm: swapper Not tainted 2.6.29.1 #3
>  [<c042d066>] nf_conntrack_in+0x3b8/0x41e
>  [<c042b2d4>] skb_make_writable+0x5a/0x7a
>  [<c04641a0>] manip_pkt+0x1c/0xe2
> Call Trace:
>  [<c024f6d4>] __alloc_pages_internal+0x342/0x356
> Pid: 321, comm: kswapd0 Not tainted 2.6.29.1 #3
>  [<c04642cc>] nf_nat_packet+0x66/0x78
>  [<c024f6d4>] __alloc_pages_internal+0x342/0x356
>  [<c04682e2>] nf_nat_in+0x1d/0x4a
>  [<c043a6d8>] ip_rcv_finish+0x0/0x231
>  [<c042b04c>] nf_iterate+0x30/0x61
>  [<c043b870>] ip_forward_finish+0x2c/0x2e
>  [<c043a8f5>] ip_rcv_finish+0x21d/0x231
>  [<c026a053>] cache_alloc_refill+0x260/0x442
>  [<c043a6d8>] ip_rcv_finish+0x0/0x231
>  [<c0269db9>] kmem_cache_alloc+0x49/0x83
>  [<c043a6d8>] ip_rcv_finish+0x0/0x231
>  [<c042b0e2>] nf_hook_slow+0x41/0x99
>  [<c043a6d8>] ip_rcv_finish+0x0/0x231
>  [<c0371a28>] ixgbe_alloc_rx_buffers+0x68/0x200
>  [<c043acae>] ip_rcv+0x1d9/0x211
>  [<c043a6d8>] ip_rcv_finish+0x0/0x231
>  [<c040e663>] netif_receive_skb+0x2d7/0x307
>  [<c0372e79>] ixgbe_clean_rx_irq+0x497/0x4c0
>  [<c036fb34>] e1000_clean_rx_irq+0x246/0x2e7
>  [<c0375a11>] ixgbe_clean_rxonly+0x44/0x88
>  [<c036f203>] e1000_clean+0x7d/0x20e
>  [<c041081d>] net_rx_action+0x66/0x104
>  [<c041081d>] net_rx_action+0x66/0x104
>  [<c0225571>] __do_softirq+0x76/0x113
>  [<c0225640>] do_softirq+0x32/0x36
>  [<c02257ef>] irq_exit+0x35/0x62
>  [<c02046e2>] do_IRQ+0x8a/0xa0
>  [<c0225571>] __do_softirq+0x76/0x113
>  [<c0225640>] do_softirq+0x32/0x36
>  [<c02031a7>] common_interrupt+0x27/0x2c
>  [<c02257ef>] irq_exit+0x35/0x62
>  [<c02046e2>] do_IRQ+0x8a/0xa0
>  [<c0409044>] skb_clone+0x36/0x4a
>  [<c0207c7a>] mwait_idle+0x49/0x4e
>  [<c02018c8>] cpu_idle+0x57/0x70
>  [<c02031a7>] common_interrupt+0x27/0x2c
> Mem-Info:
>  [<c0207c7a>] mwait_idle+0x49/0x4e
>  [<c02018c8>] cpu_idle+0x57/0x70
> DMA per-cpu:
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> CPU    4: hi:    0, btch:   1 usd:   0
> CPU    5: hi:    0, btch:   1 usd:   0
> CPU    6: hi:    0, btch:   1 usd:   0
> CPU    4: hi:    0, btch:   1 usd:   0
> CPU    5: hi:    0, btch:   1 usd:   0
> CPU    6: hi:    0, btch:   1 usd:   0
> CPU    7: hi:    0, btch:   1 usd:   0
> CPU    7: hi:    0, btch:   1 usd:   0
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 178
> CPU    1: hi:  186, btch:  31 usd:  84
> CPU    2: hi:  186, btch:  31 usd: 178
> CPU    3: hi:  186, btch:  31 usd:  67
> CPU    4: hi:  186, btch:  31 usd:  66
> CPU    5: hi:  186, btch:  31 usd:  88
> Normal per-cpu:
> CPU    6: hi:  186, btch:  31 usd:  42
> CPU    0: hi:  186, btch:  31 usd: 178
> CPU    1: hi:  186, btch:  31 usd:  84
> CPU    2: hi:  186, btch:  31 usd: 178
> CPU    3: hi:  186, btch:  31 usd:  67
> CPU    4: hi:  186, btch:  31 usd:  66
> CPU    5: hi:  186, btch:  31 usd:  88
> CPU    6: hi:  186, btch:  31 usd:  42
> CPU    7: hi:  186, btch:  31 usd: 169
> HighMem per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 161
> CPU    7: hi:  186, btch:  31 usd: 169
> HighMem per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 161
> CPU    1: hi:  186, btch:  31 usd: 142
> CPU    1: hi:  186, btch:  31 usd: 142
> CPU    2: hi:  186, btch:  31 usd: 127
> CPU    3: hi:  186, btch:  31 usd: 150
> CPU    4: hi:  186, btch:  31 usd: 143
> CPU    5: hi:  186, btch:  31 usd: 151
> CPU    6: hi:  186, btch:  31 usd: 158
> CPU    7: hi:  186, btch:  31 usd: 172
>  [<c040ec0a>] dev_hard_start_xmit+0x8d/0x268
>  [<c041a33b>] __qdisc_run+0xb7/0x18e
>  [<c0410bc8>] net_tx_action+0x8d/0xd1
> Active_anon:4472 active_file:48192 inactive_anon:0
>  inactive_file:15922 unevictable:0 dirty:44 writeback:0 unstable:0
>  free:2890227 slab:124368 mapped:941 pagetables:87 bounce:0
> DMA free:3664kB min:572kB low:712kB high:856kB active_anon:0kB=20
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB=20
> present:15764kB pages_scann
> ed:0 all_unreclaimable? no
> lowmem_reserve[]: 0 865 12146 12146
> Normal free:11976kB min:32192kB low:40240kB high:48288kB active_anon:=
0kB=20
> inactive_anon:0kB active_file:147924kB inactive_file:29784kB=20
> unevictable:0kB present:
> 886228kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 90248 90248
> HighMem free:11545268kB min:512kB low:105424kB high:210340kB=20
> active_anon:17888kB inactive_anon:0kB active_file:44844kB=20
> inactive_file:33904kB unevictable:0kB p
> resent:11551812kB pages_scanned:32 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: CPU    2: hi:  186, btch:  31 usd: 127
> CPU    3: hi:  186, btch:  31 usd: 150
> CPU    4: hi:  186, btch:  31 usd: 143
> CPU    5: hi:  186, btch:  31 usd: 151
> CPU    6: hi:  186, btch:  31 usd: 158
> CPU    7: hi:  186, btch:  31 usd: 172
> Active_anon:4472 active_file:48192 inactive_anon:0
>  inactive_file:15922 unevictable:0 dirty:44 writeback:0 unstable:0
>  free:2890227 slab:124368 mapped:941 pagetables:87 bounce:0
> DMA free:3664kB min:572kB low:712kB high:856kB active_anon:0kB=20
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB=20
> present:15764kB pages_scann
> ed:0 all_unreclaimable? no
> lowmem_reserve[]: 0 865 12146 12146
> Normal free:11976kB min:32192kB low:40240kB high:48288kB active_anon:=
0kB=20
> inactive_anon:0kB active_file:147924kB inactive_file:29784kB=20
> unevictable:0kB present:
> 886228kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 90248 90248
> HighMem free:11545268kB min:512kB low:105424kB high:210340kB=20
> active_anon:17888kB inactive_anon:0kB active_file:44844kB=20
> inactive_file:33904kB unevictable:0kB p
> resent:11551812kB pages_scanned:32 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 3*4kB 3*8kB 6*16kB 5*32kB 4*64kB 2*128kB 1*256kB 1*512kB 2*1024k=
B=20
> 0*2048kB 0*4096kB =3D 3620kB
> Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB=20
> 1*1024kB 1*2048kB 2*4096kB =3D 11656kB
> HighMem: 3*4kB 3*8kB 6*16kB 5*32kB 4*64kB 2*128kB 1*256kB 1*512kB=20
> 2*1024kB 0*2048kB 0*4096kB =3D 3620kB
> Normal:  [<c0225571>] __do_softirq+0x76/0x113
> 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB 1*1024kB=20
> 1*2048kB 2*4096kB =3D 11656kB
> HighMem: 1118*4kB 1118*4kB 3728*8kB 736*16kB 372*32kB 235*64kB 90*128=
kB=20
> 70*256kB 17*512kB 18*1024kB 2*2048kB 2786*4096kB =3D 11545144kB
> 64154 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  =3D 2040232kB
> Total swap =3D 2040232kB
> 3728*8kB 736*16kB 372*32kB 235*64kB 90*128kB 70*256kB 17*512kB 18*102=
4kB=20
> 2*2048kB 2786*4096kB =3D 11545144kB
> 64154 total pagecache pages
> 0 pages in swap cache
> Swap cache stats: add 0, delete 0, find 0/0
> Free swap  =3D 2040232kB
> Total swap =3D 2040232kB
>  [<c0225640>] do_softirq+0x32/0x36
>  [<c02257ef>] irq_exit+0x35/0x62
>  [<c020f8f5>] smp_apic_timer_interrupt+0x71/0x7b
>  [<c02032c0>] apic_timer_interrupt+0x28/0x30
>  [<c0207c7a>] mwait_idle+0x49/0x4e
> Call Trace:
>  [<c02018c8>] cpu_idle+0x57/0x70
>  [<c024f6d4>] __alloc_pages_internal+0x342/0x356
>  [<c026a053>] cache_alloc_refill+0x260/0x442
> Mem-Info:
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20


