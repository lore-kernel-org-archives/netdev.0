From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [linux-next] oops in ip_route_input_noref
Date: Wed, 16 Sep 2015 12:00:55 -0300
Message-ID: <CAOMZO5CTgq_Sd81=XWEHv5oe1WyVpaydNzUXz_EbY2BWR6xF7g@mail.gmail.com>
References: <20150916092447.GA945@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Ahern <dsa@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:38125 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182AbbIPPA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 11:00:56 -0400
In-Reply-To: <20150916092447.GA945@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2015 at 6:24 AM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:

> added by b7503e0cdb5dbec5d201aa69d8888c14679b5ae8
>
>     net: Add FIB table id to rtable
>
>     Add the FIB table id to rtable to make the information available for
>     IPv4 as it is for IPv6.

I see the same issue here when booting a mx25 ARM processor via NFS.

defconfig is arch/arm/configs/imx_v4_v5_defconfig.

It happens in 100% of the boots and the log is:

fec 50038000.ethernet eth0: Link is Up - 100Mbps/Full - flow control rx/tx
Sending DHCP requests .
Unable to handle kernel NULL pointer dereference at virtual address 00000007
pgd = c0004000
[00000007] *pgd=00000000
Internal error: Oops: 1 [#1] PREEMPT ARM
Modules linked in:
CPU: 0 PID: 0 Comm: swapper Not tainted 4.3.0-rc1-next-20150916-dirty #96
Hardware name: Freescale i.MX25 (Device Tree Support)
task: c06ac1d0 ti: c06a8000 task.ti: c06a8000
PC is at ip_route_input_noref+0x3d8/0x808
LR is at __local_bh_enable_ip+0x5c/0xdc
pc : [<c0439ef0>]    lr : [<c001bfc0>]    psr: a0000013
sp : c06a9cb0  ip : 0000000a  fp : 00000000
r10: c39b7000  r9 : c39c8d00  r8 : 1e00a8c0
r7 : c39c04a0  r6 : 00000000  r5 : c3969a00  r4 : ffffff8f
r3 : ffffffff  r2 : 00000001  r1 : c0438410  r0 : c3969a00
Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
Control: 0005317f  Table: 80004000  DAC: 00000053
Process swapper (pid: 0, stack limit = 0xc06a8190)
Stack: (0xc06a9cb0 to 0xc06aa000)
9ca0:                                     00000000 00000000 00000044 c06ab93c
9cc0: 0100a8c0 c06f0540 c3a8f74e 00000000 00000002 00070044 c043bba8 00000000
9ce0: ffffffff c06a9d24 00000000 00000002 00000000 1e000000 0100a8c0 00000000
9d00: 00000000 00000000 0100a8c0 1e00a8c0 c3a8f720 00000001 00000000 c3a8f74e
9d20: c39c04a0 c39c04a0 0000002e c3a8f720 00000001 00000000 c06fa580 c043bbbc
9d40: c39b7000 c06a9d60 c3a8f720 c39b7000 c39c04a0 c06f0540 0000002e c043c3a0
9d60: c3a8f896 c06929f4 c39b7000 c30d3ce0 c06a9d78 0100a8c0 c0401190 c06ab9d8
9d80: 00000008 c39b7048 00000008 c06ab9d8 c39b7000 c39b705c c39c04a0 c040dfa0
9da0: c39c04a0 c3a8f74e 0000002e c39b753c c39c04a0 c39c04a0 c06ab9c0 c39b705c
9dc0: c39b7520 00000008 00000000 00000000 00000000 00000000 c39c04a0 c04117c0
9de0: 000008e0 c39c04a0 c39c04a0 c39b7520 00000001 00000000 00000000 00000000
9e00: c39b7000 c0411400 00000000 00000000 00000003 c04120cc c485d000 00000800
9e20: c39c04a0 c02fde40 00000000 c06ac1d0 c06b1c38 00000040 c39b7030 c39b7040
9e40: c3943000 00000000 00000000 00000002 c30d39e0 00000000 00000000 00000000
9e60: c39b74b8 00000040 c39b7460 c39b7520 c06b3ce0 c383de14 e1e6cf80 c39b7520
9e80: 00000001 00000040 0000012c c06a9ea8 ffff8c4d c06b4500 c06fa580 c0411bdc
9ea0: c06a9eb0 ffff8c4d c06a9ea8 c06a9ea8 c06a9eb0 c06a9eb0 00000001 00000000
9ec0: 00000008 00000003 c06fd76c c06fa8d0 00000101 00000004 0000000c c001bc24
9ee0: c39d2080 00000000 00000001 0000000a ffff8c4c 00200000 00000000 00000000
9f00: c06cf3a4 00000000 00000001 c06a9f58 41069264 c3802000 00000000 c001c148
9f20: 00000000 c004c958 c06a9f58 c06fd284 c06a9f58 0000ffff c06a9f8c c06fa69d
9f40: c06b3034 c0009404 c000ac20 60000013 ffffffff c04b5c64 00000000 0005317f
9f60: 0005217f 60000013 c06aa0f4 c06fae98 c06fa69d c06fae98 c06fa69d 41069264
9f80: c06b3034 00000000 600000d3 c06a9fa8 c000ac30 c000ac20 60000013 ffffffff
9fa0: 00000053 c06fae98 00000000 c0041724 c06ac1d0 ffffffff 00000000 c065ebc4
9fc0: ffffffff ffffffff 00000000 c065e670 00000000 c06978bc 00000000 c06fd174
9fe0: c06aa094 c06978b8 c06ad120 80004000 80695fb8 80008048 00000000 00000000
[<c0439ef0>] (ip_route_input_noref) from [<c043bbbc>] (ip_rcv_finish+0xe8/0x31c)
[<c043bbbc>] (ip_rcv_finish) from [<c043c3a0>] (ip_rcv+0x2b4/0x3d4)
[<c043c3a0>] (ip_rcv) from [<c040dfa0>] (__netif_receive_skb_core+0x304/0x944)
[<c040dfa0>] (__netif_receive_skb_core) from [<c0411400>]
(netif_receive_skb_internal+0x28/0x78)
[<c0411400>] (netif_receive_skb_internal) from [<c04120cc>]
(napi_gro_receive+0x88/0x130)
[<c04120cc>] (napi_gro_receive) from [<c02fde40>] (fec_enet_rx_napi+0x404/0xa78)
[<c02fde40>] (fec_enet_rx_napi) from [<c0411bdc>] (net_rx_action+0xf8/0x334)
[<c0411bdc>] (net_rx_action) from [<c001bc24>] (__do_softirq+0x11c/0x3a0)
[<c001bc24>] (__do_softirq) from [<c001c148>] (irq_exit+0xac/0xf8)
[<c001c148>] (irq_exit) from [<c004c958>] (__handle_domain_irq+0x64/0xd0)
[<c004c958>] (__handle_domain_irq) from [<c0009404>] (avic_handle_irq+0x34/0x54)
[<c0009404>] (avic_handle_irq) from [<c04b5c64>] (__irq_svc+0x44/0x78)
Exception stack(0xc06a9f58 to 0xc06a9fa0)
9f40:                                                       00000000 0005317f
9f60: 0005217f 60000013 c06aa0f4 c06fae98 c06fa69d c06fae98 c06fa69d 41069264
9f80: c06b3034 00000000 600000d3 c06a9fa8 c000ac30 c000ac20 60000013 ffffffff
[<c04b5c64>] (__irq_svc) from [<c000ac20>] (arch_cpu_idle+0x28/0x44)
[<c000ac20>] (arch_cpu_idle) from [<c0041724>] (cpu_startup_entry+0x118/0x2bc)
[<c0041724>] (cpu_startup_entry) from [<c065ebc4>] (start_kernel+0x308/0x368)
[<c065ebc4>] (start_kernel) from [<80008048>] (0x80008048)
Code: e3a02001 e3530000 e585102c e5c5205e (15933008)
---[ end trace 443993f61e8bf0a0 ]---
Kernel panic - not syncing: Fatal exception in interrupt
---[ end Kernel panic - not syncing: Fatal exception in interrupt
