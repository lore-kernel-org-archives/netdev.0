From: Burton Windle <bwindle@fint.org>
Subject: 2.6.0-test1: oops in raw_rcv_skb
Date: Tue, 15 Jul 2003 17:46:22 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.43.0307151743030.1640-100000@morpheus>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello. Forgive me if you don't want to see these; I already filed it at
bugzilla.kernel.org (http://bugzilla.kernel.org/show_bug.cgi?id=937), but
thought I saw in the list you wanted them emailed to the maintaiers as well.

When doing a ping flood of another machine on my same network (using
multiple instances of 'ping -f hostname &'), after about 10 seconds I get this
oops, and the machine hangs:

Unable to handle kernel paging request at virtual address c4f66068
 printing eip:
c02b6bd0
*pde = 00014067
*pte = 04f66000
Oops: 0000 [#1]
CPU:    0
EIP:    0060:[<c02b6bd0>]    Not tainted
EFLAGS: 00010246
EIP is at raw_rcv_skb+0x190/0x260
eax: 00000040   ebx: c5321060   ecx: c4dae024   edx: 00000014
esi: c5160000   edi: c5321004   ebp: c4f66004   esp: c5161b80
ds: 007b   es: 007b   ss: 0068
Process ping (pid: 294, threadinfo=c5160000 task=c52cf000)
Stack: c4f66000 c1169890 00001000 c532106c 00000216 00000000 c4f66000 0000005a
       c4f66004 c5321004 c4dae024 c510e004 c02b6d3d c5321004 c4f66004 c510e038
       00000030 00000001 c5321004 c02b681d c5321004 c4f66004 6164050a 1964050a
Call Trace:
 [<c02b6d3d>] raw_rcv+0x9d/0x110
 [<c02b681d>] raw_v4_input+0xad/0x160
 [<c029206b>] ip_local_deliver+0x9b/0x220
 [<c0292586>] ip_rcv+0x396/0x49c
 [<c0118ee8>] kernel_map_pages+0x28/0x5c
 [<c0280211>] netif_receive_skb+0x181/0x210
 [<c0280329>] process_backlog+0x89/0x120
 [<c0280455>] net_rx_action+0x95/0x130
 [<c0124595>] do_softirq+0xd5/0xe0
 [<c010c235>] do_IRQ+0x185/0x230
 [<c010a218>] common_interrupt+0x18/0x20
 [<c011007b>] alloc_ldt+0x7b/0x1f0
 [<c0143334>] kfree+0x204/0x340
 [<c027b253>] kfree_skbmem+0x13/0x30
 [<c027b253>] kfree_skbmem+0x13/0x30
 [<c027b2db>] __kfree_skb+0x6b/0xf0
 [<c02b79a3>] raw_recvmsg+0x113/0x180
 [<c02c343a>] inet_recvmsg+0x5a/0x80
 [<c027719c>] sock_recvmsg+0x9c/0xc0
 [<c0118ee8>] kernel_map_pages+0x28/0x5c
 [<c013ddc9>] __alloc_pages+0x309/0x370
 [<c0276eac>] sockfd_lookup+0x1c/0x80
 [<c02787a2>] sys_recvfrom+0xb2/0x120
 [<c016cbd4>] poll_freewait+0x44/0x50
 [<c016cfa1>] do_select+0x1f1/0x340
 [<c02790d6>] sys_socketcall+0x1e6/0x2a0
 [<c01098ab>] syscall_call+0x7/0xb

Code: 8b 45 64 89 3c 24 89 44 24 04 ff 97 50 01 00 00 eb b2 e8 59
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing

Distribution: Debian Testing
Hardware Environment: Dual Pentium2 266, AIC-7880 SCSI, 3Com PCI 3c905C Tornado
Software Environment: gcc 3.3.1, SMP kernel, preempt on


--
Burton Windle                           burton@fint.org
Linux: the "grim reaper of innocent orphaned children."
          from /usr/src/linux-2.4.18/init/main.c:461
