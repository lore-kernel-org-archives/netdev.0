From: Fengguang Wu <fengguang.wu@intel.com>
Subject: WARNING: at net/core/neighbour.c:1545 neigh_table_init()
Date: Sat, 9 Feb 2013 20:39:38 +0800
Message-ID: <20130209123937.GA23420@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="x+6KMIRAuhnl3hBn"
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:46158 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522Ab3BIMkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Feb 2013 07:40:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below oops in linux-next and the first bad commit is

commit 455e987c0c2eb2c9045dc854559474cf41509965
Merge: 7c17e48 fd6da69
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Sat Dec 1 13:07:48 2012 -0800

    Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
    
    Pull perf fixes from Ingo Molnar:
     "This is mostly about unbreaking architectures that took the UAPI
      changes in the v3.7 cycle, plus misc fixes."
    
    * 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip:
      perf kvm: Fix building perf kvm on non x86 arches
      perf kvm: Rename perf_kvm to perf_kvm_stat
      perf: Make perf build for x86 with UAPI disintegration applied
      perf powerpc: Use uapi/unistd.h to fix build error
      tools: Pass the target in descend
      tools: Honour the O= flag when tool build called from a higher Makefile
      tools: Define a Makefile function to do subdir processing
      x86: Export asm/{svm.h,vmx.h,perf_regs.h}
      perf tools: Fix strbuf_addf() when the buffer needs to grow
      perf header: Fix numa topology printing
      perf, powerpc: Fix hw breakpoints returning -ENOSPC

[  108.102297] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[  108.105501] ------------[ cut here ]------------
[  108.106286] WARNING: at /c/kernel-tests/src/i386/net/core/neighbour.c:1545 neigh_table_init+0x16f/0x490()
[  108.107506] Hardware name: Bochs
[  108.108577] Pid: 1, comm: swapper Not tainted 3.8.0-rc5-01118-geee5035 #17
[  108.109506] Call Trace:
[  108.111179]  [<c1054e52>] warn_slowpath_common+0xf2/0x140
[  108.112064]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
[  108.112880]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
[  108.114164]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
[  108.115409]  [<c1054ff9>] warn_slowpath_null+0x39/0x50
[  108.116776]  [<c1acc2af>] neigh_table_init+0x16f/0x490
[  108.118169]  [<c1d0ba16>] ? mutex_unlock+0x16/0x30
[  108.119260]  [<c1a9cbf5>] ? proto_register+0x65/0x350
[  108.120016]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
[  108.121591]  [<c24d91c6>] dn_neigh_init+0x1b/0x2b
[  108.122305]  [<c24d8cce>] decnet_init+0x67/0xfc
[  108.123169]  [<c2472470>] do_one_initcall+0xf2/0x259
[  108.124259]  [<c24727fa>] kernel_init_freeable+0x223/0x393
[  108.125053]  [<c2471548>] ? loglevel+0x55/0x55
[  108.125712]  [<c1ce8b59>] kernel_init+0x19/0x200
[  108.126411]  [<c1d114fb>] ret_from_kernel_thread+0x1b/0x30
[  108.127194]  [<c1ce8b40>] ? rest_init+0x1f0/0x1f0
[  108.128351] ---[ end trace 1bcbb5f262552fec ]---

git bisect start v3.7 v3.6 --
git bisect good d66e6737d454553e1e62109d8298ede5351178a4  #    10  2013-02-09 11:28:24  Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
git bisect good e1b28147f684af67bfac989756c27c19859d3d4e  #    10  2013-02-09 11:58:58  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
git bisect good 37820108f395032e850e400139d956561a043c26  #    10  2013-02-09 12:28:59  Merge tag 'fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
git bisect good 60541d778e536455970281de25b2476e01c03aef  #    10  2013-02-09 12:59:29  unicore32: switch to generic sys_execve()
git bisect good 403f43c937d24832b18524f65415c0bbba6b5064  #    10  2013-02-09 13:29:53  team: bcast: convert return value of team_dev_queue_xmit() to bool correctly
git bisect good e23739b4ade80a3a7f87198f008f6c44a7cbc9fd  #    10  2013-02-09 14:00:15  Merge branch 'v4l_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media
git bisect  bad 455e987c0c2eb2c9045dc854559474cf41509965  #     0  2013-02-09 14:03:12  Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 50a53bbe1280839755cb120eef729ad150f644f9  #    10  2013-02-09 14:31:02  Merge branch 'akpm' (Fixes from Andrew)
git bisect good 31e06a42a34395111842707a85774151245447b7  #    10  2013-02-09 15:01:25  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/signal
git bisect good 97a13bf3fed11a7508d58b67515c4b83cce25540  #    10  2013-02-09 15:31:48  Merge tag 'perf-uapi-20121119' of git://git.infradead.org/users/dhowells/linux-headers into perf/urgent
git bisect good 8fdd78eeb11aeda018b22424f863344ef83a92d3  #    10  2013-02-09 16:02:24  Merge tag 'for-linus' of git://linux-c6x.org/git/projects/linux-c6x-upstreaming
git bisect good 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8  #    10  2013-02-09 16:32:42  Merge branch 'x86/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good 7321090f6751c9987c26a8c81c63680d16a614d7  #    10  2013-02-09 17:03:13  perf kvm: Fix building perf kvm on non x86 arches
git bisect good fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d  #    10  2013-02-09 17:33:37  Merge tag 'perf-urgent-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent
git bisect good 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8  #    30  2013-02-09 18:34:45  Merge branch 'x86/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d  #    30  2013-02-09 19:35:42  Merge tag 'perf-urgent-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent
git bisect  bad e347c988b34344c5192c2c238ad1c4bae51e975b  #     0  2013-02-09 19:51:48  Add linux-next specific files for 20130208

Thanks,
Fengguang

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-ant-6584-2013-02-08-19-09-59-3.8.0-rc5-01118-geee5035-17"

[    0.000000] Linux version 3.8.0-rc5-01118-geee5035 (kbuild@lkp-mb01) (gcc version 4.7.1 (GCC) ) #17 Fri Feb 8 19:07:06 CST 2013
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: non-PAE kernel!
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x100000
[    0.000000] initial memory mapped: [mem 0x00000000-0x02ffffff]
[    0.000000] Base memory trampoline at [c008f000] 8f000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x0fffdfff]
[    0.000000]  [mem 0x00000000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fbfffff] page 2M
[    0.000000]  [mem 0x0fc00000-0x0fffdfff] page 4k
[    0.000000] kernel direct mapping tables up to 0xfffdfff @ [mem 0x02ffa000-0x02ffffff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 129512(98%)
[    0.000000] RAMDISK: [mem 0x0e73f000-0x0ffeffff]
[    0.000000] ACPI: RSDP 000fd930 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 0fffff40 00040
[    0.000000] ACPI: SSDT 0ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 0ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00010000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65409
[    0.000000] free_area_init_node: node 0, pgdat c245e260, node_mem_map cdd3f200
[    0.000000]   Normal zone: 512 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 64897 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] e820: [mem 0x10000000-0xfffbffff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on bare hardware
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64897
[    0.000000] Kernel command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 branch=netdev-next/master log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=vmlinuz-2013-02-08-19-08-32-netdev-next:master:eee5035-eee5035-i386-randconfig-m022-9-ant noapic nolapic nohz=off BOOT_IMAGE=kernel-tests/kernels/i386-randconfig-m022/eee5035/vmlinuz-3.8.0-rc5-01118-geee5035
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 195292k/262136k available (13384k kernel code, 66344k reserved, 7544k data, 776k init, 0k highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfffcd000 - 0xfffff000   ( 200 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0xd07fe000 - 0xff7fe000   ( 752 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xcfffe000   ( 255 MB)
[    0.000000]       .init : 0xc2471000 - 0xc2533000   ( 776 kB)
[    0.000000]       .data : 0xc1d123ef - 0xc2470640   (7544 kB)
[    0.000000]       .text : 0xc1000000 - 0xc1d123ef   (13384 kB)
[    0.000000] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] CPU 0 irqstacks, hard=c0088000 soft=c008a000
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3807 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000] ODEBUG: 7 of 7 active objects replaced
[    0.000000] ODEBUG: selftest passed
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration failed
[    0.000000] tsc: Unable to calibrate against PIT
[    0.000000] tsc: using HPET reference calibration
[    0.000000] tsc: Detected 3192.030 MHz processor
[    0.071318] Calibrating delay loop (skipped), value calculated using timer frequency.. 6384.06 BogoMIPS (lpj=31920300)
[    0.074428] pid_max: default: 4096 minimum: 301
[    0.088563] Mount-cache hash table entries: 512
[    0.163291] mce: CPU supports 10 MCE banks
[    0.173267] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.173267] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.173267] tlb_flushall_shift: -1
[    0.176172] CPU: AMD QEMU Virtual CPU version 1.1.0 (fam: 06, model: 02, stepping: 03)
[    0.215337] ACPI: Core revision 20121018
[    1.063525] ACPI: setting ELCR to 0200 (from 0c00)
[    1.110644] Performance Events: Broken PMU hardware detected, using software events only.
[    1.114263] Failed to access perfctr msr (MSR c0010004 is 0)
[    1.304561] gcov: version magic: 0x3430372a
[    1.586201] RTC time: 11:08:06, date: 02/08/13
[    1.600778] NET: Registered protocol family 16
[    1.681370] i2c-core: driver [dummy] registered
[    1.713195] ACPI: bus type pci registered
[    1.725747] PCI: PCI BIOS revision 2.10 entry at 0xfc78c, last bus=0
[    1.727418] PCI: Using configuration type 1 for base access
[    2.899589] bio: create slab <bio-0> at 0
[    2.926431] ACPI: Added _OSI(Module Device)
[    2.927526] ACPI: Added _OSI(Processor Device)
[    2.928629] ACPI: Added _OSI(3.0 _SCP Extensions)
[    2.930482] ACPI: Added _OSI(Processor Aggregator Device)
[    3.213323] ACPI: EC: Look up EC in DSDT
[    4.698200] ACPI: Interpreter enabled
[    4.700614] ACPI: (supports S0 S3 S5)
[    4.711458] ACPI: Using PIC for interrupt routing
[    6.527490] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    6.546325] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    6.548462] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    6.867176] pci_root PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    6.870420] pci_root PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    6.879154] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    6.880630] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    6.882454] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    6.884010] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    6.886468] PCI: root bus 00: using default resources
[    6.891573] pci_root PNP0A03:00: fail to add MMCONFIG information, can't access extended PCI configuration space under this bridge.
[    6.912026] PCI host bridge to bus 0000:00
[    6.914352] pci_bus 0000:00: root bus resource [bus 00-ff]
[    6.916013] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    6.917357] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffff]
[    6.920658] pci_bus 0000:00: scanning bus
[    6.926086] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    6.930000] pci 0000:00:00.0: calling quirk_mmio_always_on+0x0/0x20
[    6.948059] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    6.958748] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    6.972408] pci 0000:00:01.1: reg 20: [io  0xc1c0-0xc1cf]
[    6.981431] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    6.983013] pci 0000:00:01.3: calling acpi_pm_check_blacklist+0x0/0x80
[    6.991334] pci 0000:00:01.3: calling quirk_piix4_acpi+0x0/0x290
[    6.994142] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    6.995956] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    6.998497] pci 0000:00:01.3: calling pci_fixup_piix4_acpi+0x0/0x20
[    7.002711] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    7.007308] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    7.012115] pci 0000:00:02.0: reg 14: [mem 0xfebf0000-0xfebf0fff]
[    7.028408] pci 0000:00:02.0: reg 30: [mem 0xfebe0000-0xfebeffff pref]
[    7.032938] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    7.037260] pci 0000:00:03.0: reg 10: [mem 0xfeba0000-0xfebbffff]
[    7.042068] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    7.058287] pci 0000:00:03.0: reg 30: [mem 0xfebc0000-0xfebdffff pref]
[    7.063908] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    7.068628] pci 0000:00:04.0: reg 10: [io  0xc040-0xc07f]
[    7.073137] pci 0000:00:04.0: reg 14: [mem 0xfebf1000-0xfebf1fff]
[    7.093980] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    7.098677] pci 0000:00:05.0: reg 10: [io  0xc080-0xc0bf]
[    7.103154] pci 0000:00:05.0: reg 14: [mem 0xfebf2000-0xfebf2fff]
[    7.123965] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    7.128612] pci 0000:00:06.0: reg 10: [io  0xc0c0-0xc0ff]
[    7.133183] pci 0000:00:06.0: reg 14: [mem 0xfebf3000-0xfebf3fff]
[    7.153780] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    7.158489] pci 0000:00:07.0: reg 10: [io  0xc100-0xc13f]
[    7.163150] pci 0000:00:07.0: reg 14: [mem 0xfebf4000-0xfebf4fff]
[    7.183378] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    7.187974] pci 0000:00:08.0: reg 10: [io  0xc140-0xc17f]
[    7.191927] pci 0000:00:08.0: reg 14: [mem 0xfebf5000-0xfebf5fff]
[    7.212734] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    7.217400] pci 0000:00:09.0: reg 10: [io  0xc180-0xc1bf]
[    7.221958] pci 0000:00:09.0: reg 14: [mem 0xfebf6000-0xfebf6fff]
[    7.242093] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    7.245366] pci 0000:00:0a.0: reg 10: [mem 0xfebf7000-0xfebf700f]
[    7.263151] pci_bus 0000:00: fixups for bus
[    7.264978] pci_bus 0000:00: bus scan returning with max=00
[    7.266350] pci_bus 0000:00: on NUMA node 0
[    7.356333] ACPI _OSC control for PCIe not granted, disabling ASPM
[   11.708681] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[   11.748258] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[   11.787469] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[   11.825091] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[   11.858287] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[   11.884247] i2c-core: driver [88PM860x] registered
[   11.887888] i2c-core: driver [88PM80X] registered
[   11.892394] i2c-core: driver [stmpe-i2c] registered
[   11.895928] i2c-core: driver [tc3589x] registered
[   11.899563] i2c-core: driver [wm8350] registered
[   11.903785] i2c-core: driver [tps65217] registered
[   11.907144] i2c-core: driver [twl] registered
[   11.912540] i2c-core: driver [mc13xxx] registered
[   11.916008] i2c-core: driver [da9052] registered
[   11.919306] i2c-core: driver [lp8788] registered
[   11.922827] i2c-core: driver [da9055] registered
[   11.926193] i2c-core: driver [max8925] registered
[   11.933004] i2c-core: driver [max8997] registered
[   11.936425] i2c-core: driver [max8998] registered
[   11.940888] i2c-core: driver [pcf50633] registered
[   11.944341] i2c-core: driver [tps65090] registered
[   11.947789] i2c-core: driver [as3711] registered
[   11.978440] SCSI subsystem initialized
[   11.986507] libata version 3.00 loaded.
[   12.000360] Linux video capture interface: v2.00
[   12.007650] pps_core: LinuxPPS API ver. 1 registered
[   12.008778] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[   12.011902] PTP clock support registered
[   12.034562] PCI: Using ACPI for IRQ routing
[   12.036352] PCI: pci_cache_line_size set to 64 bytes
[   12.041559] pci 0000:00:01.1: BAR 0: reserving [io  0x01f0-0x01f7 flags 0x110] (d=0, p=0)
[   12.043548] pci 0000:00:01.1: BAR 1: reserving [io  0x03f6 flags 0x110] (d=0, p=0)
[   12.045288] pci 0000:00:01.1: BAR 2: reserving [io  0x0170-0x0177 flags 0x110] (d=0, p=0)
[   12.047050] pci 0000:00:01.1: BAR 3: reserving [io  0x0376 flags 0x110] (d=0, p=0)
[   12.048671] pci 0000:00:01.1: BAR 4: reserving [io  0xc1c0-0xc1cf flags 0x40101] (d=0, p=0)
[   12.051140] pci 0000:00:02.0: BAR 0: reserving [mem 0xfc000000-0xfdffffff flags 0x42208] (d=0, p=0)
[   12.053442] pci 0000:00:02.0: BAR 1: reserving [mem 0xfebf0000-0xfebf0fff flags 0x40200] (d=0, p=0)
[   12.055630] pci 0000:00:03.0: BAR 0: reserving [mem 0xfeba0000-0xfebbffff flags 0x40200] (d=0, p=0)
[   12.057558] pci 0000:00:03.0: BAR 1: reserving [io  0xc000-0xc03f flags 0x40101] (d=0, p=0)
[   12.060874] pci 0000:00:04.0: BAR 0: reserving [io  0xc040-0xc07f flags 0x40101] (d=0, p=0)
[   12.062700] pci 0000:00:04.0: BAR 1: reserving [mem 0xfebf1000-0xfebf1fff flags 0x40200] (d=0, p=0)
[   12.064814] pci 0000:00:05.0: BAR 0: reserving [io  0xc080-0xc0bf flags 0x40101] (d=0, p=0)
[   12.066600] pci 0000:00:05.0: BAR 1: reserving [mem 0xfebf2000-0xfebf2fff flags 0x40200] (d=0, p=0)
[   12.068855] pci 0000:00:06.0: BAR 0: reserving [io  0xc0c0-0xc0ff flags 0x40101] (d=0, p=0)
[   12.070566] pci 0000:00:06.0: BAR 1: reserving [mem 0xfebf3000-0xfebf3fff flags 0x40200] (d=0, p=0)
[   12.072741] pci 0000:00:07.0: BAR 0: reserving [io  0xc100-0xc13f flags 0x40101] (d=0, p=0)
[   12.074511] pci 0000:00:07.0: BAR 1: reserving [mem 0xfebf4000-0xfebf4fff flags 0x40200] (d=0, p=0)
[   12.076638] pci 0000:00:08.0: BAR 0: reserving [io  0xc140-0xc17f flags 0x40101] (d=0, p=0)
[   12.080588] pci 0000:00:08.0: BAR 1: reserving [mem 0xfebf5000-0xfebf5fff flags 0x40200] (d=0, p=0)
[   12.082774] pci 0000:00:09.0: BAR 0: reserving [io  0xc180-0xc1bf flags 0x40101] (d=0, p=0)
[   12.084570] pci 0000:00:09.0: BAR 1: reserving [mem 0xfebf6000-0xfebf6fff flags 0x40200] (d=0, p=0)
[   12.086714] pci 0000:00:0a.0: BAR 0: reserving [mem 0xfebf7000-0xfebf700f flags 0x40200] (d=0, p=0)
[   12.093713] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[   12.096038] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[   12.184380] NET: Registered protocol family 23
[   12.190971] NET: Registered protocol family 8
[   12.192144] NET: Registered protocol family 20
[   12.209089] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[   12.211595] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[   12.223365] Switching to clocksource hpet
[   12.232231] CE: hpet increased min_delta_ns to 5000 nsec
[   12.248687] FS-Cache: Loaded
[   12.262684] CacheFiles: Loaded
[   12.275060] pnp: PnP ACPI init
[   12.283176] ACPI: bus type pnp registered
[   12.315822] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[   12.342613] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[   12.374286] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[   12.393054] pnp 00:03: [dma 2]
[   12.403253] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[   12.439580] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[   12.475378] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[   12.575769] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[   12.642525] pnp: PnP ACPI: found 7 devices
[   12.643964] ACPI: ACPI bus type pnp unregistered
[   12.791918] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[   12.793269] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffff]
[   12.798682] NET: Registered protocol family 2
[   12.844041] TCP established hash table entries: 2048 (order: 2, 16384 bytes)
[   12.847619] TCP bind hash table entries: 2048 (order: 4, 90112 bytes)
[   12.856665] TCP: Hash tables configured (established 2048 bind 2048)
[   12.862296] TCP: reno registered
[   12.863952] UDP hash table entries: 128 (order: 1, 12288 bytes)
[   12.866636] UDP-Lite hash table entries: 128 (order: 1, 12288 bytes)
[   12.882079] NET: Registered protocol family 1
[   12.884622] pci 0000:00:00.0: calling quirk_natoma+0x0/0x60
[   12.885943] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[   12.887345] pci 0000:00:00.0: calling quirk_passive_release+0x0/0x120
[   12.889320] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[   12.893644] pci 0000:00:01.0: calling quirk_isa_dma_hangs+0x0/0x60
[   12.895038] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[   12.897228] pci 0000:00:02.0: calling pci_fixup_video+0x0/0x170
[   12.898905] pci 0000:00:02.0: Boot video device
[   12.901571] pci 0000:00:03.0: calling quirk_e100_interrupt+0x0/0x2e0
[   12.905069] PCI: CLS 0 bytes, default 64
[   12.956476] Trying to unpack rootfs image as initramfs...
[   62.105852] Freeing initrd memory: 25284k freed
[   62.342134] apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16ac)
[   62.343373] apm: overridden by ACPI.
[   62.365733] cryptomgr_test (16) used greatest stack depth: 7488 bytes left
[   62.427529] NatSemi SCx200 Driver
[   62.515946] Initializing RT-Tester: OK
[   73.989917] Switching to clocksource tsc
[   74.009288] HugeTLB registered 4 MB page size, pre-allocated 0 pages
[   74.397468] NET: Registered protocol family 38
[   74.403361] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 251)
[   74.405934] io scheduler noop registered
[   74.407225] io scheduler deadline registered (default)
[   74.409311] io scheduler cfq registered
[   74.523706] list_sort_test: start testing list_sort()
[   74.659533] xz_dec_test: module loaded
[   74.661989] xz_dec_test: Create a device node with 'mknod xz_dec_test c 250 0' and write .xz files to it.
[   74.688833] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   74.701767] i2c-core: driver [lm3630_bl] registered
[   74.714867] i2c-core: driver [adp8870_bl] using legacy suspend method
[   74.716323] i2c-core: driver [adp8870_bl] using legacy resume method
[   74.717679] i2c-core: driver [adp8870_bl] registered
[   74.742974] nvidiafb_setup START
[   74.760213] no IO addresses supplied
[   78.878386] HDLC line discipline maxframe=4096
[   78.879234] N_HDLC line discipline registered.
[   78.882593] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[   78.919332] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[   79.047856] Cyclades driver 2.6
[   79.052173] MOXA Intellio family driver version 6.0k
[   79.056660] RocketPort device driver module, version 2.09, 12-June-2003
[   79.059154] No rocketport ports found; unloading driver
[   79.062392] SyncLink GT
[   79.063528] SyncLink GT, tty major#247
[   79.074276] SyncLink GT no devices found
[   79.084780] lp: driver loaded but no devices found
[   79.116162] Non-volatile memory driver v1.3
[   79.117057] toshiba: not a supported Toshiba laptop
[   79.119362] ppdev: user-space parallel port driver
[   79.121074] scx200_gpio: no SCx200 gpio present
[   79.126256] platform pc8736x_gpio.0: NatSemi pc8736x GPIO Driver Initializing
[   79.127536] platform pc8736x_gpio.0: no device found
[   79.132866] nsc_gpio initializing
[   79.134117] telclk_interrupt = 0xf non-mcpbl0010 hw.
[   79.137379] smapi::smapi_init, ERROR invalid usSmapiID
[   79.138159] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is not available on this machine
[   79.139345] mwave: mwavedd::mwave_init: Error: Failed to initialize board data
[   79.141202] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   79.142281] Linux agpgart interface v0.103
[   79.163869] SyncLink PC Card driver $Revision: 4.34 $, tty major#246
[   80.006830] brd: module loaded
[   80.405563] loop: module loaded
[   80.459989] mtip32xx Version 1.2.6os3
[   80.491190] i2c-core: driver [ics932s401] registered
[   80.494151] lkdtm: No crash points registered, enable through debugfs
[   80.497536] i2c-core: driver [apds990x] registered
[   80.502356] i2c-core: driver [hmc6352] registered
[   80.505837] i2c-core: driver [at24] registered
[   80.509153] i2c-core: driver [eeprom] registered
[   80.523595] i2c-core: driver [max6875] registered
[   80.536424] i2c-core: driver [fsa9480] using legacy suspend method
[   80.537736] i2c-core: driver [fsa9480] using legacy resume method
[   80.538977] i2c-core: driver [fsa9480] registered
[   80.562365] i2c-core: driver [wm8994] registered
[   80.571895] i2c-core: driver [smsc] registered
[   80.608900] Uniform Multi-Platform E-IDE driver
[   80.676041] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[   80.693087] piix 0000:00:01.1: not 100% native mode: will probe irqs later
[   80.697574] PIIX_IDE 0000:00:01.1: enabling bus mastering
[   80.699459] PIIX_IDE 0000:00:01.1: setting latency timer to 64
[   80.702697]     ide0: BM-DMA at 0xc1c0-0xc1c7
[   80.706374]     ide1: BM-DMA at 0xc1c8-0xc1cf
[   80.708878] Probing IDE interface ide0...
[   81.347305] Probing IDE interface ide1...
[   82.134140] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[   82.866032] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[   82.873654] hdc: MWDMA2 mode selected
[   82.882770] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   82.885798] ide1 at 0x170-0x177,0x376 on irq 15
[   82.955533] ide_generic: please use "probe_mask=0x3f" module parameter for probing all legacy ISA IDE ports
[   82.957010] ide-cd driver 5.00
[   83.002429] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[   83.004051] cdrom: Uniform CD-ROM driver Revision: 3.20
[   83.076893] Loading iSCSI transport class v2.0-870.
[   83.127511] osst :I: Tape driver with OnStream support version 0.99.4
[   83.127511] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   83.199893] SSFDC read-only Flash Translation layer
[   83.203964] device id = 2440
[   83.205431] device id = 2480
[   83.206675] device id = 24c0
[   83.207868] device id = 24d0
[   83.209126] device id = 25a1
[   83.211684] device id = 2670
[   83.216748] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   83.236232] Could not find PAR responsible for SC520CDP Flash Bank #1
[   83.237582] Trying default address 0x8c00000
[   83.239820] SC520 CDP flash device: 0x800000 at 0x8800000
[   83.242478] Failed to ioremap_nocache
[   83.243408] Failed to ioremap_nocache
[   83.243996] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[   83.249549] slram: not enough parameters.
[   83.391139] onenand_wait: timeout! ctrl=0x0000 intr=0x0000
[   83.392208] OneNAND Manufacturer: Samsung (0xec)
[   83.393365] OneNAND 16MB 1.8V 16-bit (0x04)
[   83.393960] OneNAND version = 0x001e
[   83.394745] Lock scheme is Continuous Lock
[   83.398175] Scanning device for bad blocks
[   83.474194] Creating 1 MTD partitions on "OneNAND simulator":
[   83.476304] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[   83.537153] ftl_cs: FTL header not found.
[   83.606047] HSI/SSI char device loaded
[   83.648753] I2O subsystem v1.325
[   83.649888] i2o: max drivers = 8
[   83.671744] I2O Configuration OSM v1.323
[   83.696051] I2O Bus Adapter OSM v1.317
[   83.699764] I2O Block Device OSM v1.325
[   83.717866] Fusion MPT base driver 3.04.20
[   83.718974] Copyright (c) 1999-2008 LSI Corporation
[   83.722451] Fusion MPT SPI Host driver 3.04.20
[   83.742195] Fusion MPT SAS Host driver 3.04.20
[   83.845272] aoe: AoE v81 initialised.
[   83.865760] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[   83.908675] serio: i8042 KBD port at 0x60,0x64 irq 1
[   83.913714] serio: i8042 AUX port at 0x60,0x64 irq 12
[   84.035755] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[   84.182923] i2c-core: driver [ili210x_i2c] registered
[   84.186558] i2c-core: driver [max11801_ts] registered
[   84.213513] i2c-core: driver [mcs5000_ts] registered
[   84.216950] i2c-core: driver [mms114] registered
[   84.229785] i2c-core: driver [wacom_i2c] registered
[   84.252698] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   84.256593] i2c-core: driver [bma150] registered
[   84.263825] i2c-core: driver [kxtj9] registered
[   84.269476] i2c-core: driver [mma8450] registered
[   84.303330] wistron_btns: System unknown
[   84.308007] rtc_cmos 00:00: RTC can wake from S4
[   84.334562] rtc (null): alarm rollover: day
[   84.363218] rtc_cmos: dev (254:0)
[   84.364949] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   84.371925] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[   84.388626] i2c-core: driver [rtc-ds1307] registered
[   84.393675] i2c-core: driver [rtc-ds1374] registered
[   84.413092] i2c-core: driver [rtc-ds1672] registered
[   84.419280] i2c-core: driver [rtc-ds3232] registered
[   84.424202] i2c-core: driver [rtc-fm3130] registered
[   84.427745] i2c-core: driver [rtc-isl1208] registered
[   84.432637] i2c-core: driver [rtc-isl12022] registered
[   84.436211] i2c-core: driver [rtc-m41t80] registered
[   84.458780] i2c-core: driver [pcf8583] registered
[   84.467570] i2c-core: driver [rtc-rs5c372] registered
[   84.472554] i2c-core: driver [rtc-rx8581] registered
[   84.476093] i2c-core: driver [rtc-s35390a] registered
[   84.502025] i2c-core: driver [smbus_alert] registered
[   84.503492] i2c /dev entries driver
[   84.525342] piix4_smbus 0000:00:01.3: Using Interrupt 9 for SMBus.
[   84.527147] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[   84.574008] i2c-dev: adapter [SMBus PIIX4 adapter at b100] registered as minor 0
[   84.582128] i2c i2c-0: adapter [SMBus PIIX4 adapter at b100] registered
[   84.587123] i2c i2c-0: found normal entry for adapter 0, addr 0x69
[   84.594345] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=d2, DAT0=00, DAT1=00
[   84.704952] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=d2, DAT0=00, DAT1=00
[   84.708457] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=d3, DAT0=00, DAT1=00
[   84.722656] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=d3, DAT0=ff, DAT1=ff
[   84.728832] i2c i2c-0: found normal entry for adapter 0, addr 0x50
[   84.732522] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=a1, DAT0=ff, DAT1=ff
[   84.752401] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=a1, DAT0=00, DAT1=ff
[   84.755774] i2c i2c-0: Creating eeprom at 0x50
[   84.765550] i2c 0-0050: uevent
[   84.771941] eeprom 0-0050: probe
[   84.775983] i2c i2c-0: client [eeprom] registered with bus id 0-0050
[   84.777593] i2c i2c-0: found normal entry for adapter 0, addr 0x51
[   84.779445] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=a3, DAT0=00, DAT1=ff
[   84.802051] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=a3, DAT0=00, DAT1=ff
[   84.803879] i2c i2c-0: Creating eeprom at 0x51
[   84.833269] i2c 0-0051: uevent
[   84.837279] eeprom 0-0051: probe
[   84.839232] i2c i2c-0: client [eeprom] registered with bus id 0-0051
[   84.841789] i2c i2c-0: found normal entry for adapter 0, addr 0x52
[   84.843554] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=a5, DAT0=00, DAT1=ff
[   84.862145] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=a5, DAT0=00, DAT1=ff
[   84.864784] i2c i2c-0: Creating eeprom at 0x52
[   84.872320] i2c 0-0052: uevent
[   84.874642] eeprom 0-0052: probe
[   84.876758] i2c i2c-0: client [eeprom] registered with bus id 0-0052
[   84.877693] i2c i2c-0: found normal entry for adapter 0, addr 0x53
[   84.878809] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=a7, DAT0=00, DAT1=ff
[   84.948599] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input1
[   84.963902] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=a7, DAT0=00, DAT1=ff
[   84.965544] i2c i2c-0: Creating eeprom at 0x53
[   84.976922] i2c 0-0053: uevent
[   84.979683] eeprom 0-0053: probe
[   84.982216] i2c i2c-0: client [eeprom] registered with bus id 0-0053
[   84.983143] i2c i2c-0: found normal entry for adapter 0, addr 0x54
[   84.984414] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=a9, DAT0=00, DAT1=ff
[   85.002408] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=a9, DAT0=00, DAT1=ff
[   85.004262] i2c i2c-0: Creating eeprom at 0x54
[   85.016390] i2c 0-0054: uevent
[   85.020036] eeprom 0-0054: probe
[   85.023671] i2c i2c-0: client [eeprom] registered with bus id 0-0054
[   85.025028] i2c i2c-0: found normal entry for adapter 0, addr 0x55
[   85.026711] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=ab, DAT0=00, DAT1=ff
[   85.042109] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=ab, DAT0=00, DAT1=ff
[   85.043461] i2c i2c-0: Creating eeprom at 0x55
[   85.057303] i2c 0-0055: uevent
[   85.059949] eeprom 0-0055: probe
[   85.062222] i2c i2c-0: client [eeprom] registered with bus id 0-0055
[   85.063176] i2c i2c-0: found normal entry for adapter 0, addr 0x56
[   85.064730] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=ad, DAT0=00, DAT1=ff
[   85.081922] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=ad, DAT0=00, DAT1=ff
[   85.083664] i2c i2c-0: Creating eeprom at 0x56
[   85.088501] i2c 0-0056: uevent
[   85.092063] eeprom 0-0056: probe
[   85.093347] i2c i2c-0: client [eeprom] registered with bus id 0-0056
[   85.094451] i2c i2c-0: found normal entry for adapter 0, addr 0x57
[   85.096142] i2c i2c-0: Transaction (pre): CNT=04, CMD=07, ADD=af, DAT0=00, DAT1=ff
[   85.112161] i2c i2c-0: Transaction (post): CNT=04, CMD=07, ADD=af, DAT0=00, DAT1=ff
[   85.113701] i2c i2c-0: Creating eeprom at 0x57
[   85.119829] i2c 0-0057: uevent
[   85.124291] eeprom 0-0057: probe
[   85.125775] i2c i2c-0: Transaction (pre): CNT=08, CMD=80, ADD=af, DAT0=00, DAT1=ff
[   85.142438] i2c i2c-0: Transaction (post): CNT=08, CMD=80, ADD=af, DAT0=00, DAT1=ff
[   85.145150] i2c i2c-0: Transaction (pre): CNT=08, CMD=81, ADD=af, DAT0=00, DAT1=ff
[   85.162389] i2c i2c-0: Transaction (post): CNT=08, CMD=81, ADD=af, DAT0=00, DAT1=ff
[   85.164538] i2c i2c-0: Transaction (pre): CNT=08, CMD=82, ADD=af, DAT0=00, DAT1=ff
[   85.182263] i2c i2c-0: Transaction (post): CNT=08, CMD=82, ADD=af, DAT0=00, DAT1=ff
[   85.184269] i2c i2c-0: Transaction (pre): CNT=08, CMD=83, ADD=af, DAT0=00, DAT1=ff
[   85.203344] i2c i2c-0: Transaction (post): CNT=08, CMD=83, ADD=af, DAT0=00, DAT1=ff
[   85.206604] i2c i2c-0: client [eeprom] registered with bus id 0-0057
[   85.244002] i2c-parport-light: adapter type unspecified
[   85.246597] i2c-core: driver [cx25840] registered
[   85.258220] i2c-core: driver [tda7432] registered
[   85.261870] i2c-core: driver [saa6588] registered
[   85.264731] i2c-core: driver [tea6415c] registered
[   85.267479] i2c-core: driver [tea6420] registered
[   85.271188] i2c-core: driver [saa7115] registered
[   85.273965] i2c-core: driver [saa7127] registered
[   85.276784] i2c-core: driver [saa7185] registered
[   85.279467] i2c-core: driver [adv7180] using legacy suspend method
[   85.281212] i2c-core: driver [adv7180] using legacy resume method
[   85.282116] i2c-core: driver [adv7180] registered
[   85.292164] i2c-core: driver [adv7393] registered
[   85.295093] i2c-core: driver [vpx3220] registered
[   85.297896] i2c-core: driver [bt819] registered
[   85.301661] i2c-core: driver [bt866] registered
[   85.304479] i2c-core: driver [ks0127] registered
[   85.307190] i2c-core: driver [ths7303] registered
[   85.309914] i2c-core: driver [tvp514x] registered
[   85.313655] i2c-core: driver [tlv320aic23b] registered
[   85.324103] i2c-core: driver [wm8739] registered
[   85.326990] i2c-core: driver [upd64031a] registered
[   85.329660] i2c-core: driver [ak881x] registered
[   85.334154] i2c-core: driver [tuner] registered
[   85.335911] b2c2-flexcop: B2C2 FlexcopII/II(b)/III digital TV receiver chip loaded successfully
[   85.337754] saa7146: register extension 'budget_av'
[   85.344672] saa7146: register extension 'budget_patch dvb'
[   85.349938] saa7146: register extension 'av7110'
[   85.375014] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas
[   85.381707] Digital Devices PCIE bridge driver, Copyright (C) 2010-11 Digital Devices GmbH
[   85.392885] i2c-core: driver [saa6752hs] registered
[   85.394640] saa7130/34: v4l2 driver version 0, 2, 17 loaded
[   85.416489] i2c-core: driver [si4713] registered
[   85.424239] i2c-core: driver [saa7706h] registered
[   85.449340] pps pps0: new PPS source ktimer
[   85.452378] pps pps0: ktimer PPS source registered
[   85.453844] pps_ldisc: PPS line discipline registered
[   85.454862] pps_parport: parallel port PPS client
[   85.461608] Driver for 1-wire Dallas network protocol.
[   85.485202] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 2004-2005, Szabolcs Gyurko
[   85.502186] i2c-core: driver [ds2782-battery] registered
[   85.506618] i2c-core: driver [sbs-battery] using legacy suspend method
[   85.507895] i2c-core: driver [sbs-battery] registered
[   85.527164] i2c-core: driver [max17040] using legacy suspend method
[   85.528477] i2c-core: driver [max17040] using legacy resume method
[   85.529660] i2c-core: driver [max17040] registered
[   85.535174] i2c-core: driver [max17042] registered
[   85.548710] i2c-core: driver [lp8727] registered
[   85.554293] i2c-core: driver [bq2415x-charger] registered
[   85.558966] i2c-core: driver [w83793] registered
[   85.562175] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   85.564164] i2c i2c-0: Transaction (pre): CNT=00, CMD=83, ADD=58, DAT0=00, DAT1=ff
[   85.582126] i2c i2c-0: Transaction (post): CNT=00, CMD=83, ADD=58, DAT0=00, DAT1=ff
[   85.584341] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=59, DAT0=00, DAT1=ff
[   85.602155] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=59, DAT0=ff, DAT1=ff
[   85.604256] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=59, DAT0=ff, DAT1=ff
[   85.621588] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=59, DAT0=ff, DAT1=ff
[   85.622941] w83793: Detection failed at check vendor id
[   85.623898] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   85.625605] i2c i2c-0: Transaction (pre): CNT=00, CMD=0d, ADD=5a, DAT0=ff, DAT1=ff
[   85.641435] i2c i2c-0: Transaction (post): CNT=00, CMD=0d, ADD=5a, DAT0=ff, DAT1=ff
[   85.642739] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   85.661353] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   85.662604] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5b, DAT0=ff, DAT1=ff
[   85.681750] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5b, DAT0=ff, DAT1=ff
[   85.683037] w83793: Detection failed at check vendor id
[   85.683892] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   85.685450] i2c i2c-0: Transaction (pre): CNT=00, CMD=0d, ADD=5c, DAT0=ff, DAT1=ff
[   85.701747] i2c i2c-0: Transaction (post): CNT=00, CMD=0d, ADD=5c, DAT0=ff, DAT1=ff
[   85.703354] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5d, DAT0=ff, DAT1=ff
[   85.721733] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5d, DAT0=ff, DAT1=ff
[   85.723271] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5d, DAT0=ff, DAT1=ff
[   85.741739] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5d, DAT0=ff, DAT1=ff
[   85.743133] w83793: Detection failed at check vendor id
[   85.743915] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[   85.746627] i2c i2c-0: Transaction (pre): CNT=00, CMD=0d, ADD=5e, DAT0=ff, DAT1=ff
[   85.761694] i2c i2c-0: Transaction (post): CNT=00, CMD=0d, ADD=5e, DAT0=ff, DAT1=ff
[   85.763259] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5f, DAT0=ff, DAT1=ff
[   85.781527] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5f, DAT0=ff, DAT1=ff
[   85.782967] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5f, DAT0=ff, DAT1=ff
[   85.801386] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5f, DAT0=ff, DAT1=ff
[   85.802505] w83793: Detection failed at check vendor id
[   85.813939] i2c-core: driver [w83795] registered
[   85.815674] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   85.817233] i2c i2c-0: Transaction (pre): CNT=00, CMD=0d, ADD=58, DAT0=ff, DAT1=ff
[   85.831389] i2c i2c-0: Transaction (post): CNT=00, CMD=0d, ADD=58, DAT0=ff, DAT1=ff
[   85.832933] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=59, DAT0=ff, DAT1=ff
[   85.851765] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=59, DAT0=ff, DAT1=ff
[   85.853440] i2c i2c-0: w83795: Detection failed at addr 0x2c, check bank
[   85.854962] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   85.857080] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=5a, DAT0=ff, DAT1=ff
[   85.871705] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=5a, DAT0=ff, DAT1=ff
[   85.873331] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   85.891693] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   85.892989] i2c i2c-0: w83795: Detection failed at addr 0x2d, check bank
[   85.894137] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   85.895538] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=5c, DAT0=ff, DAT1=ff
[   85.912269] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=5c, DAT0=ff, DAT1=ff
[   85.915105] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5d, DAT0=ff, DAT1=ff
[   85.932289] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5d, DAT0=ff, DAT1=ff
[   85.934128] i2c i2c-0: w83795: Detection failed at addr 0x2e, check bank
[   85.935539] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[   85.937567] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=5e, DAT0=ff, DAT1=ff
[   85.952369] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=5e, DAT0=ff, DAT1=ff
[   85.954366] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5f, DAT0=ff, DAT1=ff
[   85.972152] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5f, DAT0=ff, DAT1=ff
[   85.973800] i2c i2c-0: w83795: Detection failed at addr 0x2f, check bank
[   85.978371] i2c-core: driver [w83781d] registered
[   85.981800] i2c i2c-0: found normal entry for adapter 0, addr 0x28
[   85.983899] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=50, DAT0=ff, DAT1=ff
[   86.002269] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=50, DAT0=ff, DAT1=ff
[   86.004322] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=51, DAT0=ff, DAT1=ff
[   86.022199] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=51, DAT0=ff, DAT1=ff
[   86.024047] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.025378] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[   86.027291] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=52, DAT0=ff, DAT1=ff
[   86.042202] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=52, DAT0=ff, DAT1=ff
[   86.044043] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=53, DAT0=ff, DAT1=ff
[   86.062260] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=53, DAT0=ff, DAT1=ff
[   86.064047] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.065352] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[   86.067244] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=54, DAT0=ff, DAT1=ff
[   86.082214] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=54, DAT0=ff, DAT1=ff
[   86.084121] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=55, DAT0=ff, DAT1=ff
[   86.102173] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=55, DAT0=ff, DAT1=ff
[   86.103849] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.105113] i2c i2c-0: found normal entry for adapter 0, addr 0x2b
[   86.106901] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=56, DAT0=ff, DAT1=ff
[   86.122267] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=56, DAT0=ff, DAT1=ff
[   86.124172] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=57, DAT0=ff, DAT1=ff
[   86.142366] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=57, DAT0=ff, DAT1=ff
[   86.144049] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.145373] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   86.147320] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[   86.162145] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[   86.163998] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[   86.182339] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[   86.184004] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.185357] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   86.187443] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[   86.202125] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[   86.204024] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[   86.222362] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[   86.224120] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.225398] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   86.227207] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[   86.242129] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[   86.243904] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[   86.262023] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[   86.263837] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.264999] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[   86.266848] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5e, DAT0=ff, DAT1=ff
[   86.282247] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5e, DAT0=ff, DAT1=ff
[   86.284183] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5f, DAT0=ff, DAT1=ff
[   86.302229] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5f, DAT0=ff, DAT1=ff
[   86.303943] i2c i2c-0: Detection of w83781d chip failed at step 3
[   86.308843] i2c-core: driver [ad7418] registered
[   86.314638] i2c-core: driver [adm1029] registered
[   86.316701] i2c i2c-0: found normal entry for adapter 0, addr 0x28
[   86.318798] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=50, DAT0=ff, DAT1=ff
[   86.342177] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=50, DAT0=ff, DAT1=ff
[   86.344245] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=51, DAT0=ff, DAT1=ff
[   86.362114] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=51, DAT0=ff, DAT1=ff
[   86.364102] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=51, DAT0=ff, DAT1=ff
[   86.382194] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=51, DAT0=ff, DAT1=ff
[   86.384177] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=51, DAT0=ff, DAT1=ff
[   86.402179] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=51, DAT0=ff, DAT1=ff
[   86.404150] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=51, DAT0=ff, DAT1=ff
[   86.422231] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=51, DAT0=ff, DAT1=ff
[   86.424219] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[   86.426225] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=52, DAT0=ff, DAT1=ff
[   86.442303] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=52, DAT0=ff, DAT1=ff
[   86.444257] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=53, DAT0=ff, DAT1=ff
[   86.462243] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=53, DAT0=ff, DAT1=ff
[   86.464211] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=53, DAT0=ff, DAT1=ff
[   86.482551] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=53, DAT0=ff, DAT1=ff
[   86.484547] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=53, DAT0=ff, DAT1=ff
[   86.502223] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=53, DAT0=ff, DAT1=ff
[   86.504181] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=53, DAT0=ff, DAT1=ff
[   86.522230] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=53, DAT0=ff, DAT1=ff
[   86.523966] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[   86.525958] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=54, DAT0=ff, DAT1=ff
[   86.543545] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=54, DAT0=ff, DAT1=ff
[   86.545424] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=55, DAT0=ff, DAT1=ff
[   86.562327] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=55, DAT0=ff, DAT1=ff
[   86.564336] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=55, DAT0=ff, DAT1=ff
[   86.582258] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=55, DAT0=ff, DAT1=ff
[   86.584115] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=55, DAT0=ff, DAT1=ff
[   86.601759] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=55, DAT0=ff, DAT1=ff
[   86.603124] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=55, DAT0=ff, DAT1=ff
[   86.622336] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=55, DAT0=ff, DAT1=ff
[   86.624131] i2c i2c-0: found normal entry for adapter 0, addr 0x2b
[   86.627127] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=56, DAT0=ff, DAT1=ff
[   86.642018] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=56, DAT0=ff, DAT1=ff
[   86.643518] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=57, DAT0=ff, DAT1=ff
[   86.663279] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=57, DAT0=ff, DAT1=ff
[   86.665439] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=57, DAT0=ff, DAT1=ff
[   86.682293] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=57, DAT0=ff, DAT1=ff
[   86.684176] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=57, DAT0=ff, DAT1=ff
[   86.702610] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=57, DAT0=ff, DAT1=ff
[   86.705912] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=57, DAT0=ff, DAT1=ff
[   86.722496] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=57, DAT0=ff, DAT1=ff
[   86.725628] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   86.727610] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   86.742548] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   86.744673] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=59, DAT0=ff, DAT1=ff
[   86.762505] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=59, DAT0=ff, DAT1=ff
[   86.764515] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=59, DAT0=ff, DAT1=ff
[   86.782605] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=59, DAT0=ff, DAT1=ff
[   86.784789] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=59, DAT0=ff, DAT1=ff
[   86.802531] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=59, DAT0=ff, DAT1=ff
[   86.804749] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=59, DAT0=ff, DAT1=ff
[   86.822629] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=59, DAT0=ff, DAT1=ff
[   86.824698] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   86.826731] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=5a, DAT0=ff, DAT1=ff
[   86.843392] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=5a, DAT0=ff, DAT1=ff
[   86.845565] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5b, DAT0=ff, DAT1=ff
[   86.862611] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5b, DAT0=ff, DAT1=ff
[   86.864865] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=5b, DAT0=ff, DAT1=ff
[   86.882612] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=5b, DAT0=ff, DAT1=ff
[   86.884814] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=5b, DAT0=ff, DAT1=ff
[   86.903352] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=5b, DAT0=ff, DAT1=ff
[   86.906177] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=5b, DAT0=ff, DAT1=ff
[   86.923335] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=5b, DAT0=ff, DAT1=ff
[   86.926162] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   86.928862] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=5c, DAT0=ff, DAT1=ff
[   86.952544] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=5c, DAT0=ff, DAT1=ff
[   86.954557] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5d, DAT0=ff, DAT1=ff
[   86.972622] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5d, DAT0=ff, DAT1=ff
[   86.974670] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=5d, DAT0=ff, DAT1=ff
[   86.992581] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=5d, DAT0=ff, DAT1=ff
[   86.994599] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=5d, DAT0=ff, DAT1=ff
[   87.012660] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=5d, DAT0=ff, DAT1=ff
[   87.014692] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=5d, DAT0=ff, DAT1=ff
[   87.034255] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=5d, DAT0=ff, DAT1=ff
[   87.036219] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[   87.038250] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=5e, DAT0=ff, DAT1=ff
[   87.052585] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=5e, DAT0=ff, DAT1=ff
[   87.054563] i2c i2c-0: Transaction (pre): CNT=08, CMD=0d, ADD=5f, DAT0=ff, DAT1=ff
[   87.072824] i2c i2c-0: Transaction (post): CNT=08, CMD=0d, ADD=5f, DAT0=ff, DAT1=ff
[   87.074807] i2c i2c-0: Transaction (pre): CNT=08, CMD=0e, ADD=5f, DAT0=ff, DAT1=ff
[   87.092481] i2c i2c-0: Transaction (post): CNT=08, CMD=0e, ADD=5f, DAT0=ff, DAT1=ff
[   87.094447] i2c i2c-0: Transaction (pre): CNT=08, CMD=06, ADD=5f, DAT0=ff, DAT1=ff
[   87.111991] i2c i2c-0: Transaction (post): CNT=08, CMD=06, ADD=5f, DAT0=ff, DAT1=ff
[   87.113780] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=5f, DAT0=ff, DAT1=ff
[   87.131944] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=5f, DAT0=ff, DAT1=ff
[   87.136305] i2c-core: driver [adm1031] registered
[   87.137879] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   87.139443] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   87.161435] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   87.162867] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[   87.181581] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[   87.182830] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[   87.202202] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[   87.203909] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   87.205759] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[   87.221513] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[   87.222792] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5b, DAT0=ff, DAT1=ff
[   87.241370] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5b, DAT0=ff, DAT1=ff
[   87.242611] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[   87.261274] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[   87.262440] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   87.263925] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[   87.281550] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[   87.282720] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[   87.302195] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[   87.304016] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[   87.322107] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[   87.326928] i2c-core: driver [adm9240] registered
[   87.328788] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   87.331880] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[   87.352019] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[   87.354108] i2c i2c-0: Transaction (pre): CNT=08, CMD=48, ADD=59, DAT0=ff, DAT1=ff
[   87.372254] i2c i2c-0: Transaction (post): CNT=08, CMD=48, ADD=59, DAT0=ff, DAT1=ff
[   87.374107] i2c i2c-0: detect fail: address match, 0x2c
[   87.375327] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   87.377319] i2c i2c-0: Transaction (pre): CNT=00, CMD=48, ADD=5a, DAT0=ff, DAT1=ff
[   87.392184] i2c i2c-0: Transaction (post): CNT=00, CMD=48, ADD=5a, DAT0=ff, DAT1=ff
[   87.394081] i2c i2c-0: Transaction (pre): CNT=08, CMD=48, ADD=5b, DAT0=ff, DAT1=ff
[   87.412145] i2c i2c-0: Transaction (post): CNT=08, CMD=48, ADD=5b, DAT0=ff, DAT1=ff
[   87.413699] i2c i2c-0: detect fail: address match, 0x2d
[   87.414707] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   87.416608] i2c i2c-0: Transaction (pre): CNT=00, CMD=48, ADD=5c, DAT0=ff, DAT1=ff
[   87.432077] i2c i2c-0: Transaction (post): CNT=00, CMD=48, ADD=5c, DAT0=ff, DAT1=ff
[   87.433862] i2c i2c-0: Transaction (pre): CNT=08, CMD=48, ADD=5d, DAT0=ff, DAT1=ff
[   87.452685] i2c i2c-0: Transaction (post): CNT=08, CMD=48, ADD=5d, DAT0=ff, DAT1=ff
[   87.454332] i2c i2c-0: detect fail: address match, 0x2e
[   87.455533] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[   87.457500] i2c i2c-0: Transaction (pre): CNT=00, CMD=48, ADD=5e, DAT0=ff, DAT1=ff
[   87.472480] i2c i2c-0: Transaction (post): CNT=00, CMD=48, ADD=5e, DAT0=ff, DAT1=ff
[   87.474377] i2c i2c-0: Transaction (pre): CNT=08, CMD=48, ADD=5f, DAT0=ff, DAT1=ff
[   87.492338] i2c i2c-0: Transaction (post): CNT=08, CMD=48, ADD=5f, DAT0=ff, DAT1=ff
[   87.494129] i2c i2c-0: detect fail: address match, 0x2f
[   87.498768] i2c-core: driver [ads7828] registered
[   87.504635] i2c-core: driver [adt7410] registered
[   87.506583] applesmc: supported laptop not found!
[   87.507619] applesmc: driver init failed (ret=-19)!
[   87.523296] i2c-core: driver [atxp1] registered
[   87.525248] i2c i2c-0: found normal entry for adapter 0, addr 0x37
[   87.527155] i2c i2c-0: Transaction (pre): CNT=04, CMD=48, ADD=6f, DAT0=ff, DAT1=ff
[   87.542255] i2c i2c-0: Transaction (post): CNT=04, CMD=48, ADD=6f, DAT0=ff, DAT1=ff
[   87.544100] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=6f, DAT0=ff, DAT1=ff
[   87.562241] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=6f, DAT0=ff, DAT1=ff
[   87.564122] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[   87.565934] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=9c, DAT0=ff, DAT1=ff
[   87.582127] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=9c, DAT0=ff, DAT1=ff
[   87.583926] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=9d, DAT0=ff, DAT1=ff
[   87.602164] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=9d, DAT0=ff, DAT1=ff
[   87.607252] i2c-core: driver [dme1737] registered
[   87.609162] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   87.612459] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[   87.632064] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[   87.634220] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[   87.652085] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[   87.653804] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=59, DAT0=ff, DAT1=ff
[   87.672169] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=59, DAT0=ff, DAT1=ff
[   87.674060] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   87.675932] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=5a, DAT0=ff, DAT1=ff
[   87.692186] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=5a, DAT0=ff, DAT1=ff
[   87.693894] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[   87.712344] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[   87.714128] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=5b, DAT0=ff, DAT1=ff
[   87.732198] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=5b, DAT0=ff, DAT1=ff
[   87.734027] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   87.735922] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[   87.752164] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[   87.753914] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[   87.772264] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[   87.774085] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=5d, DAT0=ff, DAT1=ff
[   87.791983] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=5d, DAT0=ff, DAT1=ff
[   87.797307] i2c-core: driver [ds620] registered
[   87.802670] i2c-core: driver [emc2103] registered
[   87.804581] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[   87.806542] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[   87.822024] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[   87.824148] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=5d, DAT0=ff, DAT1=ff
[   87.842972] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=5d, DAT0=ff, DAT1=ff
[   87.853309] i2c-core: driver [fschmd] registered
[   87.855143] i2c i2c-0: found normal entry for adapter 0, addr 0x73
[   87.857234] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=e7, DAT0=ff, DAT1=ff
[   87.871974] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=e7, DAT0=ff, DAT1=ff
[   87.873910] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=e7, DAT0=ff, DAT1=ff
[   87.891817] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=e7, DAT0=ff, DAT1=ff
[   87.893625] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=e7, DAT0=ff, DAT1=ff
[   87.912080] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=e7, DAT0=ff, DAT1=ff
[   87.913916] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=e7, DAT0=ff, DAT1=ff
[   87.932596] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=e7, DAT0=ff, DAT1=ff
[   87.939238] i2c-core: driver [gl520sm] registered
[   87.942748] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[   87.945305] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   87.962012] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=58, DAT0=ff, DAT1=ff
[   87.964089] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=59, DAT0=ff, DAT1=ff
[   87.982094] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=59, DAT0=ff, DAT1=ff
[   87.983777]  (null): Unknown chip type, skipping
[   87.984726] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[   87.986336] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=5a, DAT0=ff, DAT1=ff
[   88.001990] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=5a, DAT0=ff, DAT1=ff
[   88.003654] i2c i2c-0: Transaction (pre): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   88.021874] i2c i2c-0: Transaction (post): CNT=08, CMD=00, ADD=5b, DAT0=ff, DAT1=ff
[   88.023552]  (null): Unknown chip type, skipping
[   88.037755] i2c-core: driver [hih6130] registered
[   88.049141] i2c-core: driver [lm63] registered
[   88.053186] i2c i2c-0: found normal entry for adapter 0, addr 0x18
[   88.054983] i2c i2c-0: Transaction (pre): CNT=00, CMD=00, ADD=30, DAT0=ff, DAT1=ff
[   88.072074] i2c i2c-0: Transaction (post): CNT=00, CMD=00, ADD=30, DAT0=ff, DAT1=ff
[   88.073900] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[   88.091900] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[   88.093660] i2c i2c-0: Transaction (pre): CNT=08, CMD=ff, ADD=31, DAT0=ff, DAT1=ff
[   88.111863] i2c i2c-0: Transaction (post): CNT=08, CMD=ff, ADD=31, DAT0=ff, DAT1=ff
[   88.113547] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=31, DAT0=ff, DAT1=ff
[   88.131991] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=31, DAT0=ff, DAT1=ff
[   88.133642] i2c i2c-0: Transaction (pre): CNT=08, CMD=bf, ADD=31, DAT0=ff, DAT1=ff
[   88.151882] i2c i2c-0: Transaction (post): CNT=08, CMD=bf, ADD=31, DAT0=ff, DAT1=ff
[   88.153571] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=31, DAT0=ff, DAT1=ff
[   88.172612] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=31, DAT0=ff, DAT1=ff
[   88.174906] i2c i2c-0: Transaction (pre): CNT=08, CMD=16, ADD=31, DAT0=ff, DAT1=ff
[   88.192145] i2c i2c-0: Transaction (post): CNT=08, CMD=16, ADD=31, DAT0=ff, DAT1=ff
[   88.193478] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[   88.194642] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[   88.196136] i2c i2c-0: Transaction (pre): CNT=00, CMD=16, ADD=98, DAT0=ff, DAT1=ff
[   88.212071] i2c i2c-0: Transaction (post): CNT=00, CMD=16, ADD=98, DAT0=ff, DAT1=ff
[   88.213920] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[   88.232358] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[   88.234976] i2c i2c-0: Transaction (pre): CNT=08, CMD=ff, ADD=99, DAT0=ff, DAT1=ff
[   88.252403] i2c i2c-0: Transaction (post): CNT=08, CMD=ff, ADD=99, DAT0=ff, DAT1=ff
[   88.254817] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=99, DAT0=ff, DAT1=ff
[   88.272216] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=99, DAT0=ff, DAT1=ff
[   88.274339] i2c i2c-0: Transaction (pre): CNT=08, CMD=bf, ADD=99, DAT0=ff, DAT1=ff
[   88.292446] i2c i2c-0: Transaction (post): CNT=08, CMD=bf, ADD=99, DAT0=ff, DAT1=ff
[   88.294590] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=99, DAT0=ff, DAT1=ff
[   88.312382] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=99, DAT0=ff, DAT1=ff
[   88.314424] i2c i2c-0: Transaction (pre): CNT=08, CMD=16, ADD=99, DAT0=ff, DAT1=ff
[   88.332498] i2c i2c-0: Transaction (post): CNT=08, CMD=16, ADD=99, DAT0=ff, DAT1=ff
[   88.334575] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[   88.335782] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[   88.337660] i2c i2c-0: Transaction (pre): CNT=00, CMD=16, ADD=9c, DAT0=ff, DAT1=ff
[   88.352453] i2c i2c-0: Transaction (post): CNT=00, CMD=16, ADD=9c, DAT0=ff, DAT1=ff
[   88.354473] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[   88.372352] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[   88.374415] i2c i2c-0: Transaction (pre): CNT=08, CMD=ff, ADD=9d, DAT0=ff, DAT1=ff
[   88.392450] i2c i2c-0: Transaction (post): CNT=08, CMD=ff, ADD=9d, DAT0=ff, DAT1=ff
[   88.394457] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=9d, DAT0=ff, DAT1=ff
[   88.412521] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=9d, DAT0=ff, DAT1=ff
[   88.414608] i2c i2c-0: Transaction (pre): CNT=08, CMD=bf, ADD=9d, DAT0=ff, DAT1=ff
[   88.432507] i2c i2c-0: Transaction (post): CNT=08, CMD=bf, ADD=9d, DAT0=ff, DAT1=ff
[   88.434410] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=9d, DAT0=ff, DAT1=ff
[   88.452823] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=9d, DAT0=ff, DAT1=ff
[   88.454682] i2c i2c-0: Transaction (pre): CNT=08, CMD=16, ADD=9d, DAT0=ff, DAT1=ff
[   88.472568] i2c i2c-0: Transaction (post): CNT=08, CMD=16, ADD=9d, DAT0=ff, DAT1=ff
[   88.474483] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[   88.479755] i2c-core: driver [lm77] registered
[   88.483675] i2c i2c-0: found normal entry for adapter 0, addr 0x48
[   88.485839] i2c i2c-0: Transaction (pre): CNT=00, CMD=16, ADD=90, DAT0=ff, DAT1=ff
[   88.502372] i2c i2c-0: Transaction (post): CNT=00, CMD=16, ADD=90, DAT0=ff, DAT1=ff
[   88.504602] i2c i2c-0: Transaction (pre): CNT=0c, CMD=00, ADD=91, DAT0=ff, DAT1=ff
[   88.522388] i2c i2c-0: Transaction (post): CNT=0c, CMD=00, ADD=91, DAT0=ff, DAT1=ff
[   88.524478] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=91, DAT0=ff, DAT1=ff
[   88.542440] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=91, DAT0=ff, DAT1=ff
[   88.544564] i2c i2c-0: Transaction (pre): CNT=0c, CMD=02, ADD=91, DAT0=ff, DAT1=ff
[   88.562487] i2c i2c-0: Transaction (post): CNT=0c, CMD=02, ADD=91, DAT0=ff, DAT1=ff
[   88.564625] i2c i2c-0: Transaction (pre): CNT=0c, CMD=03, ADD=91, DAT0=ff, DAT1=ff
[   88.582455] i2c i2c-0: Transaction (post): CNT=0c, CMD=03, ADD=91, DAT0=ff, DAT1=ff
[   88.584557] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=91, DAT0=ff, DAT1=ff
[   88.602495] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=91, DAT0=ff, DAT1=ff
[   88.604675] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=91, DAT0=ff, DAT1=ff
[   88.622458] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=91, DAT0=ff, DAT1=ff
[   88.624558] i2c i2c-0: Transaction (pre): CNT=08, CMD=09, ADD=91, DAT0=ff, DAT1=ff
[   88.642433] i2c i2c-0: Transaction (post): CNT=08, CMD=09, ADD=91, DAT0=ff, DAT1=ff
[   88.644543] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0a, ADD=91, DAT0=ff, DAT1=ff
[   88.662397] i2c i2c-0: Transaction (post): CNT=0c, CMD=0a, ADD=91, DAT0=ff, DAT1=ff
[   88.664572] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0b, ADD=91, DAT0=ff, DAT1=ff
[   88.682503] i2c i2c-0: Transaction (post): CNT=0c, CMD=0b, ADD=91, DAT0=ff, DAT1=ff
[   88.684621] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0c, ADD=91, DAT0=ff, DAT1=ff
[   88.702604] i2c i2c-0: Transaction (post): CNT=0c, CMD=0c, ADD=91, DAT0=ff, DAT1=ff
[   88.704888] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0d, ADD=91, DAT0=ff, DAT1=ff
[   88.722055] i2c i2c-0: Transaction (post): CNT=0c, CMD=0d, ADD=91, DAT0=ff, DAT1=ff
[   88.723924] i2c i2c-0: Transaction (pre): CNT=08, CMD=11, ADD=91, DAT0=ff, DAT1=ff
[   88.741878] i2c i2c-0: Transaction (post): CNT=08, CMD=11, ADD=91, DAT0=ff, DAT1=ff
[   88.743478] i2c i2c-0: Transaction (pre): CNT=0c, CMD=12, ADD=91, DAT0=ff, DAT1=ff
[   88.761682] i2c i2c-0: Transaction (post): CNT=0c, CMD=12, ADD=91, DAT0=ff, DAT1=ff
[   88.763212] i2c i2c-0: Transaction (pre): CNT=0c, CMD=13, ADD=91, DAT0=ff, DAT1=ff
[   88.781906] i2c i2c-0: Transaction (post): CNT=0c, CMD=13, ADD=91, DAT0=ff, DAT1=ff
[   88.783571] i2c i2c-0: Transaction (pre): CNT=0c, CMD=14, ADD=91, DAT0=ff, DAT1=ff
[   88.803526] i2c i2c-0: Transaction (post): CNT=0c, CMD=14, ADD=91, DAT0=ff, DAT1=ff
[   88.805436] i2c i2c-0: Transaction (pre): CNT=0c, CMD=15, ADD=91, DAT0=ff, DAT1=ff
[   88.822196] i2c i2c-0: Transaction (post): CNT=0c, CMD=15, ADD=91, DAT0=ff, DAT1=ff
[   88.824003] i2c i2c-0: Transaction (pre): CNT=08, CMD=19, ADD=91, DAT0=ff, DAT1=ff
[   88.843092] i2c i2c-0: Transaction (post): CNT=08, CMD=19, ADD=91, DAT0=ff, DAT1=ff
[   88.845022] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1a, ADD=91, DAT0=ff, DAT1=ff
[   88.862379] i2c i2c-0: Transaction (post): CNT=0c, CMD=1a, ADD=91, DAT0=ff, DAT1=ff
[   88.865216] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1b, ADD=91, DAT0=ff, DAT1=ff
[   88.882260] i2c i2c-0: Transaction (post): CNT=0c, CMD=1b, ADD=91, DAT0=ff, DAT1=ff
[   88.884937] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1c, ADD=91, DAT0=ff, DAT1=ff
[   88.902211] i2c i2c-0: Transaction (post): CNT=0c, CMD=1c, ADD=91, DAT0=ff, DAT1=ff
[   88.904822] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1d, ADD=91, DAT0=ff, DAT1=ff
[   88.922012] i2c i2c-0: Transaction (post): CNT=0c, CMD=1d, ADD=91, DAT0=ff, DAT1=ff
[   88.923887] i2c i2c-0: Transaction (pre): CNT=08, CMD=21, ADD=91, DAT0=ff, DAT1=ff
[   88.942157] i2c i2c-0: Transaction (post): CNT=08, CMD=21, ADD=91, DAT0=ff, DAT1=ff
[   88.944131] i2c i2c-0: Transaction (pre): CNT=0c, CMD=22, ADD=91, DAT0=ff, DAT1=ff
[   88.961910] i2c i2c-0: Transaction (post): CNT=0c, CMD=22, ADD=91, DAT0=ff, DAT1=ff
[   88.963684] i2c i2c-0: Transaction (pre): CNT=0c, CMD=23, ADD=91, DAT0=ff, DAT1=ff
[   88.982414] i2c i2c-0: Transaction (post): CNT=0c, CMD=23, ADD=91, DAT0=ff, DAT1=ff
[   88.984320] i2c i2c-0: Transaction (pre): CNT=0c, CMD=24, ADD=91, DAT0=ff, DAT1=ff
[   89.001949] i2c i2c-0: Transaction (post): CNT=0c, CMD=24, ADD=91, DAT0=ff, DAT1=ff
[   89.003978] i2c i2c-0: Transaction (pre): CNT=0c, CMD=25, ADD=91, DAT0=ff, DAT1=ff
[   89.022268] i2c i2c-0: Transaction (post): CNT=0c, CMD=25, ADD=91, DAT0=ff, DAT1=ff
[   89.024090] i2c i2c-0: Transaction (pre): CNT=08, CMD=29, ADD=91, DAT0=ff, DAT1=ff
[   89.042932] i2c i2c-0: Transaction (post): CNT=08, CMD=29, ADD=91, DAT0=ff, DAT1=ff
[   89.044714] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2a, ADD=91, DAT0=ff, DAT1=ff
[   89.061914] i2c i2c-0: Transaction (post): CNT=0c, CMD=2a, ADD=91, DAT0=ff, DAT1=ff
[   89.063713] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2b, ADD=91, DAT0=ff, DAT1=ff
[   89.082139] i2c i2c-0: Transaction (post): CNT=0c, CMD=2b, ADD=91, DAT0=ff, DAT1=ff
[   89.084077] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2c, ADD=91, DAT0=ff, DAT1=ff
[   89.101961] i2c i2c-0: Transaction (post): CNT=0c, CMD=2c, ADD=91, DAT0=ff, DAT1=ff
[   89.103784] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2d, ADD=91, DAT0=ff, DAT1=ff
[   89.122002] i2c i2c-0: Transaction (post): CNT=0c, CMD=2d, ADD=91, DAT0=ff, DAT1=ff
[   89.123924] i2c i2c-0: Transaction (pre): CNT=08, CMD=31, ADD=91, DAT0=ff, DAT1=ff
[   89.141992] i2c i2c-0: Transaction (post): CNT=08, CMD=31, ADD=91, DAT0=ff, DAT1=ff
[   89.143756] i2c i2c-0: Transaction (pre): CNT=0c, CMD=32, ADD=91, DAT0=ff, DAT1=ff
[   89.161835] i2c i2c-0: Transaction (post): CNT=0c, CMD=32, ADD=91, DAT0=ff, DAT1=ff
[   89.163592] i2c i2c-0: Transaction (pre): CNT=0c, CMD=33, ADD=91, DAT0=ff, DAT1=ff
[   89.181926] i2c i2c-0: Transaction (post): CNT=0c, CMD=33, ADD=91, DAT0=ff, DAT1=ff
[   89.183740] i2c i2c-0: Transaction (pre): CNT=0c, CMD=34, ADD=91, DAT0=ff, DAT1=ff
[   89.201926] i2c i2c-0: Transaction (post): CNT=0c, CMD=34, ADD=91, DAT0=ff, DAT1=ff
[   89.203863] i2c i2c-0: Transaction (pre): CNT=0c, CMD=35, ADD=91, DAT0=ff, DAT1=ff
[   89.222189] i2c i2c-0: Transaction (post): CNT=0c, CMD=35, ADD=91, DAT0=ff, DAT1=ff
[   89.224012] i2c i2c-0: Transaction (pre): CNT=08, CMD=39, ADD=91, DAT0=ff, DAT1=ff
[   89.242001] i2c i2c-0: Transaction (post): CNT=08, CMD=39, ADD=91, DAT0=ff, DAT1=ff
[   89.243845] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3a, ADD=91, DAT0=ff, DAT1=ff
[   89.262948] i2c i2c-0: Transaction (post): CNT=0c, CMD=3a, ADD=91, DAT0=ff, DAT1=ff
[   89.265495] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3b, ADD=91, DAT0=ff, DAT1=ff
[   89.282116] i2c i2c-0: Transaction (post): CNT=0c, CMD=3b, ADD=91, DAT0=ff, DAT1=ff
[   89.284005] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3c, ADD=91, DAT0=ff, DAT1=ff
[   89.302136] i2c i2c-0: Transaction (post): CNT=0c, CMD=3c, ADD=91, DAT0=ff, DAT1=ff
[   89.303960] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3d, ADD=91, DAT0=ff, DAT1=ff
[   89.321878] i2c i2c-0: Transaction (post): CNT=0c, CMD=3d, ADD=91, DAT0=ff, DAT1=ff
[   89.323596] i2c i2c-0: Transaction (pre): CNT=08, CMD=41, ADD=91, DAT0=ff, DAT1=ff
[   89.341996] i2c i2c-0: Transaction (post): CNT=08, CMD=41, ADD=91, DAT0=ff, DAT1=ff
[   89.343828] i2c i2c-0: Transaction (pre): CNT=0c, CMD=42, ADD=91, DAT0=ff, DAT1=ff
[   89.361920] i2c i2c-0: Transaction (post): CNT=0c, CMD=42, ADD=91, DAT0=ff, DAT1=ff
[   89.363733] i2c i2c-0: Transaction (pre): CNT=0c, CMD=43, ADD=91, DAT0=ff, DAT1=ff
[   89.381933] i2c i2c-0: Transaction (post): CNT=0c, CMD=43, ADD=91, DAT0=ff, DAT1=ff
[   89.383749] i2c i2c-0: Transaction (pre): CNT=0c, CMD=44, ADD=91, DAT0=ff, DAT1=ff
[   89.401905] i2c i2c-0: Transaction (post): CNT=0c, CMD=44, ADD=91, DAT0=ff, DAT1=ff
[   89.403665] i2c i2c-0: Transaction (pre): CNT=0c, CMD=45, ADD=91, DAT0=ff, DAT1=ff
[   89.421971] i2c i2c-0: Transaction (post): CNT=0c, CMD=45, ADD=91, DAT0=ff, DAT1=ff
[   89.423783] i2c i2c-0: Transaction (pre): CNT=08, CMD=49, ADD=91, DAT0=ff, DAT1=ff
[   89.442834] i2c i2c-0: Transaction (post): CNT=08, CMD=49, ADD=91, DAT0=ff, DAT1=ff
[   89.445290] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4a, ADD=91, DAT0=ff, DAT1=ff
[   89.462567] i2c i2c-0: Transaction (post): CNT=0c, CMD=4a, ADD=91, DAT0=ff, DAT1=ff
[   89.464630] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4b, ADD=91, DAT0=ff, DAT1=ff
[   89.482528] i2c i2c-0: Transaction (post): CNT=0c, CMD=4b, ADD=91, DAT0=ff, DAT1=ff
[   89.484478] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4c, ADD=91, DAT0=ff, DAT1=ff
[   89.502067] i2c i2c-0: Transaction (post): CNT=0c, CMD=4c, ADD=91, DAT0=ff, DAT1=ff
[   89.504003] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4d, ADD=91, DAT0=ff, DAT1=ff
[   89.522043] i2c i2c-0: Transaction (post): CNT=0c, CMD=4d, ADD=91, DAT0=ff, DAT1=ff
[   89.523948] i2c i2c-0: Transaction (pre): CNT=08, CMD=51, ADD=91, DAT0=ff, DAT1=ff
[   89.542121] i2c i2c-0: Transaction (post): CNT=08, CMD=51, ADD=91, DAT0=ff, DAT1=ff
[   89.544126] i2c i2c-0: Transaction (pre): CNT=0c, CMD=52, ADD=91, DAT0=ff, DAT1=ff
[   89.561462] i2c i2c-0: Transaction (post): CNT=0c, CMD=52, ADD=91, DAT0=ff, DAT1=ff
[   89.562715] i2c i2c-0: Transaction (pre): CNT=0c, CMD=53, ADD=91, DAT0=ff, DAT1=ff
[   89.582275] i2c i2c-0: Transaction (post): CNT=0c, CMD=53, ADD=91, DAT0=ff, DAT1=ff
[   89.584328] i2c i2c-0: Transaction (pre): CNT=0c, CMD=54, ADD=91, DAT0=ff, DAT1=ff
[   89.602827] i2c i2c-0: Transaction (post): CNT=0c, CMD=54, ADD=91, DAT0=ff, DAT1=ff
[   89.605519] i2c i2c-0: Transaction (pre): CNT=0c, CMD=55, ADD=91, DAT0=ff, DAT1=ff
[   89.622275] i2c i2c-0: Transaction (post): CNT=0c, CMD=55, ADD=91, DAT0=ff, DAT1=ff
[   89.624075] i2c i2c-0: Transaction (pre): CNT=08, CMD=59, ADD=91, DAT0=ff, DAT1=ff
[   89.642287] i2c i2c-0: Transaction (post): CNT=08, CMD=59, ADD=91, DAT0=ff, DAT1=ff
[   89.644104] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5a, ADD=91, DAT0=ff, DAT1=ff
[   89.662317] i2c i2c-0: Transaction (post): CNT=0c, CMD=5a, ADD=91, DAT0=ff, DAT1=ff
[   89.664203] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5b, ADD=91, DAT0=ff, DAT1=ff
[   89.682330] i2c i2c-0: Transaction (post): CNT=0c, CMD=5b, ADD=91, DAT0=ff, DAT1=ff
[   89.684170] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5c, ADD=91, DAT0=ff, DAT1=ff
[   89.702448] i2c i2c-0: Transaction (post): CNT=0c, CMD=5c, ADD=91, DAT0=ff, DAT1=ff
[   89.704420] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5d, ADD=91, DAT0=ff, DAT1=ff
[   89.722195] i2c i2c-0: Transaction (post): CNT=0c, CMD=5d, ADD=91, DAT0=ff, DAT1=ff
[   89.723966] i2c i2c-0: Transaction (pre): CNT=08, CMD=61, ADD=91, DAT0=ff, DAT1=ff
[   89.742295] i2c i2c-0: Transaction (post): CNT=08, CMD=61, ADD=91, DAT0=ff, DAT1=ff
[   89.744271] i2c i2c-0: Transaction (pre): CNT=0c, CMD=62, ADD=91, DAT0=ff, DAT1=ff
[   89.762337] i2c i2c-0: Transaction (post): CNT=0c, CMD=62, ADD=91, DAT0=ff, DAT1=ff
[   89.764132] i2c i2c-0: Transaction (pre): CNT=0c, CMD=63, ADD=91, DAT0=ff, DAT1=ff
[   89.782212] i2c i2c-0: Transaction (post): CNT=0c, CMD=63, ADD=91, DAT0=ff, DAT1=ff
[   89.784100] i2c i2c-0: Transaction (pre): CNT=0c, CMD=64, ADD=91, DAT0=ff, DAT1=ff
[   89.802264] i2c i2c-0: Transaction (post): CNT=0c, CMD=64, ADD=91, DAT0=ff, DAT1=ff
[   89.804146] i2c i2c-0: Transaction (pre): CNT=0c, CMD=65, ADD=91, DAT0=ff, DAT1=ff
[   89.821623] i2c i2c-0: Transaction (post): CNT=0c, CMD=65, ADD=91, DAT0=ff, DAT1=ff
[   89.823426] i2c i2c-0: Transaction (pre): CNT=08, CMD=69, ADD=91, DAT0=ff, DAT1=ff
[   89.843037] i2c i2c-0: Transaction (post): CNT=08, CMD=69, ADD=91, DAT0=ff, DAT1=ff
[   89.844435] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6a, ADD=91, DAT0=ff, DAT1=ff
[   89.861915] i2c i2c-0: Transaction (post): CNT=0c, CMD=6a, ADD=91, DAT0=ff, DAT1=ff
[   89.863757] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6b, ADD=91, DAT0=ff, DAT1=ff
[   89.882093] i2c i2c-0: Transaction (post): CNT=0c, CMD=6b, ADD=91, DAT0=ff, DAT1=ff
[   89.883961] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6c, ADD=91, DAT0=ff, DAT1=ff
[   89.902116] i2c i2c-0: Transaction (post): CNT=0c, CMD=6c, ADD=91, DAT0=ff, DAT1=ff
[   89.904815] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6d, ADD=91, DAT0=ff, DAT1=ff
[   89.922460] i2c i2c-0: Transaction (post): CNT=0c, CMD=6d, ADD=91, DAT0=ff, DAT1=ff
[   89.924301] i2c i2c-0: Transaction (pre): CNT=08, CMD=71, ADD=91, DAT0=ff, DAT1=ff
[   89.942366] i2c i2c-0: Transaction (post): CNT=08, CMD=71, ADD=91, DAT0=ff, DAT1=ff
[   89.944267] i2c i2c-0: Transaction (pre): CNT=0c, CMD=72, ADD=91, DAT0=ff, DAT1=ff
[   89.962421] i2c i2c-0: Transaction (post): CNT=0c, CMD=72, ADD=91, DAT0=ff, DAT1=ff
[   89.964393] i2c i2c-0: Transaction (pre): CNT=0c, CMD=73, ADD=91, DAT0=ff, DAT1=ff
[   89.982732] i2c i2c-0: Transaction (post): CNT=0c, CMD=73, ADD=91, DAT0=ff, DAT1=ff
[   89.984712] i2c i2c-0: Transaction (pre): CNT=0c, CMD=74, ADD=91, DAT0=ff, DAT1=ff
[   90.002518] i2c i2c-0: Transaction (post): CNT=0c, CMD=74, ADD=91, DAT0=ff, DAT1=ff
[   90.004473] i2c i2c-0: Transaction (pre): CNT=0c, CMD=75, ADD=91, DAT0=ff, DAT1=ff
[   90.022740] i2c i2c-0: Transaction (post): CNT=0c, CMD=75, ADD=91, DAT0=ff, DAT1=ff
[   90.024714] i2c i2c-0: Transaction (pre): CNT=08, CMD=79, ADD=91, DAT0=ff, DAT1=ff
[   90.042137] i2c i2c-0: Transaction (post): CNT=08, CMD=79, ADD=91, DAT0=ff, DAT1=ff
[   90.044918] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7a, ADD=91, DAT0=ff, DAT1=ff
[   90.062271] i2c i2c-0: Transaction (post): CNT=0c, CMD=7a, ADD=91, DAT0=ff, DAT1=ff
[   90.064234] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7b, ADD=91, DAT0=ff, DAT1=ff
[   90.082226] i2c i2c-0: Transaction (post): CNT=0c, CMD=7b, ADD=91, DAT0=ff, DAT1=ff
[   90.084123] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7c, ADD=91, DAT0=ff, DAT1=ff
[   90.102051] i2c i2c-0: Transaction (post): CNT=0c, CMD=7c, ADD=91, DAT0=ff, DAT1=ff
[   90.103804] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7d, ADD=91, DAT0=ff, DAT1=ff
[   90.122093] i2c i2c-0: Transaction (post): CNT=0c, CMD=7d, ADD=91, DAT0=ff, DAT1=ff
[   90.123815] i2c i2c-0: Transaction (pre): CNT=08, CMD=81, ADD=91, DAT0=ff, DAT1=ff
[   90.141904] i2c i2c-0: Transaction (post): CNT=08, CMD=81, ADD=91, DAT0=ff, DAT1=ff
[   90.143637] i2c i2c-0: Transaction (pre): CNT=0c, CMD=82, ADD=91, DAT0=ff, DAT1=ff
[   90.161978] i2c i2c-0: Transaction (post): CNT=0c, CMD=82, ADD=91, DAT0=ff, DAT1=ff
[   90.163781] i2c i2c-0: Transaction (pre): CNT=0c, CMD=83, ADD=91, DAT0=ff, DAT1=ff
[   90.182960] i2c i2c-0: Transaction (post): CNT=0c, CMD=83, ADD=91, DAT0=ff, DAT1=ff
[   90.184686] i2c i2c-0: Transaction (pre): CNT=0c, CMD=84, ADD=91, DAT0=ff, DAT1=ff
[   90.201889] i2c i2c-0: Transaction (post): CNT=0c, CMD=84, ADD=91, DAT0=ff, DAT1=ff
[   90.203640] i2c i2c-0: Transaction (pre): CNT=0c, CMD=85, ADD=91, DAT0=ff, DAT1=ff
[   90.222074] i2c i2c-0: Transaction (post): CNT=0c, CMD=85, ADD=91, DAT0=ff, DAT1=ff
[   90.223772] i2c i2c-0: Transaction (pre): CNT=08, CMD=89, ADD=91, DAT0=ff, DAT1=ff
[   90.241920] i2c i2c-0: Transaction (post): CNT=08, CMD=89, ADD=91, DAT0=ff, DAT1=ff
[   90.243638] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8a, ADD=91, DAT0=ff, DAT1=ff
[   90.262099] i2c i2c-0: Transaction (post): CNT=0c, CMD=8a, ADD=91, DAT0=ff, DAT1=ff
[   90.264165] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8b, ADD=91, DAT0=ff, DAT1=ff
[   90.282339] i2c i2c-0: Transaction (post): CNT=0c, CMD=8b, ADD=91, DAT0=ff, DAT1=ff
[   90.284130] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8c, ADD=91, DAT0=ff, DAT1=ff
[   90.302088] i2c i2c-0: Transaction (post): CNT=0c, CMD=8c, ADD=91, DAT0=ff, DAT1=ff
[   90.303802] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8d, ADD=91, DAT0=ff, DAT1=ff
[   90.322061] i2c i2c-0: Transaction (post): CNT=0c, CMD=8d, ADD=91, DAT0=ff, DAT1=ff
[   90.323911] i2c i2c-0: Transaction (pre): CNT=08, CMD=91, ADD=91, DAT0=ff, DAT1=ff
[   90.342090] i2c i2c-0: Transaction (post): CNT=08, CMD=91, ADD=91, DAT0=ff, DAT1=ff
[   90.343868] i2c i2c-0: Transaction (pre): CNT=0c, CMD=92, ADD=91, DAT0=ff, DAT1=ff
[   90.362073] i2c i2c-0: Transaction (post): CNT=0c, CMD=92, ADD=91, DAT0=ff, DAT1=ff
[   90.363770] i2c i2c-0: Transaction (pre): CNT=0c, CMD=93, ADD=91, DAT0=ff, DAT1=ff
[   90.382153] i2c i2c-0: Transaction (post): CNT=0c, CMD=93, ADD=91, DAT0=ff, DAT1=ff
[   90.383908] i2c i2c-0: Transaction (pre): CNT=0c, CMD=94, ADD=91, DAT0=ff, DAT1=ff
[   90.401932] i2c i2c-0: Transaction (post): CNT=0c, CMD=94, ADD=91, DAT0=ff, DAT1=ff
[   90.403662] i2c i2c-0: Transaction (pre): CNT=0c, CMD=95, ADD=91, DAT0=ff, DAT1=ff
[   90.421864] i2c i2c-0: Transaction (post): CNT=0c, CMD=95, ADD=91, DAT0=ff, DAT1=ff
[   90.423611] i2c i2c-0: Transaction (pre): CNT=08, CMD=99, ADD=91, DAT0=ff, DAT1=ff
[   90.441990] i2c i2c-0: Transaction (post): CNT=08, CMD=99, ADD=91, DAT0=ff, DAT1=ff
[   90.443718] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9a, ADD=91, DAT0=ff, DAT1=ff
[   90.461922] i2c i2c-0: Transaction (post): CNT=0c, CMD=9a, ADD=91, DAT0=ff, DAT1=ff
[   90.463634] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9b, ADD=91, DAT0=ff, DAT1=ff
[   90.482374] i2c i2c-0: Transaction (post): CNT=0c, CMD=9b, ADD=91, DAT0=ff, DAT1=ff
[   90.484160] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9c, ADD=91, DAT0=ff, DAT1=ff
[   90.501921] i2c i2c-0: Transaction (post): CNT=0c, CMD=9c, ADD=91, DAT0=ff, DAT1=ff
[   90.503526] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9d, ADD=91, DAT0=ff, DAT1=ff
[   90.521945] i2c i2c-0: Transaction (post): CNT=0c, CMD=9d, ADD=91, DAT0=ff, DAT1=ff
[   90.523629] i2c i2c-0: Transaction (pre): CNT=08, CMD=a1, ADD=91, DAT0=ff, DAT1=ff
[   90.542261] i2c i2c-0: Transaction (post): CNT=08, CMD=a1, ADD=91, DAT0=ff, DAT1=ff
[   90.544105] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a2, ADD=91, DAT0=ff, DAT1=ff
[   90.562276] i2c i2c-0: Transaction (post): CNT=0c, CMD=a2, ADD=91, DAT0=ff, DAT1=ff
[   90.564317] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a3, ADD=91, DAT0=ff, DAT1=ff
[   90.582137] i2c i2c-0: Transaction (post): CNT=0c, CMD=a3, ADD=91, DAT0=ff, DAT1=ff
[   90.584002] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a4, ADD=91, DAT0=ff, DAT1=ff
[   90.602084] i2c i2c-0: Transaction (post): CNT=0c, CMD=a4, ADD=91, DAT0=ff, DAT1=ff
[   90.603786] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a5, ADD=91, DAT0=ff, DAT1=ff
[   90.622110] i2c i2c-0: Transaction (post): CNT=0c, CMD=a5, ADD=91, DAT0=ff, DAT1=ff
[   90.623797] i2c i2c-0: Transaction (pre): CNT=08, CMD=a9, ADD=91, DAT0=ff, DAT1=ff
[   90.642146] i2c i2c-0: Transaction (post): CNT=08, CMD=a9, ADD=91, DAT0=ff, DAT1=ff
[   90.643870] i2c i2c-0: Transaction (pre): CNT=0c, CMD=aa, ADD=91, DAT0=ff, DAT1=ff
[   90.662058] i2c i2c-0: Transaction (post): CNT=0c, CMD=aa, ADD=91, DAT0=ff, DAT1=ff
[   90.663889] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ab, ADD=91, DAT0=ff, DAT1=ff
[   90.682115] i2c i2c-0: Transaction (post): CNT=0c, CMD=ab, ADD=91, DAT0=ff, DAT1=ff
[   90.683795] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ac, ADD=91, DAT0=ff, DAT1=ff
[   90.702135] i2c i2c-0: Transaction (post): CNT=0c, CMD=ac, ADD=91, DAT0=ff, DAT1=ff
[   90.703839] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ad, ADD=91, DAT0=ff, DAT1=ff
[   90.722088] i2c i2c-0: Transaction (post): CNT=0c, CMD=ad, ADD=91, DAT0=ff, DAT1=ff
[   90.723772] i2c i2c-0: Transaction (pre): CNT=08, CMD=b1, ADD=91, DAT0=ff, DAT1=ff
[   90.742177] i2c i2c-0: Transaction (post): CNT=08, CMD=b1, ADD=91, DAT0=ff, DAT1=ff
[   90.743902] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b2, ADD=91, DAT0=ff, DAT1=ff
[   90.761829] i2c i2c-0: Transaction (post): CNT=0c, CMD=b2, ADD=91, DAT0=ff, DAT1=ff
[   90.763091] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b3, ADD=91, DAT0=ff, DAT1=ff
[   90.782322] i2c i2c-0: Transaction (post): CNT=0c, CMD=b3, ADD=91, DAT0=ff, DAT1=ff
[   90.784198] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b4, ADD=91, DAT0=ff, DAT1=ff
[   90.802538] i2c i2c-0: Transaction (post): CNT=0c, CMD=b4, ADD=91, DAT0=ff, DAT1=ff
[   90.804409] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b5, ADD=91, DAT0=ff, DAT1=ff
[   90.822277] i2c i2c-0: Transaction (post): CNT=0c, CMD=b5, ADD=91, DAT0=ff, DAT1=ff
[   90.824193] i2c i2c-0: Transaction (pre): CNT=08, CMD=b9, ADD=91, DAT0=ff, DAT1=ff
[   90.842971] i2c i2c-0: Transaction (post): CNT=08, CMD=b9, ADD=91, DAT0=ff, DAT1=ff
[   90.844796] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ba, ADD=91, DAT0=ff, DAT1=ff
[   90.862161] i2c i2c-0: Transaction (post): CNT=0c, CMD=ba, ADD=91, DAT0=ff, DAT1=ff
[   90.864077] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bb, ADD=91, DAT0=ff, DAT1=ff
[   90.882206] i2c i2c-0: Transaction (post): CNT=0c, CMD=bb, ADD=91, DAT0=ff, DAT1=ff
[   90.883962] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bc, ADD=91, DAT0=ff, DAT1=ff
[   90.902156] i2c i2c-0: Transaction (post): CNT=0c, CMD=bc, ADD=91, DAT0=ff, DAT1=ff
[   90.903939] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bd, ADD=91, DAT0=ff, DAT1=ff
[   90.922234] i2c i2c-0: Transaction (post): CNT=0c, CMD=bd, ADD=91, DAT0=ff, DAT1=ff
[   90.924091] i2c i2c-0: Transaction (pre): CNT=08, CMD=c1, ADD=91, DAT0=ff, DAT1=ff
[   90.942129] i2c i2c-0: Transaction (post): CNT=08, CMD=c1, ADD=91, DAT0=ff, DAT1=ff
[   90.943989] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c2, ADD=91, DAT0=ff, DAT1=ff
[   90.962075] i2c i2c-0: Transaction (post): CNT=0c, CMD=c2, ADD=91, DAT0=ff, DAT1=ff
[   90.963821] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c3, ADD=91, DAT0=ff, DAT1=ff
[   90.982546] i2c i2c-0: Transaction (post): CNT=0c, CMD=c3, ADD=91, DAT0=ff, DAT1=ff
[   90.984321] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c4, ADD=91, DAT0=ff, DAT1=ff
[   91.002121] i2c i2c-0: Transaction (post): CNT=0c, CMD=c4, ADD=91, DAT0=ff, DAT1=ff
[   91.003964] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c5, ADD=91, DAT0=ff, DAT1=ff
[   91.022097] i2c i2c-0: Transaction (post): CNT=0c, CMD=c5, ADD=91, DAT0=ff, DAT1=ff
[   91.023852] i2c i2c-0: Transaction (pre): CNT=08, CMD=c9, ADD=91, DAT0=ff, DAT1=ff
[   91.042302] i2c i2c-0: Transaction (post): CNT=08, CMD=c9, ADD=91, DAT0=ff, DAT1=ff
[   91.044183] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ca, ADD=91, DAT0=ff, DAT1=ff
[   91.062262] i2c i2c-0: Transaction (post): CNT=0c, CMD=ca, ADD=91, DAT0=ff, DAT1=ff
[   91.064089] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cb, ADD=91, DAT0=ff, DAT1=ff
[   91.082604] i2c i2c-0: Transaction (post): CNT=0c, CMD=cb, ADD=91, DAT0=ff, DAT1=ff
[   91.084498] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cc, ADD=91, DAT0=ff, DAT1=ff
[   91.102256] i2c i2c-0: Transaction (post): CNT=0c, CMD=cc, ADD=91, DAT0=ff, DAT1=ff
[   91.104167] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cd, ADD=91, DAT0=ff, DAT1=ff
[   91.122421] i2c i2c-0: Transaction (post): CNT=0c, CMD=cd, ADD=91, DAT0=ff, DAT1=ff
[   91.124399] i2c i2c-0: Transaction (pre): CNT=08, CMD=d1, ADD=91, DAT0=ff, DAT1=ff
[   91.142315] i2c i2c-0: Transaction (post): CNT=08, CMD=d1, ADD=91, DAT0=ff, DAT1=ff
[   91.144268] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d2, ADD=91, DAT0=ff, DAT1=ff
[   91.161839] i2c i2c-0: Transaction (post): CNT=0c, CMD=d2, ADD=91, DAT0=ff, DAT1=ff
[   91.163383] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d3, ADD=91, DAT0=ff, DAT1=ff
[   91.181912] i2c i2c-0: Transaction (post): CNT=0c, CMD=d3, ADD=91, DAT0=ff, DAT1=ff
[   91.183511] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d4, ADD=91, DAT0=ff, DAT1=ff
[   91.204043] i2c i2c-0: Transaction (post): CNT=0c, CMD=d4, ADD=91, DAT0=ff, DAT1=ff
[   91.205705] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d5, ADD=91, DAT0=ff, DAT1=ff
[   91.221587] i2c i2c-0: Transaction (post): CNT=0c, CMD=d5, ADD=91, DAT0=ff, DAT1=ff
[   91.222927] i2c i2c-0: Transaction (pre): CNT=08, CMD=d9, ADD=91, DAT0=ff, DAT1=ff
[   91.241565] i2c i2c-0: Transaction (post): CNT=08, CMD=d9, ADD=91, DAT0=ff, DAT1=ff
[   91.242893] i2c i2c-0: Transaction (pre): CNT=0c, CMD=da, ADD=91, DAT0=ff, DAT1=ff
[   91.261781] i2c i2c-0: Transaction (post): CNT=0c, CMD=da, ADD=91, DAT0=ff, DAT1=ff
[   91.263692] i2c i2c-0: Transaction (pre): CNT=0c, CMD=db, ADD=91, DAT0=ff, DAT1=ff
[   91.281490] i2c i2c-0: Transaction (post): CNT=0c, CMD=db, ADD=91, DAT0=ff, DAT1=ff
[   91.282860] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dc, ADD=91, DAT0=ff, DAT1=ff
[   91.301448] i2c i2c-0: Transaction (post): CNT=0c, CMD=dc, ADD=91, DAT0=ff, DAT1=ff
[   91.302825] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dd, ADD=91, DAT0=ff, DAT1=ff
[   91.322273] i2c i2c-0: Transaction (post): CNT=0c, CMD=dd, ADD=91, DAT0=ff, DAT1=ff
[   91.323893] i2c i2c-0: Transaction (pre): CNT=08, CMD=e1, ADD=91, DAT0=ff, DAT1=ff
[   91.342291] i2c i2c-0: Transaction (post): CNT=08, CMD=e1, ADD=91, DAT0=ff, DAT1=ff
[   91.344254] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e2, ADD=91, DAT0=ff, DAT1=ff
[   91.362253] i2c i2c-0: Transaction (post): CNT=0c, CMD=e2, ADD=91, DAT0=ff, DAT1=ff
[   91.365284] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e3, ADD=91, DAT0=ff, DAT1=ff
[   91.382600] i2c i2c-0: Transaction (post): CNT=0c, CMD=e3, ADD=91, DAT0=ff, DAT1=ff
[   91.384654] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e4, ADD=91, DAT0=ff, DAT1=ff
[   91.402547] i2c i2c-0: Transaction (post): CNT=0c, CMD=e4, ADD=91, DAT0=ff, DAT1=ff
[   91.404541] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e5, ADD=91, DAT0=ff, DAT1=ff
[   91.422535] i2c i2c-0: Transaction (post): CNT=0c, CMD=e5, ADD=91, DAT0=ff, DAT1=ff
[   91.424518] i2c i2c-0: Transaction (pre): CNT=08, CMD=e9, ADD=91, DAT0=ff, DAT1=ff
[   91.442580] i2c i2c-0: Transaction (post): CNT=08, CMD=e9, ADD=91, DAT0=ff, DAT1=ff
[   91.444568] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ea, ADD=91, DAT0=ff, DAT1=ff
[   91.463307] i2c i2c-0: Transaction (post): CNT=0c, CMD=ea, ADD=91, DAT0=ff, DAT1=ff
[   91.465452] i2c i2c-0: Transaction (pre): CNT=0c, CMD=eb, ADD=91, DAT0=ff, DAT1=ff
[   91.482983] i2c i2c-0: Transaction (post): CNT=0c, CMD=eb, ADD=91, DAT0=ff, DAT1=ff
[   91.484990] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ec, ADD=91, DAT0=ff, DAT1=ff
[   91.502564] i2c i2c-0: Transaction (post): CNT=0c, CMD=ec, ADD=91, DAT0=ff, DAT1=ff
[   91.504564] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ed, ADD=91, DAT0=ff, DAT1=ff
[   91.522578] i2c i2c-0: Transaction (post): CNT=0c, CMD=ed, ADD=91, DAT0=ff, DAT1=ff
[   91.524628] i2c i2c-0: Transaction (pre): CNT=08, CMD=f1, ADD=91, DAT0=ff, DAT1=ff
[   91.542525] i2c i2c-0: Transaction (post): CNT=08, CMD=f1, ADD=91, DAT0=ff, DAT1=ff
[   91.544484] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f2, ADD=91, DAT0=ff, DAT1=ff
[   91.562539] i2c i2c-0: Transaction (post): CNT=0c, CMD=f2, ADD=91, DAT0=ff, DAT1=ff
[   91.564526] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f3, ADD=91, DAT0=ff, DAT1=ff
[   91.582552] i2c i2c-0: Transaction (post): CNT=0c, CMD=f3, ADD=91, DAT0=ff, DAT1=ff
[   91.584558] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f4, ADD=91, DAT0=ff, DAT1=ff
[   91.603186] i2c i2c-0: Transaction (post): CNT=0c, CMD=f4, ADD=91, DAT0=ff, DAT1=ff
[   91.605283] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f5, ADD=91, DAT0=ff, DAT1=ff
[   91.622678] i2c i2c-0: Transaction (post): CNT=0c, CMD=f5, ADD=91, DAT0=ff, DAT1=ff
[   91.624745] i2c i2c-0: Transaction (pre): CNT=08, CMD=f9, ADD=91, DAT0=ff, DAT1=ff
[   91.643176] i2c i2c-0: Transaction (post): CNT=08, CMD=f9, ADD=91, DAT0=ff, DAT1=ff
[   91.644557] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fa, ADD=91, DAT0=ff, DAT1=ff
[   91.662114] i2c i2c-0: Transaction (post): CNT=0c, CMD=fa, ADD=91, DAT0=ff, DAT1=ff
[   91.663853] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fb, ADD=91, DAT0=ff, DAT1=ff
[   91.682431] i2c i2c-0: Transaction (post): CNT=0c, CMD=fb, ADD=91, DAT0=ff, DAT1=ff
[   91.684432] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fc, ADD=91, DAT0=ff, DAT1=ff
[   91.701576] i2c i2c-0: Transaction (post): CNT=0c, CMD=fc, ADD=91, DAT0=ff, DAT1=ff
[   91.702858] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fd, ADD=91, DAT0=ff, DAT1=ff
[   91.721834] i2c i2c-0: Transaction (post): CNT=0c, CMD=fd, ADD=91, DAT0=ff, DAT1=ff
[   91.723577] i2c i2c-0: found normal entry for adapter 0, addr 0x49
[   91.725437] i2c i2c-0: Transaction (pre): CNT=00, CMD=fd, ADD=92, DAT0=ff, DAT1=ff
[   91.741313] i2c i2c-0: Transaction (post): CNT=00, CMD=fd, ADD=92, DAT0=ff, DAT1=ff
[   91.742545] i2c i2c-0: Transaction (pre): CNT=0c, CMD=00, ADD=93, DAT0=ff, DAT1=ff
[   91.761944] i2c i2c-0: Transaction (post): CNT=0c, CMD=00, ADD=93, DAT0=ff, DAT1=ff
[   91.763274] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=93, DAT0=ff, DAT1=ff
[   91.781332] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=93, DAT0=ff, DAT1=ff
[   91.782586] i2c i2c-0: Transaction (pre): CNT=0c, CMD=02, ADD=93, DAT0=ff, DAT1=ff
[   91.802101] i2c i2c-0: Transaction (post): CNT=0c, CMD=02, ADD=93, DAT0=ff, DAT1=ff
[   91.804074] i2c i2c-0: Transaction (pre): CNT=0c, CMD=03, ADD=93, DAT0=ff, DAT1=ff
[   91.823073] i2c i2c-0: Transaction (post): CNT=0c, CMD=03, ADD=93, DAT0=ff, DAT1=ff
[   91.824957] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=93, DAT0=ff, DAT1=ff
[   91.842775] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=93, DAT0=ff, DAT1=ff
[   91.844554] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=93, DAT0=ff, DAT1=ff
[   91.864514] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=93, DAT0=ff, DAT1=ff
[   91.867971] i2c i2c-0: Transaction (pre): CNT=08, CMD=09, ADD=93, DAT0=ff, DAT1=ff
[   91.892780] i2c i2c-0: Transaction (post): CNT=08, CMD=09, ADD=93, DAT0=ff, DAT1=ff
[   91.895447] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0a, ADD=93, DAT0=ff, DAT1=ff
[   91.912702] i2c i2c-0: Transaction (post): CNT=0c, CMD=0a, ADD=93, DAT0=ff, DAT1=ff
[   91.915367] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0b, ADD=93, DAT0=ff, DAT1=ff
[   91.932763] i2c i2c-0: Transaction (post): CNT=0c, CMD=0b, ADD=93, DAT0=ff, DAT1=ff
[   91.935308] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0c, ADD=93, DAT0=ff, DAT1=ff
[   91.952962] i2c i2c-0: Transaction (post): CNT=0c, CMD=0c, ADD=93, DAT0=ff, DAT1=ff
[   91.955636] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0d, ADD=93, DAT0=ff, DAT1=ff
[   91.972821] i2c i2c-0: Transaction (post): CNT=0c, CMD=0d, ADD=93, DAT0=ff, DAT1=ff
[   91.975450] i2c i2c-0: Transaction (pre): CNT=08, CMD=11, ADD=93, DAT0=ff, DAT1=ff
[   91.992235] i2c i2c-0: Transaction (post): CNT=08, CMD=11, ADD=93, DAT0=ff, DAT1=ff
[   91.994197] i2c i2c-0: Transaction (pre): CNT=0c, CMD=12, ADD=93, DAT0=ff, DAT1=ff
[   92.012149] i2c i2c-0: Transaction (post): CNT=0c, CMD=12, ADD=93, DAT0=ff, DAT1=ff
[   92.014084] i2c i2c-0: Transaction (pre): CNT=0c, CMD=13, ADD=93, DAT0=ff, DAT1=ff
[   92.032140] i2c i2c-0: Transaction (post): CNT=0c, CMD=13, ADD=93, DAT0=ff, DAT1=ff
[   92.034032] i2c i2c-0: Transaction (pre): CNT=0c, CMD=14, ADD=93, DAT0=ff, DAT1=ff
[   92.051991] i2c i2c-0: Transaction (post): CNT=0c, CMD=14, ADD=93, DAT0=ff, DAT1=ff
[   92.053875] i2c i2c-0: Transaction (pre): CNT=0c, CMD=15, ADD=93, DAT0=ff, DAT1=ff
[   92.072197] i2c i2c-0: Transaction (post): CNT=0c, CMD=15, ADD=93, DAT0=ff, DAT1=ff
[   92.074165] i2c i2c-0: Transaction (pre): CNT=08, CMD=19, ADD=93, DAT0=ff, DAT1=ff
[   92.091980] i2c i2c-0: Transaction (post): CNT=08, CMD=19, ADD=93, DAT0=ff, DAT1=ff
[   92.093898] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1a, ADD=93, DAT0=ff, DAT1=ff
[   92.112141] i2c i2c-0: Transaction (post): CNT=0c, CMD=1a, ADD=93, DAT0=ff, DAT1=ff
[   92.114011] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1b, ADD=93, DAT0=ff, DAT1=ff
[   92.132183] i2c i2c-0: Transaction (post): CNT=0c, CMD=1b, ADD=93, DAT0=ff, DAT1=ff
[   92.134070] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1c, ADD=93, DAT0=ff, DAT1=ff
[   92.151980] i2c i2c-0: Transaction (post): CNT=0c, CMD=1c, ADD=93, DAT0=ff, DAT1=ff
[   92.153855] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1d, ADD=93, DAT0=ff, DAT1=ff
[   92.172125] i2c i2c-0: Transaction (post): CNT=0c, CMD=1d, ADD=93, DAT0=ff, DAT1=ff
[   92.173976] i2c i2c-0: Transaction (pre): CNT=08, CMD=21, ADD=93, DAT0=ff, DAT1=ff
[   92.191661] i2c i2c-0: Transaction (post): CNT=08, CMD=21, ADD=93, DAT0=ff, DAT1=ff
[   92.193604] i2c i2c-0: Transaction (pre): CNT=0c, CMD=22, ADD=93, DAT0=ff, DAT1=ff
[   92.211773] i2c i2c-0: Transaction (post): CNT=0c, CMD=22, ADD=93, DAT0=ff, DAT1=ff
[   92.213117] i2c i2c-0: Transaction (pre): CNT=0c, CMD=23, ADD=93, DAT0=ff, DAT1=ff
[   92.231642] i2c i2c-0: Transaction (post): CNT=0c, CMD=23, ADD=93, DAT0=ff, DAT1=ff
[   92.232848] i2c i2c-0: Transaction (pre): CNT=0c, CMD=24, ADD=93, DAT0=ff, DAT1=ff
[   92.252496] i2c i2c-0: Transaction (post): CNT=0c, CMD=24, ADD=93, DAT0=ff, DAT1=ff
[   92.254344] i2c i2c-0: Transaction (pre): CNT=0c, CMD=25, ADD=93, DAT0=ff, DAT1=ff
[   92.272281] i2c i2c-0: Transaction (post): CNT=0c, CMD=25, ADD=93, DAT0=ff, DAT1=ff
[   92.274260] i2c i2c-0: Transaction (pre): CNT=08, CMD=29, ADD=93, DAT0=ff, DAT1=ff
[   92.291843] i2c i2c-0: Transaction (post): CNT=08, CMD=29, ADD=93, DAT0=ff, DAT1=ff
[   92.293640] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2a, ADD=93, DAT0=ff, DAT1=ff
[   92.311479] i2c i2c-0: Transaction (post): CNT=0c, CMD=2a, ADD=93, DAT0=ff, DAT1=ff
[   92.312839] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2b, ADD=93, DAT0=ff, DAT1=ff
[   92.332269] i2c i2c-0: Transaction (post): CNT=0c, CMD=2b, ADD=93, DAT0=ff, DAT1=ff
[   92.334661] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2c, ADD=93, DAT0=ff, DAT1=ff
[   92.352148] CPA self-test:
[   92.355340]  4k 2046 large 62 gb 0 x 2108[c0000000-cfffd000] miss 0
[   93.571608]  4k 65534 large 0 gb 0 x 65534[c0000000-cfffd000] miss 0
[   94.472830]  4k 65534 large 0 gb 0 x 65534[c0000000-cfffd000] miss 0
[   94.474510] ok.
[   94.477625] i2c i2c-0: Transaction (post): CNT=0c, CMD=2c, ADD=93, DAT0=ff, DAT1=ff
[   94.479542] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2d, ADD=93, DAT0=ff, DAT1=ff
[   94.502470] i2c i2c-0: Transaction (post): CNT=0c, CMD=2d, ADD=93, DAT0=ff, DAT1=ff
[   94.504423] i2c i2c-0: Transaction (pre): CNT=08, CMD=31, ADD=93, DAT0=ff, DAT1=ff
[   94.522340] i2c i2c-0: Transaction (post): CNT=08, CMD=31, ADD=93, DAT0=ff, DAT1=ff
[   94.524216] i2c i2c-0: Transaction (pre): CNT=0c, CMD=32, ADD=93, DAT0=ff, DAT1=ff
[   94.542362] i2c i2c-0: Transaction (post): CNT=0c, CMD=32, ADD=93, DAT0=ff, DAT1=ff
[   94.544248] i2c i2c-0: Transaction (pre): CNT=0c, CMD=33, ADD=93, DAT0=ff, DAT1=ff
[   94.562322] i2c i2c-0: Transaction (post): CNT=0c, CMD=33, ADD=93, DAT0=ff, DAT1=ff
[   94.564166] i2c i2c-0: Transaction (pre): CNT=0c, CMD=34, ADD=93, DAT0=ff, DAT1=ff
[   94.582382] i2c i2c-0: Transaction (post): CNT=0c, CMD=34, ADD=93, DAT0=ff, DAT1=ff
[   94.584336] i2c i2c-0: Transaction (pre): CNT=0c, CMD=35, ADD=93, DAT0=ff, DAT1=ff
[   94.602327] i2c i2c-0: Transaction (post): CNT=0c, CMD=35, ADD=93, DAT0=ff, DAT1=ff
[   94.604211] i2c i2c-0: Transaction (pre): CNT=08, CMD=39, ADD=93, DAT0=ff, DAT1=ff
[   94.622380] i2c i2c-0: Transaction (post): CNT=08, CMD=39, ADD=93, DAT0=ff, DAT1=ff
[   94.624310] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3a, ADD=93, DAT0=ff, DAT1=ff
[   94.642507] i2c i2c-0: Transaction (post): CNT=0c, CMD=3a, ADD=93, DAT0=ff, DAT1=ff
[   94.644575] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3b, ADD=93, DAT0=ff, DAT1=ff
[   94.662417] i2c i2c-0: Transaction (post): CNT=0c, CMD=3b, ADD=93, DAT0=ff, DAT1=ff
[   94.664345] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3c, ADD=93, DAT0=ff, DAT1=ff
[   94.682357] i2c i2c-0: Transaction (post): CNT=0c, CMD=3c, ADD=93, DAT0=ff, DAT1=ff
[   94.684331] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3d, ADD=93, DAT0=ff, DAT1=ff
[   94.702376] i2c i2c-0: Transaction (post): CNT=0c, CMD=3d, ADD=93, DAT0=ff, DAT1=ff
[   94.704250] i2c i2c-0: Transaction (pre): CNT=08, CMD=41, ADD=93, DAT0=ff, DAT1=ff
[   94.722304] i2c i2c-0: Transaction (post): CNT=08, CMD=41, ADD=93, DAT0=ff, DAT1=ff
[   94.724266] i2c i2c-0: Transaction (pre): CNT=0c, CMD=42, ADD=93, DAT0=ff, DAT1=ff
[   94.742553] i2c i2c-0: Transaction (post): CNT=0c, CMD=42, ADD=93, DAT0=ff, DAT1=ff
[   94.744570] i2c i2c-0: Transaction (pre): CNT=0c, CMD=43, ADD=93, DAT0=ff, DAT1=ff
[   94.761873] i2c i2c-0: Transaction (post): CNT=0c, CMD=43, ADD=93, DAT0=ff, DAT1=ff
[   94.763544] i2c i2c-0: Transaction (pre): CNT=0c, CMD=44, ADD=93, DAT0=ff, DAT1=ff
[   94.781837] i2c i2c-0: Transaction (post): CNT=0c, CMD=44, ADD=93, DAT0=ff, DAT1=ff
[   94.783693] i2c i2c-0: Transaction (pre): CNT=0c, CMD=45, ADD=93, DAT0=ff, DAT1=ff
[   94.802500] i2c i2c-0: Transaction (post): CNT=0c, CMD=45, ADD=93, DAT0=ff, DAT1=ff
[   94.804389] i2c i2c-0: Transaction (pre): CNT=08, CMD=49, ADD=93, DAT0=ff, DAT1=ff
[   94.822638] i2c i2c-0: Transaction (post): CNT=08, CMD=49, ADD=93, DAT0=ff, DAT1=ff
[   94.824518] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4a, ADD=93, DAT0=ff, DAT1=ff
[   94.842290] i2c i2c-0: Transaction (post): CNT=0c, CMD=4a, ADD=93, DAT0=ff, DAT1=ff
[   94.844307] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4b, ADD=93, DAT0=ff, DAT1=ff
[   94.862280] i2c i2c-0: Transaction (post): CNT=0c, CMD=4b, ADD=93, DAT0=ff, DAT1=ff
[   94.864101] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4c, ADD=93, DAT0=ff, DAT1=ff
[   94.882263] i2c i2c-0: Transaction (post): CNT=0c, CMD=4c, ADD=93, DAT0=ff, DAT1=ff
[   94.884899] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4d, ADD=93, DAT0=ff, DAT1=ff
[   94.902161] i2c i2c-0: Transaction (post): CNT=0c, CMD=4d, ADD=93, DAT0=ff, DAT1=ff
[   94.905136] i2c i2c-0: Transaction (pre): CNT=08, CMD=51, ADD=93, DAT0=ff, DAT1=ff
[   94.922584] i2c i2c-0: Transaction (post): CNT=08, CMD=51, ADD=93, DAT0=ff, DAT1=ff
[   94.924623] i2c i2c-0: Transaction (pre): CNT=0c, CMD=52, ADD=93, DAT0=ff, DAT1=ff
[   94.942586] i2c i2c-0: Transaction (post): CNT=0c, CMD=52, ADD=93, DAT0=ff, DAT1=ff
[   94.944638] i2c i2c-0: Transaction (pre): CNT=0c, CMD=53, ADD=93, DAT0=ff, DAT1=ff
[   94.962620] i2c i2c-0: Transaction (post): CNT=0c, CMD=53, ADD=93, DAT0=ff, DAT1=ff
[   94.964631] i2c i2c-0: Transaction (pre): CNT=0c, CMD=54, ADD=93, DAT0=ff, DAT1=ff
[   94.982895] i2c i2c-0: Transaction (post): CNT=0c, CMD=54, ADD=93, DAT0=ff, DAT1=ff
[   94.984925] i2c i2c-0: Transaction (pre): CNT=0c, CMD=55, ADD=93, DAT0=ff, DAT1=ff
[   95.002561] i2c i2c-0: Transaction (post): CNT=0c, CMD=55, ADD=93, DAT0=ff, DAT1=ff
[   95.004555] i2c i2c-0: Transaction (pre): CNT=08, CMD=59, ADD=93, DAT0=ff, DAT1=ff
[   95.022100] i2c i2c-0: Transaction (post): CNT=08, CMD=59, ADD=93, DAT0=ff, DAT1=ff
[   95.023807] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5a, ADD=93, DAT0=ff, DAT1=ff
[   95.042373] i2c i2c-0: Transaction (post): CNT=0c, CMD=5a, ADD=93, DAT0=ff, DAT1=ff
[   95.044279] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5b, ADD=93, DAT0=ff, DAT1=ff
[   95.062707] i2c i2c-0: Transaction (post): CNT=0c, CMD=5b, ADD=93, DAT0=ff, DAT1=ff
[   95.064853] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5c, ADD=93, DAT0=ff, DAT1=ff
[   95.082237] i2c i2c-0: Transaction (post): CNT=0c, CMD=5c, ADD=93, DAT0=ff, DAT1=ff
[   95.084165] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5d, ADD=93, DAT0=ff, DAT1=ff
[   95.101926] i2c i2c-0: Transaction (post): CNT=0c, CMD=5d, ADD=93, DAT0=ff, DAT1=ff
[   95.103832] i2c i2c-0: Transaction (pre): CNT=08, CMD=61, ADD=93, DAT0=ff, DAT1=ff
[   95.122105] i2c i2c-0: Transaction (post): CNT=08, CMD=61, ADD=93, DAT0=ff, DAT1=ff
[   95.123627] i2c i2c-0: Transaction (pre): CNT=0c, CMD=62, ADD=93, DAT0=ff, DAT1=ff
[   95.141773] i2c i2c-0: Transaction (post): CNT=0c, CMD=62, ADD=93, DAT0=ff, DAT1=ff
[   95.143417] i2c i2c-0: Transaction (pre): CNT=0c, CMD=63, ADD=93, DAT0=ff, DAT1=ff
[   95.161866] i2c i2c-0: Transaction (post): CNT=0c, CMD=63, ADD=93, DAT0=ff, DAT1=ff
[   95.163491] i2c i2c-0: Transaction (pre): CNT=0c, CMD=64, ADD=93, DAT0=ff, DAT1=ff
[   95.181734] i2c i2c-0: Transaction (post): CNT=0c, CMD=64, ADD=93, DAT0=ff, DAT1=ff
[   95.183345] i2c i2c-0: Transaction (pre): CNT=0c, CMD=65, ADD=93, DAT0=ff, DAT1=ff
[   95.201749] i2c i2c-0: Transaction (post): CNT=0c, CMD=65, ADD=93, DAT0=ff, DAT1=ff
[   95.203347] i2c i2c-0: Transaction (pre): CNT=08, CMD=69, ADD=93, DAT0=ff, DAT1=ff
[   95.221838] i2c i2c-0: Transaction (post): CNT=08, CMD=69, ADD=93, DAT0=ff, DAT1=ff
[   95.223372] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6a, ADD=93, DAT0=ff, DAT1=ff
[   95.241598] i2c i2c-0: Transaction (post): CNT=0c, CMD=6a, ADD=93, DAT0=ff, DAT1=ff
[   95.243044] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6b, ADD=93, DAT0=ff, DAT1=ff
[   95.261580] i2c i2c-0: Transaction (post): CNT=0c, CMD=6b, ADD=93, DAT0=ff, DAT1=ff
[   95.263175] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6c, ADD=93, DAT0=ff, DAT1=ff
[   95.282240] i2c i2c-0: Transaction (post): CNT=0c, CMD=6c, ADD=93, DAT0=ff, DAT1=ff
[   95.284137] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6d, ADD=93, DAT0=ff, DAT1=ff
[   95.302247] i2c i2c-0: Transaction (post): CNT=0c, CMD=6d, ADD=93, DAT0=ff, DAT1=ff
[   95.304156] i2c i2c-0: Transaction (pre): CNT=08, CMD=71, ADD=93, DAT0=ff, DAT1=ff
[   95.322315] i2c i2c-0: Transaction (post): CNT=08, CMD=71, ADD=93, DAT0=ff, DAT1=ff
[   95.324194] i2c i2c-0: Transaction (pre): CNT=0c, CMD=72, ADD=93, DAT0=ff, DAT1=ff
[   95.342523] i2c i2c-0: Transaction (post): CNT=0c, CMD=72, ADD=93, DAT0=ff, DAT1=ff
[   95.344431] i2c i2c-0: Transaction (pre): CNT=0c, CMD=73, ADD=93, DAT0=ff, DAT1=ff
[   95.362067] i2c i2c-0: Transaction (post): CNT=0c, CMD=73, ADD=93, DAT0=ff, DAT1=ff
[   95.363871] i2c i2c-0: Transaction (pre): CNT=0c, CMD=74, ADD=93, DAT0=ff, DAT1=ff
[   95.382146] i2c i2c-0: Transaction (post): CNT=0c, CMD=74, ADD=93, DAT0=ff, DAT1=ff
[   95.383919] i2c i2c-0: Transaction (pre): CNT=0c, CMD=75, ADD=93, DAT0=ff, DAT1=ff
[   95.402283] i2c i2c-0: Transaction (post): CNT=0c, CMD=75, ADD=93, DAT0=ff, DAT1=ff
[   95.404177] i2c i2c-0: Transaction (pre): CNT=08, CMD=79, ADD=93, DAT0=ff, DAT1=ff
[   95.422203] i2c i2c-0: Transaction (post): CNT=08, CMD=79, ADD=93, DAT0=ff, DAT1=ff
[   95.424014] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7a, ADD=93, DAT0=ff, DAT1=ff
[   95.442239] i2c i2c-0: Transaction (post): CNT=0c, CMD=7a, ADD=93, DAT0=ff, DAT1=ff
[   95.444095] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7b, ADD=93, DAT0=ff, DAT1=ff
[   95.462087] i2c i2c-0: Transaction (post): CNT=0c, CMD=7b, ADD=93, DAT0=ff, DAT1=ff
[   95.463947] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7c, ADD=93, DAT0=ff, DAT1=ff
[   95.481825] i2c i2c-0: Transaction (post): CNT=0c, CMD=7c, ADD=93, DAT0=ff, DAT1=ff
[   95.483496] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7d, ADD=93, DAT0=ff, DAT1=ff
[   95.501709] i2c i2c-0: Transaction (post): CNT=0c, CMD=7d, ADD=93, DAT0=ff, DAT1=ff
[   95.503518] i2c i2c-0: Transaction (pre): CNT=08, CMD=81, ADD=93, DAT0=ff, DAT1=ff
[   95.521758] i2c i2c-0: Transaction (post): CNT=08, CMD=81, ADD=93, DAT0=ff, DAT1=ff
[   95.523490] i2c i2c-0: Transaction (pre): CNT=0c, CMD=82, ADD=93, DAT0=ff, DAT1=ff
[   95.541882] i2c i2c-0: Transaction (post): CNT=0c, CMD=82, ADD=93, DAT0=ff, DAT1=ff
[   95.543635] i2c i2c-0: Transaction (pre): CNT=0c, CMD=83, ADD=93, DAT0=ff, DAT1=ff
[   95.562656] i2c i2c-0: Transaction (post): CNT=0c, CMD=83, ADD=93, DAT0=ff, DAT1=ff
[   95.564631] i2c i2c-0: Transaction (pre): CNT=0c, CMD=84, ADD=93, DAT0=ff, DAT1=ff
[   95.582291] i2c i2c-0: Transaction (post): CNT=0c, CMD=84, ADD=93, DAT0=ff, DAT1=ff
[   95.584160] i2c i2c-0: Transaction (pre): CNT=0c, CMD=85, ADD=93, DAT0=ff, DAT1=ff
[   95.601628] i2c i2c-0: Transaction (post): CNT=0c, CMD=85, ADD=93, DAT0=ff, DAT1=ff
[   95.602869] i2c i2c-0: Transaction (pre): CNT=08, CMD=89, ADD=93, DAT0=ff, DAT1=ff
[   95.621990] i2c i2c-0: Transaction (post): CNT=08, CMD=89, ADD=93, DAT0=ff, DAT1=ff
[   95.623238] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8a, ADD=93, DAT0=ff, DAT1=ff
[   95.642170] i2c i2c-0: Transaction (post): CNT=0c, CMD=8a, ADD=93, DAT0=ff, DAT1=ff
[   95.643935] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8b, ADD=93, DAT0=ff, DAT1=ff
[   95.662009] i2c i2c-0: Transaction (post): CNT=0c, CMD=8b, ADD=93, DAT0=ff, DAT1=ff
[   95.663761] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8c, ADD=93, DAT0=ff, DAT1=ff
[   95.681975] i2c i2c-0: Transaction (post): CNT=0c, CMD=8c, ADD=93, DAT0=ff, DAT1=ff
[   95.683710] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8d, ADD=93, DAT0=ff, DAT1=ff
[   95.701997] i2c i2c-0: Transaction (post): CNT=0c, CMD=8d, ADD=93, DAT0=ff, DAT1=ff
[   95.703746] i2c i2c-0: Transaction (pre): CNT=08, CMD=91, ADD=93, DAT0=ff, DAT1=ff
[   95.722068] i2c i2c-0: Transaction (post): CNT=08, CMD=91, ADD=93, DAT0=ff, DAT1=ff
[   95.723810] i2c i2c-0: Transaction (pre): CNT=0c, CMD=92, ADD=93, DAT0=ff, DAT1=ff
[   95.742076] i2c i2c-0: Transaction (post): CNT=0c, CMD=92, ADD=93, DAT0=ff, DAT1=ff
[   95.743829] i2c i2c-0: Transaction (pre): CNT=0c, CMD=93, ADD=93, DAT0=ff, DAT1=ff
[   95.762014] i2c i2c-0: Transaction (post): CNT=0c, CMD=93, ADD=93, DAT0=ff, DAT1=ff
[   95.763788] i2c i2c-0: Transaction (pre): CNT=0c, CMD=94, ADD=93, DAT0=ff, DAT1=ff
[   95.782048] i2c i2c-0: Transaction (post): CNT=0c, CMD=94, ADD=93, DAT0=ff, DAT1=ff
[   95.783840] i2c i2c-0: Transaction (pre): CNT=0c, CMD=95, ADD=93, DAT0=ff, DAT1=ff
[   95.801988] i2c i2c-0: Transaction (post): CNT=0c, CMD=95, ADD=93, DAT0=ff, DAT1=ff
[   95.803692] i2c i2c-0: Transaction (pre): CNT=08, CMD=99, ADD=93, DAT0=ff, DAT1=ff
[   95.821640] i2c i2c-0: Transaction (post): CNT=08, CMD=99, ADD=93, DAT0=ff, DAT1=ff
[   95.822890] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9a, ADD=93, DAT0=ff, DAT1=ff
[   95.842224] i2c i2c-0: Transaction (post): CNT=0c, CMD=9a, ADD=93, DAT0=ff, DAT1=ff
[   95.843896] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9b, ADD=93, DAT0=ff, DAT1=ff
[   95.861661] i2c i2c-0: Transaction (post): CNT=0c, CMD=9b, ADD=93, DAT0=ff, DAT1=ff
[   95.863489] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9c, ADD=93, DAT0=ff, DAT1=ff
[   95.881878] i2c i2c-0: Transaction (post): CNT=0c, CMD=9c, ADD=93, DAT0=ff, DAT1=ff
[   95.883733] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9d, ADD=93, DAT0=ff, DAT1=ff
[   95.901952] i2c i2c-0: Transaction (post): CNT=0c, CMD=9d, ADD=93, DAT0=ff, DAT1=ff
[   95.903820] i2c i2c-0: Transaction (pre): CNT=08, CMD=a1, ADD=93, DAT0=ff, DAT1=ff
[   95.922490] i2c i2c-0: Transaction (post): CNT=08, CMD=a1, ADD=93, DAT0=ff, DAT1=ff
[   95.924437] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a2, ADD=93, DAT0=ff, DAT1=ff
[   95.942526] i2c i2c-0: Transaction (post): CNT=0c, CMD=a2, ADD=93, DAT0=ff, DAT1=ff
[   95.944507] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a3, ADD=93, DAT0=ff, DAT1=ff
[   95.962276] i2c i2c-0: Transaction (post): CNT=0c, CMD=a3, ADD=93, DAT0=ff, DAT1=ff
[   95.964124] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a4, ADD=93, DAT0=ff, DAT1=ff
[   95.982648] i2c i2c-0: Transaction (post): CNT=0c, CMD=a4, ADD=93, DAT0=ff, DAT1=ff
[   95.984489] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a5, ADD=93, DAT0=ff, DAT1=ff
[   96.002298] i2c i2c-0: Transaction (post): CNT=0c, CMD=a5, ADD=93, DAT0=ff, DAT1=ff
[   96.004151] i2c i2c-0: Transaction (pre): CNT=08, CMD=a9, ADD=93, DAT0=ff, DAT1=ff
[   96.022413] i2c i2c-0: Transaction (post): CNT=08, CMD=a9, ADD=93, DAT0=ff, DAT1=ff
[   96.024316] i2c i2c-0: Transaction (pre): CNT=0c, CMD=aa, ADD=93, DAT0=ff, DAT1=ff
[   96.042838] i2c i2c-0: Transaction (post): CNT=0c, CMD=aa, ADD=93, DAT0=ff, DAT1=ff
[   96.044775] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ab, ADD=93, DAT0=ff, DAT1=ff
[   96.062185] i2c i2c-0: Transaction (post): CNT=0c, CMD=ab, ADD=93, DAT0=ff, DAT1=ff
[   96.064033] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ac, ADD=93, DAT0=ff, DAT1=ff
[   96.082382] i2c i2c-0: Transaction (post): CNT=0c, CMD=ac, ADD=93, DAT0=ff, DAT1=ff
[   96.084275] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ad, ADD=93, DAT0=ff, DAT1=ff
[   96.102410] i2c i2c-0: Transaction (post): CNT=0c, CMD=ad, ADD=93, DAT0=ff, DAT1=ff
[   96.104374] i2c i2c-0: Transaction (pre): CNT=08, CMD=b1, ADD=93, DAT0=ff, DAT1=ff
[   96.122336] i2c i2c-0: Transaction (post): CNT=08, CMD=b1, ADD=93, DAT0=ff, DAT1=ff
[   96.124300] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b2, ADD=93, DAT0=ff, DAT1=ff
[   96.142367] i2c i2c-0: Transaction (post): CNT=0c, CMD=b2, ADD=93, DAT0=ff, DAT1=ff
[   96.144385] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b3, ADD=93, DAT0=ff, DAT1=ff
[   96.162546] i2c i2c-0: Transaction (post): CNT=0c, CMD=b3, ADD=93, DAT0=ff, DAT1=ff
[   96.164391] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b4, ADD=93, DAT0=ff, DAT1=ff
[   96.182376] i2c i2c-0: Transaction (post): CNT=0c, CMD=b4, ADD=93, DAT0=ff, DAT1=ff
[   96.184321] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b5, ADD=93, DAT0=ff, DAT1=ff
[   96.202424] i2c i2c-0: Transaction (post): CNT=0c, CMD=b5, ADD=93, DAT0=ff, DAT1=ff
[   96.204311] i2c i2c-0: Transaction (pre): CNT=08, CMD=b9, ADD=93, DAT0=ff, DAT1=ff
[   96.222366] i2c i2c-0: Transaction (post): CNT=08, CMD=b9, ADD=93, DAT0=ff, DAT1=ff
[   96.224342] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ba, ADD=93, DAT0=ff, DAT1=ff
[   96.242471] i2c i2c-0: Transaction (post): CNT=0c, CMD=ba, ADD=93, DAT0=ff, DAT1=ff
[   96.244436] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bb, ADD=93, DAT0=ff, DAT1=ff
[   96.263522] i2c i2c-0: Transaction (post): CNT=0c, CMD=bb, ADD=93, DAT0=ff, DAT1=ff
[   96.265646] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bc, ADD=93, DAT0=ff, DAT1=ff
[   96.283313] i2c i2c-0: Transaction (post): CNT=0c, CMD=bc, ADD=93, DAT0=ff, DAT1=ff
[   96.285376] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bd, ADD=93, DAT0=ff, DAT1=ff
[   96.302400] i2c i2c-0: Transaction (post): CNT=0c, CMD=bd, ADD=93, DAT0=ff, DAT1=ff
[   96.305175] i2c i2c-0: Transaction (pre): CNT=08, CMD=c1, ADD=93, DAT0=ff, DAT1=ff
[   96.322357] i2c i2c-0: Transaction (post): CNT=08, CMD=c1, ADD=93, DAT0=ff, DAT1=ff
[   96.325094] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c2, ADD=93, DAT0=ff, DAT1=ff
[   96.342084] i2c i2c-0: Transaction (post): CNT=0c, CMD=c2, ADD=93, DAT0=ff, DAT1=ff
[   96.343886] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c3, ADD=93, DAT0=ff, DAT1=ff
[   96.361887] i2c i2c-0: Transaction (post): CNT=0c, CMD=c3, ADD=93, DAT0=ff, DAT1=ff
[   96.363676] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c4, ADD=93, DAT0=ff, DAT1=ff
[   96.382009] i2c i2c-0: Transaction (post): CNT=0c, CMD=c4, ADD=93, DAT0=ff, DAT1=ff
[   96.383847] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c5, ADD=93, DAT0=ff, DAT1=ff
[   96.402059] i2c i2c-0: Transaction (post): CNT=0c, CMD=c5, ADD=93, DAT0=ff, DAT1=ff
[   96.403858] i2c i2c-0: Transaction (pre): CNT=08, CMD=c9, ADD=93, DAT0=ff, DAT1=ff
[   96.423500] i2c i2c-0: Transaction (post): CNT=08, CMD=c9, ADD=93, DAT0=ff, DAT1=ff
[   96.425412] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ca, ADD=93, DAT0=ff, DAT1=ff
[   96.442212] i2c i2c-0: Transaction (post): CNT=0c, CMD=ca, ADD=93, DAT0=ff, DAT1=ff
[   96.444008] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cb, ADD=93, DAT0=ff, DAT1=ff
[   96.462849] i2c i2c-0: Transaction (post): CNT=0c, CMD=cb, ADD=93, DAT0=ff, DAT1=ff
[   96.465346] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cc, ADD=93, DAT0=ff, DAT1=ff
[   96.482913] i2c i2c-0: Transaction (post): CNT=0c, CMD=cc, ADD=93, DAT0=ff, DAT1=ff
[   96.484810] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cd, ADD=93, DAT0=ff, DAT1=ff
[   96.503065] i2c i2c-0: Transaction (post): CNT=0c, CMD=cd, ADD=93, DAT0=ff, DAT1=ff
[   96.505160] i2c i2c-0: Transaction (pre): CNT=08, CMD=d1, ADD=93, DAT0=ff, DAT1=ff
[   96.523037] i2c i2c-0: Transaction (post): CNT=08, CMD=d1, ADD=93, DAT0=ff, DAT1=ff
[   96.525114] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d2, ADD=93, DAT0=ff, DAT1=ff
[   96.542889] i2c i2c-0: Transaction (post): CNT=0c, CMD=d2, ADD=93, DAT0=ff, DAT1=ff
[   96.544891] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d3, ADD=93, DAT0=ff, DAT1=ff
[   96.562834] i2c i2c-0: Transaction (post): CNT=0c, CMD=d3, ADD=93, DAT0=ff, DAT1=ff
[   96.565514] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d4, ADD=93, DAT0=ff, DAT1=ff
[   96.582331] i2c i2c-0: Transaction (post): CNT=0c, CMD=d4, ADD=93, DAT0=ff, DAT1=ff
[   96.584199] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d5, ADD=93, DAT0=ff, DAT1=ff
[   96.602282] i2c i2c-0: Transaction (post): CNT=0c, CMD=d5, ADD=93, DAT0=ff, DAT1=ff
[   96.604686] i2c i2c-0: Transaction (pre): CNT=08, CMD=d9, ADD=93, DAT0=ff, DAT1=ff
[   96.622256] i2c i2c-0: Transaction (post): CNT=08, CMD=d9, ADD=93, DAT0=ff, DAT1=ff
[   96.624226] i2c i2c-0: Transaction (pre): CNT=0c, CMD=da, ADD=93, DAT0=ff, DAT1=ff
[   96.642173] i2c i2c-0: Transaction (post): CNT=0c, CMD=da, ADD=93, DAT0=ff, DAT1=ff
[   96.644091] i2c i2c-0: Transaction (pre): CNT=0c, CMD=db, ADD=93, DAT0=ff, DAT1=ff
[   96.662317] i2c i2c-0: Transaction (post): CNT=0c, CMD=db, ADD=93, DAT0=ff, DAT1=ff
[   96.664247] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dc, ADD=93, DAT0=ff, DAT1=ff
[   96.681686] i2c i2c-0: Transaction (post): CNT=0c, CMD=dc, ADD=93, DAT0=ff, DAT1=ff
[   96.683479] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dd, ADD=93, DAT0=ff, DAT1=ff
[   96.701794] i2c i2c-0: Transaction (post): CNT=0c, CMD=dd, ADD=93, DAT0=ff, DAT1=ff
[   96.703043] i2c i2c-0: Transaction (pre): CNT=08, CMD=e1, ADD=93, DAT0=ff, DAT1=ff
[   96.721666] i2c i2c-0: Transaction (post): CNT=08, CMD=e1, ADD=93, DAT0=ff, DAT1=ff
[   96.723019] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e2, ADD=93, DAT0=ff, DAT1=ff
[   96.741859] i2c i2c-0: Transaction (post): CNT=0c, CMD=e2, ADD=93, DAT0=ff, DAT1=ff
[   96.743095] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e3, ADD=93, DAT0=ff, DAT1=ff
[   96.761669] i2c i2c-0: Transaction (post): CNT=0c, CMD=e3, ADD=93, DAT0=ff, DAT1=ff
[   96.762896] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e4, ADD=93, DAT0=ff, DAT1=ff
[   96.781654] i2c i2c-0: Transaction (post): CNT=0c, CMD=e4, ADD=93, DAT0=ff, DAT1=ff
[   96.782878] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e5, ADD=93, DAT0=ff, DAT1=ff
[   96.801740] i2c i2c-0: Transaction (post): CNT=0c, CMD=e5, ADD=93, DAT0=ff, DAT1=ff
[   96.802980] i2c i2c-0: Transaction (pre): CNT=08, CMD=e9, ADD=93, DAT0=ff, DAT1=ff
[   96.821620] i2c i2c-0: Transaction (post): CNT=08, CMD=e9, ADD=93, DAT0=ff, DAT1=ff
[   96.822820] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ea, ADD=93, DAT0=ff, DAT1=ff
[   96.841765] i2c i2c-0: Transaction (post): CNT=0c, CMD=ea, ADD=93, DAT0=ff, DAT1=ff
[   96.842987] i2c i2c-0: Transaction (pre): CNT=0c, CMD=eb, ADD=93, DAT0=ff, DAT1=ff
[   96.861597] i2c i2c-0: Transaction (post): CNT=0c, CMD=eb, ADD=93, DAT0=ff, DAT1=ff
[   96.862794] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ec, ADD=93, DAT0=ff, DAT1=ff
[   96.881698] i2c i2c-0: Transaction (post): CNT=0c, CMD=ec, ADD=93, DAT0=ff, DAT1=ff
[   96.883012] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ed, ADD=93, DAT0=ff, DAT1=ff
[   96.901567] i2c i2c-0: Transaction (post): CNT=0c, CMD=ed, ADD=93, DAT0=ff, DAT1=ff
[   96.902781] i2c i2c-0: Transaction (pre): CNT=08, CMD=f1, ADD=93, DAT0=ff, DAT1=ff
[   96.925335] i2c i2c-0: Transaction (post): CNT=08, CMD=f1, ADD=93, DAT0=ff, DAT1=ff
[   96.926588] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f2, ADD=93, DAT0=ff, DAT1=ff
[   96.941586] i2c i2c-0: Transaction (post): CNT=0c, CMD=f2, ADD=93, DAT0=ff, DAT1=ff
[   96.942797] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f3, ADD=93, DAT0=ff, DAT1=ff
[   96.961594] i2c i2c-0: Transaction (post): CNT=0c, CMD=f3, ADD=93, DAT0=ff, DAT1=ff
[   96.962809] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f4, ADD=93, DAT0=ff, DAT1=ff
[   96.981765] i2c i2c-0: Transaction (post): CNT=0c, CMD=f4, ADD=93, DAT0=ff, DAT1=ff
[   96.982981] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f5, ADD=93, DAT0=ff, DAT1=ff
[   97.001640] i2c i2c-0: Transaction (post): CNT=0c, CMD=f5, ADD=93, DAT0=ff, DAT1=ff
[   97.002882] i2c i2c-0: Transaction (pre): CNT=08, CMD=f9, ADD=93, DAT0=ff, DAT1=ff
[   97.022928] i2c i2c-0: Transaction (post): CNT=08, CMD=f9, ADD=93, DAT0=ff, DAT1=ff
[   97.025555] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fa, ADD=93, DAT0=ff, DAT1=ff
[   97.042273] i2c i2c-0: Transaction (post): CNT=0c, CMD=fa, ADD=93, DAT0=ff, DAT1=ff
[   97.043550] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fb, ADD=93, DAT0=ff, DAT1=ff
[   97.062483] i2c i2c-0: Transaction (post): CNT=0c, CMD=fb, ADD=93, DAT0=ff, DAT1=ff
[   97.064460] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fc, ADD=93, DAT0=ff, DAT1=ff
[   97.082270] i2c i2c-0: Transaction (post): CNT=0c, CMD=fc, ADD=93, DAT0=ff, DAT1=ff
[   97.084105] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fd, ADD=93, DAT0=ff, DAT1=ff
[   97.101988] i2c i2c-0: Transaction (post): CNT=0c, CMD=fd, ADD=93, DAT0=ff, DAT1=ff
[   97.103820] i2c i2c-0: found normal entry for adapter 0, addr 0x4a
[   97.106024] i2c i2c-0: Transaction (pre): CNT=00, CMD=fd, ADD=94, DAT0=ff, DAT1=ff
[   97.122452] i2c i2c-0: Transaction (post): CNT=00, CMD=fd, ADD=94, DAT0=ff, DAT1=ff
[   97.124472] i2c i2c-0: Transaction (pre): CNT=0c, CMD=00, ADD=95, DAT0=ff, DAT1=ff
[   97.142400] i2c i2c-0: Transaction (post): CNT=0c, CMD=00, ADD=95, DAT0=ff, DAT1=ff
[   97.144380] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=95, DAT0=ff, DAT1=ff
[   97.162344] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=95, DAT0=ff, DAT1=ff
[   97.164362] i2c i2c-0: Transaction (pre): CNT=0c, CMD=02, ADD=95, DAT0=ff, DAT1=ff
[   97.182148] i2c i2c-0: Transaction (post): CNT=0c, CMD=02, ADD=95, DAT0=ff, DAT1=ff
[   97.184215] i2c i2c-0: Transaction (pre): CNT=0c, CMD=03, ADD=95, DAT0=ff, DAT1=ff
[   97.202396] i2c i2c-0: Transaction (post): CNT=0c, CMD=03, ADD=95, DAT0=ff, DAT1=ff
[   97.204339] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=95, DAT0=ff, DAT1=ff
[   97.222371] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=95, DAT0=ff, DAT1=ff
[   97.224373] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=95, DAT0=ff, DAT1=ff
[   97.242357] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=95, DAT0=ff, DAT1=ff
[   97.244366] i2c i2c-0: Transaction (pre): CNT=08, CMD=09, ADD=95, DAT0=ff, DAT1=ff
[   97.262282] i2c i2c-0: Transaction (post): CNT=08, CMD=09, ADD=95, DAT0=ff, DAT1=ff
[   97.264471] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0a, ADD=95, DAT0=ff, DAT1=ff
[   97.282443] i2c i2c-0: Transaction (post): CNT=0c, CMD=0a, ADD=95, DAT0=ff, DAT1=ff
[   97.284424] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0b, ADD=95, DAT0=ff, DAT1=ff
[   97.301988] i2c i2c-0: Transaction (post): CNT=0c, CMD=0b, ADD=95, DAT0=ff, DAT1=ff
[   97.303865] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0c, ADD=95, DAT0=ff, DAT1=ff
[   97.322378] i2c i2c-0: Transaction (post): CNT=0c, CMD=0c, ADD=95, DAT0=ff, DAT1=ff
[   97.324312] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0d, ADD=95, DAT0=ff, DAT1=ff
[   97.342242] i2c i2c-0: Transaction (post): CNT=0c, CMD=0d, ADD=95, DAT0=ff, DAT1=ff
[   97.344244] i2c i2c-0: Transaction (pre): CNT=08, CMD=11, ADD=95, DAT0=ff, DAT1=ff
[   97.362367] i2c i2c-0: Transaction (post): CNT=08, CMD=11, ADD=95, DAT0=ff, DAT1=ff
[   97.364350] i2c i2c-0: Transaction (pre): CNT=0c, CMD=12, ADD=95, DAT0=ff, DAT1=ff
[   97.383025] i2c i2c-0: Transaction (post): CNT=0c, CMD=12, ADD=95, DAT0=ff, DAT1=ff
[   97.385682] i2c i2c-0: Transaction (pre): CNT=0c, CMD=13, ADD=95, DAT0=ff, DAT1=ff
[   97.402820] i2c i2c-0: Transaction (post): CNT=0c, CMD=13, ADD=95, DAT0=ff, DAT1=ff
[   97.404916] i2c i2c-0: Transaction (pre): CNT=0c, CMD=14, ADD=95, DAT0=ff, DAT1=ff
[   97.422291] i2c i2c-0: Transaction (post): CNT=0c, CMD=14, ADD=95, DAT0=ff, DAT1=ff
[   97.424276] i2c i2c-0: Transaction (pre): CNT=0c, CMD=15, ADD=95, DAT0=ff, DAT1=ff
[   97.442152] i2c i2c-0: Transaction (post): CNT=0c, CMD=15, ADD=95, DAT0=ff, DAT1=ff
[   97.443959] i2c i2c-0: Transaction (pre): CNT=08, CMD=19, ADD=95, DAT0=ff, DAT1=ff
[   97.461782] i2c i2c-0: Transaction (post): CNT=08, CMD=19, ADD=95, DAT0=ff, DAT1=ff
[   97.463535] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1a, ADD=95, DAT0=ff, DAT1=ff
[   97.482610] i2c i2c-0: Transaction (post): CNT=0c, CMD=1a, ADD=95, DAT0=ff, DAT1=ff
[   97.484597] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1b, ADD=95, DAT0=ff, DAT1=ff
[   97.502585] i2c i2c-0: Transaction (post): CNT=0c, CMD=1b, ADD=95, DAT0=ff, DAT1=ff
[   97.504622] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1c, ADD=95, DAT0=ff, DAT1=ff
[   97.524132] i2c i2c-0: Transaction (post): CNT=0c, CMD=1c, ADD=95, DAT0=ff, DAT1=ff
[   97.526397] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1d, ADD=95, DAT0=ff, DAT1=ff
[   97.542658] i2c i2c-0: Transaction (post): CNT=0c, CMD=1d, ADD=95, DAT0=ff, DAT1=ff
[   97.544659] i2c i2c-0: Transaction (pre): CNT=08, CMD=21, ADD=95, DAT0=ff, DAT1=ff
[   97.562582] i2c i2c-0: Transaction (post): CNT=08, CMD=21, ADD=95, DAT0=ff, DAT1=ff
[   97.564606] i2c i2c-0: Transaction (pre): CNT=0c, CMD=22, ADD=95, DAT0=ff, DAT1=ff
[   97.582620] i2c i2c-0: Transaction (post): CNT=0c, CMD=22, ADD=95, DAT0=ff, DAT1=ff
[   97.584622] i2c i2c-0: Transaction (pre): CNT=0c, CMD=23, ADD=95, DAT0=ff, DAT1=ff
[   97.602812] i2c i2c-0: Transaction (post): CNT=0c, CMD=23, ADD=95, DAT0=ff, DAT1=ff
[   97.604920] i2c i2c-0: Transaction (pre): CNT=0c, CMD=24, ADD=95, DAT0=ff, DAT1=ff
[   97.622632] i2c i2c-0: Transaction (post): CNT=0c, CMD=24, ADD=95, DAT0=ff, DAT1=ff
[   97.624704] i2c i2c-0: Transaction (pre): CNT=0c, CMD=25, ADD=95, DAT0=ff, DAT1=ff
[   97.642682] i2c i2c-0: Transaction (post): CNT=0c, CMD=25, ADD=95, DAT0=ff, DAT1=ff
[   97.644788] i2c i2c-0: Transaction (pre): CNT=08, CMD=29, ADD=95, DAT0=ff, DAT1=ff
[   97.662890] i2c i2c-0: Transaction (post): CNT=08, CMD=29, ADD=95, DAT0=ff, DAT1=ff
[   97.665013] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2a, ADD=95, DAT0=ff, DAT1=ff
[   97.682787] i2c i2c-0: Transaction (post): CNT=0c, CMD=2a, ADD=95, DAT0=ff, DAT1=ff
[   97.684895] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2b, ADD=95, DAT0=ff, DAT1=ff
[   97.702696] i2c i2c-0: Transaction (post): CNT=0c, CMD=2b, ADD=95, DAT0=ff, DAT1=ff
[   97.704804] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2c, ADD=95, DAT0=ff, DAT1=ff
[   97.722673] i2c i2c-0: Transaction (post): CNT=0c, CMD=2c, ADD=95, DAT0=ff, DAT1=ff
[   97.724721] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2d, ADD=95, DAT0=ff, DAT1=ff
[   97.742703] i2c i2c-0: Transaction (post): CNT=0c, CMD=2d, ADD=95, DAT0=ff, DAT1=ff
[   97.744832] i2c i2c-0: Transaction (pre): CNT=08, CMD=31, ADD=95, DAT0=ff, DAT1=ff
[   97.762687] i2c i2c-0: Transaction (post): CNT=08, CMD=31, ADD=95, DAT0=ff, DAT1=ff
[   97.764758] i2c i2c-0: Transaction (pre): CNT=0c, CMD=32, ADD=95, DAT0=ff, DAT1=ff
[   97.782646] i2c i2c-0: Transaction (post): CNT=0c, CMD=32, ADD=95, DAT0=ff, DAT1=ff
[   97.784732] i2c i2c-0: Transaction (pre): CNT=0c, CMD=33, ADD=95, DAT0=ff, DAT1=ff
[   97.802617] i2c i2c-0: Transaction (post): CNT=0c, CMD=33, ADD=95, DAT0=ff, DAT1=ff
[   97.804668] i2c i2c-0: Transaction (pre): CNT=0c, CMD=34, ADD=95, DAT0=ff, DAT1=ff
[   97.822597] i2c i2c-0: Transaction (post): CNT=0c, CMD=34, ADD=95, DAT0=ff, DAT1=ff
[   97.824632] i2c i2c-0: Transaction (pre): CNT=0c, CMD=35, ADD=95, DAT0=ff, DAT1=ff
[   97.842130] i2c i2c-0: Transaction (post): CNT=0c, CMD=35, ADD=95, DAT0=ff, DAT1=ff
[   97.843820] i2c i2c-0: Transaction (pre): CNT=08, CMD=39, ADD=95, DAT0=ff, DAT1=ff
[   97.862095] i2c i2c-0: Transaction (post): CNT=08, CMD=39, ADD=95, DAT0=ff, DAT1=ff
[   97.863402] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3a, ADD=95, DAT0=ff, DAT1=ff
[   97.881818] i2c i2c-0: Transaction (post): CNT=0c, CMD=3a, ADD=95, DAT0=ff, DAT1=ff
[   97.883441] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3b, ADD=95, DAT0=ff, DAT1=ff
[   97.902748] i2c i2c-0: Transaction (post): CNT=0c, CMD=3b, ADD=95, DAT0=ff, DAT1=ff
[   97.904671] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3c, ADD=95, DAT0=ff, DAT1=ff
[   97.922495] i2c i2c-0: Transaction (post): CNT=0c, CMD=3c, ADD=95, DAT0=ff, DAT1=ff
[   97.924348] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3d, ADD=95, DAT0=ff, DAT1=ff
[   97.942558] i2c i2c-0: Transaction (post): CNT=0c, CMD=3d, ADD=95, DAT0=ff, DAT1=ff
[   97.944476] i2c i2c-0: Transaction (pre): CNT=08, CMD=41, ADD=95, DAT0=ff, DAT1=ff
[   97.962384] i2c i2c-0: Transaction (post): CNT=08, CMD=41, ADD=95, DAT0=ff, DAT1=ff
[   97.964286] i2c i2c-0: Transaction (pre): CNT=0c, CMD=42, ADD=95, DAT0=ff, DAT1=ff
[   97.982881] i2c i2c-0: Transaction (post): CNT=0c, CMD=42, ADD=95, DAT0=ff, DAT1=ff
[   97.984921] i2c i2c-0: Transaction (pre): CNT=0c, CMD=43, ADD=95, DAT0=ff, DAT1=ff
[   98.002502] i2c i2c-0: Transaction (post): CNT=0c, CMD=43, ADD=95, DAT0=ff, DAT1=ff
[   98.004373] i2c i2c-0: Transaction (pre): CNT=0c, CMD=44, ADD=95, DAT0=ff, DAT1=ff
[   98.022364] i2c i2c-0: Transaction (post): CNT=0c, CMD=44, ADD=95, DAT0=ff, DAT1=ff
[   98.024891] i2c i2c-0: Transaction (pre): CNT=0c, CMD=45, ADD=95, DAT0=ff, DAT1=ff
[   98.044373] i2c i2c-0: Transaction (post): CNT=0c, CMD=45, ADD=95, DAT0=ff, DAT1=ff
[   98.046338] i2c i2c-0: Transaction (pre): CNT=08, CMD=49, ADD=95, DAT0=ff, DAT1=ff
[   98.062377] i2c i2c-0: Transaction (post): CNT=08, CMD=49, ADD=95, DAT0=ff, DAT1=ff
[   98.064320] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4a, ADD=95, DAT0=ff, DAT1=ff
[   98.082228] i2c i2c-0: Transaction (post): CNT=0c, CMD=4a, ADD=95, DAT0=ff, DAT1=ff
[   98.084175] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4b, ADD=95, DAT0=ff, DAT1=ff
[   98.102342] i2c i2c-0: Transaction (post): CNT=0c, CMD=4b, ADD=95, DAT0=ff, DAT1=ff
[   98.104225] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4c, ADD=95, DAT0=ff, DAT1=ff
[   98.122326] i2c i2c-0: Transaction (post): CNT=0c, CMD=4c, ADD=95, DAT0=ff, DAT1=ff
[   98.124217] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4d, ADD=95, DAT0=ff, DAT1=ff
[   98.142243] i2c i2c-0: Transaction (post): CNT=0c, CMD=4d, ADD=95, DAT0=ff, DAT1=ff
[   98.144127] i2c i2c-0: Transaction (pre): CNT=08, CMD=51, ADD=95, DAT0=ff, DAT1=ff
[   98.162294] i2c i2c-0: Transaction (post): CNT=08, CMD=51, ADD=95, DAT0=ff, DAT1=ff
[   98.164199] i2c i2c-0: Transaction (pre): CNT=0c, CMD=52, ADD=95, DAT0=ff, DAT1=ff
[   98.182215] i2c i2c-0: Transaction (post): CNT=0c, CMD=52, ADD=95, DAT0=ff, DAT1=ff
[   98.184104] i2c i2c-0: Transaction (pre): CNT=0c, CMD=53, ADD=95, DAT0=ff, DAT1=ff
[   98.202359] i2c i2c-0: Transaction (post): CNT=0c, CMD=53, ADD=95, DAT0=ff, DAT1=ff
[   98.204316] i2c i2c-0: Transaction (pre): CNT=0c, CMD=54, ADD=95, DAT0=ff, DAT1=ff
[   98.222325] i2c i2c-0: Transaction (post): CNT=0c, CMD=54, ADD=95, DAT0=ff, DAT1=ff
[   98.224218] i2c i2c-0: Transaction (pre): CNT=0c, CMD=55, ADD=95, DAT0=ff, DAT1=ff
[   98.242211] i2c i2c-0: Transaction (post): CNT=0c, CMD=55, ADD=95, DAT0=ff, DAT1=ff
[   98.244163] i2c i2c-0: Transaction (pre): CNT=08, CMD=59, ADD=95, DAT0=ff, DAT1=ff
[   98.262267] i2c i2c-0: Transaction (post): CNT=08, CMD=59, ADD=95, DAT0=ff, DAT1=ff
[   98.264379] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5a, ADD=95, DAT0=ff, DAT1=ff
[   98.282262] i2c i2c-0: Transaction (post): CNT=0c, CMD=5a, ADD=95, DAT0=ff, DAT1=ff
[   98.284228] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5b, ADD=95, DAT0=ff, DAT1=ff
[   98.302252] i2c i2c-0: Transaction (post): CNT=0c, CMD=5b, ADD=95, DAT0=ff, DAT1=ff
[   98.304086] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5c, ADD=95, DAT0=ff, DAT1=ff
[   98.322016] i2c i2c-0: Transaction (post): CNT=0c, CMD=5c, ADD=95, DAT0=ff, DAT1=ff
[   98.323841] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5d, ADD=95, DAT0=ff, DAT1=ff
[   98.342196] i2c i2c-0: Transaction (post): CNT=0c, CMD=5d, ADD=95, DAT0=ff, DAT1=ff
[   98.344071] i2c i2c-0: Transaction (pre): CNT=08, CMD=61, ADD=95, DAT0=ff, DAT1=ff
[   98.362319] i2c i2c-0: Transaction (post): CNT=08, CMD=61, ADD=95, DAT0=ff, DAT1=ff
[   98.364231] i2c i2c-0: Transaction (pre): CNT=0c, CMD=62, ADD=95, DAT0=ff, DAT1=ff
[   98.382228] i2c i2c-0: Transaction (post): CNT=0c, CMD=62, ADD=95, DAT0=ff, DAT1=ff
[   98.384099] i2c i2c-0: Transaction (pre): CNT=0c, CMD=63, ADD=95, DAT0=ff, DAT1=ff
[   98.402249] i2c i2c-0: Transaction (post): CNT=0c, CMD=63, ADD=95, DAT0=ff, DAT1=ff
[   98.404138] i2c i2c-0: Transaction (pre): CNT=0c, CMD=64, ADD=95, DAT0=ff, DAT1=ff
[   98.422266] i2c i2c-0: Transaction (post): CNT=0c, CMD=64, ADD=95, DAT0=ff, DAT1=ff
[   98.424204] i2c i2c-0: Transaction (pre): CNT=0c, CMD=65, ADD=95, DAT0=ff, DAT1=ff
[   98.442291] i2c i2c-0: Transaction (post): CNT=0c, CMD=65, ADD=95, DAT0=ff, DAT1=ff
[   98.444159] i2c i2c-0: Transaction (pre): CNT=08, CMD=69, ADD=95, DAT0=ff, DAT1=ff
[   98.462147] i2c i2c-0: Transaction (post): CNT=08, CMD=69, ADD=95, DAT0=ff, DAT1=ff
[   98.464015] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6a, ADD=95, DAT0=ff, DAT1=ff
[   98.482554] i2c i2c-0: Transaction (post): CNT=0c, CMD=6a, ADD=95, DAT0=ff, DAT1=ff
[   98.484537] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6b, ADD=95, DAT0=ff, DAT1=ff
[   98.502389] i2c i2c-0: Transaction (post): CNT=0c, CMD=6b, ADD=95, DAT0=ff, DAT1=ff
[   98.504341] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6c, ADD=95, DAT0=ff, DAT1=ff
[   98.522391] i2c i2c-0: Transaction (post): CNT=0c, CMD=6c, ADD=95, DAT0=ff, DAT1=ff
[   98.524411] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6d, ADD=95, DAT0=ff, DAT1=ff
[   98.542333] i2c i2c-0: Transaction (post): CNT=0c, CMD=6d, ADD=95, DAT0=ff, DAT1=ff
[   98.544265] i2c i2c-0: Transaction (pre): CNT=08, CMD=71, ADD=95, DAT0=ff, DAT1=ff
[   98.562215] i2c i2c-0: Transaction (post): CNT=08, CMD=71, ADD=95, DAT0=ff, DAT1=ff
[   98.564102] i2c i2c-0: Transaction (pre): CNT=0c, CMD=72, ADD=95, DAT0=ff, DAT1=ff
[   98.582372] i2c i2c-0: Transaction (post): CNT=0c, CMD=72, ADD=95, DAT0=ff, DAT1=ff
[   98.584340] i2c i2c-0: Transaction (pre): CNT=0c, CMD=73, ADD=95, DAT0=ff, DAT1=ff
[   98.603326] i2c i2c-0: Transaction (post): CNT=0c, CMD=73, ADD=95, DAT0=ff, DAT1=ff
[   98.605261] i2c i2c-0: Transaction (pre): CNT=0c, CMD=74, ADD=95, DAT0=ff, DAT1=ff
[   98.622449] i2c i2c-0: Transaction (post): CNT=0c, CMD=74, ADD=95, DAT0=ff, DAT1=ff
[   98.624384] i2c i2c-0: Transaction (pre): CNT=0c, CMD=75, ADD=95, DAT0=ff, DAT1=ff
[   98.642169] i2c i2c-0: Transaction (post): CNT=0c, CMD=75, ADD=95, DAT0=ff, DAT1=ff
[   98.643986] i2c i2c-0: Transaction (pre): CNT=08, CMD=79, ADD=95, DAT0=ff, DAT1=ff
[   98.662297] i2c i2c-0: Transaction (post): CNT=08, CMD=79, ADD=95, DAT0=ff, DAT1=ff
[   98.664227] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7a, ADD=95, DAT0=ff, DAT1=ff
[   98.682241] i2c i2c-0: Transaction (post): CNT=0c, CMD=7a, ADD=95, DAT0=ff, DAT1=ff
[   98.684208] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7b, ADD=95, DAT0=ff, DAT1=ff
[   98.702276] i2c i2c-0: Transaction (post): CNT=0c, CMD=7b, ADD=95, DAT0=ff, DAT1=ff
[   98.704226] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7c, ADD=95, DAT0=ff, DAT1=ff
[   98.722218] i2c i2c-0: Transaction (post): CNT=0c, CMD=7c, ADD=95, DAT0=ff, DAT1=ff
[   98.724163] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7d, ADD=95, DAT0=ff, DAT1=ff
[   98.742305] i2c i2c-0: Transaction (post): CNT=0c, CMD=7d, ADD=95, DAT0=ff, DAT1=ff
[   98.744291] i2c i2c-0: Transaction (pre): CNT=08, CMD=81, ADD=95, DAT0=ff, DAT1=ff
[   98.762664] i2c i2c-0: Transaction (post): CNT=08, CMD=81, ADD=95, DAT0=ff, DAT1=ff
[   98.764714] i2c i2c-0: Transaction (pre): CNT=0c, CMD=82, ADD=95, DAT0=ff, DAT1=ff
[   98.782364] i2c i2c-0: Transaction (post): CNT=0c, CMD=82, ADD=95, DAT0=ff, DAT1=ff
[   98.784360] i2c i2c-0: Transaction (pre): CNT=0c, CMD=83, ADD=95, DAT0=ff, DAT1=ff
[   98.801540] i2c i2c-0: Transaction (post): CNT=0c, CMD=83, ADD=95, DAT0=ff, DAT1=ff
[   98.802789] i2c i2c-0: Transaction (pre): CNT=0c, CMD=84, ADD=95, DAT0=ff, DAT1=ff
[   98.822108] i2c i2c-0: Transaction (post): CNT=0c, CMD=84, ADD=95, DAT0=ff, DAT1=ff
[   98.823853] i2c i2c-0: Transaction (pre): CNT=0c, CMD=85, ADD=95, DAT0=ff, DAT1=ff
[   98.842372] i2c i2c-0: Transaction (post): CNT=0c, CMD=85, ADD=95, DAT0=ff, DAT1=ff
[   98.844325] i2c i2c-0: Transaction (pre): CNT=08, CMD=89, ADD=95, DAT0=ff, DAT1=ff
[   98.862247] i2c i2c-0: Transaction (post): CNT=08, CMD=89, ADD=95, DAT0=ff, DAT1=ff
[   98.864077] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8a, ADD=95, DAT0=ff, DAT1=ff
[   98.882401] i2c i2c-0: Transaction (post): CNT=0c, CMD=8a, ADD=95, DAT0=ff, DAT1=ff
[   98.884230] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8b, ADD=95, DAT0=ff, DAT1=ff
[   98.902241] i2c i2c-0: Transaction (post): CNT=0c, CMD=8b, ADD=95, DAT0=ff, DAT1=ff
[   98.904096] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8c, ADD=95, DAT0=ff, DAT1=ff
[   98.922333] i2c i2c-0: Transaction (post): CNT=0c, CMD=8c, ADD=95, DAT0=ff, DAT1=ff
[   98.924128] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8d, ADD=95, DAT0=ff, DAT1=ff
[   98.942333] i2c i2c-0: Transaction (post): CNT=0c, CMD=8d, ADD=95, DAT0=ff, DAT1=ff
[   98.944174] i2c i2c-0: Transaction (pre): CNT=08, CMD=91, ADD=95, DAT0=ff, DAT1=ff
[   98.962183] i2c i2c-0: Transaction (post): CNT=08, CMD=91, ADD=95, DAT0=ff, DAT1=ff
[   98.963997] i2c i2c-0: Transaction (pre): CNT=0c, CMD=92, ADD=95, DAT0=ff, DAT1=ff
[   98.982493] i2c i2c-0: Transaction (post): CNT=0c, CMD=92, ADD=95, DAT0=ff, DAT1=ff
[   98.984370] i2c i2c-0: Transaction (pre): CNT=0c, CMD=93, ADD=95, DAT0=ff, DAT1=ff
[   99.002219] i2c i2c-0: Transaction (post): CNT=0c, CMD=93, ADD=95, DAT0=ff, DAT1=ff
[   99.004133] i2c i2c-0: Transaction (pre): CNT=0c, CMD=94, ADD=95, DAT0=ff, DAT1=ff
[   99.022280] i2c i2c-0: Transaction (post): CNT=0c, CMD=94, ADD=95, DAT0=ff, DAT1=ff
[   99.024107] i2c i2c-0: Transaction (pre): CNT=0c, CMD=95, ADD=95, DAT0=ff, DAT1=ff
[   99.042333] i2c i2c-0: Transaction (post): CNT=0c, CMD=95, ADD=95, DAT0=ff, DAT1=ff
[   99.044147] i2c i2c-0: Transaction (pre): CNT=08, CMD=99, ADD=95, DAT0=ff, DAT1=ff
[   99.064596] i2c i2c-0: Transaction (post): CNT=08, CMD=99, ADD=95, DAT0=ff, DAT1=ff
[   99.066142] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9a, ADD=95, DAT0=ff, DAT1=ff
[   99.082242] i2c i2c-0: Transaction (post): CNT=0c, CMD=9a, ADD=95, DAT0=ff, DAT1=ff
[   99.084162] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9b, ADD=95, DAT0=ff, DAT1=ff
[   99.102231] i2c i2c-0: Transaction (post): CNT=0c, CMD=9b, ADD=95, DAT0=ff, DAT1=ff
[   99.104712] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9c, ADD=95, DAT0=ff, DAT1=ff
[   99.122224] i2c i2c-0: Transaction (post): CNT=0c, CMD=9c, ADD=95, DAT0=ff, DAT1=ff
[   99.124075] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9d, ADD=95, DAT0=ff, DAT1=ff
[   99.142268] i2c i2c-0: Transaction (post): CNT=0c, CMD=9d, ADD=95, DAT0=ff, DAT1=ff
[   99.144100] i2c i2c-0: Transaction (pre): CNT=08, CMD=a1, ADD=95, DAT0=ff, DAT1=ff
[   99.162345] i2c i2c-0: Transaction (post): CNT=08, CMD=a1, ADD=95, DAT0=ff, DAT1=ff
[   99.164259] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a2, ADD=95, DAT0=ff, DAT1=ff
[   99.182195] i2c i2c-0: Transaction (post): CNT=0c, CMD=a2, ADD=95, DAT0=ff, DAT1=ff
[   99.184062] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a3, ADD=95, DAT0=ff, DAT1=ff
[   99.202227] i2c i2c-0: Transaction (post): CNT=0c, CMD=a3, ADD=95, DAT0=ff, DAT1=ff
[   99.204048] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a4, ADD=95, DAT0=ff, DAT1=ff
[   99.222144] i2c i2c-0: Transaction (post): CNT=0c, CMD=a4, ADD=95, DAT0=ff, DAT1=ff
[   99.225058] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a5, ADD=95, DAT0=ff, DAT1=ff
[   99.242402] i2c i2c-0: Transaction (post): CNT=0c, CMD=a5, ADD=95, DAT0=ff, DAT1=ff
[   99.244398] i2c i2c-0: Transaction (pre): CNT=08, CMD=a9, ADD=95, DAT0=ff, DAT1=ff
[   99.262296] i2c i2c-0: Transaction (post): CNT=08, CMD=a9, ADD=95, DAT0=ff, DAT1=ff
[   99.264400] i2c i2c-0: Transaction (pre): CNT=0c, CMD=aa, ADD=95, DAT0=ff, DAT1=ff
[   99.282131] i2c i2c-0: Transaction (post): CNT=0c, CMD=aa, ADD=95, DAT0=ff, DAT1=ff
[   99.284082] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ab, ADD=95, DAT0=ff, DAT1=ff
[   99.302229] i2c i2c-0: Transaction (post): CNT=0c, CMD=ab, ADD=95, DAT0=ff, DAT1=ff
[   99.304200] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ac, ADD=95, DAT0=ff, DAT1=ff
[   99.322972] i2c i2c-0: Transaction (post): CNT=0c, CMD=ac, ADD=95, DAT0=ff, DAT1=ff
[   99.324811] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ad, ADD=95, DAT0=ff, DAT1=ff
[   99.343050] i2c i2c-0: Transaction (post): CNT=0c, CMD=ad, ADD=95, DAT0=ff, DAT1=ff
[   99.345639] i2c i2c-0: Transaction (pre): CNT=08, CMD=b1, ADD=95, DAT0=ff, DAT1=ff
[   99.362402] i2c i2c-0: Transaction (post): CNT=08, CMD=b1, ADD=95, DAT0=ff, DAT1=ff
[   99.364278] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b2, ADD=95, DAT0=ff, DAT1=ff
[   99.382374] i2c i2c-0: Transaction (post): CNT=0c, CMD=b2, ADD=95, DAT0=ff, DAT1=ff
[   99.384255] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b3, ADD=95, DAT0=ff, DAT1=ff
[   99.402361] i2c i2c-0: Transaction (post): CNT=0c, CMD=b3, ADD=95, DAT0=ff, DAT1=ff
[   99.404254] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b4, ADD=95, DAT0=ff, DAT1=ff
[   99.422145] i2c i2c-0: Transaction (post): CNT=0c, CMD=b4, ADD=95, DAT0=ff, DAT1=ff
[   99.423901] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b5, ADD=95, DAT0=ff, DAT1=ff
[   99.442356] i2c i2c-0: Transaction (post): CNT=0c, CMD=b5, ADD=95, DAT0=ff, DAT1=ff
[   99.444358] i2c i2c-0: Transaction (pre): CNT=08, CMD=b9, ADD=95, DAT0=ff, DAT1=ff
[   99.462186] i2c i2c-0: Transaction (post): CNT=08, CMD=b9, ADD=95, DAT0=ff, DAT1=ff
[   99.463995] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ba, ADD=95, DAT0=ff, DAT1=ff
[   99.482476] i2c i2c-0: Transaction (post): CNT=0c, CMD=ba, ADD=95, DAT0=ff, DAT1=ff
[   99.484303] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bb, ADD=95, DAT0=ff, DAT1=ff
[   99.502106] i2c i2c-0: Transaction (post): CNT=0c, CMD=bb, ADD=95, DAT0=ff, DAT1=ff
[   99.503971] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bc, ADD=95, DAT0=ff, DAT1=ff
[   99.522069] i2c i2c-0: Transaction (post): CNT=0c, CMD=bc, ADD=95, DAT0=ff, DAT1=ff
[   99.523878] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bd, ADD=95, DAT0=ff, DAT1=ff
[   99.542188] i2c i2c-0: Transaction (post): CNT=0c, CMD=bd, ADD=95, DAT0=ff, DAT1=ff
[   99.544251] i2c i2c-0: Transaction (pre): CNT=08, CMD=c1, ADD=95, DAT0=ff, DAT1=ff
[   99.562760] i2c i2c-0: Transaction (post): CNT=08, CMD=c1, ADD=95, DAT0=ff, DAT1=ff
[   99.565348] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c2, ADD=95, DAT0=ff, DAT1=ff
[   99.582893] i2c i2c-0: Transaction (post): CNT=0c, CMD=c2, ADD=95, DAT0=ff, DAT1=ff
[   99.585500] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c3, ADD=95, DAT0=ff, DAT1=ff
[   99.602686] i2c i2c-0: Transaction (post): CNT=0c, CMD=c3, ADD=95, DAT0=ff, DAT1=ff
[   99.605281] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c4, ADD=95, DAT0=ff, DAT1=ff
[   99.622833] i2c i2c-0: Transaction (post): CNT=0c, CMD=c4, ADD=95, DAT0=ff, DAT1=ff
[   99.625477] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c5, ADD=95, DAT0=ff, DAT1=ff
[   99.642378] i2c i2c-0: Transaction (post): CNT=0c, CMD=c5, ADD=95, DAT0=ff, DAT1=ff
[   99.644420] i2c i2c-0: Transaction (pre): CNT=08, CMD=c9, ADD=95, DAT0=ff, DAT1=ff
[   99.662251] i2c i2c-0: Transaction (post): CNT=08, CMD=c9, ADD=95, DAT0=ff, DAT1=ff
[   99.664225] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ca, ADD=95, DAT0=ff, DAT1=ff
[   99.682203] i2c i2c-0: Transaction (post): CNT=0c, CMD=ca, ADD=95, DAT0=ff, DAT1=ff
[   99.684156] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cb, ADD=95, DAT0=ff, DAT1=ff
[   99.702124] i2c i2c-0: Transaction (post): CNT=0c, CMD=cb, ADD=95, DAT0=ff, DAT1=ff
[   99.704072] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cc, ADD=95, DAT0=ff, DAT1=ff
[   99.722188] i2c i2c-0: Transaction (post): CNT=0c, CMD=cc, ADD=95, DAT0=ff, DAT1=ff
[   99.724142] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cd, ADD=95, DAT0=ff, DAT1=ff
[   99.742293] i2c i2c-0: Transaction (post): CNT=0c, CMD=cd, ADD=95, DAT0=ff, DAT1=ff
[   99.744116] i2c i2c-0: Transaction (pre): CNT=08, CMD=d1, ADD=95, DAT0=ff, DAT1=ff
[   99.761982] i2c i2c-0: Transaction (post): CNT=08, CMD=d1, ADD=95, DAT0=ff, DAT1=ff
[   99.763801] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d2, ADD=95, DAT0=ff, DAT1=ff
[   99.782036] i2c i2c-0: Transaction (post): CNT=0c, CMD=d2, ADD=95, DAT0=ff, DAT1=ff
[   99.783875] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d3, ADD=95, DAT0=ff, DAT1=ff
[   99.802129] i2c i2c-0: Transaction (post): CNT=0c, CMD=d3, ADD=95, DAT0=ff, DAT1=ff
[   99.803952] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d4, ADD=95, DAT0=ff, DAT1=ff
[   99.822027] i2c i2c-0: Transaction (post): CNT=0c, CMD=d4, ADD=95, DAT0=ff, DAT1=ff
[   99.823765] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d5, ADD=95, DAT0=ff, DAT1=ff
[   99.841779] i2c i2c-0: Transaction (post): CNT=0c, CMD=d5, ADD=95, DAT0=ff, DAT1=ff
[   99.843595] i2c i2c-0: Transaction (pre): CNT=08, CMD=d9, ADD=95, DAT0=ff, DAT1=ff
[   99.861972] i2c i2c-0: Transaction (post): CNT=08, CMD=d9, ADD=95, DAT0=ff, DAT1=ff
[   99.863755] i2c i2c-0: Transaction (pre): CNT=0c, CMD=da, ADD=95, DAT0=ff, DAT1=ff
[   99.882027] i2c i2c-0: Transaction (post): CNT=0c, CMD=da, ADD=95, DAT0=ff, DAT1=ff
[   99.883835] i2c i2c-0: Transaction (pre): CNT=0c, CMD=db, ADD=95, DAT0=ff, DAT1=ff
[   99.901682] i2c i2c-0: Transaction (post): CNT=0c, CMD=db, ADD=95, DAT0=ff, DAT1=ff
[   99.903418] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dc, ADD=95, DAT0=ff, DAT1=ff
[   99.922170] i2c i2c-0: Transaction (post): CNT=0c, CMD=dc, ADD=95, DAT0=ff, DAT1=ff
[   99.924077] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dd, ADD=95, DAT0=ff, DAT1=ff
[   99.943397] i2c i2c-0: Transaction (post): CNT=0c, CMD=dd, ADD=95, DAT0=ff, DAT1=ff
[   99.945280] i2c i2c-0: Transaction (pre): CNT=08, CMD=e1, ADD=95, DAT0=ff, DAT1=ff
[   99.962204] i2c i2c-0: Transaction (post): CNT=08, CMD=e1, ADD=95, DAT0=ff, DAT1=ff
[   99.964128] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e2, ADD=95, DAT0=ff, DAT1=ff
[   99.982710] i2c i2c-0: Transaction (post): CNT=0c, CMD=e2, ADD=95, DAT0=ff, DAT1=ff
[   99.984700] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e3, ADD=95, DAT0=ff, DAT1=ff
[  100.002268] i2c i2c-0: Transaction (post): CNT=0c, CMD=e3, ADD=95, DAT0=ff, DAT1=ff
[  100.004161] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e4, ADD=95, DAT0=ff, DAT1=ff
[  100.022379] i2c i2c-0: Transaction (post): CNT=0c, CMD=e4, ADD=95, DAT0=ff, DAT1=ff
[  100.024323] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e5, ADD=95, DAT0=ff, DAT1=ff
[  100.042276] i2c i2c-0: Transaction (post): CNT=0c, CMD=e5, ADD=95, DAT0=ff, DAT1=ff
[  100.044169] i2c i2c-0: Transaction (pre): CNT=08, CMD=e9, ADD=95, DAT0=ff, DAT1=ff
[  100.062195] i2c i2c-0: Transaction (post): CNT=08, CMD=e9, ADD=95, DAT0=ff, DAT1=ff
[  100.064113] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ea, ADD=95, DAT0=ff, DAT1=ff
[  100.082287] i2c i2c-0: Transaction (post): CNT=0c, CMD=ea, ADD=95, DAT0=ff, DAT1=ff
[  100.084109] i2c i2c-0: Transaction (pre): CNT=0c, CMD=eb, ADD=95, DAT0=ff, DAT1=ff
[  100.102294] i2c i2c-0: Transaction (post): CNT=0c, CMD=eb, ADD=95, DAT0=ff, DAT1=ff
[  100.104285] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ec, ADD=95, DAT0=ff, DAT1=ff
[  100.123298] i2c i2c-0: Transaction (post): CNT=0c, CMD=ec, ADD=95, DAT0=ff, DAT1=ff
[  100.125179] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ed, ADD=95, DAT0=ff, DAT1=ff
[  100.142204] i2c i2c-0: Transaction (post): CNT=0c, CMD=ed, ADD=95, DAT0=ff, DAT1=ff
[  100.144118] i2c i2c-0: Transaction (pre): CNT=08, CMD=f1, ADD=95, DAT0=ff, DAT1=ff
[  100.162054] i2c i2c-0: Transaction (post): CNT=08, CMD=f1, ADD=95, DAT0=ff, DAT1=ff
[  100.163899] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f2, ADD=95, DAT0=ff, DAT1=ff
[  100.182094] i2c i2c-0: Transaction (post): CNT=0c, CMD=f2, ADD=95, DAT0=ff, DAT1=ff
[  100.184068] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f3, ADD=95, DAT0=ff, DAT1=ff
[  100.202189] i2c i2c-0: Transaction (post): CNT=0c, CMD=f3, ADD=95, DAT0=ff, DAT1=ff
[  100.204119] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f4, ADD=95, DAT0=ff, DAT1=ff
[  100.221872] i2c i2c-0: Transaction (post): CNT=0c, CMD=f4, ADD=95, DAT0=ff, DAT1=ff
[  100.223703] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f5, ADD=95, DAT0=ff, DAT1=ff
[  100.242225] i2c i2c-0: Transaction (post): CNT=0c, CMD=f5, ADD=95, DAT0=ff, DAT1=ff
[  100.244107] i2c i2c-0: Transaction (pre): CNT=08, CMD=f9, ADD=95, DAT0=ff, DAT1=ff
[  100.262182] i2c i2c-0: Transaction (post): CNT=08, CMD=f9, ADD=95, DAT0=ff, DAT1=ff
[  100.264175] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fa, ADD=95, DAT0=ff, DAT1=ff
[  100.281944] i2c i2c-0: Transaction (post): CNT=0c, CMD=fa, ADD=95, DAT0=ff, DAT1=ff
[  100.283773] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fb, ADD=95, DAT0=ff, DAT1=ff
[  100.302150] i2c i2c-0: Transaction (post): CNT=0c, CMD=fb, ADD=95, DAT0=ff, DAT1=ff
[  100.303984] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fc, ADD=95, DAT0=ff, DAT1=ff
[  100.322258] i2c i2c-0: Transaction (post): CNT=0c, CMD=fc, ADD=95, DAT0=ff, DAT1=ff
[  100.324219] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fd, ADD=95, DAT0=ff, DAT1=ff
[  100.342098] i2c i2c-0: Transaction (post): CNT=0c, CMD=fd, ADD=95, DAT0=ff, DAT1=ff
[  100.343864] i2c i2c-0: found normal entry for adapter 0, addr 0x4b
[  100.345893] i2c i2c-0: Transaction (pre): CNT=00, CMD=fd, ADD=96, DAT0=ff, DAT1=ff
[  100.362175] i2c i2c-0: Transaction (post): CNT=00, CMD=fd, ADD=96, DAT0=ff, DAT1=ff
[  100.364090] i2c i2c-0: Transaction (pre): CNT=0c, CMD=00, ADD=97, DAT0=ff, DAT1=ff
[  100.382191] i2c i2c-0: Transaction (post): CNT=0c, CMD=00, ADD=97, DAT0=ff, DAT1=ff
[  100.384163] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=97, DAT0=ff, DAT1=ff
[  100.402374] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=97, DAT0=ff, DAT1=ff
[  100.404239] i2c i2c-0: Transaction (pre): CNT=0c, CMD=02, ADD=97, DAT0=ff, DAT1=ff
[  100.423065] i2c i2c-0: Transaction (post): CNT=0c, CMD=02, ADD=97, DAT0=ff, DAT1=ff
[  100.424961] i2c i2c-0: Transaction (pre): CNT=0c, CMD=03, ADD=97, DAT0=ff, DAT1=ff
[  100.443351] i2c i2c-0: Transaction (post): CNT=0c, CMD=03, ADD=97, DAT0=ff, DAT1=ff
[  100.446887] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=97, DAT0=ff, DAT1=ff
[  100.463266] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=97, DAT0=ff, DAT1=ff
[  100.465340] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=97, DAT0=ff, DAT1=ff
[  100.483440] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=97, DAT0=ff, DAT1=ff
[  100.485505] i2c i2c-0: Transaction (pre): CNT=08, CMD=09, ADD=97, DAT0=ff, DAT1=ff
[  100.503102] i2c i2c-0: Transaction (post): CNT=08, CMD=09, ADD=97, DAT0=ff, DAT1=ff
[  100.505187] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0a, ADD=97, DAT0=ff, DAT1=ff
[  100.523016] i2c i2c-0: Transaction (post): CNT=0c, CMD=0a, ADD=97, DAT0=ff, DAT1=ff
[  100.525189] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0b, ADD=97, DAT0=ff, DAT1=ff
[  100.542448] i2c i2c-0: Transaction (post): CNT=0c, CMD=0b, ADD=97, DAT0=ff, DAT1=ff
[  100.544404] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0c, ADD=97, DAT0=ff, DAT1=ff
[  100.562357] i2c i2c-0: Transaction (post): CNT=0c, CMD=0c, ADD=97, DAT0=ff, DAT1=ff
[  100.564379] i2c i2c-0: Transaction (pre): CNT=0c, CMD=0d, ADD=97, DAT0=ff, DAT1=ff
[  100.582422] i2c i2c-0: Transaction (post): CNT=0c, CMD=0d, ADD=97, DAT0=ff, DAT1=ff
[  100.584469] i2c i2c-0: Transaction (pre): CNT=08, CMD=11, ADD=97, DAT0=ff, DAT1=ff
[  100.602237] i2c i2c-0: Transaction (post): CNT=08, CMD=11, ADD=97, DAT0=ff, DAT1=ff
[  100.604105] i2c i2c-0: Transaction (pre): CNT=0c, CMD=12, ADD=97, DAT0=ff, DAT1=ff
[  100.621860] i2c i2c-0: Transaction (post): CNT=0c, CMD=12, ADD=97, DAT0=ff, DAT1=ff
[  100.623627] i2c i2c-0: Transaction (pre): CNT=0c, CMD=13, ADD=97, DAT0=ff, DAT1=ff
[  100.641813] i2c i2c-0: Transaction (post): CNT=0c, CMD=13, ADD=97, DAT0=ff, DAT1=ff
[  100.643500] i2c i2c-0: Transaction (pre): CNT=0c, CMD=14, ADD=97, DAT0=ff, DAT1=ff
[  100.661798] i2c i2c-0: Transaction (post): CNT=0c, CMD=14, ADD=97, DAT0=ff, DAT1=ff
[  100.663536] i2c i2c-0: Transaction (pre): CNT=0c, CMD=15, ADD=97, DAT0=ff, DAT1=ff
[  100.681885] i2c i2c-0: Transaction (post): CNT=0c, CMD=15, ADD=97, DAT0=ff, DAT1=ff
[  100.683671] i2c i2c-0: Transaction (pre): CNT=08, CMD=19, ADD=97, DAT0=ff, DAT1=ff
[  100.701973] i2c i2c-0: Transaction (post): CNT=08, CMD=19, ADD=97, DAT0=ff, DAT1=ff
[  100.703731] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1a, ADD=97, DAT0=ff, DAT1=ff
[  100.721650] i2c i2c-0: Transaction (post): CNT=0c, CMD=1a, ADD=97, DAT0=ff, DAT1=ff
[  100.723388] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1b, ADD=97, DAT0=ff, DAT1=ff
[  100.742059] i2c i2c-0: Transaction (post): CNT=0c, CMD=1b, ADD=97, DAT0=ff, DAT1=ff
[  100.743558] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1c, ADD=97, DAT0=ff, DAT1=ff
[  100.762245] i2c i2c-0: Transaction (post): CNT=0c, CMD=1c, ADD=97, DAT0=ff, DAT1=ff
[  100.764807] i2c i2c-0: Transaction (pre): CNT=0c, CMD=1d, ADD=97, DAT0=ff, DAT1=ff
[  100.782574] i2c i2c-0: Transaction (post): CNT=0c, CMD=1d, ADD=97, DAT0=ff, DAT1=ff
[  100.784436] i2c i2c-0: Transaction (pre): CNT=08, CMD=21, ADD=97, DAT0=ff, DAT1=ff
[  100.802148] i2c i2c-0: Transaction (post): CNT=08, CMD=21, ADD=97, DAT0=ff, DAT1=ff
[  100.803977] i2c i2c-0: Transaction (pre): CNT=0c, CMD=22, ADD=97, DAT0=ff, DAT1=ff
[  100.822106] i2c i2c-0: Transaction (post): CNT=0c, CMD=22, ADD=97, DAT0=ff, DAT1=ff
[  100.824062] i2c i2c-0: Transaction (pre): CNT=0c, CMD=23, ADD=97, DAT0=ff, DAT1=ff
[  100.842021] i2c i2c-0: Transaction (post): CNT=0c, CMD=23, ADD=97, DAT0=ff, DAT1=ff
[  100.843832] i2c i2c-0: Transaction (pre): CNT=0c, CMD=24, ADD=97, DAT0=ff, DAT1=ff
[  100.862492] i2c i2c-0: Transaction (post): CNT=0c, CMD=24, ADD=97, DAT0=ff, DAT1=ff
[  100.864437] i2c i2c-0: Transaction (pre): CNT=0c, CMD=25, ADD=97, DAT0=ff, DAT1=ff
[  100.882083] i2c i2c-0: Transaction (post): CNT=0c, CMD=25, ADD=97, DAT0=ff, DAT1=ff
[  100.883964] i2c i2c-0: Transaction (pre): CNT=08, CMD=29, ADD=97, DAT0=ff, DAT1=ff
[  100.901852] i2c i2c-0: Transaction (post): CNT=08, CMD=29, ADD=97, DAT0=ff, DAT1=ff
[  100.903589] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2a, ADD=97, DAT0=ff, DAT1=ff
[  100.922142] i2c i2c-0: Transaction (post): CNT=0c, CMD=2a, ADD=97, DAT0=ff, DAT1=ff
[  100.923885] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2b, ADD=97, DAT0=ff, DAT1=ff
[  100.941741] i2c i2c-0: Transaction (post): CNT=0c, CMD=2b, ADD=97, DAT0=ff, DAT1=ff
[  100.943353] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2c, ADD=97, DAT0=ff, DAT1=ff
[  100.962148] i2c i2c-0: Transaction (post): CNT=0c, CMD=2c, ADD=97, DAT0=ff, DAT1=ff
[  100.964056] i2c i2c-0: Transaction (pre): CNT=0c, CMD=2d, ADD=97, DAT0=ff, DAT1=ff
[  100.982635] i2c i2c-0: Transaction (post): CNT=0c, CMD=2d, ADD=97, DAT0=ff, DAT1=ff
[  100.984610] i2c i2c-0: Transaction (pre): CNT=08, CMD=31, ADD=97, DAT0=ff, DAT1=ff
[  101.002180] i2c i2c-0: Transaction (post): CNT=08, CMD=31, ADD=97, DAT0=ff, DAT1=ff
[  101.004100] i2c i2c-0: Transaction (pre): CNT=0c, CMD=32, ADD=97, DAT0=ff, DAT1=ff
[  101.022036] i2c i2c-0: Transaction (post): CNT=0c, CMD=32, ADD=97, DAT0=ff, DAT1=ff
[  101.023956] i2c i2c-0: Transaction (pre): CNT=0c, CMD=33, ADD=97, DAT0=ff, DAT1=ff
[  101.042102] i2c i2c-0: Transaction (post): CNT=0c, CMD=33, ADD=97, DAT0=ff, DAT1=ff
[  101.044690] i2c i2c-0: Transaction (pre): CNT=0c, CMD=34, ADD=97, DAT0=ff, DAT1=ff
[  101.062046] i2c i2c-0: Transaction (post): CNT=0c, CMD=34, ADD=97, DAT0=ff, DAT1=ff
[  101.064671] i2c i2c-0: Transaction (pre): CNT=0c, CMD=35, ADD=97, DAT0=ff, DAT1=ff
[  101.082028] i2c i2c-0: Transaction (post): CNT=0c, CMD=35, ADD=97, DAT0=ff, DAT1=ff
[  101.084609] i2c i2c-0: Transaction (pre): CNT=08, CMD=39, ADD=97, DAT0=ff, DAT1=ff
[  101.101554] i2c i2c-0: Transaction (post): CNT=08, CMD=39, ADD=97, DAT0=ff, DAT1=ff
[  101.103117] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3a, ADD=97, DAT0=ff, DAT1=ff
[  101.122245] i2c i2c-0: Transaction (post): CNT=0c, CMD=3a, ADD=97, DAT0=ff, DAT1=ff
[  101.125013] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3b, ADD=97, DAT0=ff, DAT1=ff
[  101.142091] i2c i2c-0: Transaction (post): CNT=0c, CMD=3b, ADD=97, DAT0=ff, DAT1=ff
[  101.144712] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3c, ADD=97, DAT0=ff, DAT1=ff
[  101.162120] i2c i2c-0: Transaction (post): CNT=0c, CMD=3c, ADD=97, DAT0=ff, DAT1=ff
[  101.164786] i2c i2c-0: Transaction (pre): CNT=0c, CMD=3d, ADD=97, DAT0=ff, DAT1=ff
[  101.183469] i2c i2c-0: Transaction (post): CNT=0c, CMD=3d, ADD=97, DAT0=ff, DAT1=ff
[  101.186773] i2c i2c-0: Transaction (pre): CNT=08, CMD=41, ADD=97, DAT0=ff, DAT1=ff
[  101.203436] i2c i2c-0: Transaction (post): CNT=08, CMD=41, ADD=97, DAT0=ff, DAT1=ff
[  101.206741] i2c i2c-0: Transaction (pre): CNT=0c, CMD=42, ADD=97, DAT0=ff, DAT1=ff
[  101.223427] i2c i2c-0: Transaction (post): CNT=0c, CMD=42, ADD=97, DAT0=ff, DAT1=ff
[  101.226741] i2c i2c-0: Transaction (pre): CNT=0c, CMD=43, ADD=97, DAT0=ff, DAT1=ff
[  101.243422] i2c i2c-0: Transaction (post): CNT=0c, CMD=43, ADD=97, DAT0=ff, DAT1=ff
[  101.245169] i2c i2c-0: Transaction (pre): CNT=0c, CMD=44, ADD=97, DAT0=ff, DAT1=ff
[  101.262179] i2c i2c-0: Transaction (post): CNT=0c, CMD=44, ADD=97, DAT0=ff, DAT1=ff
[  101.264328] i2c i2c-0: Transaction (pre): CNT=0c, CMD=45, ADD=97, DAT0=ff, DAT1=ff
[  101.282187] i2c i2c-0: Transaction (post): CNT=0c, CMD=45, ADD=97, DAT0=ff, DAT1=ff
[  101.284029] i2c i2c-0: Transaction (pre): CNT=08, CMD=49, ADD=97, DAT0=ff, DAT1=ff
[  101.301559] i2c i2c-0: Transaction (post): CNT=08, CMD=49, ADD=97, DAT0=ff, DAT1=ff
[  101.303167] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4a, ADD=97, DAT0=ff, DAT1=ff
[  101.321395] i2c i2c-0: Transaction (post): CNT=0c, CMD=4a, ADD=97, DAT0=ff, DAT1=ff
[  101.322797] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4b, ADD=97, DAT0=ff, DAT1=ff
[  101.341361] i2c i2c-0: Transaction (post): CNT=0c, CMD=4b, ADD=97, DAT0=ff, DAT1=ff
[  101.342733] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4c, ADD=97, DAT0=ff, DAT1=ff
[  101.361379] i2c i2c-0: Transaction (post): CNT=0c, CMD=4c, ADD=97, DAT0=ff, DAT1=ff
[  101.362765] i2c i2c-0: Transaction (pre): CNT=0c, CMD=4d, ADD=97, DAT0=ff, DAT1=ff
[  101.381392] i2c i2c-0: Transaction (post): CNT=0c, CMD=4d, ADD=97, DAT0=ff, DAT1=ff
[  101.382859] i2c i2c-0: Transaction (pre): CNT=08, CMD=51, ADD=97, DAT0=ff, DAT1=ff
[  101.401405] i2c i2c-0: Transaction (post): CNT=08, CMD=51, ADD=97, DAT0=ff, DAT1=ff
[  101.402799] i2c i2c-0: Transaction (pre): CNT=0c, CMD=52, ADD=97, DAT0=ff, DAT1=ff
[  101.421414] i2c i2c-0: Transaction (post): CNT=0c, CMD=52, ADD=97, DAT0=ff, DAT1=ff
[  101.422858] i2c i2c-0: Transaction (pre): CNT=0c, CMD=53, ADD=97, DAT0=ff, DAT1=ff
[  101.441407] i2c i2c-0: Transaction (post): CNT=0c, CMD=53, ADD=97, DAT0=ff, DAT1=ff
[  101.442809] i2c i2c-0: Transaction (pre): CNT=0c, CMD=54, ADD=97, DAT0=ff, DAT1=ff
[  101.461512] i2c i2c-0: Transaction (post): CNT=0c, CMD=54, ADD=97, DAT0=ff, DAT1=ff
[  101.463311] i2c i2c-0: Transaction (pre): CNT=0c, CMD=55, ADD=97, DAT0=ff, DAT1=ff
[  101.481574] i2c i2c-0: Transaction (post): CNT=0c, CMD=55, ADD=97, DAT0=ff, DAT1=ff
[  101.483110] i2c i2c-0: Transaction (pre): CNT=08, CMD=59, ADD=97, DAT0=ff, DAT1=ff
[  101.501352] i2c i2c-0: Transaction (post): CNT=08, CMD=59, ADD=97, DAT0=ff, DAT1=ff
[  101.502708] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5a, ADD=97, DAT0=ff, DAT1=ff
[  101.521460] i2c i2c-0: Transaction (post): CNT=0c, CMD=5a, ADD=97, DAT0=ff, DAT1=ff
[  101.522962] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5b, ADD=97, DAT0=ff, DAT1=ff
[  101.541775] i2c i2c-0: Transaction (post): CNT=0c, CMD=5b, ADD=97, DAT0=ff, DAT1=ff
[  101.543056] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5c, ADD=97, DAT0=ff, DAT1=ff
[  101.561528] i2c i2c-0: Transaction (post): CNT=0c, CMD=5c, ADD=97, DAT0=ff, DAT1=ff
[  101.562755] i2c i2c-0: Transaction (pre): CNT=0c, CMD=5d, ADD=97, DAT0=ff, DAT1=ff
[  101.581735] i2c i2c-0: Transaction (post): CNT=0c, CMD=5d, ADD=97, DAT0=ff, DAT1=ff
[  101.583257] i2c i2c-0: Transaction (pre): CNT=08, CMD=61, ADD=97, DAT0=ff, DAT1=ff
[  101.602274] i2c i2c-0: Transaction (post): CNT=08, CMD=61, ADD=97, DAT0=ff, DAT1=ff
[  101.603682] i2c i2c-0: Transaction (pre): CNT=0c, CMD=62, ADD=97, DAT0=ff, DAT1=ff
[  101.622828] i2c i2c-0: Transaction (post): CNT=0c, CMD=62, ADD=97, DAT0=ff, DAT1=ff
[  101.624776] i2c i2c-0: Transaction (pre): CNT=0c, CMD=63, ADD=97, DAT0=ff, DAT1=ff
[  101.642117] i2c i2c-0: Transaction (post): CNT=0c, CMD=63, ADD=97, DAT0=ff, DAT1=ff
[  101.643926] i2c i2c-0: Transaction (pre): CNT=0c, CMD=64, ADD=97, DAT0=ff, DAT1=ff
[  101.662121] i2c i2c-0: Transaction (post): CNT=0c, CMD=64, ADD=97, DAT0=ff, DAT1=ff
[  101.663927] i2c i2c-0: Transaction (pre): CNT=0c, CMD=65, ADD=97, DAT0=ff, DAT1=ff
[  101.682174] i2c i2c-0: Transaction (post): CNT=0c, CMD=65, ADD=97, DAT0=ff, DAT1=ff
[  101.683994] i2c i2c-0: Transaction (pre): CNT=08, CMD=69, ADD=97, DAT0=ff, DAT1=ff
[  101.702136] i2c i2c-0: Transaction (post): CNT=08, CMD=69, ADD=97, DAT0=ff, DAT1=ff
[  101.703980] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6a, ADD=97, DAT0=ff, DAT1=ff
[  101.722155] i2c i2c-0: Transaction (post): CNT=0c, CMD=6a, ADD=97, DAT0=ff, DAT1=ff
[  101.723666] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6b, ADD=97, DAT0=ff, DAT1=ff
[  101.742431] i2c i2c-0: Transaction (post): CNT=0c, CMD=6b, ADD=97, DAT0=ff, DAT1=ff
[  101.744374] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6c, ADD=97, DAT0=ff, DAT1=ff
[  101.762348] i2c i2c-0: Transaction (post): CNT=0c, CMD=6c, ADD=97, DAT0=ff, DAT1=ff
[  101.764174] i2c i2c-0: Transaction (pre): CNT=0c, CMD=6d, ADD=97, DAT0=ff, DAT1=ff
[  101.782441] i2c i2c-0: Transaction (post): CNT=0c, CMD=6d, ADD=97, DAT0=ff, DAT1=ff
[  101.784304] i2c i2c-0: Transaction (pre): CNT=08, CMD=71, ADD=97, DAT0=ff, DAT1=ff
[  101.802353] i2c i2c-0: Transaction (post): CNT=08, CMD=71, ADD=97, DAT0=ff, DAT1=ff
[  101.804215] i2c i2c-0: Transaction (pre): CNT=0c, CMD=72, ADD=97, DAT0=ff, DAT1=ff
[  101.822240] i2c i2c-0: Transaction (post): CNT=0c, CMD=72, ADD=97, DAT0=ff, DAT1=ff
[  101.824115] i2c i2c-0: Transaction (pre): CNT=0c, CMD=73, ADD=97, DAT0=ff, DAT1=ff
[  101.841590] i2c i2c-0: Transaction (post): CNT=0c, CMD=73, ADD=97, DAT0=ff, DAT1=ff
[  101.843103] i2c i2c-0: Transaction (pre): CNT=0c, CMD=74, ADD=97, DAT0=ff, DAT1=ff
[  101.862265] i2c i2c-0: Transaction (post): CNT=0c, CMD=74, ADD=97, DAT0=ff, DAT1=ff
[  101.864848] i2c i2c-0: Transaction (pre): CNT=0c, CMD=75, ADD=97, DAT0=ff, DAT1=ff
[  101.882276] i2c i2c-0: Transaction (post): CNT=0c, CMD=75, ADD=97, DAT0=ff, DAT1=ff
[  101.885098] i2c i2c-0: Transaction (pre): CNT=08, CMD=79, ADD=97, DAT0=ff, DAT1=ff
[  101.902358] i2c i2c-0: Transaction (post): CNT=08, CMD=79, ADD=97, DAT0=ff, DAT1=ff
[  101.904242] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7a, ADD=97, DAT0=ff, DAT1=ff
[  101.922213] i2c i2c-0: Transaction (post): CNT=0c, CMD=7a, ADD=97, DAT0=ff, DAT1=ff
[  101.924237] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7b, ADD=97, DAT0=ff, DAT1=ff
[  101.942253] i2c i2c-0: Transaction (post): CNT=0c, CMD=7b, ADD=97, DAT0=ff, DAT1=ff
[  101.944188] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7c, ADD=97, DAT0=ff, DAT1=ff
[  101.962330] i2c i2c-0: Transaction (post): CNT=0c, CMD=7c, ADD=97, DAT0=ff, DAT1=ff
[  101.964241] i2c i2c-0: Transaction (pre): CNT=0c, CMD=7d, ADD=97, DAT0=ff, DAT1=ff
[  101.982507] i2c i2c-0: Transaction (post): CNT=0c, CMD=7d, ADD=97, DAT0=ff, DAT1=ff
[  101.984461] i2c i2c-0: Transaction (pre): CNT=08, CMD=81, ADD=97, DAT0=ff, DAT1=ff
[  102.003760] i2c i2c-0: Transaction (post): CNT=08, CMD=81, ADD=97, DAT0=ff, DAT1=ff
[  102.005714] i2c i2c-0: Transaction (pre): CNT=0c, CMD=82, ADD=97, DAT0=ff, DAT1=ff
[  102.022203] i2c i2c-0: Transaction (post): CNT=0c, CMD=82, ADD=97, DAT0=ff, DAT1=ff
[  102.024223] i2c i2c-0: Transaction (pre): CNT=0c, CMD=83, ADD=97, DAT0=ff, DAT1=ff
[  102.042414] i2c i2c-0: Transaction (post): CNT=0c, CMD=83, ADD=97, DAT0=ff, DAT1=ff
[  102.044350] i2c i2c-0: Transaction (pre): CNT=0c, CMD=84, ADD=97, DAT0=ff, DAT1=ff
[  102.062268] i2c i2c-0: Transaction (post): CNT=0c, CMD=84, ADD=97, DAT0=ff, DAT1=ff
[  102.064203] i2c i2c-0: Transaction (pre): CNT=0c, CMD=85, ADD=97, DAT0=ff, DAT1=ff
[  102.082330] i2c i2c-0: Transaction (post): CNT=0c, CMD=85, ADD=97, DAT0=ff, DAT1=ff
[  102.084116] i2c i2c-0: Transaction (pre): CNT=08, CMD=89, ADD=97, DAT0=ff, DAT1=ff
[  102.102241] i2c i2c-0: Transaction (post): CNT=08, CMD=89, ADD=97, DAT0=ff, DAT1=ff
[  102.103970] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8a, ADD=97, DAT0=ff, DAT1=ff
[  102.122192] i2c i2c-0: Transaction (post): CNT=0c, CMD=8a, ADD=97, DAT0=ff, DAT1=ff
[  102.124055] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8b, ADD=97, DAT0=ff, DAT1=ff
[  102.142144] i2c i2c-0: Transaction (post): CNT=0c, CMD=8b, ADD=97, DAT0=ff, DAT1=ff
[  102.144058] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8c, ADD=97, DAT0=ff, DAT1=ff
[  102.162233] i2c i2c-0: Transaction (post): CNT=0c, CMD=8c, ADD=97, DAT0=ff, DAT1=ff
[  102.164170] i2c i2c-0: Transaction (pre): CNT=0c, CMD=8d, ADD=97, DAT0=ff, DAT1=ff
[  102.182198] i2c i2c-0: Transaction (post): CNT=0c, CMD=8d, ADD=97, DAT0=ff, DAT1=ff
[  102.184077] i2c i2c-0: Transaction (pre): CNT=08, CMD=91, ADD=97, DAT0=ff, DAT1=ff
[  102.202152] i2c i2c-0: Transaction (post): CNT=08, CMD=91, ADD=97, DAT0=ff, DAT1=ff
[  102.203880] i2c i2c-0: Transaction (pre): CNT=0c, CMD=92, ADD=97, DAT0=ff, DAT1=ff
[  102.222430] i2c i2c-0: Transaction (post): CNT=0c, CMD=92, ADD=97, DAT0=ff, DAT1=ff
[  102.224409] i2c i2c-0: Transaction (pre): CNT=0c, CMD=93, ADD=97, DAT0=ff, DAT1=ff
[  102.242376] i2c i2c-0: Transaction (post): CNT=0c, CMD=93, ADD=97, DAT0=ff, DAT1=ff
[  102.244299] i2c i2c-0: Transaction (pre): CNT=0c, CMD=94, ADD=97, DAT0=ff, DAT1=ff
[  102.262213] i2c i2c-0: Transaction (post): CNT=0c, CMD=94, ADD=97, DAT0=ff, DAT1=ff
[  102.264261] i2c i2c-0: Transaction (pre): CNT=0c, CMD=95, ADD=97, DAT0=ff, DAT1=ff
[  102.282297] i2c i2c-0: Transaction (post): CNT=0c, CMD=95, ADD=97, DAT0=ff, DAT1=ff
[  102.284255] i2c i2c-0: Transaction (pre): CNT=08, CMD=99, ADD=97, DAT0=ff, DAT1=ff
[  102.301766] i2c i2c-0: Transaction (post): CNT=08, CMD=99, ADD=97, DAT0=ff, DAT1=ff
[  102.303178] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9a, ADD=97, DAT0=ff, DAT1=ff
[  102.323546] i2c i2c-0: Transaction (post): CNT=0c, CMD=9a, ADD=97, DAT0=ff, DAT1=ff
[  102.325517] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9b, ADD=97, DAT0=ff, DAT1=ff
[  102.342660] i2c i2c-0: Transaction (post): CNT=0c, CMD=9b, ADD=97, DAT0=ff, DAT1=ff
[  102.344807] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9c, ADD=97, DAT0=ff, DAT1=ff
[  102.362574] i2c i2c-0: Transaction (post): CNT=0c, CMD=9c, ADD=97, DAT0=ff, DAT1=ff
[  102.364796] i2c i2c-0: Transaction (pre): CNT=0c, CMD=9d, ADD=97, DAT0=ff, DAT1=ff
[  102.382496] i2c i2c-0: Transaction (post): CNT=0c, CMD=9d, ADD=97, DAT0=ff, DAT1=ff
[  102.384526] i2c i2c-0: Transaction (pre): CNT=08, CMD=a1, ADD=97, DAT0=ff, DAT1=ff
[  102.402446] i2c i2c-0: Transaction (post): CNT=08, CMD=a1, ADD=97, DAT0=ff, DAT1=ff
[  102.404515] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a2, ADD=97, DAT0=ff, DAT1=ff
[  102.422484] i2c i2c-0: Transaction (post): CNT=0c, CMD=a2, ADD=97, DAT0=ff, DAT1=ff
[  102.424543] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a3, ADD=97, DAT0=ff, DAT1=ff
[  102.442638] i2c i2c-0: Transaction (post): CNT=0c, CMD=a3, ADD=97, DAT0=ff, DAT1=ff
[  102.443981] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a4, ADD=97, DAT0=ff, DAT1=ff
[  102.462590] i2c i2c-0: Transaction (post): CNT=0c, CMD=a4, ADD=97, DAT0=ff, DAT1=ff
[  102.464676] i2c i2c-0: Transaction (pre): CNT=0c, CMD=a5, ADD=97, DAT0=ff, DAT1=ff
[  102.483794] i2c i2c-0: Transaction (post): CNT=0c, CMD=a5, ADD=97, DAT0=ff, DAT1=ff
[  102.486809] i2c i2c-0: Transaction (pre): CNT=08, CMD=a9, ADD=97, DAT0=ff, DAT1=ff
[  102.502508] i2c i2c-0: Transaction (post): CNT=08, CMD=a9, ADD=97, DAT0=ff, DAT1=ff
[  102.505352] i2c i2c-0: Transaction (pre): CNT=0c, CMD=aa, ADD=97, DAT0=ff, DAT1=ff
[  102.523194] i2c i2c-0: Transaction (post): CNT=0c, CMD=aa, ADD=97, DAT0=ff, DAT1=ff
[  102.525978] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ab, ADD=97, DAT0=ff, DAT1=ff
[  102.543211] i2c i2c-0: Transaction (post): CNT=0c, CMD=ab, ADD=97, DAT0=ff, DAT1=ff
[  102.546008] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ac, ADD=97, DAT0=ff, DAT1=ff
[  102.562568] i2c i2c-0: Transaction (post): CNT=0c, CMD=ac, ADD=97, DAT0=ff, DAT1=ff
[  102.564694] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ad, ADD=97, DAT0=ff, DAT1=ff
[  102.583213] i2c i2c-0: Transaction (post): CNT=0c, CMD=ad, ADD=97, DAT0=ff, DAT1=ff
[  102.585985] i2c i2c-0: Transaction (pre): CNT=08, CMD=b1, ADD=97, DAT0=ff, DAT1=ff
[  102.602481] i2c i2c-0: Transaction (post): CNT=08, CMD=b1, ADD=97, DAT0=ff, DAT1=ff
[  102.604474] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b2, ADD=97, DAT0=ff, DAT1=ff
[  102.622503] i2c i2c-0: Transaction (post): CNT=0c, CMD=b2, ADD=97, DAT0=ff, DAT1=ff
[  102.624902] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b3, ADD=97, DAT0=ff, DAT1=ff
[  102.642586] i2c i2c-0: Transaction (post): CNT=0c, CMD=b3, ADD=97, DAT0=ff, DAT1=ff
[  102.644657] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b4, ADD=97, DAT0=ff, DAT1=ff
[  102.662582] i2c i2c-0: Transaction (post): CNT=0c, CMD=b4, ADD=97, DAT0=ff, DAT1=ff
[  102.664643] i2c i2c-0: Transaction (pre): CNT=0c, CMD=b5, ADD=97, DAT0=ff, DAT1=ff
[  102.682544] i2c i2c-0: Transaction (post): CNT=0c, CMD=b5, ADD=97, DAT0=ff, DAT1=ff
[  102.684583] i2c i2c-0: Transaction (pre): CNT=08, CMD=b9, ADD=97, DAT0=ff, DAT1=ff
[  102.703178] i2c i2c-0: Transaction (post): CNT=08, CMD=b9, ADD=97, DAT0=ff, DAT1=ff
[  102.705923] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ba, ADD=97, DAT0=ff, DAT1=ff
[  102.723167] i2c i2c-0: Transaction (post): CNT=0c, CMD=ba, ADD=97, DAT0=ff, DAT1=ff
[  102.725863] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bb, ADD=97, DAT0=ff, DAT1=ff
[  102.743090] i2c i2c-0: Transaction (post): CNT=0c, CMD=bb, ADD=97, DAT0=ff, DAT1=ff
[  102.745799] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bc, ADD=97, DAT0=ff, DAT1=ff
[  102.763091] i2c i2c-0: Transaction (post): CNT=0c, CMD=bc, ADD=97, DAT0=ff, DAT1=ff
[  102.765801] i2c i2c-0: Transaction (pre): CNT=0c, CMD=bd, ADD=97, DAT0=ff, DAT1=ff
[  102.782339] i2c i2c-0: Transaction (post): CNT=0c, CMD=bd, ADD=97, DAT0=ff, DAT1=ff
[  102.784515] i2c i2c-0: Transaction (pre): CNT=08, CMD=c1, ADD=97, DAT0=ff, DAT1=ff
[  102.803592] i2c i2c-0: Transaction (post): CNT=08, CMD=c1, ADD=97, DAT0=ff, DAT1=ff
[  102.805522] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c2, ADD=97, DAT0=ff, DAT1=ff
[  102.822486] i2c i2c-0: Transaction (post): CNT=0c, CMD=c2, ADD=97, DAT0=ff, DAT1=ff
[  102.824545] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c3, ADD=97, DAT0=ff, DAT1=ff
[  102.842254] i2c i2c-0: Transaction (post): CNT=0c, CMD=c3, ADD=97, DAT0=ff, DAT1=ff
[  102.844168] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c4, ADD=97, DAT0=ff, DAT1=ff
[  102.862315] i2c i2c-0: Transaction (post): CNT=0c, CMD=c4, ADD=97, DAT0=ff, DAT1=ff
[  102.865102] i2c i2c-0: Transaction (pre): CNT=0c, CMD=c5, ADD=97, DAT0=ff, DAT1=ff
[  102.882365] i2c i2c-0: Transaction (post): CNT=0c, CMD=c5, ADD=97, DAT0=ff, DAT1=ff
[  102.884285] i2c i2c-0: Transaction (pre): CNT=08, CMD=c9, ADD=97, DAT0=ff, DAT1=ff
[  102.902378] i2c i2c-0: Transaction (post): CNT=08, CMD=c9, ADD=97, DAT0=ff, DAT1=ff
[  102.904220] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ca, ADD=97, DAT0=ff, DAT1=ff
[  102.922261] i2c i2c-0: Transaction (post): CNT=0c, CMD=ca, ADD=97, DAT0=ff, DAT1=ff
[  102.924159] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cb, ADD=97, DAT0=ff, DAT1=ff
[  102.942282] i2c i2c-0: Transaction (post): CNT=0c, CMD=cb, ADD=97, DAT0=ff, DAT1=ff
[  102.944061] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cc, ADD=97, DAT0=ff, DAT1=ff
[  102.962083] i2c i2c-0: Transaction (post): CNT=0c, CMD=cc, ADD=97, DAT0=ff, DAT1=ff
[  102.963866] i2c i2c-0: Transaction (pre): CNT=0c, CMD=cd, ADD=97, DAT0=ff, DAT1=ff
[  102.982517] i2c i2c-0: Transaction (post): CNT=0c, CMD=cd, ADD=97, DAT0=ff, DAT1=ff
[  102.984351] i2c i2c-0: Transaction (pre): CNT=08, CMD=d1, ADD=97, DAT0=ff, DAT1=ff
[  103.002182] i2c i2c-0: Transaction (post): CNT=08, CMD=d1, ADD=97, DAT0=ff, DAT1=ff
[  103.003955] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d2, ADD=97, DAT0=ff, DAT1=ff
[  103.022057] i2c i2c-0: Transaction (post): CNT=0c, CMD=d2, ADD=97, DAT0=ff, DAT1=ff
[  103.023776] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d3, ADD=97, DAT0=ff, DAT1=ff
[  103.042374] i2c i2c-0: Transaction (post): CNT=0c, CMD=d3, ADD=97, DAT0=ff, DAT1=ff
[  103.044241] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d4, ADD=97, DAT0=ff, DAT1=ff
[  103.062229] i2c i2c-0: Transaction (post): CNT=0c, CMD=d4, ADD=97, DAT0=ff, DAT1=ff
[  103.064020] i2c i2c-0: Transaction (pre): CNT=0c, CMD=d5, ADD=97, DAT0=ff, DAT1=ff
[  103.082142] i2c i2c-0: Transaction (post): CNT=0c, CMD=d5, ADD=97, DAT0=ff, DAT1=ff
[  103.083939] i2c i2c-0: Transaction (pre): CNT=08, CMD=d9, ADD=97, DAT0=ff, DAT1=ff
[  103.102306] i2c i2c-0: Transaction (post): CNT=08, CMD=d9, ADD=97, DAT0=ff, DAT1=ff
[  103.104164] i2c i2c-0: Transaction (pre): CNT=0c, CMD=da, ADD=97, DAT0=ff, DAT1=ff
[  103.122235] i2c i2c-0: Transaction (post): CNT=0c, CMD=da, ADD=97, DAT0=ff, DAT1=ff
[  103.124102] i2c i2c-0: Transaction (pre): CNT=0c, CMD=db, ADD=97, DAT0=ff, DAT1=ff
[  103.142225] i2c i2c-0: Transaction (post): CNT=0c, CMD=db, ADD=97, DAT0=ff, DAT1=ff
[  103.144056] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dc, ADD=97, DAT0=ff, DAT1=ff
[  103.162332] i2c i2c-0: Transaction (post): CNT=0c, CMD=dc, ADD=97, DAT0=ff, DAT1=ff
[  103.164268] i2c i2c-0: Transaction (pre): CNT=0c, CMD=dd, ADD=97, DAT0=ff, DAT1=ff
[  103.182203] i2c i2c-0: Transaction (post): CNT=0c, CMD=dd, ADD=97, DAT0=ff, DAT1=ff
[  103.184071] i2c i2c-0: Transaction (pre): CNT=08, CMD=e1, ADD=97, DAT0=ff, DAT1=ff
[  103.202188] i2c i2c-0: Transaction (post): CNT=08, CMD=e1, ADD=97, DAT0=ff, DAT1=ff
[  103.204054] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e2, ADD=97, DAT0=ff, DAT1=ff
[  103.222263] i2c i2c-0: Transaction (post): CNT=0c, CMD=e2, ADD=97, DAT0=ff, DAT1=ff
[  103.224116] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e3, ADD=97, DAT0=ff, DAT1=ff
[  103.242331] i2c i2c-0: Transaction (post): CNT=0c, CMD=e3, ADD=97, DAT0=ff, DAT1=ff
[  103.244162] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e4, ADD=97, DAT0=ff, DAT1=ff
[  103.262235] i2c i2c-0: Transaction (post): CNT=0c, CMD=e4, ADD=97, DAT0=ff, DAT1=ff
[  103.264219] i2c i2c-0: Transaction (pre): CNT=0c, CMD=e5, ADD=97, DAT0=ff, DAT1=ff
[  103.282184] i2c i2c-0: Transaction (post): CNT=0c, CMD=e5, ADD=97, DAT0=ff, DAT1=ff
[  103.284095] i2c i2c-0: Transaction (pre): CNT=08, CMD=e9, ADD=97, DAT0=ff, DAT1=ff
[  103.302205] i2c i2c-0: Transaction (post): CNT=08, CMD=e9, ADD=97, DAT0=ff, DAT1=ff
[  103.304103] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ea, ADD=97, DAT0=ff, DAT1=ff
[  103.322236] i2c i2c-0: Transaction (post): CNT=0c, CMD=ea, ADD=97, DAT0=ff, DAT1=ff
[  103.324135] i2c i2c-0: Transaction (pre): CNT=0c, CMD=eb, ADD=97, DAT0=ff, DAT1=ff
[  103.342155] i2c i2c-0: Transaction (post): CNT=0c, CMD=eb, ADD=97, DAT0=ff, DAT1=ff
[  103.344029] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ec, ADD=97, DAT0=ff, DAT1=ff
[  103.362105] i2c i2c-0: Transaction (post): CNT=0c, CMD=ec, ADD=97, DAT0=ff, DAT1=ff
[  103.363920] i2c i2c-0: Transaction (pre): CNT=0c, CMD=ed, ADD=97, DAT0=ff, DAT1=ff
[  103.382220] i2c i2c-0: Transaction (post): CNT=0c, CMD=ed, ADD=97, DAT0=ff, DAT1=ff
[  103.384030] i2c i2c-0: Transaction (pre): CNT=08, CMD=f1, ADD=97, DAT0=ff, DAT1=ff
[  103.402229] i2c i2c-0: Transaction (post): CNT=08, CMD=f1, ADD=97, DAT0=ff, DAT1=ff
[  103.404093] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f2, ADD=97, DAT0=ff, DAT1=ff
[  103.422812] i2c i2c-0: Transaction (post): CNT=0c, CMD=f2, ADD=97, DAT0=ff, DAT1=ff
[  103.425325] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f3, ADD=97, DAT0=ff, DAT1=ff
[  103.442714] i2c i2c-0: Transaction (post): CNT=0c, CMD=f3, ADD=97, DAT0=ff, DAT1=ff
[  103.444662] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f4, ADD=97, DAT0=ff, DAT1=ff
[  103.462191] i2c i2c-0: Transaction (post): CNT=0c, CMD=f4, ADD=97, DAT0=ff, DAT1=ff
[  103.464072] i2c i2c-0: Transaction (pre): CNT=0c, CMD=f5, ADD=97, DAT0=ff, DAT1=ff
[  103.482628] i2c i2c-0: Transaction (post): CNT=0c, CMD=f5, ADD=97, DAT0=ff, DAT1=ff
[  103.484527] i2c i2c-0: Transaction (pre): CNT=08, CMD=f9, ADD=97, DAT0=ff, DAT1=ff
[  103.502348] i2c i2c-0: Transaction (post): CNT=08, CMD=f9, ADD=97, DAT0=ff, DAT1=ff
[  103.504229] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fa, ADD=97, DAT0=ff, DAT1=ff
[  103.522453] i2c i2c-0: Transaction (post): CNT=0c, CMD=fa, ADD=97, DAT0=ff, DAT1=ff
[  103.524319] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fb, ADD=97, DAT0=ff, DAT1=ff
[  103.543154] i2c i2c-0: Transaction (post): CNT=0c, CMD=fb, ADD=97, DAT0=ff, DAT1=ff
[  103.545026] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fc, ADD=97, DAT0=ff, DAT1=ff
[  103.565033] i2c i2c-0: Transaction (post): CNT=0c, CMD=fc, ADD=97, DAT0=ff, DAT1=ff
[  103.567026] i2c i2c-0: Transaction (pre): CNT=0c, CMD=fd, ADD=97, DAT0=ff, DAT1=ff
[  103.582201] i2c i2c-0: Transaction (post): CNT=0c, CMD=fd, ADD=97, DAT0=ff, DAT1=ff
[  103.587939] i2c-core: driver [lm78] registered
[  103.590461] i2c i2c-0: found normal entry for adapter 0, addr 0x28
[  103.593726] i2c i2c-0: Transaction (pre): CNT=00, CMD=fd, ADD=50, DAT0=ff, DAT1=ff
[  103.612473] i2c i2c-0: Transaction (post): CNT=00, CMD=fd, ADD=50, DAT0=ff, DAT1=ff
[  103.614478] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=51, DAT0=ff, DAT1=ff
[  103.632660] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=51, DAT0=ff, DAT1=ff
[  103.634703] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[  103.636830] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=52, DAT0=ff, DAT1=ff
[  103.653007] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=52, DAT0=ff, DAT1=ff
[  103.654607] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=53, DAT0=ff, DAT1=ff
[  103.672294] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=53, DAT0=ff, DAT1=ff
[  103.673775] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[  103.676065] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=54, DAT0=ff, DAT1=ff
[  103.692322] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=54, DAT0=ff, DAT1=ff
[  103.694331] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=55, DAT0=ff, DAT1=ff
[  103.712285] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=55, DAT0=ff, DAT1=ff
[  103.714111] i2c i2c-0: found normal entry for adapter 0, addr 0x2b
[  103.716109] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=56, DAT0=ff, DAT1=ff
[  103.732273] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=56, DAT0=ff, DAT1=ff
[  103.734173] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=57, DAT0=ff, DAT1=ff
[  103.752159] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=57, DAT0=ff, DAT1=ff
[  103.753852] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  103.755789] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[  103.772147] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[  103.774108] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[  103.792249] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[  103.794028] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[  103.796027] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[  103.812403] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[  103.814382] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[  103.832331] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[  103.834188] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  103.836120] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[  103.852270] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[  103.854196] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[  103.872269] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[  103.874153] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[  103.876123] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5e, DAT0=ff, DAT1=ff
[  103.892322] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5e, DAT0=ff, DAT1=ff
[  103.894268] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5f, DAT0=ff, DAT1=ff
[  103.912958] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5f, DAT0=ff, DAT1=ff
[  103.919661] i2c-core: driver [lm85] registered
[  103.923646] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  103.926342] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[  103.943008] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=58, DAT0=ff, DAT1=ff
[  103.946002] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  103.963134] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  103.965790] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=59, DAT0=ff, DAT1=ff
[  103.982714] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=59, DAT0=ff, DAT1=ff
[  103.984673] i2c i2c-0: Detecting device at 0x2c with COMPANY: 0xff and VERSTEP: 0xff
[  103.986291] i2c i2c-0: Autodetection failed: unsupported version
[  103.987574] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[  103.989578] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=5a, DAT0=ff, DAT1=ff
[  104.012663] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=5a, DAT0=ff, DAT1=ff
[  104.014550] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  104.032612] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  104.034557] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=5b, DAT0=ff, DAT1=ff
[  104.052558] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=5b, DAT0=ff, DAT1=ff
[  104.054289] i2c i2c-0: Detecting device at 0x2d with COMPANY: 0xff and VERSTEP: 0xff
[  104.055775] i2c i2c-0: Autodetection failed: unsupported version
[  104.057070] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  104.059087] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[  104.083593] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=5c, DAT0=ff, DAT1=ff
[  104.085580] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  104.102385] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  104.104364] i2c i2c-0: Transaction (pre): CNT=08, CMD=3f, ADD=5d, DAT0=ff, DAT1=ff
[  104.122176] i2c i2c-0: Transaction (post): CNT=08, CMD=3f, ADD=5d, DAT0=ff, DAT1=ff
[  104.123898] i2c i2c-0: Detecting device at 0x2e with COMPANY: 0xff and VERSTEP: 0xff
[  104.125358] i2c i2c-0: Autodetection failed: unsupported version
[  104.131649] i2c-core: driver [lm87] registered
[  104.133582] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  104.135516] i2c i2c-0: Transaction (pre): CNT=00, CMD=3f, ADD=58, DAT0=ff, DAT1=ff
[  104.155317] i2c i2c-0: Transaction (post): CNT=00, CMD=3f, ADD=58, DAT0=ff, DAT1=ff
[  104.157442] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[  104.172238] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=59, DAT0=ff, DAT1=ff
[  104.174218] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[  104.176252] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[  104.192446] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5a, DAT0=ff, DAT1=ff
[  104.194381] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[  104.212338] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5b, DAT0=ff, DAT1=ff
[  104.214135] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  104.216161] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[  104.232349] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=5c, DAT0=ff, DAT1=ff
[  104.234282] i2c i2c-0: Transaction (pre): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[  104.252142] i2c i2c-0: Transaction (post): CNT=08, CMD=40, ADD=5d, DAT0=ff, DAT1=ff
[  104.257634] i2c-core: driver [lm92] registered
[  104.259522] i2c i2c-0: found normal entry for adapter 0, addr 0x48
[  104.262994] i2c i2c-0: Transaction (pre): CNT=00, CMD=40, ADD=90, DAT0=ff, DAT1=ff
[  104.282235] i2c i2c-0: Transaction (post): CNT=00, CMD=40, ADD=90, DAT0=ff, DAT1=ff
[  104.284298] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=91, DAT0=ff, DAT1=ff
[  104.302269] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=91, DAT0=ff, DAT1=ff
[  104.304225] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.322129] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.324120] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=91, DAT0=ff, DAT1=ff
[  104.342172] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=91, DAT0=ff, DAT1=ff
[  104.344153] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.362279] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.364439] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=91, DAT0=ff, DAT1=ff
[  104.382326] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=91, DAT0=ff, DAT1=ff
[  104.384410] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.402391] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=91, DAT0=ff, DAT1=ff
[  104.404233] i2c i2c-0: found normal entry for adapter 0, addr 0x49
[  104.406083] i2c i2c-0: Transaction (pre): CNT=00, CMD=07, ADD=92, DAT0=ff, DAT1=ff
[  104.422165] i2c i2c-0: Transaction (post): CNT=00, CMD=07, ADD=92, DAT0=ff, DAT1=ff
[  104.423963] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=93, DAT0=ff, DAT1=ff
[  104.442081] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=93, DAT0=ff, DAT1=ff
[  104.443965] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.462374] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.464185] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=93, DAT0=ff, DAT1=ff
[  104.482625] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=93, DAT0=ff, DAT1=ff
[  104.484443] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.502227] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.504037] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=93, DAT0=ff, DAT1=ff
[  104.521773] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=93, DAT0=ff, DAT1=ff
[  104.523074] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.542276] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=93, DAT0=ff, DAT1=ff
[  104.543471] i2c i2c-0: found normal entry for adapter 0, addr 0x4a
[  104.544777] i2c i2c-0: Transaction (pre): CNT=00, CMD=07, ADD=94, DAT0=ff, DAT1=ff
[  104.561674] i2c i2c-0: Transaction (post): CNT=00, CMD=07, ADD=94, DAT0=ff, DAT1=ff
[  104.563050] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=95, DAT0=ff, DAT1=ff
[  104.581631] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=95, DAT0=ff, DAT1=ff
[  104.583008] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.601620] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.602987] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=95, DAT0=ff, DAT1=ff
[  104.622042] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=95, DAT0=ff, DAT1=ff
[  104.623837] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.642130] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.643968] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=95, DAT0=ff, DAT1=ff
[  104.662150] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=95, DAT0=ff, DAT1=ff
[  104.663986] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.681801] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=95, DAT0=ff, DAT1=ff
[  104.683476] i2c i2c-0: found normal entry for adapter 0, addr 0x4b
[  104.685249] i2c i2c-0: Transaction (pre): CNT=00, CMD=07, ADD=96, DAT0=ff, DAT1=ff
[  104.702206] i2c i2c-0: Transaction (post): CNT=00, CMD=07, ADD=96, DAT0=ff, DAT1=ff
[  104.703935] i2c i2c-0: Transaction (pre): CNT=08, CMD=01, ADD=97, DAT0=ff, DAT1=ff
[  104.722089] i2c i2c-0: Transaction (post): CNT=08, CMD=01, ADD=97, DAT0=ff, DAT1=ff
[  104.723923] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.742215] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.744067] i2c i2c-0: Transaction (pre): CNT=0c, CMD=04, ADD=97, DAT0=ff, DAT1=ff
[  104.762155] i2c i2c-0: Transaction (post): CNT=0c, CMD=04, ADD=97, DAT0=ff, DAT1=ff
[  104.764000] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.782306] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.784207] i2c i2c-0: Transaction (pre): CNT=0c, CMD=05, ADD=97, DAT0=ff, DAT1=ff
[  104.802261] i2c i2c-0: Transaction (post): CNT=0c, CMD=05, ADD=97, DAT0=ff, DAT1=ff
[  104.804235] i2c i2c-0: Transaction (pre): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.822134] i2c i2c-0: Transaction (post): CNT=0c, CMD=07, ADD=97, DAT0=ff, DAT1=ff
[  104.839679] i2c-core: driver [lm93] registered
[  104.842810] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  104.844920] i2c i2c-0: Transaction (pre): CNT=00, CMD=07, ADD=58, DAT0=ff, DAT1=ff
[  104.862212] i2c i2c-0: Transaction (post): CNT=00, CMD=07, ADD=58, DAT0=ff, DAT1=ff
[  104.864435] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  104.882169] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  104.884161] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[  104.885543] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[  104.887609] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[  104.901480] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[  104.902701] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  104.922149] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  104.923744] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[  104.924986] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  104.926909] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  104.942043] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  104.943801] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  104.963546] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  104.965252] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[  104.969827] i2c-core: driver [lm95245] registered
[  104.972915] i2c i2c-0: found normal entry for adapter 0, addr 0x18
[  104.974905] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=30, DAT0=ff, DAT1=ff
[  104.992314] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=30, DAT0=ff, DAT1=ff
[  104.994400] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[  105.012728] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[  105.015141] i2c i2c-0: found normal entry for adapter 0, addr 0x19
[  105.017668] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=32, DAT0=ff, DAT1=ff
[  105.032716] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=32, DAT0=ff, DAT1=ff
[  105.035063] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=33, DAT0=ff, DAT1=ff
[  105.052775] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=33, DAT0=ff, DAT1=ff
[  105.054484] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[  105.055776] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=52, DAT0=ff, DAT1=ff
[  105.072298] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=52, DAT0=ff, DAT1=ff
[  105.074255] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=53, DAT0=ff, DAT1=ff
[  105.092036] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=53, DAT0=ff, DAT1=ff
[  105.093795] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  105.095820] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  105.112192] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  105.114149] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  105.132041] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  105.133750] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  105.135648] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  105.152880] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  105.155315] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  105.172236] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  105.177760] i2c-core: driver [ltc4245] registered
[  105.183779] i2c-core: driver [max16065] registered
[  105.188477] i2c-core: driver [max1619] registered
[  105.191735] i2c i2c-0: found normal entry for adapter 0, addr 0x18
[  105.193628] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=30, DAT0=ff, DAT1=ff
[  105.212150] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=30, DAT0=ff, DAT1=ff
[  105.214410] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=31, DAT0=ff, DAT1=ff
[  105.232427] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=31, DAT0=ff, DAT1=ff
[  105.234443] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=31, DAT0=ff, DAT1=ff
[  105.252335] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=31, DAT0=ff, DAT1=ff
[  105.254440] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=31, DAT0=ff, DAT1=ff
[  105.272361] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=31, DAT0=ff, DAT1=ff
[  105.274022] i2c i2c-0: MAX1619 detection failed at 0x18
[  105.275053] i2c i2c-0: found normal entry for adapter 0, addr 0x19
[  105.276815] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=32, DAT0=ff, DAT1=ff
[  105.291706] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=32, DAT0=ff, DAT1=ff
[  105.293304] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=33, DAT0=ff, DAT1=ff
[  105.311696] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=33, DAT0=ff, DAT1=ff
[  105.313232] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=33, DAT0=ff, DAT1=ff
[  105.331670] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=33, DAT0=ff, DAT1=ff
[  105.333267] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=33, DAT0=ff, DAT1=ff
[  105.351575] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=33, DAT0=ff, DAT1=ff
[  105.353007] i2c i2c-0: MAX1619 detection failed at 0x19
[  105.355220] i2c i2c-0: found normal entry for adapter 0, addr 0x1a
[  105.357562] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=34, DAT0=ff, DAT1=ff
[  105.372419] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=34, DAT0=ff, DAT1=ff
[  105.374450] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=35, DAT0=ff, DAT1=ff
[  105.392057] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=35, DAT0=ff, DAT1=ff
[  105.393693] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=35, DAT0=ff, DAT1=ff
[  105.412193] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=35, DAT0=ff, DAT1=ff
[  105.414154] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=35, DAT0=ff, DAT1=ff
[  105.432549] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=35, DAT0=ff, DAT1=ff
[  105.434418] i2c i2c-0: MAX1619 detection failed at 0x1a
[  105.435593] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[  105.437833] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=52, DAT0=ff, DAT1=ff
[  105.452935] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=52, DAT0=ff, DAT1=ff
[  105.455086] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=53, DAT0=ff, DAT1=ff
[  105.473620] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=53, DAT0=ff, DAT1=ff
[  105.475400] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=53, DAT0=ff, DAT1=ff
[  105.492161] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=53, DAT0=ff, DAT1=ff
[  105.494006] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=53, DAT0=ff, DAT1=ff
[  105.511704] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=53, DAT0=ff, DAT1=ff
[  105.513110] i2c i2c-0: MAX1619 detection failed at 0x29
[  105.513891] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[  105.515347] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=54, DAT0=ff, DAT1=ff
[  105.532357] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=54, DAT0=ff, DAT1=ff
[  105.534277] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=55, DAT0=ff, DAT1=ff
[  105.552253] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=55, DAT0=ff, DAT1=ff
[  105.553979] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=55, DAT0=ff, DAT1=ff
[  105.571580] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=55, DAT0=ff, DAT1=ff
[  105.572964] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=55, DAT0=ff, DAT1=ff
[  105.592116] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=55, DAT0=ff, DAT1=ff
[  105.593950] i2c i2c-0: MAX1619 detection failed at 0x2a
[  105.595057] i2c i2c-0: found normal entry for adapter 0, addr 0x2b
[  105.596934] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=56, DAT0=ff, DAT1=ff
[  105.612322] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=56, DAT0=ff, DAT1=ff
[  105.614078] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=57, DAT0=ff, DAT1=ff
[  105.631834] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=57, DAT0=ff, DAT1=ff
[  105.633188] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=57, DAT0=ff, DAT1=ff
[  105.651829] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=57, DAT0=ff, DAT1=ff
[  105.653146] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=57, DAT0=ff, DAT1=ff
[  105.672222] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=57, DAT0=ff, DAT1=ff
[  105.673892] i2c i2c-0: MAX1619 detection failed at 0x2b
[  105.675000] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  105.677058] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=98, DAT0=ff, DAT1=ff
[  105.692346] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=98, DAT0=ff, DAT1=ff
[  105.694157] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=99, DAT0=ff, DAT1=ff
[  105.712248] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=99, DAT0=ff, DAT1=ff
[  105.714019] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=99, DAT0=ff, DAT1=ff
[  105.732264] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=99, DAT0=ff, DAT1=ff
[  105.734108] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=99, DAT0=ff, DAT1=ff
[  105.752099] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=99, DAT0=ff, DAT1=ff
[  105.754682] i2c i2c-0: MAX1619 detection failed at 0x4c
[  105.755904] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  105.757934] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=9a, DAT0=ff, DAT1=ff
[  105.772148] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=9a, DAT0=ff, DAT1=ff
[  105.773985] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=9b, DAT0=ff, DAT1=ff
[  105.792343] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=9b, DAT0=ff, DAT1=ff
[  105.794158] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=9b, DAT0=ff, DAT1=ff
[  105.812357] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=9b, DAT0=ff, DAT1=ff
[  105.814204] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=9b, DAT0=ff, DAT1=ff
[  105.832249] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=9b, DAT0=ff, DAT1=ff
[  105.833871] i2c i2c-0: MAX1619 detection failed at 0x4d
[  105.834964] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[  105.836908] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=9c, DAT0=ff, DAT1=ff
[  105.852004] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=9c, DAT0=ff, DAT1=ff
[  105.853792] i2c i2c-0: Transaction (pre): CNT=08, CMD=03, ADD=9d, DAT0=ff, DAT1=ff
[  105.872222] i2c i2c-0: Transaction (post): CNT=08, CMD=03, ADD=9d, DAT0=ff, DAT1=ff
[  105.874086] i2c i2c-0: Transaction (pre): CNT=08, CMD=04, ADD=9d, DAT0=ff, DAT1=ff
[  105.892026] i2c i2c-0: Transaction (post): CNT=08, CMD=04, ADD=9d, DAT0=ff, DAT1=ff
[  105.893886] i2c i2c-0: Transaction (pre): CNT=08, CMD=02, ADD=9d, DAT0=ff, DAT1=ff
[  105.911925] i2c i2c-0: Transaction (post): CNT=08, CMD=02, ADD=9d, DAT0=ff, DAT1=ff
[  105.913286] i2c i2c-0: MAX1619 detection failed at 0x4e
[  105.917048] i2c-core: driver [max1668] registered
[  105.918539] i2c i2c-0: found normal entry for adapter 0, addr 0x18
[  105.922722] i2c i2c-0: Transaction (pre): CNT=00, CMD=02, ADD=30, DAT0=ff, DAT1=ff
[  105.941687] i2c i2c-0: Transaction (post): CNT=00, CMD=02, ADD=30, DAT0=ff, DAT1=ff
[  105.943286] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[  105.961670] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=31, DAT0=ff, DAT1=ff
[  105.962915] i2c i2c-0: found normal entry for adapter 0, addr 0x19
[  105.964247] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=32, DAT0=ff, DAT1=ff
[  105.982066] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=32, DAT0=ff, DAT1=ff
[  105.983546] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=33, DAT0=ff, DAT1=ff
[  106.001975] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=33, DAT0=ff, DAT1=ff
[  106.003443] i2c i2c-0: found normal entry for adapter 0, addr 0x1a
[  106.005207] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=34, DAT0=ff, DAT1=ff
[  106.022136] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=34, DAT0=ff, DAT1=ff
[  106.024081] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=35, DAT0=ff, DAT1=ff
[  106.041666] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=35, DAT0=ff, DAT1=ff
[  106.043192] i2c i2c-0: found normal entry for adapter 0, addr 0x29
[  106.044527] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=52, DAT0=ff, DAT1=ff
[  106.061636] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=52, DAT0=ff, DAT1=ff
[  106.063245] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=53, DAT0=ff, DAT1=ff
[  106.081901] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=53, DAT0=ff, DAT1=ff
[  106.083164] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[  106.084801] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=54, DAT0=ff, DAT1=ff
[  106.101701] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=54, DAT0=ff, DAT1=ff
[  106.103278] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=55, DAT0=ff, DAT1=ff
[  106.121656] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=55, DAT0=ff, DAT1=ff
[  106.123119] i2c i2c-0: found normal entry for adapter 0, addr 0x2b
[  106.124745] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=56, DAT0=ff, DAT1=ff
[  106.142325] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=56, DAT0=ff, DAT1=ff
[  106.144265] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=57, DAT0=ff, DAT1=ff
[  106.161773] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=57, DAT0=ff, DAT1=ff
[  106.163229] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  106.165132] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  106.181740] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  106.183280] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  106.202392] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  106.204229] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  106.205741] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  106.221674] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  106.223342] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  106.241772] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  106.243263] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[  106.244939] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  106.261621] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  106.263344] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  106.281583] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  106.287884] i2c-core: driver [max6639] registered
[  106.289682] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  106.292354] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=58, DAT0=ff, DAT1=ff
[  106.312117] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=58, DAT0=ff, DAT1=ff
[  106.314072] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[  106.332000] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[  106.333910] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  106.351739] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  106.353276] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  106.354882] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  106.371745] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  106.373284] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[  106.391741] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[  106.393288] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  106.411836] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  106.413424] i2c i2c-0: found normal entry for adapter 0, addr 0x2f
[  106.414983] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5e, DAT0=ff, DAT1=ff
[  106.431664] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5e, DAT0=ff, DAT1=ff
[  106.433182] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5f, DAT0=ff, DAT1=ff
[  106.451972] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5f, DAT0=ff, DAT1=ff
[  106.453265] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5f, DAT0=ff, DAT1=ff
[  106.472325] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5f, DAT0=ff, DAT1=ff
[  106.486538] i2c-core: driver [max6642] registered
[  106.488180] i2c i2c-0: found normal entry for adapter 0, addr 0x48
[  106.489706] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=90, DAT0=ff, DAT1=ff
[  106.511483] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=90, DAT0=ff, DAT1=ff
[  106.513401] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=91, DAT0=ff, DAT1=ff
[  106.533743] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=91, DAT0=ff, DAT1=ff
[  106.535675] i2c i2c-0: found normal entry for adapter 0, addr 0x49
[  106.537797] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=92, DAT0=ff, DAT1=ff
[  106.552285] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=92, DAT0=ff, DAT1=ff
[  106.554242] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=93, DAT0=ff, DAT1=ff
[  106.572106] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=93, DAT0=ff, DAT1=ff
[  106.573814] i2c i2c-0: found normal entry for adapter 0, addr 0x4a
[  106.575747] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=94, DAT0=ff, DAT1=ff
[  106.592148] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=94, DAT0=ff, DAT1=ff
[  106.594082] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=95, DAT0=ff, DAT1=ff
[  106.612136] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=95, DAT0=ff, DAT1=ff
[  106.613945] i2c i2c-0: found normal entry for adapter 0, addr 0x4b
[  106.616044] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=96, DAT0=ff, DAT1=ff
[  106.631462] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=96, DAT0=ff, DAT1=ff
[  106.632685] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=97, DAT0=ff, DAT1=ff
[  106.652274] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=97, DAT0=ff, DAT1=ff
[  106.654083] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  106.656097] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  106.672144] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  106.674066] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  106.692184] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  106.693957] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  106.695996] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  106.712229] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  106.714198] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  106.732125] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  106.733920] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[  106.736024] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  106.752338] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  106.754279] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  106.771490] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  106.772947] i2c i2c-0: found normal entry for adapter 0, addr 0x4f
[  106.774227] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9e, DAT0=ff, DAT1=ff
[  106.792326] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9e, DAT0=ff, DAT1=ff
[  106.794358] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9f, DAT0=ff, DAT1=ff
[  106.812127] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9f, DAT0=ff, DAT1=ff
[  106.822891] i2c-core: driver [mcp3021] registered
[  106.827569] pc87360: PC8736x not detected, module not inserted
[  106.833022] i2c-core: driver [pcf8591] registered
[  106.837517] i2c-core: driver [sht21] registered
[  106.847647] i2c-core: driver [smm665] registered
[  106.865710] i2c-core: driver [amc6821] registered
[  106.867795] i2c i2c-0: found normal entry for adapter 0, addr 0x18
[  106.870001] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=30, DAT0=ff, DAT1=ff
[  106.891430] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=30, DAT0=ff, DAT1=ff
[  106.892676] i2c i2c-0: amc6821_detect called.
[  106.894030] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=31, DAT0=ff, DAT1=ff
[  106.911565] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=31, DAT0=ff, DAT1=ff
[  106.912884] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=31, DAT0=ff, DAT1=ff
[  106.932155] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=31, DAT0=ff, DAT1=ff
[  106.934089] i2c i2c-0: amc6821: detection failed at 0x18.
[  106.935381] i2c i2c-0: found normal entry for adapter 0, addr 0x19
[  106.937526] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=32, DAT0=ff, DAT1=ff
[  106.952120] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=32, DAT0=ff, DAT1=ff
[  106.953899] i2c i2c-0: amc6821_detect called.
[  106.955062] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=33, DAT0=ff, DAT1=ff
[  106.972285] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=33, DAT0=ff, DAT1=ff
[  106.974217] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=33, DAT0=ff, DAT1=ff
[  106.992210] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=33, DAT0=ff, DAT1=ff
[  106.993992] i2c i2c-0: amc6821: detection failed at 0x19.
[  106.995162] i2c i2c-0: found normal entry for adapter 0, addr 0x1a
[  106.997255] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=34, DAT0=ff, DAT1=ff
[  107.012234] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=34, DAT0=ff, DAT1=ff
[  107.014005] i2c i2c-0: amc6821_detect called.
[  107.015183] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=35, DAT0=ff, DAT1=ff
[  107.032080] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=35, DAT0=ff, DAT1=ff
[  107.034013] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=35, DAT0=ff, DAT1=ff
[  107.051819] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=35, DAT0=ff, DAT1=ff
[  107.053541] i2c i2c-0: amc6821: detection failed at 0x1a.
[  107.054709] i2c i2c-0: found normal entry for adapter 0, addr 0x2c
[  107.056729] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[  107.073265] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=58, DAT0=ff, DAT1=ff
[  107.075046] i2c i2c-0: amc6821_detect called.
[  107.076267] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[  107.092456] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=59, DAT0=ff, DAT1=ff
[  107.094551] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  107.112601] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=59, DAT0=ff, DAT1=ff
[  107.114348] i2c i2c-0: amc6821: detection failed at 0x2c.
[  107.115189] i2c i2c-0: found normal entry for adapter 0, addr 0x2d
[  107.117278] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[  107.132199] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5a, DAT0=ff, DAT1=ff
[  107.133355] i2c i2c-0: amc6821_detect called.
[  107.134243] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5b, DAT0=ff, DAT1=ff
[  107.152485] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5b, DAT0=ff, DAT1=ff
[  107.154442] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  107.173225] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5b, DAT0=ff, DAT1=ff
[  107.175025] i2c i2c-0: amc6821: detection failed at 0x2d.
[  107.176892] i2c i2c-0: found normal entry for adapter 0, addr 0x2e
[  107.178873] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  107.203280] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=5c, DAT0=ff, DAT1=ff
[  107.204987] i2c i2c-0: amc6821_detect called.
[  107.206997] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[  107.222531] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=5d, DAT0=ff, DAT1=ff
[  107.224425] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  107.242683] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=5d, DAT0=ff, DAT1=ff
[  107.244483] i2c i2c-0: amc6821: detection failed at 0x2e.
[  107.245711] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  107.247677] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=98, DAT0=ff, DAT1=ff
[  107.262723] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=98, DAT0=ff, DAT1=ff
[  107.264461] i2c i2c-0: amc6821_detect called.
[  107.265668] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=99, DAT0=ff, DAT1=ff
[  107.282659] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=99, DAT0=ff, DAT1=ff
[  107.284643] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=99, DAT0=ff, DAT1=ff
[  107.302586] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=99, DAT0=ff, DAT1=ff
[  107.304325] i2c i2c-0: amc6821: detection failed at 0x4c.
[  107.305461] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  107.307387] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=9a, DAT0=ff, DAT1=ff
[  107.323436] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=9a, DAT0=ff, DAT1=ff
[  107.325145] i2c i2c-0: amc6821_detect called.
[  107.327018] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=9b, DAT0=ff, DAT1=ff
[  107.343239] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=9b, DAT0=ff, DAT1=ff
[  107.345261] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=9b, DAT0=ff, DAT1=ff
[  107.363219] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=9b, DAT0=ff, DAT1=ff
[  107.364997] i2c i2c-0: amc6821: detection failed at 0x4d.
[  107.366994] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[  107.369700] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=9c, DAT0=ff, DAT1=ff
[  107.392974] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=9c, DAT0=ff, DAT1=ff
[  107.394784] i2c i2c-0: amc6821_detect called.
[  107.396574] i2c i2c-0: Transaction (pre): CNT=08, CMD=3d, ADD=9d, DAT0=ff, DAT1=ff
[  107.412987] i2c i2c-0: Transaction (post): CNT=08, CMD=3d, ADD=9d, DAT0=ff, DAT1=ff
[  107.414970] i2c i2c-0: Transaction (pre): CNT=08, CMD=3e, ADD=9d, DAT0=ff, DAT1=ff
[  107.431540] i2c i2c-0: Transaction (post): CNT=08, CMD=3e, ADD=9d, DAT0=ff, DAT1=ff
[  107.432672] i2c i2c-0: amc6821: detection failed at 0x4e.
[  107.435940] i2c-core: driver [tmp102] registered
[  107.438727] i2c-core: driver [tmp401] registered
[  107.440028] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  107.443158] i2c i2c-0: Transaction (pre): CNT=00, CMD=3e, ADD=98, DAT0=ff, DAT1=ff
[  107.462075] i2c i2c-0: Transaction (post): CNT=00, CMD=3e, ADD=98, DAT0=ff, DAT1=ff
[  107.464125] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  107.482156] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  107.486551] i2c-core: driver [tmp421] registered
[  107.487812] i2c i2c-0: found normal entry for adapter 0, addr 0x2a
[  107.489550] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=54, DAT0=ff, DAT1=ff
[  107.511809] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=54, DAT0=ff, DAT1=ff
[  107.513562] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=55, DAT0=ff, DAT1=ff
[  107.531269] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=55, DAT0=ff, DAT1=ff
[  107.532398] i2c i2c-0: found normal entry for adapter 0, addr 0x4c
[  107.534350] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  107.551218] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=98, DAT0=ff, DAT1=ff
[  107.552356] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  107.571218] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=99, DAT0=ff, DAT1=ff
[  107.572280] i2c i2c-0: found normal entry for adapter 0, addr 0x4d
[  107.574169] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  107.591217] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9a, DAT0=ff, DAT1=ff
[  107.592353] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  107.611208] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9b, DAT0=ff, DAT1=ff
[  107.612260] i2c i2c-0: found normal entry for adapter 0, addr 0x4e
[  107.614212] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  107.631217] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9c, DAT0=ff, DAT1=ff
[  107.632360] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  107.651611] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9d, DAT0=ff, DAT1=ff
[  107.652917] i2c i2c-0: found normal entry for adapter 0, addr 0x4f
[  107.654935] i2c i2c-0: Transaction (pre): CNT=00, CMD=fe, ADD=9e, DAT0=ff, DAT1=ff
[  107.671257] i2c i2c-0: Transaction (post): CNT=00, CMD=fe, ADD=9e, DAT0=ff, DAT1=ff
[  107.672418] i2c i2c-0: Transaction (pre): CNT=08, CMD=fe, ADD=9f, DAT0=ff, DAT1=ff
[  107.691230] i2c i2c-0: Transaction (post): CNT=08, CMD=fe, ADD=9f, DAT0=ff, DAT1=ff
[  107.699195] i2c-core: driver [pmbus] registered
[  107.703587] i2c-core: driver [adm1275] registered
[  107.716586] i2c-core: driver [max8688] registered
[  107.722449] i2c-core: driver [ucd9200] registered
[  107.725957] i2c-core: driver [zl6100] registered
[  107.727748] md: linear personality registered for level -1
[  107.728779] md: raid0 personality registered for level 0
[  107.730181] md: raid1 personality registered for level 1
[  107.731934] md: multipath personality registered for level -4
[  107.734090] cpuidle: using governor ladder
[  107.735205] cpuidle: using governor menu
[  107.755663] i2c-core: driver [BD2802] registered
[  107.758621] i2c-core: driver [leds-lm3642] registered
[  107.762340] i2c-core: driver [lp3944] registered
[  107.765140] i2c-core: driver [leds-tca6507] registered
[  107.769463] leds_ss4200: no LED devices found
[  107.814650] iscsi: registered transport (iser)
[  107.846369] EFI Variables Facility v0.08 2004-May-17
[  107.868251] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[  107.891621] i2c-core: driver [i2c_hid] registered
[  107.899255] oprofile: using timer interrupt.
[  107.904779] NET: Registered protocol family 26
[  107.908020] Netfilter messages via NETLINK v0.30.
[  107.914037] gre: GRE over IPv4 demultiplexor driver
[  107.914783] ip_gre: GRE over IPv4 tunneling driver
[  107.954135] TCP: cubic registered
[  107.956631] NET: Registered protocol family 10
[  107.991193] ip6_tables: (C) 2000-2006 Netfilter Core Team
[  108.002677] sit: IPv6 over IPv4 tunneling driver
[  108.047327] Ebtables v2.0 registered
[  108.049372] NET: Registered protocol family 4
[  108.052638] NET: Registered protocol family 5
[  108.102297] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet Project Team
[  108.105501] ------------[ cut here ]------------
[  108.106286] WARNING: at /c/kernel-tests/src/i386/net/core/neighbour.c:1545 neigh_table_init+0x16f/0x490()
[  108.107506] Hardware name: Bochs
[  108.108577] Pid: 1, comm: swapper Not tainted 3.8.0-rc5-01118-geee5035 #17
[  108.109506] Call Trace:
[  108.111179]  [<c1054e52>] warn_slowpath_common+0xf2/0x140
[  108.112064]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
[  108.112880]  [<c1acc2af>] ? neigh_table_init+0x16f/0x490
[  108.114164]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
[  108.115409]  [<c1054ff9>] warn_slowpath_null+0x39/0x50
[  108.116776]  [<c1acc2af>] neigh_table_init+0x16f/0x490
[  108.118169]  [<c1d0ba16>] ? mutex_unlock+0x16/0x30
[  108.119260]  [<c1a9cbf5>] ? proto_register+0x65/0x350
[  108.120016]  [<c24d8c67>] ? atm_clip_init+0x98/0x98
[  108.121591]  [<c24d91c6>] dn_neigh_init+0x1b/0x2b
[  108.122305]  [<c24d8cce>] decnet_init+0x67/0xfc
[  108.123169]  [<c2472470>] do_one_initcall+0xf2/0x259
[  108.124259]  [<c24727fa>] kernel_init_freeable+0x223/0x393
[  108.125053]  [<c2471548>] ? loglevel+0x55/0x55
[  108.125712]  [<c1ce8b59>] kernel_init+0x19/0x200
[  108.126411]  [<c1d114fb>] ret_from_kernel_thread+0x1b/0x30
[  108.127194]  [<c1ce8b40>] ? rest_init+0x1f0/0x1f0
[  108.128351] ---[ end trace 1bcbb5f262552fec ]---
[  108.131944] DECnet: Routing cache hash table of 256 buckets, 11Kbytes
[  108.133917] NET: Registered protocol family 12
[  108.142467] 9pnet: Installing 9P2000 support
[  108.148343] NET: Registered protocol family 37
[  108.152285] openvswitch: Open vSwitch switching datapath
[  108.241621] registered taskstats version 1
[  108.298550]   Magic number: 1:804:124
[  108.303845] i2c-core: driver [wl1273-fm] registered
[  108.324870] rtc_cmos 00:00: setting system clock to 2013-02-08 11:09:53 UTC (1360321793)
[  108.326236] BIOS EDD facility v0.16 2004-Jun-25, 6 devices found
[  108.474734] Freeing unused kernel memory: 776k freed
[  110.262821] hostname (90) used greatest stack depth: 7020 bytes left
[  111.838095] sh (92) used greatest stack depth: 6952 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
[  112.892858] sh (95) used greatest stack depth: 6940 bytes left

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="eee5035-bisect.log"

git checkout b285109dde7b873b5dc671ef1b3ae3090f4bc72f
Previous HEAD position was eee5035... ixgbe: refactor initialization of feature flags
HEAD is now at b285109... Merge branch 'tg3'

2013-02-09-10:22:28 b285109dde7b873b5dc671ef1b3ae3090f4bc72f compiling
/home/wfg/tip

2013-02-09-10:23:45 detecting boot state 3.8.0-rc5-bisect2-01107-gb285109 #23  TEST FAILURE
bisect: bad commit b285109dde7b873b5dc671ef1b3ae3090f4bc72f
git checkout v3.7
Previous HEAD position was b285109... Merge branch 'tg3'
HEAD is now at 2959440... Linux 3.7

2013-02-09-10:24:23 29594404d7fe73cd80eaa4ee8c43dcc53970c60e compiling
/home/wfg/tip

2013-02-09-10:26:54 detecting boot state 3.7.0-bisect2 #24  TEST FAILURE
bisect: bad commit v3.7
git checkout v3.6
Previous HEAD position was 2959440... Linux 3.7
HEAD is now at a0d271c... Linux 3.6

2013-02-09-10:27:34 a0d271cbfed1dd50278c6b06bead3d00ba0a88f9 compiling
/home/wfg/tip

2013-02-09-10:30:00 detecting boot state 3.6.0-bisect2 #25 ........................	10.............................	18 SUCCESS
bisect: good commit v3.6
git bisect start v3.7 v3.6 --
Previous HEAD position was a0d271c... Linux 3.6
HEAD is now at 3c0eee3f... Linux 2.6.37
Bisecting: 6499 revisions left to test after this (roughly 13 steps)
[d66e6737d454553e1e62109d8298ede5351178a4] Merge git://git.kernel.org/pub/scm/linux/kernel/git/herbert/crypto-2.6
git bisect run /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-10:58:25 d66e6737d454553e1e62109d8298ede5351178a4 compiling
/home/wfg/tip

2013-02-09-11:00:53 detecting boot state 3.6.0-bisect2-02605-gd66e673 #26 .......................	10.............................	17 SUCCESS
Bisecting: 3249 revisions left to test after this (roughly 12 steps)
[e1b28147f684af67bfac989756c27c19859d3d4e] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/s390/linux
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-11:28:28 e1b28147f684af67bfac989756c27c19859d3d4e compiling
/home/wfg/tip

2013-02-09-11:30:57 detecting boot state 3.6.0-bisect2-00026-ge1b2814 #27 ........................	10.............................	19 SUCCESS
Bisecting: 1614 revisions left to test after this (roughly 11 steps)
[37820108f395032e850e400139d956561a043c26] Merge tag 'fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-11:59:01 37820108f395032e850e400139d956561a043c26 compiling
/home/wfg/tip

2013-02-09-12:01:27 detecting boot state 3.7.0-rc1-bisect2-00151-g3782010 #28 .......................	2	10............................. SUCCESS
Bisecting: 807 revisions left to test after this (roughly 10 steps)
[60541d778e536455970281de25b2476e01c03aef] unicore32: switch to generic sys_execve()
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-12:29:01 60541d778e536455970281de25b2476e01c03aef compiling
/home/wfg/tip

2013-02-09-12:31:28 detecting boot state 3.7.0-rc4-bisect2-00008-g60541d7 #29 ........................	7	10............................. SUCCESS
Bisecting: 415 revisions left to test after this (roughly 9 steps)
[403f43c937d24832b18524f65415c0bbba6b5064] team: bcast: convert return value of team_dev_queue_xmit() to bool correctly
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-12:59:31 403f43c937d24832b18524f65415c0bbba6b5064 compiling
/home/wfg/tip

2013-02-09-13:01:51 detecting boot state 3.7.0-rc6-bisect2-00028-g403f43c #30 ........................	4	10............................. SUCCESS
Bisecting: 196 revisions left to test after this (roughly 8 steps)
[e23739b4ade80a3a7f87198f008f6c44a7cbc9fd] Merge branch 'v4l_for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-13:29:54 e23739b4ade80a3a7f87198f008f6c44a7cbc9fd compiling
/home/wfg/tip

2013-02-09-13:32:14 detecting boot state 3.7.0-rc7-bisect2-00051-ge23739b #31 .........................	10............................. SUCCESS
Bisecting: 96 revisions left to test after this (roughly 7 steps)
[455e987c0c2eb2c9045dc854559474cf41509965] Merge branch 'perf-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-14:00:17 455e987c0c2eb2c9045dc854559474cf41509965 compiling
/home/wfg/tip

2013-02-09-14:02:42 detecting boot state 3.7.0-rc7-bisect2-00151-g455e987 #32  TEST FAILURE
Bisecting: 50 revisions left to test after this (roughly 6 steps)
[50a53bbe1280839755cb120eef729ad150f644f9] Merge branch 'akpm' (Fixes from Andrew)
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-14:03:13 50a53bbe1280839755cb120eef729ad150f644f9 compiling
/home/wfg/tip

2013-02-09-14:04:31 detecting boot state 3.7.0-rc7-bisect2-00100-g50a53bb #33 .....................	10.............................	18 SUCCESS
Bisecting: 24 revisions left to test after this (roughly 5 steps)
[31e06a42a34395111842707a85774151245447b7] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/signal
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-14:31:04 31e06a42a34395111842707a85774151245447b7 compiling
/home/wfg/tip

2013-02-09-14:32:24 detecting boot state 3.7.0-rc7-bisect2-00126-g31e06a4 #34 ..........................	10.............................	14 SUCCESS
Bisecting: 12 revisions left to test after this (roughly 4 steps)
[97a13bf3fed11a7508d58b67515c4b83cce25540] Merge tag 'perf-uapi-20121119' of git://git.infradead.org/users/dhowells/linux-headers into perf/urgent
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-15:01:27 97a13bf3fed11a7508d58b67515c4b83cce25540 compiling
/home/wfg/tip

2013-02-09-15:03:47 detecting boot state 3.7.0-rc3-bisect2-00002-g97a13bf #35 ........................	8	10............................. SUCCESS
Bisecting: 7 revisions left to test after this (roughly 3 steps)
[8fdd78eeb11aeda018b22424f863344ef83a92d3] Merge tag 'for-linus' of git://linux-c6x.org/git/projects/linux-c6x-upstreaming
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-15:31:50 8fdd78eeb11aeda018b22424f863344ef83a92d3 compiling
/home/wfg/tip

2013-02-09-15:34:23 detecting boot state 3.7.0-rc7-bisect2-00131-g8fdd78e #36 ........................	10.............................	17 SUCCESS
Bisecting: 3 revisions left to test after this (roughly 2 steps)
[7c17e486e865d616f0e37c7f7f0e4dcfab704cd8] Merge branch 'x86/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-16:02:26 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8 compiling
/home/wfg/tip

2013-02-09-16:03:40 detecting boot state 3.7.0-rc7-bisect2-00135-g7c17e48 #37 ..........................	8	10............................. SUCCESS
Bisecting: 1 revision left to test after this (roughly 1 step)
[7321090f6751c9987c26a8c81c63680d16a614d7] perf kvm: Fix building perf kvm on non x86 arches
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-16:32:43 7321090f6751c9987c26a8c81c63680d16a614d7 compiling
/home/wfg/tip

2013-02-09-16:35:11 detecting boot state 3.7.0-rc3-bisect2-00004-g7321090 #38 ........................	8	10............................. SUCCESS
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d] Merge tag 'perf-urgent-for-mingo' of git://git.kernel.org/pub/scm/linux/kernel/git/acme/linux into perf/urgent
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-i386

2013-02-09-17:03:14 fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d compiling
/home/wfg/tip

2013-02-09-17:04:35 detecting boot state 3.7.0-rc3-bisect2-00005-gfd6da69 #39 ..........................	7	10............................. SUCCESS
455e987c0c2eb2c9045dc854559474cf41509965 is the first bad commit
bisect run success

2013-02-09-17:33:43 7c17e486e865d616f0e37c7f7f0e4dcfab704cd8 compiling
/home/wfg/tip

2013-02-09-17:36:12 detecting boot state 3.7.0-rc7-bisect2-00135-g7c17e48 #40 ........................	10..............................	20.............................	30.............................	38 SUCCESS

2013-02-09-18:34:49 fd6da696f38b00ffeae1185d6f0ec5d4ab3b472d compiling
/home/wfg/tip

2013-02-09-18:37:09 detecting boot state 3.7.0-rc3-bisect2-00005-gfd6da69 #41 ........................	10..............................	20.............................	30.............................	38 SUCCESS

========= linux-next =========

2013-02-09-19:35:51 e347c988b34344c5192c2c238ad1c4bae51e975b compiling
/home/wfg/tip

2013-02-09-19:38:17 detecting boot state 3.8.0-rc6-bisect2-next-20130208 #42 ........................	10. TEST FAILURE
ERROR# 1: /c/kernel-tests/bisect:59: main: $BISECT_TEST $KBUILD_OUTPUT

--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.8.0-rc5 Kernel Configuration
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf32-i386"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/i386_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
CONFIG_ARCH_HAS_DEFAULT_IDLE=y
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_ARCH_HAS_CPU_AUTOPROBE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
CONFIG_FHANDLE=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_IRQ_DOMAIN=y
CONFIG_IRQ_DOMAIN_DEBUG=y
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_KTIME_SCALAR=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
# CONFIG_TASK_IO_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
# CONFIG_CHECKPOINT_RESTORE is not set
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_EXPERT=y
CONFIG_HAVE_UID16=y
# CONFIG_UID16 is not set
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
# CONFIG_SHMEM is not set
CONFIG_AIO=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
CONFIG_PCI_QUIRKS=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_HAVE_DMA_CONTIGUOUS=y
CONFIG_GENERIC_SMP_IDLE_THREAD=y
CONFIG_HAVE_REGS_AND_STACK_ACCESS_API=y
CONFIG_HAVE_DMA_API_DEBUG=y
CONFIG_HAVE_HW_BREAKPOINT=y
CONFIG_HAVE_MIXED_BREAKPOINTS_REGS=y
CONFIG_HAVE_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_PERF_EVENTS_NMI=y
CONFIG_HAVE_PERF_REGS=y
CONFIG_HAVE_PERF_USER_STACK_DUMP=y
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_IPC_PARSE_VERSION=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_GENERIC_SIGALTSTACK=y
CONFIG_CLONE_BACKWARDS=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
CONFIG_GCOV_PROFILE_ALL=y
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
# CONFIG_LBDAF is not set
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_X86_32_IRIS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_PARAVIRT_GUEST=y
CONFIG_PARAVIRT_TIME_ACCOUNTING=y
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_LGUEST_GUEST is not set
CONFIG_PARAVIRT=y
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP3D is not set
CONFIG_MELAN=y
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_X86_GENERIC=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_ALIGNMENT_16=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_NR_CPUS=1
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
# CONFIG_X86_UP_APIC is not set
CONFIG_X86_MCE=y
CONFIG_X86_ANCIENT_MCE=y
# CONFIG_X86_MCE_INJECT is not set
# CONFIG_VM86 is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
# CONFIG_MICROCODE_INTEL is not set
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
# CONFIG_HIGHPTE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK=y
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
# CONFIG_X86_SMAP is not set
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_HZ_100=y
# CONFIG_HZ_250 is not set
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=100
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
# CONFIG_PM_WAKELOCKS_GC is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
# CONFIG_PM_ADVANCED_DEBUG is not set
# CONFIG_PM_TEST_SUSPEND is not set
CONFIG_PM_SLEEP_DEBUG=y
CONFIG_PM_TRACE=y
CONFIG_PM_TRACE_RTC=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
CONFIG_ACPI_EC_DEBUGFS=y
# CONFIG_ACPI_AC is not set
CONFIG_ACPI_BATTERY=y
# CONFIG_ACPI_BUTTON is not set
CONFIG_ACPI_VIDEO=y
# CONFIG_ACPI_FAN is not set
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_THERMAL is not set
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
CONFIG_ACPI_DEBUG_FUNC_TRACE=y
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
CONFIG_ACPI_BGRT=y
# CONFIG_ACPI_APEI is not set
# CONFIG_SFI is not set
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
CONFIG_APM_ALLOW_INTS=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
# CONFIG_HOTPLUG_PCI_PCIE is not set
CONFIG_PCIEAER=y
CONFIG_PCIE_ECRC=y
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_PERFORMANCE=y
CONFIG_PCIE_PME=y
CONFIG_PCI_DEBUG=y
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
# CONFIG_PCI_ATS is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
CONFIG_SCx200=y
# CONFIG_SCx200HR_TIMER is not set
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
# CONFIG_NET5501 is not set
# CONFIG_GEOS is not set
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
# CONFIG_YENTA_TI is not set
# CONFIG_YENTA_TOSHIBA is not set
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_COMPAQ is not set
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
# CONFIG_RAPIDIO_DMA_ENGINE is not set
# CONFIG_RAPIDIO_DEBUG is not set
CONFIG_RAPIDIO_TSI57X=y
# CONFIG_RAPIDIO_CPS_XX is not set
# CONFIG_RAPIDIO_TSI568 is not set
# CONFIG_RAPIDIO_CPS_GEN2 is not set
# CONFIG_RAPIDIO_TSI500 is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
# CONFIG_BINFMT_MISC is not set
# CONFIG_COREDUMP is not set
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_USER is not set
CONFIG_XFRM_IPCOMP=y
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IPGRE=y
CONFIG_ARPD=y
CONFIG_SYN_COOKIES=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_IPV6=y
# CONFIG_IPV6_PRIVACY is not set
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_INET6_AH is not set
CONFIG_INET6_ESP=y
# CONFIG_INET6_IPCOMP is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET6_XFRM_MODE_TUNNEL is not set
# CONFIG_INET6_XFRM_MODE_BEET is not set
CONFIG_IPV6_SIT=y
CONFIG_IPV6_NDISC_NODETYPE=y
# CONFIG_IPV6_TUNNEL is not set
# CONFIG_IPV6_GRE is not set
# CONFIG_NETWORK_SECMARK is not set
CONFIG_NETFILTER=y
CONFIG_NETFILTER_DEBUG=y
# CONFIG_NETFILTER_ADVANCED is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_LOG=y
# CONFIG_NF_CONNTRACK is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
# CONFIG_NETFILTER_XT_MATCH_POLICY is not set
# CONFIG_IP_SET is not set
# CONFIG_IP_VS is not set

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
# CONFIG_IP_NF_IPTABLES is not set

#
# IPv6: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV6 is not set
CONFIG_IP6_NF_IPTABLES=y
# CONFIG_IP6_NF_MATCH_IPV6HEADER is not set
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_BRIDGE_NF_EBTABLES=y
# CONFIG_BRIDGE_EBT_BROUTE is not set
# CONFIG_BRIDGE_EBT_T_FILTER is not set
# CONFIG_BRIDGE_EBT_T_NAT is not set
# CONFIG_BRIDGE_EBT_802_3 is not set
# CONFIG_BRIDGE_EBT_AMONG is not set
# CONFIG_BRIDGE_EBT_ARP is not set
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
# CONFIG_BRIDGE_EBT_PKTTYPE is not set
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
# CONFIG_BRIDGE_EBT_DNAT is not set
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
# CONFIG_BRIDGE_EBT_ULOG is not set
# CONFIG_BRIDGE_EBT_NFLOG is not set
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
# CONFIG_ATM_LANE is not set
# CONFIG_ATM_BR2684 is not set
# CONFIG_L2TP is not set
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
# CONFIG_IPDDP is not set
CONFIG_PHONET=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
# CONFIG_NET_SCH_HFSC is not set
# CONFIG_NET_SCH_ATM is not set
CONFIG_NET_SCH_PRIO=y
# CONFIG_NET_SCH_MULTIQ is not set
CONFIG_NET_SCH_RED=y
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
# CONFIG_NET_CLS_TCINDEX is not set
# CONFIG_NET_CLS_ROUTE4 is not set
CONFIG_NET_CLS_FW=y
# CONFIG_NET_CLS_U32 is not set
# CONFIG_NET_CLS_RSVP is not set
CONFIG_NET_CLS_RSVP6=y
# CONFIG_NET_CLS_FLOW is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
CONFIG_OPENVSWITCH=y
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
# CONFIG_IRDA_FAST_RR is not set
# CONFIG_IRDA_DEBUG is not set

#
# Infrared-port device drivers
#

#
# SIR device drivers
#
# CONFIG_IRTTY_SIR is not set

#
# Dongle support
#

#
# FIR device drivers
#
# CONFIG_NSC_FIR is not set
CONFIG_WINBOND_FIR=y
CONFIG_TOSHIBA_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_VIA_FIR=y
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
# CONFIG_CAIF_DEBUG is not set
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
# CONFIG_NFC is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
# CONFIG_CMA is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
# CONFIG_MTD_REDBOOT_PARTS is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=y
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
CONFIG_MTD_BLOCK_RO=y
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_MTD_OOPS is not set

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
# CONFIG_MTD_CFI_ADV_OPTIONS is not set
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
# CONFIG_MTD_MAP_BANK_WIDTH_8 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_16 is not set
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
CONFIG_MTD_CFI_I1=y
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
# CONFIG_MTD_CFI_I8 is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
# CONFIG_MTD_ROM is not set
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_SC520CDP=y
# CONFIG_MTD_NETSC520 is not set
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_SCx200_DOCFLASH=y
# CONFIG_MTD_AMD76XROM is not set
CONFIG_MTD_ICHXROM=y
CONFIG_MTD_ESB2ROM=y
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=y
# CONFIG_MTD_PCMCIA is not set
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
# CONFIG_MTD_PHRAM is not set
# CONFIG_MTD_MTDRAM is not set
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
# CONFIG_MTD_DOCG3 is not set
# CONFIG_MTD_NAND is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=y

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_PARPORT=y
# CONFIG_PARPORT_PC is not set
# CONFIG_PARPORT_GSC is not set
CONFIG_PARPORT_AX88796=y
CONFIG_PARPORT_1284=y
CONFIG_PARPORT_NOT_PC=y
CONFIG_PNP=y
# CONFIG_PNP_DEBUG_MESSAGES is not set

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_NVME=y
# CONFIG_BLK_DEV_SX8 is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_XIP=y
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
CONFIG_ATA_OVER_ETH=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
# CONFIG_AD525X_DPOT_I2C is not set
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
CONFIG_INTEL_MID_PTI=y
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_CS5535_MFGPT is not set
# CONFIG_HP_ILO is not set
# CONFIG_APDS9802ALS is not set
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
# CONFIG_DS1682 is not set
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_TIMINGS=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_IDE_GD is not set
CONFIG_BLK_DEV_IDECS=y
CONFIG_BLK_DEV_DELKIN=y
CONFIG_BLK_DEV_IDECD=y
# CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS is not set
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEACPI is not set
CONFIG_IDE_TASK_IOCTL=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
CONFIG_BLK_DEV_PLATFORM=y
CONFIG_BLK_DEV_CMD640=y
CONFIG_BLK_DEV_CMD640_ENHANCED=y
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_IDEPCI_PCIBUS_ORDER is not set
# CONFIG_BLK_DEV_OFFBOARD is not set
CONFIG_BLK_DEV_GENERIC=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
CONFIG_BLK_DEV_AEC62XX=y
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
CONFIG_BLK_DEV_CMD64X=y
# CONFIG_BLK_DEV_TRIFLEX is not set
CONFIG_BLK_DEV_CS5530=y
CONFIG_BLK_DEV_CS5535=y
CONFIG_BLK_DEV_CS5536=y
# CONFIG_BLK_DEV_HPT366 is not set
CONFIG_BLK_DEV_JMICRON=y
CONFIG_BLK_DEV_SC1200=y
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
CONFIG_BLK_DEV_PDC202XX_NEW=y
# CONFIG_BLK_DEV_SVWKS is not set
CONFIG_BLK_DEV_SIIMAGE=y
CONFIG_BLK_DEV_SIS5513=y
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
CONFIG_BLK_DEV_VIA82CXXX=y
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_NETLINK=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
# CONFIG_BLK_DEV_SR is not set
# CONFIG_CHR_DEV_SG is not set
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_ATA is not set
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_SCSI_DH is not set
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
CONFIG_SCSI_OSD_DEBUG=y
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
# CONFIG_ATA_ACPI is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
# CONFIG_SATA_SIL24 is not set
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
# CONFIG_MD_RAID10 is not set
# CONFIG_MD_RAID456 is not set
CONFIG_MD_MULTIPATH=y
# CONFIG_MD_FAULTY is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
# CONFIG_FUSION_FC is not set
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
# CONFIG_I2O_SCSI is not set
# CONFIG_I2O_PROC is not set
# CONFIG_MACINTOSH_DRIVERS is not set
# CONFIG_NETDEVICES is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
CONFIG_INPUT_MATRIXKMAP=y

#
# Userland interfaces
#
# CONFIG_INPUT_MOUSEDEV is not set
# CONFIG_INPUT_JOYDEV is not set
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
# CONFIG_KEYBOARD_ADP5588 is not set
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
# CONFIG_KEYBOARD_QT2160 is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_STMPE is not set
# CONFIG_KEYBOARD_TC3589X is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
# CONFIG_MOUSE_PS2_LIFEBOOK is not set
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
# CONFIG_JOYSTICK_ANALOG is not set
# CONFIG_JOYSTICK_A3D is not set
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
# CONFIG_JOYSTICK_GRIP is not set
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
# CONFIG_JOYSTICK_INTERACT is not set
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
# CONFIG_JOYSTICK_IFORCE_232 is not set
# CONFIG_JOYSTICK_WARRIOR is not set
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
# CONFIG_JOYSTICK_SPACEBALL is not set
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
# CONFIG_JOYSTICK_ZHENHUA is not set
# CONFIG_JOYSTICK_DB9 is not set
CONFIG_JOYSTICK_GAMECON=y
# CONFIG_JOYSTICK_TURBOGRAFX is not set
# CONFIG_JOYSTICK_AS5011 is not set
# CONFIG_JOYSTICK_JOYDUMP is not set
# CONFIG_JOYSTICK_XPAD is not set
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
# CONFIG_TABLET_USB_ACECAD is not set
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_HANWANG is not set
# CONFIG_TABLET_USB_KBTAB is not set
# CONFIG_TABLET_USB_WACOM is not set
CONFIG_INPUT_TOUCHSCREEN=y
# CONFIG_TOUCHSCREEN_88PM860X is not set
# CONFIG_TOUCHSCREEN_AD7879 is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
# CONFIG_TOUCHSCREEN_DA9052 is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
# CONFIG_TOUCHSCREEN_EETI is not set
# CONFIG_TOUCHSCREEN_FUJITSU is not set
CONFIG_TOUCHSCREEN_ILI210X=y
# CONFIG_TOUCHSCREEN_GUNZE is not set
# CONFIG_TOUCHSCREEN_ELO is not set
# CONFIG_TOUCHSCREEN_WACOM_W8001 is not set
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
CONFIG_TOUCHSCREEN_MCS5000=y
CONFIG_TOUCHSCREEN_MMS114=y
# CONFIG_TOUCHSCREEN_MTOUCH is not set
# CONFIG_TOUCHSCREEN_INEXIO is not set
# CONFIG_TOUCHSCREEN_MK712 is not set
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
# CONFIG_TOUCHSCREEN_TOUCHRIGHT is not set
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
# CONFIG_TOUCHSCREEN_USB_COMPOSITE is not set
CONFIG_TOUCHSCREEN_MC13783=y
# CONFIG_TOUCHSCREEN_TOUCHIT213 is not set
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2007 is not set
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_STMPE=y
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
CONFIG_INPUT_88PM860X_ONKEY=y
CONFIG_INPUT_88PM80X_ONKEY=y
CONFIG_INPUT_AD714X=y
# CONFIG_INPUT_AD714X_I2C is not set
CONFIG_INPUT_BMA150=y
# CONFIG_INPUT_PCSPKR is not set
# CONFIG_INPUT_MAX8925_ONKEY is not set
CONFIG_INPUT_MC13783_PWRBUTTON=y
CONFIG_INPUT_MMA8450=y
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=y
CONFIG_INPUT_WISTRON_BTNS=y
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
CONFIG_INPUT_KXTJ9=y
# CONFIG_INPUT_KXTJ9_POLLED_MODE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
# CONFIG_INPUT_CM109 is not set
CONFIG_INPUT_TWL4030_PWRBUTTON=y
CONFIG_INPUT_TWL4030_VIBRA=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
CONFIG_INPUT_PWM_BEEPER=y
# CONFIG_INPUT_DA9052_ONKEY is not set
CONFIG_INPUT_DA9055_ONKEY=y
CONFIG_INPUT_ADXL34X=y
# CONFIG_INPUT_ADXL34X_I2C is not set
# CONFIG_INPUT_CMA3000 is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PARKBD is not set
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
# CONFIG_GAMEPORT_L4 is not set
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
# CONFIG_VT is not set
# CONFIG_UNIX98_PTYS is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
CONFIG_CYZ_INTR=y
CONFIG_MOXA_INTELLIO=y
# CONFIG_MOXA_SMARTIO is not set
# CONFIG_SYNCLINK is not set
# CONFIG_SYNCLINKMP is not set
CONFIG_SYNCLINK_GT=y
# CONFIG_NOZOMI is not set
# CONFIG_ISI is not set
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
CONFIG_TRACE_ROUTER=y
CONFIG_TRACE_SINK=y
CONFIG_DEVKMEM=y
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
CONFIG_SERIAL_ALTERA_JTAGUART=y
# CONFIG_SERIAL_ALTERA_JTAGUART_CONSOLE is not set
CONFIG_SERIAL_ALTERA_UART=y
CONFIG_SERIAL_ALTERA_UART_MAXPORTS=4
CONFIG_SERIAL_ALTERA_UART_BAUDRATE=115200
CONFIG_SERIAL_ALTERA_UART_CONSOLE=y
# CONFIG_SERIAL_PCH_UART is not set
CONFIG_SERIAL_ARC=y
CONFIG_SERIAL_ARC_CONSOLE=y
CONFIG_SERIAL_ARC_NR_PORTS=1
CONFIG_TTY_PRINTK=y
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
# CONFIG_HW_RANDOM_TIMERIOMEM is not set
# CONFIG_HW_RANDOM_INTEL is not set
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
CONFIG_HW_RANDOM_VIA=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
# CONFIG_CARDMAN_4040 is not set
CONFIG_MWAVE=y
CONFIG_SCx200_GPIO=y
CONFIG_PC8736x_GPIO=y
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
# CONFIG_HANGCHECK_TIMER is not set
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
# CONFIG_I2C_MUX is not set
CONFIG_I2C_HELPER_AUTO=y
CONFIG_I2C_SMBUS=y
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
CONFIG_I2C_ALI1535=y
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
CONFIG_I2C_ISCH=y
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y

#
# Other I2C/SMBus bus drivers
#
# CONFIG_SCx200_I2C is not set
# CONFIG_SCx200_ACB is not set
CONFIG_I2C_DEBUG_CORE=y
CONFIG_I2C_DEBUG_ALGO=y
CONFIG_I2C_DEBUG_BUS=y
# CONFIG_SPI is not set
CONFIG_HSI=y
CONFIG_HSI_BOARDINFO=y

#
# HSI clients
#
CONFIG_HSI_CHAR=y

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
CONFIG_PPS_CLIENT_LDISC=y
CONFIG_PPS_CLIENT_PARPORT=y
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
CONFIG_PTP_1588_CLOCK=y

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
CONFIG_PTP_1588_CLOCK_PCH=y
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
# CONFIG_GPIOLIB is not set
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
# CONFIG_W1_MASTER_DS2482 is not set
# CONFIG_W1_MASTER_DS1WM is not set

#
# 1-wire Slaves
#
# CONFIG_W1_SLAVE_THERM is not set
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
CONFIG_POWER_SUPPLY_DEBUG=y
# CONFIG_PDA_POWER is not set
CONFIG_MAX8925_POWER=y
CONFIG_WM8350_POWER=y
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
CONFIG_BATTERY_DA9052=y
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
# CONFIG_CHARGER_PCF50633 is not set
CONFIG_BATTERY_RX51=y
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_BQ2415X=y
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7414 is not set
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_ADT7475 is not set
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_DA9052_ADC is not set
# CONFIG_SENSORS_DA9055 is not set
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
CONFIG_SENSORS_FSCHMD=y
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_HIH6130=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LM63=y
# CONFIG_SENSORS_LM73 is not set
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
# CONFIG_SENSORS_LTC4151 is not set
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
# CONFIG_SENSORS_PC87427 is not set
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
# CONFIG_SENSORS_LTC2978 is not set
# CONFIG_SENSORS_MAX16064 is not set
# CONFIG_SENSORS_MAX34440 is not set
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA2XX is not set
# CONFIG_SENSORS_THMC50 is not set
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_TWL4030_MADC=y
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
# CONFIG_SENSORS_W83627EHF is not set
CONFIG_SENSORS_WM8350=y
CONFIG_SENSORS_APPLESMC=y
CONFIG_SENSORS_MC13783_ADC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE=y
CONFIG_FAIR_SHARE=y
CONFIG_STEP_WISE=y
CONFIG_USER_SPACE=y
# CONFIG_WATCHDOG is not set
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
# CONFIG_SSB is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
# CONFIG_BCMA_HOST_PCI is not set
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_88PM800=y
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
# CONFIG_HTC_PASIC3 is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS6507X is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS80031 is not set
CONFIG_TWL4030_CORE=y
CONFIG_TWL4030_MADC=y
CONFIG_MFD_TWL4030_AUDIO=y
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_STMPE=y

#
# STMPE Interface Drivers
#
CONFIG_STMPE_I2C=y
CONFIG_MFD_TC3589X=y
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_SMSC=y
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_LP8788=y
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
CONFIG_MFD_WM8994=y
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
# CONFIG_PCF50633_GPIO is not set
CONFIG_MFD_MC13783=y
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_ABX500_CORE=y
# CONFIG_AB3100_CORE is not set
CONFIG_MFD_CS5535=y
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
CONFIG_MFD_RDC321X=y
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_MFD_RETU is not set
CONFIG_MFD_AS3711=y
# CONFIG_REGULATOR is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
# CONFIG_VIDEO_ADV_DEBUG is not set
CONFIG_VIDEO_FIXED_MINOR_RANGES=y
CONFIG_VIDEO_TUNER=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_DVB_CORE=y
CONFIG_DVB_NET=y
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y

#
# Media drivers
#
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture/analog TV support
#
# CONFIG_VIDEO_ZORAN is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
# CONFIG_VIDEO_HEXIUM_ORION is not set
# CONFIG_VIDEO_MXB is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_SAA7134=y
# CONFIG_VIDEO_SAA7134_DVB is not set
# CONFIG_VIDEO_SAA7164 is not set

#
# Media digital TV PCI Adapters
#
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_AV7110=y
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=y
# CONFIG_DVB_BUDGET is not set
CONFIG_DVB_BUDGET_AV=y
CONFIG_DVB_BUDGET_PATCH=y
CONFIG_DVB_B2C2_FLEXCOP_PCI=y
CONFIG_DVB_B2C2_FLEXCOP_PCI_DEBUG=y
CONFIG_DVB_PLUTO2=y
# CONFIG_DVB_PT1 is not set
CONFIG_DVB_NGENE=y
CONFIG_DVB_DDBRIDGE=y

#
# Supported MMC/SDIO adapters
#
CONFIG_RADIO_ADAPTERS=y
CONFIG_RADIO_SI470X=y
# CONFIG_I2C_SI470X is not set
CONFIG_I2C_SI4713=y
CONFIG_RADIO_SI4713=y
# CONFIG_RADIO_TEA5764 is not set
CONFIG_RADIO_SAA7706H=y
# CONFIG_RADIO_TEF6862 is not set
# CONFIG_RADIO_WL1273 is not set

#
# Texas Instruments WL128x FM driver (ST based)
#
CONFIG_DVB_B2C2_FLEXCOP=y
CONFIG_DVB_B2C2_FLEXCOP_DEBUG=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y
# CONFIG_MEDIA_SUBDRV_AUTOSELECT is not set

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_VIDEO_TVEEPROM=y

#
# Encoders, decoders, sensors and other helper chips
#

#
# Audio decoders, processors and mixers
#
# CONFIG_VIDEO_TVAUDIO is not set
CONFIG_VIDEO_TDA7432=y
# CONFIG_VIDEO_TDA9840 is not set
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
# CONFIG_VIDEO_MSP3400 is not set
# CONFIG_VIDEO_CS5345 is not set
# CONFIG_VIDEO_CS53L32A is not set
CONFIG_VIDEO_TLV320AIC23B=y
# CONFIG_VIDEO_WM8775 is not set
CONFIG_VIDEO_WM8739=y
# CONFIG_VIDEO_VP27SMPX is not set

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_ADV7180=y
# CONFIG_VIDEO_ADV7183 is not set
CONFIG_VIDEO_BT819=y
# CONFIG_VIDEO_BT856 is not set
CONFIG_VIDEO_BT866=y
CONFIG_VIDEO_KS0127=y
# CONFIG_VIDEO_SAA7110 is not set
CONFIG_VIDEO_SAA711X=y
# CONFIG_VIDEO_SAA7191 is not set
CONFIG_VIDEO_TVP514X=y
# CONFIG_VIDEO_TVP5150 is not set
# CONFIG_VIDEO_TVP7002 is not set
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#
# CONFIG_VIDEO_SAA717X is not set
CONFIG_VIDEO_CX25840=y

#
# MPEG video encoders
#
# CONFIG_VIDEO_CX2341X is not set

#
# Video encoders
#
CONFIG_VIDEO_SAA7127=y
CONFIG_VIDEO_SAA7185=y
# CONFIG_VIDEO_ADV7170 is not set
# CONFIG_VIDEO_ADV7175 is not set
# CONFIG_VIDEO_ADV7343 is not set
CONFIG_VIDEO_ADV7393=y
CONFIG_VIDEO_AK881X=y

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#
CONFIG_VIDEO_UPD64031A=y
# CONFIG_VIDEO_UPD64083 is not set

#
# Miscelaneous helper chips
#
CONFIG_VIDEO_THS7303=y
# CONFIG_VIDEO_M52790 is not set

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y

#
# Customize TV tuners
#
# CONFIG_MEDIA_TUNER_SIMPLE is not set
# CONFIG_MEDIA_TUNER_TDA8290 is not set
CONFIG_MEDIA_TUNER_TDA827X=y
# CONFIG_MEDIA_TUNER_TDA18271 is not set
# CONFIG_MEDIA_TUNER_TDA9887 is not set
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
# CONFIG_MEDIA_TUNER_MT20XX is not set
# CONFIG_MEDIA_TUNER_MT2060 is not set
# CONFIG_MEDIA_TUNER_MT2063 is not set
CONFIG_MEDIA_TUNER_MT2266=y
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_QT1010=y
# CONFIG_MEDIA_TUNER_XC2028 is not set
# CONFIG_MEDIA_TUNER_XC5000 is not set
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MXL5005S=y
# CONFIG_MEDIA_TUNER_MXL5007T is not set
CONFIG_MEDIA_TUNER_MC44S803=y
CONFIG_MEDIA_TUNER_MAX2165=y
# CONFIG_MEDIA_TUNER_TDA18218 is not set
CONFIG_MEDIA_TUNER_FC0011=y
# CONFIG_MEDIA_TUNER_FC0012 is not set
CONFIG_MEDIA_TUNER_FC0013=y
# CONFIG_MEDIA_TUNER_TDA18212 is not set
CONFIG_MEDIA_TUNER_E4000=y
CONFIG_MEDIA_TUNER_FC2580=y
# CONFIG_MEDIA_TUNER_TUA9001 is not set

#
# Customise DVB Frontends
#

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STB6100=y
# CONFIG_DVB_STV090x is not set
# CONFIG_DVB_STV6110x is not set

#
# Multistandard (cable + terrestrial) frontends
#
# CONFIG_DVB_DRXK is not set
# CONFIG_DVB_TDA18271C2DD is not set

#
# DVB-S (satellite) frontends
#
# CONFIG_DVB_CX24110 is not set
CONFIG_DVB_CX24123=y
# CONFIG_DVB_MT312 is not set
# CONFIG_DVB_ZL10036 is not set
CONFIG_DVB_ZL10039=y
# CONFIG_DVB_S5H1420 is not set
CONFIG_DVB_STV0288=y
CONFIG_DVB_STB6000=y
# CONFIG_DVB_STV0299 is not set
# CONFIG_DVB_STV6110 is not set
# CONFIG_DVB_STV0900 is not set
# CONFIG_DVB_TDA8083 is not set
# CONFIG_DVB_TDA10086 is not set
CONFIG_DVB_TDA8261=y
# CONFIG_DVB_VES1X93 is not set
# CONFIG_DVB_TUNER_ITD1000 is not set
# CONFIG_DVB_TUNER_CX24113 is not set
CONFIG_DVB_TDA826X=y
# CONFIG_DVB_TUA6100 is not set
# CONFIG_DVB_CX24116 is not set
CONFIG_DVB_SI21XX=y
# CONFIG_DVB_DS3000 is not set
# CONFIG_DVB_MB86A16 is not set
CONFIG_DVB_TDA10071=y

#
# DVB-T (terrestrial) frontends
#
# CONFIG_DVB_SP8870 is not set
# CONFIG_DVB_SP887X is not set
CONFIG_DVB_CX22700=y
# CONFIG_DVB_CX22702 is not set
# CONFIG_DVB_S5H1432 is not set
# CONFIG_DVB_DRXD is not set
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
# CONFIG_DVB_NXT6000 is not set
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_DIB3000MB=y
# CONFIG_DVB_DIB3000MC is not set
# CONFIG_DVB_DIB7000M is not set
# CONFIG_DVB_DIB7000P is not set
CONFIG_DVB_DIB9000=y
CONFIG_DVB_TDA10048=y
# CONFIG_DVB_AF9013 is not set
CONFIG_DVB_EC100=y
CONFIG_DVB_HD29L2=y
# CONFIG_DVB_STV0367 is not set
CONFIG_DVB_CXD2820R=y
CONFIG_DVB_RTL2830=y
# CONFIG_DVB_RTL2832 is not set

#
# DVB-C (cable) frontends
#
# CONFIG_DVB_VES1820 is not set
CONFIG_DVB_TDA10021=y
# CONFIG_DVB_TDA10023 is not set
# CONFIG_DVB_STV0297 is not set

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_OR51211=y
# CONFIG_DVB_OR51132 is not set
# CONFIG_DVB_BCM3510 is not set
# CONFIG_DVB_LGDT330X is not set
CONFIG_DVB_LGDT3305=y
# CONFIG_DVB_LG2160 is not set
# CONFIG_DVB_S5H1409 is not set
# CONFIG_DVB_AU8522_DTV is not set
# CONFIG_DVB_AU8522_V4L is not set
# CONFIG_DVB_S5H1411 is not set

#
# ISDB-T (terrestrial) frontends
#
# CONFIG_DVB_S921 is not set
# CONFIG_DVB_DIB8000 is not set
CONFIG_DVB_MB86A20S=y

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y
CONFIG_DVB_TUNER_DIB0070=y
# CONFIG_DVB_TUNER_DIB0090 is not set

#
# SEC control devices for DVB-S
#
# CONFIG_DVB_LNBP21 is not set
CONFIG_DVB_LNBP22=y
# CONFIG_DVB_ISL6405 is not set
CONFIG_DVB_ISL6421=y
# CONFIG_DVB_ISL6423 is not set
CONFIG_DVB_A8293=y
# CONFIG_DVB_LGS8GL5 is not set
# CONFIG_DVB_LGS8GXX is not set
CONFIG_DVB_ATBM8830=y
CONFIG_DVB_TDA665x=y
# CONFIG_DVB_IX2505V is not set
CONFIG_DVB_IT913X_FE=y
CONFIG_DVB_M88RS2000=y
CONFIG_DVB_AF9033=y

#
# Tools to develop new frontends
#
CONFIG_DVB_DUMMY_FE=y

#
# Graphics support
#
CONFIG_AGP=y
# CONFIG_AGP_ALI is not set
CONFIG_AGP_ATI=y
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD64 is not set
# CONFIG_AGP_INTEL is not set
CONFIG_AGP_NVIDIA=y
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_SWORKS is not set
CONFIG_AGP_VIA=y
CONFIG_AGP_EFFICEON=y
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
CONFIG_STUB_POULSBO=y
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
CONFIG_FB_DDC=y
CONFIG_FB_BOOT_VESA_SUPPORT=y
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
# CONFIG_FB_WMT_GE_ROPS is not set
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_HECUBA=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
# CONFIG_FB_PM2_FIFO_DISCONNECT is not set
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
# CONFIG_FB_ARC is not set
CONFIG_FB_ASILIANT=y
CONFIG_FB_IMSTT=y
# CONFIG_FB_VGA16 is not set
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
CONFIG_FB_N411=y
# CONFIG_FB_HGA is not set
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
CONFIG_FB_NVIDIA_DEBUG=y
# CONFIG_FB_NVIDIA_BACKLIGHT is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_LE80578 is not set
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
# CONFIG_FB_MATROX_MYSTIQUE is not set
CONFIG_FB_MATROX_G=y
# CONFIG_FB_MATROX_I2C is not set
CONFIG_FB_RADEON=y
# CONFIG_FB_RADEON_I2C is not set
# CONFIG_FB_RADEON_BACKLIGHT is not set
CONFIG_FB_RADEON_DEBUG=y
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
# CONFIG_FB_TMIO is not set
# CONFIG_FB_SM501 is not set
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
# CONFIG_BACKLIGHT_PWM is not set
# CONFIG_BACKLIGHT_DA9052 is not set
# CONFIG_BACKLIGHT_MAX8925 is not set
CONFIG_BACKLIGHT_APPLE=y
CONFIG_BACKLIGHT_SAHARA=y
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_LM3630=y
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set
CONFIG_BACKLIGHT_PANDORA=y
# CONFIG_BACKLIGHT_TPS65217 is not set
# CONFIG_LOGO is not set
# CONFIG_SOUND is not set

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
CONFIG_UHID=y
# CONFIG_HID_GENERIC is not set

#
# Special HID drivers
#

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
# CONFIG_USB is not set
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_HCD_BCMA is not set

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#
# CONFIG_USB_GADGET is not set

#
# OTG and related infrastructure
#
# CONFIG_UWB is not set
# CONFIG_MMC is not set
CONFIG_MEMSTICK=y
# CONFIG_MEMSTICK_DEBUG is not set

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP8788 is not set
CONFIG_LEDS_CLEVO_MAIL=y
# CONFIG_LEDS_PCA955X is not set
# CONFIG_LEDS_PCA9633 is not set
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_MC13783=y
CONFIG_LEDS_TCA6507=y
CONFIG_LEDS_MAX8997=y
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set
# CONFIG_LEDS_TRIGGERS is not set

#
# LED Triggers
#
CONFIG_ACCESSIBILITY=y
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
# CONFIG_INFINIBAND_USER_ACCESS is not set
CONFIG_INFINIBAND_ADDR_TRANS=y
# CONFIG_INFINIBAND_MTHCA is not set
# CONFIG_INFINIBAND_AMSO1100 is not set
# CONFIG_INFINIBAND_NES is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_ISER=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
CONFIG_RTC_DEBUG=y

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_DEV=y
CONFIG_RTC_INTF_DEV_UIE_EMUL=y
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_88PM860X is not set
# CONFIG_RTC_DRV_88PM80X is not set
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_MAX6900 is not set
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8523 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
CONFIG_RTC_DRV_M41T80_WDT=y
# CONFIG_RTC_DRV_BQ32K is not set
# CONFIG_RTC_DRV_TWL4030 is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
# CONFIG_RTC_DRV_DS1511 is not set
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9052=y
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
# CONFIG_RTC_DRV_M48T35 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_MSM6242 is not set
# CONFIG_RTC_DRV_BQ4802 is not set
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_WM8350=y
# CONFIG_RTC_DRV_PCF50633 is not set

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_MC13XXX is not set
# CONFIG_DMADEVICES is not set
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set

#
# Virtio drivers
#

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
# CONFIG_STAGING is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_SUPPORT=y

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
# CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND is not set
# CONFIG_DEVFREQ_GOV_PERFORMANCE is not set
CONFIG_DEVFREQ_GOV_POWERSAVE=y
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_TWL=y
CONFIG_PWM_TWL_LED=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
# CONFIG_DELL_RBU is not set
CONFIG_DCDBAS=y
# CONFIG_DMIID is not set
CONFIG_DMI_SYSFS=y
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
# CONFIG_EXT3_DEFAULTS_TO_ORDERED is not set
# CONFIG_EXT3_FS_XATTR is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
CONFIG_AUTOFS4_FS=y
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
# CONFIG_FSCACHE_DEBUG is not set
CONFIG_CACHEFILES=y
CONFIG_CACHEFILES_DEBUG=y

#
# CD-ROM/DVD Filesystems
#
# CONFIG_ISO9660_FS is not set
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
# CONFIG_NLS_CODEPAGE_936 is not set
CONFIG_NLS_CODEPAGE_950=y
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
# CONFIG_NLS_ISO8859_7 is not set
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=y
# CONFIG_NLS_KOI8_R is not set
CONFIG_NLS_KOI8_U=y
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
CONFIG_NLS_MAC_CROATIAN=y
# CONFIG_NLS_MAC_CYRILLIC is not set
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
CONFIG_READABLE_ASM=y
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_DEBUG_OBJECTS=y
CONFIG_DEBUG_OBJECTS_SELFTEST=y
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_HAVE_DEBUG_KMEMLEAK=y
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
# CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_VIRTUAL is not set
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
# CONFIG_DEBUG_LIST is not set
CONFIG_TEST_LIST_SORT=y
CONFIG_DEBUG_SG=y
# CONFIG_DEBUG_NOTIFIERS is not set
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
# CONFIG_FAULT_INJECTION is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DYNAMIC_DEBUG=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
CONFIG_TEST_KSTRTOX=y
# CONFIG_STRICT_DEVMEM is not set
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
CONFIG_DOUBLEFAULT=y
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
CONFIG_IO_DELAY_UDELAY=y
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=2
CONFIG_DEBUG_BOOT_PARAMS=y
CONFIG_CPA_DEBUG=y
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
# CONFIG_SECURITYFS is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_CRYPTO=y

#
# Crypto core or helper
#
CONFIG_CRYPTO_ALGAPI=y
CONFIG_CRYPTO_ALGAPI2=y
CONFIG_CRYPTO_AEAD=y
CONFIG_CRYPTO_AEAD2=y
CONFIG_CRYPTO_BLKCIPHER=y
CONFIG_CRYPTO_BLKCIPHER2=y
CONFIG_CRYPTO_HASH=y
CONFIG_CRYPTO_HASH2=y
CONFIG_CRYPTO_RNG=y
CONFIG_CRYPTO_RNG2=y
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
CONFIG_CRYPTO_USER=y
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER_X86=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
# CONFIG_CRYPTO_CCM is not set
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
# CONFIG_CRYPTO_CTS is not set
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_HMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
CONFIG_CRYPTO_TGR192=y
# CONFIG_CRYPTO_WP512 is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
CONFIG_CRYPTO_AES_NI_INTEL=y
# CONFIG_CRYPTO_ANUBIS is not set
# CONFIG_CRYPTO_ARC4 is not set
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
# CONFIG_CRYPTO_TWOFISH_586 is not set

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
CONFIG_CRYPTO_ZLIB=y
CONFIG_CRYPTO_LZO=y

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
# CONFIG_CRYPTO_USER_API_HASH is not set
CONFIG_CRYPTO_USER_API_SKCIPHER=y
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_PERCPU_RWSEM=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
CONFIG_CRC7=y
# CONFIG_LIBCRC32C is not set
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
# CONFIG_XZ_DEC_ARM is not set
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_DRM_TTM is not set
# CONFIG_ISDN_DRV_LOOP is not set

--x+6KMIRAuhnl3hBn--
