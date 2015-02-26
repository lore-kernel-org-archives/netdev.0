From: "Thomas D." <whissi@whissi.de>
Subject: ppp0: hw csum failure since 3fcb95a84 (RESEND)
Date: Thu, 26 Feb 2015 11:50:29 +0100
Message-ID: <54EEFA75.9030302@whissi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "therbert@google.com" <therbert@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

on my VPN server (strongswan-5.2.2 + ppp-2.4.7 + xl2tpd-1.3.6) I am
seeing the following errors since linux-3.18 when a client (roadwarrior)
connects (this is not fixed in linux-3.19.0):

> Feb 16 20:36:08 vpn1 kernel: [   90.265403] ppp0: hw csum failure
> Feb 16 20:36:08 vpn1 kernel: [   90.265411] CPU: 7 PID: 0 Comm: swapper/7 Tainted: G           O   3.17.0-rc4-00953-g3fcb95a #1
> Feb 16 20:36:08 vpn1 kernel: [   90.265414] Hardware name: FUJITSU SIEMENS PRIMERGY RX200 S4             /D2671, BIOS 4.06  Rev. 1.17.2671             02/16/2010
> Feb 16 20:36:08 vpn1 kernel: [   90.265416]  0000000000000001 ffff88043f9c3b90 ffffffff816a9c14 ffff880428477000
> Feb 16 20:36:08 vpn1 kernel: [   90.265420]  ffff88043f9c3ba8 ffffffff815bb6ea ffff8800bb69bd00 ffff88043f9c3bd8
> Feb 16 20:36:08 vpn1 kernel: [   90.265423]  ffffffff815b3255 b49cb25600000011 ffff8800bb69bd00 0000000000000014
> Feb 16 20:36:08 vpn1 kernel: [   90.265427] Call Trace:
> Feb 16 20:36:08 vpn1 kernel: [   90.265429]  <IRQ>  [<ffffffff816a9c14>] dump_stack+0x45/0x56
> Feb 16 20:36:08 vpn1 kernel: [   90.265444]  [<ffffffff815bb6ea>] netdev_rx_csum_fault+0x3a/0x40
> Feb 16 20:36:08 vpn1 kernel: [   90.265447]  [<ffffffff815b3255>] __skb_checksum_complete+0xa5/0xb0
> Feb 16 20:36:08 vpn1 kernel: [   90.265451]  [<ffffffff8163c34c>] nf_ip_checksum+0xcc/0x100
> Feb 16 20:36:08 vpn1 kernel: [   90.265473]  [<ffffffffa03116b2>] udp_error+0x102/0x1f0 [nf_conntrack]
> Feb 16 20:36:08 vpn1 kernel: [   90.265481]  [<ffffffffa030b78c>] nf_conntrack_in+0xec/0x9a0 [nf_conntrack]
> Feb 16 20:36:08 vpn1 kernel: [   90.265487]  [<ffffffff815f441f>] ? ip_rcv+0x27f/0x380
> Feb 16 20:36:08 vpn1 kernel: [   90.265490]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:08 vpn1 kernel: [   90.265496]  [<ffffffffa0339352>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
> Feb 16 20:36:08 vpn1 kernel: [   90.265499]  [<ffffffff815ed6ba>] nf_iterate+0x9a/0xb0
> Feb 16 20:36:08 vpn1 kernel: [   90.265503]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:08 vpn1 kernel: [   90.265506]  [<ffffffff815ed744>] nf_hook_slow+0x74/0x130
> Feb 16 20:36:08 vpn1 kernel: [   90.265509]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:08 vpn1 kernel: [   90.265513]  [<ffffffff815f448e>] ip_rcv+0x2ee/0x380
> Feb 16 20:36:08 vpn1 kernel: [   90.265516]  [<ffffffff815bd622>] __netif_receive_skb_core+0x1e2/0x7c0
> Feb 16 20:36:08 vpn1 kernel: [   90.265519]  [<ffffffff815bdc16>] __netif_receive_skb+0x16/0x70
> Feb 16 20:36:08 vpn1 kernel: [   90.265521]  [<ffffffff815be764>] process_backlog+0x94/0x150
> Feb 16 20:36:08 vpn1 kernel: [   90.265524]  [<ffffffff815be02a>] net_rx_action+0x11a/0x1b0
> Feb 16 20:36:08 vpn1 kernel: [   90.265529]  [<ffffffff810d904c>] __do_softirq+0x10c/0x280
> Feb 16 20:36:08 vpn1 kernel: [   90.265532]  [<ffffffff810d9315>] irq_exit+0x95/0xa0
> Feb 16 20:36:08 vpn1 kernel: [   90.265536]  [<ffffffff816b2656>] do_IRQ+0x56/0xe0
> Feb 16 20:36:08 vpn1 kernel: [   90.265540]  [<ffffffff816b0bea>] common_interrupt+0x6a/0x6a
> Feb 16 20:36:08 vpn1 kernel: [   90.265541]  <EOI>  [<ffffffff8100c95c>] ? default_idle+0x1c/0xb0
> Feb 16 20:36:08 vpn1 kernel: [   90.265549]  [<ffffffff8100d23f>] arch_cpu_idle+0xf/0x20
> Feb 16 20:36:08 vpn1 kernel: [   90.265553]  [<ffffffff81112547>] cpu_startup_entry+0x367/0x3a0
> Feb 16 20:36:08 vpn1 kernel: [   90.265558]  [<ffffffff8102d712>] start_secondary+0x1e2/0x220
> Feb 16 20:36:12 vpn1 kernel: [   94.253650] ppp0: hw csum failure
> Feb 16 20:36:12 vpn1 kernel: [   94.253665] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O   3.17.0-rc4-00953-g3fcb95a #1
> Feb 16 20:36:12 vpn1 kernel: [   94.253667] Hardware name: FUJITSU SIEMENS PRIMERGY RX200 S4             /D2671, BIOS 4.06  Rev. 1.17.2671             02/16/2010
> Feb 16 20:36:12 vpn1 kernel: [   94.253670]  0000000000000001 ffff88043f803b90 ffffffff816a9c14 ffff880428477000
> Feb 16 20:36:12 vpn1 kernel: [   94.253674]  ffff88043f803ba8 ffffffff815bb6ea ffff88042646bf00 ffff88043f803bd8
> Feb 16 20:36:12 vpn1 kernel: [   94.253677]  ffffffff815b3255 b39cb35600000011 ffff88042646bf00 0000000000000014
> Feb 16 20:36:12 vpn1 kernel: [   94.253680] Call Trace:
> Feb 16 20:36:12 vpn1 kernel: [   94.253682]  <IRQ>  [<ffffffff816a9c14>] dump_stack+0x45/0x56
> Feb 16 20:36:12 vpn1 kernel: [   94.253697]  [<ffffffff815bb6ea>] netdev_rx_csum_fault+0x3a/0x40
> Feb 16 20:36:12 vpn1 kernel: [   94.253700]  [<ffffffff815b3255>] __skb_checksum_complete+0xa5/0xb0
> Feb 16 20:36:12 vpn1 kernel: [   94.253704]  [<ffffffff8163c34c>] nf_ip_checksum+0xcc/0x100
> Feb 16 20:36:12 vpn1 kernel: [   94.253725]  [<ffffffffa03116b2>] udp_error+0x102/0x1f0 [nf_conntrack]
> Feb 16 20:36:12 vpn1 kernel: [   94.253732]  [<ffffffffa030b78c>] nf_conntrack_in+0xec/0x9a0 [nf_conntrack]
> Feb 16 20:36:12 vpn1 kernel: [   94.253739]  [<ffffffff815f441f>] ? ip_rcv+0x27f/0x380
> Feb 16 20:36:12 vpn1 kernel: [   94.253742]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:12 vpn1 kernel: [   94.253747]  [<ffffffffa0339352>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
> Feb 16 20:36:12 vpn1 kernel: [   94.253751]  [<ffffffff815ed6ba>] nf_iterate+0x9a/0xb0
> Feb 16 20:36:12 vpn1 kernel: [   94.253754]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:12 vpn1 kernel: [   94.253757]  [<ffffffff815ed744>] nf_hook_slow+0x74/0x130
> Feb 16 20:36:12 vpn1 kernel: [   94.253760]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:12 vpn1 kernel: [   94.253764]  [<ffffffff815f448e>] ip_rcv+0x2ee/0x380
> Feb 16 20:36:12 vpn1 kernel: [   94.253767]  [<ffffffff815bd622>] __netif_receive_skb_core+0x1e2/0x7c0
> Feb 16 20:36:12 vpn1 kernel: [   94.253770]  [<ffffffff815bdc16>] __netif_receive_skb+0x16/0x70
> Feb 16 20:36:12 vpn1 kernel: [   94.253773]  [<ffffffff815be764>] process_backlog+0x94/0x150
> Feb 16 20:36:12 vpn1 kernel: [   94.253775]  [<ffffffff815be02a>] net_rx_action+0x11a/0x1b0
> Feb 16 20:36:12 vpn1 kernel: [   94.253780]  [<ffffffff810d904c>] __do_softirq+0x10c/0x280
> Feb 16 20:36:12 vpn1 kernel: [   94.253783]  [<ffffffff810d9315>] irq_exit+0x95/0xa0
> Feb 16 20:36:12 vpn1 kernel: [   94.253788]  [<ffffffff816b2656>] do_IRQ+0x56/0xe0
> Feb 16 20:36:12 vpn1 kernel: [   94.253791]  [<ffffffff816b0bea>] common_interrupt+0x6a/0x6a
> Feb 16 20:36:12 vpn1 kernel: [   94.253792]  <EOI>  [<ffffffff8100c95c>] ? default_idle+0x1c/0xb0
> Feb 16 20:36:12 vpn1 kernel: [   94.253800]  [<ffffffff8100d23f>] arch_cpu_idle+0xf/0x20
> Feb 16 20:36:12 vpn1 kernel: [   94.253804]  [<ffffffff81112547>] cpu_startup_entry+0x367/0x3a0
> Feb 16 20:36:12 vpn1 kernel: [   94.253807]  [<ffffffff816a0ac7>] rest_init+0x77/0x80
> Feb 16 20:36:12 vpn1 kernel: [   94.253812]  [<ffffffff81d11eb5>] start_kernel+0x431/0x43e
> Feb 16 20:36:12 vpn1 kernel: [   94.253816]  [<ffffffff81d11495>] x86_64_start_reservations+0x2a/0x2c
> Feb 16 20:36:12 vpn1 kernel: [   94.253819]  [<ffffffff81d1158e>] x86_64_start_kernel+0xf7/0xfa
> Feb 16 20:36:17 vpn1 kernel: [   98.941276] ppp0: hw csum failure
> Feb 16 20:36:17 vpn1 kernel: [   98.941287] CPU: 6 PID: 0 Comm: swapper/6 Tainted: G           O   3.17.0-rc4-00953-g3fcb95a #1
> Feb 16 20:36:17 vpn1 kernel: [   98.941290] Hardware name: FUJITSU SIEMENS PRIMERGY RX200 S4             /D2671, BIOS 4.06  Rev. 1.17.2671             02/16/2010
> Feb 16 20:36:17 vpn1 kernel: [   98.941292]  0000000000000001 ffff88043f983b90 ffffffff816a9c14 ffff880428477000
> Feb 16 20:36:17 vpn1 kernel: [   98.941296]  ffff88043f983ba8 ffffffff815bb6ea ffff880424e77900 ffff88043f983bd8
> Feb 16 20:36:17 vpn1 kernel: [   98.941299]  ffffffff815b3255 b298b45a00000011 ffff880424e77900 0000000000000014
> Feb 16 20:36:17 vpn1 kernel: [   98.941302] Call Trace:
> Feb 16 20:36:17 vpn1 kernel: [   98.941303]  <IRQ>  [<ffffffff816a9c14>] dump_stack+0x45/0x56
> Feb 16 20:36:17 vpn1 kernel: [   98.941313]  [<ffffffff815bb6ea>] netdev_rx_csum_fault+0x3a/0x40
> Feb 16 20:36:17 vpn1 kernel: [   98.941316]  [<ffffffff815b3255>] __skb_checksum_complete+0xa5/0xb0
> Feb 16 20:36:17 vpn1 kernel: [   98.941319]  [<ffffffff8163c34c>] nf_ip_checksum+0xcc/0x100
> Feb 16 20:36:17 vpn1 kernel: [   98.941331]  [<ffffffffa03116b2>] udp_error+0x102/0x1f0 [nf_conntrack]
> Feb 16 20:36:17 vpn1 kernel: [   98.941338]  [<ffffffffa030b78c>] nf_conntrack_in+0xec/0x9a0 [nf_conntrack]
> Feb 16 20:36:17 vpn1 kernel: [   98.941344]  [<ffffffff815f441f>] ? ip_rcv+0x27f/0x380
> Feb 16 20:36:17 vpn1 kernel: [   98.941347]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:17 vpn1 kernel: [   98.941352]  [<ffffffffa0339352>] ipv4_conntrack_in+0x22/0x30 [nf_conntrack_ipv4]
> Feb 16 20:36:17 vpn1 kernel: [   98.941355]  [<ffffffff815ed6ba>] nf_iterate+0x9a/0xb0
> Feb 16 20:36:17 vpn1 kernel: [   98.941358]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:17 vpn1 kernel: [   98.941361]  [<ffffffff815ed744>] nf_hook_slow+0x74/0x130
> Feb 16 20:36:17 vpn1 kernel: [   98.941364]  [<ffffffff815f3ab0>] ? inet_del_offload+0x40/0x40
> Feb 16 20:36:17 vpn1 kernel: [   98.941368]  [<ffffffff815f448e>] ip_rcv+0x2ee/0x380
> Feb 16 20:36:17 vpn1 kernel: [   98.941371]  [<ffffffff815bd622>] __netif_receive_skb_core+0x1e2/0x7c0
> Feb 16 20:36:17 vpn1 kernel: [   98.941374]  [<ffffffff815bdc16>] __netif_receive_skb+0x16/0x70
> Feb 16 20:36:17 vpn1 kernel: [   98.941376]  [<ffffffff815be764>] process_backlog+0x94/0x150
> Feb 16 20:36:17 vpn1 kernel: [   98.941379]  [<ffffffff815be02a>] net_rx_action+0x11a/0x1b0
> Feb 16 20:36:17 vpn1 kernel: [   98.941383]  [<ffffffff810d904c>] __do_softirq+0x10c/0x280
> Feb 16 20:36:17 vpn1 kernel: [   98.941386]  [<ffffffff810d9315>] irq_exit+0x95/0xa0
> Feb 16 20:36:17 vpn1 kernel: [   98.941389]  [<ffffffff816b2656>] do_IRQ+0x56/0xe0
> Feb 16 20:36:17 vpn1 kernel: [   98.941392]  [<ffffffff816b0bea>] common_interrupt+0x6a/0x6a
> Feb 16 20:36:17 vpn1 kernel: [   98.941393]  <EOI>  [<ffffffff8100c95c>] ? default_idle+0x1c/0xb0
> Feb 16 20:36:17 vpn1 kernel: [   98.941400]  [<ffffffff8100d23f>] arch_cpu_idle+0xf/0x20
> Feb 16 20:36:17 vpn1 kernel: [   98.941403]  [<ffffffff81112547>] cpu_startup_entry+0x367/0x3a0
> Feb 16 20:36:17 vpn1 kernel: [   98.941406]  [<ffffffff8102d712>] start_secondary+0x1e2/0x220

I bisected the kernel and this is the result:

> 3fcb95a84fdb11e922cfac3b5cd3a9d96a9e9995 is the first bad commit
> commit 3fcb95a84fdb11e922cfac3b5cd3a9d96a9e9995
> Author: Tom Herbert <therbert@google.com>
> Date:   Mon Sep 22 11:39:44 2014 -0700
> 
>     udp: Need to make ip6_udp_tunnel.c have GPL license
> 
>     Unable to load various tunneling modules without this:
> 
>     [   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
>     [   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
>     [   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
>     [   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
>     [   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)
> 
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> :040000 040000 1ec7af31dba9cd4bbccdc5d47dbd9a402a727253 b658c31f77f9fb2cedd0010b95c47e17986a7389 M      net

Complete bisect log:

> Bisecting: a merge base must be tested
> [bfe01a5ba2490f299e1d2d5508cbbbadd897bbe9] Linux 3.17
> Bisecting: 6452 revisions left to test after this (roughly 13 steps)
> [754c780953397dd5ee5191b7b3ca67e09088ce7a] Merge branch 'for-v3.18' of git://git.linaro.org/people/mszyprowski/linux-dma-mapping
> Bisecting: 3086 revisions left to test after this (roughly 12 steps)
> [4a4743e840d06a5772be7c21110807165c5b3c9f] Merge tag 'fixes-nc-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
> Bisecting: 1506 revisions left to test after this (roughly 11 steps)
> [a4b4a2b7f98a45c71a906b1126cabea6446a9905] Merge tag 'master-2014-10-02' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next
> Bisecting: 795 revisions left to test after this (roughly 10 steps)
> [58310b3fc6aaa4f896ad3cbcd88851e7ad0908f6] Merge branch 'mlx4-next'
> Bisecting: 397 revisions left to test after this (roughly 9 steps)
> [005eff5919cdc29ec7f1c6169db40c533f1e05d7] ath5k: add missing include for debug code
> Bisecting: 186 revisions left to test after this (roughly 8 steps)
> [852248449c73b5ffe109a33d65485c71d3d398a7] Merge git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
> Bisecting: 96 revisions left to test after this (roughly 7 steps)
> [b1840060508d2c5202abb07b6128e4645d78fe57] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> Bisecting: 56 revisions left to test after this (roughly 6 steps)
> [f71470b37e79d6eb151debd47364d920b7babd30] udp: move logic out of udp[46]_ufo_send_check
> Bisecting: 28 revisions left to test after this (roughly 5 steps)
> [d6b7a9b7e77ae4d2a7652cdfbd65f2de0a1053b0] be2net: add speed reporting for 20G-KR interface
> Bisecting: 14 revisions left to test after this (roughly 4 steps)
> [de5df63228fcfbd5bb7fd883774c18fec9e61f12] net: sched: cls_u32 changes to knode must appear atomic to readers
> Bisecting: 6 revisions left to test after this (roughly 3 steps)
> [5f820b6c6e1cd75d5f2d08a684ecb3c2fda22d14] be2net: remove multiple assignments on a single line
> Bisecting: 3 revisions left to test after this (roughly 2 steps)
> [3fcb95a84fdb11e922cfac3b5cd3a9d96a9e9995] udp: Need to make ip6_udp_tunnel.c have GPL license
> Bisecting: 0 revisions left to test after this (roughly 1 step)
> [5624e80f8dba63499684d8920733d7465ad7d14b] Merge branch 'be2net-next'
> 3fcb95a84fdb11e922cfac3b5cd3a9d96a9e9995 is the first bad commit
> commit 3fcb95a84fdb11e922cfac3b5cd3a9d96a9e9995
> Author: Tom Herbert <therbert@google.com>
> Date:   Mon Sep 22 11:39:44 2014 -0700
> 
>     udp: Need to make ip6_udp_tunnel.c have GPL license
> 
>     Unable to load various tunneling modules without this:
> 
>     [   80.679049] fou: Unknown symbol udp_sock_create6 (err 0)
>     [   91.439939] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
>     [   91.439954] ip6_udp_tunnel: Unknown symbol __put_net (err 0)
>     [   91.457792] vxlan: Unknown symbol udp_sock_create6 (err 0)
>     [   91.457831] vxlan: Unknown symbol udp_tunnel6_xmit_skb (err 0)
> 
>     Signed-off-by: Tom Herbert <therbert@google.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> :040000 040000 1ec7af31dba9cd4bbccdc5d47dbd9a402a727253 b658c31f77f9fb2cedd0010b95c47e17986a7389 M      net

Without the "bad commit" I don't see hw_csum errors, only

> [   60.723963] ip6_udp_tunnel: Unknown symbol ip6_local_out (err 0)
> [   60.724000] ip6_udp_tunnel: Unknown symbol __put_net (err 0)

on boot.


If you need further information please don't hesitate to ask me.

Thanks!


-Thomas
