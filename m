From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Fw: [Bug 14470] New: freez in TCP stack
Date: Mon, 26 Oct 2009 08:41:32 -0700
Message-ID: <20091026084132.57bc3d07@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42148 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752122AbZJZPlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 11:41:36 -0400
Received: from nehalam (pool-74-107-146-78.ptldor.fios.verizon.net [74.107.146.78])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n9QFfcFS029666
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 08:41:40 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 26 Oct 2009 12:47:22 GMT
From: bugzilla-daemon@bugzilla.kernel.org
To: shemminger@linux-foundation.org
Subject: [Bug 14470] New: freez in TCP stack


http://bugzilla.kernel.org/show_bug.cgi?id=14470

           Summary: freez in TCP stack
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.31
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: kolo@albatani.cz
        Regression: No


We are hiting kernel panics on Dell R610 servers with e1000e NICs; it apears
usualy under a high network trafic ( around 100Mbit/s) but it is not a rule it
has happened even on low trafic.

Servers are used as reverse http proxy (varnish).

On 6 equal servers this panic happens aprox 2 times a day depending on network
load. Machine completly freezes till the management watchdog reboots. 


We had to put serial console on these servers to catch the oops. Is there
anything else We can do to debug this?
The RIP is always the same:

RIP: 0010:[<ffffffff814203cc>]  [<ffffffff814203cc>]
tcp_xmit_retransmit_queue+0x8c/0x290

rest of the oops always differs a litle ... here is an example:

RIP: 0010:[<ffffffff814203cc>]  [<ffffffff814203cc>]
tcp_xmit_retransmit_queue+0x8c/0x290
RSP: 0018:ffffc90000003a40  EFLAGS: 00010246
RAX: ffff8807e7420678 RBX: ffff8807e74205c0 RCX: 0000000000000000
RDX: 000000004598a105 RSI: 0000000000000000 RDI: ffff8807e74205c0
RBP: ffffc90000003a80 R08: 0000000000000003 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000
R13: ffff8807e74205c0 R14: ffff8807e7420678 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000000000000000 CR3: 0000000001001000 CR4: 00000000000006f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff81608000, task ffffffff81631440)
Stack:
 ffffc90000003a60 0000000000000000 4598a105e74205c0 000000004598a101
<0> 000000000000050e ffff8807e74205c0 0000000000000003 0000000000000000
<0> ffffc90000003b40 ffffffff8141ae4a ffff8807e7420678 0000000000000000
Call Trace:
 <IRQ>
 [<ffffffff8141ae4a>] tcp_ack+0x170a/0x1dd0
 [<ffffffff8141c362>] tcp_rcv_state_process+0x122/0xab0
 [<ffffffff81422c6c>] tcp_v4_do_rcv+0xac/0x220
 [<ffffffff813fd02f>] ? nf_iterate+0x5f/0x90
 [<ffffffff81424b26>] tcp_v4_rcv+0x586/0x6b0
 [<ffffffff813fd0c5>] ? nf_hook_slow+0x65/0xf0
 [<ffffffff81406b70>] ? ip_local_deliver_finish+0x0/0x120
 [<ffffffff81406bcf>] ip_local_deliver_finish+0x5f/0x120
 [<ffffffff8140715b>] ip_local_deliver+0x3b/0x90
 [<ffffffff81406971>] ip_rcv_finish+0x141/0x340
 [<ffffffff8140701f>] ip_rcv+0x24f/0x350
 [<ffffffff813e7ced>] netif_receive_skb+0x20d/0x2f0
 [<ffffffff813e7e90>] napi_skb_finish+0x40/0x50
 [<ffffffff813e82f4>] napi_gro_receive+0x34/0x40
 [<ffffffff8133e0c8>] e1000_receive_skb+0x48/0x60
 [<ffffffff81342342>] e1000_clean_rx_irq+0xf2/0x330
 [<ffffffff813410a1>] e1000_clean+0x81/0x2a0
 [<ffffffff81054ce1>] ? ktime_get+0x11/0x50
 [<ffffffff813eaf1c>] net_rx_action+0x9c/0x130
 [<ffffffff81046940>] ? get_next_timer_interrupt+0x1d0/0x210
 [<ffffffff81041bd7>] __do_softirq+0xb7/0x160
 [<ffffffff8100c27c>] call_softirq+0x1c/0x30
 [<ffffffff8100e04d>] do_softirq+0x3d/0x80
 [<ffffffff81041b0b>] irq_exit+0x7b/0x90
 [<ffffffff8100d613>] do_IRQ+0x73/0xe0
 [<ffffffff8100bb13>] ret_from_intr+0x0/0xa
 <EOI>
 [<ffffffff81296e6c>] ? acpi_idle_enter_bm+0x245/0x271
 [<ffffffff81296e62>] ? acpi_idle_enter_bm+0x23b/0x271
 [<ffffffff813c7a08>] ? cpuidle_idle_call+0x98/0xf0
 [<ffffffff8100a104>] ? cpu_idle+0x94/0xd0
 [<ffffffff81468db6>] ? rest_init+0x66/0x70
 [<ffffffff816a082f>] ? start_kernel+0x2ef/0x340
 [<ffffffff8169fd54>] ? x86_64_start_reservations+0x84/0x90
 [<ffffffff8169fe32>] ? x86_64_start_kernel+0xd2/0x100
Code: 00 eb 28 8b 83 d0 03 00 00 41 39 44 24 40 0f 89 00 01 00 00 41 0f b6 cd
41 bd 2f 00 00 00 83 e1 03 0f 84 fc 00 00 00 4d 8b 24 24 <49> 8b 04 24 4d 39 f4
0f 18 08 0f 84 d9 00 00 00 4c 3b a3 b8 01
RIP  [<ffffffff814203cc>] tcp_xmit_retransmit_queue+0x8c/0x290
 RSP <ffffc90000003a40>
CR2: 0000000000000000
---[ end trace d97d99c9ae1d52cc ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D    2.6.31 #2
Call Trace:
 <IRQ>  [<ffffffff8103cab0>] panic+0xa0/0x170
 [<ffffffff8100bb13>] ? ret_from_intr+0x0/0xa
 [<ffffffff8103c74e>] ? print_oops_end_marker+0x1e/0x20
 [<ffffffff8100f38e>] oops_end+0x9e/0xb0
 [<ffffffff81025b9a>] no_context+0x15a/0x250
 [<ffffffff81025e2b>] __bad_area_nosemaphore+0xdb/0x1c0
 [<ffffffff813e89e9>] ? dev_hard_start_xmit+0x269/0x2f0
 [<ffffffff81025fae>] bad_area_nosemaphore+0xe/0x10
 [<ffffffff8102639f>] do_page_fault+0x17f/0x260
 [<ffffffff8147eadf>] page_fault+0x1f/0x30
 [<ffffffff814203cc>] ? tcp_xmit_retransmit_queue+0x8c/0x290
 [<ffffffff8141ae4a>] tcp_ack+0x170a/0x1dd0
 [<ffffffff8141c362>] tcp_rcv_state_process+0x122/0xab0
 [<ffffffff81422c6c>] tcp_v4_do_rcv+0xac/0x220
 [<ffffffff813fd02f>] ? nf_iterate+0x5f/0x90
 [<ffffffff81424b26>] tcp_v4_rcv+0x586/0x6b0
 [<ffffffff813fd0c5>] ? nf_hook_slow+0x65/0xf0
 [<ffffffff81406b70>] ? ip_local_deliver_finish+0x0/0x120
 [<ffffffff81406bcf>] ip_local_deliver_finish+0x5f/0x120
 [<ffffffff8140715b>] ip_local_deliver+0x3b/0x90
 [<ffffffff81406971>] ip_rcv_finish+0x141/0x340
 [<ffffffff8140701f>] ip_rcv+0x24f/0x350
 [<ffffffff813e7ced>] netif_receive_skb+0x20d/0x2f0
 [<ffffffff813e7e90>] napi_skb_finish+0x40/0x50
 [<ffffffff813e82f4>] napi_gro_receive+0x34/0x40
 [<ffffffff8133e0c8>] e1000_receive_skb+0x48/0x60
 [<ffffffff81342342>] e1000_clean_rx_irq+0xf2/0x330
 [<ffffffff813410a1>] e1000_clean+0x81/0x2a0
 [<ffffffff81054ce1>] ? ktime_get+0x11/0x50
 [<ffffffff813eaf1c>] net_rx_action+0x9c/0x130
 [<ffffffff81046940>] ? get_next_timer_interrupt+0x1d0/0x210
 [<ffffffff81041bd7>] __do_softirq+0xb7/0x160
 [<ffffffff8100c27c>] call_softirq+0x1c/0x30
 [<ffffffff8100e04d>] do_softirq+0x3d/0x80
 [<ffffffff81041b0b>] irq_exit+0x7b/0x90
 [<ffffffff8100d613>] do_IRQ+0x73/0xe0
 [<ffffffff8100bb13>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff81296e6c>] ? acpi_idle_enter_bm+0x245/0x271
 [<ffffffff81296e62>] ? acpi_idle_enter_bm+0x23b/0x271
 [<ffffffff813c7a08>] ? cpuidle_idle_call+0x98/0xf0
 [<ffffffff8100a104>] ? cpu_idle+0x94/0xd0
 [<ffffffff81468db6>] ? rest_init+0x66/0x70
 [<ffffffff816a082f>] ? start_kernel+0x2ef/0x340
 [<ffffffff8169fd54>] ? x86_64_start_reservations+0x84/0x90
 [<ffffffff8169fe32>] ? x86_64_start_kernel+0xd2/0x100

-- 
Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.


-- 
