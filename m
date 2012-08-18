From: Dave Jones <davej@redhat.com>
Subject: Re: BUG: unable to handle kernel paging request at 00010016
Date: Sat, 18 Aug 2012 11:00:25 -0400
Message-ID: <20120818150025.GA29454@redhat.com>
References: <502ECC74.9030605@oak.selfip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Haywood <tla@oak.selfip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2814 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752917Ab2HRPAo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Aug 2012 11:00:44 -0400
Content-Disposition: inline
In-Reply-To: <502ECC74.9030605@oak.selfip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ trimmed, and cc'd to netdev.  oops-tracing.txt asks for an excessive amount
  of info, we should probably rewrite that, as it's rare that 160KB bug reports
  are necessary ]

 > BUG: unable to handle kernel paging request at 00010016
 > IP: [<c15acfc9>] inet6_sk_rx_dst_set+0x29/0x40
 > *pde = 00000000
 > Oops: 0000 [#1] SMP
 > Pid: 2168, comm: mprime Not tainted 3.6.0-rc2 #297 Compaq Deskpro/06C4h
 > EIP: 0060:[<c15acfc9>] EFLAGS: 00010202 CPU: 0
 > EIP is at inet6_sk_rx_dst_set+0x29/0x40
 > EAX: ce738508 EBX: ce73a760 ECX: cf377000 EDX: 00010002
 > ESI: ca06c900 EDI: ce738000 EBP: cf80bc7c ESP: cf80bc7c
 >  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
 > CR0: 80050033 CR2: 00010016 CR3: 0a036000 CR4: 000007d0
 > DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
 > DR6: ffff0ff0 DR7: 00000400
 > Process mprime (pid: 2168, ti=cf80a000 task=ce4f7390 task.ti=ca052000)
 > Stack:
 >  cf80bc9c c15449cb ffffffff ce436780 00000000 ce738508 ca06c900 ce738000
 >  cf80bcc0 c154337e c167545e cf80bcec c124b318 ce436780 ce738508 ce738000
 >  ce436780 cf80bd48 c15aff9d 00000000 00000001 cf80bcec c1236880 ce691ec0
 > Call Trace:
 >  [<c15449cb>] tcp_create_openreq_child+0x3b/0x4a0
 >  [<c154337e>] tcp_v4_syn_recv_sock+0x2e/0x2a0
 >  [<c167545e>] ? _raw_spin_unlock_bh+0xe/0x10
 >  [<c124b318>] ? selinux_netlbl_sock_rcv_skb+0x18/0x190
 >  [<c15aff9d>] tcp_v6_syn_recv_sock+0x3ed/0x6d0
 >  [<c1236880>] ? selinux_parse_skb+0x50/0xb0
 >  [<c15450b3>] tcp_check_req+0x283/0x450
 >  [<c1541191>] tcp_v4_hnd_req+0x51/0x140
 >  [<c1542e69>] tcp_v4_do_rcv+0x129/0x1b0
 >  [<c14f5b45>] ? sk_filter+0x25/0xb0
 >  [<c154407e>] tcp_v4_rcv+0x5fe/0x730
 >  [<c15209b0>] ? ip_rcv_finish+0x2f0/0x2f0
 >  [<c1520a3c>] ip_local_deliver_finish+0x8c/0x260
 >  [<c15206c0>] ? inet_del_protocol+0x30/0x30
 >  [<c1520d9f>] ip_local_deliver+0x7f/0x90
 >  [<c15209b0>] ? ip_rcv_finish+0x2f0/0x2f0
 >  [<c15207b1>] ip_rcv_finish+0xf1/0x2f0
 >  [<c15206c0>] ? inet_del_protocol+0x30/0x30
 >  [<c1521002>] ip_rcv+0x252/0x320
 >  [<c15206c0>] ? inet_del_protocol+0x30/0x30
 >  [<c14e19bb>] __netif_receive_skb+0x46b/0x670
 >  [<c14e4b72>] netif_receive_skb+0x22/0x80
 >  [<c13eb6e2>] rtl8139_rx+0xd2/0x370
 >  [<c13eb9c2>] rtl8139_poll+0x42/0xb0
 >  [<c14e56dd>] net_rx_action+0xed/0x1c0
 >  [<c12c6110>] ? fbcon_add_cursor_timer+0xd0/0xd0
 >  [<c10427a7>] __do_softirq+0xa7/0x200
 >  [<c1042700>] ? local_bh_enable_ip+0x80/0x80
 >  <IRQ>
 >  [<c1042b0e>] ? irq_exit+0x6e/0x90
 >  [<c1004176>] ? do_IRQ+0x46/0xb0
 >  [<c1042af7>] ? irq_exit+0x57/0x90
 >  [<c10224a6>] ? smp_apic_timer_interrupt+0x56/0x90
 >  [<c1676289>] ? common_interrupt+0x29/0x30
 > Code: 90 90 55 8b 4a 48 89 e5 83 e1 fe 3e ff 41 40 89 88 8c 00 00 00 8b 52 74 89 90 cc 01 00 00 8b 51 58 85 d2 74 0c 8b 80 a0 01 00 00 <8b> 52 14 89 50 68 5d c3 eb 0d 90 90 90 90 90 90 90 90 90 90 90
 > EIP: [<c15acfc9>] inet6_sk_rx_dst_set+0x29/0x40 SS:ESP 0068:cf80bc7c
 > CR2: 0000000000010016
 > ---[ end trace 1fcc7fe92846c9d3 ]---
 > Kernel panic - not syncing: Fatal exception in interrupt
