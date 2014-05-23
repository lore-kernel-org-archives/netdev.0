From: Borislav Petkov <bp@alien8.de>
Subject: e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
Date: Fri, 23 May 2014 18:16:19 +0200
Message-ID: <20140523161619.GF21332@pd.tnic>
References: <20140410115941.GI29093@pd.tnic>
 <9B4A1B1917080E46B64F07F2989DADD65297BCAC@ORSMSX102.amr.corp.intel.com>
 <2B0E3F215D1AB84DA946C8BEE234CCC9370D484B@ORSMSX101.amr.corp.intel.com>
 <20140410163339.GL29093@pd.tnic>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140410163339.GL29093@pd.tnic>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi guys,

again a hardware hang, this time on my workstation with 3.15-rc6:

It happened during a suspend-to-disk attempt doing:

echo 3 > /proc/sys/vm/drop_caches
echo "shutdown" > /sys/power/disk
echo "disk" > /sys/power/state

The box came right back up and dmesg said:

[  294.132711] hib.sh (2254): drop_caches: 3
[  294.559897] PM: Syncing filesystems ... done.
[  294.582962] Freezing user space processes ... (elapsed 0.015 seconds) done.
[  294.606714] PM: Preallocating image memory... done (allocated 147807 pages)
[  294.906232] PM: Allocated 591228 kbytes in 0.29 seconds (2038.71 MB/s)
[  294.912795] Freezing remaining freezable tasks ... (elapsed 0.001 seconds) done.
[  294.923896] serial 00:09: disabled
[  294.924048] i8042 kbd 00:08: System wakeup enabled by ACPI
[  294.924476] nouveau  [     DRM] suspending display...
[  294.924694] nouveau  [     DRM] unpinning framebuffer(s)...
[  294.925098] nouveau  [     DRM] evicting buffers...
[  295.070410] nouveau  [     DRM] waiting for kernel channels to go idle...
[  295.070694] nouveau  [     DRM] suspending client object trees...
[  295.071235] nouveau  [     DRM] suspending kernel object tree...
[  296.435639] PM: freeze of devices complete after 1513.693 msecs
[  296.437013] PM: late freeze of devices complete after 1.134 msecs
[  296.439230] PM: noirq freeze of devices complete after 1.975 msecs
[  296.439480] Disabling non-boot CPUs ...
[  296.442481] kvm: disabling virtualization on CPU1
[  296.443273] smpboot: CPU 1 is now offline
[  296.446958] kvm: disabling virtualization on CPU2
[  296.447512] smpboot: CPU 2 is now offline
[  296.449853] kvm: disabling virtualization on CPU3
[  296.450388] smpboot: CPU 3 is now offline
[  296.452738] kvm: disabling virtualization on CPU4
[  296.453269] smpboot: CPU 4 is now offline
[  296.455420] kvm: disabling virtualization on CPU5
[  296.455613] smpboot: CPU 5 is now offline
[  296.457781] kvm: disabling virtualization on CPU6
[  296.457973] smpboot: CPU 6 is now offline
[  296.460264] kvm: disabling virtualization on CPU7
[  296.460460] smpboot: CPU 7 is now offline
[  296.461718] PM: Creating hibernation image:
[  296.652835] PM: Need to copy 150757 pages
[  297.096476] PM: Hibernation image created (150757 pages copied)
[  296.463242] microcode: CPU0 sig=0x206d7, pf=0x1, revision=0x710
[  296.463581] Enabling non-boot CPUs ...
[  296.463998] x86: Booting SMP configuration:
[  296.464161] smpboot: Booting Node 0 Processor 1 APIC 0x2
[  296.475592] kvm: enabling virtualization on CPU1
[  296.478860] microcode: CPU1 sig=0x206d7, pf=0x1, revision=0x710
[  296.479103] CPU1 is up
[  296.479251] smpboot: Booting Node 0 Processor 2 APIC 0x4
[  296.490562] kvm: enabling virtualization on CPU2
[  296.493462] microcode: CPU2 sig=0x206d7, pf=0x1, revision=0x710
[  296.493702] CPU2 is up
[  296.493842] smpboot: Booting Node 0 Processor 3 APIC 0x6
[  296.505131] kvm: enabling virtualization on CPU3
[  296.508150] microcode: CPU3 sig=0x206d7, pf=0x1, revision=0x710
[  296.508392] CPU3 is up
[  296.508532] smpboot: Booting Node 0 Processor 4 APIC 0x1
[  296.519835] kvm: enabling virtualization on CPU4
[  296.522742] microcode: CPU4 sig=0x206d7, pf=0x1, revision=0x710
[  296.522986] CPU4 is up
[  296.523126] smpboot: Booting Node 0 Processor 5 APIC 0x3
[  296.534432] kvm: enabling virtualization on CPU5
[  296.537336] microcode: CPU5 sig=0x206d7, pf=0x1, revision=0x710
[  296.537628] CPU5 is up
[  296.537766] smpboot: Booting Node 0 Processor 6 APIC 0x5
[  296.549081] kvm: enabling virtualization on CPU6
[  296.552051] microcode: CPU6 sig=0x206d7, pf=0x1, revision=0x710
[  296.552296] CPU6 is up
[  296.552439] smpboot: Booting Node 0 Processor 7 APIC 0x7
[  296.563736] kvm: enabling virtualization on CPU7
[  296.566810] microcode: CPU7 sig=0x206d7, pf=0x1, revision=0x710
[  296.567053] CPU7 is up
[  296.575584] PM: noirq thaw of devices complete after 1.113 msecs
[  296.577011] PM: early thaw of devices complete after 1.117 msecs
[  296.577598] e1000e 0000:00:19.0: irq 73 for MSI/MSI-X
[  296.577614] nouveau  [     DRM] re-enabling device...
[  296.577624] nouveau  [     DRM] resuming kernel object tree...
[  296.577633] nouveau  [   VBIOS][0000:03:00.0] running init tables
[  296.578310] i8042 kbd 00:08: System wakeup disabled by ACPI
[  296.579194] serial 00:09: activated
[  296.588124] snd_hda_intel 0000:00:1b.0: irq 75 for MSI/MSI-X
[  296.588765] megasas: Waiting for FW to come to ready state
[  296.602572] megasas: FW now in Ready state
[  296.602652] megaraid_sas 0000:04:00.0: irq 84 for MSI/MSI-X
[  296.645901] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
[  296.653425] e1000e 0000:00:19.0 eth0: 10/100 speed: disabling TSO
[  296.882443] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
[  296.894256] ata1.00: configured for UDMA/100
[  296.899303] nouveau  [    VOLT][0000:03:00.0] GPU voltage: 900000uv
[  296.905646] nouveau  [  PTHERM][0000:03:00.0] fan management: automatic
[  296.912342] nouveau  [     CLK][0000:03:00.0] --: core 405 MHz shader 810 MHz memory 405 MHz
[  296.921316] nouveau  [     DRM] resuming client object trees...
[  296.927510] nouveau  [     DRM] resuming display...
[  296.977712] PM: thaw of devices complete after 400.618 msecs
[  296.984852] PM: Cannot find swap device, try swapon -a.
[  296.990310] PM: Cannot get swap writer
[  297.075181] Restarting tasks ... done.
[  309.022159] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[  309.022159]   TDH                  <0>
[  309.022159]   TDT                  <6>
[  309.022159]   next_to_use          <6>
[  309.022159]   next_to_clean        <0>
[  309.022159] buffer_info[next_to_clean]:
[  309.022159]   time_stamp           <ffffefc5>
[  309.022159]   next_to_watch        <1>
[  309.022159]   jiffies              <100001e11>
[  309.022159]   next_to_watch.status <0>
[  309.022159] MAC Status             <43>
[  309.022159] PHY Status             <796d>
[  309.022159] PHY 1000BASE-T Status  <0>
[  309.022159] PHY Extended Status    <3000>
[  309.022159] PCI Status             <10>
[  311.021049] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[  311.021049]   TDH                  <0>
[  311.021049]   TDT                  <6>
[  311.021049]   next_to_use          <6>
[  311.021049]   next_to_clean        <0>
[  311.021049] buffer_info[next_to_clean]:
[  311.021049]   time_stamp           <ffffefc5>
[  311.021049]   next_to_watch        <1>
[  311.021049]   jiffies              <1000025e1>
[  311.021049]   next_to_watch.status <0>
[  311.021049] MAC Status             <43>
[  311.021049] PHY Status             <796d>
[  311.021049] PHY 1000BASE-T Status  <0>
[  311.021049] PHY Extended Status    <3000>
[  311.021049] PCI Status             <10>
[  312.043582] ------------[ cut here ]------------
[  312.048470] WARNING: CPU: 1 PID: 0 at net/sched/sch_generic.c:264 dev_watchdog+0x276/0x280()
[  312.056968] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed out
[  312.057025] Modules linked in: ext2 vfat fat fuse loop dm_crypt dm_mod x86_pkg_temp_thermal coretemp kvm_intel kvm crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 glue_helper lrw snd_hda_codec_realtek snd_hda_codec_hdmi gf128mul ablk_helper usbhid snd_hda_codec_generic cryptd snd_hda_intel snd_hda_controller snd_hda_codec iTCO_wdt xhci_hcd sb_edac ehci_pci microcode edac_core iTCO_vendor_support pcspkr ehci_hcd evdev dcdbas button snd_hwdep snd_pcm usbcore acpi_cpufreq snd_timer processor snd i2c_i801 lpc_ich mfd_core usb_common soundcore
[  312.057029] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.15.0-rc6+ #1
[  312.057030] Hardware name: Dell Inc. Precision T3600/0PTTT9, BIOS A08 01/24/2013
[  312.057035]  0000000000000009 ffff88043e223d68 ffffffff8170edda ffff88043e223db0
[  312.057039]  ffff88043e223da0 ffffffff81065b7d 0000000000000000 ffff8804365b4000
[  312.057042]  ffff8804364ed480 0000000000000001 0000000000000001 ffff88043e223e00
[  312.057043] Call Trace:
[  312.057052]  <IRQ>  [<ffffffff8170edda>] dump_stack+0x4e/0x7a
[  312.057057]  [<ffffffff81065b7d>] warn_slowpath_common+0x7d/0xa0
[  312.057061]  [<ffffffff81065bec>] warn_slowpath_fmt+0x4c/0x50
[  312.057064]  [<ffffffff816403e6>] dev_watchdog+0x276/0x280
[  312.057068]  [<ffffffff81640170>] ? dev_graft_qdisc+0x80/0x80
[  312.057072]  [<ffffffff81072c6a>] call_timer_fn+0x7a/0x1a0
[  312.057075]  [<ffffffff81072bf5>] ? call_timer_fn+0x5/0x1a0
[  312.057079]  [<ffffffff81640170>] ? dev_graft_qdisc+0x80/0x80
[  312.057082]  [<ffffffff810730e4>] run_timer_softirq+0x264/0x310
[  312.057087]  [<ffffffff8106b549>] __do_softirq+0x139/0x3a0
[  312.057091]  [<ffffffff8106bb65>] irq_exit+0x115/0x120
[  312.057097]  [<ffffffff817232c5>] smp_apic_timer_interrupt+0x45/0x60
[  312.057101]  [<ffffffff81721c72>] apic_timer_interrupt+0x72/0x80
[  312.057108]  <EOI>  [<ffffffff815d3474>] ? cpuidle_enter_state+0x54/0xd0
[  312.057112]  [<ffffffff815d3470>] ? cpuidle_enter_state+0x50/0xd0
[  312.057116]  [<ffffffff815d3527>] cpuidle_enter+0x17/0x20
[  312.057120]  [<ffffffff810b0d65>] cpu_startup_entry+0x335/0x4c0
[  312.057126]  [<ffffffff8104402b>] start_secondary+0x1fb/0x270
[  312.057129] ---[ end trace 3aa454781533e361 ]---
[  312.057296] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[  313.826071] e1000e: eth0 NIC Link is Up 100 Mbps Full Duplex, Flow Control: Rx/Tx
[  313.833622] e1000e 0000:00:19.0 eth0: 10/100 speed: disabling TSO

Thanks.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
