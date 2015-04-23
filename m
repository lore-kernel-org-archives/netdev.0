From: Sudeep Holla <sudeep.holla@arm.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Thu, 23 Apr 2015 18:35:08 +0100
Message-ID: <CAPKp9uZCCAg_TYr4LVuAyCwU+Fmkn4-iHwYR5umQMm5KV0-gKA@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	dac.override@gmail.com
To: Josh Boyer <jwboyer@fedoraproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2015 at 6:07 PM, Josh Boyer <jwboyer@fedoraproject.org> wrote:
> Hi All,
>
> We've had a user report the following backtrace from the bridge module
> with a recent Linus' tree.  Has anything like this been reported yet?
> If you have any questions on setup, the user is CC'd.
>

I too observed similar backtrace once(not able to reproduce it again)
while I was trying to check inconsistent lock state[1] with lockdep enabled.

Regards,
Sudeep

[1] https://lkml.org/lkml/2015/4/23/329


--->8

===============================
[ INFO: suspicious RCU usage. ]
4.0.0 #269 Not tainted
-------------------------------
include/trace/events/ipi.h:68 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


RCU used illegally from idle CPU!
rcu_scheduler_active = 1, debug_locks = 1
RCU used illegally from extended quiescent state!
no locks held by swapper/0/0.

stack backtrace:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.0 #269
Hardware name: ARM-Versatile Express
[<c00151f1>] (unwind_backtrace) from [<c0011971>] (show_stack+0x11/0x14)
[<c0011971>] (show_stack) from [<c05627c7>] (dump_stack+0x73/0x8c)
[<c05627c7>] (dump_stack) from [<c0013e63>] (handle_IPI+0x257/0x410)
[<c0013e63>] (handle_IPI) from [<c000932b>] (gic_handle_irq+0x4f/0x50)
[<c000932b>] (gic_handle_irq) from [<c00121ff>] (__irq_svc+0x3f/0x64)
Exception stack(0xc083bf30 to 0xc083bf78)
bf20:                                     00000001 00000001 00000000 c0841938
bf40: c083a000 c083d5fc c08ba5c8 c083d598 00000000 00000000 c08b938f c056afc8
bf60: 00000008 c083bf78 c005d157 c000f288 40000133 ffffffff
[<c00121ff>] (__irq_svc) from [<c000f288>] (arch_cpu_idle+0x30/0x34)
[<c000f288>] (arch_cpu_idle) from [<c00555d5>] (cpu_startup_entry+0x339/0x404)
[<c00555d5>] (cpu_startup_entry) from [<c07d1a4f>] (start_kernel+0x32f/0x338)
[<c07d1a4f>] (start_kernel) from [<8000807f>] (0x8000807f)

===============================
[ INFO: suspicious RCU usage. ]
4.0.0 #269 Not tainted
-------------------------------
include/trace/events/ipi.h:84 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


RCU used illegally from idle CPU!
rcu_scheduler_active = 1, debug_locks = 1
RCU used illegally from extended quiescent state!
no locks held by swapper/0/0.

stack backtrace:
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.0.0 #269
Hardware name: ARM-Versatile Express
[<c00151f1>] (unwind_backtrace) from [<c0011971>] (show_stack+0x11/0x14)
[<c0011971>] (show_stack) from [<c05627c7>] (dump_stack+0x73/0x8c)
[<c05627c7>] (dump_stack) from [<c0013f85>] (handle_IPI+0x379/0x410)
[<c0013f85>] (handle_IPI) from [<c000932b>] (gic_handle_irq+0x4f/0x50)
[<c000932b>] (gic_handle_irq) from [<c00121ff>] (__irq_svc+0x3f/0x64)
Exception stack(0xc083bf30 to 0xc083bf78)
bf20:                                     00000001 00000001 00000000 c0841938
bf40: c083a000 c083d5fc c08ba5c8 c083d598 00000000 00000000 c08b938f c056afc8
bf60: 00000008 c083bf78 c005d157 c000f288 40000133 ffffffff
[<c00121ff>] (__irq_svc) from [<c000f288>] (arch_cpu_idle+0x30/0x34)
[<c000f288>] (arch_cpu_idle) from [<c00555d5>] (cpu_startup_entry+0x339/0x404)
[<c00555d5>] (cpu_startup_entry) from [<c07d1a4f>] (start_kernel+0x32f/0x338)
[<c07d1a4f>] (start_kernel) from [<8000807f>] (0x8000807f)
