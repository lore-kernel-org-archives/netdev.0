From: Phil Oester <kernel@linuxace.com>
Subject: NMI lockup in fib_sync_down
Date: Wed, 27 Apr 2005 08:42:13 -0700
Message-ID: <20050427154213.GA18158@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Been trying to upgrade a netfilter box from 2.6.10 to 2.6.11, but
it panics within a few hours due to an NMI lockup.  2.6.10 never
exhibits this problem.

There were some fib cleanups done in the 2.6.11-rc series which
may be related -- any ideas?

Phil

NMI Watchdog detected LOCKUP on CPU1, eip c026a8d4, registers:
CPU:    1
EIP:    0060:[<c026a8d4>]    Not tainted VLI
EFLAGS: 00001482   (2.6.11) 
EIP is at fib_sync_down+0x74/0x140
eax: c11c42f0   ebx: 00001920   ecx: c11c42f8   edx: c11c42f8
esi: f69327fc   edi: f742d034   ebp: f69327ec   esp: c032ada8
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c032a000 task=c191a530)
Stack: f7c07934 c1919334 c1919349 f75c1020 f7b94c80 c024440c 00000004 00000304 
       00000000 c02281ee b6a02450 c11c4241 b6a02174 b6a02450 c11c4241 b6a02174 
       00000003 00000001 f69327ec c11c42f8 00000002 00000003 00000001 f69327b4 
Call Trace:
 [<c024440c>] ip_finish_output2+0xac/0x1b0
 [<c02281ee>] skb_checksum+0x4e/0x2a0
 [<c026f863>] tcp_packet+0xe3/0x430
 [<c0244360>] ip_finish_output2+0x0/0x1b0
 [<c0240920>] ip_forward_finish+0x0/0x50
 [<c026d682>] __ip_conntrack_find+0x12/0xe0
 [<c026df2e>] ip_conntrack_in+0xde/0x290
 [<c02360d2>] nf_iterate+0x72/0xb0
 [<c023f510>] ip_rcv_finish+0x0/0x240
 [<c023f510>] ip_rcv_finish+0x0/0x240
 [<c0236388>] nf_hook_slow+0x68/0xf0
 [<c023f510>] ip_rcv_finish+0x0/0x240
 [<c023f2f2>] ip_rcv+0x3c2/0x480
 [<c023f510>] ip_rcv_finish+0x0/0x240
 [<c0226d02>] alloc_skb+0x32/0xd0
 [<c022cd5a>] netif_receive_skb+0x13a/0x1a0
 [<c01f50ae>] e1000_clean_rx_irq+0x16e/0x4c0
 [<c010ff37>] try_to_wake_up+0x237/0x260
 [<c01f4e6e>] e1000_clean_tx_irq+0x14e/0x220
 [<c01f4c72>] e1000_clean+0x42/0xf0
 [<c022cf5f>] net_rx_action+0x7f/0x110
 [<c0119a16>] __do_softirq+0xb6/0xd0
 [<c01047aa>] do_softirq+0x4a/0x60
 =======================
 [<c010469d>] do_IRQ+0x4d/0x70
 [<c0102d92>] common_interrupt+0x1a/0x20
 [<c01004e3>] default_idle+0x23/0x30
 [<c010058f>] cpu_idle+0x5f/0x70
Code: 31 ca 48 21 c2 8b 0c 96 85 c9 74 2b 8d 74 26 00 8d bc 27 00 00 00 00 8b 11 0f 18 02 90 8d 41 f8 39 58 24 0f 84 b8 00 00 00 85 d2 <89> d1 75 e8 90 8d b4 26 00 00 00 00 85 ff 74 47 c7 04 24 00 00 
console shuts up ...
