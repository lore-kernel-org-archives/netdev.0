From: Stephen Hemminger <shemminger@osdl.org>
Subject: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 13:28:04 -0800
Message-ID: <20050304132804.270cf05b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I was intentionally over stressing r8169 without NAPI to test out
an alternative version of netif_rx, and discovered the following bug.
Looks like a problem in r8169. I was using pktgen to overwhelm the r8169
from a fast machine.

eth0: Too much work at interrupt!
eth0: Too much work at interrupt!
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:91!
invalid operand: 0000 [#1]
PREEMPT
Modules linked in: i810 md5 ipv6 autofs4 sunrpc reiserfs video button battery adCPU:    0
EIP:    0060:[<c0258c78>]    Not tainted VLI
EFLAGS: 00010296   (2.6.11-netrx)
EIP is at skb_over_panic+0x38/0x50
eax: 0000002e   ebx: d7144000   ecx: 00000000   edx: c036cf40
esi: c02cee94   edi: 00000000   ebp: c036cf58   esp: c036cf3c
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c036c000 task=c02f8b20)
Stack: c02e38f8 d8856a10 00001fec 00001fec d7144000 d39fe6a0 00000036 c036cf94
       d8856a15 00000002 c1378b20 d8856a30 00001fec d395b360 00000100 00109f36
       d7144220 d7144000 d39fe6a0 00000001 d881cc00 d7144000 c036cfbc d8856b4d
Call Trace:
 [<c010344a>] show_stack+0x7a/0x90
 [<c01035c9>] show_registers+0x149/0x1c0
 [<c01037cd>] die+0xdd/0x170
 [<c0103b65>] do_invalid_op+0xa5/0xb0
 [<c01030d7>] error_code+0x2b/0x30
 [<d8856a15>] rtl8169_rx_interrupt+0x365/0x380 [r8169]
 [<d8856b4d>] rtl8169_interrupt+0xed/0x140 [r8169]
 [<c0137cc5>] handle_IRQ_event+0x35/0x70
 [<c0137dbe>] __do_IRQ+0xbe/0x150
 [<c01048a1>] do_IRQ+0x41/0x70
 =======================
 [<c010309e>] common_interrupt+0x1a/0x20
 [<c02716bd>] ip_route_input_slow+0x6d/0x9f0
 [<c0274660>] ip_rcv+0x380/0x480
 [<c025eda5>] netif_receive_skb+0x1e5/0x220
 [<c025ee5e>] process_backlog+0x7e/0x100
 [<c025ef45>] net_rx_action+0x65/0xf0
 [<c011fbb2>] __do_softirq+0x42/0xa0
 [<c01049b4>] do_softirq+0x44/0x60
 =======================
 [<c011fcd8>] irq_exit+0x38/0x40
 [<c01048a8>] do_IRQ+0x48/0x70
 [<c010309e>] common_interrupt+0x1a/0x20
 [<c0102e7e>] need_resched+0x1f/0x21
Code: c0 89 5d f8 8b 58 18 89 54 24 0c 85 db 0f 44 de 89 5c 24 10 8b 40 60 89 4
 <0>Kernel panic - not syncing: Fatal exception in interrupt
