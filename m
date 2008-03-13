From: Badari Pulavarty <pbadari@gmail.com>
Subject: Re: 2.6.25-rc5-mm1
Date: Thu, 13 Mar 2008 15:10:09 -0800
Message-ID: <1205449809.19403.40.camel@dyn9047017100.beaverton.ibm.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
	 <20080311202300.GA8957@vino.hallyn.com>
	 <20080311133920.68dc410b.akpm@linux-foundation.org>
	 <64bb37e0803121233v30d12a58i77a1e23fd02ea6f2@mail.gmail.com>
	 <20080312124420.3ba8c3d7.akpm@linux-foundation.org>
	 <64bb37e0803121301u6f836710m9ebb30e065751bec@mail.gmail.com>
	 <64bb37e0803131505u7ae920fdvbbed005cbeb8c98e@mail.gmail.com>
	 <20080313153528.a11795b7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Torsten Kaiser <just.for.lkml@googlemail.com>,
	lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:47208 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757304AbYCMXG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Mar 2008 19:06:56 -0400
In-Reply-To: <20080313153528.a11795b7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-03-13 at 15:35 -0700, Andrew Morton wrote:
> On Thu, 13 Mar 2008 23:05:11 +0100
> "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
> 
> > On Wed, Mar 12, 2008 at 9:01 PM, Torsten Kaiser
> > <just.for.lkml@googlemail.com> wrote:
> > > On Wed, Mar 12, 2008 at 8:44 PM, Andrew Morton
> > > <akpm@linux-foundation.org> wrote:
> > > >  OK, so it looks like it died during networking initialisation.
> > >  >
> > >  >  Could you please add initcall_debug to the boot command line so we can see
> > >  >  which function it is getting stuck in?
> > >
> > >  Yes, here is the result:
> > >  [    2.573979] PCI-DMA: Disabling AGP.
> > >  [    2.577639] PCI-DMA: aperture base @ 8000000 size 65536 KB
> > >  [    2.589504] PCI-DMA: using GART IOMMU.
> > >  [    2.593258] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
> > >  [    2.600132] initcall pci_iommu_init+0x0/0x20() returned 0 after 19 msecs
> > >  [    2.622146] calling  hpet_late_init+0x0/0x140()
> > >  [    2.626689] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
> > >  [    2.633022] hpet0: 3 32-bit timers, 25000000 Hz
> > >  [    2.638562] initcall hpet_late_init+0x0/0x140() returned 0 after 9 msecs
> > >  [    2.654545] calling  clocksource_done_booting+0x0/0x20()
> > >  [    2.659855] initcall clocksource_done_booting+0x0/0x20()<6>Time:
> > >
> > > hpet clocksource has been installed.
> > >  [    2.662185]  returned 0 after 0 msecs
> > >  [    2.688448] calling  init_pipe_fs+0x0/0x60()
> > >  [    2.695423] initcall init_pipe_fs+0x0/0x60() returned 0 after 0 msecs
> > >  [    2.705784] calling  init_mnt_writers+0x0/0x70()
> > >  [    2.711681] initcall init_mnt_writers+0x0/0x70() returned 0 after 0 msecs
> > >  [    2.721678] calling  eventpoll_init+0x0/0x90()
> > >  [    2.731644] initcall eventpoll_init+0x0/0x90() returned 0 after 0 msecs
> > >  [    2.738295] calling  anon_inode_init+0x0/0x130()
> > >  [    2.751614] initcall anon_inode_init+0x0/0x130() returned 0 after 0 msecs
> > >  [    2.771585] calling  pcie_aspm_init+0x0/0x30()
> > >  [    2.779297] initcall pcie_aspm_init+0x0/0x30() returned 0 after 2 msecs
> > >  [    2.793911] calling  acpi_event_init+0x0/0x52()
> > >
> > >  -> it looked like the system this time already hung here. But just
> > >  pressing the 'Alt' key let the system continue until the network hang.
> > >  (I tried this a second time, again it paused here until I pressed a key)
> > >
> > >  [   94.857929] initcall acpi_event_init+0x0/0x52() returned 0 after 29276 msecs
> > >  [   94.865002] calling  pnp_system_init+0x0/0x20()
> > >  [   94.877935] system 00:06: ioport range 0x4d0-0x4d1 has been reserved
> > >  [   94.884286] system 00:06: ioport range 0x7b0-0x7df has been reserved
> > >  [   94.897886] system 00:06: ioport range 0x800-0x80f has been reserved
> > >  [   94.907886] system 00:06: ioport range 0xbb0-0xbdf has been reserved
> > >  [   94.917855] system 00:06: ioport range 0x2000-0x207f has been reserved
> > >  [   94.937827] system 00:06: ioport range 0x2080-0x20ff has been reserved
> > >  [   94.947827] system 00:06: ioport range 0x2400-0x247f has been reserved
> > >  [   94.957793] system 00:06: ioport range 0x2480-0x24ff has been reserved
> > >  [   94.977766] system 00:06: ioport range 0x2800-0x287f has been reserved
> > >  [   94.987766] system 00:06: ioport range 0x2880-0x28ff has been reserved
> > >  [   94.997734] system 00:06: ioport range 0x2c00-0x2c7f has been reserved
> > >  [   95.017708] system 00:06: ioport range 0x2c80-0x2cff has been reserved
> > >  [   95.024234] system 00:06: iomem range 0x0-0x0 could not be reserved
> > >  [   95.037678] system 00:06: iomem range 0xfee01000-0xfeefffff could
> > >  not be reserved
> > >  [   95.060158] system 00:06: iomem range 0xefa80000-0xefabffff has been reserved
> > >  [   95.070158] system 00:06: iomem range 0xffb00000-0xffbfffff could
> > >  not be reserved
> > >  [   95.077633] system 00:06: iomem range 0xfff00000-0xffffffff could
> > >  not be reserved
> > >  [   95.097590] system 00:08: iomem range 0xfec00000-0xfec00fff could
> > >  not be reserved
> > >  [   95.120064] system 00:08: iomem range 0xfee00000-0xfee00fff could
> > >  not be reserved
> > >  [   95.130070] system 00:0c: ioport range 0x290-0x297 has been reserved
> > >  [   95.137523] system 00:0d: iomem range 0x0-0x9ffff could not be reserved
> > >  [   95.157495] system 00:0d: iomem range 0xc0000-0xcffff has been reserved
> > >  [   95.167495] system 00:0d: iomem range 0xe0000-0xfffff could not be reserved
> > >  [   95.177463] system 00:0d: iomem range 0x100000-0xdfffffff could not
> > >  be reserved
> > >  [   95.197437] system 00:0d: iomem range 0xfec00000-0xffffffff could
> > >  not be reserved
> > >  [   95.219983] initcall pnp_system_init+0x0/0x20() returned 0 after 162 msecs
> > >  [   95.226887] calling  chr_dev_init+0x0/0xd0()
> > >  [   95.237813] initcall chr_dev_init+0x0/0xd0() returned 0 after 0 msecs
> > >  [   95.247378] calling  firmware_class_init+0x0/0x90()
> > >  [   95.257320] initcall firmware_class_init+0x0/0x90() returned 0 after 0 msecs
> > >  [   95.276031] calling  loopback_init+0x0/0x20()
> > >  [   95.288590] initcall loopback_init+0x0/0x20() returned 0 after 0 msecs
> > >  [   95.296837] calling  cpufreq_gov_performance_init+0x0/0x20()
> > >  [   95.309084] initcall cpufreq_gov_performance_init+0x0/0x20()
> > >  returned 0 after 0 msecs
> > >  [   95.317734] calling  cpufreq_gov_dbs_init+0x0/0x50()
> > >  [   95.338090] initcall cpufreq_gov_dbs_init+0x0/0x50() returned 0 after 0 msecs
> > >  [   95.345254] calling  init_acpi_pm_clocksource+0x0/0xc0()
> > >  [   95.355293] initcall init_acpi_pm_clocksource+0x0/0xc0() returned 0
> > >  after 0 msecs
> > >  [   95.374115] calling  pcibios_assign_resources+0x0/0x90()
> > >  [   95.379618] PCI: Bridge: 0000:00:06.0
> > >  [   95.394087]   IO window: disabled.
> > >  [   95.397502]   MEM window: 0xeff00000-0xefffffff
> > >  [   95.402032]   PREFETCH window: 0x00000000eef00000-0x00000000eeffffff
> > >  [   95.415189] PCI: Bridge: 0000:00:0b.0
> > >  [   95.418860]   IO window: e000-efff
> > >  [   95.438075]   MEM window: 0xefe00000-0xefefffff
> > >  [   95.442610]   PREFETCH window: disabled.
> > >  [   95.455526] PCI: Bridge: 0000:00:0c.0
> > >  [   95.459197]   IO window: disabled.
> > >  [   95.462604]   MEM window: 0xefd00000-0xefdfffff
> > >  [   95.475513]   PREFETCH window: disabled.
> > >  [   95.479443] PCI: Bridge: 0000:00:0d.0
> > >  [   95.485512]   IO window: disabled.
> > >  [   95.495480]   MEM window: 0xefc00000-0xefcfffff
> > >  [   95.500010]   PREFETCH window: disabled.
> > >  [   95.515455] PCI: Bridge: 0000:00:0f.0
> > >  [   95.519124]   IO window: d000-dfff
> > >  [   95.522533]   MEM window: 0xefb00000-0xefbfffff
> > >  [   95.535423]   PREFETCH window: 0x00000000e0000000-0x00000000e7ffffff
> > >  [   95.545456] initcall pcibios_assign_resources+0x0/0x90() returned 0
> > >  after 79 msecs
> > >  [   95.557830] calling  fill_mp_bus_to_cpumask+0x0/0x100()
> > >  [   95.575408] initcall fill_mp_bus_to_cpumask+0x0/0x100() returned 0
> > >  after 0 msecs
> > >  [   95.593777] calling  inet_init+0x0/0x380()
> > >  [   95.597890] NET: Registered protocol family 2
> > >
> > >  -> same hang, no reaction to SysRq.
> > >
> > >  What looks suspicious: The call to pcie_aspm_init is just before the
> > >  temporary hang. When I used make oldconfig to upgrade the .config from
> > >  2.6.25-rc3-mm1 to -rc5-mm1 I activated the new option CONFIG_PCIEASPM.
> > >
> > >  I will try with CONFIG_PCIEASPM_DEBUG added and completely without this option.
> > 
> > CONFIG_PCIEASPM does not change anything.
> > Also testing the range of ipc patches you suggested to Badari did not fix it.
> > 
> > I did a bisect, these patches are currently remaining, but I dod not
> > have the time for more bisect steps until tomorrow:
> 
> OK, thanks for persisting.
> 
> > git-scsi-misc
> > git-sh
> > execute-tasklets-in-the-same-order-they-were-queued
> > git-sched
> > sched: work around hrtick related lockup
> > sched: make sure jiffies is up to date before calling __update_rq_clock()
> > sched: fix rq->clock overflows detection with CONFIG_NO_HZ
> > sched: make cpu_clock() globally synchronous
> > sched: remove isolcpus
> > ftrace: make the task state char-string visible to all
> > sched: add latency tracer callbacks to the scheduler

Yes. I found the following patch to be the culprit.

sched: make sure jiffies is up to date before calling __update_rq_clock
()

Torsten, looking at your output, it looks like it hung at the same
place. Backing out this patch should help. Try it out. I am sure
you also have CONFIG_DETECT_SOFTLOCKUP=y in your config ?


commit 60befbc1c0b6d141c9c26e61ddd303aedd1e7396
Author: Guillaume Chazarain <guichaz@yahoo.fr>
Date:   Mon Mar 10 08:16:41 2008 +0100

    sched: make sure jiffies is up to date before calling
__update_rq_clock()

    Now that __update_rq_clock() uses jiffies to detect clock overflows,
    make sure jiffies are up to date before touch_softlockup_watchdog().

    Removed a touch_softlockup_watchdog() call becoming redundant with
the
    added tick_nohz_update_jiffies().

    Signed-off-by: Guillaume Chazarain <guichaz@yahoo.fr>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/kernel/sched.c b/kernel/sched.c
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -66,6 +66,7 @@
 #include <linux/unistd.h>
 #include <linux/pagemap.h>
 #include <linux/hrtimer.h>
+#include <linux/tick.h>
 
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
@@ -913,7 +914,7 @@ void sched_clock_idle_wakeup_event(u64 delta_ns)
        rq->prev_clock_raw = now;
        rq->clock += delta_ns;
        spin_unlock(&rq->lock);
-       touch_softlockup_watchdog();
+       tick_nohz_update_jiffies();
 }
 EXPORT_SYMBOL_GPL(sched_clock_idle_wakeup_event);

Thanks,
Badari

