From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: oops in raw_rcv_skb
Date: Fri, 1 Aug 2003 12:14:41 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0308011213350.18584@montezuma.mastecende.com>
References: <Mutt.LNX.4.44.0308020150400.29556-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
In-Reply-To: <Mutt.LNX.4.44.0308020150400.29556-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2 Aug 2003, James Morris wrote:

> On Fri, 1 Aug 2003, Zwane Mwaikambo wrote:
> 
> > You can reproduce this one easily by doing 5-6 ping -f of a system on the 
> > network (not loopback), originally picked up at http://bugme.osdl.org/show_bug.cgi?id=937
> 
> Any chance of getting a gdb traceback on this one? :-)

Here is a new oops with the corresponding code. 2.6.0-test2-mm2

(gdb) list *raw_rcv_skb+0x1b5
0xc04e2235 is in raw_rcv_skb (sock.h:942).
937
938             skb->dev = NULL;
939             skb_set_owner_r(skb, sk);
940             skb_queue_tail(&sk->sk_receive_queue, skb);
941             if (!sock_flag(sk, SOCK_DEAD))
942                     sk->sk_data_ready(sk, skb->len);
943     out:
944             return err;
945     }

Unable to handle kernel paging request at virtual address c3148068
 printing eip:
c04e2235
*pde = 0000d067
Oops: 0000 [#1]
PREEMPT SMP DEBUG_PAGEALLOC
CPU:    0
EIP:    0060:[<c04e2235>]    Not tainted VLI
EFLAGS: 00010246
EIP is at raw_rcv_skb+0x1b5/0x270
eax: 00000000   ebx: 00000104   ecx: 00000104   edx: 00000001
esi: c7fae004   edi: 00000000   ebp: c3148004   esp: cbf4fecc
ds: 007b   es: 007b   ss: 0068
Process ksoftirqd/0 (pid: 3, threadinfo=cbf4e000 task=cbf81000)
Stack: c7fae06c cbf4e000 00000206 00000000 c3148000 0000005a c3148004 c96e7024 
       c7fae004 cab51004 c04e237c c7fae004 c3148004 00000020 c7fae004 c96e7024 
       c04e1ead c7fae004 c3148004 00000001 ca214004 cab51004 0a00a8c0 c04bd389 
Call Trace:
 [<c04e237c>] raw_rcv+0x8c/0xe0
 [<c04e1ead>] raw_v4_input+0xbd/0x150
 [<c04bd389>] ip_local_deliver+0xc9/0x270
 [<c04bd8ac>] ip_rcv+0x37c/0x4e0
 [<c04a82e3>] netif_receive_skb+0x153/0x1d0
 [<c04a83e7>] process_backlog+0x87/0x160
 [<c04a8544>] net_rx_action+0x84/0x160
 [<c0129173>] do_softirq+0xd3/0xe0
 [<c01296bc>] ksoftirqd+0xbc/0x100
 [<c0129600>] ksoftirqd+0x0/0x100
 [<c0107125>] kernel_thread_helper+0x5/0x10

Code: 43 86 56 68 ff 74 24 08 9d 8b 54 24 04 8b 5a 14 4b 89 5a 14 8b 42 08 
83 e0 08 
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing

-- 
function.linuxpower.ca
