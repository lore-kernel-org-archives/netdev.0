From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PROBLEM] r8169 deadlocks
Date: Thu, 15 Jan 2004 22:08:27 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115220827.A22007@electric-eye.fr.zoreil.com>
References: <200401152039.00182.harisri@bigpond.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Srihari Vijayaraghavan <harisri@bigpond.com>
Content-Disposition: inline
In-Reply-To: <200401152039.00182.harisri@bigpond.com>; from harisri@bigpond.com on Thu, Jan 15, 2004 at 08:38:59PM +1100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Srihari Vijayaraghavan <harisri@bigpond.com> :
[...]
> Consider desktop as the computer with the RealTek r8169 card and laptop from 
> where I perform these steps:
> 1. ssh desktop
> 2. while true; do ls -la /; done
> 3. In few seconds the desktop computer hangs
> (And of course at the laptop computer the ssh session hangs)
> 
> Here is the sysrq-p from the desktop computer (captured using serial-console):
> Pid: 1963, comm: ls Not tainted
> RIP: 0010:[<ffffffffa008afd9>] 
> <ffffffffa008afd9>{:r8169:rtl8169_tx_interrupt+73}
> RSP: 0000:ffffffff80374dc8  EFLAGS: 00000286
> RAX: 0000000000000420 RBX: ffffffff80374d18 RCX: 0000010000399000
> RDX: ffffffff80370e80 RSI: 000000003525d05e RDI: 0000000080391bf0
> RBP: ffffffff801100d9 R08: 0000000000000007 R09: 0000000000000000
> R10: 0000002a95587de0 R11: 0000000000000003 R12: 0000000000000042
> R13: 0000000000000001 R14: 00000000000000bc R15: 000001003f7d1340
> FS:  00000000005144a0(005b) GS:ffffffff80370e80(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> CR2: 0000002a957876d0 CR3: 0000000000101000 CR4: 00000000000006a0
> 
> Call Trace:<IRQ> <ffffffffa008b3c8>{:r8169:rtl8169_interrupt+120} 
> <ffffffff8011222f>{handle_IRQ_event+47}
>        <ffffffff801123b3>{do_IRQ+147} <ffffffff801100d9>{ret_from_intr+0}
>         <EOI> <ffffffff80110152>{retint_careful+13}

*head scratch*

Can you monitor 'vmstat 1' output on the r8169 host during the test ?

You can try 2.6.1-bk2 + Jeff Garzik's -netdev4 + 
http://www.fr.zoreil.com/people/francois/misc/r8169-tx-index-overflow.patch 

If it does not perform better, you can try against 2.6.1-bk1 the set at
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1-bk1-b

If I remember correctly, you are the first report of a non-completely
disfunctional driver for the new version of the r8169. Things improve.

--
Ueimor
