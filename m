From: Srihari Vijayaraghavan <harisri@bigpond.com>
Subject: Re: [update] 2.6.2-rc1 - Realtek 8169 patches
Date: Sat, 24 Jan 2004 15:22:18 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401241522.18369.harisri@bigpond.com>
References: <20040122234725.A8109@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040122234725.A8109@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Francois,

On Friday 23 January 2004 09:47, Francois Romieu wrote:
> An updated version of the r8169 patches against 2.6.2-rc1 is available.
>
> Individual files:
>   http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.2-rc1

I have applied your patches (all of them) and the kernel oops when I ping to 
that machine from a remote machine :-(.

r8169 Gigabit Ethernet driver 1.2 loaded
eth1: RTL8169 at 0xffffff000022e000, 00:0d:61:15:23:e6, IRQ 5
eth1: Auto-negotiation Enabled.
eth1: 100Mbps Full-duplex operation.
skput:over: ffffffffa00e32d8:3068 put:3068 dev:eth1----------- [cut here ] 
-----
Kernel BUG at skbuff:88
invalid operand: 0000 [1]
CPU 0
Pid: 0, comm: swapper Not tainted
RIP: 0010:[<ffffffff802284f2>] <ffffffff802284f2>{skb_over_panic+50}
RSP: 0018:ffffffff80370ff8  EFLAGS: 00010292
RAX: 0000000000000036 RBX: 0000f8650101f865 RCX: 0000000000000000
RDX: 00000000000003f9 RSI: 0000000000000000 RDI: ffffffff802c0260
RBP: 000001003e5c2320 R08: 0000000000000000 R09: 0000000000000003
R10: 00000000ffffffff R11: 0000000000000000 R12: ffffff000022e000
R13: 0000000000000bfc R14: 0000010000091010 R15: 0000000000000001
FS:  00000000005144a0(0000) GS:ffffffff8036d0c0(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 0000002a95d36fe8 CR3: 0000000000101000 CR4: 00000000000006a0
Process swapper (pid: 0, stackpage=ffffffff802b8be0)
Stack: 0000000000000292 ffffffffa00e32e0 0000000000000bfc 000001003e5c2000
       000001003f5d21c0 0000000000008001 0000000000000014 ffffff000022e000
       000001003e5c2320 000001003e5c2000
Call Trace:<IRQ> <ffffffffa00e32e0>{:r8169:rtl8169_rx_interrupt+416}
       <ffffffffa00e3435>{:r8169:rtl8169_interrupt+101} 
<ffffffff801121af>{hand
       <ffffffff80112333>{do_IRQ+147} <ffffffff8010dbe0>{default_idle+0}
       <ffffffff80110089>{ret_from_intr+0}  <EOI> 
<ffffffff8012f3e5>{thread_ret
       <ffffffff8010dc00>{default_idle+32} <ffffffff8010dc8a>{cpu_idle+26}
       <ffffffff803796b2>{start_kernel+322}

Code: 0f 0b c2 c9 29 80 ff ff ff ff 58 00 48 83 c4 08 c3 66 66 66
RIP <ffffffff802284f2>{skb_over_panic+50} RSP <ffffffff80370ff8>
 <0>Kernel panic: Aiee, killing interrupt handler!
In interrupt handler - not syncing
 
I will try to track down which one of your patch introduces the regression.

> The first patch of the series probably wants to go directly to 2.6.x/2.4.x.
>
> Please Cc: netdev@oss.sgi.com on success/failure.

Thanks
Hari
