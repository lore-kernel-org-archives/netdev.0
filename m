From: James Morris <jmorris@redhat.com>
Subject: Re: TCP crashes when cycling loopback interface.
Date: Thu, 7 Oct 2004 12:46:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0410071234460.4571-100000@thoron.boston.redhat.com>
References: <E1CFVXD-0007iJ-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1CFVXD-0007iJ-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 7 Oct 2004, Herbert Xu wrote:

> James Morris <jmorris@redhat.com> wrote:
> > On an FC2 system, kernel 2.6.9-rc3-mm2 (selinux=0), running this causes a 
> > often repeatable oopses:
> 
> Please apply the foolowing patch and see if it produces a meaningful
> back trace.

Two runs with the following crashes:

KERNEL: assertion (!skb_queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_timer.c (322)
Unable to handle kernel NULL pointer dereference at virtual address 00000048
 printing eip:
c03077e9
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP 
Modules linked in: ipv6 e1000 3c59x mii ac
CPU:    0
EIP:    0060:[<c03077e9>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9-rc3-mm2) 
EIP is at tcp_retransmit_skb+0x50/0x3bb
eax: 00000000   ebx: 00000000   ecx: f6317654   edx: 00000000
esi: f5ecf258   edi: f5ecf024   ebp: c0468f64   esp: c0468f3c
ds: 007b   es: 007b   ss: 0068
Process basename (pid: 20822, threadinfo=c0468000 task=f617d170)
Stack: c0468f54 c011f2be f5ecf0a8 00000000 f5ecf258 000005a8 f5ecf258 f5ecf024 
       f5ecf258 f5ecf0a8 c0468fa0 c0309b7f c038e540 c038f8a8 c038c773 00000142 
       00000000 c1812960 c03a8f80 c1812960 c0468fa0 c012ec85 f5ecf024 f5ecf258 
Call Trace:
 [<c0106b0f>] show_stack+0x7a/0x90
 [<c0106c94>] show_registers+0x156/0x1ce
 [<c0106e96>] die+0xfb/0x181
 [<c011496e>] do_page_fault+0x304/0x5f3
 [<c0106739>] error_code+0x2d/0x38
 [<c0309b7f>] tcp_retransmit_timer+0xf1/0x442
 [<c0309f85>] tcp_write_timer+0xb5/0xd1
 [<c0127767>] run_timer_softirq+0xba/0x17a
 [<c0123c93>] __do_softirq+0x63/0xcf
 [<c010810d>] do_softirq+0x59/0x5d
 [<c013999d>] irq_exit+0x42/0x44
 [<c01116c9>] smp_apic_timer_interrupt+0xc4/0xc9
 [<c010669e>] apic_timer_interrupt+0x1a/0x20

EIP appears to be at:

static inline int before(__u32 seq1, __u32 seq2)
{
        return (__s32)(seq1-seq2) < 0;
}

Unable to handle kernel NULL pointer dereference at virtual address 00000050
 printing eip:
c02ff74d
*pde = 00000000
Oops: 0000 [#1]
PREEMPT SMP
Modules linked in: ipv6 e1000 3c59x mii ac
CPU:    0
EIP:    0060:[<c02ff74d>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9-rc3-mm2)
EIP is at tcp_time_to_recover+0x173/0x1af
eax: fffdb26b   ebx: f7925c50   ecx: 00000001   edx: 00000000
esi: 00000003   edi: f7925a1c   ebp: c0468ddc   esp: c0468dc8
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0468000 task=c03a4bc0)
Stack: f7925c50 00000001 f7925c50 00000000 1112733a c0468e20 c030031c c014214a
       dff494b0 c1938c80 00010800 1112733a 07925aa0 00000004 00000000 0000010e
       00000003 111270e8 f7925a1c 00000002 f7925c50 1112733a c0468e60 c03019b2
Call Trace:
 [<c0106b0f>] show_stack+0x7a/0x90
 [<c0106c94>] show_registers+0x156/0x1ce
 [<c0106e96>] die+0xfb/0x181
 [<c011496e>] do_page_fault+0x304/0x5f3
 [<c0106739>] error_code+0x2d/0x38
 [<c030031c>] tcp_fastretrans_alert+0x147/0x720
 [<c03019b2>] tcp_ack+0x25a/0x5ea
 [<c030462f>] tcp_rcv_established+0x5d7/0x875
 [<c030d825>] tcp_v4_do_rcv+0x101/0x103
 [<c030e043>] tcp_v4_rcv+0x81c/0x930
 [<c02f1ce5>] ip_local_deliver+0x9e/0x26c
 [<c02f23e3>] ip_rcv+0x343/0x506
 [<c02de1f1>] netif_receive_skb+0x1f9/0x226
 [<c02de29e>] process_backlog+0x80/0x130
 [<c02de3cf>] net_rx_action+0x81/0x12e
 [<c0123c93>] __do_softirq+0x63/0xcf
 [<c010810d>] do_softirq+0x59/0x5d
 [<c013999d>] irq_exit+0x42/0x44
 [<c0107fe4>] do_IRQ+0x64/0x9b
 [<c010661c>] common_interrupt+0x18/0x20
 [<c0103e3e>] cpu_idle+0x3b/0x5f
 [<c043787a>] start_kernel+0x184/0x1c2
 [<c0100211>] 0xc0100211

0xc02ff74d is in tcp_time_to_recover (net/ipv4/tcp_input.c:1355).
1350                    tcp_get_pcount(&tp->fackets_out);
1351    }
1352
1353    static inline int tcp_skb_timedout(struct tcp_opt *tp, struct sk_buff *skb)
1354    {
1355            return (tcp_time_stamp - TCP_SKB_CB(skb)->when > tp->rto);
1356    }
1357
1358    static inline int tcp_head_timedout(struct sock *sk, struct tcp_opt *tp)
1359    {


This should be easy to reproduce:

$ set -x
$ while (true) ; do ifdown lo ; ifup lo; done

Then start using the network via ssh or whatever.

I also noticed some more "retrans_out leaked" messages followed by a 
stalled ssh connection.


- James
-- 
James Morris
<jmorris@redhat.com>
