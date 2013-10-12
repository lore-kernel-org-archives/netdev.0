From: Gary Dale <garydale@torfree.net>
Subject: r8168-dkms and interaction with IOMMU setting
Date: Sat, 12 Oct 2013 00:21:50 -0400
Message-ID: <5258CE5E.7080700@torfree.net>
Reply-To: gary@extremeground.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040409050800070602020509"
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm28.bullet.mail.bf1.yahoo.com ([98.139.212.187]:37826 "EHLO
	nm28.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750705Ab3JLEV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Oct 2013 00:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040409050800070602020509
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I'm running Jessie. I just replaced my mainboard and was having some 
problems.

1) I was not getting the RTL8168 onboard NIC to work. It seemed to be 
able to receive but not transmit if I read this ifconfig output correctly:

eth0      Link encap:Ethernet  HWaddr 94:de:80:b1:57:17
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:86 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:34 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:15027 (14.6 KiB)  TX bytes:0 (0.0 B)
           Interrupt:72 Base address:0xa000

I was not getting a DHCP address for eth0. I tried to set it manually 
and add a route to the router, but I still couldn't get out. I've also 
tried the SID r8168-dkms driver and the slightly more recent one from 
RealTek but they didn't work either.

The lspci listing for it is: 04:00.0 Ethernet controller: Realtek 
Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet 
Controller (rev 06)


2) Most of the back panel USB ports didn't seem to work. The USB3 ports 
do but not the USB2 ones.

The lspci listings for the USB controllers are:
00:12.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
00:12.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB EHCI Controller
00:13.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
00:13.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB EHCI Controller
....
00:14.5 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB OHCI2 Controller
00:16.0 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
00:16.2 USB controller: Advanced Micro Devices, Inc. [AMD/ATI] 
SB7x0/SB8x0/SB9x0 USB EHCI Controller
...
02:00.0 USB controller: VIA Technologies, Inc. Device 3483 (rev 01)

The lsusb listing is:
Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 009 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 008 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 004 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 007 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 006 Device 001: ID 1d6b:0001 Linux Foundation 1.1 root hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 004: ID 066b:400b Linksys, Inc. USB10TX
Bus 001 Device 003: ID 046d:c03d Logitech, Inc. M-BT96a Pilot Optical Mouse
Bus 001 Device 002: ID 2109:3431
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub


Bus 001 Device 004 is an old USB network adapter I'd pressed into 
service to give me network connectivity.
Bus 001 Device 003 is my logitech mouse.

Both devices are plugged into the USB3 ports. They didn't work in the 
USB2 ports.


Anyway, after looking at a report of problems with AMD 970 USB ports, I 
discovered that the BIOS IOMMU setting seems to be important. Enabling 
it seems to have fixed both problems (don't know now if the USB3 ports 
work - my mouse stopped working on it, but now works on a USB2 port).

I'm also getting a lot of IO_PAGE_FAULT errors now that weren't there 
before. I've attached the dmesg log in case you need it. I don't know if 
this is of interest to you but it does seem to have an impact on the 
r8168 NIC.



--------------040409050800070602020509
Content-Type: text/plain;
 name="dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="dmesg"

[    0.000000] PM: Registered nosave memory: 00000000fed90000 - 00000000fef00000
[    0.000000] PM: Registered nosave memory: 00000000fef00000 - 0000000100000000
[    0.000000] PM: Registered nosave memory: 0000000100000000 - 0000000100001000
[    0.000000] e820: [mem 0xbf800000-0xf7ffffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:6 nr_node_ids:1
[    0.000000] PERCPU: Embedded 28 pages/cpu @ffff88023ec00000 s84928 r8192 d21568 u262144
[    0.000000] pcpu-alloc: s84928 r8192 d21568 u262144 alloc=1*2097152
[    0.000000] pcpu-alloc: [0] 0 1 2 3 4 5 - - 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2059533
[    0.000000] Policy zone: Normal
[    0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.10-3-amd64 root=UUID=95fe03ab-42b8-412a-9bb3-2ae7a1e829bc ro quiet
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] xsave: enabled xstate_bv 0x7, cntxt size 0x340
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Node 0: aperture @ f8000000 size 64 MB
[    0.000000] Memory: 8148840k/9420800k available (3643k kernel code, 1068384k absent, 203576k reserved, 3126k data, 920k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000] 	RCU dyntick-idle grace-period acceleration is enabled.
[    0.000000] 	RCU restricting CPUs from NR_CPUS=512 to nr_cpu_ids=6.
[    0.000000] NR_IRQS:33024 nr_irqs:1272 16
[    0.000000] spurious 8259A interrupt: IRQ7.
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration using PIT
[    0.004000] tsc: Detected 3315.179 MHz processor
[    0.000003] Calibrating delay loop (skipped), value calculated using timer frequency.. 6630.35 BogoMIPS (lpj=13260716)
[    0.000006] pid_max: default: 32768 minimum: 301
[    0.000036] Security Framework initialized
[    0.000039] AppArmor: AppArmor disabled by boot time parameter
[    0.000040] Yama: disabled by default; enable with sysctl kernel.yama.*
[    0.000596] Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
[    0.002655] Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
[    0.003550] Mount-cache hash table entries: 256
[    0.003712] Initializing cgroup subsys memory
[    0.003725] Initializing cgroup subsys devices
[    0.003727] Initializing cgroup subsys freezer
[    0.003729] Initializing cgroup subsys net_cls
[    0.003730] Initializing cgroup subsys blkio
[    0.003732] Initializing cgroup subsys perf_event
[    0.003756] tseg: 00bf800000
[    0.003758] CPU: Physical Processor ID: 0
[    0.003759] CPU: Processor Core ID: 0
[    0.003761] mce: CPU supports 7 MCE banks
[    0.003768] LVT offset 1 assigned for vector 0xf9
[    0.003774] Last level iTLB entries: 4KB 512, 2MB 1024, 4MB 512
[    0.003774] Last level dTLB entries: 4KB 1024, 2MB 1024, 4MB 512
[    0.003774] tlb_flushall_shift: 5
[    0.003837] Freeing SMP alternatives: 12k freed
[    0.004124] ACPI: Core revision 20130328
[    0.006584] ACPI: All ACPI Tables successfully acquired
[    0.092962] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.132664] smpboot: CPU0: AMD FX(tm)-6100 Six-Core Processor (fam: 15, model: 01, stepping: 02)
[    0.239560] Performance Events: 
[    0.239561] perf: AMD core performance counters detected
[    0.239564] AMD PMU driver.
[    0.239567] ... version:                0
[    0.239568] ... bit width:              48
[    0.239569] ... generic registers:      6
[    0.239571] ... value mask:             0000ffffffffffff
[    0.239572] ... max period:             00007fffffffffff
[    0.239573] ... fixed-purpose events:   0
[    0.239574] ... event mask:             000000000000003f
[    0.239788] NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counter.
[    0.239882] smpboot: Booting Node   0, Processors  #1 #2 #3 #4 #5 OK
[    0.306050] Brought up 6 CPUs
[    0.306053] smpboot: Total of 6 processors activated (39782.14 BogoMIPS)
[    0.317280] devtmpfs: initialized
[    0.320069] PM: Registering ACPI NVS region [mem 0xbea4b000-0xbee39fff] (4124672 bytes)
[    0.320175] PM: Registering ACPI NVS region [mem 0xbf15e000-0xbf363fff] (2121728 bytes)
[    0.320398] regulator-dummy: no parameters
[    0.320467] NET: Registered protocol family 16
[    0.320581] ACPI: bus type PCI registered
[    0.320584] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.320637] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.320640] PCI: not using MMCONFIG
[    0.320641] PCI: Using configuration type 1 for base access
[    0.320642] PCI: Using configuration type 1 for extended access
[    0.321494] bio: create slab <bio-0> at 0
[    0.321669] ACPI: Added _OSI(Module Device)
[    0.321671] ACPI: Added _OSI(Processor Device)
[    0.321673] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.321674] ACPI: Added _OSI(Processor Aggregator Device)
[    0.322326] ACPI: EC: Look up EC in DSDT
[    0.323359] ACPI: Executed 3 blocks of module-level executable AML code
[    0.336609] ACPI: Interpreter enabled
[    0.336626] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20130328/hwxface-568)
[    0.336636] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130328/hwxface-568)
[    0.336667] ACPI: (supports S0 S3 S4 S5)
[    0.336671] ACPI: Using IOAPIC for interrupt routing
[    0.336937] PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] (base 0xe0000000)
[    0.337028] PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in ACPI motherboard resources
[    0.353443] PCI: Using host bridge windows from ACPI; if necessary, use "pci=nocrs" and report a bug
[    0.353514] ACPI: No dock devices found.
[    0.501484] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.502316] PCI host bridge to bus 0000:00
[    0.502324] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.502331] pci_bus 0000:00: root bus resource [io  0x0000-0x03af]
[    0.502336] pci_bus 0000:00: root bus resource [io  0x03e0-0x0cf7]
[    0.502341] pci_bus 0000:00: root bus resource [io  0x03b0-0x03df]
[    0.502346] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.502351] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff]
[    0.502356] pci_bus 0000:00: root bus resource [mem 0x000c0000-0x000dffff]
[    0.502361] pci_bus 0000:00: root bus resource [mem 0xc0000000-0xffffffff]
[    0.502384] pci 0000:00:00.0: [1002:5a14] type 00 class 0x060000
[    0.502630] pci 0000:00:00.2: [1002:5a23] type 00 class 0x080600
[    0.502868] pci 0000:00:02.0: [1002:5a16] type 01 class 0x060400
[    0.502926] pci 0000:00:02.0: PME# supported from D0 D3hot D3cold
[    0.503049] pci 0000:00:02.0: System wakeup disabled by ACPI
[    0.503124] pci 0000:00:04.0: [1002:5a18] type 01 class 0x060400
[    0.503180] pci 0000:00:04.0: PME# supported from D0 D3hot D3cold
[    0.503301] pci 0000:00:04.0: System wakeup disabled by ACPI
[    0.503373] pci 0000:00:05.0: [1002:5a19] type 01 class 0x060400
[    0.503429] pci 0000:00:05.0: PME# supported from D0 D3hot D3cold
[    0.503551] pci 0000:00:05.0: System wakeup disabled by ACPI
[    0.503624] pci 0000:00:09.0: [1002:5a1c] type 01 class 0x060400
[    0.503680] pci 0000:00:09.0: PME# supported from D0 D3hot D3cold
[    0.503801] pci 0000:00:09.0: System wakeup disabled by ACPI
[    0.503883] pci 0000:00:11.0: [1002:4390] type 00 class 0x01018f
[    0.503906] pci 0000:00:11.0: reg 10: [io  0xf090-0xf097]
[    0.503919] pci 0000:00:11.0: reg 14: [io  0xf080-0xf083]
[    0.503931] pci 0000:00:11.0: reg 18: [io  0xf070-0xf077]
[    0.503943] pci 0000:00:11.0: reg 1c: [io  0xf060-0xf063]
[    0.503955] pci 0000:00:11.0: reg 20: [io  0xf050-0xf05f]
[    0.503968] pci 0000:00:11.0: reg 24: [mem 0xfeb0b000-0xfeb0b3ff]
[    0.503991] pci 0000:00:11.0: set SATA to AHCI mode
[    0.504190] pci 0000:00:12.0: [1002:4397] type 00 class 0x0c0310
[    0.504207] pci 0000:00:12.0: reg 10: [mem 0xfeb0a000-0xfeb0afff]
[    0.504401] pci 0000:00:12.0: System wakeup disabled by ACPI
[    0.504478] pci 0000:00:12.2: [1002:4396] type 00 class 0x0c0320
[    0.504501] pci 0000:00:12.2: reg 10: [mem 0xfeb09000-0xfeb090ff]
[    0.504586] pci 0000:00:12.2: supports D1 D2
[    0.504591] pci 0000:00:12.2: PME# supported from D0 D1 D2 D3hot
[    0.504710] pci 0000:00:12.2: System wakeup disabled by ACPI
[    0.504785] pci 0000:00:13.0: [1002:4397] type 00 class 0x0c0310
[    0.504802] pci 0000:00:13.0: reg 10: [mem 0xfeb08000-0xfeb08fff]
[    0.504968] pci 0000:00:13.0: System wakeup disabled by ACPI
[    0.505052] pci 0000:00:13.2: [1002:4396] type 00 class 0x0c0320
[    0.505074] pci 0000:00:13.2: reg 10: [mem 0xfeb07000-0xfeb070ff]
[    0.505158] pci 0000:00:13.2: supports D1 D2
[    0.505163] pci 0000:00:13.2: PME# supported from D0 D1 D2 D3hot
[    0.505282] pci 0000:00:13.2: System wakeup disabled by ACPI
[    0.505363] pci 0000:00:14.0: [1002:4385] type 00 class 0x0c0500
[    0.505589] pci 0000:00:14.1: [1002:439c] type 00 class 0x01018a
[    0.505606] pci 0000:00:14.1: reg 10: [io  0xf040-0xf047]
[    0.505619] pci 0000:00:14.1: reg 14: [io  0xf030-0xf033]
[    0.505631] pci 0000:00:14.1: reg 18: [io  0xf020-0xf027]
[    0.505643] pci 0000:00:14.1: reg 1c: [io  0xf010-0xf013]
[    0.505655] pci 0000:00:14.1: reg 20: [io  0xf000-0xf00f]
[    0.505845] pci 0000:00:14.2: [1002:4383] type 00 class 0x040300
[    0.505870] pci 0000:00:14.2: reg 10: [mem 0xfeb00000-0xfeb03fff 64bit]
[    0.505940] pci 0000:00:14.2: PME# supported from D0 D3hot D3cold
[    0.506057] pci 0000:00:14.2: System wakeup disabled by ACPI
[    0.506126] pci 0000:00:14.3: [1002:439d] type 00 class 0x060100
[    0.506351] pci 0000:00:14.4: [1002:4384] type 01 class 0x060401
[    0.506500] pci 0000:00:14.4: System wakeup disabled by ACPI
[    0.506570] pci 0000:00:14.5: [1002:4399] type 00 class 0x0c0310
[    0.506587] pci 0000:00:14.5: reg 10: [mem 0xfeb06000-0xfeb06fff]
[    0.506754] pci 0000:00:14.5: System wakeup disabled by ACPI
[    0.506825] pci 0000:00:16.0: [1002:4397] type 00 class 0x0c0310
[    0.506842] pci 0000:00:16.0: reg 10: [mem 0xfeb05000-0xfeb05fff]
[    0.507010] pci 0000:00:16.0: System wakeup disabled by ACPI
[    0.507084] pci 0000:00:16.2: [1002:4396] type 00 class 0x0c0320
[    0.507106] pci 0000:00:16.2: reg 10: [mem 0xfeb04000-0xfeb040ff]
[    0.507191] pci 0000:00:16.2: supports D1 D2
[    0.507195] pci 0000:00:16.2: PME# supported from D0 D1 D2 D3hot
[    0.507315] pci 0000:00:16.2: System wakeup disabled by ACPI
[    0.507389] pci 0000:00:18.0: [1022:1600] type 00 class 0x060000
[    0.507573] pci 0000:00:18.1: [1022:1601] type 00 class 0x060000
[    0.507745] pci 0000:00:18.2: [1022:1602] type 00 class 0x060000
[    0.507918] pci 0000:00:18.3: [1022:1603] type 00 class 0x060000
[    0.508097] pci 0000:00:18.4: [1022:1604] type 00 class 0x060000
[    0.508267] pci 0000:00:18.5: [1022:1605] type 00 class 0x060000
[    0.508523] pci 0000:01:00.0: [1002:6819] type 00 class 0x030000
[    0.508541] pci 0000:01:00.0: reg 10: [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.508556] pci 0000:01:00.0: reg 18: [mem 0xfea00000-0xfea3ffff 64bit]
[    0.508567] pci 0000:01:00.0: reg 20: [io  0xe000-0xe0ff]
[    0.508584] pci 0000:01:00.0: reg 30: [mem 0xfea40000-0xfea5ffff pref]
[    0.508631] pci 0000:01:00.0: supports D1 D2
[    0.508635] pci 0000:01:00.0: PME# supported from D1 D2 D3hot
[    0.508737] pci 0000:01:00.1: [1002:aab0] type 00 class 0x040300
[    0.508755] pci 0000:01:00.1: reg 10: [mem 0xfea60000-0xfea63fff 64bit]
[    0.508831] pci 0000:01:00.1: supports D1 D2
[    0.517063] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.517073] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.517079] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.517087] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.517178] pci 0000:02:00.0: [1106:3483] type 00 class 0x0c0330
[    0.517198] pci 0000:02:00.0: reg 10: [mem 0xfe900000-0xfe900fff 64bit]
[    0.517275] pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.525064] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.525074] pci 0000:00:04.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.525173] pci 0000:03:00.0: [14f1:8852] type 00 class 0x040000
[    0.525202] pci 0000:03:00.0: reg 10: [mem 0xfe600000-0xfe7fffff 64bit]
[    0.525335] pci 0000:03:00.0: supports D1 D2
[    0.525340] pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot
[    0.525435] pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
[    0.525447] pci 0000:00:05.0: PCI bridge to [bus 03]
[    0.525456] pci 0000:00:05.0:   bridge window [mem 0xfe600000-0xfe7fffff]
[    0.525561] pci 0000:04:00.0: [10ec:8168] type 00 class 0x020000
[    0.525579] pci 0000:04:00.0: reg 10: [io  0xd000-0xd0ff]
[    0.525606] pci 0000:04:00.0: reg 18: [mem 0xfe800000-0xfe800fff 64bit]
[    0.525625] pci 0000:04:00.0: reg 20: [mem 0xd0000000-0xd0003fff 64bit pref]
[    0.525694] pci 0000:04:00.0: supports D1 D2
[    0.525698] pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
[    0.525748] pci 0000:04:00.0: System wakeup disabled by ACPI
[    0.533069] pci 0000:00:09.0: PCI bridge to [bus 04]
[    0.533078] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.533084] pci 0000:00:09.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.533092] pci 0000:00:09.0:   bridge window [mem 0xd0000000-0xd00fffff 64bit pref]
[    0.533199] pci 0000:00:14.4: PCI bridge to [bus 05] (subtractive decode)
[    0.533212] pci 0000:00:14.4:   bridge window [io  0x0000-0x03af] (subtractive decode)
[    0.533217] pci 0000:00:14.4:   bridge window [io  0x03e0-0x0cf7] (subtractive decode)
[    0.533222] pci 0000:00:14.4:   bridge window [io  0x03b0-0x03df] (subtractive decode)
[    0.533227] pci 0000:00:14.4:   bridge window [io  0x0d00-0xffff] (subtractive decode)
[    0.533232] pci 0000:00:14.4:   bridge window [mem 0x000a0000-0x000bffff] (subtractive decode)
[    0.533237] pci 0000:00:14.4:   bridge window [mem 0x000c0000-0x000dffff] (subtractive decode)
[    0.533242] pci 0000:00:14.4:   bridge window [mem 0xc0000000-0xffffffff] (subtractive decode)
[    0.533268] acpi PNP0A08:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.533273] acpi PNP0A08:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.577341] ACPI: PCI Interrupt Link [LNKA] (IRQs 4 7 10 11 14 15) *0
[    0.577486] ACPI: PCI Interrupt Link [LNKB] (IRQs 4 7 10 11 14 15) *0
[    0.577637] ACPI: PCI Interrupt Link [LNKC] (IRQs 4 7 10 11 14 15) *0
[    0.577780] ACPI: PCI Interrupt Link [LNKD] (IRQs 4 7 10 11 14 15) *0
[    0.577900] ACPI: PCI Interrupt Link [LNKE] (IRQs 4 10 11 14 15) *0
[    0.577996] ACPI: PCI Interrupt Link [LNKF] (IRQs 4 10 11 14 15) *0
[    0.578091] ACPI: PCI Interrupt Link [LNKG] (IRQs 4 10 11 14 15) *0
[    0.578186] ACPI: PCI Interrupt Link [LNKH] (IRQs 4 10 11 14 15) *0
[    0.578404] acpi root: \_SB_.PCI0 notify handler is installed
[    0.578473] Found 1 acpi root devices
[    0.578750] vgaarb: device added: PCI:0000:01:00.0,decodes=io+mem,owns=io+mem,locks=none
[    0.578756] vgaarb: loaded
[    0.578759] vgaarb: bridge control possible 0000:01:00.0
[    0.578844] PCI: Using ACPI for IRQ routing
[    0.587084] PCI: pci_cache_line_size set to 64 bytes
[    0.587176] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.587181] e820: reserve RAM buffer [mem 0xbe86e000-0xbfffffff]
[    0.587186] e820: reserve RAM buffer [mem 0xbf15e000-0xbfffffff]
[    0.587189] e820: reserve RAM buffer [mem 0xbf800000-0xbfffffff]
[    0.587193] e820: reserve RAM buffer [mem 0x23f000000-0x23fffffff]
[    0.587408] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.587416] hpet0: 3 comparators, 32-bit 14.318180 MHz counter
[    0.589473] Switching to clocksource hpet
[    0.592943] pnp: PnP ACPI init
[    0.592965] ACPI: bus type PNP registered
[    0.593150] system 00:00: [mem 0xe0000000-0xefffffff] has been reserved
[    0.593159] system 00:00: Plug and Play ACPI device, IDs PNP0c01 (active)
[    0.593807] system 00:01: [io  0x040b] has been reserved
[    0.593813] system 00:01: [io  0x04d6] has been reserved
[    0.593819] system 00:01: [io  0x0c00-0x0c01] has been reserved
[    0.593824] system 00:01: [io  0x0c14] has been reserved
[    0.593829] system 00:01: [io  0x0c50-0x0c51] has been reserved
[    0.593834] system 00:01: [io  0x0c52] has been reserved
[    0.593839] system 00:01: [io  0x0c6c] has been reserved
[    0.593844] system 00:01: [io  0x0c6f] has been reserved
[    0.593849] system 00:01: [io  0x0cd0-0x0cd1] has been reserved
[    0.593854] system 00:01: [io  0x0cd2-0x0cd3] has been reserved
[    0.593859] system 00:01: [io  0x0cd4-0x0cd5] has been reserved
[    0.593864] system 00:01: [io  0x0cd6-0x0cd7] has been reserved
[    0.593869] system 00:01: [io  0x0cd8-0x0cdf] has been reserved
[    0.593874] system 00:01: [io  0x0800-0x089f] has been reserved
[    0.593880] system 00:01: [io  0x0b20-0x0b3f] has been reserved
[    0.593885] system 00:01: [io  0x0900-0x090f] has been reserved
[    0.593890] system 00:01: [io  0x0910-0x091f] has been reserved
[    0.593895] system 00:01: [io  0xfe00-0xfefe] has been reserved
[    0.593903] system 00:01: [mem 0xfec00000-0xfec00fff] could not be reserved
[    0.593909] system 00:01: [mem 0xfee00000-0xfee00fff] has been reserved
[    0.593915] system 00:01: [mem 0xfed80000-0xfed8ffff] has been reserved
[    0.593921] system 00:01: [mem 0xfed61000-0xfed70fff] has been reserved
[    0.593927] system 00:01: [mem 0xfec10000-0xfec10fff] has been reserved
[    0.593933] system 00:01: [mem 0xfed00000-0xfed00fff] has been reserved
[    0.593939] system 00:01: [mem 0xffc00000-0xffffffff] has been reserved
[    0.593945] system 00:01: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.594306] system 00:02: [io  0x0220-0x0227] has been reserved
[    0.594312] system 00:02: [io  0x0228-0x0237] has been reserved
[    0.594318] system 00:02: [io  0x0a20-0x0a2f] has been reserved
[    0.594324] system 00:02: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.594439] pnp 00:03: Plug and Play ACPI device, IDs PNP0303 PNP030b (active)
[    0.594954] pnp 00:04: [dma 0 disabled]
[    0.595061] pnp 00:04: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.595084] pnp 00:05: [dma 4]
[    0.595128] pnp 00:05: Plug and Play ACPI device, IDs PNP0200 (active)
[    0.595191] pnp 00:06: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.595241] pnp 00:07: Plug and Play ACPI device, IDs PNP0800 (active)
[    0.595373] system 00:08: [io  0x04d0-0x04d1] has been reserved
[    0.595380] system 00:08: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.595441] pnp 00:09: Plug and Play ACPI device, IDs PNP0c04 (active)
[    0.595526] system 00:0a: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.595843] system 00:0b: [mem 0xfeb20000-0xfeb23fff] could not be reserved
[    0.595849] system 00:0b: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.596118] system 00:0c: [mem 0xfec20000-0xfec200ff] could not be reserved
[    0.596125] system 00:0c: Plug and Play ACPI device, IDs PNP0c02 (active)
[    0.596436] pnp 00:0d: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.596443] pnp: PnP ACPI: found 14 devices
[    0.596446] ACPI: bus type PNP unregistered
[    0.605302] pci 0000:00:02.0: PCI bridge to [bus 01]
[    0.605310] pci 0000:00:02.0:   bridge window [io  0xe000-0xefff]
[    0.605318] pci 0000:00:02.0:   bridge window [mem 0xfea00000-0xfeafffff]
[    0.605324] pci 0000:00:02.0:   bridge window [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.605332] pci 0000:00:04.0: PCI bridge to [bus 02]
[    0.605338] pci 0000:00:04.0:   bridge window [mem 0xfe900000-0xfe9fffff]
[    0.605347] pci 0000:00:05.0: PCI bridge to [bus 03]
[    0.605353] pci 0000:00:05.0:   bridge window [mem 0xfe600000-0xfe7fffff]
[    0.605361] pci 0000:00:09.0: PCI bridge to [bus 04]
[    0.605366] pci 0000:00:09.0:   bridge window [io  0xd000-0xdfff]
[    0.605373] pci 0000:00:09.0:   bridge window [mem 0xfe800000-0xfe8fffff]
[    0.605379] pci 0000:00:09.0:   bridge window [mem 0xd0000000-0xd00fffff 64bit pref]
[    0.605386] pci 0000:00:14.4: PCI bridge to [bus 05]
[    0.605925] pci_bus 0000:00: resource 4 [io  0x0000-0x03af]
[    0.605930] pci_bus 0000:00: resource 5 [io  0x03e0-0x0cf7]
[    0.605936] pci_bus 0000:00: resource 6 [io  0x03b0-0x03df]
[    0.605940] pci_bus 0000:00: resource 7 [io  0x0d00-0xffff]
[    0.605945] pci_bus 0000:00: resource 8 [mem 0x000a0000-0x000bffff]
[    0.605950] pci_bus 0000:00: resource 9 [mem 0x000c0000-0x000dffff]
[    0.605955] pci_bus 0000:00: resource 10 [mem 0xc0000000-0xffffffff]
[    0.605960] pci_bus 0000:01: resource 0 [io  0xe000-0xefff]
[    0.605965] pci_bus 0000:01: resource 1 [mem 0xfea00000-0xfeafffff]
[    0.605970] pci_bus 0000:01: resource 2 [mem 0xc0000000-0xcfffffff 64bit pref]
[    0.605975] pci_bus 0000:02: resource 1 [mem 0xfe900000-0xfe9fffff]
[    0.605980] pci_bus 0000:03: resource 1 [mem 0xfe600000-0xfe7fffff]
[    0.605985] pci_bus 0000:04: resource 0 [io  0xd000-0xdfff]
[    0.605990] pci_bus 0000:04: resource 1 [mem 0xfe800000-0xfe8fffff]
[    0.605995] pci_bus 0000:04: resource 2 [mem 0xd0000000-0xd00fffff 64bit pref]
[    0.606000] pci_bus 0000:05: resource 4 [io  0x0000-0x03af]
[    0.606005] pci_bus 0000:05: resource 5 [io  0x03e0-0x0cf7]
[    0.606010] pci_bus 0000:05: resource 6 [io  0x03b0-0x03df]
[    0.606014] pci_bus 0000:05: resource 7 [io  0x0d00-0xffff]
[    0.606019] pci_bus 0000:05: resource 8 [mem 0x000a0000-0x000bffff]
[    0.606024] pci_bus 0000:05: resource 9 [mem 0x000c0000-0x000dffff]
[    0.606029] pci_bus 0000:05: resource 10 [mem 0xc0000000-0xffffffff]
[    0.606176] NET: Registered protocol family 2
[    0.606715] TCP established hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.607238] TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
[    0.607586] TCP: Hash tables configured (established 65536 bind 65536)
[    0.607640] TCP: reno registered
[    0.607668] UDP hash table entries: 4096 (order: 5, 131072 bytes)
[    0.607740] UDP-Lite hash table entries: 4096 (order: 5, 131072 bytes)
[    0.607951] NET: Registered protocol family 1
[    0.934105] pci 0000:01:00.0: Boot video device
[    0.934235] PCI: CLS 64 bytes, default 64
[    0.934307] Unpacking initramfs...
[    1.226374] Freeing initrd memory: 13140k freed
[    1.229848] AMD-Vi: Found IOMMU at 0000:00:00.2 cap 0x40
[    1.229851] AMD-Vi: Interrupt remapping enabled
[    1.229868] pci 0000:00:00.2: irq 72 for MSI/MSI-X
[    1.238901] AMD-Vi: Lazy IO/TLB flushing enabled
[    1.323715] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    1.323718] software IO TLB [mem 0xba86e000-0xbe86e000] (64MB) mapped at [ffff8800ba86e000-ffff8800be86dfff]
[    1.323943] perf: AMD NB counters detected
[    1.323966] LVT offset 0 assigned for vector 0x400
[    1.323987] perf: AMD IBS detected (0x000000ff)
[    1.324184] audit: initializing netlink socket (disabled)
[    1.324196] type=2000 audit(1381550830.124:1): initialized
[    1.337120] bounce pool size: 64 pages
[    1.337124] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    1.337747] VFS: Disk quotas dquot_6.5.2
[    1.337773] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.337858] msgmni has been set to 15941
[    1.338117] alg: No test for stdrng (krng)
[    1.338146] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 252)
[    1.338196] io scheduler noop registered
[    1.338198] io scheduler deadline registered
[    1.338223] io scheduler cfq registered (default)
[    1.338377] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.338392] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.338466] GHES: HEST is not enabled!
[    1.338513] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    1.358884] 00:04: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.359276] Linux agpgart interface v0.103
[    1.359368] i8042: PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
[    1.359370] i8042: PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
[    1.359495] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.359591] mousedev: PS/2 mouse device common for all mice
[    1.359630] rtc_cmos 00:06: RTC can wake from S4
[    1.359727] rtc_cmos 00:06: rtc core: registered rtc_cmos as rtc0
[    1.359749] rtc_cmos 00:06: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
[    1.359756] cpuidle: using governor ladder
[    1.359758] cpuidle: using governor menu
[    1.359848] TCP: cubic registered
[    1.359916] NET: Registered protocol family 10
[    1.360092] mip6: Mobile IPv6
[    1.360095] NET: Registered protocol family 17
[    1.360402] PM: Hibernation image not present or could not be loaded.
[    1.360411] registered taskstats version 1
[    1.361150] rtc_cmos 00:06: setting system clock to 2013-10-12 04:07:10 UTC (1381550830)
[    1.362076] Freeing unused kernel memory: 920k freed
[    1.362288] Write protecting the kernel read-only data: 6144k
[    1.363530] Freeing unused kernel memory: 444k freed
[    1.364854] Freeing unused kernel memory: 492k freed
[    1.375552] systemd-udevd[78]: starting version 204
[    1.382679] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    1.397462] SCSI subsystem initialized
[    1.398688] ACPI: bus type ATA registered
[    1.399046] ACPI: bus type USB registered
[    1.399084] usbcore: registered new interface driver usbfs
[    1.399097] usbcore: registered new interface driver hub
[    1.401666] libata version 3.00 loaded.
[    1.402110] usbcore: registered new device driver usb
[    1.402539] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.402776] ahci 0000:00:11.0: version 3.0
[    1.402886] ehci-pci: EHCI PCI platform driver
[    1.402979] ahci 0000:00:11.0: AHCI 0001.0200 32 slots 4 ports 6 Gbps 0xf impl SATA mode
[    1.402983] ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum part 
[    1.403069] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    1.403202] r8168 Gigabit Ethernet driver 8.036.00-NAPI loaded
[    1.403308] r8168 0000:04:00.0: irq 73 for MSI/MSI-X
[    1.403509] xhci_hcd 0000:02:00.0: xHCI Host Controller
[    1.403518] xhci_hcd 0000:02:00.0: new USB bus registered, assigned bus number 1
[    1.403633] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.403724] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.403808] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.403894] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.403982] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404074] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404158] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404243] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404328] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404412] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404502] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404591] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404682] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404773] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404891] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.404985] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405077] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405170] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405260] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405350] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405440] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405531] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405621] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405711] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405801] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405905] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.405993] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406116] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406205] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406296] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406385] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406475] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406565] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406655] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406744] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406835] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.406925] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407015] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407106] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407196] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407314] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407404] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407495] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407585] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407676] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407767] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407862] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.407955] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408045] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408173] scsi0 : ahci
[    1.408137] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408230] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408329] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408417] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408535] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408624] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408714] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408803] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408895] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.408986] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409076] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409165] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409254] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409344] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409434] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409522] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409612] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409729] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409819] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.409945] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410013] scsi1 : ahci
[    1.410035] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410126] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410215] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410305] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410394] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410500] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410592] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410685] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410834] microcode: CPU0: patch_level=0x0600063d
[    1.410856] platform microcode: firmware: agent loaded amd-ucode/microcode_amd_fam15h.bin into memory
[    1.410814] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.410904] microcode: CPU1: patch_level=0x0600063d
[    1.410925] microcode: CPU2: patch_level=0x0600063d
[    1.410940] AMD-Vi: Event logged [
[    1.410983] microcode: CPU3: patch_level=0x0600063d
[    1.411033] microcode: CPU4: patch_level=0x0600063d
[    1.411041] microcode: CPU5: patch_level=0x0600063d
[    1.411043] IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411048] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411052] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411054] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411057] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411058] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411060] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411063] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411065] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411067] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411068] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411070] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411072] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411074] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411077] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411078] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411080] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411082] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411085] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411087] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411090] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411092] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411095] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411097] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411100] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411102] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411105] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411108] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411110] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411112] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411114] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411116] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411117] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411119] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411122] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411124] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411126] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411128] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411130] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411131] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411133] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411135] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411137] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411139] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411141] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411143] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411144] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411146] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411148] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411149] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411151] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411153] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411154] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411158] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411160] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411162] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411165] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411167] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411169] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411170] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411173] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411174] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411176] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411177] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411179] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411180] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411182] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411183] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411185] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411187] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411188] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411190] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411191] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411193] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411195] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411196] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411198] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411200] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411203] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411207] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411209] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411211] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411213] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411215] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411217] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411219] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411221] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411223] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411225] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411227] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411229] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411231] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411233] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411235] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411237] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411239] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411241] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411242] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411244] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411245] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411247] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411248] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411250] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411251] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411253] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411256] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411257] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411259] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411260] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411262] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411263] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411265] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411266] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411269] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411271] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411272] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411275] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411277] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411278] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411281] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411283] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411284] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411286] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411288] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411290] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411292] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411295] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411296] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411298] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411300] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411303] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411305] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411308] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411309] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411312] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411313] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411315] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411316] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411318] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411320] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411322] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411323] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411325] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411327] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411329] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411330] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411332] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411334] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411335] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411337] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411339] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411340] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411342] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411343] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411345] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411346] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411348] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411350] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411352] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411354] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411357] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411358] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411360] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411362] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411364] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411366] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411368] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411370] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411372] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411374] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411376] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411378] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411379] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411381] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411382] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411384] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411385] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411387] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411389] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411390] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411392] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411393] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411395] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411396] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411398] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411399] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411401] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411403] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411405] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411407] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411409] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411410] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411412] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411413] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411415] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411417] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411419] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411420] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411422] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411424] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411425] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411427] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411428] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411430] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411432] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411433] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411435] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411436] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411438] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411440] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411441] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411443] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411444] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411446] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411448] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411449] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411451] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411453] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411456] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411458] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411459] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411461] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411463] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411464] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411466] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411467] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411469] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411471] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411473] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411474] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411476] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411477] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411479] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411480] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411482] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411484] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411485] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411487] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411488] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411490] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411492] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411493] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411495] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411497] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411499] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411500] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411502] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411503] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411507] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411508] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411510] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411512] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411513] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411515] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411516] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411518] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411519] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411521] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411522] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411524] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411526] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411527] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411529] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411531] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411532] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411534] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411535] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411537] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411539] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411541] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411543] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411544] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411546] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411547] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411549] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411551] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411553] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411556] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411558] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411559] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411561] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411563] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411565] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411566] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411568] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411570] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411571] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411573] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411575] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411576] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411578] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411580] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411582] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411583] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411585] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411587] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411588] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411590] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411592] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411594] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411595] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411597] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411599] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411600] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411602] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411604] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411607] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411608] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411610] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411611] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411614] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411616] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411617] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411619] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411620] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411622] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411624] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411625] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411627] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411629] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411631] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411632] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411634] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411636] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411637] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411639] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411641] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411642] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411644] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411646] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411648] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411649] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411651] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411652] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411655] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411657] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411659] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411660] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411662] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411664] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411666] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411667] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411669] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411671] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411673] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411675] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411676] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411678] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411680] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411681] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411683] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411685] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411686] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411688] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411690] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411691] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411693] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411695] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411697] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411698] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411700] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411701] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411703] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411706] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411707] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411710] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411711] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411713] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411715] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411717] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411719] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411721] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411723] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411725] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411726] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411728] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411730] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411731] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411733] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411735] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411737] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411739] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411740] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411742] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411743] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411745] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411747] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411749] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411750] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411752] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411755] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411757] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411758] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411760] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411762] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411763] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411765] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411766] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411768] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411770] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411772] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411773] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411775] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411777] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411778] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411780] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411782] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411787] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411791] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411796] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411799] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411801] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411803] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411805] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411807] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411809] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411811] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411812] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411814] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411815] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411822] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411827] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411830] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411833] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411835] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411837] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411839] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411842] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411844] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411846] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411849] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411851] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.411852] AMD-Vi: Event logged [IO_PAGE_FAULT device=02:00.0 domain=0x0016 address=0x00000000bea166c0 flags=0x0010]
[    1.415299] scsi2 : ahci
[    1.415377] scsi3 : ahci
[    1.415466] ata1: SATA max UDMA/133 abar m1024@0xfeb0b000 port 0xfeb0b100 irq 19
[    1.415472] ata2: SATA max UDMA/133 abar m1024@0xfeb0b000 port 0xfeb0b180 irq 19
[    1.415474] ata3: SATA max UDMA/133 abar m1024@0xfeb0b000 port 0xfeb0b200 irq 19
[    1.415477] ata4: SATA max UDMA/133 abar m1024@0xfeb0b000 port 0xfeb0b280 irq 19
[    1.457712] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.460019] eth%d: 0xffffc90000c28000, 94:de:80:b1:57:17, IRQ 73
[    1.460183] r8168: This product is covered by one or more of the following patents: US6,570,884, US6,115,776, and US6,327,625.
[    1.460188] r8168  Copyright (C) 2013  Realtek NIC software team <nicfae@realtek.com> 
[    1.460188]  This program comes with ABSOLUTELY NO WARRANTY; for details, please see <http://www.gnu.org/licenses/>. 
[    1.460188]  This is free software, and you are welcome to redistribute it under certain conditions; see <http://www.gnu.org/licenses/>. 
[    1.906086] ata4: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.906111] ata3: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.906132] ata2: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.906155] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
[    1.906782] ata3.00: ATA-8: ST2000DL003-9VT166, CC32, max UDMA/133
[    1.906785] ata3.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    1.906848] ata2.00: ATA-8: ST2000DL003-9VT166, CC3C, max UDMA/133
[    1.906851] ata2.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32)
[    1.907528] ata3.00: configured for UDMA/133
[    1.907631] ata2.00: configured for UDMA/133
[    1.910364] ata4.00: ATA-8: WDC WD20EARX-00PASB0, 51.0AB51, max UDMA/133
[    1.910367] ata4.00: 3907029168 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.914368] ata4.00: configured for UDMA/133
[    1.918135] ata1.00: ATA-8: OCZ-AGILITY3, 2.15, max UDMA/133
[    1.918138] ata1.00: 234441648 sectors, multi 16: LBA48 NCQ (depth 31/32), AA
[    1.928130] ata1.00: configured for UDMA/133
[    1.928274] scsi 0:0:0:0: Direct-Access     ATA      OCZ-AGILITY3     2.15 PQ: 0 ANSI: 5
[    1.928500] scsi 1:0:0:0: Direct-Access     ATA      ST2000DL003-9VT1 CC3C PQ: 0 ANSI: 5
[    1.928699] scsi 2:0:0:0: Direct-Access     ATA      ST2000DL003-9VT1 CC32 PQ: 0 ANSI: 5
[    1.928880] scsi 3:0:0:0: Direct-Access     ATA      WDC WD20EARX-00P 51.0 PQ: 0 ANSI: 5
[    1.932349] sd 1:0:0:0: [sdb] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    1.932354] sd 1:0:0:0: [sdb] 4096-byte physical blocks
[    1.932393] sd 2:0:0:0: [sdc] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    1.932398] sd 0:0:0:0: [sda] 234441648 512-byte logical blocks: (120 GB/111 GiB)
[    1.932404] sd 3:0:0:0: [sdd] 3907029168 512-byte logical blocks: (2.00 TB/1.81 TiB)
[    1.932409] sd 3:0:0:0: [sdd] 4096-byte physical blocks
[    1.932469] sd 2:0:0:0: [sdc] Write Protect is off
[    1.932473] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
[    1.932479] sd 3:0:0:0: [sdd] Write Protect is off
[    1.932483] sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
[    1.932494] sd 1:0:0:0: [sdb] Write Protect is off
[    1.932498] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
[    1.932502] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.932518] sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.932557] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.932565] sd 0:0:0:0: [sda] Write Protect is off
[    1.932569] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
[    1.932666] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
[    1.933305]  sda: sda1
[    1.933757] sd 0:0:0:0: [sda] Attached SCSI disk
[    1.959780]  sdb: sdb1
[    1.960114] sd 1:0:0:0: [sdb] Attached SCSI disk
[    1.971682]  sdd: sdd1
[    1.972012] sd 3:0:0:0: [sdd] Attached SCSI disk
[    1.996983]  sdc: sdc1
[    1.997320] sd 2:0:0:0: [sdc] Attached SCSI disk
[    1.999170] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    1.999258] sd 1:0:0:0: Attached scsi generic sg1 type 0
[    1.999304] sd 2:0:0:0: Attached scsi generic sg2 type 0
[    1.999353] sd 3:0:0:0: Attached scsi generic sg3 type 0
[   18.929538] xhci_hcd 0000:02:00.0: can't setup
[   18.929581] xhci_hcd 0000:02:00.0: USB bus 1 deregistered
[   18.929610] Switching to clocksource tsc
[   18.929628] ehci-pci 0000:00:12.2: EHCI Host Controller
[   18.929649] ehci-pci 0000:00:12.2: new USB bus registered, assigned bus number 1
[   18.929661] QUIRK: Enable AMD PLL fix
[   18.929664] ehci-pci 0000:00:12.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   18.929675] ehci-pci 0000:00:12.2: debug port 1
[   18.929685] xhci_hcd 0000:02:00.0: init 0000:02:00.0 fail, -110
[   18.929718] ehci-pci 0000:00:12.2: irq 17, io mem 0xfeb09000
[   18.929736] xhci_hcd: probe of 0000:02:00.0 failed with error -110
[   18.940994] ehci-pci 0000:00:12.2: USB 2.0 started, EHCI 1.00
[   18.941044] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
[   18.941051] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   18.941056] usb usb1: Product: EHCI Host Controller
[   18.941061] usb usb1: Manufacturer: Linux 3.10-3-amd64 ehci_hcd
[   18.941065] usb usb1: SerialNumber: 0000:00:12.2
[   18.941302] hub 1-0:1.0: USB hub found
[   18.941314] hub 1-0:1.0: 5 ports detected
[   18.941740] ehci-pci 0000:00:13.2: EHCI Host Controller
[   18.941752] ehci-pci 0000:00:13.2: new USB bus registered, assigned bus number 2
[   18.941760] ehci-pci 0000:00:13.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   18.941775] ehci-pci 0000:00:13.2: debug port 1
[   18.941816] ehci-pci 0000:00:13.2: irq 17, io mem 0xfeb07000
[   18.952977] ehci-pci 0000:00:13.2: USB 2.0 started, EHCI 1.00
[   18.953028] usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
[   18.953034] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   18.953039] usb usb2: Product: EHCI Host Controller
[   18.953043] usb usb2: Manufacturer: Linux 3.10-3-amd64 ehci_hcd
[   18.953047] usb usb2: SerialNumber: 0000:00:13.2
[   18.953260] hub 2-0:1.0: USB hub found
[   18.953274] hub 2-0:1.0: 5 ports detected
[   18.953659] ehci-pci 0000:00:16.2: EHCI Host Controller
[   18.953671] ehci-pci 0000:00:16.2: new USB bus registered, assigned bus number 3
[   18.953679] ehci-pci 0000:00:16.2: applying AMD SB700/SB800/Hudson-2/3 EHCI dummy qh workaround
[   18.953694] ehci-pci 0000:00:16.2: debug port 1
[   18.953733] ehci-pci 0000:00:16.2: irq 17, io mem 0xfeb04000
[   18.964996] ehci-pci 0000:00:16.2: USB 2.0 started, EHCI 1.00
[   18.965036] usb usb3: New USB device found, idVendor=1d6b, idProduct=0002
[   18.965043] usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   18.965048] usb usb3: Product: EHCI Host Controller
[   18.965052] usb usb3: Manufacturer: Linux 3.10-3-amd64 ehci_hcd
[   18.965056] usb usb3: SerialNumber: 0000:00:16.2
[   18.965280] hub 3-0:1.0: USB hub found
[   18.965291] hub 3-0:1.0: 4 ports detected
[   18.965728] ohci_hcd 0000:00:12.0: OHCI Host Controller
[   18.965746] ohci_hcd 0000:00:12.0: new USB bus registered, assigned bus number 4
[   18.965804] ohci_hcd 0000:00:12.0: irq 18, io mem 0xfeb0a000
[   19.025039] usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
[   19.025048] usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.025054] usb usb4: Product: OHCI Host Controller
[   19.025058] usb usb4: Manufacturer: Linux 3.10-3-amd64 ohci_hcd
[   19.025062] usb usb4: SerialNumber: 0000:00:12.0
[   19.025288] hub 4-0:1.0: USB hub found
[   19.025300] hub 4-0:1.0: 5 ports detected
[   19.025679] ohci_hcd 0000:00:13.0: OHCI Host Controller
[   19.025691] ohci_hcd 0000:00:13.0: new USB bus registered, assigned bus number 5
[   19.025719] ohci_hcd 0000:00:13.0: irq 18, io mem 0xfeb08000
[   19.085047] usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
[   19.085054] usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.085059] usb usb5: Product: OHCI Host Controller
[   19.085063] usb usb5: Manufacturer: Linux 3.10-3-amd64 ohci_hcd
[   19.085067] usb usb5: SerialNumber: 0000:00:13.0
[   19.085274] hub 5-0:1.0: USB hub found
[   19.085284] hub 5-0:1.0: 5 ports detected
[   19.085646] ohci_hcd 0000:00:14.5: OHCI Host Controller
[   19.085657] ohci_hcd 0000:00:14.5: new USB bus registered, assigned bus number 6
[   19.085684] ohci_hcd 0000:00:14.5: irq 18, io mem 0xfeb06000
[   19.145049] usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
[   19.145056] usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.145060] usb usb6: Product: OHCI Host Controller
[   19.145064] usb usb6: Manufacturer: Linux 3.10-3-amd64 ohci_hcd
[   19.145068] usb usb6: SerialNumber: 0000:00:14.5
[   19.145279] hub 6-0:1.0: USB hub found
[   19.145290] hub 6-0:1.0: 2 ports detected
[   19.145595] ohci_hcd 0000:00:16.0: OHCI Host Controller
[   19.145606] ohci_hcd 0000:00:16.0: new USB bus registered, assigned bus number 7
[   19.145632] ohci_hcd 0000:00:16.0: irq 18, io mem 0xfeb05000
[   19.205068] usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
[   19.205075] usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[   19.205079] usb usb7: Product: OHCI Host Controller
[   19.205083] usb usb7: Manufacturer: Linux 3.10-3-amd64 ohci_hcd
[   19.205087] usb usb7: SerialNumber: 0000:00:16.0
[   19.205294] hub 7-0:1.0: USB hub found
[   19.205304] hub 7-0:1.0: 4 ports detected
[   19.206538] scsi4 : pata_atiixp
[   19.207078] scsi5 : pata_atiixp
[   19.207316] ata5: PATA max UDMA/100 cmd 0x1f0 ctl 0x3f6 bmdma 0xf000 irq 14
[   19.207323] ata6: PATA max UDMA/100 cmd 0x170 ctl 0x376 bmdma 0xf008 irq 15
[   19.389405] ata5.01: ATAPI: ASUS    BW-12B1ST, 1.03, max UDMA/100
[   19.389415] ata5.01: limited to UDMA/33 due to 40-wire cable
[   19.405426] ata5.01: configured for UDMA/33
[   19.409670] scsi 4:0:1:0: CD-ROM            ASUS     BW-12B1ST        1.03 PQ: 0 ANSI: 5
[   19.409930] scsi 4:0:1:0: Attached scsi generic sg4 type 5
[   19.419990] sr0: scsi3-mmc drive: 48x/48x writer dvd-ram cd/rw xa/form2 cdda tray
[   19.419996] cdrom: Uniform CD-ROM driver Revision: 3.20
[   19.420266] sr 4:0:1:0: Attached scsi CD-ROM sr0
[   19.473150] usb 5-5: new low-speed USB device number 2 using ohci_hcd
[   19.502890] md: md1 stopped.
[   19.504799] md: bind<sdb1>
[   19.505140] md: bind<sdc1>
[   19.505359] md: bind<sdd1>
[   19.573170] raid6: sse2x1    4164 MB/s
[   19.641187] raid6: sse2x2    7252 MB/s
[   19.642283] usb 5-5: New USB device found, idVendor=046d, idProduct=c03d
[   19.642288] usb 5-5: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[   19.642291] usb 5-5: Product: USB-PS/2 Optical Mouse
[   19.642293] usb 5-5: Manufacturer: Logitech
[   19.646241] hidraw: raw HID events driver (C) Jiri Kosina
[   19.650342] usbcore: registered new interface driver usbhid
[   19.650345] usbhid: USB HID core driver
[   19.652114] input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:00/0000:00:13.0/usb5/5-5/5-5:1.0/input/input1
[   19.652201] hid-generic 0003:046D:C03D.0001: input,hidraw0: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:13.0-5/input0
[   19.709208] raid6: sse2x4    9557 MB/s
[   19.709211] raid6: using algorithm sse2x4 (9557 MB/s)
[   19.709214] raid6: using ssse3x2 recovery algorithm
[   19.709423] xor: automatically using best checksumming function:
[   19.749230]    avx       : 10737.000 MB/sec
[   19.749428] async_tx: api initialized (async)
[   19.750354] md: raid6 personality registered for level 6
[   19.750356] md: raid5 personality registered for level 5
[   19.750358] md: raid4 personality registered for level 4
[   19.750633] md/raid:md1: device sdd1 operational as raid disk 0
[   19.750636] md/raid:md1: device sdc1 operational as raid disk 2
[   19.750638] md/raid:md1: device sdb1 operational as raid disk 1
[   19.750878] md/raid:md1: allocated 3282kB
[   19.750900] md/raid:md1: raid level 5 active with 3 out of 3 devices, algorithm 2
[   19.750902] RAID conf printout:
[   19.750903]  --- level:5 rd:3 wd:3
[   19.750904]  disk 0, o:1, dev:sdd1
[   19.750906]  disk 1, o:1, dev:sdb1
[   19.750907]  disk 2, o:1, dev:sdc1
[   19.750912] md1: Warning: Device sdb1 is misaligned
[   19.750914] md1: Warning: Device sdb1 is misaligned
[   19.750929] md1: detected capacity change from 0 to 4000792444928
[   19.750946] RAID conf printout:
[   19.750949]  --- level:5 rd:3 wd:3
[   19.750951]  disk 0, o:1, dev:sdd1
[   19.750953]  disk 1, o:1, dev:sdb1
[   19.750958]  disk 2, o:1, dev:sdc1
[   19.752089]  md1: unknown partition table
[   19.753852] device-mapper: uevent: version 1.0.3
[   19.753910] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised: dm-devel@redhat.com
[   20.244322] EXT4-fs (sda1): mounted filesystem with ordered data mode. Opts: (null)
[   20.510879] systemd-udevd[416]: starting version 204
[   20.589060] ACPI: acpi_idle registered with cpuidle
[   20.589385] input: Power Button as /devices/LNXSYSTM:00/device:00/PNP0C0C:00/input/input2
[   20.589392] ACPI: Power Button [PWRB]
[   20.590495] media: Linux media interface: v0.10
[   20.590684] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
[   20.590689] ACPI: Power Button [PWRF]
[   20.592418] Linux video capture interface: v2.00
[   20.616980] cx23885 driver version 0.0.3 loaded
[   20.629625] piix4_smbus 0000:00:14.0: SMBus Host Controller at 0xb00, revision 0
[   20.629854] CORE cx23885[0]: subsystem: 0070:7911, board: Hauppauge WinTV-HVR1250 [card=3,autodetected]
[   20.631376] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[   20.631429] sp5100_tco: PCI Revision ID: 0x42
[   20.631459] sp5100_tco: Using 0xfed80b00 for watchdog MMIO address
[   20.631470] sp5100_tco: Last reboot was not triggered by watchdog.
[   20.631519] sp5100_tco: initialized (0xffffc90000c4ab00). heartbeat=60 sec (nowayout=0)
[   20.633267] EDAC MC: Ver: 3.0.0
[   20.634743] MCE: In-kernel MCE decoding enabled.
[   20.635539] AMD64 EDAC driver v3.4.0
[   20.652112] input: HDA ATI SB Front Headphone as /devices/pci0000:00/0000:00:14.2/sound/card0/input4
[   20.652212] input: HDA ATI SB Line Out Side as /devices/pci0000:00/0000:00:14.2/sound/card0/input5
[   20.652282] input: HDA ATI SB Line Out CLFE as /devices/pci0000:00/0000:00:14.2/sound/card0/input6
[   20.652357] input: HDA ATI SB Line Out Surround as /devices/pci0000:00/0000:00:14.2/sound/card0/input7
[   20.652440] input: HDA ATI SB Line Out Front as /devices/pci0000:00/0000:00:14.2/sound/card0/input8
[   20.652608] input: HDA ATI SB Line as /devices/pci0000:00/0000:00:14.2/sound/card0/input9
[   20.652687] input: HDA ATI SB Rear Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input10
[   20.652753] input: HDA ATI SB Front Mic as /devices/pci0000:00/0000:00:14.2/sound/card0/input11
[   20.653427] EDAC amd64: DRAM ECC disabled.
[   20.653440] EDAC amd64: ECC disabled in the BIOS or no ECC capability, module will not load.
[   20.653440]  Either enable ECC checking or force module loading by setting 'ecc_enable_override'.
[   20.653440]  (Note that use of the override may cause unknown side effects.)
[   20.656497] input: PC Speaker as /devices/platform/pcspkr/input/input12
[   20.681091] alg: No test for __gcm-aes-aesni (__driver-gcm-aes-aesni)
[   20.696099] kvm: Nested Virtualization enabled
[   20.696106] kvm: Nested Paging enabled
[   20.756628] tveeprom 1-0050: Hauppauge model 79001, rev E1D9, serial# 3463031
[   20.756632] tveeprom 1-0050: MAC address is 00:0d:fe:34:d7:77
[   20.756635] tveeprom 1-0050: tuner model is Microtune MT2131 (idx 139, type 4)
[   20.756637] tveeprom 1-0050: TV standards NTSC(M) ATSC/DVB Digital (eeprom 0x88)
[   20.756639] tveeprom 1-0050: audio processor is CX23885 (idx 39)
[   20.756641] tveeprom 1-0050: decoder processor is CX23885 (idx 33)
[   20.756643] tveeprom 1-0050: has no radio, has IR receiver, has no IR transmitter
[   20.756644] cx23885[0]: hauppauge eeprom: model=79001
[   20.757988] hda-intel 0000:01:00.1: Handle VGA-switcheroo audio client
[   20.757992] hda-intel 0000:01:00.1: Force to non-snoop mode
[   20.758040] snd_hda_intel 0000:01:00.1: irq 74 for MSI/MSI-X
[   20.762290] cx25840 3-0044: cx23885 A/V decoder found @ 0x88 (cx23885[0])
[   20.764875] input: HDA ATI HDMI HDMI/DP,pcm=11 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input13
[   20.764950] input: HDA ATI HDMI HDMI/DP,pcm=10 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input14
[   20.765016] input: HDA ATI HDMI HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input15
[   20.765080] input: HDA ATI HDMI HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input16
[   20.765147] input: HDA ATI HDMI HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input17
[   20.765210] input: HDA ATI HDMI HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:02.0/0000:01:00.1/sound/card1/input18
[   20.772956] cx25840 3-0044: firmware: agent loaded v4l-cx23885-avcore-01.fw into memory
[   20.779777] acpi-cpufreq: overriding BIOS provided _PSD data
[   21.385543] cx25840 3-0044: loaded v4l-cx23885-avcore-01.fw firmware (16382 bytes)
[   21.406574] tuner 1-0061: Tuner -1 found with type(s) Radio TV.
[   21.411656] tuner-simple 1-0061: creating new instance
[   21.411659] tuner-simple 1-0061: type set to 0 (Temic PAL (4002 FH5))
[   21.412348] cx23885[0]: registered device video0 [v4l2]
[   21.412399] cx23885[0]: registered device vbi0
[   21.412792] cx23885[0]: registered ALSA audio device
[   21.440443] cx23885_dvb_register() allocating 1 frontend(s)
[   21.440446] cx23885[0]: cx23885 based dvb card
[   21.475959] MT2131: successfully identified at address 0x61
[   21.475963] DVB: registering new adapter (cx23885[0])
[   21.475967] cx23885 0000:03:00.0: DVB: registering adapter 0 frontend 0 (Samsung S5H1409 QAM/8VSB Frontend)...
[   21.476262] cx23885_dev_checkrevision() Hardware revision = 0xa4
[   21.476267] cx23885[0]/0: found at 0000:03:00.0, rev: 3, irq: 46, latency: 0, mmio: 0xfe600000
[   21.966280] EXT4-fs (sda1): re-mounted. Opts: (null)
[   22.042060] EXT4-fs (sda1): re-mounted. Opts: discard,errors=remount-ro
[   22.636824] fuse init (API version 7.22)
[   22.674247] loop: module loaded
[   22.701301] [drm] Initialized drm 1.1.0 20060810
[   22.714587] [drm] radeon kernel modesetting enabled.
[   22.716311] [drm] initializing kernel modesetting (PITCAIRN 0x1002:0x6819 0x1043:0x042C).
[   22.716359] [drm] register mmio base: 0xFEA00000
[   22.716362] [drm] register mmio size: 262144
[   22.716653] ATOM BIOS: 6819.15.17.0.1.AS07
[   22.716727] radeon 0000:01:00.0: VRAM: 2048M 0x0000000000000000 - 0x000000007FFFFFFF (2048M used)
[   22.716732] radeon 0000:01:00.0: GTT: 512M 0x0000000080000000 - 0x000000009FFFFFFF
[   22.737461] [drm] Detected VRAM RAM=2048M, BAR=256M
[   22.737466] [drm] RAM width 256bits DDR
[   22.737570] [TTM] Zone  kernel: Available graphics memory: 4081924 kiB
[   22.737571] [TTM] Zone   dma32: Available graphics memory: 2097152 kiB
[   22.737572] [TTM] Initializing pool allocator
[   22.737578] [TTM] Initializing DMA pool allocator
[   22.737619] [drm] radeon: 2048M of VRAM memory ready
[   22.737622] [drm] radeon: 512M of GTT memory ready.
[   22.740441] platform radeon_uvd.0: firmware: agent loaded radeon/TAHITI_uvd.bin into memory
[   22.740832] [drm] GART: num cpu pages 131072, num gpu pages 131072
[   22.749045] [drm] Loading PITCAIRN Microcode
[   22.749647] platform radeon_cp.0: firmware: agent loaded radeon/PITCAIRN_pfp.bin into memory
[   22.750996] platform radeon_cp.0: firmware: agent loaded radeon/PITCAIRN_me.bin into memory
[   22.751191] platform radeon_cp.0: firmware: agent loaded radeon/PITCAIRN_ce.bin into memory
[   22.751508] platform radeon_cp.0: firmware: agent loaded radeon/PITCAIRN_rlc.bin into memory
[   22.752250] platform radeon_cp.0: firmware: agent loaded radeon/PITCAIRN_mc.bin into memory
[   22.904691] EXT4-fs (md1): mounted filesystem with ordered data mode. Opts: user_xattr
[   23.223566] [drm] PCIE GART of 512M enabled (table at 0x0000000000276000).
[   23.223676] radeon 0000:01:00.0: WB enabled
[   23.223679] radeon 0000:01:00.0: fence driver on ring 0 use gpu addr 0x0000000080000c00 and cpu addr 0xffff880233712c00
[   23.223682] radeon 0000:01:00.0: fence driver on ring 1 use gpu addr 0x0000000080000c04 and cpu addr 0xffff880233712c04
[   23.223684] radeon 0000:01:00.0: fence driver on ring 2 use gpu addr 0x0000000080000c08 and cpu addr 0xffff880233712c08
[   23.223686] radeon 0000:01:00.0: fence driver on ring 3 use gpu addr 0x0000000080000c0c and cpu addr 0xffff880233712c0c
[   23.223688] radeon 0000:01:00.0: fence driver on ring 4 use gpu addr 0x0000000080000c10 and cpu addr 0xffff880233712c10
[   23.224683] radeon 0000:01:00.0: fence driver on ring 5 use gpu addr 0x0000000000075a18 and cpu addr 0xffffc90011535a18
[   23.224685] [drm] Supports vblank timestamp caching Rev 1 (10.10.2010).
[   23.224686] [drm] Driver supports precise vblank timestamp query.
[   23.224708] radeon 0000:01:00.0: irq 75 for MSI/MSI-X
[   23.224718] radeon 0000:01:00.0: radeon: using MSI.
[   23.224744] [drm] radeon: irq initialized.
[   23.243970] [drm] ring test on 0 succeeded in 3 usecs
[   23.243977] [drm] ring test on 1 succeeded in 1 usecs
[   23.243982] [drm] ring test on 2 succeeded in 1 usecs
[   23.244045] [drm] ring test on 3 succeeded in 2 usecs
[   23.244056] [drm] ring test on 4 succeeded in 1 usecs
[   23.429884] [drm] ring test on 5 succeeded in 2 usecs
[   23.429893] [drm] UVD initialized successfully.
[   23.432625] [drm] ib test on ring 0 succeeded in 0 usecs
[   23.432708] [drm] ib test on ring 1 succeeded in 0 usecs
[   23.432782] [drm] ib test on ring 2 succeeded in 0 usecs
[   23.432833] [drm] ib test on ring 3 succeeded in 0 usecs
[   23.432881] [drm] ib test on ring 4 succeeded in 1 usecs
[   23.586872] [drm] ib test on ring 5 succeeded
[   23.588560] [drm] Radeon Display Connectors
[   23.588563] [drm] Connector 0:
[   23.588564] [drm]   DP-1
[   23.588566] [drm]   HPD4
[   23.588568] [drm]   DDC: 0x6530 0x6530 0x6534 0x6534 0x6538 0x6538 0x653c 0x653c
[   23.588570] [drm]   Encoders:
[   23.588571] [drm]     DFP1: INTERNAL_UNIPHY2
[   23.588572] [drm] Connector 1:
[   23.588574] [drm]   HDMI-A-1
[   23.588575] [drm]   HPD5
[   23.588577] [drm]   DDC: 0x6540 0x6540 0x6544 0x6544 0x6548 0x6548 0x654c 0x654c
[   23.588578] [drm]   Encoders:
[   23.588579] [drm]     DFP2: INTERNAL_UNIPHY2
[   23.588581] [drm] Connector 2:
[   23.588582] [drm]   DVI-D-1
[   23.588583] [drm]   HPD1
[   23.588585] [drm]   DDC: 0x6570 0x6570 0x6574 0x6574 0x6578 0x6578 0x657c 0x657c
[   23.588586] [drm]   Encoders:
[   23.588588] [drm]     DFP3: INTERNAL_UNIPHY1
[   23.588589] [drm] Connector 3:
[   23.588590] [drm]   DVI-I-1
[   23.588591] [drm]   HPD6
[   23.588593] [drm]   DDC: 0x6580 0x6580 0x6584 0x6584 0x6588 0x6588 0x658c 0x658c
[   23.588594] [drm]   Encoders:
[   23.588595] [drm]     DFP4: INTERNAL_UNIPHY
[   23.588597] [drm]     CRT1: INTERNAL_KLDSCP_DAC1
[   23.588655] [drm] Internal thermal controller with fan control
[   23.588744] [drm] radeon: power management initialized
[   23.679692] [drm] fb mappable at 0xC1381000
[   23.679697] [drm] vram apper at 0xC0000000
[   23.679701] [drm] size 8294400
[   23.679704] [drm] fb depth is 24
[   23.679706] [drm]    pitch is 7680
[   23.679907] fbcon: radeondrmfb (fb0) is primary device
[   23.719884] Console: switching to colour frame buffer device 240x67
[   23.738935] radeon 0000:01:00.0: fb0: radeondrmfb frame buffer device
[   23.738938] radeon 0000:01:00.0: registered panic notifier
[   23.738967] [drm] Initialized radeon 2.33.0 20080528 for 0000:01:00.0 on minor 0
[   24.668351] Adding 8388604k swap on /home/swap1.  Priority:1 extents:253 across:85598204k 
[   26.245690] Adding 8388604k swap on /home/swap2.  Priority:1 extents:179 across:51716092k 
[   26.586178] Bridge firewalling registered
[   26.590659] device eth0 entered promiscuous mode
[   26.652574] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   26.657831] IPv6: ADDRCONF(NETDEV_UP): br0: link is not ready
[   31.667599] r8168: eth0: link up
[   31.667642] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   31.667800] br0: port 1(eth0) entered forwarding state
[   31.667809] br0: port 1(eth0) entered forwarding state
[   31.667832] IPv6: ADDRCONF(NETDEV_CHANGE): br0: link becomes ready
[   35.230540] RPC: Registered named UNIX socket transport module.
[   35.230543] RPC: Registered udp transport module.
[   35.230544] RPC: Registered tcp transport module.
[   35.230546] RPC: Registered tcp NFSv4.1 backchannel transport module.
[   35.236798] FS-Cache: Loaded
[   35.237636] Key type dns_resolver registered
[   35.248419] FS-Cache: Netfs 'nfs' registered for caching
[   35.259533] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[   37.306728] Bluetooth: Core ver 2.16
[   37.306751] NET: Registered protocol family 31
[   37.306754] Bluetooth: HCI device and connection manager initialized
[   37.306763] Bluetooth: HCI socket layer initialized
[   37.306768] Bluetooth: L2CAP socket layer initialized
[   37.306776] Bluetooth: SCO socket layer initialized
[   37.310912] Bluetooth: RFCOMM TTY layer initialized
[   37.310921] Bluetooth: RFCOMM socket layer initialized
[   37.310922] Bluetooth: RFCOMM ver 1.11
[   37.317751] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   37.317754] Bluetooth: BNEP filters: protocol multicast
[   37.317763] Bluetooth: BNEP socket layer initialized
[   37.367106] lp: driver loaded but no devices found
[   37.373575] ppdev: user-space parallel port driver
[   37.654581] Ebtables v2.0 registered
[   37.672280] ip_tables: (C) 2000-2006 Netfilter Core Team
[   37.685456] ip6_tables: (C) 2000-2006 Netfilter Core Team

--------------040409050800070602020509--
