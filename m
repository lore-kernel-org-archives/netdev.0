From: latten@austin.ibm.com
Subject: IPSecv6/Neighbor discovery crash
Date: Thu, 21 Aug 2003 20:49:47 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308220149.h7M1nlAU017798@faith.austin.ibm.com>
Cc: kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am using linux-2.6.0-test3 + patch-2.6.0-test3-bk7 on SMP machines.
Upon configuring AH, I do a ping6 to test connectivity and 
I get the following trace. (see first crash)
I have seen this crash with ESP configured also. 

This only seems to happen when IPSecv6 is configured. 
So far, I have not been able to track down the culprit... I have
not been able to determine if it is a lock... icmpv6_echo_reply()
takes a lock on the socket and will let it go when done...
Has anyone else seen this? 

Joy


Unable to handle kernel NULL pointer dereference at virtual address 00000164
 printing eip:
c0445767
*pde = 00000000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c0445767>]    Not tainted
EFLAGS: 00010246
EIP is at ndisc_build_ll_hdr+0x17/0x1e0
eax: 00000000   ebx: f7564bc0   ecx: f550ce60   edx: f6d388c0
esi: c1af9430   edi: 00000000   ebp: c05c1c90   esp: c05c1c44
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c05c0000 task=c050f020)
Stack: c1ab41a0 f29ad1c4 f3128624 f3128640 00000206 0000000c 3a000246 f70803e0
       f7080408 c1aff200 c05c1cb0 c0460b4d f70803e0 f7564bc0 c1af944c c1aff214
       f7564bc0 f7564bc0 c1af94cc c05c1cb0 c0445970 f7564bc0 00000000 c1af9430
Call Trace:
 [<c0460b4d>] ah6_output+0x26d/0x510
 [<c0445970>] ndisc_output+0x40/0x80
 [<c043822f>] ip6_push_pending_frames+0x22f/0x380
 [<c044e496>] icmpv6_push_pending_frames+0x116/0x1a0
 [<c044edfa>] icmpv6_echo_reply+0x28a/0x340
 [<c044f324>] icmpv6_rcv+0x264/0x590
 [<c0438820>] ip6_input+0x120/0x2e0
 [<c04385ee>] ipv6_rcv+0x13e/0x250
 [<c03cf62b>] netif_receive_skb+0x16b/0x200
 [<c03cf744>] process_backlog+0x84/0x120
 [<c03cf863>] net_rx_action+0x83/0x110
 [<c0129de7>] do_softirq+0xe7/0xf0
 [<c010e10d>] do_IRQ+0x15d/0x200
 [<c0119c3d>] smp_apic_timer_interrupt+0xcd/0x140
 [<c0109060>] default_idle+0x0/0x40
 [<c010c170>] common_interrupt+0x18/0x20
 [<c0109060>] default_idle+0x0/0x40
 [<c0109090>] default_idle+0x30/0x40
 [<c0109126>] cpu_idle+0x46/0x50
 [<c0105000>] rest_init+0x0/0x80
 [<c05c298e>] start_kernel+0x19e/0x1f0
 [<c05c2500>] unknown_bootoption+0x0/0x110

Code: 8b 80 64 01 00 00 85 c0 75 14 ba 01 00 00 00 8b 5d f4 89 d0
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing
