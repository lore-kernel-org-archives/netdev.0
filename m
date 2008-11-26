From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skge finds PCI error cmd=0x117 status=0x22b0 in 2.6.27.7
Date: Wed, 26 Nov 2008 08:48:05 -0800
Message-ID: <20081126084805.7c0ab417@extreme>
References: <1227676694.16069.78.camel@corfu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Guenther Thomsen <guenthert@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43846 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbYKZQsS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 11:48:18 -0500
In-Reply-To: <1227676694.16069.78.camel@corfu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Nov 2008 21:18:14 -0800
Guenther Thomsen <guenthert@gmail.com> wrote:

> Just about an hour or so after upgrading my desktop at work from 4 to
> 8GiB RAM, I lost network connectivity and found following in the
> kernel's message buffer:
> --8<--
> 
> Nov 24 17:06:32 corfu kernel: [  116.841025] skge 0000:03:04.0: PCI error cmd=0x117 status=0x22b0
> Nov 24 17:06:32 corfu kernel: [  116.841054] skge 0000:03:04.0: unable to clear error (so ignoring them)
> Nov 24 17:06:32 corfu pulseaudio[4702]: module-hal-detect.c: Error getting capability: org.freedesktop.Hal.NoSuchDevice: No device with id /org/freedesktop/Hal/devices/usb_device_fca_1_noserial_if0
> Nov 24 17:06:39 corfu last message repeated 141 times
> Nov 24 17:06:39 corfu kernel: [  124.337092] ------------[ cut here ]------------
> Nov 24 17:06:39 corfu kernel: [  124.337102] WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x1f5/0x210()
> Nov 24 17:06:39 corfu kernel: [  124.337104] NETDEV WATCHDOG: eth0 (skge): transmit timed out
> Nov 24 17:06:39 corfu kernel: [  124.337106] Modules linked in: berry_charge isofs nfs lockd nfs_acl sunrpc binfmt_misc autofs4 cpufreq_stats cpufreq_userspace cpufreq_powersave cpufreq_conservative cpufreq_ondemand freq_table wmi container video output fan sbs pci_slot sbshc battery iptable_filter ip_tables x_tables ipv6 ac it87 hwmon_vid fuse sr_mod cdrom af_packet usbhid hid snd_hda_intel snd_pcm snd_timer serio_raw snd soundcore ehci_hcd shpchp atiixp thermal ohci_hcd snd_page_alloc pci_hotplug skge psmouse i2c_piix4 button processor thermal_sys sg ide_core evdev i2c_core usbcore k8temp pcspkr floppy
> Nov 24 17:06:39 corfu kernel: [  124.337136] Pid: 2280, comm: udevd Not tainted 2.6.27.7 #4
> Nov 24 17:06:39 corfu kernel: [  124.337137] 
> Nov 24 17:06:39 corfu kernel: [  124.337138] Call Trace:
> Nov 24 17:06:39 corfu kernel: [  124.337139]  <IRQ>  [<ffffffff8023541d>] warn_slowpath+0xcd/0x110
> Nov 24 17:06:39 corfu kernel: [  124.337146]  [<ffffffff80229d11>] update_curr+0x41/0x80
> Nov 24 17:06:39 corfu kernel: [  124.337148]  [<ffffffff80229d11>] update_curr+0x41/0x80
> Nov 24 17:06:39 corfu kernel: [  124.337150]  [<ffffffff802292b7>] source_load+0x37/0x70
> Nov 24 17:06:39 corfu kernel: [  124.337153]  [<ffffffff80368d09>] __next_cpu+0x19/0x30
> Nov 24 17:06:39 corfu kernel: [  124.337156]  [<ffffffff8022b53e>] find_busiest_group+0x19e/0x850
> Nov 24 17:06:39 corfu kernel: [  124.337158]  [<ffffffff80229d11>] update_curr+0x41/0x80
> Nov 24 17:06:39 corfu kernel: [  124.337161]  [<ffffffff80229d11>] update_curr+0x41/0x80
> Nov 24 17:06:39 corfu kernel: [  124.337163]  [<ffffffff8036e57e>] strlcpy+0x4e/0x80
> Nov 24 17:06:39 corfu kernel: [  124.337165]  [<ffffffff80442925>] dev_watchdog+0x1f5/0x210
> Nov 24 17:06:39 corfu kernel: [  124.337168]  [<ffffffff80442730>] dev_watchdog+0x0/0x210
> Nov 24 17:06:39 corfu kernel: [  124.337171]  [<ffffffff8023f1ef>] run_timer_softirq+0x18f/0x200
> Nov 24 17:06:39 corfu kernel: [  124.337173]  [<ffffffff802502f9>] getnstimeofday+0x39/0xc0
> Nov 24 17:06:39 corfu kernel: [  124.337176]  [<ffffffff8023ab76>] __do_softirq+0x76/0xf0
> Nov 24 17:06:39 corfu kernel: [  124.337179]  [<ffffffff8020ca3c>] call_softirq+0x1c/0x30
> Nov 24 17:06:39 corfu kernel: [  124.337181]  [<ffffffff8020e345>] do_softirq+0x35/0x70
> Nov 24 17:06:39 corfu kernel: [  124.337183]  [<ffffffff8023aaf9>] irq_exit+0x89/0x90
> Nov 24 17:06:39 corfu kernel: [  124.337187]  [<ffffffff8021c100>] smp_apic_timer_interrupt+0x80/0xc0
> Nov 24 17:06:39 corfu kernel: [  124.337189]  [<ffffffff8020c486>] apic_timer_interrupt+0x66/0x70
> Nov 24 17:06:39 corfu kernel: [  124.337190]  <EOI>  [<ffffffff80370075>] copy_page_c+0x5/0x10
> Nov 24 17:06:39 corfu kernel: [  124.337195]  [<ffffffff80288287>] do_wp_page+0x127/0x540
> Nov 24 17:06:39 corfu kernel: [  124.337197]  [<ffffffff80289da8>] handle_mm_fault+0x5e8/0x7d0
> Nov 24 17:06:39 corfu kernel: [  124.337200]  [<ffffffff804a9459>] error_exit+0x0/0x51
> Nov 24 17:06:39 corfu kernel: [  124.337203]  [<ffffffff804ab91f>] do_page_fault+0x46f/0x830
> Nov 24 17:06:39 corfu kernel: [  124.337206]  [<ffffffff80370dad>] __put_user_4+0x1d/0x30
> Nov 24 17:06:39 corfu kernel: [  124.337208]  [<ffffffff804a9459>] error_exit+0x0/0x51
> Nov 24 17:06:39 corfu kernel: [  124.337209] 
> Nov 24 17:06:39 corfu kernel: [  124.337211] ---[ end trace 764746180da213d0 ]---
> -->8--
> 
> This turns out to be easily reproduceable: unzip'ing a large ZIP file
> (~200MiB) which resides on a fast NFS server, i.e. reading and writing
> large amounts via NFS, will cause  above error within seconds.
> 
> Now I actually don't do that usually using my desktop PC (in fact I
> can't remember to have ever done that before), so it might have been
> unrelated to the upgrade of the memory. Memtest+ doesn't find any
> problems and as long as I don't unzip the files on the NFS server, the
> desktop works seemingly fine (for more than 24h now, doing the usual low
> intensity stuff, but my home directory is NFS mounted and I can write
> large files to the NFS server as well - let me try reading, after I
> complete this e-mail ;-) .
> 
> Hardware: Asus M2R32-MVP motherboard (ATI CrossFire Xpress 3200 / ATI
> SB600 chipset) with Athlon 64 X2 4600+ CPU and Marvell 88E8001 LAN
> controller on MB (autoneg. to 1000Mbps).
> Software: Ubuntu 8.04.1, Kernel 2.6.27 and 2.6.27.7 (config based on
> Ubuntu 8.04), most recent stable AMI BIOS 10/2007 iirc.
> 
> --8<--
> 
> gthomsen@corfu:~$ lspci
> 00:00.0 Host bridge: ATI Technologies Inc RD580 [CrossFire Xpress 3200] Chipset Host Bridge
> 00:02.0 PCI bridge: ATI Technologies Inc RS480 PCI-X Root Port
> 00:05.0 PCI bridge: ATI Technologies Inc RS480 PCI Bridge
> 00:12.0 SATA controller: ATI Technologies Inc SB600 Non-Raid-5 SATA
> 00:13.0 USB Controller: ATI Technologies Inc SB600 USB (OHCI0)
> 00:13.1 USB Controller: ATI Technologies Inc SB600 USB (OHCI1)
> 00:13.2 USB Controller: ATI Technologies Inc SB600 USB (OHCI2)
> 00:13.3 USB Controller: ATI Technologies Inc SB600 USB (OHCI3)
> 00:13.4 USB Controller: ATI Technologies Inc SB600 USB (OHCI4)
> 00:13.5 USB Controller: ATI Technologies Inc SB600 USB Controller (EHCI)
> 00:14.0 SMBus: ATI Technologies Inc SBx00 SMBus Controller (rev 13)
> 00:14.1 IDE interface: ATI Technologies Inc SB600 IDE
> 00:14.2 Audio device: ATI Technologies Inc SBx00 Azalia
> 00:14.3 ISA bridge: ATI Technologies Inc SB600 PCI to LPC Bridge
> 00:14.4 PCI bridge: ATI Technologies Inc SBx00 PCI to PCI Bridge
> 00:18.0 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] HyperTransport Technology Configuration
> 00:18.1 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Address Map
> 00:18.2 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] DRAM Controller
> 00:18.3 Host bridge: Advanced Micro Devices [AMD] K8 [Athlon64/Opteron] Miscellaneous Control
> 01:00.0 VGA compatible controller: ATI Technologies Inc RV530 [Radeon X1600]
> 01:00.1 Display controller: ATI Technologies Inc RV530 [Radeon X1600] (Secondary)
> 02:00.0 SATA controller: JMicron Technologies, Inc. JMicron 20360/20363 AHCI Controller (rev 02)
> 03:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Gigabit Ethernet Controller (rev 13)
> -->8--
> 
> 
> --8<--
> Nov 24 10:04:50 corfu syslogd 1.5.0#1ubuntu1: restart.
> Nov 24 10:04:50 corfu kernel: Inspecting /boot/System.map-2.6.27.7
> Nov 24 10:04:50 corfu kernel: Inspecting /boot/System.map
> Nov 24 10:04:50 corfu kernel: Cannot find map file.
> Nov 24 10:04:50 corfu kernel: Loaded 26832 symbols from 56 modules.
> Nov 24 10:04:50 corfu kernel: [    0.000000] Initializing cgroup subsys cpuset
> Nov 24 10:04:50 corfu kernel: [    0.000000] Linux version 2.6.27.7 (root@corfu) (gcc version 4.2.4 (Ubuntu 4.2.4-1ubuntu3)) #4 SMP Mon Nov 24 16:36:49 PST 2008
> Nov 24 10:04:50 corfu kernel: [    0.000000] Command line: root=/dev/sda9 ro  
> Nov 24 10:04:50 corfu kernel: [    0.000000] KERNEL supported cpus:
> Nov 24 10:04:50 corfu kernel: [    0.000000]   Intel GenuineIntel
> Nov 24 10:04:50 corfu kernel: [    0.000000]   AMD AuthenticAMD
> Nov 24 10:04:50 corfu kernel: [    0.000000]   Centaur CentaurHauls
> Nov 24 10:04:50 corfu kernel: [    0.000000] BIOS-provided physical RAM map:
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 0000000000100000 - 00000000cffb0000 (usable)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 00000000cffb0000 - 00000000cffbe000 (ACPI data)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 00000000cffbe000 - 00000000cffe0000 (ACPI NVS)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 00000000cffe0000 - 00000000d0000000 (reserved)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 00000000ff700000 - 0000000100000000 (reserved)
> Nov 24 10:04:50 corfu kernel: [    0.000000]  BIOS-e820: 0000000100000000 - 0000000230000000 (usable)
> Nov 24 10:04:50 corfu kernel: [    0.000000] DMI 2.3 present.
> Nov 24 10:04:50 corfu kernel: [    0.000000] AMI BIOS detected: BIOS may corrupt low RAM, working it around.
> Nov 24 10:04:50 corfu kernel: [    0.000000] last_pfn = 0x230000 max_arch_pfn = 0x3ffffffff
> Nov 24 10:04:50 corfu kernel: [    0.000000] x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
> Nov 24 10:04:50 corfu kernel: [    0.000000] last_pfn = 0xcffb0 max_arch_pfn = 0x3ffffffff
> Nov 24 10:04:50 corfu kernel: [    0.000000] init_memory_mapping
> Nov 24 10:04:50 corfu kernel: [    0.000000]  0000000000 - 00cfe00000 page 2M
> Nov 24 10:04:50 corfu kernel: [    0.000000]  00cfe00000 - 00cffb0000 page 4k
> Nov 24 10:04:50 corfu kernel: [    0.000000] kernel direct mapping tables up to cffb0000 @ 10000-16000
> Nov 24 10:04:50 corfu kernel: [    0.000000] last_map_addr: cffb0000 end: cffb0000
> Nov 24 10:04:50 corfu kernel: [    0.000000] init_memory_mapping
> Nov 24 10:04:50 corfu kernel: [    0.000000]  0100000000 - 0230000000 page 2M
> Nov 24 10:04:50 corfu kernel: [    0.000000] kernel direct mapping tables up to 230000000 @ 14000-1e000
> Nov 24 10:04:50 corfu kernel: [    0.000000] last_map_addr: 230000000 end: 230000000
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: RSDP 000FB8B0, 0024 (r2 ACPIAM)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: XSDT CFFB0100, 004C (r1 A_M_I_ OEMXSDT  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: FACP CFFB0290, 00F4 (r3 A_M_I_ OEMFACP  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: DSDT CFFB0440, 7CA3 (r1  A0578 A0578000        0 INTL 20060113)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: FACS CFFBE000, 0040
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: APIC CFFB0390, 006C (r1 A_M_I_ OEMAPIC  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: MCFG CFFB0400, 003C (r1 A_M_I_ OEMMCFG  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: OEMB CFFBE040, 0060 (r1 A_M_I_ AMI_OEM  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: HPET CFFB80F0, 0038 (r1 A_M_I_ OEMHPET  10000730 MSFT       97)
> Nov 24 10:04:50 corfu kernel: [    0.000000] Scanning NUMA topology in Northbridge 24
> Nov 24 10:04:50 corfu kernel: [    0.000000] No NUMA configuration found
> Nov 24 10:04:50 corfu kernel: [    0.000000] Faking a node at 0000000000000000-0000000230000000
> Nov 24 10:04:50 corfu kernel: [    0.000000] Bootmem setup node 0 0000000000000000-0000000230000000
> Nov 24 10:04:50 corfu kernel: [    0.000000]   NODE_DATA [0000000000019000 - 000000000001afff]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   bootmap [000000000001b000 -  0000000000060fff] pages 46
> Nov 24 10:04:50 corfu kernel: [    0.000000] (6 early reservations) ==> bootmem [0000000000 - 0230000000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #2 [0000200000 - 00006c7c54]    TEXT DATA BSS ==> [0000200000 - 00006c7c54]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #3 [000009fc00 - 0000100000]    BIOS reserved ==> [000009fc00 - 0000100000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #4 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 - 0000014000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]   #5 [0000014000 - 0000019000]          PGTABLE ==> [0000014000 - 0000019000]
> Nov 24 10:04:50 corfu kernel: [    0.000000]  [ffffe20000000000-ffffe20007bfffff] PMD -> [ffff880028200000-ffff88002f3fffff] on node 0
> Nov 24 10:04:50 corfu kernel: [    0.000000] Zone PFN ranges:
> Nov 24 10:04:50 corfu kernel: [    0.000000]   DMA      0x00000010 -> 0x00001000
> Nov 24 10:04:50 corfu kernel: [    0.000000]   DMA32    0x00001000 -> 0x00100000
> Nov 24 10:04:50 corfu kernel: [    0.000000]   Normal   0x00100000 -> 0x00230000
> Nov 24 10:04:50 corfu kernel: [    0.000000] Movable zone start PFN for each node
> Nov 24 10:04:50 corfu kernel: [    0.000000] early_node_map[3] active PFN ranges
> Nov 24 10:04:50 corfu kernel: [    0.000000]     0: 0x00000010 -> 0x0000009f
> Nov 24 10:04:50 corfu kernel: [    0.000000]     0: 0x00000100 -> 0x000cffb0
> Nov 24 10:04:50 corfu kernel: [    0.000000]     0: 0x00100000 -> 0x00230000
> Nov 24 10:04:50 corfu kernel: [    0.000000] On node 0 totalpages: 2096959
> Nov 24 10:04:50 corfu kernel: [    0.000000]   DMA zone: 2596 pages, LIFO batch:0
> Nov 24 10:04:50 corfu kernel: [    0.000000]   DMA32 zone: 833512 pages, LIFO batch:31
> Nov 24 10:04:50 corfu kernel: [    0.000000]   Normal zone: 1228160 pages, LIFO batch:31
> Nov 24 10:04:50 corfu kernel: [    0.000000] Detected use of extended apic ids on hypertransport bus
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: PM-Timer IO Port: 0x808
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: Local APIC address 0xfee00000
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x01] enabled)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x82] disabled)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: LAPIC (acpi_id[0x04] lapic_id[0x83] disabled)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
> Nov 24 10:04:50 corfu kernel: [    0.000000] IOAPIC[0]: apic_id 2, version 0, address 0xfec00000, GSI 0-23
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: IRQ0 used by override.
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: IRQ2 used by override.
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: IRQ9 used by override.
> Nov 24 10:04:50 corfu kernel: [    0.000000] Setting APIC routing to flat
> Nov 24 10:04:50 corfu kernel: [    0.000000] ACPI: HPET id: 0x8300 base: 0xfed00000
> Nov 24 10:04:50 corfu kernel: [    0.000000] SMP: Allowing 4 CPUs, 2 hotplug CPUs
> Nov 24 10:04:50 corfu kernel: [    0.000000] Allocating PCI resources starting at d4000000 (gap: d0000000:2f700000)
> Nov 24 10:04:50 corfu kernel: [    0.000000] PERCPU: Allocating 47072 bytes of per cpu data
> Nov 24 10:04:50 corfu kernel: [    0.000000] NR_CPUS: 8, nr_cpu_ids: 4, nr_node_ids 1
> Nov 24 10:04:50 corfu kernel: [    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2064268
> Nov 24 10:04:50 corfu kernel: [    0.000000] Policy zone: Normal
> Nov 24 10:04:50 corfu kernel: [    0.000000] Kernel command line: root=/dev/sda9 ro  
> Nov 24 10:04:50 corfu kernel: [    0.000000] Initializing CPU#0
> Nov 24 10:04:50 corfu kernel: [    0.000000] PID hash table entries: 4096 (order: 12, 32768 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.000000] Extended CMOS year: 2000
> Nov 24 10:04:50 corfu kernel: [    0.000000] TSC: Unable to calibrate against PIT
> Nov 24 10:04:50 corfu kernel: [    0.000000] TSC: using PMTIMER reference calibration
> Nov 24 10:04:50 corfu kernel: [    0.000000] Detected 2405.444 MHz processor.
> Nov 24 10:04:50 corfu kernel: [    0.003333] Console: colour VGA+ 80x25
> Nov 24 10:04:50 corfu kernel: [    0.003333] console [tty0] enabled
> Nov 24 10:04:50 corfu kernel: [    0.003333] Checking aperture...
> Nov 24 10:04:50 corfu kernel: [    0.003333] No AGP bridge found
> Nov 24 10:04:50 corfu kernel: [    0.003333] Node 0: aperture @ 20000000 size 32 MB
> Nov 24 10:04:50 corfu kernel: [    0.003333] Aperture pointing to e820 RAM. Ignoring.
> Nov 24 10:04:50 corfu kernel: [    0.003333] Your BIOS doesn't leave a aperture memory hole
> Nov 24 10:04:50 corfu kernel: [    0.003333] Please enable the IOMMU option in the BIOS setup
> Nov 24 10:04:50 corfu kernel: [    0.003333] This costs you 64 MB of RAM
> Nov 24 10:04:50 corfu kernel: [    0.003333] Mapping aperture over 65536 KB of RAM @ 20000000
> Nov 24 10:04:50 corfu kernel: [    0.003333] Memory: 8200160k/9175040k available (2751k kernel code, 187676k reserved, 1258k data, 328k init)
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPA: page pool initialized 1 of 1 pages preallocated
> Nov 24 10:04:50 corfu kernel: [    0.003333] SLUB: Genslabs=13, HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
> Nov 24 10:04:50 corfu kernel: [    0.003333] hpet clockevent registered
> Nov 24 10:04:50 corfu kernel: [    0.003340] Calibrating delay loop (skipped), value calculated using timer frequency.. 4812.34 BogoMIPS (lpj=8018146)
> Nov 24 10:04:50 corfu kernel: [    0.003442] Security Framework initialized
> Nov 24 10:04:50 corfu kernel: [    0.003487] SELinux:  Disabled at boot.
> Nov 24 10:04:50 corfu kernel: [    0.004094] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.007653] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.010037] Mount-cache hash table entries: 256
> Nov 24 10:04:50 corfu kernel: [    0.010225] Initializing cgroup subsys cpuacct
> Nov 24 10:04:50 corfu kernel: [    0.010276] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> Nov 24 10:04:50 corfu kernel: [    0.010319] CPU: L2 Cache: 512K (64 bytes/line)
> Nov 24 10:04:50 corfu kernel: [    0.010362] CPU 0/0 -> Node 0
> Nov 24 10:04:50 corfu kernel: [    0.010404] tseg: 0000000000
> Nov 24 10:04:50 corfu kernel: [    0.010411] CPU: Physical Processor ID: 0
> Nov 24 10:04:50 corfu kernel: [    0.010452] CPU: Processor Core ID: 0
> Nov 24 10:04:50 corfu kernel: [    0.010499] using C1E aware idle routine
> Nov 24 10:04:50 corfu kernel: [    0.010553] ACPI: Core revision 20080609
> Nov 24 10:04:50 corfu kernel: [    0.018997] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
> Nov 24 10:04:50 corfu kernel: [    0.052643] CPU0: AMD Athlon(tm) 64 X2 Dual Core Processor 4600+ stepping 02
> Nov 24 10:04:50 corfu kernel: [    0.052760] Using local APIC timer interrupts.
> Nov 24 10:04:50 corfu kernel: [    0.053331] APIC timer calibration result 12528342
> Nov 24 10:04:50 corfu kernel: [    0.053332] Detected 12.528 MHz APIC timer.
> Nov 24 10:04:50 corfu kernel: [    0.053455] Booting processor 1/1 ip 6000
> Nov 24 10:04:50 corfu kernel: [    0.003333] Initializing CPU#1
> Nov 24 10:04:50 corfu kernel: [    0.003333] Calibrating delay using timer specific routine.. 4812.43 BogoMIPS (lpj=8018290)
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPU: L2 Cache: 512K (64 bytes/line)
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPU 1/1 -> Node 0
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPU: Physical Processor ID: 0
> Nov 24 10:04:50 corfu kernel: [    0.003333] CPU: Processor Core ID: 1
> Nov 24 10:04:50 corfu kernel: [    0.003333] x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
> Nov 24 10:04:50 corfu kernel: [    0.146959] CPU1: AMD Athlon(tm) 64 X2 Dual Core Processor 4600+ stepping 02
> Nov 24 10:04:50 corfu kernel: [    0.147417] Brought up 2 CPUs
> Nov 24 10:04:50 corfu kernel: [    0.147460] Total of 2 processors activated (9625.77 BogoMIPS).
> Nov 24 10:04:50 corfu kernel: [    0.147556] net_namespace: 1456 bytes
> Nov 24 10:04:50 corfu kernel: [    0.147556] NET: Registered protocol family 16
> Nov 24 10:04:50 corfu kernel: [    0.147556] No dock devices found.
> Nov 24 10:04:50 corfu kernel: [    0.147556] node 0 link 0: io port [1000, ffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] TOM: 00000000d0000000 aka 3328M
> Nov 24 10:04:50 corfu kernel: [    0.147556] node 0 link 0: mmio [e0000000, efffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] node 0 link 0: mmio [d0000000, dfffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] node 0 link 0: mmio [a0000, bffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] node 0 link 0: mmio [d0000000, ffffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] TOM2: 0000000230000000 aka 8960M
> Nov 24 10:04:50 corfu kernel: [    0.147556] bus: [00,07] on node 0 link 0
> Nov 24 10:04:50 corfu kernel: [    0.147556] bus: 00 index 0 io port: [0, ffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] bus: 00 index 1 mmio: [d0000000, ffffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] bus: 00 index 2 mmio: [a0000, bffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] bus: 00 index 3 mmio: [230000000, fcffffffff]
> Nov 24 10:04:50 corfu kernel: [    0.147556] ACPI: bus type pci registered
> Nov 24 10:04:50 corfu kernel: [    0.147556] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
> Nov 24 10:04:50 corfu kernel: [    0.147556] PCI: Not using MMCONFIG.
> Nov 24 10:04:50 corfu kernel: [    0.147556] PCI: Using configuration type 1 for base access
> Nov 24 10:04:50 corfu kernel: [    0.147556] ACPI: EC: Look up EC in DSDT
> Nov 24 10:04:50 corfu kernel: [    0.158197] ACPI: Interpreter enabled
> Nov 24 10:04:50 corfu kernel: [    0.158242] ACPI: (supports S0 S1 S3 S5)
> Nov 24 10:04:50 corfu kernel: [    0.158439] ACPI: Using IOAPIC for interrupt routing
> Nov 24 10:04:50 corfu kernel: [    0.158615] PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
> Nov 24 10:04:50 corfu kernel: [    0.162074] PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
> Nov 24 10:04:50 corfu kernel: [    0.167771] PCI: Using MMCONFIG at e0000000 - efffffff
> Nov 24 10:04:50 corfu kernel: [    0.175008] ACPI: PCI Root Bridge [PCI0] (0000:00)
> Nov 24 10:04:50 corfu kernel: [    0.175008] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
> Nov 24 10:04:50 corfu kernel: [    0.175008] pci 0000:00:02.0: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.175008] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
> Nov 24 10:04:50 corfu kernel: [    0.175008] pci 0000:00:05.0: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.176681] PCI: 0000:00:12.0 reg 10 io port: [b000, b007]
> Nov 24 10:04:50 corfu kernel: [    0.176688] PCI: 0000:00:12.0 reg 14 io port: [a000, a003]
> Nov 24 10:04:50 corfu kernel: [    0.176695] PCI: 0000:00:12.0 reg 18 io port: [9000, 9007]
> Nov 24 10:04:50 corfu kernel: [    0.176701] PCI: 0000:00:12.0 reg 1c io port: [8000, 8003]
> Nov 24 10:04:50 corfu kernel: [    0.176708] PCI: 0000:00:12.0 reg 20 io port: [7000, 700f]
> Nov 24 10:04:50 corfu kernel: [    0.176715] PCI: 0000:00:12.0 reg 24 32bit mmio: [fbcffc00, fbcfffff]
> Nov 24 10:04:50 corfu kernel: [    0.176741] pci 0000:00:12.0: set SATA to AHCI mode
> Nov 24 10:04:50 corfu kernel: [    0.176818] PCI: 0000:00:13.0 reg 10 32bit mmio: [fbcfe000, fbcfefff]
> Nov 24 10:04:50 corfu kernel: [    0.176891] PCI: 0000:00:13.1 reg 10 32bit mmio: [fbcfd000, fbcfdfff]
> Nov 24 10:04:50 corfu kernel: [    0.176964] PCI: 0000:00:13.2 reg 10 32bit mmio: [fbcfc000, fbcfcfff]
> Nov 24 10:04:50 corfu kernel: [    0.177038] PCI: 0000:00:13.3 reg 10 32bit mmio: [fbcfb000, fbcfbfff]
> Nov 24 10:04:50 corfu kernel: [    0.177111] PCI: 0000:00:13.4 reg 10 32bit mmio: [fbcfa000, fbcfafff]
> Nov 24 10:04:50 corfu kernel: [    0.177200] PCI: 0000:00:13.5 reg 10 32bit mmio: [fbcff800, fbcff8ff]
> Nov 24 10:04:50 corfu kernel: [    0.177250] pci 0000:00:13.5: supports D1
> Nov 24 10:04:50 corfu kernel: [    0.177251] pci 0000:00:13.5: supports D2
> Nov 24 10:04:50 corfu kernel: [    0.177253] pci 0000:00:13.5: PME# supported from D0 D1 D2 D3hot
> Nov 24 10:04:50 corfu kernel: [    0.177299] pci 0000:00:13.5: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.177370] PCI: 0000:00:14.0 reg 10 io port: [b00, b0f]
> Nov 24 10:04:50 corfu kernel: [    0.177377] PCI: 0000:00:14.0 reg 14 32bit mmio: [fed00000, fed003ff]
> Nov 24 10:04:50 corfu kernel: [    0.177444] PCI: 0000:00:14.1 reg 10 io port: [0, 7]
> Nov 24 10:04:50 corfu kernel: [    0.177450] PCI: 0000:00:14.1 reg 14 io port: [0, 3]
> Nov 24 10:04:50 corfu kernel: [    0.177457] PCI: 0000:00:14.1 reg 18 io port: [0, 7]
> Nov 24 10:04:50 corfu kernel: [    0.177464] PCI: 0000:00:14.1 reg 1c io port: [0, 3]
> Nov 24 10:04:50 corfu kernel: [    0.177471] PCI: 0000:00:14.1 reg 20 io port: [ff00, ff0f]
> Nov 24 10:04:50 corfu kernel: [    0.177538] PCI: 0000:00:14.2 reg 10 64bit mmio: [fbcf4000, fbcf7fff]
> Nov 24 10:04:50 corfu kernel: [    0.177581] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
> Nov 24 10:04:50 corfu kernel: [    0.177627] pci 0000:00:14.2: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.177846] PCI: 0000:01:00.0 reg 10 64bit mmio: [d0000000, dfffffff]
> Nov 24 10:04:50 corfu kernel: [    0.177854] PCI: 0000:01:00.0 reg 18 64bit mmio: [fbdf0000, fbdfffff]
> Nov 24 10:04:50 corfu kernel: [    0.177859] PCI: 0000:01:00.0 reg 20 io port: [c000, c0ff]
> Nov 24 10:04:50 corfu kernel: [    0.177867] PCI: 0000:01:00.0 reg 30 32bit mmio: [fbdc0000, fbddffff]
> Nov 24 10:04:50 corfu kernel: [    0.177880] pci 0000:01:00.0: supports D1
> Nov 24 10:04:50 corfu kernel: [    0.177881] pci 0000:01:00.0: supports D2
> Nov 24 10:04:50 corfu kernel: [    0.177902] PCI: 0000:01:00.1 reg 10 64bit mmio: [fbde0000, fbdeffff]
> Nov 24 10:04:50 corfu kernel: [    0.177928] pci 0000:01:00.1: supports D1
> Nov 24 10:04:50 corfu kernel: [    0.177930] pci 0000:01:00.1: supports D2
> Nov 24 10:04:50 corfu kernel: [    0.177976] PCI: bridge 0000:00:02.0 io port: [c000, cfff]
> Nov 24 10:04:50 corfu kernel: [    0.177979] PCI: bridge 0000:00:02.0 32bit mmio: [fbd00000, fbdfffff]
> Nov 24 10:04:50 corfu kernel: [    0.177983] PCI: bridge 0000:00:02.0 64bit mmio pref: [d0000000, dfffffff]
> Nov 24 10:04:50 corfu kernel: [    0.178033] PCI: 0000:02:00.0 reg 10 io port: [dc00, dc07]
> Nov 24 10:04:50 corfu kernel: [    0.178041] PCI: 0000:02:00.0 reg 14 io port: [d880, d883]
> Nov 24 10:04:50 corfu kernel: [    0.178050] PCI: 0000:02:00.0 reg 18 io port: [d800, d807]
> Nov 24 10:04:50 corfu kernel: [    0.178058] PCI: 0000:02:00.0 reg 1c io port: [d480, d483]
> Nov 24 10:04:50 corfu kernel: [    0.178066] PCI: 0000:02:00.0 reg 20 io port: [d400, d40f]
> Nov 24 10:04:50 corfu kernel: [    0.178075] PCI: 0000:02:00.0 reg 24 32bit mmio: [fbefe000, fbefffff]
> Nov 24 10:04:50 corfu kernel: [    0.178103] pci 0000:02:00.0: PME# supported from D3hot
> Nov 24 10:04:50 corfu kernel: [    0.178149] pci 0000:02:00.0: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.178232] PCI: bridge 0000:00:05.0 io port: [d000, dfff]
> Nov 24 10:04:50 corfu kernel: [    0.178235] PCI: bridge 0000:00:05.0 32bit mmio: [fbe00000, fbefffff]
> Nov 24 10:04:50 corfu kernel: [    0.178296] PCI: 0000:03:04.0 reg 10 32bit mmio: [fbffc000, fbffffff]
> Nov 24 10:04:50 corfu kernel: [    0.178304] PCI: 0000:03:04.0 reg 14 io port: [e800, e8ff]
> Nov 24 10:04:50 corfu kernel: [    0.178339] PCI: 0000:03:04.0 reg 30 32bit mmio: [fbfc0000, fbfdffff]
> Nov 24 10:04:50 corfu kernel: [    0.178359] pci 0000:03:04.0: supports D1
> Nov 24 10:04:50 corfu kernel: [    0.178360] pci 0000:03:04.0: supports D2
> Nov 24 10:04:50 corfu kernel: [    0.178362] pci 0000:03:04.0: PME# supported from D0 D1 D2 D3hot D3cold
> Nov 24 10:04:50 corfu kernel: [    0.178408] pci 0000:03:04.0: PME# disabled
> Nov 24 10:04:50 corfu kernel: [    0.178494] pci 0000:00:14.4: transparent bridge
> Nov 24 10:04:50 corfu kernel: [    0.178539] PCI: bridge 0000:00:14.4 io port: [e000, efff]
> Nov 24 10:04:50 corfu kernel: [    0.178543] PCI: bridge 0000:00:14.4 32bit mmio: [fbf00000, fbffffff]
> Nov 24 10:04:50 corfu kernel: [    0.178563] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
> Nov 24 10:04:50 corfu kernel: [    0.178819] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE2._PRT]
> Nov 24 10:04:50 corfu kernel: [    0.178927] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCE5._PRT]
> Nov 24 10:04:50 corfu kernel: [    0.179048] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.BR10._PRT]
> Nov 24 10:04:50 corfu kernel: [    0.196846] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.197413] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.198060] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.198707] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.199354] ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.200487] ACPI: PCI Interrupt Link [LNKF] (IRQs 9) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.200838] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.201485] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 7 10 11 12 14 15) *0, disabled.
> Nov 24 10:04:50 corfu kernel: [    0.202056] ACPI Warning (tbutils-0217): Incorrect checksum in table [OEMB] - 78, should be 6F [20080609]
> Nov 24 10:04:50 corfu kernel: [    0.202056] Linux Plug and Play Support v0.97 (c) Adam Belay
> Nov 24 10:04:50 corfu kernel: [    0.202056] pnp: PnP ACPI init
> Nov 24 10:04:50 corfu kernel: [    0.202056] ACPI: bus type pnp registered
> Nov 24 10:04:50 corfu kernel: [    0.204233] pnp: PnP ACPI: found 15 devices
> Nov 24 10:04:50 corfu kernel: [    0.204233] ACPI: ACPI bus type pnp unregistered
> Nov 24 10:04:50 corfu kernel: [    0.206711] SCSI subsystem initialized
> Nov 24 10:04:50 corfu kernel: [    0.206721] libata version 3.00 loaded.
> Nov 24 10:04:50 corfu kernel: [    0.206721] PCI: Using ACPI for IRQ routing
> Nov 24 10:04:50 corfu kernel: [    0.220135] PCI-DMA: Disabling AGP.
> Nov 24 10:04:50 corfu kernel: [    0.220274] PCI-DMA: aperture base @ 20000000 size 65536 KB
> Nov 24 10:04:50 corfu kernel: [    0.220751] PCI-DMA: using GART IOMMU.
> Nov 24 10:04:50 corfu kernel: [    0.220795] PCI-DMA: Reserving 64MB of IOMMU area in the AGP aperture
> Nov 24 10:04:50 corfu kernel: [    0.221236] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
> Nov 24 10:04:50 corfu kernel: [    0.221468] hpet0: 4 32-bit timers, 14318180 Hz
> Nov 24 10:04:50 corfu kernel: [    0.223332] Switched to high resolution mode on CPU 0
> Nov 24 10:04:50 corfu kernel: [    0.223577] Switched to high resolution mode on CPU 1
> Nov 24 10:04:50 corfu kernel: [    0.230044] system 00:06: ioport range 0x4d0-0x4d1 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230088] system 00:06: ioport range 0x40b-0x40b has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230132] system 00:06: ioport range 0x4d6-0x4d6 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230176] system 00:06: ioport range 0xc00-0xc01 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230220] system 00:06: ioport range 0xc14-0xc14 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230264] system 00:06: ioport range 0xc50-0xc51 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230308] system 00:06: ioport range 0xc52-0xc52 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230352] system 00:06: ioport range 0xc6c-0xc6c has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230396] system 00:06: ioport range 0xc6f-0xc6f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230444] system 00:06: ioport range 0xcd0-0xcd1 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230488] system 00:06: ioport range 0xcd2-0xcd3 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230532] system 00:06: ioport range 0xcd4-0xcd5 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230576] system 00:06: ioport range 0xcd6-0xcd7 has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230620] system 00:06: ioport range 0xcd8-0xcdf has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230664] system 00:06: ioport range 0x800-0x89f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230707] system 00:06: ioport range 0xb10-0xb1f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230752] system 00:06: ioport range 0x900-0x90f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230797] system 00:06: ioport range 0x910-0x91f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230841] system 00:06: ioport range 0xfe00-0xfefe has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.230887] system 00:06: iomem range 0xffb80000-0xffbfffff could not be reserved
> Nov 24 10:04:50 corfu kernel: [    0.230935] system 00:06: iomem range 0xfff00000-0xffffffff could not be reserved
> Nov 24 10:04:50 corfu kernel: [    0.230985] system 00:06: iomem range 0xff600000-0xff60ffff has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231034] system 00:0a: iomem range 0xfec00000-0xfec00fff has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231078] system 00:0a: iomem range 0xfee00000-0xfee00fff has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231126] system 00:0c: ioport range 0xe00-0xe0f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231170] system 00:0c: ioport range 0xe80-0xe8f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231214] system 00:0c: ioport range 0xf40-0xf4f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231258] system 00:0c: ioport range 0xa30-0xa3f has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231304] system 00:0d: iomem range 0xe0000000-0xefffffff has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231352] system 00:0e: iomem range 0x0-0x9ffff could not be reserved
> Nov 24 10:04:50 corfu kernel: [    0.231395] system 00:0e: iomem range 0xc0000-0xcffff has been reserved
> Nov 24 10:04:50 corfu kernel: [    0.231439] system 00:0e: iomem range 0xe0000-0xfffff could not be reserved
> Nov 24 10:04:50 corfu kernel: [    0.231483] system 00:0e: iomem range 0x100000-0xcfffffff could not be reserved
> Nov 24 10:04:50 corfu kernel: [    0.236652] pci 0000:00:02.0: PCI bridge, secondary bus 0000:01
> Nov 24 10:04:50 corfu kernel: [    0.236710] pci 0000:00:02.0:   IO window: 0xc000-0xcfff
> Nov 24 10:04:50 corfu kernel: [    0.236754] pci 0000:00:02.0:   MEM window: 0xfbd00000-0xfbdfffff
> Nov 24 10:04:50 corfu kernel: [    0.236799] pci 0000:00:02.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff
> Nov 24 10:04:50 corfu kernel: [    0.236848] pci 0000:00:05.0: PCI bridge, secondary bus 0000:02
> Nov 24 10:04:50 corfu kernel: [    0.236892] pci 0000:00:05.0:   IO window: 0xd000-0xdfff
> Nov 24 10:04:50 corfu kernel: [    0.236935] pci 0000:00:05.0:   MEM window: 0xfbe00000-0xfbefffff
> Nov 24 10:04:50 corfu kernel: [    0.236979] pci 0000:00:05.0:   PREFETCH window: disabled
> Nov 24 10:04:50 corfu kernel: [    0.237024] pci 0000:00:14.4: PCI bridge, secondary bus 0000:03
> Nov 24 10:04:50 corfu kernel: [    0.237069] pci 0000:00:14.4:   IO window: 0xe000-0xefff
> Nov 24 10:04:50 corfu kernel: [    0.237119] pci 0000:00:14.4:   MEM window: 0xfbf00000-0xfbffffff
> Nov 24 10:04:50 corfu kernel: [    0.237165] pci 0000:00:14.4:   PREFETCH window: 0x000000f0000000-0x000000f00fffff
> Nov 24 10:04:50 corfu kernel: [    0.237223] pci 0000:00:02.0: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    0.237228] pci 0000:00:05.0: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    0.237234] bus: 00 index 0 io port: [0, ffff]
> Nov 24 10:04:50 corfu kernel: [    0.237277] bus: 00 index 1 mmio: [0, ffffffffffffffff]
> Nov 24 10:04:50 corfu kernel: [    0.237320] bus: 01 index 0 io port: [c000, cfff]
> Nov 24 10:04:50 corfu kernel: [    0.237363] bus: 01 index 1 mmio: [fbd00000, fbdfffff]
> Nov 24 10:04:50 corfu kernel: [    0.237405] bus: 01 index 2 mmio: [d0000000, dfffffff]
> Nov 24 10:04:50 corfu kernel: [    0.237448] bus: 01 index 3 mmio: [0, 0]
> Nov 24 10:04:50 corfu kernel: [    0.237491] bus: 02 index 0 io port: [d000, dfff]
> Nov 24 10:04:50 corfu kernel: [    0.237533] bus: 02 index 1 mmio: [fbe00000, fbefffff]
> Nov 24 10:04:50 corfu kernel: [    0.237576] bus: 02 index 2 mmio: [0, 0]
> Nov 24 10:04:50 corfu kernel: [    0.237618] bus: 02 index 3 mmio: [0, 0]
> Nov 24 10:04:50 corfu kernel: [    0.237661] bus: 03 index 0 io port: [e000, efff]
> Nov 24 10:04:50 corfu kernel: [    0.237704] bus: 03 index 1 mmio: [fbf00000, fbffffff]
> Nov 24 10:04:50 corfu kernel: [    0.237747] bus: 03 index 2 mmio: [f0000000, f00fffff]
> Nov 24 10:04:50 corfu kernel: [    0.237789] bus: 03 index 3 io port: [0, ffff]
> Nov 24 10:04:50 corfu kernel: [    0.237832] bus: 03 index 4 mmio: [0, ffffffffffffffff]
> Nov 24 10:04:50 corfu kernel: [    0.237883] NET: Registered protocol family 2
> Nov 24 10:04:50 corfu kernel: [    0.270188] IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.271564] TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.276088] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.276751] TCP: Hash tables configured (established 524288 bind 65536)
> Nov 24 10:04:50 corfu kernel: [    0.276796] TCP reno registered
> Nov 24 10:04:50 corfu kernel: [    0.286745] NET: Registered protocol family 1
> Nov 24 10:04:50 corfu kernel: [    0.288628] audit: initializing netlink socket (disabled)
> Nov 24 10:04:50 corfu kernel: [    0.288679] type=2000 audit(1227549875.286:1): initialized
> Nov 24 10:04:50 corfu kernel: [    0.293269] VFS: Disk quotas dquot_6.5.1
> Nov 24 10:04:50 corfu kernel: [    0.293372] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
> Nov 24 10:04:50 corfu kernel: [    0.293805] msgmni has been set to 16015
> Nov 24 10:04:50 corfu kernel: [    0.293929] io scheduler noop registered
> Nov 24 10:04:50 corfu kernel: [    0.293972] io scheduler anticipatory registered
> Nov 24 10:04:50 corfu kernel: [    0.294014] io scheduler deadline registered
> Nov 24 10:04:50 corfu kernel: [    0.294173] io scheduler cfq registered (default)
> Nov 24 10:04:50 corfu kernel: [    0.450042] pci 0000:01:00.0: Boot video device
> Nov 24 10:04:50 corfu kernel: [    0.450145] pcieport-driver 0000:00:02.0: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    0.450166] pcieport-driver 0000:00:02.0: found MSI capability
> Nov 24 10:04:50 corfu kernel: [    0.450230] pci_express 0000:00:02.0:pcie00: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.450280] pci_express 0000:00:02.0:pcie01: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.450325] pci_express 0000:00:02.0:pcie03: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.450406] pcieport-driver 0000:00:05.0: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    0.450431] pcieport-driver 0000:00:05.0: found MSI capability
> Nov 24 10:04:50 corfu kernel: [    0.450491] pci_express 0000:00:05.0:pcie00: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.450541] pci_express 0000:00:05.0:pcie01: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.450589] pci_express 0000:00:05.0:pcie03: allocate port service
> Nov 24 10:04:50 corfu kernel: [    0.452281] aer 0000:00:02.0:pcie01: AER service couldn't init device: no _OSC support
> Nov 24 10:04:50 corfu kernel: [    0.453816] aer 0000:00:05.0:pcie01: AER service couldn't init device: no _OSC support
> Nov 24 10:04:50 corfu kernel: [    0.483716] hpet_resources: 0xfed00000 is busy
> Nov 24 10:04:50 corfu kernel: [    0.483782] Linux agpgart interface v0.103
> Nov 24 10:04:50 corfu kernel: [    0.483827] Serial: 8250/16550 driver4 ports, IRQ sharing enabled
> Nov 24 10:04:50 corfu kernel: [    0.484012] serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Nov 24 10:04:50 corfu kernel: [    0.484676] 00:0b: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Nov 24 10:04:50 corfu kernel: [    0.486254] brd: module loaded
> Nov 24 10:04:50 corfu kernel: [    0.486335] Driver 'sd' needs updating - please use bus_type methods
> Nov 24 10:04:50 corfu kernel: [    0.486424] ahci 0000:00:12.0: version 3.0
> Nov 24 10:04:50 corfu kernel: [    0.486440] ahci 0000:00:12.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
> Nov 24 10:04:50 corfu kernel: [    0.486500] ahci 0000:00:12.0: controller can't do 64bit DMA, forcing 32bit
> Nov 24 10:04:50 corfu kernel: [    0.486614] ahci 0000:00:12.0: AHCI 0001.0100 32 slots 4 ports 3 Gbps 0xf impl SATA mode
> Nov 24 10:04:50 corfu kernel: [    0.486663] ahci 0000:00:12.0: flags: ncq sntf ilck pm led clo pmp pio slum part 
> Nov 24 10:04:50 corfu kernel: [    0.486961] scsi0 : ahci
> Nov 24 10:04:50 corfu kernel: [    0.487303] scsi1 : ahci
> Nov 24 10:04:50 corfu kernel: [    0.487431] scsi2 : ahci
> Nov 24 10:04:50 corfu kernel: [    0.487551] scsi3 : ahci
> Nov 24 10:04:50 corfu kernel: [    0.487692] ata1: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd00 irq 21
> Nov 24 10:04:50 corfu kernel: [    0.487741] ata2: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffd80 irq 21
> Nov 24 10:04:50 corfu kernel: [    0.487790] ata3: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe00 irq 21
> Nov 24 10:04:50 corfu kernel: [    0.487839] ata4: SATA max UDMA/133 abar m1024@0xfbcffc00 port 0xfbcffe80 irq 21
> Nov 24 10:04:50 corfu kernel: [    0.806701] ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
> Nov 24 10:04:50 corfu kernel: [    0.850783] ata1.00: ATA-7: ST3320620AS, 3.AAE, max UDMA/133
> Nov 24 10:04:50 corfu kernel: [    0.850831] ata1.00: 625142448 sectors, multi 16: LBA48 NCQ (depth 31/32)
> Nov 24 10:04:50 corfu kernel: [    0.850879] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> Nov 24 10:04:50 corfu kernel: [    0.909084] ata1.00: SB600 AHCI: limiting to 255 sectors per cmd
> Nov 24 10:04:50 corfu kernel: [    0.909128] ata1.00: configured for UDMA/133
> Nov 24 10:04:50 corfu kernel: [    1.240030] ata2: SATA link down (SStatus 0 SControl 300)
> Nov 24 10:04:50 corfu kernel: [    1.573364] ata3: SATA link down (SStatus 0 SControl 300)
> Nov 24 10:04:50 corfu kernel: [    1.906696] ata4: SATA link down (SStatus 0 SControl 300)
> Nov 24 10:04:50 corfu kernel: [    1.920106] scsi 0:0:0:0: Direct-Access     ATA      ST3320620AS      3.AA PQ: 0 ANSI: 5
> Nov 24 10:04:50 corfu kernel: [    1.920312] sd 0:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
> Nov 24 10:04:50 corfu kernel: [    1.920367] sd 0:0:0:0: [sda] Write Protect is off
> Nov 24 10:04:50 corfu kernel: [    1.920411] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> Nov 24 10:04:50 corfu kernel: [    1.920431] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> Nov 24 10:04:50 corfu kernel: [    1.920523] sd 0:0:0:0: [sda] 625142448 512-byte hardware sectors (320073 MB)
> Nov 24 10:04:50 corfu kernel: [    1.920577] sd 0:0:0:0: [sda] Write Protect is off
> Nov 24 10:04:50 corfu kernel: [    1.920621] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
> Nov 24 10:04:50 corfu kernel: [    1.920639] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
> Nov 24 10:04:50 corfu kernel: [    1.920689]  sda: sda1 sda2 sda3 sda4 < sda5 sda6 sda7 sda8 sda9 sda10 sda11 >
> Nov 24 10:04:50 corfu kernel: [    2.010806]  sda1: <solaris: [s0] sda12 [s1] sda13 [s2] sda14 [s8] sda15 >
> Nov 24 10:04:50 corfu kernel: [    2.011935] sd 0:0:0:0: [sda] Attached SCSI disk
> Nov 24 10:04:50 corfu kernel: [    2.012067] ahci 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> Nov 24 10:04:50 corfu kernel: [    2.023782] ahci 0000:02:00.0: AHCI 0001.0000 32 slots 1 ports 3 Gbps 0x1 impl SATA mode
> Nov 24 10:04:50 corfu kernel: [    2.023830] ahci 0000:02:00.0: flags: 64bit ncq pm led clo pmp pio slum part 
> Nov 24 10:04:50 corfu kernel: [    2.023877] ahci 0000:02:00.0: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    2.023985] scsi4 : ahci
> Nov 24 10:04:50 corfu kernel: [    2.024100] ata5: SATA max UDMA/133 abar m8192@0xfbefe000 port 0xfbefe100 irq 17
> Nov 24 10:04:50 corfu kernel: [    2.343365] ata5: SATA link down (SStatus 0 SControl 300)
> Nov 24 10:04:50 corfu kernel: [    2.356743] pata_atiixp 0000:00:14.1: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> Nov 24 10:04:50 corfu kernel: [    2.356814] pata_atiixp 0000:00:14.1: setting latency timer to 64
> Nov 24 10:04:50 corfu kernel: [    2.356886] scsi5 : pata_atiixp
> Nov 24 10:04:50 corfu kernel: [    2.357017] scsi6 : pata_atiixp
> Nov 24 10:04:50 corfu kernel: [    2.358317] ata6: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xff00 irq 14
> Nov 24 10:04:50 corfu kernel: [    2.358362] ata7: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xff08 irq 15
> Nov 24 10:04:50 corfu kernel: [    2.517195] ata6.00: ATAPI: DVD RW DRU-820A, 1.0b, max UDMA/66
> Nov 24 10:04:50 corfu kernel: [    2.530467] ata6.00: configured for UDMA/66
> Nov 24 10:04:50 corfu kernel: [    2.684808] scsi 5:0:0:0: CD-ROM            SONY     DVD RW DRU-820A  1.0b PQ: 0 ANSI: 5
> Nov 24 10:04:50 corfu kernel: [    2.685090] PNP: PS/2 Controller [PNP0303:PS2K,PNP0f03:PS2M] at 0x60,0x64 irq 1,12
> Nov 24 10:04:50 corfu kernel: [    2.685492] serio: i8042 KBD port at 0x60,0x64 irq 1
> Nov 24 10:04:50 corfu kernel: [    2.685537] serio: i8042 AUX port at 0x60,0x64 irq 12
> Nov 24 10:04:50 corfu kernel: [    2.685729] mice: PS/2 mouse device common for all mice
> Nov 24 10:04:50 corfu kernel: [    2.685817] cpuidle: using governor ladder
> Nov 24 10:04:50 corfu kernel: [    2.685859] cpuidle: using governor menu
> Nov 24 10:04:50 corfu kernel: [    2.686142] registered taskstats version 1
> Nov 24 10:04:50 corfu kernel: [    2.686316] drivers/rtc/hctosys.c: unable to open rtc device (rtc0)
> Nov 24 10:04:50 corfu kernel: [    2.686360] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
> Nov 24 10:04:50 corfu kernel: [    2.686403] EDD information not available.
> Nov 24 10:04:50 corfu kernel: [    2.704216] input: AT Translated Set 2 keyboard as /class/input/input0
> Nov 24 10:04:50 corfu kernel: [    2.809832] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    2.809881] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    2.809930] VFS: Mounted root (ext3 filesystem) readonly.
> Nov 24 10:04:50 corfu kernel: [    2.809983] Freeing unused kernel memory: 328k freed
> Nov 24 10:04:50 corfu kernel: [    5.418405] Floppy drive(s): fd0 is 1.44M
> Nov 24 10:04:50 corfu kernel: [    5.433841] FDC 0 is a post-1991 82077
> Nov 24 10:04:50 corfu kernel: [    5.442107] input: PC Speaker as /class/input/input1
> Nov 24 10:04:50 corfu kernel: [    5.482826] usbcore: registered new interface driver usbfs
> Nov 24 10:04:50 corfu kernel: [    5.482901] usbcore: registered new interface driver hub
> Nov 24 10:04:50 corfu kernel: [    5.482979] usbcore: registered new device driver usb
> Nov 24 10:04:50 corfu kernel: [    5.554715] Uniform Multi-Platform E-IDE driver
> Nov 24 10:04:50 corfu kernel: [    5.578452] sd 0:0:0:0: Attached scsi generic sg0 type 0
> Nov 24 10:04:50 corfu kernel: [    5.578533] scsi 5:0:0:0: Attached scsi generic sg1 type 5
> Nov 24 10:04:50 corfu kernel: [    5.611265] ACPI: duty_cycle spans bit 4
> Nov 24 10:04:50 corfu kernel: [    5.611361] processor ACPI0007:00: registered as cooling_device0
> Nov 24 10:04:50 corfu kernel: [    5.611487] processor ACPI0007:01: registered as cooling_device1
> Nov 24 10:04:50 corfu kernel: [    5.623421] input: Power Button (FF) as /class/input/input2
> Nov 24 10:04:50 corfu kernel: [    5.628025] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
> Nov 24 10:04:50 corfu kernel: [    5.651410] skge 0000:03:04.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
> Nov 24 10:04:50 corfu kernel: [    5.651508] skge 1.13 addr 0xfbffc000 irq 23 chip Yukon-Lite rev 9
> Nov 24 10:04:50 corfu kernel: [    5.651728] skge eth0: addr 00:18:f3:52:2e:d4
> Nov 24 10:04:50 corfu kernel: [    5.666776] ACPI: Power Button (FF) [PWRF]
> Nov 24 10:04:50 corfu kernel: [    5.666895] input: Power Button (CM) as /class/input/input3
> Nov 24 10:04:50 corfu kernel: [    5.675392] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
> Nov 24 10:04:50 corfu kernel: [    5.693202] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
> Nov 24 10:04:50 corfu kernel: [    5.693228] ohci_hcd 0000:00:13.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> Nov 24 10:04:50 corfu kernel: [    5.693288] ohci_hcd 0000:00:13.0: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    5.694869] ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 1
> Nov 24 10:04:50 corfu kernel: [    5.694943] ohci_hcd 0000:00:13.0: irq 16, io mem 0xfbcfe000
> Nov 24 10:04:50 corfu kernel: [    5.700914] skge eth0: enabling interface
> Nov 24 10:04:50 corfu kernel: [    5.706803] ACPI: Power Button (CM) [PWRB]
> Nov 24 10:04:50 corfu kernel: [    5.751239] usb usb1: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    5.751313] hub 1-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    5.751364] hub 1-0:1.0: 2 ports detected
> Nov 24 10:04:50 corfu kernel: [    5.757284] Warning! ehci_hcd should always be loaded before uhci_hcd and ohci_hcd, not after
> Nov 24 10:04:50 corfu kernel: [    5.800720] warning: `dhclient3' uses 32-bit capabilities (legacy support in use)
> Nov 24 10:04:50 corfu kernel: [    5.957456] usb usb1: New USB device found, idVendor=1d6b, idProduct=0001
> Nov 24 10:04:50 corfu kernel: [    5.957504] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    5.957552] usb usb1: Product: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    5.957595] usb usb1: Manufacturer: Linux 2.6.27.7 ohci_hcd
> Nov 24 10:04:50 corfu kernel: [    5.957637] usb usb1: SerialNumber: 0000:00:13.0
> Nov 24 10:04:50 corfu kernel: [    5.957723] ohci_hcd 0000:00:13.1: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> Nov 24 10:04:50 corfu kernel: [    5.957778] ohci_hcd 0000:00:13.1: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    5.957856] ohci_hcd 0000:00:13.1: new USB bus registered, assigned bus number 2
> Nov 24 10:04:50 corfu kernel: [    5.957920] ohci_hcd 0000:00:13.1: irq 17, io mem 0xfbcfd000
> Nov 24 10:04:50 corfu kernel: [    6.014160] usb usb2: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.014230] hub 2-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    6.014280] hub 2-0:1.0: 2 ports detected
> Nov 24 10:04:50 corfu kernel: [    6.086687] usb 1-2: new low speed USB device using ohci_hcd and address 2
> Nov 24 10:04:50 corfu kernel: [    6.220539] usb usb2: New USB device found, idVendor=1d6b, idProduct=0001
> Nov 24 10:04:50 corfu kernel: [    6.220585] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    6.220632] usb usb2: Product: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.220675] usb usb2: Manufacturer: Linux 2.6.27.7 ohci_hcd
> Nov 24 10:04:50 corfu kernel: [    6.220718] usb usb2: SerialNumber: 0000:00:13.1
> Nov 24 10:04:50 corfu kernel: [    6.220802] ohci_hcd 0000:00:13.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
> Nov 24 10:04:50 corfu kernel: [    6.220856] ohci_hcd 0000:00:13.2: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.220923] ohci_hcd 0000:00:13.2: new USB bus registered, assigned bus number 3
> Nov 24 10:04:50 corfu kernel: [    6.220991] ohci_hcd 0000:00:13.2: irq 18, io mem 0xfbcfc000
> Nov 24 10:04:50 corfu kernel: [    6.263230] usb 1-2: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.279719] usb 1-2: New USB device found, idVendor=046e, idProduct=52c4
> Nov 24 10:04:50 corfu kernel: [    6.279767] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> Nov 24 10:04:50 corfu kernel: [    6.279810] usb 1-2: Product: USB Multimedia Keyboard
> Nov 24 10:04:50 corfu kernel: [    6.279853] usb 1-2: Manufacturer: BTC
> Nov 24 10:04:50 corfu kernel: [    6.280310] usb usb3: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.300498] hub 3-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    6.300587] hub 3-0:1.0: 2 ports detected
> Nov 24 10:04:50 corfu kernel: [    6.403504] usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
> Nov 24 10:04:50 corfu kernel: [    6.403552] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    6.403599] usb usb3: Product: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.403643] usb usb3: Manufacturer: Linux 2.6.27.7 ohci_hcd
> Nov 24 10:04:50 corfu kernel: [    6.403686] usb usb3: SerialNumber: 0000:00:13.2
> Nov 24 10:04:50 corfu kernel: [    6.403780] ohci_hcd 0000:00:13.3: PCI INT B -> GSI 17 (level, low) -> IRQ 17
> Nov 24 10:04:50 corfu kernel: [    6.403834] ohci_hcd 0000:00:13.3: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.403902] ohci_hcd 0000:00:13.3: new USB bus registered, assigned bus number 4
> Nov 24 10:04:50 corfu kernel: [    6.403963] ohci_hcd 0000:00:13.3: irq 17, io mem 0xfbcfb000
> Nov 24 10:04:50 corfu kernel: [    6.407099] usb 2-1: new low speed USB device using ohci_hcd and address 2
> Nov 24 10:04:50 corfu kernel: [    6.460775] usb usb4: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.460843] hub 4-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    6.460892] hub 4-0:1.0: 2 ports detected
> Nov 24 10:04:50 corfu kernel: [    6.563844] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
> Nov 24 10:04:50 corfu kernel: [    6.563888] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    6.563936] usb usb4: Product: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.563979] usb usb4: Manufacturer: Linux 2.6.27.7 ohci_hcd
> Nov 24 10:04:50 corfu kernel: [    6.564022] usb usb4: SerialNumber: 0000:00:13.3
> Nov 24 10:04:50 corfu kernel: [    6.564108] ohci_hcd 0000:00:13.4: PCI INT C -> GSI 18 (level, low) -> IRQ 18
> Nov 24 10:04:50 corfu kernel: [    6.564160] ohci_hcd 0000:00:13.4: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.564224] ohci_hcd 0000:00:13.4: new USB bus registered, assigned bus number 5
> Nov 24 10:04:50 corfu kernel: [    6.564282] ohci_hcd 0000:00:13.4: irq 18, io mem 0xfbcfa000
> Nov 24 10:04:50 corfu kernel: [    6.565117] usb 2-1: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.567284] usb 2-1: New USB device found, idVendor=045e, idProduct=0040
> Nov 24 10:04:50 corfu kernel: [    6.567331] usb 2-1: New USB device strings: Mfr=1, Product=3, SerialNumber=0
> Nov 24 10:04:50 corfu kernel: [    6.567375] usb 2-1: Product: Microsoft 3-Button Mouse with IntelliEye(TM)
> Nov 24 10:04:50 corfu kernel: [    6.567418] usb 2-1: Manufacturer: Microsoft
> Nov 24 10:04:50 corfu kernel: [    6.567498] usbcore: registered new interface driver hiddev
> Nov 24 10:04:50 corfu kernel: [    6.579426] input: BTC USB Multimedia Keyboard as /class/input/input4
> Nov 24 10:04:50 corfu kernel: [    6.607162] input,hidraw0: USB HID v1.10 Keyboard [BTC USB Multimedia Keyboard] on usb-0000:00:13.0-2
> Nov 24 10:04:50 corfu kernel: [    6.621258] usb usb5: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.621339] hub 5-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    6.621390] hub 5-0:1.0: 2 ports detected
> Nov 24 10:04:50 corfu kernel: [    6.640226] input: BTC USB Multimedia Keyboard as /class/input/input5
> Nov 24 10:04:50 corfu kernel: [    6.660568] input,hiddev96,hidraw1: USB HID v1.10 Device [BTC USB Multimedia Keyboard] on usb-0000:00:13.0-2
> Nov 24 10:04:50 corfu kernel: [    6.665428] input: Microsoft Microsoft 3-Button Mouse with IntelliEye(TM) as /class/input/input6
> Nov 24 10:04:50 corfu kernel: [    6.707173] input,hidraw2: USB HID v1.10 Mouse [Microsoft Microsoft 3-Button Mouse with IntelliEye(TM)] on usb-0000:00:13.1-1
> Nov 24 10:04:50 corfu kernel: [    6.707385] usbcore: registered new interface driver usbhid
> Nov 24 10:04:50 corfu kernel: [    6.707438] usbhid: v2.6:USB HID core driver
> Nov 24 10:04:50 corfu kernel: [    6.723972] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
> Nov 24 10:04:50 corfu kernel: [    6.724019] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    6.724067] usb usb5: Product: OHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.724110] usb usb5: Manufacturer: Linux 2.6.27.7 ohci_hcd
> Nov 24 10:04:50 corfu kernel: [    6.724153] usb usb5: SerialNumber: 0000:00:13.4
> Nov 24 10:04:50 corfu kernel: [    6.724296] ehci_hcd 0000:00:13.5: PCI INT D -> GSI 19 (level, low) -> IRQ 19
> Nov 24 10:04:50 corfu kernel: [    6.724351] ehci_hcd 0000:00:13.5: EHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.724418] ehci_hcd 0000:00:13.5: new USB bus registered, assigned bus number 6
> Nov 24 10:04:50 corfu kernel: [    6.724528] ehci_hcd 0000:00:13.5: debug port 1
> Nov 24 10:04:50 corfu kernel: [    6.724586] ehci_hcd 0000:00:13.5: irq 19, io mem 0xfbcff800
> Nov 24 10:04:50 corfu kernel: [    6.733773] ehci_hcd 0000:00:13.5: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
> Nov 24 10:04:50 corfu kernel: [    6.733998] usb usb6: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    6.734082] hub 6-0:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    6.734132] hub 6-0:1.0: 10 ports detected
> Nov 24 10:04:50 corfu kernel: [    6.843778] usb 1-2: USB disconnect, address 2
> Nov 24 10:04:50 corfu kernel: [    6.873789] NET: Registered protocol family 17
> Nov 24 10:04:50 corfu kernel: [    6.940573] usb usb6: New USB device found, idVendor=1d6b, idProduct=0002
> Nov 24 10:04:50 corfu kernel: [    6.940621] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
> Nov 24 10:04:50 corfu kernel: [    6.940668] usb usb6: Product: EHCI Host Controller
> Nov 24 10:04:50 corfu kernel: [    6.940712] usb usb6: Manufacturer: Linux 2.6.27.7 ehci_hcd
> Nov 24 10:04:50 corfu kernel: [    6.940754] usb usb6: SerialNumber: 0000:00:13.5
> Nov 24 10:04:50 corfu kernel: [    6.940864] HDA Intel 0000:00:14.2: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> Nov 24 10:04:50 corfu kernel: [    6.963233] hda_codec: Unknown model for AD1988, trying auto-probe from BIOS...
> Nov 24 10:04:50 corfu kernel: [    7.050025] usb 2-1: USB disconnect, address 2
> Nov 24 10:04:50 corfu kernel: [    7.339637] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
> Nov 24 10:04:50 corfu kernel: [    7.390289] Driver 'sr' needs updating - please use bus_type methods
> Nov 24 10:04:50 corfu kernel: [    7.400020] sr0: scsi3-mmc drive: 40x/40x writer dvd-ram cd/rw xa/form2 cdda tray
> Nov 24 10:04:50 corfu kernel: [    7.400073] Uniform CD-ROM driver Revision: 3.20
> Nov 24 10:04:50 corfu kernel: [    7.400221] sr 5:0:0:0: Attached scsi CD-ROM sr0
> Nov 24 10:04:50 corfu kernel: [    7.403780] usb 6-4: new high speed USB device using ehci_hcd and address 4
> Nov 24 10:04:50 corfu kernel: [    7.531892] usb 6-4: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    7.532052] hub 6-4:1.0: USB hub found
> Nov 24 10:04:50 corfu kernel: [    7.532155] hub 6-4:1.0: 4 ports detected
> Nov 24 10:04:50 corfu kernel: [    7.568427] fuse init (API version 7.9)
> Nov 24 10:04:50 corfu kernel: [    7.613298] it87: Found IT8716F chip at 0xe80, revision 0
> Nov 24 10:04:50 corfu kernel: [    7.613355] it87: in3 is VCC (+5V)
> Nov 24 10:04:50 corfu kernel: [    7.635049] usb 6-4: New USB device found, idVendor=0409, idProduct=005a
> Nov 24 10:04:50 corfu kernel: [    7.635052] usb 6-4: New USB device strings: Mfr=0, Product=0, SerialNumber=0
> Nov 24 10:04:50 corfu kernel: [    7.679115] Adding 3598520k swap on /dev/sda11.  Priority:-1 extents:1 across:3598520k
> Nov 24 10:04:50 corfu kernel: [    7.754526] EXT3 FS on sda9, internal journal
> Nov 24 10:04:50 corfu kernel: [    7.883353] usb 1-2: new low speed USB device using ohci_hcd and address 3
> Nov 24 10:04:50 corfu kernel: [    8.061799] usb 1-2: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    8.080510] input: BTC USB Multimedia Keyboard as /class/input/input7
> Nov 24 10:04:50 corfu kernel: [    8.120524] input,hidraw0: USB HID v1.10 Keyboard [BTC USB Multimedia Keyboard] on usb-0000:00:13.0-2
> Nov 24 10:04:50 corfu kernel: [    8.153270] input: BTC USB Multimedia Keyboard as /class/input/input8
> Nov 24 10:04:50 corfu kernel: [    8.190576] input,hiddev96,hidraw1: USB HID v1.10 Device [BTC USB Multimedia Keyboard] on usb-0000:00:13.0-2
> Nov 24 10:04:50 corfu kernel: [    8.194360] usb 1-2: New USB device found, idVendor=046e, idProduct=52c4
> Nov 24 10:04:50 corfu kernel: [    8.194363] usb 1-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
> Nov 24 10:04:50 corfu kernel: [    8.194365] usb 1-2: Product: USB Multimedia Keyboard
> Nov 24 10:04:50 corfu kernel: [    8.194366] usb 1-2: Manufacturer: BTC
> Nov 24 10:04:50 corfu kernel: [    8.443766] usb 2-1: new low speed USB device using ohci_hcd and address 3
> Nov 24 10:04:50 corfu kernel: [    8.602243] usb 2-1: configuration #1 chosen from 1 choice
> Nov 24 10:04:50 corfu kernel: [    8.609428] input: Microsoft Microsoft 3-Button Mouse with IntelliEye(TM) as /class/input/input9
> Nov 24 10:04:50 corfu kernel: [    8.657208] input,hidraw2: USB HID v1.10 Mouse [Microsoft Microsoft 3-Button Mouse with IntelliEye(TM)] on usb-0000:00:13.1-1
> Nov 24 10:04:50 corfu kernel: [    8.657309] usb 2-1: New USB device found, idVendor=045e, idProduct=0040
> Nov 24 10:04:50 corfu kernel: [    8.657312] usb 2-1: New USB device strings: Mfr=1, Product=3, SerialNumber=0
> Nov 24 10:04:50 corfu kernel: [    8.657314] usb 2-1: Product: Microsoft 3-Button Mouse with IntelliEye(TM)
> Nov 24 10:04:50 corfu kernel: [    8.657315] usb 2-1: Manufacturer: Microsoft
> Nov 24 10:04:50 corfu kernel: [    8.888493] skge eth0: Link is up at 1000 Mbps, full duplex, flow control both
> Nov 24 10:04:50 corfu kernel: [    9.012477] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.012713] EXT3 FS on sda3, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.012716] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    9.030192] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.030403] EXT3 FS on sda6, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.030406] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    9.042189] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.042375] EXT3 FS on sda5, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.042378] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    9.076607] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.076781] EXT3 FS on sda7, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.076784] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    9.094136] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.094317] EXT3 FS on sda10, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.094320] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [    9.137954] kjournald starting.  Commit interval 5 seconds
> Nov 24 10:04:50 corfu kernel: [    9.138162] EXT3 FS on sda8, internal journal
> Nov 24 10:04:50 corfu kernel: [    9.138165] EXT3-fs: mounted filesystem with ordered data mode.
> Nov 24 10:04:50 corfu kernel: [   11.171036] NET: Registered protocol family 10
> Nov 24 10:04:50 corfu kernel: [   11.171162] lo: Disabled Privacy Extensions
> Nov 24 10:04:50 corfu kernel: [   13.097949] ip_tables: (C) 2000-2006 Netfilter Core Team
> Nov 24 10:04:50 corfu kernel: [   15.112351] toshiba_acpi: Unknown parameter `hotkeys_over_acpi'
> Nov 24 10:04:50 corfu kernel: [   15.125260] ACPI: WMI: Mapper loaded
> Nov 24 10:04:50 corfu kernel: [   15.265244] powernow-k8: Found 1 AMD Athlon(tm) 64 X2 Dual Core Processor 4600+ processors (2 cpu cores) (version 2.20.00)
> Nov 24 10:04:50 corfu kernel: [   15.265767] powernow-k8: ACPI Processor support is required for SMP systems but is absent. Please load the ACPI Processor module before starting this driver.
> Nov 24 10:04:50 corfu kernel: [   15.265947] powernow-k8: ACPI Processor support is required for SMP systems but is absent. Please load the ACPI Processor module before starting this driver.
> -->8--
> 
> 
> If there is more information I could provide, then please let me know.

The problem is your ethernet hardware is unable to access that memory above 4G.
I suspect you have a motherboard which won't work with 4G or more. The skge driver
will, but some of the consumer hardware is crap. There seems to be no good way to
test if the hardware is 

What motherboard?

Are you running 32bit or 64bit kernel? You need to have 64bit kernel or
compile with HIGHMEM64G option on 32bit.

Full lspci output would help as well. Then maybe a PCI quirk could be setup
to force bounce buffer.



