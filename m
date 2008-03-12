From: "Torsten Kaiser" <just.for.lkml@googlemail.com>
Subject: Re: 2.6.25-rc5-mm1
Date: Wed, 12 Mar 2008 21:01:36 +0100
Message-ID: <64bb37e0803121301u6f836710m9ebb30e065751bec@mail.gmail.com>
References: <20080311011434.ad8c8d7d.akpm@linux-foundation.org>
	 <20080311202300.GA8957@vino.hallyn.com>
	 <20080311133920.68dc410b.akpm@linux-foundation.org>
	 <64bb37e0803121233v30d12a58i77a1e23fd02ea6f2@mail.gmail.com>
	 <20080312124420.3ba8c3d7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754788AbYCLUBy@vger.kernel.org>
In-Reply-To: <20080312124420.3ba8c3d7.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2008 at 8:44 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 12 Mar 2008 20:33:02 +0100
>  "Torsten Kaiser" <just.for.lkml@googlemail.com> wrote:
>  > dmesg:
>  > [    0.000000] Linux version 2.6.25-rc5-mm1 (root@treogen) (gcc
>  > version 4.2.3 (Gentoo 4.2.3 p1.0)) #1 SMP Wed Mar 12 19:51:41 CET 2008
>  > [    0.000000] Command line: earlyprintk=serial,ttyS0,115200
>  > console=ttyS0,115200 console=tty1 crypt_root=/dev/md1 sata_nv.swncq=1
>
>  So you aren't using netconsole.  I had a series of hangs yesterday which
>  went away when netconsole was disabled.  I think netconsole is still
>  busted.

No, just a plain serial console.

>  > be reserved
>  > [    1.943656] system 00:0d: iomem range 0xfec00000-0xffffffff could
>  > not be reserved
>  > [    1.961251] PCI: Bridge: 0000:00:06.0
>  > [    1.964921]   IO window: disabled.
>  > [    1.968331]   MEM window: 0xeff00000-0xefffffff
>  > [    1.980903]   PREFETCH window: 0x00000000eef00000-0x00000000eeffffff
>  > [    1.987254] PCI: Bridge: 0000:00:0b.0
>  > [    2.000871]   IO window: e000-efff
>  > [    2.004283]   MEM window: 0xefe00000-0xefefffff
>  > [    2.022569]   PREFETCH window: disabled.
>  > [    2.026646] PCI: Bridge: 0000:00:0c.0
>  > [    2.030312]   IO window: disabled.
>  > [    2.040486]   MEM window: 0xefd00000-0xefdfffff
>  > [    2.045020]   PREFETCH window: disabled.
>  > [    2.050486] PCI: Bridge: 0000:00:0d.0
>  > [    2.062526]   IO window: disabled.
>  > [    2.065935]   MEM window: 0xefc00000-0xefcfffff
>  > [    2.082499]   PREFETCH window: disabled.
>  > [    2.086432] PCI: Bridge: 0000:00:0f.0
>  > [    2.092499]   IO window: d000-dfff
>  > [    2.102467]   MEM window: 0xefb00000-0xefbfffff
>  > [    2.107000]   PREFETCH window: 0x00000000e0000000-0x00000000e7ffffff
>  > [    2.122526] NET: Registered protocol family 2
>  > -> System hang, no reaction to the SysRq keys.
[snip]
>  OK, so it looks like it died during networking initialisation.
>
>  Could you please add initcall_debug to the boot command line so we can see
>  which function it is getting stuck in?

Yes, here is the result:
[    2.573979] PCI-DMA: Disabling AGP.
[    2.577639] PCI-DMA: aperture base @ 8000000 size 65536 KB
[    2.589504] PCI-DMA: using GART IOMMU.
[    2.593258] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
[    2.600132] initcall pci_iommu_init+0x0/0x20() returned 0 after 19 msecs
[    2.622146] calling  hpet_late_init+0x0/0x140()
[    2.626689] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 31
[    2.633022] hpet0: 3 32-bit timers, 25000000 Hz
[    2.638562] initcall hpet_late_init+0x0/0x140() returned 0 after 9 msecs
[    2.654545] calling  clocksource_done_booting+0x0/0x20()
[    2.659855] initcall clocksource_done_booting+0x0/0x20()<6>Time:
hpet clocksource has been installed.
[    2.662185]  returned 0 after 0 msecs
[    2.688448] calling  init_pipe_fs+0x0/0x60()
[    2.695423] initcall init_pipe_fs+0x0/0x60() returned 0 after 0 msecs
[    2.705784] calling  init_mnt_writers+0x0/0x70()
[    2.711681] initcall init_mnt_writers+0x0/0x70() returned 0 after 0 msecs
[    2.721678] calling  eventpoll_init+0x0/0x90()
[    2.731644] initcall eventpoll_init+0x0/0x90() returned 0 after 0 msecs
[    2.738295] calling  anon_inode_init+0x0/0x130()
[    2.751614] initcall anon_inode_init+0x0/0x130() returned 0 after 0 msecs
[    2.771585] calling  pcie_aspm_init+0x0/0x30()
[    2.779297] initcall pcie_aspm_init+0x0/0x30() returned 0 after 2 msecs
[    2.793911] calling  acpi_event_init+0x0/0x52()

-> it looked like the system this time already hung here. But just
pressing the 'Alt' key let the system continue until the network hang.
(I tried this a second time, again it paused here until I pressed a key)

[   94.857929] initcall acpi_event_init+0x0/0x52() returned 0 after 29276 msecs
[   94.865002] calling  pnp_system_init+0x0/0x20()
[   94.877935] system 00:06: ioport range 0x4d0-0x4d1 has been reserved
[   94.884286] system 00:06: ioport range 0x7b0-0x7df has been reserved
[   94.897886] system 00:06: ioport range 0x800-0x80f has been reserved
[   94.907886] system 00:06: ioport range 0xbb0-0xbdf has been reserved
[   94.917855] system 00:06: ioport range 0x2000-0x207f has been reserved
[   94.937827] system 00:06: ioport range 0x2080-0x20ff has been reserved
[   94.947827] system 00:06: ioport range 0x2400-0x247f has been reserved
[   94.957793] system 00:06: ioport range 0x2480-0x24ff has been reserved
[   94.977766] system 00:06: ioport range 0x2800-0x287f has been reserved
[   94.987766] system 00:06: ioport range 0x2880-0x28ff has been reserved
[   94.997734] system 00:06: ioport range 0x2c00-0x2c7f has been reserved
[   95.017708] system 00:06: ioport range 0x2c80-0x2cff has been reserved
[   95.024234] system 00:06: iomem range 0x0-0x0 could not be reserved
[   95.037678] system 00:06: iomem range 0xfee01000-0xfeefffff could
not be reserved
[   95.060158] system 00:06: iomem range 0xefa80000-0xefabffff has been reserved
[   95.070158] system 00:06: iomem range 0xffb00000-0xffbfffff could
not be reserved
[   95.077633] system 00:06: iomem range 0xfff00000-0xffffffff could
not be reserved
[   95.097590] system 00:08: iomem range 0xfec00000-0xfec00fff could
not be reserved
[   95.120064] system 00:08: iomem range 0xfee00000-0xfee00fff could
not be reserved
[   95.130070] system 00:0c: ioport range 0x290-0x297 has been reserved
[   95.137523] system 00:0d: iomem range 0x0-0x9ffff could not be reserved
[   95.157495] system 00:0d: iomem range 0xc0000-0xcffff has been reserved
[   95.167495] system 00:0d: iomem range 0xe0000-0xfffff could not be reserved
[   95.177463] system 00:0d: iomem range 0x100000-0xdfffffff could not
be reserved
[   95.197437] system 00:0d: iomem range 0xfec00000-0xffffffff could
not be reserved
[   95.219983] initcall pnp_system_init+0x0/0x20() returned 0 after 162 msecs
[   95.226887] calling  chr_dev_init+0x0/0xd0()
[   95.237813] initcall chr_dev_init+0x0/0xd0() returned 0 after 0 msecs
[   95.247378] calling  firmware_class_init+0x0/0x90()
[   95.257320] initcall firmware_class_init+0x0/0x90() returned 0 after 0 msecs
[   95.276031] calling  loopback_init+0x0/0x20()
[   95.288590] initcall loopback_init+0x0/0x20() returned 0 after 0 msecs
[   95.296837] calling  cpufreq_gov_performance_init+0x0/0x20()
[   95.309084] initcall cpufreq_gov_performance_init+0x0/0x20()
returned 0 after 0 msecs
[   95.317734] calling  cpufreq_gov_dbs_init+0x0/0x50()
[   95.338090] initcall cpufreq_gov_dbs_init+0x0/0x50() returned 0 after 0 msecs
[   95.345254] calling  init_acpi_pm_clocksource+0x0/0xc0()
[   95.355293] initcall init_acpi_pm_clocksource+0x0/0xc0() returned 0
after 0 msecs
[   95.374115] calling  pcibios_assign_resources+0x0/0x90()
[   95.379618] PCI: Bridge: 0000:00:06.0
[   95.394087]   IO window: disabled.
[   95.397502]   MEM window: 0xeff00000-0xefffffff
[   95.402032]   PREFETCH window: 0x00000000eef00000-0x00000000eeffffff
[   95.415189] PCI: Bridge: 0000:00:0b.0
[   95.418860]   IO window: e000-efff
[   95.438075]   MEM window: 0xefe00000-0xefefffff
[   95.442610]   PREFETCH window: disabled.
[   95.455526] PCI: Bridge: 0000:00:0c.0
[   95.459197]   IO window: disabled.
[   95.462604]   MEM window: 0xefd00000-0xefdfffff
[   95.475513]   PREFETCH window: disabled.
[   95.479443] PCI: Bridge: 0000:00:0d.0
[   95.485512]   IO window: disabled.
[   95.495480]   MEM window: 0xefc00000-0xefcfffff
[   95.500010]   PREFETCH window: disabled.
[   95.515455] PCI: Bridge: 0000:00:0f.0
[   95.519124]   IO window: d000-dfff
[   95.522533]   MEM window: 0xefb00000-0xefbfffff
[   95.535423]   PREFETCH window: 0x00000000e0000000-0x00000000e7ffffff
[   95.545456] initcall pcibios_assign_resources+0x0/0x90() returned 0
after 79 msecs
[   95.557830] calling  fill_mp_bus_to_cpumask+0x0/0x100()
[   95.575408] initcall fill_mp_bus_to_cpumask+0x0/0x100() returned 0
after 0 msecs
[   95.593777] calling  inet_init+0x0/0x380()
[   95.597890] NET: Registered protocol family 2

-> same hang, no reaction to SysRq.

What looks suspicious: The call to pcie_aspm_init is just before the
temporary hang. When I used make oldconfig to upgrade the .config from
2.6.25-rc3-mm1 to -rc5-mm1 I activated the new option CONFIG_PCIEASPM.

I will try with CONFIG_PCIEASPM_DEBUG added and completely without this option.

Torsten
