From: md@Linux.IT (Marco d'Itri)
Subject: networking-related oopses on 2.6.9
Date: Fri, 28 Jan 2005 15:08:36 +0100
Message-ID: <20050128140836.GA10777@wonderland.linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxppc-dev@ozlabs.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[Please Cc me, I'm not subscribed to either list.]

In the last few days, after about two months it was running, one of my
servers (an IBM B50) running 2.6.9 vanilla started oopsing.
A twin server running the same kernel had no problems, but it's less
loaded.
Now I switched it back to 2.6.6, which never showed problems (but I need
something newer, because SSM multicast is broken in this release).

I have been able to capture the latest two oopses from the serial
console, is this a known problem?

KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tc
Oops: kernel access of bad area, sig: 11 [#1]
NIP: C01B3BBC LR: C01B3B8C SP: D01D7DF0 REGS: d01d7d40 TRAP: 0300    Not tainted
MSR: 00009032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
DAR: 00000048, DSISR: 40000000
TASK = cf5439d0[9999] 'bryar.cgi' THREAD: d01d6000Last syscall: 6
GPR00: 00000000 D01D7DF0 CF5439D0 000004B8 00000500 00000308 00000000 C034A250
GPR08: 000004B8 FFFFFFF5 00000000 00000000 34D0744B 1001B8D4 00000000 00000000
GPR16: 00000000 00000080 102E1FE8 00000000 102E1FDC 102E1FF0 00000000 10003078
GPR24: C0360000 C0340000 C0360000 000004B8 C0310000 CC4371E0 CC4373B4 00000000
NIP [c01b3bbc] tcp_retransmit_skb+0x54/0x39c
LR [c01b3b8c] tcp_retransmit_skb+0x24/0x39c
Call trace:
 [c01b61f0] tcp_retransmit_timer+0x134/0x47c
 [c01b65fc] tcp_write_timer+0xc4/0xec
 [c002396c] run_timer_softirq+0xf8/0x1ac
 [c001f004] __do_softirq+0xdc/0xec
 [c001f06c] do_softirq+0x58/0x5c
 [c00083bc] timer_interrupt+0x1fc/0x22c
 [c0006660] ret_from_except+0x0/0x14
Kernel panic - not syncing: Aiee, killing interrupt handler!


Oops: kernel access of bad area, sig: 11 [#1]
NIP: C01AB880 LR: C01AC6D0 SP: C030FBE0 REGS: c030fb30 TRAP: 0300    Not tainted
MSR: 00009032 EE: 1 PR: 0 FP: 0 ME: 1 IR/DR: 11
DAR: 00000050, DSISR: 40000000
TASK = c02973e0[0] 'swapper' THREAD: c030e000Last syscall: 120
GPR00: 00000000 C030FBE0 C02973E0 00000001 D21EEB34 00000003 00000001 0000021D
GPR08: 00000000 00000000 001AA19A 00000000 2401C088 00000000 00000000 00000000
GPR16: 00000000 00000000 00000000 00000000 C0340000 00000004 DFD37648 00000006
GPR24: C0310000 00000003 00000000 00000000 7ABF8951 D21EE960 D21EE960 D21EEB34
NIP [c01ab880] tcp_time_to_recover+0x84/0x1f4
LR [c01ac6d0] tcp_fastretrans_alert+0x1a4/0x7ac
Call trace:
 [c01ac6d0] tcp_fastretrans_alert+0x1a4/0x7ac
 [c01adc90] tcp_ack+0x178/0x560
 [c01b0a34] tcp_rcv_established+0x410/0x824
 [c020cf18] tcp_v6_do_rcv+0x2a0/0x320
 [c020d5d0] tcp_v6_rcv+0x638/0x854
 [c01ec188] ip6_input+0x1dc/0x384
 [c01ebe98] ipv6_rcv+0x1a8/0x2bc
 [c01882cc] netif_receive_skb+0x178/0x250
 [c018844c] process_backlog+0xa8/0x188
 [c01885c4] net_rx_action+0x98/0x178
 [c001f004] __do_softirq+0xdc/0xec
 [c001f06c] do_softirq+0x58/0x5c
 [c0007e70] do_IRQ+0xc8/0xcc
 [c0006660] ret_from_except+0x0/0x14
 [c0008140] default_idle+0x14/0x5c
Kernel panic - not syncing: Aiee, killing interrupt handler!

-- 
ciao,
Marco
