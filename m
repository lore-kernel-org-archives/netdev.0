From: Ranko Zivojnovic <ranko@spidernet.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
	to -mm tree
Date: Fri, 06 Jul 2007 16:14:14 +0300
Message-ID: <1183727654.6389.3.camel@ranko-fc2.spidernet.net>
References: <200706271921.l5RJLgCC003910@imap1.linux-foundation.org>
	 <1183642800.3789.11.camel@ranko-fc2.spidernet.net>
	 <20070705142135.GG4759@ff.dom.local>
	 <1183646029.4069.11.camel@ranko-fc2.spidernet.net>
	 <1183651165.4069.26.camel@ranko-fc2.spidernet.net>
	 <20070706061420.GA1846@ff.dom.local> <20070706062629.GC1846@ff.dom.local>
	 <20070706064523.GA2144@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MPP-Goya.spidernet.net ([194.154.128.52]:44795 "EHLO
	mail0pop.spidernet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100AbXGFNOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 09:14:41 -0400
In-Reply-To: <20070706064523.GA2144@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-06 at 08:45 +0200, Jarek Poplawski wrote: 
> On Fri, Jul 06, 2007 at 09:08:43AM +0300, Ranko Zivojnovic wrote:
> > On Thu, 2007-07-05 at 18:59 +0300, Ranko Zivojnovic wrote:
> > > On Thu, 2007-07-05 at 17:34 +0300, Ranko Zivojnovic wrote:
> > > > Anyhow - I am currently running 2.6.22-rc6-mm1 + sch_htb patch and
> > > > running a test script that always managed to reproduce the problem
> > > > within half hour - so far it looks good, but I will leave it hammering
> > > > until tomorrow and will let you know.
> > > > 
> > > 
> > > Ahm...it managed to get stuck:
> > > 
> > > Relevant piece of the process table ('tc' stays stuck):
> > >  9608 pts/0    S+     0:00 /bin/bash ./tc-crash.sh
> > >  9609 pts/0    D+     0:00 tc qdisc del dev lo root
> > > 
> > 
> > Something really weird happened here...
> > 
> > I've left it the way it was (stuck) over night and this morning the
> > process was terminated.
> > 
> > It looks like some timer was out of whack.
> > 
> > I'm not sure if it is possibly relevant - but the test I performed was
> > done in VMWare.
> 
> Yes, this could be relevant, so it's good to know.
> 
> > 
> > In order to get that parameter out of the way - I will make the same
> > test on a real machine.
> 
> Fine! But, unles you have something to hide, try to reply
> on these messages which went through netdev, or cc netdev
> at least, because maybe more people would be interested
> or even could help to solve this faster.
> 

Nope - nothing to hide :).

Managed to get stuck on a normal machine as well (2.6.22-rc6-mm1 +
sch_htb patch) ... here's the log:

---CUT--- 
-- 0:loop-telnet.sh -- time-stamp -- Jul/06/07 14:46:17 --
u32 classifier
    Performance counters on
    OLD policer on
    input device check on
-- 0:loop-telnet.sh -- time-stamp -- Jul/06/07 14:48:13 --
-- 0:loop-telnet.sh -- time-stamp -- Jul/06/07 15:38:26 --
BUG: spinlock lockup on CPU#0, swapper/0, c03eff80
 [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
 [<c02a8468>] __qdisc_run+0x97/0x1b0
 [<c02a96f3>] qdisc_watchdog+0x19/0x58
 [<c02fe5e7>] __lock_text_start+0x37/0x43
 [<c02a9730>] qdisc_watchdog+0x56/0x58
 [<c02a96da>] qdisc_watchdog+0x0/0x58
 [<c0135d84>] run_hrtimer_softirq+0x58/0xb5
 [<c012626a>] __do_softirq+0x7e/0xf3
 [<c0126335>] do_softirq+0x56/0x58
 [<c0112574>] smp_apic_timer_interrupt+0x5a/0x85
 [<c0103eb1>] apic_timer_interrupt+0x29/0x38
 [<c0103ebb>] apic_timer_interrupt+0x33/0x38
 [<c010172f>] mwait_idle_with_hints+0x3b/0x3f
 [<c0101846>] cpu_idle+0x5f/0x74
 [<c0417d2a>] start_kernel+0x318/0x3ae
 [<c04174bf>] unknown_bootoption+0x0/0x258
 =======================
BUG: spinlock lockup on CPU#1, swapper/0, c03eff80
 [<c01ed1fe>] _raw_spin_lock+0x108/0x13c
 [<c0298b9b>] est_timer+0x53/0x148
 [<c01294b3>] run_timer_softirq+0x30/0x184
 [<c01295a4>] run_timer_softirq+0x121/0x184
 [<c0126252>] __do_softirq+0x66/0xf3
 [<c0298b48>] est_timer+0x0/0x148
 [<c012626a>] __do_softirq+0x7e/0xf3
 [<c0126335>] do_softirq+0x56/0x58
 [<c0112574>] smp_apic_timer_interrupt+0x5a/0x85
 [<c0103eb1>] apic_timer_interrupt+0x29/0x38
 [<c0103ebb>] apic_timer_interrupt+0x33/0x38
 [<c010172f>] mwait_idle_with_hints+0x3b/0x3f
 [<c0101846>] cpu_idle+0x5f/0x74
 =======================

telnet> send break
SysRq : HELP : loglevel0-8 reBoot show-all-locks(D) tErm Full kIll saK showMem Nice powerOff showPc show-all-timers(Q) unRaw Sync showTasks Unmount shoW-blocked-tasks

telnet> send break
SysRq : Show Regs

Pid: 0, comm:              swapper
EIP: 0060:[<c01ed199>] CPU: 1
EIP is at _raw_spin_lock+0xa3/0x13c
 EFLAGS: 00000246    Not tainted  (2.6.22-rc6-mm1.SNET.Thors.htbpatch.2.lockdebug #1)
EAX: 00000000 EBX: c03eff80 ECX: e4f7bf60 EDX: 98b928f8
ESI: 260e7970 EDI: 00000000 EBP: beb75188 DS: 007b ES: 007b FS: 00d8
CR0: 8005003b CR2: 080f7578 CR3: 03651000 CR4: 000006d0
DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
DR6: ffff0ff0 DR7: 00000400
 [<c0298b9b>] est_timer+0x53/0x148
 [<c01294b3>] run_timer_softirq+0x30/0x184
 [<c01295a4>] run_timer_softirq+0x121/0x184
 [<c0126252>] __do_softirq+0x66/0xf3
 [<c0298b48>] est_timer+0x0/0x148
 [<c012626a>] __do_softirq+0x7e/0xf3
 [<c0126335>] do_softirq+0x56/0x58
 [<c0112574>] smp_apic_timer_interrupt+0x5a/0x85
 [<c0103eb1>] apic_timer_interrupt+0x29/0x38
 [<c0103ebb>] apic_timer_interrupt+0x33/0x38
 [<c010172f>] mwait_idle_with_hints+0x3b/0x3f
 [<c0101846>] cpu_idle+0x5f/0x74
 =======================

telnet> send break
SysRq : Show Blocked State

                         free                        sibling
  task             PC    stack   pid father child younger older
kjournald     D 00000343     0   518      2 (L-TLB)
       c2361e8c 00000092 090e4f4b 00000343 c2361e74 00000000 c2baf920 c2360000
       00000002 c2baf920 c21343f0 c21345a8 c1d24080 00000002 c040ed80 c2361ec4
       c4289280 00000000 00000000 003252cc c02feb97 c2361ecc ffffffff 00000000
Call Trace:
 [<c02feb97>] _spin_unlock_irqrestore+0x34/0x39
 [<c02fc563>] io_schedule+0x1d/0x27
 [<c018b02c>] sync_buffer+0x30/0x35
 [<c02fcb5e>] __wait_on_bit+0x42/0x5e
 [<c018affc>] sync_buffer+0x0/0x35
 [<c018affc>] sync_buffer+0x0/0x35
 [<c02fcbdd>] out_of_line_wait_on_bit+0x63/0x76
 [<c0132bf2>] wake_bit_function+0x0/0x3c
 [<c018af91>] __wait_on_buffer+0x24/0x29
 [<c018bdb2>] sync_dirty_buffer+0x9c/0xe6
 [<f88fcefe>] journal_get_descriptor_buffer+0x88/0x9a [jbd]
 [<f88f922b>] journal_commit_transaction+0xf2a/0x111f [jbd]
 [<c02fea7a>] _spin_unlock_irq+0x20/0x23
 [<f88fc8bf>] kjournald+0xac/0x1f4 [jbd]
 [<c0132bbb>] autoremove_wake_function+0x0/0x37
 [<f88fc813>] kjournald+0x0/0x1f4 [jbd]
 [<c0132976>] kthread+0x34/0x56
 [<c0132942>] kthread+0x0/0x56
 [<c0104053>] kernel_thread_helper+0x7/0x14
 =======================
syslogd       D 00000341     0  2173      1 (NOTLB)
       c4315e84 00000082 b9c1b1c3 00000341 c4315e6c 00000000 00000000 c4314000
       00000002 00000002 c2ea25f0 c2ea27a8 c1d24080 00000002 c040ed80 c2ea25f0
       c3652b80 c2aab4c8 c2aab414 00323cc0 00000002 00000046 ffffffff 00000000
Call Trace:
 [<f88fbbfb>] log_wait_commit+0xaf/0x116 [jbd]
 [<c0132bbb>] autoremove_wake_function+0x0/0x37
 [<f88f66b1>] journal_stop+0x158/0x1fa [jbd]
 [<c0186711>] __writeback_single_inode+0x26f/0x331
 [<c01867e3>] sync_inode+0x10/0x2a
 [<c02fe7cf>] _spin_lock+0x29/0x34
 [<c01867ec>] sync_inode+0x19/0x2a
 [<f88b3533>] ext3_sync_file+0xbf/0xcc [ext3]
 [<c02fd2f1>] __mutex_lock_slowpath+0x14b/0x293
 [<c018948b>] do_fsync+0x57/0x90
 [<c01894e1>] __do_fsync+0x1d/0x2b
 [<c0103366>] sysenter_past_esp+0x5f/0x99
 =======================
crond         D 0000034B     0 10251   2740 (NOTLB)
       c5b6be18 00000086 44c73986 0000034b c5b6be00 00000000 c43048f0 c5b6a000
       00000002 c04ea564 c43048f0 c4304aa8 c1d24080 00000002 c040ed80 00000000
       c393e280 c02fea7a c5b6be2c 0032dd68 c013d19e c02fc418 ffffffff 00000000
Call Trace:
 [<c02fea7a>] _spin_unlock_irq+0x20/0x23
 [<c013d19e>] trace_hardirqs_on+0xab/0x147
 [<c02fc418>] wait_for_completion+0x24/0xb7
 [<c02fc492>] wait_for_completion+0x9e/0xb7
 [<c011bd50>] default_wake_function+0x0/0xc
 [<c012f537>] call_usermodehelper_exec+0xdb/0xe0
 [<c0167d3b>] cache_alloc_refill+0x163/0x557
 [<c012f69b>] request_module+0x9f/0xe2
 [<c02feb97>] _spin_unlock_irqrestore+0x34/0x39
 [<c013d19e>] trace_hardirqs_on+0xab/0x147
 [<c0118f2d>] __wake_up+0x32/0x43
 [<c02adfa2>] netlink_create+0xa6/0x1a2
 [<c029011b>] __sock_create+0xae/0x1db
 [<c029027d>] sock_create+0x18/0x1d
 [<c0290412>] sys_socket+0x1c/0x44
 [<c0290d06>] sys_socketcall+0x68/0x271
 [<c013d19e>] trace_hardirqs_on+0xab/0x147
 [<c0103438>] restore_nocheck+0x12/0x15
 [<c0103366>] sysenter_past_esp+0x5f/0x99
 =======================
Sched Debug Version: v0.03, cfs-v18, 2.6.22-rc6-mm1.SNET.Thors.htbpatch.2.lockdebug #1
now at 3640122056027 nsecs

cpu#0, 3200.442 MHz
  .nr_running                    : 2
  .load                          : 4149
  .ls.delta_fair                 : 0
  .ls.delta_exec                 : 0
  .nr_switches                   : 904853
  .nr_load_updates               : 3640019
  .nr_uninterruptible            : 425
  .jiffies                       : 3340159
  .next_balance                  : 2936193
  .curr->pid                     : 0
  .clock                         : 3628742932463
  .prev_clock_raw                : 3628948350088
  .clock_warps                   : 0
  .clock_overflows               : 57
  .clock_unstable_events         : 1
  .clock_max_delta               : 1999557
  .cfs.fair_clock                : 557156111815
  .cfs.exec_clock                : 213278676734
  .cfs.wait_runtime              : -93884907451
  .cfs.wait_runtime_overruns     : 1235
  .cfs.wait_runtime_underruns    : 2874
  .cpu_load[0]                   : 0
  .cpu_load[1]                   : 0
  .cpu_load[2]                   : 0
  .cpu_load[3]                   : 0
  .cpu_load[4]                   : 0
  .wait_runtime_rq_sum           : 47286887

runnable tasks:
            task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
------------------------------------------------------------------------------------------------------------------------------------------------------------------
         khelper    19    557082869628     -73242187      24000000       955   115        12293227     53703642836   3621787091747               1               0
           eping  3114    557163819749       7707934      23286887    333993   120     83353964767       253906993   2733416723635              41             217
WARNING: at kernel/lockdep.c:2031 trace_hardirqs_on()
 [<c02fea9d>] _read_unlock_irq+0x20/0x23
 [<c0119814>] sched_debug_show+0x8b2/0xe04
 [<c011e2ab>] show_state_filter+0x161/0x184
 [<c02354c3>] __handle_sysrq+0x7a/0x115
 [<c024059d>] receive_chars+0x23b/0x2a4
 [<c024174d>] serial8250_interrupt+0x114/0x132
 [<c0148733>] handle_IRQ_event+0x1e/0x48
 [<c014982f>] handle_edge_irq+0x9b/0x112
 [<c0105afc>] do_IRQ+0x45/0x99
 [<c0103dd0>] common_interrupt+0x24/0x34
 [<c0103dda>] common_interrupt+0x2e/0x34
 [<c010172f>] mwait_idle_with_hints+0x3b/0x3f
 [<c0101846>] cpu_idle+0x5f/0x74
 =======================

cpu#1, 3200.442 MHz
  .nr_running                    : 1
  .load                          : 1024
  .ls.delta_fair                 : 0
  .ls.delta_exec                 : 0
  .nr_switches                   : 1825911
  .nr_load_updates               : 3638353
  .nr_uninterruptible            : 4294967022
  .jiffies                       : 3340380
  .next_balance                  : 2937417
  .curr->pid                     : 0
  .clock                         : 3627052732372
  .prev_clock_raw                : 3629168676206
  .clock_warps                   : 0
  .clock_overflows               : 45
  .clock_unstable_events         : 0
  .clock_max_delta               : 1968238
  .cfs.fair_clock                : 1032651577814
  .cfs.exec_clock                : 242507384061
  .cfs.wait_runtime              : -91108953414
  .cfs.wait_runtime_overruns     : 2143
  .cfs.wait_runtime_underruns    : 1953
  .cpu_load[0]                   : 0
  .cpu_load[1]                   : 0
  .cpu_load[2]                   : 0
  .cpu_load[3]                   : 0
  .cpu_load[4]                   : 0
  .wait_runtime_rq_sum           : 23979985

runnable tasks:
            task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
------------------------------------------------------------------------------------------------------------------------------------------------------------------
 hald-addon-stor  2781   1032650759709       -818105      23979985     12308   120       491952575      2635261433   3092710060269              30               0

cpu#2, 3200.442 MHz
  .nr_running                    : 0
  .load                          : 0
  .ls.delta_fair                 : 0
  .ls.delta_exec                 : 0
  .nr_switches                   : 1509999
  .nr_load_updates               : 3639454
  .nr_uninterruptible            : 789
  .jiffies                       : 3340529
  .next_balance                  : 3339823
  .curr->pid                     : 0
  .clock                         : 3628130245442
  .prev_clock_raw                : 3629317315215
  .clock_warps                   : 0
  .clock_overflows               : 73
  .clock_unstable_events         : 0
  .clock_max_delta               : 1965436
  .cfs.fair_clock                : 839764839660
  .cfs.exec_clock                : 208639226606
  .cfs.wait_runtime              : 17382220347
  .cfs.wait_runtime_overruns     : 2282
  .cfs.wait_runtime_underruns    : 11415
  .cpu_load[0]                   : 0
  .cpu_load[1]                   : 0
  .cpu_load[2]                   : 0
  .cpu_load[3]                   : 0
  .cpu_load[4]                   : 0
  .wait_runtime_rq_sum           : 0

runnable tasks:
            task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
------------------------------------------------------------------------------------------------------------------------------------------------------------------

cpu#3, 3200.442 MHz
  .nr_running                    : 1
  .load                          : 1024
  .ls.delta_fair                 : 0
  .ls.delta_exec                 : 0
  .nr_switches                   : 3120535
  .nr_load_updates               : 3640332
  .nr_uninterruptible            : 4294966359
  .jiffies                       : 3340663
  .next_balance                  : 2936318
  .curr->pid                     : 10250
  .clock                         : 3629093644120
  .prev_clock_raw                : 3629450829376
  .clock_warps                   : 0
  .clock_overflows               : 15
  .clock_unstable_events         : 0
  .clock_max_delta               : 1940676
  .cfs.fair_clock                : 2242476711934
  .cfs.exec_clock                : 782992850413
  .cfs.wait_runtime              : 621759666860
  .cfs.wait_runtime_overruns     : 4730
  .cfs.wait_runtime_underruns    : 46039
  .cpu_load[0]                   : 1019
  .cpu_load[1]                   : 1020
  .cpu_load[2]                   : 1018
  .cpu_load[3]                   : 1017
  .cpu_load[4]                   : 1009
  .wait_runtime_rq_sum           : -272987

runnable tasks:
            task   PID        tree-key         delta       waiting  switches  prio        sum-exec        sum-wait       sum-sleep    wait-overrun   wait-underrun
------------------------------------------------------------------------------------------------------------------------------------------------------------------
R             tc 10250   2242552751078        273022       -273022         1   120    403322303899         -273022             653               0               0


telnet> send break
SysRq : Show Pending Timers
Timer List Version: v0.3
HRTIMER_MAX_CLOCK_BASES: 2
now at 3730198060133 nsecs

cpu: 0
 clock 0:
  .index:      0
  .resolution: 1 nsecs
  .get_time:   ktime_get_real
  .offset:     1183721968505121290 nsecs
active timers:
 clock 1:
  .index:      1
  .resolution: 1 nsecs
  .get_time:   ktime_get
  .offset:     0 nsecs
active timers:
 #0: <3>BUG: sleeping function called from invalid context at kernel/mutex.c:86
in_atomic():1, irqs_disabled():1
INFO: lockdep is turned off.
irq event stamp: 38482572
hardirqs last  enabled at (38482572): [<c0103438>] restore_nocheck+0x12/0x15
hardirqs last disabled at (38482571): [<c0103eb1>] apic_timer_interrupt+0x29/0x38
softirqs last  enabled at (37677028): [<c0126335>] do_softirq+0x56/0x58
softirqs last disabled at (37677033): [<c0126335>] do_softirq+0x56/0x58
 [<c02fd44b>] mutex_lock+0x12/0x1a
 [<c0145e69>] lookup_module_symbol_name+0x14/0xbb
 [<c0138810>] print_name_offset+0x1a/0x8e
 [<c0121c3f>] release_console_sem+0x1d9/0x1f5
 [<c01391a1>] timer_list_show+0x660/0xa66
 [<c013a861>] tick_sched_timer+0x0/0x186
 [<c02354c3>] __handle_sysrq+0x7a/0x115
 [<c024059d>] receive_chars+0x23b/0x2a4
 [<c024174d>] serial8250_interrupt+0x114/0x132
 [<c0148733>] handle_IRQ_event+0x1e/0x48
 [<c014982f>] handle_edge_irq+0x9b/0x112
 [<c0105afc>] do_IRQ+0x45/0x99
 [<c0103dd0>] common_interrupt+0x24/0x34
 [<c0103dda>] common_interrupt+0x2e/0x34
 [<c01e007b>] vsnprintf+0x29a/0x5fe
 [<c01ed199>] _raw_spin_lock+0xa3/0x13c
 [<c0298b9b>] est_timer+0x53/0x148
 [<c01294b3>] run_timer_softirq+0x30/0x184
 [<c01295a4>] run_timer_softirq+0x121/0x184
 [<c0126252>] __do_softirq+0x66/0xf3
 [<c0298b48>] est_timer+0x0/0x148
 [<c012626a>] __do_softirq+0x7e/0xf3
 [<c0126335>] do_softirq+0x56/0x58
 [<c0112574>] smp_apic_timer_interrupt+0x5a/0x85
 [<c0103eb1>] apic_timer_interrupt+0x29/0x38
 [<c0103ebb>] apic_timer_interrupt+0x33/0x38
 [<c010172f>] mwait_idle_with_hints+0x3b/0x3f
 [<c0101846>] cpu_idle+0x5f/0x74
 =======================
<c2047d6c>, tick_sched_timer, S:01
 # expires at 3730231000000 nsecs [in 32939867 nsecs]
 #1: <c2047d6c>, it_real_fn, S:01
 # expires at 3734130154519 nsecs [in 3932094386 nsecs]
 #2: <c2047d6c>, it_real_fn, S:01
 # expires at 3734197190457 nsecs [in 3999130324 nsecs]
 #3: <c2047d6c>, it_real_fn, S:01
 # expires at 31835132462428 nsecs [in 28104934402295 nsecs]
  .expires_next   : 3730415000000 nsecs
  .hres_active    : 1
  .nr_events      : 3736552
  .nohz_mode      : 0
  .idle_tick      : 0 nsecs
  .tick_stopped   : 0
  .idle_jiffies   : 0
  .idle_calls     : 0
  .idle_sleeps    : 0
  .idle_entrytime : 0 nsecs
  .idle_sleeptime : 0 nsecs
  .last_jiffies   : 0
  .next_jiffies   : 0
  .idle_expires   : 0 nsecs
jiffies: 3430448

cpu: 1
 clock 0:
  .index:      0
  .resolution: 1 nsecs
  .get_time:   ktime_get_real
  .offset:     1183721968505121290 nsecs
active timers:
 clock 1:
  .index:      1
  .resolution: 1 nsecs
  .get_time:   ktime_get
  .offset:     0 nsecs
active timers:
 #0: <c2047d6c>, tick_sched_timer, S:01
 # expires at 3730196015625 nsecs [in 18446744073707507108 nsecs]
  .expires_next   : 3730196015625 nsecs
  .hres_active    : 1
  .nr_events      : 3733988
  .nohz_mode      : 0
  .idle_tick      : 0 nsecs
  .tick_stopped   : 0
  .idle_jiffies   : 0
  .idle_calls     : 0
  .idle_sleeps    : 0
  .idle_entrytime : 0 nsecs
  .idle_sleeptime : 0 nsecs
  .last_jiffies   : 0
  .next_jiffies   : 0
  .idle_expires   : 0 nsecs
jiffies: 3430518

cpu: 2
 clock 0:
  .index:      0
  .resolution: 1 nsecs
  .get_time:   ktime_get_real
  .offset:     1183721968505121290 nsecs
active timers:
 clock 1:
  .index:      1
  .resolution: 1 nsecs
  .get_time:   ktime_get
  .offset:     0 nsecs
active timers:
 #0: <c2047d6c>, tick_sched_timer, S:01
 # expires at 3730546031250 nsecs [in 347971117 nsecs]
 #1: <c2047d6c>, hrtimer_wakeup, S:01
 # expires at 3730649159723 nsecs [in 451099590 nsecs]
 #2: <c2047d6c>, hrtimer_wakeup, S:01
 # expires at 3734223051944 nsecs [in 4024991811 nsecs]
 #3: <c2047d6c>, hrtimer_wakeup, S:01
 # expires at 3753480126556 nsecs [in 23282066423 nsecs]
  .expires_next   : 3730581031250 nsecs
  .hres_active    : 1
  .nr_events      : 3739031
  .nohz_mode      : 0
  .idle_tick      : 0 nsecs
  .tick_stopped   : 0
  .idle_jiffies   : 0
  .idle_calls     : 0
  .idle_sleeps    : 0
  .idle_entrytime : 0 nsecs
  .idle_sleeptime : 0 nsecs
  .last_jiffies   : 0
  .next_jiffies   : 0
  .idle_expires   : 0 nsecs
jiffies: 3430613

cpu: 3
 clock 0:
  .index:      0
  .resolution: 1 nsecs
  .get_time:   ktime_get_real
  .offset:     1183721968505121290 nsecs
active timers:
 clock 1:
  .index:      1
  .resolution: 1 nsecs
  .get_time:   ktime_get
  .offset:     0 nsecs
active timers:
 #0: <c2047d6c>, tick_sched_timer, S:01
 # expires at 3730641046875 nsecs [in 442986742 nsecs]
  .expires_next   : 3730650046875 nsecs
  .hres_active    : 1
  .nr_events      : 3736405
  .nohz_mode      : 0
  .idle_tick      : 0 nsecs
  .tick_stopped   : 0
  .idle_jiffies   : 0
  .idle_calls     : 0
  .idle_sleeps    : 0
  .idle_entrytime : 0 nsecs
  .idle_sleeptime : 0 nsecs
  .last_jiffies   : 0
  .next_jiffies   : 0
  .idle_expires   : 0 nsecs
jiffies: 3430685


Tick Device: mode:     1
Clock Event Device: pit
 max_delta_ns:   27461866
 min_delta_ns:   12571
 mult:           5124677
 shift:          32
 mode:           3
 next_event:     9223372036854775807 nsecs
 set_next_event: pit_next_event
 set_mode:       init_pit_timer
 event_handler:  tick_handle_oneshot_broadcast
tick_broadcast_mask: 00000000
tick_broadcast_oneshot_mask: 00000000


Tick Device: mode:     1
Clock Event Device: lapic
 max_delta_ns:   671064938
 min_delta_ns:   1199
 mult:           53688981
 shift:          32
 mode:           3
 next_event:     3730740000000 nsecs
 set_next_event: lapic_next_event
 set_mode:       lapic_timer_setup
 event_handler:  hrtimer_interrupt

Tick Device: mode:     1
Clock Event Device: lapic
 max_delta_ns:   671064938
 min_delta_ns:   1199
 mult:           53688981
 shift:          32
 mode:           3
 next_event:     3730196015625 nsecs
 set_next_event: lapic_next_event
 set_mode:       lapic_timer_setup
 event_handler:  hrtimer_interrupt

Tick Device: mode:     1
Clock Event Device: lapic
 max_delta_ns:   671064938
 min_delta_ns:   1199
 mult:           53688981
 shift:          32
 mode:           3
 next_event:     3730799031250 nsecs
 set_next_event: lapic_next_event
 set_mode:       lapic_timer_setup
 event_handler:  hrtimer_interrupt

Tick Device: mode:     1
Clock Event Device: lapic
 max_delta_ns:   671064938
 min_delta_ns:   1199
 mult:           53688981
 shift:          32
 mode:           3
 next_event:     3730828046875 nsecs
 set_next_event: lapic_next_event
 set_mode:       lapic_timer_setup
 event_handler:  hrtimer_interrupt

---CUT---


