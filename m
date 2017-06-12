From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: WARNING in dev_watchdog
Date: Mon, 12 Jun 2017 08:42:32 +0200
Message-ID: <20170612064232.GA14559@kroah.com>
References: <CAJsXRPGWqm-DN2+VsEjCAOZV-C2GqkzmjPjJgRoGTUABJSFnow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        security@kernel.org
To: Dison River <pwn2river@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJsXRPGWqm-DN2+VsEjCAOZV-C2GqkzmjPjJgRoGTUABJSFnow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2017 at 02:37:22PM +0800, Dison River wrote:
> Hi:
>     I've got the following error report while fuzzing the kernel with
> syzkaller on linux-4.11.0-rc3.
> 
> log:
> WARNING: CPU: 2 PID: 0 at net/sched/sch_generic.c:316
> dev_watchdog+0x648/0x770 net/sched/sch_generic.c:315
> NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
> Kernel panic - not syncing: panic_on_warn set ...
> 
> CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc3 #2
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS
> Ubuntu-1.8.2-1ubuntu1 04/01/2014
> Call Trace:
>  <IRQ>
>  __dump_stack lib/dump_stack.c:16 [inline]
>  dump_stack+0x95/0xe8 lib/dump_stack.c:52
>  panic+0x1ae/0x386 kernel/panic.c:180
>  __warn+0x1c4/0x1e0 kernel/panic.c:541
>  warn_slowpath_fmt+0xac/0xd0 kernel/panic.c:564
>  dev_watchdog+0x648/0x770 net/sched/sch_generic.c:315
>  call_timer_fn+0x15b/0x5e0 kernel/time/timer.c:1268
>  expire_timers kernel/time/timer.c:1307 [inline]
>  __run_timers kernel/time/timer.c:1601 [inline]
>  run_timer_softirq+0x5c7/0x1140 kernel/time/timer.c:1614
>  __do_softirq+0x217/0x8b7 kernel/softirq.c:284
>  invoke_softirq kernel/softirq.c:364 [inline]
>  irq_exit+0x198/0x1d0 kernel/softirq.c:405
>  exiting_irq arch/x86/include/asm/apic.h:657 [inline]
>  smp_apic_timer_interrupt+0x76/0xa0 arch/x86/kernel/apic/apic.c:962
>  apic_timer_interrupt+0x90/0xa0 arch/x86/entry/entry_64.S:707
> RIP: 0010:native_safe_halt arch/x86/include/asm/irqflags.h:53 [inline]
> RIP: 0010:arch_safe_halt arch/x86/include/asm/irqflags.h:95 [inline]
> RIP: 0010:default_idle+0x1f/0x2d0 arch/x86/kernel/process.c:275
> RSP: 0018:ffff88006dee7e78 EFLAGS: 00000246 ORIG_RAX: ffffffffffffff10
> RAX: 0000000000000007 RBX: ffff88006de9db40 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88006de9e314
> RBP: ffff88006dee7e98 R08: 0000000000000040 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff83efc9b8
> R13: ffff88006de9db40 R14: 0000000000000002 R15: ffff88006de9db40
>  </IRQ>
>  arch_cpu_idle+0xa/0x10 arch/x86/kernel/process.c:266
>  default_idle_call+0x36/0x50 kernel/sched/idle.c:97
>  cpuidle_idle_call kernel/sched/idle.c:155 [inline]
>  do_idle+0x20b/0x2d0 kernel/sched/idle.c:244
>  cpu_startup_entry+0x18/0x20 kernel/sched/idle.c:346
>  start_secondary+0x245/0x2d0 arch/x86/kernel/smpboot.c:275
>  start_cpu+0x14/0x14 arch/x86/kernel/head_64.S:306
> Dumping ftrace buffer:
>    (ftrace buffer empty)
> Kernel Offset: disabled
> Rebooting in 86400 seconds..
> 
> 
> report :
> 
> 
> syzkaller login: [   37.041894] ------------[ cut here ]------------
> [   37.042430] WARNING: CPU: 2 PID: 0 at net/sched/sch_generic.c:316
> dev_watchdog+0x648/0x770
> [   37.042978] NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
> [   37.043405] Kernel panic - not syncing: panic_on_warn set ...
> [   37.043405]
> [   37.043888] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.11.0-rc3 #2
> [   37.044297] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> [   37.044909] Call Trace:
> [   37.045080]  <IRQ>
> [   37.045226]  dump_stack+0x95/0xe8
> [   37.045453]  ? dev_watchdog+0x648/0x770
> [   37.045712]  panic+0x1ae/0x386
> [   37.045924]  ? percpu_up_read_preempt_enable.constprop.53+0xae/0xae
> [   37.046342]  ? dev_watchdog+0x648/0x770
> [   37.046605]  ? vprintk_default+0x28/0x30
> [   37.046873]  ? dev_watchdog+0x648/0x770
> [   37.047114]  __warn+0x1c4/0x1e0
> [   37.047820]  warn_slowpath_fmt+0xac/0xd0
> [   37.048467]  ? __warn+0x1e0/0x1e0
> [   37.048698]  ? dev_watchdog+0x125/0x770
> [   37.048963]  dev_watchdog+0x648/0x770
> [   37.049218]  call_timer_fn+0x15b/0x5e0
> [   37.049475]  ? call_timer_fn+0xcc/0x5e0
> [   37.049739]  ? qdisc_rcu_free+0x110/0x110
> [   37.050014]  ? process_timeout+0x20/0x20
> [   37.050285]  ? trace_hardirqs_on_caller+0x19e/0x580
> [   37.053699]  ? qdisc_rcu_free+0x110/0x110
> [   37.054931]  ? qdisc_rcu_free+0x110/0x110
> [   37.055296]  run_timer_softirq+0x5c7/0x1140
> [   37.055949]  ? msleep_interruptible+0x170/0x170
> [   37.056671]  ? lapic_timer_shutdown+0x3d/0x50
> [   37.057268]  ? clockevents_switch_state+0xe3/0x320
> [   37.057837]  __do_softirq+0x217/0x8b7
> [   37.058097]  irq_exit+0x198/0x1d0
> [   37.058326]  smp_apic_timer_interrupt+0x76/0xa0
> [   37.058634]  apic_timer_interrupt+0x90/0xa0
> [   37.058921] RIP: 0010:default_idle+0x1f/0x2d0
> [   37.059217] RSP: 0018:ffff88006dee7e78 EFLAGS: 00000246 ORIG_RAX:
> ffffffffffffff10
> [   37.059702] RAX: 0000000000000007 RBX: ffff88006de9db40 RCX: 0000000000000000
> [   37.060179] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88006de9e314
> [   37.065968] RBP: ffff88006dee7e98 R08: 0000000000000040 R09: 0000000000000000
> [   37.066451] R10: 0000000000000000 R11: 0000000000000000 R12: ffffffff83efc9b8
> [   37.073921] R13: ffff88006de9db40 R14: 0000000000000002 R15: ffff88006de9db40
> [   37.074405]  </IRQ>
> [   37.074767]  ? default_idle+0x1d/0x2d0
> [   37.075026]  arch_cpu_idle+0xa/0x10
> [   37.075266]  default_idle_call+0x36/0x50
> [   37.075534]  do_idle+0x20b/0x2d0
> [   37.075815]  cpu_startup_entry+0x18/0x20
> [   37.076084]  start_secondary+0x245/0x2d0
> [   37.076352]  start_cpu+0x14/0x14
> [   37.077025] Dumping ftrace buffer:
> [   37.077308]    (ftrace buffer empty)
> [   37.077555] Kernel Offset: disabled
> [   37.078786] Rebooting in 86400 seconds..

Any hints as to exactly what you were doing at the time, and a
reproducer so we could try to test this?

thanks,

greg k-h
