From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: oops in udp_queue_rcv_skb
Date: Thu, 31 Jul 2003 22:19:31 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0307312110340.3779@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I got this whilst doing transfers from a SAMBA server, kernel is 
2.6.0-test2-mm2 on a 3way. Is there any specific information you require?

Unable to handle kernel paging request at virtual address c4734068
 printing eip:
c04e58b6
*pde = 00012067
Oops: 0000 [#1]
PREEMPT SMP DEBUG_PAGEALLOC
CPU:    0
EIP:    0060:[<c04e58b6>]    Not tainted VLI
EFLAGS: 00010246
EIP is at udp_queue_rcv_skb+0x276/0x3e0
eax: 00000000   ebx: c8977060   ecx: 00000104   edx: 00000001
esi: c4734004   edi: c8977004   ebp: 00000000   esp: c06dde78
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c06dc000 task=c0623a20)
Stack: c897706c c06dc000 00000202 00000000 0300a8c0 cad60084 c4734004 c8977004 
       cad60084 c97ef038 c04e5fe2 c8977004 c4734004 c06dc000 2003c000 0300a8c0 
       ca789004 0300a8c0 0a00a8c0 c0687d18 00000000 c4734004 0a00a8c0 c04bcfc2 
Call Trace:
 [<c04e5fe2>] udp_rcv+0x222/0x3e0
 [<c04bcfc2>] ip_local_deliver+0x102/0x270
 [<c04bd4ac>] ip_rcv+0x37c/0x4e0
 [<c04a7ee3>] netif_receive_skb+0x153/0x1d0
 [<c04a7fe7>] process_backlog+0x87/0x160
 [<c04a8144>] net_rx_action+0x84/0x160
 [<c0129173>] do_softirq+0xd3/0xe0
 [<c010c2a5>] do_IRQ+0x1b5/0x250
 [<c0106f30>] default_idle+0x0/0x40
 [<c010a558>] common_interrupt+0x18/0x20
 [<c0106f30>] default_idle+0x0/0x40
 [<c0106f5e>] default_idle+0x2e/0x40
 [<c0106fea>] cpu_idle+0x3a/0x50
 [<c0105000>] rest_init+0x0/0x90
 [<c06de7d1>] start_kernel+0x171/0x190

Code: 43 86 57 68 ff 74 24 08 9d 8b 54 24 04 8b 42 14 48 89 42 14 8b 42 08 83 e0 08 
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing

(gdb) list *udp_queue_rcv_skb+0x276
0xc04e5cb6 is in udp_queue_rcv_skb (sock.h:942).
937
938             skb->dev = NULL;
939             skb_set_owner_r(skb, sk);
940             skb_queue_tail(&sk->sk_receive_queue, skb);
941             if (!sock_flag(sk, SOCK_DEAD))
942                     sk->sk_data_ready(sk, skb->len);
943     out:
944             return err;
945     }
946

-- 
function.linuxpower.ca
