From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 4.12.0: igb: transmit queue 7 timed out
Date: Fri, 21 Jul 2017 17:47:55 -0700
Message-ID: <CAM_iQpX3ujcp0dArkLY=ogiFJACyhOyAk+-UE8XSmZg-LNp8Rg@mail.gmail.com>
References: <000001d30008$6edd4690$4c97d3b0$@lucidpixels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <000001d30008$6edd4690$4c97d3b0$@lucidpixels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Cc netdev and Intel)

On Tue, Jul 18, 2017 at 1:57 PM, Justin Piszcz <jpiszcz@lucidpixels.com> wrote:
> Hello,
>
> Kernel: 4.12.0
> Arch: x86_64
>
> What causes this issue?


It is likely a igb driver issue.


>
> [199141.434449] NETDEV WATCHDOG: eth1 (igb): transmit queue 7 timed out
> [199141.434501] ------------[ cut here ]------------
> [199141.434515] WARNING: CPU: 10 PID: 0 at net/sched/sch_generic.c:316
> dev_watchdog+0x212/0x220
> [199141.434528] CPU: 10 PID: 0 Comm: swapper/10 Not tainted 4.12.0 #3
> [199141.434533] Hardware name: Supermicro X9SRL-F/X9SRL-F, BIOS 3.2
> 01/16/2015
> [199141.434539] task: ffff8810385b8180 task.stack: ffffc900000b4000
> [199141.434546] RIP: 0010:dev_watchdog+0x212/0x220
> [199141.434551] RSP: 0018:ffff88103f483e68 EFLAGS: 00010286
> [199141.434558] RAX: 0000000000000037 RBX: 0000000000000007 RCX:
> 000000000000083f
> [199141.434563] RDX: 0000000000000000 RSI: 00000000000000f6 RDI:
> 000000000000003f
> [199141.434569] RBP: ffff88103f483e88 R08: 000000000006a111 R09:
> 0000000000000487
> [199141.434574] R10: 0000000000000082 R11: ffffffff823f49ee R12:
> ffff8810348a8000
> [199141.434579] R13: 000000000000000a R14: 0000000000000008 R15:
> 0000000000000082
> [199141.434585] FS:  0000000000000000(0000) GS:ffff88103f480000(0000)
> knlGS:0000000000000000
> [199141.434590] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [199141.434596] CR2: 000029e25c35b000 CR3: 000000000220a000 CR4:
> 00000000001406e0
> [199141.434600] Call Trace:
> [199141.434607]  <IRQ>
> [199141.434615]  ? qdisc_rcu_free+0x40/0x40
> [199141.434625]  call_timer_fn.isra.4+0x19/0x90
> [199141.434633]  expire_timers+0x7f/0x90
> [199141.434641]  run_timer_softirq+0x84/0xe0
> [199141.434650]  ? ktime_get+0x3b/0x90
> [199141.434659]  ? clockevents_program_event+0x75/0xf0
> [199141.434666]  __do_softirq+0xdf/0x1f0
> [199141.434673]  irq_exit+0xab/0xb0
> [199141.434681]  smp_trace_apic_timer_interrupt+0x63/0x90
> [199141.434688]  smp_apic_timer_interrupt+0x9/0x10
> [199141.434696]  apic_timer_interrupt+0x86/0x90
> [199141.434705] RIP: 0010:cpuidle_enter_state+0x153/0x1e0
> [199141.434711] RSP: 0018:ffffc900000b7e68 EFLAGS: 00000286 ORIG_RAX:
> ffffffffffffff10
> [199141.434720] RAX: ffff88103f499000 RBX: ffffe8ffffc91fd0 RCX:
> 000000000000001f
> [199141.434725] RDX: 20c49ba5e353f7cf RSI: ffff88103f496818 RDI:
> 0000000000000000
> [199141.434730] RBP: ffffc900000b7e98 R08: 0000000000003f7b R09:
> 0000000000000018
> [199141.434735] R10: ffffc900000b7e48 R11: 00000000000038b6 R12:
> 0000b51e3a7582f1
> [199141.434740] R13: 0000000000000004 R14: ffffffff8225e2b8 R15:
> ffffffff8225e120
> [199141.434746]  </IRQ>
> [199141.434754]  ? cpuidle_enter_state+0x148/0x1e0
> [199141.434762]  cpuidle_enter+0x12/0x20
> [199141.434771]  call_cpuidle+0x1e/0x30
> [199141.434779]  do_idle+0xde/0x180
> [199141.434788]  cpu_startup_entry+0x6c/0x70
> [199141.434796]  start_secondary+0x13c/0x160
> [199141.434808]  secondary_startup_64+0x9f/0x9f
> [199141.434813] Code: 8c 24 a4 03 00 00 eb 8d 4c 89 e7 c6 05 ea 96 81 00 01
> e8 02 f0 fd ff 89 d9 4c 89 e6 48 c7 c7 f0 49 00 82 48 89 c2 e8 bd 08 6e ff
> <0f> ff eb c1 66 2e 0f 1f 84 00 00 00 00 00 48 8b 4e 48 55 44 8b
> [199141.434895] ---[ end trace 0bac15bcef84778a ]---
> [199141.435208] igb 0000:08:00.2 eth1: Reset adapter
> [199144.839995] igb 0000:08:00.2 eth1: igb: eth1 NIC Link is Up 1000 Mbps
> Full Duplex, Flow Control: RX/TX
>
> Justin.
>
