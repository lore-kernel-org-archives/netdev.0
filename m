From: Phil Oester <kernel@linuxace.com>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Fri, 22 Oct 2004 11:54:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022185435.GA30709@linuxace.com>
References: <20041019215054.GA17565@linuxace.com> <E1CK3Az-0004P2-00@gondolin.me.apana.org.au> <20041020164748.GA20905@linuxace.com> <20041020212651.GA8534@gondor.apana.org.au> <20041020225536.GA22179@linuxace.com> <20041021130339.GA19345@gondor.apana.org.au> <20041021165224.GA25399@linuxace.com> <20041021215743.GA23062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041021215743.GA23062@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 22, 2004 at 07:57:43AM +1000, Herbert Xu wrote:
> On Thu, Oct 21, 2004 at 09:52:24AM -0700, Phil Oester wrote:
> > 
> > KERNEL: assertion (!tcp_get_pcount(&tp->packets_out) || !skb_
> > 	queue_empty(&sk->sk_write_queue)) failed at net/ipv4/tcp_input.c (2496)
> 
> Perhaps the MTU is growing upwards? Does this patch help?
> 
> Dave, we need to use the skb's MSS in trim_head as otherwise the
> counters will be screwed up.

This patch gets it a bit further, but still panics (divide by 0?):


divide error: 0000 [#1]
SMP 
CPU:    0
EIP:    0060:[<c029e36c>]    Not tainted VLI
EFLAGS: 00010246   (2.6.9) 
EIP is at tcp_set_skb_tso_segs+0x2c/0x50
eax: 000000f3   ebx: d75f5b00   ecx: 00000000   edx: 00000000
esi: 00000001   edi: d6c22460   ebp: d6c22650   esp: c035decc
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c035c000 task=c030eac0)
Stack: d75f5b00 c029e858 d75f5b00 d75f5b00 d6c22460 fffffff5 c029f3dd c02971a6 
       00000002 000005b4 d6c22460 d6c22650 d6c224c4 c035df58 c02a148d 00000002 
       00004100 00000080 f7c52260 c0393bec c038bda0 f710f130 00000010 c035df4c 
Call Trace:
 [<c029e858>] tcp_trim_head+0x88/0xc0
 [<c029f3dd>] tcp_retransmit_skb+0x8d/0x320
 [<c02971a6>] tcp_enter_loss+0x76/0x240
 [<c02a148d>] tcp_retransmit_timer+0xfd/0x430
 [<c02a1889>] tcp_write_timer+0xc9/0x100
 [<c02a17c0>] tcp_write_timer+0x0/0x100
 [<c011ee49>] run_timer_softirq+0xd9/0x170
 [<c011b0f6>] __do_softirq+0xb6/0xd0
 [<c011b13d>] do_softirq+0x2d/0x30
 [<c010de35>] smp_apic_timer_interrupt+0x85/0xf0
 [<c010492e>] apic_timer_interrupt+0x1a/0x20
 [<c0101f40>] default_idle+0x0/0x40
 [<c0101f6c>] default_idle+0x2c/0x40
 [<c0101ffb>] cpu_idle+0x3b/0x50
 [<c035ea66>] start_kernel+0x156/0x180
 [<c035e530>] unknown_bootoption+0x0/0x180
