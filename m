From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [BUG] 3.11.5: IPv6 provoked oops?
Date: Fri, 20 Dec 2013 20:31:16 +0000
Message-ID: <20131220203115.GL4360@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35882 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751471Ab3LTUb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:31:56 -0500
Received: from n2100.arm.linux.org.uk ([2002:4e20:1eda:1:214:fdff:fe10:4f86]:33881)
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.76)
	(envelope-from <linux@arm.linux.org.uk>)
	id 1Vu6jc-0004QN-6b
	for netdev@vger.kernel.org; Fri, 20 Dec 2013 20:31:49 +0000
Received: from linux by n2100.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <linux@n2100.arm.linux.org.uk>)
	id 1Vu6jN-0006cS-2V
	for netdev@vger.kernel.org; Fri, 20 Dec 2013 20:31:33 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So, I'm now running PPPoE on this box, which also does 6to4.  I tried
to ping another 6to4 address from a box on my lan, which caused this
oops from 3.11.5:

kernel BUG at /home/rmk/git/linux-stable/net/core/skbuff.c:1059!
Internal error: Oops - BUG: 0 [#1] ARM
Modules linked in: sunrpc pppoe pppox ppp_generic slhc sit ip_tunnel
 tunnel4 nf_nat_sip nf_conntrack_sip iptable_raw xt_TCPMSS
 xt_mark xt_connmark iptable_mangle xt_nat iptable_nat nf_nat_ipv4
 nf_nat xt_comment xt_u32 ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4
 xt_multiport iptable_filter ip_tables xt_LOG xt_limit xt_tcpudp
 nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter
 ip6table_mangle ip6_tables x_tables ipv6 redboot cfi_cmdset_0001
 cfi_probe gen_probe cfi_util physmap mtd chipreg ehci_pci leds_pca9532 
 ehci_hcd uhci_hcd r8169 sg mii usbcore usb_common 
CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.5+ #23
task: c03363f8 ti: c032c000 task.ti: c032c000
PC is at pskb_expand_head+0x34/0x260
LR is at ip6_forward+0x648/0x880 [ipv6]
pc : [<c01c2f38>]    lr : [<bf0c9ef8>]    psr: 20000013
sp : c032db34  ip : c032db60  fp : c032db5c
r10: bf0cb3a4  r9 : bf0cb3a4  r8 : 00000040
r7 : d5d2b858  r6 : 00000020  r5 : de7faa80  r4 : d5d2b840
r3 : ddc4f800  r2 : 00000000  r1 : 00000003  r0 : ddc4ff40
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
Control: 0000397f  Table: bc21c000  DAC: 00000017
Process swapper (pid: 0, stack limit = 0xc032c1a8)
...
Backtrace:
[<c01c2f04>] (pskb_expand_head+0x0/0x260) from [<bf0c9ef8>] (ip6_forward+0x648/0x880 [ipv6])
[<bf0c98b0>] (ip6_forward+0x0/0x880 [ipv6]) from [<bf0cb428>] (ip6_rcv_finish+0x84/0x90 [ipv6])
[<bf0cb3a4>] (ip6_rcv_finish+0x0/0x90 [ipv6]) from [<bf154884>] (__ipv6_conntrack_in.clone.6+0x11c/0x198 [nf_conntrack_ipv6])
 r4:d5d2b840
[<bf154768>] (__ipv6_conntrack_in.clone.6+0x0/0x198 [nf_conntrack_ipv6]) from [<bf15491c>] (ipv6_conntrack_in+0x1c/0x20 [nf_$
[<bf154900>] (ipv6_conntrack_in+0x0/0x20 [nf_conntrack_ipv6]) from [<c01efb90>] (nf_iterate+0x60/0xa0)
[<c01efb30>] (nf_iterate+0x0/0xa0) from [<c01efc3c>] (nf_hook_slow+0x6c/0x12c)
[<c01efbd0>] (nf_hook_slow+0x0/0x12c) from [<bf14ec50>] (nf_ct_frag6_output+0xc0/0x118 [nf_defrag_ipv6])
[<bf14eb90>] (nf_ct_frag6_output+0x0/0x118 [nf_defrag_ipv6]) from [<bf14e084>] (ipv6_defrag+0x74/0x94 [nf_defrag_ipv6])
[<bf14e010>] (ipv6_defrag+0x0/0x94 [nf_defrag_ipv6]) from [<c01efb90>] (nf_iterate+0x60/0xa0)
 r7:00000000 r6:d5d2b780 r5:c0334c90 r4:c032dd3c
[<c01efb30>] (nf_iterate+0x0/0xa0) from [<c01efc3c>] (nf_hook_slow+0x6c/0x12c)
[<c01efbd0>] (nf_hook_slow+0x0/0x12c) from [<bf0cb848>] (ipv6_rcv+0x414/0x48c [ipv6])
[<bf0cb434>] (ipv6_rcv+0x0/0x48c [ipv6]) from [<c01cbdf4>] (__netif_receive_skb_core+0x618/0x688)
 r8:0000dd86 r7:00000000 r6:df80e000 r5:bf0f9994 r4:c0334484
[<c01cb7dc>] (__netif_receive_skb_core+0x0/0x688) from [<c01cbedc>] (__netif_receive_skb+0x78/0x80)
[<c01cbe64>] (__netif_receive_skb+0x0/0x80) from [<c01cc090>] (netif_receive_skb+0x60/0x6c)
 r5:d5d2b780 r4:d5d2b780
[<c01cc030>] (netif_receive_skb+0x0/0x6c) from [<c01ccab4>] (napi_gro_receive+0x50/0xa0)
 r4:00000003
[<c01cca64>] (napi_gro_receive+0x0/0xa0) from [<bf0466ec>] (rtl8169_poll+0x300/0x538 [r8169])
 r5:df80e000 r4:df80e3a0
[<bf0463ec>] (rtl8169_poll+0x0/0x538 [r8169]) from [<c01cc2c4>] (net_rx_action+0x78/0x1ac)
[<c01cc24c>] (net_rx_action+0x0/0x1ac) from [<c001e3f0>] (__do_softirq+0xbc/0x1a8)
[<c001e334>] (__do_softirq+0x0/0x1a8) from [<c001e588>] (do_softirq+0x4c/0x68)
[<c001e53c>] (do_softirq+0x0/0x68) from [<c001e824>] (irq_exit+0x80/0xd8)
 r4:c032c000
[<c001e7a4>] (irq_exit+0x0/0xd8) from [<c000f110>] (handle_IRQ+0x6c/0x8c)
 r4:0000001b
[<c000f0a4>] (handle_IRQ+0x0/0x8c) from [<c0008190>] (asm_do_IRQ+0x10/0x14)
 r5:60000013 r4:c000f2a0
[<c0008180>] (asm_do_IRQ+0x0/0x14) from [<c0011f1c>] (__irq_svc+0x3c/0x60)
Exception stack(0xc032df44 to 0xc032df8c)
df40:          00000001 00000000 00000000 60000013 c032c000 c034a61f c0334064
df60: 00000001 a0004000 69052e30 a0323038 c032df98 c032df9c c032df8c c000f294
df80: c000f2a0 60000013 ffffffff
[<c000f26c>] (arch_cpu_idle+0x0/0x3c) from [<c0042a88>] (cpu_startup_entry+0x84/0xe8)
[<c0042a04>] (cpu_startup_entry+0x0/0xe8) from [<c0250d0c>] (rest_init+0x64/0x7c)
 r7:c0336fdc r6:c075c0a0 r5:c0325168 r4:c03340a4
[<c0250ca8>] (rest_init+0x0/0x7c) from [<c030ca18>] (start_kernel+0x29c/0x2f0)
[<c030c77c>] (start_kernel+0x0/0x2f0) from [<a000803c>] (0xa000803c)
Code: e7f001f2 e59410b4 e3510001 0a000000 (e7f001f2)
---[ end trace cd0e36495a7451a4 ]---
Kernel panic - not syncing: Fatal exception in interrupt
