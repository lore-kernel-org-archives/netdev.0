From: David Coulson <david@davidcoulson.net>
Subject: EIP is at find_busiest_group+0xc9/0x310 (2.6.11-rc1-bk8)
Date: Wed, 26 Jan 2005 22:01:33 -0500
Message-ID: <41F8598D.4070400@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Same kernel I've been working with for the last week, with Herbert's 
checksum patch (Thanks for that, BTW :). Not sure if this is a network 
issue, since the problem is in apic.c, but since it was all network 
functions prior, I figured something kicked it off. I found an apparent 
patch for find_busiest_group, but it didn't make it into the mainline in 
six months, so I assume it's either wrong, broke, or the implementation 
is whacked.

stack segment: 0000 [#1]
SMP
CPU:    0
EIP:    0060:[<c01162b9>]    Not tainted VLI
EFLAGS: 00010246   (2.6.11-rc1-bk8)
EIP is at find_busiest_group+0xc9/0x310
eax: c8000980   ebx: c8000980   ecx: ded227ff   edx: c89c3680
esi: dd89d000   edi: c0314b40   ebp: 00000002   esp: c04bddbc
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c04bc000 task=c0408b60)
Stack: c0314b69 c8000980 c038800a ded22800 c047e5e0 c04bde20 c0542650 
80000000
        c02f0512 dd89d000 c0314b40 00000002 c04bde1c c79e4810 00000002 
00000002
        c0314b40 c02f0818 ded22800 dd89d000 c04bde20 c0314b40 80000000 
00000000
Call Trace:
  [<c0314b69>] ip_forward_finish+0x29/0x50
  [<c038800a>] ip_sabotage_out+0x10a/0x180
  [<c02f0512>] nf_iterate+0x72/0xb0
  [<c0314b40>] ip_forward_finish+0x0/0x50
  [<c0314b40>] ip_forward_finish+0x0/0x50
  [<c02f0818>] nf_hook_slow+0x68/0xf0
  [<c0314b40>] ip_forward_finish+0x0/0x50
  [<c0314a7c>] ip_forward+0x1bc/0x280
  [<c0314b40>] ip_forward_finish+0x0/0x50
  [<c03138e8>] ip_rcv_finish+0x1f8/0x270
  [<c0386d10>] br_nf_pre_routing_finish+0x0/0x290
  [<c03874cb>] br_nf_pre_routing+0x24b/0x3f0
  [<c0386d10>] br_nf_pre_routing_finish+0x0/0x290
  [<c0387eec>] ip_sabotage_in+0x1c/0x30
  [<c02f0512>] nf_iterate+0x72/0xb0
  [<c03136f0>] ip_rcv_finish+0x0/0x270
  [<c03136f0>] ip_rcv_finish+0x0/0x270
  [<c02f0818>] nf_hook_slow+0x68/0xf0
  [<c03136f0>] ip_rcv_finish+0x0/0x270
  [<c031345c>] ip_rcv+0x3ec/0x4b0
  [<c03136f0>] ip_rcv_finish+0x0/0x270
  [<c03833d0>] br_handle_frame_finish+0x0/0xf0
  [<c02e70ed>] netif_receive_skb+0x20d/0x2b0
  [<c02e7216>] process_backlog+0x86/0x120
  [<c02e732f>] net_rx_action+0x7f/0x110
  [<c011f986>] __do_softirq+0xb6/0xd0
  [<c011f9cd>] do_softirq+0x2d/0x30
  [<c010515e>] do_IRQ+0x1e/0x30
  [<c0103912>] common_interrupt+0x1a/0x20
  [<c0101053>] default_idle+0x23/0x30
  [<c01010ff>] cpu_idle+0x5f/0x70
  [<c04be88f>] start_kernel+0x13f/0x160
  [<c04be330>] unknown_bootoption+0x0/0x1c0
Code: 26 00 8b 45 c4 85 c0 0f 84 35 02 00 00 8b 3c 8d 20 30 51 c0 b8 c0 
e0 50 c0
  01 f8 8b 50 04 8b 40 08 c1 e2 07 39 c2 0f 43 c2 ff 45 <c8> 41 01 c6 ba 
08 00 00
  00 89 d8 e8 27 51 0e 00 83 f8 09 ba 08
  <0>Kernel panic - not syncing: Fatal exception in interrupt




David
