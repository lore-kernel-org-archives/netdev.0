From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: oops in raw_rcv_skb
Date: Fri, 1 Aug 2003 01:35:04 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0308010125480.18584@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You can reproduce this one easily by doing 5-6 ping -f of a system on the 
network (not loopback), originally picked up at http://bugme.osdl.org/show_bug.cgi?id=937

Unable to handle kernel paging request at virtual address c5100068
 printing eip:
c02ae8b6
*pde = 00015067
*pte = 05100163
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c02ae8b6>]    Not tainted
EFLAGS: 00010246
EIP is at raw_rcv_skb+0x156/0x220
eax: 00000040   ebx: c52ed060   ecx: c4f6e024   edx: 00000014
esi: c52ed004   edi: c5100004   ebp: c52ed06c   esp: c5661d24
ds: 007b   es: 007b   ss: 0068
Process ping (pid: 283, threadinfo=c5660000 task=c585f000)
Stack: c5100000 c1169890 00001000 00000206 00000000 c1169890 c5100000 0000005a
       c5100004 c52ed004 c4f6e024 c54a2004 c02aea1d c52ed004 c5100004 c54a2038
       00000030 00000001 c52ed004 c02ae569 c52ed004 c5100004 6164050a 1964050a
Call Trace:
 [<c02aea1d>] raw_rcv+0x9d/0x110
 [<c02ae569>] raw_v4_input+0xa9/0x130
 [<c028ad0b>] ip_local_deliver+0x8b/0x200
 [<c028b1fc>] ip_rcv+0x37c/0x47a
 [<c0118588>] kernel_map_pages+0x28/0x5c
 [<c027a205>] netif_receive_skb+0x165/0x1f0
 [<c027a319>] process_backlog+0x89/0x120
 [<c027a441>] net_rx_action+0x91/0x110
 [<c0123165>] do_softirq+0xd5/0xe0
 [<c010bfd5>] do_IRQ+0x165/0x220
 [<c010a06c>] common_interrupt+0x18/0x20
 [<c027007b>] pirq_sis_get+0x9b/0xc0
 [<c01557d2>] fput+0x2/0x20
 [<c0169a05>] poll_freewait+0x35/0x50
 [<c0169df1>] do_select+0x201/0x350
 [<c0169a20>] __pollwait+0x0/0xd0
 [<c016a24b>] sys_select+0x2db/0x4e0
 [<c027007b>] pirq_sis_get+0x9b/0xc0
 [<c01096ff>] syscall_call+0x7/0xb
 
Code: 8b 47 64 89 34 24 89 44 24 04 ff 96 50 01 00 00 eb b2 0f 0b
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing

-- 
function.linuxpower.ca
