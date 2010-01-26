From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: 2.6.33-rc5: (e1000): transmit queue 0 timed out
Date: Mon, 25 Jan 2010 17:07:52 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1001251704310.2536@jbrandeb-desk1.amr.corp.intel.com>
References: <a4423d671001230737i3b3c7da1q6cd4ce615888b36e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a4423d671001230737i3b3c7da1q6cd4ce615888b36e@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org



On Sat, 23 Jan 2010, Alexander Beregalov wrote:
> It is x86_32, UP
> 
> e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>   Tx Queue             <0>
>   TDH                  <0>

The queue seems to have not been started...  what test are you running?  
what kind of traffic and system?  (lspci -vvv please)


>   TDT                  <1f>
>   next_to_use          <1f>
>   next_to_clean        <30>
> buffer_info[next_to_clean]
>   time_stamp           <12d519>
>   next_to_watch        <30>
>   jiffies              <12da92>
>   next_to_watch.status <0>
> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1c5/0x1d0()
> Hardware name:
> NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
> Modules linked in: hwmon_vid sata_sil i2c_nforce2
> Pid: 0, comm: swapper Not tainted 2.6.33-rc5 #1
> Call Trace:
>  [<c102a49d>] warn_slowpath_common+0x6d/0xa0
>  [<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>  [<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>  [<c102a516>] warn_slowpath_fmt+0x26/0x30
>  [<c12ea885>] dev_watchdog+0x1c5/0x1d0
>  [<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>  [<c1033c31>] run_timer_softirq+0x151/0x240
>  [<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>  [<c12ea6c0>] ? dev_watchdog+0x0/0x1d0
>  [<c102f40a>] __do_softirq+0x7a/0x110
>  [<c102f4ed>] do_softirq+0x4d/0x60
>  [<c102f625>] irq_exit+0x65/0x70
>  [<c1015fe7>] smp_apic_timer_interrupt+0x47/0x80
>  [<c11d6904>] ? trace_hardirqs_off_thunk+0xc/0x18
>  [<c1350e63>] apic_timer_interrupt+0x2f/0x34
>  [<c10088fd>] ? default_idle+0x2d/0x60
>  [<c1001b19>] cpu_idle+0x39/0x60
>  [<c13451e8>] rest_init+0x48/0x50
>  [<c16196b4>] start_kernel+0x26d/0x274
>  [<c1619275>] ? unknown_bootoption+0x0/0x19c
>  [<c1619068>] i386_start_kernel+0x68/0x6e
> ---[ end trace 828c510cca9472df ]---
> BUG: unable to handle kernel paging request at 2e8ca4f3
> IP: [<c1071c51>] put_page+0x11/0x120

hm, put_page panic, are you running with jumbo frames enabled?  Does your 
network have jumbo frame traffic on it?

> *pde = 00000000
> Oops: 0000 [#1]
> last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
> Modules linked in: hwmon_vid sata_sil i2c_nforce2
> 
> Pid: 5, comm: events/0 Tainted: G        W  2.6.33-rc5 #1
> NF7-S/NF7,NF7-V (nVidia-nForce2)/
> EIP: 0060:[<c1071c51>] EFLAGS: 00010282 CPU: 0
> EIP is at put_page+0x11/0x120
> EAX: 2e8ca4f3 EBX: 2e8ca4f3 ECX: 00000000 EDX: ee960640
> ESI: f6482620 EDI: 000016b0 EBP: f7065ea8 ESP: f7065e98
>  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> Process events/0 (pid: 5, ti=f7064000 task=f70553c0 task.ti=f7064000)
> Stack:
>  00000206 00000001 f6482620 000016b0 f7065eb8 c12d3100 f6482620 f71d9f50
> <0> f7065ec4 c12d2e32 f80376b0 f7065ecc c12d2ec5 f7065f00 c1276970 cccccccd
> <0> f7065f00 f711fafc f711fafc f711faa0 00000000 f702b440 000000f2 f702b440
> Call Trace:
>  [<c12d3100>] ? skb_release_data+0x90/0xa0
>  [<c12d2e32>] ? __kfree_skb+0x12/0x90
>  [<c12d2ec5>] ? consume_skb+0x15/0x30
>  [<c1276970>] ? e1000_clean_rx_ring+0x80/0x150
>  [<c127c743>] ? e1000_down+0x1b3/0x1d0
>  [<c127cf60>] ? e1000_reset_task+0x0/0x10
>  [<c127cd3b>] ? e1000_reinit_locked+0x4b/0x70
>  [<c127cf6d>] ? e1000_reset_task+0xd/0x10
>  [<c103a9ea>] ? worker_thread+0x14a/0x230
>  [<c103a989>] ? worker_thread+0xe9/0x230
>  [<c103e160>] ? autoremove_wake_function+0x0/0x40
>  [<c103a8a0>] ? worker_thread+0x0/0x230
>  [<c103de6c>] ? kthread+0x6c/0x80
>  [<c103de00>] ? kthread+0x0/0x80
>  [<c100303a>] ? kernel_thread_helper+0x6/0x1c
> Code: 00 00 00 8d bc 27 00 00 00 00 55 b8 e0 1f 07 c1 89 e5 e8 83 93
> fc ff c9 c3 90 55 89 e5 83 ec 10 89 5d f4 89 75 f8 89 c3 89 7d fc <66>
> f7 00 00 c0 0f 85 e4 00 00 00 8b 40 04 85 c0 0f 84 e3 00 00
> EIP: [<c1071c51>] put_page+0x11/0x120 SS:ESP 0068:f7065e98
> CR2: 000000002e8ca4f3
> ---[ end trace 828c510cca9472e0 ]---


Thanks for the report, do you believe it to be new to e1000 in 2.6.33-rc5?
Have you had failure like this before and/or can you see the same failure 
on 2.6.32?



------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
