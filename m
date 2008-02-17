From: Andrey Borzenkov <arvidjaar@mail.ru>
Subject: [2.6.25-rc2] e100: Trying to free already-free IRQ 11 during suspend ...
Date: Sun, 17 Feb 2008 15:36:50 +0300
Message-ID: <200802171536.51695.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2199787.zNLJxBX1q2";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx33.mail.ru ([194.67.23.194]:24021 "EHLO mx33.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755190AbYBQMg5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 07:36:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2199787.zNLJxBX1q2
Content-Type: multipart/mixed;
  boundary="Boundary-01=_jpCuHP3cXYHHfIx"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_jpCuHP3cXYHHfIx
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

... and possibly reboot/poweroff (it flows by too fast to be legible).

[ 8803.850634] ACPI: Preparing to enter system sleep state S3
[ 8803.853141] Suspending console(s)
[ 8805.287505] serial 00:09: disabled
[ 8805.291564] Trying to free already-free IRQ 11
[ 8805.291579] Pid: 6920, comm: pm-suspend Not tainted 2.6.25-rc2-1avb #2
[ 8805.291628]  [<c0152127>] free_irq+0xb7/0x130
[ 8805.291675]  [<c024bd80>] e100_suspend+0xc0/0x100
[ 8805.291724]  [<c01eaa36>] pci_device_suspend+0x26/0x70
[ 8805.291747]  [<c0243674>] suspend_device+0x94/0xd0
[ 8805.291763]  [<c02439a3>] device_suspend+0x153/0x240
[ 8805.291784]  [<c014314f>] suspend_devices_and_enter+0x4f/0xf0
[ 8805.291808]  [<c0143a5f>] ? freeze_processes+0x3f/0x80
[ 8805.291825]  [<c01432fa>] enter_state+0xaa/0x140
[ 8805.291840]  [<c014341f>] state_store+0x8f/0xd0
[ 8805.291852]  [<c0143390>] ? state_store+0x0/0xd0
[ 8805.291866]  [<c01d3404>] kobj_attr_store+0x24/0x30
[ 8805.291901]  [<c01b547b>] sysfs_write_file+0xbb/0x110
[ 8805.291936]  [<c0177d79>] vfs_write+0x99/0x130
[ 8805.291963]  [<c01b53c0>] ? sysfs_write_file+0x0/0x110
[ 8805.291979]  [<c01782fd>] sys_write+0x3d/0x70
[ 8805.291998]  [<c010409a>] sysenter_past_esp+0x5f/0xa5
[ 8805.292038]  =======================
[ 8805.347640] ACPI: PCI interrupt for device 0000:00:06.0 disabled
[ 8805.361128] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[ 8805.376670]  hwsleep-0322 [00] enter_sleep_state     : Entering sleep state [S3]
[ 8805.376670] Back to C!

Interface is unused normally (only for netconsole sometimes). dmesg and config
attached.

Hmm ... after resume device has disappeared at all ...

{pts/1}% cat /proc/interrupts
           CPU0
  0:    1290492    XT-PIC-XT        timer
  1:       6675    XT-PIC-XT        i8042
  2:          0    XT-PIC-XT        cascade
  3:          2    XT-PIC-XT
  4:          2    XT-PIC-XT
  5:          3    XT-PIC-XT
  7:          4    XT-PIC-XT        irda0
  8:          0    XT-PIC-XT        rtc0
  9:        583    XT-PIC-XT        acpi
 10:          2    XT-PIC-XT
 11:      31483    XT-PIC-XT        yenta, yenta, yenta, ohci_hcd:usb1, ALI 5451, pcmcia0.0
 12:      28070    XT-PIC-XT        i8042
 14:      21705    XT-PIC-XT        ide0
 15:      82123    XT-PIC-XT        ide1
NMI:          0   Non-maskable interrupts
TRM:          0   Thermal event interrupts
SPU:          0   Spurious interrupts
ERR:          0

--Boundary-01=_jpCuHP3cXYHHfIx
Content-Type: text/plain;
  charset="us-ascii";
  name="dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="dmesg"

[    0.000000] Linux version 2.6.25-rc2-1avb (bor@cooker) (gcc version 4.2.2 20071128 (prerelease) (4.2.2-2mdv2008.1)) #2 Sun Feb 17 02:43:49 MSK 2008
[    0.000000] BIOS-provided physical RAM map:
[    0.000000]  BIOS-e820: 0000000000000000 - 000000000009fc00 (usable)
[    0.000000]  BIOS-e820: 000000000009fc00 - 00000000000a0000 (reserved)
[    0.000000]  BIOS-e820: 00000000000e0000 - 00000000000eee00 (reserved)
[    0.000000]  BIOS-e820: 00000000000eee00 - 00000000000ef000 (ACPI NVS)
[    0.000000]  BIOS-e820: 00000000000ef000 - 0000000000100000 (reserved)
[    0.000000]  BIOS-e820: 0000000000100000 - 000000001ef60000 (usable)
[    0.000000]  BIOS-e820: 000000001ef60000 - 000000001ef70000 (ACPI data)
[    0.000000]  BIOS-e820: 000000001ef70000 - 0000000020000000 (reserved)
[    0.000000]  BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
[    0.000000] 495MB LOWMEM available.
[    0.000000] Entering add_active_range(0, 0, 126816) 0 entries of 256 used
[    0.000000] Zone PFN ranges:
[    0.000000]   DMA             0 ->     4096
[    0.000000]   Normal       4096 ->   126816
[    0.000000] Movable zone start PFN for each node
[    0.000000] early_node_map[1] active PFN ranges
[    0.000000]     0:        0 ->   126816
[    0.000000] On node 0 totalpages: 126816
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 4064 pages, LIFO batch:0
[    0.000000]   Normal zone: 958 pages used for memmap
[    0.000000]   Normal zone: 121762 pages, LIFO batch:31
[    0.000000]   Movable zone: 0 pages used for memmap
[    0.000000] DMI 2.3 present.
[    0.000000] ACPI: RSDP 000F0090, 0014 (r0 TOSHIB)
[    0.000000] ACPI: RSDT 1EF60000, 0028 (r1 TOSHIB 750        970814 TASM  4010000)
[    0.000000] ACPI: FACP 1EF60054, 0084 (r2 TOSHIB 750        970814 TASM  4010000)
[    0.000000] ACPI: DSDT 1EF600D8, 68DA (r1 TOSHIB 4000     20020417 MSFT  100000A)
[    0.000000] ACPI: FACS 000EEE00, 0040
[    0.000000] ACPI: DMI detected: Toshiba
[    0.000000] ACPI: PM-Timer IO Port: 0xee08
[    0.000000] Allocating PCI resources starting at 30000000 (gap: 20000000:dff80000)
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000e0000
[    0.000000] PM: Registered nosave memory: 00000000000e0000 - 00000000000ee000
[    0.000000] PM: Registered nosave memory: 00000000000ee000 - 00000000000ef000
[    0.000000] PM: Registered nosave memory: 00000000000ef000 - 0000000000100000
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 125826
[    0.000000] Kernel command line: BOOT_IMAGE=2.6.25-rc2-1avb root=LABEL=/ resume=LABEL=swap vga=791
[    0.000000] Enabling fast FPU save and restore... done.
[    0.000000] Enabling unmasked SIMD FPU exception support... done.
[    0.000000] Initializing CPU#0
[    0.000000] PID hash table entries: 2048 (order: 11, 8192 bytes)
[    0.000000] Detected 747.686 MHz processor.
[    0.003333] Console: colour dummy device 80x25
[    0.003333] console [tty0] enabled
[    0.003333] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc., Ingo Molnar
[    0.003333] ... MAX_LOCKDEP_SUBCLASSES:    8
[    0.003333] ... MAX_LOCK_DEPTH:          30
[    0.003333] ... MAX_LOCKDEP_KEYS:        2048
[    0.003333] ... CLASSHASH_SIZE:           1024
[    0.003333] ... MAX_LOCKDEP_ENTRIES:     8192
[    0.003333] ... MAX_LOCKDEP_CHAINS:      16384
[    0.003333] ... CHAINHASH_SIZE:          8192
[    0.003333]  memory used by lock dependency info: 1024 kB
[    0.003333]  per task-struct memory footprint: 1680 bytes
[    0.003333] ------------------------
[    0.003333] | Locking API testsuite:
[    0.003333] ----------------------------------------------------------------------------
[    0.003333]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]                      A-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]                     double unlock:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]                   initialize held:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]               recursive read-lock:             |  ok  |             |  ok  |
[    0.003333]            recursive read-lock #2:             |  ok  |             |  ok  |
[    0.003333]             mixed read-write-lock:             |  ok  |             |  ok  |
[    0.003333]             mixed write-read-lock:             |  ok  |             |  ok  |
[    0.003333]   --------------------------------------------------------------------------
[    0.003333]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.003333]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.003333]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.003333]        sirq-safe-A => hirqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]        sirq-safe-A => hirqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.003333]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.003333]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.003333]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.003333]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.003333]       hard-irq read-recursion/123:  ok  |
[    0.003333]       soft-irq read-recursion/123:  ok  |
[    0.003333]       hard-irq read-recursion/132:  ok  |
[    0.003333]       soft-irq read-recursion/132:  ok  |
[    0.003333]       hard-irq read-recursion/213:  ok  |
[    0.003333]       soft-irq read-recursion/213:  ok  |
[    0.003333]       hard-irq read-recursion/231:  ok  |
[    0.003333]       soft-irq read-recursion/231:  ok  |
[    0.003333]       hard-irq read-recursion/312:  ok  |
[    0.003333]       soft-irq read-recursion/312:  ok  |
[    0.003333]       hard-irq read-recursion/321:  ok  |
[    0.003333]       soft-irq read-recursion/321:  ok  |
[    0.003333] -------------------------------------------------------
[    0.003333] Good, all 218 testcases passed! |
[    0.003333] ---------------------------------
[    0.003333] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.003333] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.003333] Memory: 494188k/507264k available (1865k kernel code, 12460k reserved, 896k data, 208k init, 0k highmem)
[    0.003333] virtual kernel memory layout:
[    0.003333]     fixmap  : 0xffff6000 - 0xfffff000   (  36 kB)
[    0.003333]     vmalloc : 0xdf800000 - 0xffff4000   ( 519 MB)
[    0.003333]     lowmem  : 0xc0000000 - 0xdef60000   ( 495 MB)
[    0.003333]       .init : 0xc03b6000 - 0xc03ea000   ( 208 kB)
[    0.003333]       .data : 0xc02d263b - 0xc03b2a20   ( 896 kB)
[    0.003333]       .text : 0xc0100000 - 0xc02d263b   (1865 kB)
[    0.003333] Checking if this processor honours the WP bit even in supervisor mode...Ok.
[    0.003333] CPA: page pool initialized 16 of 16 pages preallocated
[    0.003333] SLUB: Genslabs=12, HWalign=32, Order=0-1, MinObjects=4, CPUs=1, Nodes=1
[    0.086673] Calibrating delay using timer specific routine.. 1499.07 BogoMIPS (lpj=2497726)
[    0.087000] Mount-cache hash table entries: 512
[    0.089327] CPU: L1 I cache: 16K, L1 D cache: 16K
[    0.089357] CPU: L2 cache: 256K
[    0.089401] Compat vDSO mapped to ffffe000.
[    0.089442] CPU: Intel Pentium III (Coppermine) stepping 0a
[    0.089479] Checking 'hlt' instruction... OK.
[    0.100806] Freeing SMP alternatives: 0k freed
[    0.101921] checking if image is initramfs... it is
[    0.673154] Freeing initrd memory: 2418k freed
[    0.673374] ACPI: Core revision 20070126
[    0.682630] ACPI: Checking initramfs for custom DSDT
[    0.703572] Parsing all Control Methods:
[    0.703913] Table [DSDT](id 0001) - 683 Objects with 60 Devices 195 Methods 10 Regions
[    0.703962]  tbxface-0598 [00] tb_load_namespace     : ACPI Tables successfully acquired
[    0.704002] ACPI: setting ELCR to 0200 (from 0a00)
[    0.704621] evxfevnt-0091 [00] enable                : Transition to ACPI mode successful
[    0.708468] net_namespace: 236 bytes
[    0.711573] NET: Registered protocol family 16
[    0.714218] ACPI: bus type pci registered
[    0.716067] PCI: PCI BIOS revision 2.10 entry at 0xfe5ae, last bus=5
[    0.716119] PCI: Using configuration type 1
[    0.716134] Setting up standard PCI resources
[    0.730878] evgpeblk-0956 [00] ev_create_gpe_block   : GPE 00 to 3F [_GPE] 8 regs on int 0x9
[    0.733847] evgpeblk-1052 [00] ev_initialize_gpe_bloc: Found 3 Wake, Enabled 0 Runtime GPEs in this block
[    0.733905] ACPI: EC: Look up EC in DSDT
[    0.742487] Completing Region/Field/Buffer/Package initialization:.....................................
[    0.745218] Initialized 5/10 Regions 0/0 Fields 16/16 Buffers 16/27 Packages (692 nodes)
[    0.745250] Initializing Device/Processor/Thermal objects by executing _INI methods:.
[    0.747941] Executed 1 _INI methods requiring 0 _STA executions (examined 64 objects)
[    0.748023] ACPI: Interpreter enabled
[    0.748041] ACPI: (supports S0 S3 S4 S5)
[    0.748193] ACPI: Using PIC for interrupt routing
[    0.785720] ACPI: PCI Root Bridge [PCI0] (0000:00)
[    0.787796] pci 0000:00:08.0: quirk: region ee00-ee3f claimed by ali7101 ACPI
[    0.787844] pci 0000:00:08.0: quirk: region ef00-ef1f claimed by ali7101 SMB
[    0.789217] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.789705] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PCI1._PRT]
[    0.820681] ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 10 *11)
[    0.821451] ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 10 *11)
[    0.822149] ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 10 *11)
[    0.822842] ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 10 *11)
[    0.823670] ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 10 *11)
[    0.824371] ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 10 *11)
[    0.825858] ACPI: Power Resource [PFAN] (off)
[    0.826327] Linux Plug and Play Support v0.97 (c) Adam Belay
[    0.826689] pnp: PnP ACPI init
[    0.826878] ACPI: bus type pnp registered
[    0.853020] pnp: PnP ACPI: found 12 devices
[    0.853079] ACPI: ACPI bus type pnp unregistered
[    0.854964] PCI: Using ACPI for IRQ routing
[    0.855005] PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
[    0.866248] Time: tsc clocksource has been installed.
[    0.866796] ACPI: RTC can wake from S4
[    0.867001] system 00:00: iomem range 0x0-0x9ffff could not be reserved
[    0.867030] system 00:00: iomem range 0xe0000-0xeffff could not be reserved
[    0.867057] system 00:00: iomem range 0xf0000-0xfffff could not be reserved
[    0.867084] system 00:00: iomem range 0x100000-0x1ef5ffff could not be reserved
[    0.867113] system 00:00: iomem range 0x1ef60000-0x1ef6ffff could not be reserved
[    0.867143] system 00:00: iomem range 0x1f000000-0x1fffffff could not be reserved
[    0.867172] system 00:00: iomem range 0x1ef70000-0x1effffff could not be reserved
[    0.867202] system 00:00: iomem range 0xffe00000-0xffffffff could not be reserved
[    0.867290] system 00:08: ioport range 0x370-0x371 has been reserved
[    0.867316] system 00:08: ioport range 0x40b-0x40b has been reserved
[    0.867340] system 00:08: ioport range 0x480-0x48f has been reserved
[    0.867364] system 00:08: ioport range 0x4d0-0x4d1 has been reserved
[    0.867387] system 00:08: ioport range 0x4d6-0x4d6 has been reserved
[    0.867411] system 00:08: ioport range 0x6c0-0x6ff has been reserved
[    0.867435] system 00:08: ioport range 0xe000-0xe07f has been reserved
[    0.867459] system 00:08: ioport range 0xe080-0xe0ff has been reserved
[    0.867483] system 00:08: ioport range 0xe400-0xe47f has been reserved
[    0.867508] system 00:08: ioport range 0xe480-0xe4ff has been reserved
[    0.867532] system 00:08: ioport range 0xe800-0xe87f has been reserved
[    0.867556] system 00:08: ioport range 0xe880-0xe8ff has been reserved
[    0.867580] system 00:08: ioport range 0xec00-0xec7f has been reserved
[    0.867604] system 00:08: ioport range 0xec80-0xecff has been reserved
[    0.867630] system 00:08: ioport range 0xee00-0xee41 could not be reserved
[    0.867655] system 00:08: ioport range 0xee90-0xee9f has been reserved
[    0.867679] system 00:08: ioport range 0xeeac-0xeeac has been reserved
[    0.867704] system 00:08: ioport range 0xef00-0xef3f could not be reserved
[    0.867729] system 00:08: ioport range 0xef40-0xef5f has been reserved
[    0.902724] PCI: Bridge: 0000:00:01.0
[    0.902773]   IO window: disabled.
[    0.902801]   MEM window: 0xf7f00000-0xfdffffff
[    0.902826]   PREFETCH window: disabled.
[    0.902859] PCI: Bus 2, cardbus bridge: 0000:00:10.0
[    0.902878]   IO window: 0x00001000-0x000010ff
[    0.902903]   IO window: 0x00001400-0x000014ff
[    0.902927]   PREFETCH window: 0x30000000-0x33ffffff
[    0.902953]   MEM window: 0x34000000-0x37ffffff
[    0.902978] PCI: Bus 6, cardbus bridge: 0000:00:11.0
[    0.902995]   IO window: 0x00001800-0x000018ff
[    0.903019]   IO window: 0x00001c00-0x00001cff
[    0.903044]   PREFETCH window: 0x38000000-0x3bffffff
[    0.903070]   MEM window: 0x3c000000-0x3fffffff
[    0.903095] PCI: Bus 10, cardbus bridge: 0000:00:11.1
[    0.903113]   IO window: 0x00002000-0x000020ff
[    0.903137]   IO window: 0x00002400-0x000024ff
[    0.903161]   PREFETCH window: 0x40000000-0x43ffffff
[    0.903187]   MEM window: 0x44000000-0x47ffffff
[    0.903242] PCI: Setting latency timer of device 0000:00:01.0 to 64
[    0.903346] PCI: Enabling device 0000:00:10.0 (0000 -> 0003)
[    0.905022] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    0.905055] PCI: setting IRQ 11 as level-triggered
[    0.905064] ACPI: PCI Interrupt 0000:00:10.0[A] -> Link [LNKC] -> GSI 11 (level, low) -> IRQ 11
[    0.905155] PCI: Enabling device 0000:00:11.0 (0000 -> 0003)
[    0.906268] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 11
[    0.906291] ACPI: PCI Interrupt 0000:00:11.0[A] -> Link [LNKA] -> GSI 11 (level, low) -> IRQ 11
[    0.906374] PCI: Enabling device 0000:00:11.1 (0000 -> 0003)
[    0.907529] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 11
[    0.907552] ACPI: PCI Interrupt 0000:00:11.1[B] -> Link [LNKB] -> GSI 11 (level, low) -> IRQ 11
[    0.907656] NET: Registered protocol family 2
[    0.908639] IP route cache hash table entries: 4096 (order: 2, 16384 bytes)
[    0.910600] TCP established hash table entries: 16384 (order: 5, 131072 bytes)
[    0.911366] TCP bind hash table entries: 16384 (order: 7, 589824 bytes)
[    0.917529] TCP: Hash tables configured (established 16384 bind 16384)
[    0.917770] TCP reno registered
[    0.923174] audit: initializing netlink socket (disabled)
[    0.923483] type=2000 audit(1203238344.923:1): initialized
[    0.947451] io scheduler noop registered
[    0.947509] io scheduler anticipatory registered
[    0.947528] io scheduler deadline registered
[    0.948145] io scheduler cfq registered (default)
[    0.948289] pci 0000:00:07.0: Activating ISA DMA hang workarounds
[    0.948388] pci 0000:01:00.0: Boot video device
[    0.949794] vesafb: framebuffer at 0xfc000000, mapped to 0xdf880000, using 3072k, total 16384k
[    0.949841] vesafb: mode is 1024x768x16, linelength=2048, pages=9
[    0.949862] vesafb: protected mode interface info at c000:775e
[    0.949883] vesafb: pmi: set display start = c00c777f, set palette = c00c77e2
[    0.949969] vesafb: scrolling: redraw
[    0.949989] vesafb: Truecolor: size=0:5:6:5, shift=0:11:5:0
[    1.021117] Console: switching to colour frame buffer device 128x48
[    1.083282] fb0: VESA VGA frame buffer device
[    1.352781] brd: module loaded
[    1.354826] e100: Intel(R) PRO/100 Network Driver, 3.5.23-k4-NAPI
[    1.355656] e100: Copyright(c) 1999-2006 Intel Corporation
[    1.358318] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    1.359107] ACPI: PCI Interrupt 0000:00:0a.0[A] -> Link [LNKD] -> GSI 11 (level, low) -> IRQ 11
[    1.389557] e100: eth0: e100_probe: addr 0xf7efd000, irq 11, MAC addr 00:00:39:d7:14:a1
[    1.390354] console [netcon0] enabled
[    1.393318] netconsole: network logging started
[    1.400970] PNP: PS/2 Controller [PNP0303:KBC,PNP0f13:PS2M] at 0x60,0x64 irq 1,12
[    1.403458] Switched to high resolution mode on CPU 0
[    1.410426] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.413404] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.420149] mice: PS/2 mouse device common for all mice
[    1.424039] cpuidle: using governor ladder
[    1.426655] cpuidle: using governor menu
[    1.436212] TCP cubic registered
[    1.437383] NET: Registered protocol family 1
[    1.440094] Using IPI Shortcut mode
[    1.446663] BIOS EDD facility v0.16 2004-Jun-25, 16 devices found
[    1.458402] Freeing unused kernel memory: 208k freed
[    1.460155] Write protecting the kernel read-only data: 744k
[    1.492266] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input0
[    2.062397] Uniform Multi-Platform E-IDE driver
[    2.065562] ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
[    2.148193] ALI15X3: IDE controller (0x10b9:0x5229 rev 0xc3) at  PCI slot 0000:00:04.0
[    2.148944] ACPI: Unable to derive IRQ for device 0000:00:04.0
[    2.152193] ALI15X3: not 100% native mode: will probe irqs later
[    2.155726]     ide0: BM-DMA at 0xeff0-0xeff7, BIOS settings: hda:DMA, hdb:PIO
[    2.162170]     ide1: BM-DMA at 0xeff8-0xefff, BIOS settings: hdc:DMA, hdd:PIO
[    2.165501] Probing IDE interface ide0...
[    3.087592] hda: IC25N020ATDA04-0, ATA DISK drive
[    3.087833] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    3.088156] hda: host side 80-wire cable detection failed, limiting max speed to UDMA33
[    3.090963] hda: UDMA/33 mode selected
[    3.094615] Probing IDE interface ide1...
[    4.440862] hdc: TOSHIBA DVD-ROM SD-C2502, ATAPI CD/DVD-ROM drive
[    4.441043] hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[    4.441428] hdc: UDMA/33 mode selected
[    4.445606] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    4.474714] ide1 at 0x170-0x177,0x376 on irq 15
[    4.480074] hda: max request size: 128KiB
[    4.482087] hda: 39070080 sectors (20003 MB) w/1806KiB Cache, CHS=38760/16/63
[    4.484751] hda: cache flushes not supported
[    4.492186]  hda: hda1 hda2
[    4.811550] ReiserFS: hda2: found reiserfs format "3.6" with standard journal
[    4.814835] ReiserFS: hda2: using ordered data mode
[    4.856293] ReiserFS: hda2: journal params: device hda2, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
[    4.868102] ReiserFS: hda2: checking transaction log (hda2)
[    4.929981] ReiserFS: hda2: Using r5 hash to sort names
[   13.051622] Linux agpgart interface v0.103
[   13.091384] Yenta: CardBus bridge found at 0000:00:10.0 [12a3:ab01]
[   13.091455] Yenta: Using CSCINT to route CSC interrupts to PCI
[   13.091463] Yenta: Routing CardBus interrupts to PCI
[   13.091478] Yenta TI: socket 0000:00:10.0, mfunc 0x01000002, devctl 0x60
[   13.205776] hdc: ATAPI 24X DVD-ROM drive, 128kB Cache
[   13.205813] Uniform CD-ROM driver Revision: 3.20
[   13.221438] PCI: Enabling device 0000:00:08.0 (0000 -> 0001)
[   13.222514] ALi_M1535: initialized. timeout=60 sec (nowayout=0)
[   13.320934] Yenta: ISA IRQ mask 0x0000, PCI irq 11
[   13.320953] Socket status: 30000059
[   13.348110] Yenta: CardBus bridge found at 0000:00:11.0 [1179:0001]
[   13.474505] Yenta: ISA IRQ mask 0x04b8, PCI irq 11
[   13.474523] Socket status: 30000087
[   13.487317] Yenta: CardBus bridge found at 0000:00:11.1 [1179:0001]
[   13.614491] Yenta: ISA IRQ mask 0x04b8, PCI irq 11
[   13.614510] Socket status: 30000007
[   13.653174] agpgart: Detected ALi M1644 chipset
[   13.666109] agpgart: AGP aperture is 64M @ 0xf0000000
[   13.771819] ACPI: CPU0 (power states: C1[C1] C2[C2])
[   13.773125] ACPI: ACPI0007:00 is registered as cooling_device0
[   13.803785] input: PC Speaker as /devices/platform/pcspkr/input/input1
[   13.849164] input: Power Button (FF) as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input2
[   13.870415] ACPI: Power Button (FF) [PWRF]
[   13.871032] input: Lid Switch as /devices/LNXSYSTM:00/device:00/PNP0C0D:00/input/input3
[   13.880905] ACPI: Lid Switch [LID]
[   13.890413] ACPI: AC Adapter [ADP1] (on-line)
[   13.983754] pccard: PCMCIA card inserted into slot 0
[   13.988643] ACPI: Battery Slot [BAT1] (battery present)
[   13.988871] ACPI: Battery Slot [BAT2] (battery absent)
[   14.407044] ACPI: LNXTHERM:01 is registered as thermal_zone0
[   14.407985] ACPI: Thermal Zone [THRM] (64 C)
[   14.418860] usbcore: registered new interface driver usbfs
[   14.419417] usbcore: registered new interface driver hub
[   14.439706] usbcore: registered new device driver usb
[   14.534464] ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
[   14.536271] ACPI: PCI Interrupt Link [LNKG] enabled at IRQ 11
[   14.536289] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LNKG] -> GSI 11 (level, low) -> IRQ 11
[   14.536371] ohci_hcd 0000:00:02.0: OHCI Host Controller
[   14.696372] ohci_hcd 0000:00:02.0: new USB bus registered, assigned bus number 1
[   14.696595] ohci_hcd 0000:00:02.0: irq 11, io mem 0xf7eff000
[   14.815184] usb usb1: configuration #1 chosen from 1 choice
[   14.855818] hub 1-0:1.0: USB hub found
[   14.871641] hub 1-0:1.0: 3 ports detected
[   14.909523] input: ImPS/2 Generic Wheel Mouse as /devices/platform/i8042/serio1/input/input4
[   14.929279] ACPI: Transitioning device [FAN] to D3
[   14.929563] ACPI: PNP0C0B:00 is registered as cooling_device1
[   14.929596] ACPI: Fan [FAN] (off)
[   15.659717] ACPI: PCI Interrupt Link [LNKH] enabled at IRQ 11
[   15.659742] ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKH] -> GSI 11 (level, low) -> IRQ 11
[   15.685243] Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing enabled
[   15.724367] rtc_cmos 00:07: rtc core: registered rtc_cmos as rtc0
[   15.724468] rtc0: alarms up to one year
[   15.989650] serial 00:09: activated
[   16.215254] NET: Registered protocol family 23
[   16.320280] Detected unconfigured Toshiba laptop with ALi ISA bridge SMSC IrDA chip, pre-configuring device.
[   16.320322] Activated ALi 1533 ISA bridge port 0x02e8.
[   16.320339] Activated ALi 1533 ISA bridge port 0x02f8.
[   16.320550] found SMC SuperIO Chip (devid=0x5a rev=00 base=0x002e): LPC47N227
[   16.320585] smsc_superio_flat(): fir: 0x2f8, sir: 0x2e8, dma: 03, irq: 7, mode: 0x0a
[   16.320623] SMsC IrDA Controller found
[   16.320627]  IrCC version 2.0, firport 0x2f8, sirport 0x2e8 dma=3, irq=7
[   16.320844] No transceiver found. Defaulting to Fast pin select
[   16.324729] IrDA: Registered device irda0
[   19.926483] cs: IO port probe 0x100-0x3af: excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   19.930157] cs: IO port probe 0x3e0-0x4ff: clean.
[   19.931629] cs: IO port probe 0x820-0x8ff: clean.
[   19.933094] cs: IO port probe 0xc00-0xcf7: clean.
[   19.935534] cs: IO port probe 0xa00-0xaff: clean.
[   20.566139] cs: IO port probe 0x100-0x3af: excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   20.569487] cs: IO port probe 0x3e0-0x4ff: clean.
[   20.571048] cs: IO port probe 0x820-0x8ff: clean.
[   20.572393] cs: IO port probe 0xc00-0xcf7: clean.
[   20.575059] cs: IO port probe 0xa00-0xaff: clean.
[   20.577461] cs: memory probe 0xa0000000-0xa0ffffff: clean.
[   20.590887] pcmcia: registering new device pcmcia0.0
[   20.605373] cs: IO port probe 0x100-0x3af: excluding 0x200-0x207 0x220-0x22f 0x330-0x337 0x388-0x38f
[   20.608703] cs: IO port probe 0x3e0-0x4ff: clean.
[   20.610241] cs: IO port probe 0x820-0x8ff: clean.
[   20.611570] cs: IO port probe 0xc00-0xcf7: clean.
[   20.614126] cs: IO port probe 0xa00-0xaff: clean.
[   21.231647] Marking TSC unstable due to: TSC halts in idle.
[   21.324733] Time: acpi_pm clocksource has been installed.
[   21.578958] Clocksource tsc unstable (delta = -322867937 ns)
[   21.790570] wlags49_h1_cs v7.18 for PCMCIA, 03/31/2004 14:31:00 by Agere Systems, http://www.agere.com
[   21.790597] *** Modified for kernel 2.6 by Andrey Borzenkov <arvidjaar@mail.ru> $Revision: 39 $
[   21.790605] *** Station Mode (STA) Support: YES
[   21.790611] *** Access Point Mode (AP) Support: YES
[   21.836772] eth1: PRI 31 variant 2 version 9.48
[   21.836772] eth1: NIC 5 variant 2 version 1.02
[   21.852013] eth1: Wireless, io_addr 0x100, irq 11, mac_address 00:02:2D:26:95:6C
[   22.483307] Toshiba System Management Mode driver v1.11 26/9/2001
[   22.607162] Non-volatile memory driver v1.2
[   23.615362] device-mapper: uevent: version 1.0.3
[   23.618746] device-mapper: ioctl: 4.13.0-ioctl (2007-10-18) initialised: dm-devel@redhat.com
[   27.663108] Adding 500432k swap on /dev/hda1.  Priority:-1 extents:1 across:500432k
[   28.219423] loop: module loaded
[   41.815792] IrCOMM protocol (Dag Brattli)
[   43.017701] PPP generic driver version 2.4.2
[   51.745765] Bluetooth: Core ver 2.11
[   51.749903] NET: Registered protocol family 31
[   51.749928] Bluetooth: HCI device and connection manager initialized
[   51.750626] Bluetooth: HCI socket layer initialized
[   51.879426] NET: Registered protocol family 17
[   52.196149] Bluetooth: L2CAP ver 2.9
[   52.196185] Bluetooth: L2CAP socket layer initialized
[   52.361060] Bluetooth: RFCOMM socket layer initialized
[   52.362425] Bluetooth: RFCOMM TTY layer initialized
[   52.362449] Bluetooth: RFCOMM ver 1.8
[   54.336846] eth1: PRI 31 variant 2 version 9.48
[   54.336846] eth1: NIC 5 variant 2 version 1.02
[   55.827790] eth1: PRI 31 variant 2 version 9.48
[   55.827790] eth1: NIC 5 variant 2 version 1.02
[   56.041110] eth1: PRI 31 variant 2 version 9.48
[   56.041110] eth1: NIC 5 variant 2 version 1.02
[   63.162469] warning: `ntpd' uses 32-bit capabilities (legacy support in use)
[ 6771.263238] PM: Syncing filesystems ... done.
[ 6771.306778] Freezing user space processes ... (elapsed 0.00 seconds) done.
[ 6771.317193] Freezing remaining freezable tasks ... (elapsed 0.00 seconds) done.
[ 6771.320933] ACPI: Preparing to enter system sleep state S3
[ 6771.322957] Suspending console(s)
[ 6773.467232] serial 00:09: disabled
[ 6773.473857] Trying to free already-free IRQ 11
[ 6773.473871] Pid: 4819, comm: pm-suspend Not tainted 2.6.25-rc2-1avb #2
[ 6773.473885]  [<c0152127>] free_irq+0xb7/0x130
[ 6773.473932]  [<c024bd80>] e100_suspend+0xc0/0x100
[ 6773.473981]  [<c01eaa36>] pci_device_suspend+0x26/0x70
[ 6773.474004]  [<c0243674>] suspend_device+0x94/0xd0
[ 6773.474019]  [<c02439a3>] device_suspend+0x153/0x240
[ 6773.474039]  [<c014314f>] suspend_devices_and_enter+0x4f/0xf0
[ 6773.474065]  [<c0143a5f>] ? freeze_processes+0x3f/0x80
[ 6773.474083]  [<c01432fa>] enter_state+0xaa/0x140
[ 6773.474098]  [<c014341f>] state_store+0x8f/0xd0
[ 6773.474109]  [<c0143390>] ? state_store+0x0/0xd0
[ 6773.474123]  [<c01d3404>] kobj_attr_store+0x24/0x30
[ 6773.474159]  [<c01b547b>] sysfs_write_file+0xbb/0x110
[ 6773.474196]  [<c0177d79>] vfs_write+0x99/0x130
[ 6773.474224]  [<c01b53c0>] ? sysfs_write_file+0x0/0x110
[ 6773.474239]  [<c01782fd>] sys_write+0x3d/0x70
[ 6773.474258]  [<c010409a>] sysenter_past_esp+0x5f/0xa5
[ 6773.474297]  =======================
[ 6773.475189] ACPI: PCI interrupt for device 0000:00:0a.0 disabled
[ 6773.531352] ACPI: PCI interrupt for device 0000:00:06.0 disabled
[ 6773.544526] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[ 6773.562975]  hwsleep-0322 [00] enter_sleep_state     : Entering sleep state [S3]
[ 6773.562975] Back to C!
[ 6773.583911] PCI: Setting latency timer of device 0000:00:01.0 to 64
[ 6773.596830] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LNKG] -> GSI 11 (level, low) -> IRQ 11
[ 6773.596879] PM: Writing back config space on device 0000:00:02.0 at offset f (was 500001ff, writing 5000010b)
[ 6773.597101] ACPI: Unable to derive IRQ for device 0000:00:04.0
[ 6773.610384] PM: Writing back config space on device 0000:00:06.0 at offset f (was 180201ff, writing 1802010b)
[ 6773.610498] ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKH] -> GSI 11 (level, low) -> IRQ 11
[ 6773.910220] PCI: Enabling device 0000:00:08.0 (0000 -> 0001)
[ 6773.923378] PM: Writing back config space on device 0000:00:0a.0 at offset f (was 380801ff, writing 3808010b)
[ 6773.923447] PM: Writing back config space on device 0000:00:0a.0 at offset 1 (was 2900003, writing 2900007)
[ 6773.923576] PM: Writing back config space on device 0000:00:10.0 at offset 6 (was 50200, writing b0050200)
[ 6774.899360] PM: Writing back config space on device 0000:00:12.0 at offset f (was 1ff, writing 10b)
[ 6774.899478] PM: Writing back config space on device 0000:01:00.0 at offset f (was 1ff, writing 10b)
[ 6774.909757] serial 00:09: activated
[ 6775.332194] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[ 6775.332424] hda: UDMA/33 mode selected
[ 6775.344338] hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[ 6775.345526] hdc: UDMA/33 mode selected
[ 6775.399843] usb usb1: root hub lost power or was reset
[ 6775.556713] eth1: PRI 31 variant 2 version 9.48
[ 6775.556713] eth1: NIC 5 variant 2 version 1.02
[ 6775.560089] Restarting tasks ... done.
[ 6781.179680] eth1: PRI 31 variant 2 version 9.48
[ 6781.179680] eth1: NIC 5 variant 2 version 1.02
[ 6781.326338] eth1: PRI 31 variant 2 version 9.48
[ 6781.326338] eth1: NIC 5 variant 2 version 1.02
[ 6781.442997] eth1: PRI 31 variant 2 version 9.48
[ 6781.442997] eth1: NIC 5 variant 2 version 1.02
[ 8737.795758] toshiba_acpi: Toshiba Laptop ACPI Extras version 0.18
[ 8737.795785] toshiba_acpi:     HCI method: \_SB_.VALD.GHCI
[ 8803.781910] PM: Syncing filesystems ... done.
[ 8803.838967] Freezing user space processes ... (elapsed 0.00 seconds) done.
[ 8803.848156] Freezing remaining freezable tasks ... (elapsed 0.00 seconds) done.
[ 8803.850634] ACPI: Preparing to enter system sleep state S3
[ 8803.853141] Suspending console(s)
[ 8805.287505] serial 00:09: disabled
[ 8805.291564] Trying to free already-free IRQ 11
[ 8805.291579] Pid: 6920, comm: pm-suspend Not tainted 2.6.25-rc2-1avb #2
[ 8805.291628]  [<c0152127>] free_irq+0xb7/0x130
[ 8805.291675]  [<c024bd80>] e100_suspend+0xc0/0x100
[ 8805.291724]  [<c01eaa36>] pci_device_suspend+0x26/0x70
[ 8805.291747]  [<c0243674>] suspend_device+0x94/0xd0
[ 8805.291763]  [<c02439a3>] device_suspend+0x153/0x240
[ 8805.291784]  [<c014314f>] suspend_devices_and_enter+0x4f/0xf0
[ 8805.291808]  [<c0143a5f>] ? freeze_processes+0x3f/0x80
[ 8805.291825]  [<c01432fa>] enter_state+0xaa/0x140
[ 8805.291840]  [<c014341f>] state_store+0x8f/0xd0
[ 8805.291852]  [<c0143390>] ? state_store+0x0/0xd0
[ 8805.291866]  [<c01d3404>] kobj_attr_store+0x24/0x30
[ 8805.291901]  [<c01b547b>] sysfs_write_file+0xbb/0x110
[ 8805.291936]  [<c0177d79>] vfs_write+0x99/0x130
[ 8805.291963]  [<c01b53c0>] ? sysfs_write_file+0x0/0x110
[ 8805.291979]  [<c01782fd>] sys_write+0x3d/0x70
[ 8805.291998]  [<c010409a>] sysenter_past_esp+0x5f/0xa5
[ 8805.292038]  =======================
[ 8805.347640] ACPI: PCI interrupt for device 0000:00:06.0 disabled
[ 8805.361128] ACPI: PCI interrupt for device 0000:00:02.0 disabled
[ 8805.376670]  hwsleep-0322 [00] enter_sleep_state     : Entering sleep state [S3]
[ 8805.376670] Back to C!
[ 8805.397476] PCI: Setting latency timer of device 0000:00:01.0 to 64
[ 8805.410564] ACPI: PCI Interrupt 0000:00:02.0[A] -> Link [LNKG] -> GSI 11 (level, low) -> IRQ 11
[ 8805.410613] PM: Writing back config space on device 0000:00:02.0 at offset f (was 500001ff, writing 5000010b)
[ 8805.410836] ACPI: Unable to derive IRQ for device 0000:00:04.0
[ 8805.424228] PM: Writing back config space on device 0000:00:06.0 at offset f (was 180201ff, writing 1802010b)
[ 8805.424343] ACPI: PCI Interrupt 0000:00:06.0[A] -> Link [LNKH] -> GSI 11 (level, low) -> IRQ 11
[ 8805.717374] PCI: Enabling device 0000:00:08.0 (0000 -> 0001)
[ 8805.730528] PM: Writing back config space on device 0000:00:0a.0 at offset f (was 380801ff, writing 3808010b)
[ 8805.730712] PM: Writing back config space on device 0000:00:10.0 at offset 6 (was 50200, writing b0050200)
[ 8806.709907] PM: Writing back config space on device 0000:00:12.0 at offset f (was 1ff, writing 10b)
[ 8806.710025] PM: Writing back config space on device 0000:01:00.0 at offset f (was 1ff, writing 10b)
[ 8806.720272] serial 00:09: activated
[ 8807.138422] hda: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[ 8807.138659] hda: UDMA/33 mode selected
[ 8807.145088] hdc: host max PIO5 wanted PIO255(auto-tune) selected PIO4
[ 8807.145088] hdc: UDMA/33 mode selected
[ 8807.203643] usb usb1: root hub lost power or was reset
[ 8807.360453] eth1: PRI 31 variant 2 version 9.48
[ 8807.360453] eth1: NIC 5 variant 2 version 1.02
[ 8807.367163] Restarting tasks ... done.
[ 8811.193537] eth1: PRI 31 variant 2 version 9.48
[ 8811.193537] eth1: NIC 5 variant 2 version 1.02
[ 8811.333528] eth1: PRI 31 variant 2 version 9.48
[ 8811.333528] eth1: NIC 5 variant 2 version 1.02
[ 8811.446854] eth1: PRI 31 variant 2 version 9.48
[ 8811.446854] eth1: NIC 5 variant 2 version 1.02

--Boundary-01=_jpCuHP3cXYHHfIx
Content-Type: text/plain;
  charset="us-ascii";
  name="config-2.6.25-rc2-1avb"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="config-2.6.25-rc2-1avb"

#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.25-rc2
# Sat Feb 16 19:45:46 2008
#
# CONFIG_64BIT is not set
CONFIG_X86_32=y
# CONFIG_X86_64 is not set
CONFIG_X86=y
# CONFIG_GENERIC_LOCKBREAK is not set
CONFIG_GENERIC_TIME=y
CONFIG_GENERIC_CMOS_UPDATE=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_SEMAPHORE_SLEEPERS=y
CONFIG_FAST_CMPXCHG_LOCAL=y
CONFIG_MMU=y
CONFIG_ZONE_DMA=y
CONFIG_QUICKLIST=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_HWEIGHT=y
# CONFIG_GENERIC_GPIO is not set
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_DMI=y
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
# CONFIG_ARCH_HAS_ILOG2_U32 is not set
# CONFIG_ARCH_HAS_ILOG2_U64 is not set
CONFIG_ARCH_HAS_CPU_IDLE_WAIT=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
# CONFIG_GENERIC_TIME_VSYSCALL is not set
CONFIG_ARCH_HAS_CPU_RELAX=y
# CONFIG_HAVE_SETUP_PER_CPU_AREA is not set
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
# CONFIG_ZONE_DMA32 is not set
CONFIG_ARCH_POPULATES_NODE_MAP=y
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_AOUT=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_KTIME_SCALAR=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_TASKSTATS is not set
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_TREE=y
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
# CONFIG_CGROUPS is not set
CONFIG_GROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_USER_SCHED=y
# CONFIG_CGROUP_SCHED is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
# CONFIG_NAMESPACES is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_EMBEDDED=y
# CONFIG_UID16 is not set
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_COMPAT_BRK=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_ANON_INODES=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
CONFIG_PROFILING=y
# CONFIG_MARKERS is not set
CONFIG_OPROFILE=m
CONFIG_HAVE_OPROFILE=y
CONFIG_KPROBES=y
CONFIG_HAVE_KPROBES=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
CONFIG_KMOD=y
CONFIG_BLOCK=y
# CONFIG_LBD is not set
# CONFIG_BLK_DEV_IO_TRACE is not set
# CONFIG_LSF is not set
# CONFIG_BLK_DEV_BSG is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_AS=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_AS is not set
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_CLASSIC_RCU=y
# CONFIG_PREEMPT_RCU is not set

#
# Processor type and features
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
# CONFIG_SMP is not set
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_VSMP is not set
CONFIG_SCHED_NO_NO_OMIT_FRAME_POINTER=y
# CONFIG_PARAVIRT_GUEST is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
# CONFIG_MPENTIUMII is not set
CONFIG_MPENTIUMIII=y
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_GENERIC_CPU is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=4
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_IOMMU_HELPER is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_RCU_TRACE=y
# CONFIG_X86_UP_APIC is not set
# CONFIG_X86_MCE is not set
CONFIG_VM86=y
CONFIG_TOSHIBA=m
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=m
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_X86_MSR=m
CONFIG_X86_CPUID=m
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_VMSPLIT_3G=y
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0xC0000000
# CONFIG_X86_PAE is not set
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_DISCONTIGMEM_MANUAL is not set
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
# CONFIG_SPARSEMEM_VMEMMAP_ENABLE is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_RESOURCES_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NR_QUICK=1
CONFIG_VIRT_TO_BUS=y
# CONFIG_MATH_EMULATION is not set
CONFIG_MTRR=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
# CONFIG_KEXEC is not set
CONFIG_PHYSICAL_START=0x100000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x100000
# CONFIG_COMPAT_VDSO is not set

#
# Power management options
#
CONFIG_PM=y
# CONFIG_PM_LEGACY is not set
# CONFIG_PM_DEBUG is not set
CONFIG_PM_SLEEP=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
CONFIG_ACPI_SYSFS_POWER=y
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=m
CONFIG_ACPI_BATTERY=m
CONFIG_ACPI_BUTTON=m
CONFIG_ACPI_VIDEO=m
CONFIG_ACPI_FAN=m
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=m
CONFIG_ACPI_THERMAL=m
# CONFIG_ACPI_WMI is not set
# CONFIG_ACPI_ASUS is not set
CONFIG_ACPI_TOSHIBA=m
# CONFIG_ACPI_CUSTOM_DSDT is not set
CONFIG_ACPI_CUSTOM_DSDT_INITRD=y
CONFIG_ACPI_BLACKLIST_YEAR=0
CONFIG_ACPI_DEBUG=y
# CONFIG_ACPI_DEBUG_FUNC_TRACE is not set
CONFIG_ACPI_EC=y
CONFIG_ACPI_POWER=y
CONFIG_ACPI_SYSTEM=y
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_APM is not set

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
# CONFIG_CPU_FREQ_DEBUG is not set
CONFIG_CPU_FREQ_STAT=y
CONFIG_CPU_FREQ_STAT_DETAILS=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=m
CONFIG_CPU_FREQ_GOV_POWERSAVE=m
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=m
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=m

#
# CPUFreq processor drivers
#
CONFIG_X86_ACPI_CPUFREQ=m
# CONFIG_X86_POWERNOW_K6 is not set
# CONFIG_X86_POWERNOW_K7 is not set
# CONFIG_X86_POWERNOW_K8 is not set
# CONFIG_X86_GX_SUSPMOD is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_SPEEDSTEP_ICH is not set
# CONFIG_X86_SPEEDSTEP_SMI is not set
# CONFIG_X86_P4_CLOCKMOD is not set
# CONFIG_X86_CPUFREQ_NFORCE2 is not set
# CONFIG_X86_LONGRUN is not set
# CONFIG_X86_LONGHAUL is not set
# CONFIG_X86_E_POWERSAVER is not set

#
# shared options
#
# CONFIG_X86_ACPI_CPUFREQ_PROC_INTF is not set
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y

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
# CONFIG_PCIEPORTBUS is not set
# CONFIG_ARCH_SUPPORTS_MSI is not set
CONFIG_PCI_LEGACY=y
# CONFIG_PCI_DEBUG is not set
CONFIG_ISA_DMA_API=y
CONFIG_ISA=y
# CONFIG_EISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set
CONFIG_PCCARD=m
# CONFIG_PCMCIA_DEBUG is not set
CONFIG_PCMCIA=m
CONFIG_PCMCIA_LOAD_CIS=y
# CONFIG_PCMCIA_IOCTL is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=m
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
# CONFIG_PD6729 is not set
# CONFIG_I82092 is not set
# CONFIG_I82365 is not set
# CONFIG_TCIC is not set
CONFIG_PCMCIA_PROBE=y
CONFIG_PCCARD_NONSTATIC=m
# CONFIG_HOTPLUG_PCI is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_BINFMT_AOUT=m
CONFIG_BINFMT_MISC=m

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=m
CONFIG_PACKET_MMAP=y
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=m
# CONFIG_XFRM_SUB_POLICY is not set
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
CONFIG_NET_KEY=m
# CONFIG_NET_KEY_MIGRATE is not set
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
# CONFIG_IP_ROUTE_MULTIPATH is not set
# CONFIG_IP_ROUTE_VERBOSE is not set
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
# CONFIG_IP_MROUTE is not set
# CONFIG_ARPD is not set
# CONFIG_SYN_COOKIES is not set
# CONFIG_INET_AH is not set
# CONFIG_INET_ESP is not set
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
# CONFIG_INET_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_TRANSPORT is not set
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
# CONFIG_INET_LRO is not set
# CONFIG_INET_DIAG is not set
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_CUBIC=y
CONFIG_DEFAULT_TCP_CONG="cubic"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_INET6_XFRM_TUNNEL is not set
# CONFIG_INET6_TUNNEL is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETFILTER is not set
# CONFIG_IP_DCCP is not set
# CONFIG_IP_SCTP is not set
# CONFIG_TIPC is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_ECONET is not set
# CONFIG_WAN_ROUTER is not set
# CONFIG_NET_SCHED is not set

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_NET_TCPPROBE is not set
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
CONFIG_IRDA=m

#
# IrDA protocols
#
CONFIG_IRLAN=m
CONFIG_IRNET=m
CONFIG_IRCOMM=m
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
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
# CONFIG_KINGSUN_DONGLE is not set
# CONFIG_KSDAZZLE_DONGLE is not set
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
# CONFIG_USB_IRDA is not set
# CONFIG_SIGMATEL_FIR is not set
# CONFIG_NSC_FIR is not set
# CONFIG_WINBOND_FIR is not set
# CONFIG_TOSHIBA_FIR is not set
CONFIG_SMC_IRCC_FIR=m
# CONFIG_ALI_FIR is not set
# CONFIG_VLSI_FIR is not set
# CONFIG_VIA_FIR is not set
# CONFIG_MCS_FIR is not set
CONFIG_BT=m
CONFIG_BT_L2CAP=m
# CONFIG_BT_SCO is not set
CONFIG_BT_RFCOMM=m
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=m
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIUSB=m
# CONFIG_BT_HCIUSB_SCO is not set
# CONFIG_BT_HCIUART is not set
# CONFIG_BT_HCIBCM203X is not set
# CONFIG_BT_HCIBPA10X is not set
# CONFIG_BT_HCIBFUSB is not set
# CONFIG_BT_HCIDTL1 is not set
# CONFIG_BT_HCIBT3C is not set
# CONFIG_BT_HCIBLUECARD is not set
# CONFIG_BT_HCIBTUART is not set
# CONFIG_BT_HCIVHCI is not set
# CONFIG_AF_RXRPC is not set
CONFIG_FIB_RULES=y

#
# Wireless
#
CONFIG_CFG80211=m
CONFIG_NL80211=y
CONFIG_WIRELESS_EXT=y
# CONFIG_MAC80211 is not set
# CONFIG_IEEE80211 is not set
# CONFIG_RFKILL is not set
# CONFIG_NET_9P is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH="\"\""
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=m
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
CONFIG_CONNECTOR=m
# CONFIG_MTD is not set
# CONFIG_PARPORT is not set
CONFIG_PNP=y
# CONFIG_PNP_DEBUG is not set

#
# Protocols
#
# CONFIG_ISAPNP is not set
# CONFIG_PNPBIOS is not set
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_FD is not set
# CONFIG_BLK_DEV_XD is not set
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=m
CONFIG_BLK_DEV_CRYPTOLOOP=m
CONFIG_BLK_DEV_NBD=m
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=32000
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
# CONFIG_ATA_OVER_ETH is not set
CONFIG_MISC_DEVICES=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_EEPROM_93CX6 is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_MSI_LAPTOP is not set
# CONFIG_SONY_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=m
CONFIG_IDE_MAX_HWIFS=4
CONFIG_BLK_DEV_IDE=m

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_HD_IDE is not set
CONFIG_BLK_DEV_IDEDISK=m
# CONFIG_IDEDISK_MULTI_MODE is not set
# CONFIG_BLK_DEV_IDECS is not set
# CONFIG_BLK_DEV_DELKIN is not set
CONFIG_BLK_DEV_IDECD=m
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
# CONFIG_BLK_DEV_IDETAPE is not set
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_BLK_DEV_IDESCSI is not set
CONFIG_BLK_DEV_IDEACPI=y
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=m
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
# CONFIG_BLK_DEV_IDEPNP is not set
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_OPTI621 is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
CONFIG_BLK_DEV_ALI15X3=m
# CONFIG_WDC_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
# CONFIG_BLK_DEV_PIIX is not set
# CONFIG_BLK_DEV_IT8213 is not set
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_BLK_DEV_TC86C001 is not set

#
# Other IDE chipsets support
#

#
# Note: most of these also require special kernel boot parameters
#
# CONFIG_BLK_DEV_4DRIVES is not set
# CONFIG_BLK_DEV_ALI14XX is not set
# CONFIG_BLK_DEV_DTC2278 is not set
# CONFIG_BLK_DEV_HT6560B is not set
# CONFIG_BLK_DEV_QD65XX is not set
# CONFIG_BLK_DEV_UMC8672 is not set
CONFIG_BLK_DEV_IDEDMA=y
CONFIG_IDE_ARCH_OBSOLETE_INIT=y
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=m
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=m
# CONFIG_SCSI_NETLINK is not set
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=m
# CONFIG_CHR_DEV_ST is not set
# CONFIG_CHR_DEV_OSST is not set
CONFIG_BLK_DEV_SR=m
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=m
# CONFIG_CHR_DEV_SCH is not set

#
# Some SCSI devices (e.g. CD jukebox) support multiple LUNs
#
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set
CONFIG_SCSI_WAIT_SCAN=m

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=m
# CONFIG_SCSI_FC_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=m
# CONFIG_SCSI_SAS_LIBSAS is not set
# CONFIG_SCSI_SRP_ATTRS is not set
CONFIG_SCSI_LOWLEVEL=y
# CONFIG_ISCSI_TCP is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_7000FASST is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AHA152X is not set
# CONFIG_SCSI_AHA1542 is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC7XXX_OLD is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_IN2000 is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_DTC3280 is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_GENERIC_NCR5380 is not set
# CONFIG_SCSI_GENERIC_NCR5380_MMIO is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_NCR53C406A is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_IPR is not set
# CONFIG_SCSI_PAS16 is not set
# CONFIG_SCSI_QLOGIC_FAS is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_SYM53C416 is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_T128 is not set
# CONFIG_SCSI_U14_34F is not set
# CONFIG_SCSI_ULTRASTOR is not set
# CONFIG_SCSI_NSP32 is not set
# CONFIG_SCSI_DEBUG is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_LOWLEVEL_PCMCIA is not set
CONFIG_ATA=m
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_AHCI is not set
# CONFIG_SATA_SVW is not set
# CONFIG_ATA_PIIX is not set
# CONFIG_SATA_MV is not set
# CONFIG_SATA_NV is not set
# CONFIG_PDC_ADMA is not set
# CONFIG_SATA_QSTOR is not set
# CONFIG_SATA_PROMISE is not set
# CONFIG_SATA_SX4 is not set
# CONFIG_SATA_SIL is not set
# CONFIG_SATA_SIL24 is not set
# CONFIG_SATA_SIS is not set
# CONFIG_SATA_ULI is not set
# CONFIG_SATA_VIA is not set
# CONFIG_SATA_VITESSE is not set
# CONFIG_SATA_INIC162X is not set
CONFIG_PATA_ACPI=m
CONFIG_PATA_ALI=m
# CONFIG_PATA_AMD is not set
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
# CONFIG_PATA_CMD640_PCI is not set
# CONFIG_PATA_CMD64X is not set
# CONFIG_PATA_CS5520 is not set
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5535 is not set
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
# CONFIG_PATA_EFAR is not set
# CONFIG_ATA_GENERIC is not set
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT821X is not set
# CONFIG_PATA_IT8213 is not set
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_LEGACY is not set
# CONFIG_PATA_TRIFLEX is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_MPIIX is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_NETCELL is not set
# CONFIG_PATA_NINJA32 is not set
# CONFIG_PATA_NS87410 is not set
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OPTI is not set
# CONFIG_PATA_OPTIDMA is not set
# CONFIG_PATA_PCMCIA is not set
# CONFIG_PATA_PDC_OLD is not set
# CONFIG_PATA_QDI is not set
# CONFIG_PATA_RADISYS is not set
# CONFIG_PATA_RZ1000 is not set
# CONFIG_PATA_SC1200 is not set
# CONFIG_PATA_SERVERWORKS is not set
# CONFIG_PATA_PDC2027X is not set
# CONFIG_PATA_SIL680 is not set
# CONFIG_PATA_SIS is not set
# CONFIG_PATA_VIA is not set
# CONFIG_PATA_WINBOND is not set
# CONFIG_PATA_WINBOND_VLB is not set
# CONFIG_PATA_PLATFORM is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=m
CONFIG_MD_LINEAR=m
CONFIG_MD_RAID0=m
CONFIG_MD_RAID1=m
CONFIG_MD_RAID10=m
CONFIG_MD_RAID456=m
CONFIG_MD_RAID5_RESHAPE=y
CONFIG_MD_MULTIPATH=m
CONFIG_MD_FAULTY=m
CONFIG_BLK_DEV_DM=m
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=m
CONFIG_DM_SNAPSHOT=m
CONFIG_DM_MIRROR=m
CONFIG_DM_ZERO=m
CONFIG_DM_MULTIPATH=m
CONFIG_DM_MULTIPATH_EMC=m
# CONFIG_DM_MULTIPATH_RDAC is not set
# CONFIG_DM_MULTIPATH_HP is not set
# CONFIG_DM_DELAY is not set
CONFIG_DM_UEVENT=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_IEEE1394 is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
# CONFIG_NETDEVICES_MULTIQUEUE is not set
CONFIG_DUMMY=m
CONFIG_BONDING=m
# CONFIG_MACVLAN is not set
# CONFIG_EQUALIZER is not set
CONFIG_TUN=m
CONFIG_VETH=m
# CONFIG_NET_SB1000 is not set
# CONFIG_ARCNET is not set
# CONFIG_PHYLIB is not set
CONFIG_NET_ETHERNET=y
CONFIG_MII=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NET_VENDOR_3COM is not set
# CONFIG_LANCE is not set
# CONFIG_NET_VENDOR_SMC is not set
# CONFIG_NET_VENDOR_RACAL is not set
# CONFIG_NET_TULIP is not set
# CONFIG_AT1700 is not set
# CONFIG_DEPCA is not set
# CONFIG_HP100 is not set
# CONFIG_NET_ISA is not set
# CONFIG_IBM_NEW_EMAC_ZMII is not set
# CONFIG_IBM_NEW_EMAC_RGMII is not set
# CONFIG_IBM_NEW_EMAC_TAH is not set
# CONFIG_IBM_NEW_EMAC_EMAC4 is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_AC3200 is not set
# CONFIG_APRICOT is not set
# CONFIG_B44 is not set
# CONFIG_FORCEDETH is not set
# CONFIG_CS89x0 is not set
# CONFIG_EEPRO100 is not set
CONFIG_E100=y
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R6040 is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_VIA_RHINE is not set
# CONFIG_SC92031 is not set
# CONFIG_NETDEV_1000 is not set
# CONFIG_NETDEV_10000 is not set
# CONFIG_TR is not set

#
# Wireless LAN
#
# CONFIG_WLAN_PRE80211 is not set
CONFIG_WLAN_80211=y
# CONFIG_PCMCIA_RAYCS is not set
# CONFIG_IPW2100 is not set
# CONFIG_IPW2200 is not set
# CONFIG_LIBERTAS is not set
# CONFIG_AIRO is not set
# CONFIG_HERMES is not set
# CONFIG_ATMEL is not set
# CONFIG_AIRO_CS is not set
# CONFIG_PCMCIA_WL3501 is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
# CONFIG_USB_NET_RNDIS_WLAN is not set
# CONFIG_HOSTAP is not set

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
# CONFIG_USB_PEGASUS is not set
# CONFIG_USB_RTL8150 is not set
# CONFIG_USB_USBNET is not set
# CONFIG_NET_PCMCIA is not set
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
CONFIG_PPP=m
CONFIG_PPP_MULTILINK=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_ASYNC=m
CONFIG_PPP_SYNC_TTY=m
CONFIG_PPP_DEFLATE=m
CONFIG_PPP_BSDCOMP=m
CONFIG_PPP_MPPE=m
CONFIG_PPPOE=m
# CONFIG_PPPOL2TP is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=m
# CONFIG_NET_FC is not set
CONFIG_NETCONSOLE=y
# CONFIG_NETCONSOLE_DYNAMIC is not set
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
# CONFIG_ISDN is not set
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=m
CONFIG_INPUT_EVDEV=m
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=m
# CONFIG_MOUSE_PS2_ALPS is not set
# CONFIG_MOUSE_PS2_LOGIPS2PP is not set
# CONFIG_MOUSE_PS2_SYNAPTICS is not set
# CONFIG_MOUSE_PS2_LIFEBOOK is not set
# CONFIG_MOUSE_PS2_TRACKPOINT is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_INPORT is not set
# CONFIG_MOUSE_LOGIBM is not set
# CONFIG_MOUSE_PC110PAD is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
CONFIG_INPUT_MISC=y
CONFIG_INPUT_PCSPKR=m
# CONFIG_INPUT_APANEL is not set
# CONFIG_INPUT_WISTRON_BTNS is not set
# CONFIG_INPUT_ATLAS_BTNS is not set
# CONFIG_INPUT_ATI_REMOTE is not set
# CONFIG_INPUT_ATI_REMOTE2 is not set
# CONFIG_INPUT_KEYSPAN_REMOTE is not set
# CONFIG_INPUT_POWERMATE is not set
# CONFIG_INPUT_YEALINK is not set
CONFIG_INPUT_UINPUT=m

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=m
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=m
CONFIG_FIX_EARLYCON_MEM=y
# CONFIG_SERIAL_8250_PCI is not set
CONFIG_SERIAL_8250_PNP=m
CONFIG_SERIAL_8250_CS=m
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
# CONFIG_SERIAL_8250_MANY_PORTS is not set
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
# CONFIG_SERIAL_8250_RSA is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_CORE=m
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_INTEL=m
# CONFIG_HW_RANDOM_AMD is not set
# CONFIG_HW_RANDOM_GEODE is not set
# CONFIG_HW_RANDOM_VIA is not set
CONFIG_NVRAM=m
# CONFIG_RTC is not set
CONFIG_GEN_RTC=m
CONFIG_GEN_RTC_X=y
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_IPWIRELESS is not set
# CONFIG_MWAVE is not set
# CONFIG_PC8736x_GPIO is not set
# CONFIG_NSC_GPIO is not set
# CONFIG_CS5535_GPIO is not set
CONFIG_RAW_DRIVER=m
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
# CONFIG_HPET_RTC_IRQ is not set
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=m
# CONFIG_TCG_TPM is not set
# CONFIG_TELCLOCK is not set
CONFIG_DEVPORT=y
CONFIG_I2C=m
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_CHARDEV=m

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=m
CONFIG_I2C_ALGOPCF=m
CONFIG_I2C_ALGOPCA=m

#
# I2C Hardware Bus support
#
CONFIG_I2C_ALI1535=m
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_ELEKTOR is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_I810 is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_OCORES is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_PROSAVAGE is not set
# CONFIG_I2C_SAVAGE4 is not set
# CONFIG_I2C_SIMTEC is not set
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_STUB=m
# CONFIG_I2C_TINY_USB is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set
# CONFIG_I2C_VOODOO3 is not set
# CONFIG_I2C_PCA_ISA is not set

#
# Miscellaneous I2C Chip support
#
# CONFIG_DS1682 is not set
CONFIG_SENSORS_EEPROM=m
# CONFIG_SENSORS_PCF8574 is not set
# CONFIG_PCF8575 is not set
# CONFIG_SENSORS_PCF8591 is not set
# CONFIG_TPS65010 is not set
# CONFIG_SENSORS_MAX6875 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_I2C_DEBUG_CHIP is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_BATTERY_DS2760 is not set
CONFIG_HWMON=m
# CONFIG_HWMON_VID is not set
# CONFIG_SENSORS_ABITUGURU is not set
# CONFIG_SENSORS_ABITUGURU3 is not set
# CONFIG_SENSORS_AD7418 is not set
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
# CONFIG_SENSORS_ADM1026 is not set
# CONFIG_SENSORS_ADM1029 is not set
# CONFIG_SENSORS_ADM1031 is not set
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7470 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_ASB100 is not set
# CONFIG_SENSORS_ATXP1 is not set
# CONFIG_SENSORS_DS1621 is not set
# CONFIG_SENSORS_I5K_AMB is not set
# CONFIG_SENSORS_F71805F is not set
# CONFIG_SENSORS_F71882FG is not set
# CONFIG_SENSORS_F75375S is not set
# CONFIG_SENSORS_FSCHER is not set
# CONFIG_SENSORS_FSCPOS is not set
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
# CONFIG_SENSORS_GL520SM is not set
# CONFIG_SENSORS_CORETEMP is not set
# CONFIG_SENSORS_IT87 is not set
# CONFIG_SENSORS_LM63 is not set
# CONFIG_SENSORS_LM75 is not set
# CONFIG_SENSORS_LM77 is not set
# CONFIG_SENSORS_LM78 is not set
# CONFIG_SENSORS_LM80 is not set
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=m
# CONFIG_SENSORS_LM92 is not set
# CONFIG_SENSORS_LM93 is not set
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX6650 is not set
# CONFIG_SENSORS_PC87360 is not set
# CONFIG_SENSORS_PC87427 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
# CONFIG_SENSORS_SMSC47B397 is not set
# CONFIG_SENSORS_ADS7828 is not set
# CONFIG_SENSORS_THMC50 is not set
# CONFIG_SENSORS_VIA686A is not set
# CONFIG_SENSORS_VT1211 is not set
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
# CONFIG_SENSORS_W83627EHF is not set
# CONFIG_SENSORS_HDAPS is not set
# CONFIG_SENSORS_APPLESMC is not set
# CONFIG_HWMON_DEBUG_CHIP is not set
CONFIG_THERMAL=y
CONFIG_WATCHDOG=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=m
# CONFIG_ACQUIRE_WDT is not set
# CONFIG_ADVANTECH_WDT is not set
CONFIG_ALIM1535_WDT=m
# CONFIG_ALIM7101_WDT is not set
# CONFIG_SC520_WDT is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
# CONFIG_IBMASR is not set
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_ITCO_WDT is not set
# CONFIG_IT8712F_WDT is not set
# CONFIG_SC1200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_SBC7240_WDT is not set
# CONFIG_CPU5_WDT is not set
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_W83627HF_WDT is not set
# CONFIG_W83697HF_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
# CONFIG_SBC_EPX_C3_WATCHDOG is not set

#
# ISA-based Watchdog Cards
#
# CONFIG_PCWATCHDOG is not set
# CONFIG_MIXCOMWD is not set
# CONFIG_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set

#
# Sonics Silicon Backplane
#
CONFIG_SSB_POSSIBLE=y
# CONFIG_SSB is not set

#
# Multifunction device drivers
#
# CONFIG_MFD_SM501 is not set

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set
# CONFIG_DVB_CORE is not set
# CONFIG_DAB is not set

#
# Graphics support
#
CONFIG_AGP=m
CONFIG_AGP_ALI=m
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
# CONFIG_AGP_AMD64 is not set
# CONFIG_AGP_INTEL is not set
# CONFIG_AGP_NVIDIA is not set
# CONFIG_AGP_SIS is not set
# CONFIG_AGP_SWORKS is not set
# CONFIG_AGP_VIA is not set
# CONFIG_AGP_EFFICEON is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=m
CONFIG_FB=y
CONFIG_FIRMWARE_EDID=y
# CONFIG_FB_DDC is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
# CONFIG_FB_SYS_FILLRECT is not set
# CONFIG_FB_SYS_COPYAREA is not set
# CONFIG_FB_SYS_IMAGEBLIT is not set
# CONFIG_FB_SYS_FOPS is not set
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
# CONFIG_FB_ARC is not set
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=m
CONFIG_FB_VESA=y
# CONFIG_FB_EFI is not set
# CONFIG_FB_HECUBA is not set
# CONFIG_FB_HGA is not set
# CONFIG_FB_S1D13XXX is not set
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I810 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_INTEL is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_CYBLA is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_VIRTUAL is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=m
CONFIG_BACKLIGHT_CLASS_DEVICE=m
# CONFIG_BACKLIGHT_CORGI is not set
# CONFIG_BACKLIGHT_PROGEAR is not set

#
# Display device support
#
# CONFIG_DISPLAY_SUPPORT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_VIDEO_SELECT=y
# CONFIG_MDA_CONSOLE is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_FRAMEBUFFER_CONSOLE_ROTATION is not set
CONFIG_FONTS=y
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_FONT_6x11 is not set
# CONFIG_FONT_7x14 is not set
# CONFIG_FONT_PEARL_8x8 is not set
# CONFIG_FONT_ACORN_8x8 is not set
# CONFIG_FONT_MINI_4x6 is not set
# CONFIG_FONT_SUN8x16 is not set
# CONFIG_FONT_SUN12x22 is not set
# CONFIG_FONT_10x18 is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
CONFIG_LOGO_LINUX_VGA16=y
CONFIG_LOGO_LINUX_CLUT224=y

#
# Sound
#
CONFIG_SOUND=m

#
# Advanced Linux Sound Architecture
#
CONFIG_SND=m
CONFIG_SND_TIMER=m
CONFIG_SND_PCM=m
CONFIG_SND_RAWMIDI=m
CONFIG_SND_SEQUENCER=m
CONFIG_SND_SEQ_DUMMY=m
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=m
CONFIG_SND_PCM_OSS=m
CONFIG_SND_PCM_OSS_PLUGINS=y
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
# CONFIG_SND_DEBUG is not set

#
# Generic devices
#
CONFIG_SND_MPU401_UART=m
CONFIG_SND_AC97_CODEC=m
CONFIG_SND_DUMMY=m
CONFIG_SND_VIRMIDI=m
CONFIG_SND_MTPAV=m
CONFIG_SND_SERIAL_U16550=m
CONFIG_SND_MPU401=m

#
# ISA devices
#
# CONFIG_SND_ADLIB is not set
# CONFIG_SND_AD1816A is not set
# CONFIG_SND_AD1848 is not set
# CONFIG_SND_ALS100 is not set
# CONFIG_SND_AZT2320 is not set
# CONFIG_SND_CMI8330 is not set
# CONFIG_SND_CS4231 is not set
# CONFIG_SND_CS4232 is not set
# CONFIG_SND_CS4236 is not set
# CONFIG_SND_DT019X is not set
# CONFIG_SND_ES968 is not set
# CONFIG_SND_ES1688 is not set
# CONFIG_SND_ES18XX is not set
# CONFIG_SND_SC6000 is not set
# CONFIG_SND_GUSCLASSIC is not set
# CONFIG_SND_GUSEXTREME is not set
# CONFIG_SND_GUSMAX is not set
# CONFIG_SND_INTERWAVE is not set
# CONFIG_SND_INTERWAVE_STB is not set
# CONFIG_SND_OPL3SA2 is not set
# CONFIG_SND_OPTI92X_AD1848 is not set
# CONFIG_SND_OPTI92X_CS4231 is not set
# CONFIG_SND_OPTI93X is not set
# CONFIG_SND_MIRO is not set
# CONFIG_SND_SB8 is not set
# CONFIG_SND_SB16 is not set
# CONFIG_SND_SBAWE is not set
# CONFIG_SND_SGALAXY is not set
# CONFIG_SND_SSCAPE is not set
# CONFIG_SND_WAVEFRONT is not set

#
# PCI devices
#
# CONFIG_SND_AD1889 is not set
# CONFIG_SND_ALS300 is not set
# CONFIG_SND_ALS4000 is not set
CONFIG_SND_ALI5451=m
# CONFIG_SND_ATIIXP is not set
# CONFIG_SND_ATIIXP_MODEM is not set
# CONFIG_SND_AU8810 is not set
# CONFIG_SND_AU8820 is not set
# CONFIG_SND_AU8830 is not set
# CONFIG_SND_AZT3328 is not set
# CONFIG_SND_BT87X is not set
# CONFIG_SND_CA0106 is not set
# CONFIG_SND_CMIPCI is not set
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_DARLA20 is not set
# CONFIG_SND_GINA20 is not set
# CONFIG_SND_LAYLA20 is not set
# CONFIG_SND_DARLA24 is not set
# CONFIG_SND_GINA24 is not set
# CONFIG_SND_LAYLA24 is not set
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
# CONFIG_SND_ECHO3G is not set
# CONFIG_SND_INDIGO is not set
# CONFIG_SND_INDIGOIO is not set
# CONFIG_SND_INDIGODJ is not set
# CONFIG_SND_EMU10K1 is not set
# CONFIG_SND_EMU10K1X is not set
# CONFIG_SND_ENS1370 is not set
# CONFIG_SND_ENS1371 is not set
# CONFIG_SND_ES1938 is not set
# CONFIG_SND_ES1968 is not set
# CONFIG_SND_FM801 is not set
# CONFIG_SND_HDA_INTEL is not set
# CONFIG_SND_HDSP is not set
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_HIFIER is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
# CONFIG_SND_INTEL8X0 is not set
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
# CONFIG_SND_MAESTRO3 is not set
# CONFIG_SND_MIXART is not set
# CONFIG_SND_NM256 is not set
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
# CONFIG_SND_RME32 is not set
# CONFIG_SND_RME96 is not set
# CONFIG_SND_RME9652 is not set
# CONFIG_SND_SIS7019 is not set
# CONFIG_SND_SONICVIBES is not set
# CONFIG_SND_TRIDENT is not set
# CONFIG_SND_VIA82XX is not set
# CONFIG_SND_VIA82XX_MODEM is not set
# CONFIG_SND_VIRTUOSO is not set
# CONFIG_SND_VX222 is not set
# CONFIG_SND_YMFPCI is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=60

#
# USB devices
#
# CONFIG_SND_USB_AUDIO is not set
# CONFIG_SND_USB_USX2Y is not set
# CONFIG_SND_USB_CAIAQ is not set

#
# PCMCIA devices
#
# CONFIG_SND_VXPOCKET is not set
# CONFIG_SND_PDAUDIOCF is not set

#
# System on Chip audio support
#
# CONFIG_SND_SOC is not set

#
# SoC Audio support for SuperH
#

#
# ALSA SoC audio for Freescale SOCs
#

#
# Open Sound System
#
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=m
CONFIG_HID_SUPPORT=y
CONFIG_HID=m
# CONFIG_HID_DEBUG is not set
# CONFIG_HIDRAW is not set

#
# USB Input Devices
#
CONFIG_USB_HID=m
# CONFIG_USB_HIDINPUT_POWERBOOK is not set
# CONFIG_HID_FF is not set
# CONFIG_USB_HIDDEV is not set

#
# USB HID Boot Protocol drivers
#
CONFIG_USB_KBD=m
CONFIG_USB_MOUSE=m
CONFIG_USB_SUPPORT=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB=m
# CONFIG_USB_DEBUG is not set
# CONFIG_USB_ANNOUNCE_NEW_DEVICES is not set

#
# Miscellaneous USB options
#
CONFIG_USB_DEVICEFS=y
# CONFIG_USB_DEVICE_CLASS is not set
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_SUSPEND=y
CONFIG_USB_PERSIST=y
# CONFIG_USB_OTG is not set

#
# USB Host Controller Drivers
#
# CONFIG_USB_EHCI_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
CONFIG_USB_OHCI_HCD=m
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_SL811_HCD is not set
# CONFIG_USB_R8A66597_HCD is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=m
CONFIG_USB_PRINTER=m

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# may also be needed; see USB_STORAGE Help for more information
#
CONFIG_USB_STORAGE=m
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
# CONFIG_USB_STORAGE_ISD200 is not set
CONFIG_USB_STORAGE_DPCM=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_KARMA=y
# CONFIG_USB_LIBUSUAL is not set

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
# CONFIG_USB_MICROTEK is not set
# CONFIG_USB_MON is not set

#
# USB port drivers
#
CONFIG_USB_SERIAL=m
# CONFIG_USB_EZUSB is not set
CONFIG_USB_SERIAL_GENERIC=y
# CONFIG_USB_SERIAL_AIRCABLE is not set
# CONFIG_USB_SERIAL_AIRPRIME is not set
# CONFIG_USB_SERIAL_ARK3116 is not set
# CONFIG_USB_SERIAL_BELKIN is not set
# CONFIG_USB_SERIAL_CH341 is not set
# CONFIG_USB_SERIAL_WHITEHEAT is not set
# CONFIG_USB_SERIAL_DIGI_ACCELEPORT is not set
# CONFIG_USB_SERIAL_CP2101 is not set
# CONFIG_USB_SERIAL_CYPRESS_M8 is not set
# CONFIG_USB_SERIAL_EMPEG is not set
# CONFIG_USB_SERIAL_FTDI_SIO is not set
# CONFIG_USB_SERIAL_FUNSOFT is not set
# CONFIG_USB_SERIAL_VISOR is not set
# CONFIG_USB_SERIAL_IPAQ is not set
# CONFIG_USB_SERIAL_IR is not set
# CONFIG_USB_SERIAL_EDGEPORT is not set
# CONFIG_USB_SERIAL_EDGEPORT_TI is not set
# CONFIG_USB_SERIAL_GARMIN is not set
# CONFIG_USB_SERIAL_IPW is not set
# CONFIG_USB_SERIAL_IUU is not set
# CONFIG_USB_SERIAL_KEYSPAN_PDA is not set
# CONFIG_USB_SERIAL_KEYSPAN is not set
# CONFIG_USB_SERIAL_KLSI is not set
# CONFIG_USB_SERIAL_KOBIL_SCT is not set
# CONFIG_USB_SERIAL_MCT_U232 is not set
# CONFIG_USB_SERIAL_MOS7720 is not set
# CONFIG_USB_SERIAL_MOS7840 is not set
# CONFIG_USB_SERIAL_NAVMAN is not set
CONFIG_USB_SERIAL_PL2303=m
# CONFIG_USB_SERIAL_OTI6858 is not set
# CONFIG_USB_SERIAL_HP4X is not set
# CONFIG_USB_SERIAL_SAFE is not set
# CONFIG_USB_SERIAL_SIERRAWIRELESS is not set
# CONFIG_USB_SERIAL_TI is not set
# CONFIG_USB_SERIAL_CYBERJACK is not set
# CONFIG_USB_SERIAL_XIRCOM is not set
# CONFIG_USB_SERIAL_OPTION is not set
# CONFIG_USB_SERIAL_OMNINET is not set
# CONFIG_USB_SERIAL_DEBUG is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
# CONFIG_USB_EMI26 is not set
# CONFIG_USB_ADUTUX is not set
# CONFIG_USB_AUERSWALD is not set
# CONFIG_USB_RIO500 is not set
# CONFIG_USB_LEGOTOWER is not set
# CONFIG_USB_LCD is not set
# CONFIG_USB_BERRY_CHARGE is not set
# CONFIG_USB_LED is not set
# CONFIG_USB_CYPRESS_CY7C63 is not set
# CONFIG_USB_CYTHERM is not set
# CONFIG_USB_PHIDGET is not set
# CONFIG_USB_IDMOUSE is not set
# CONFIG_USB_FTDI_ELAN is not set
# CONFIG_USB_APPLEDISPLAY is not set
# CONFIG_USB_LD is not set
# CONFIG_USB_TRANCEVIBRATOR is not set
# CONFIG_USB_IOWARRIOR is not set
# CONFIG_USB_TEST is not set
# CONFIG_USB_GADGET is not set
# CONFIG_MMC is not set
# CONFIG_MEMSTICK is not set
# CONFIG_NEW_LEDS is not set
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=m
CONFIG_RTC_CLASS=m

#
# Conflicting RTC option has been selected, check GEN_RTC and RTC
#

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
# CONFIG_RTC_INTF_PROC is not set
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
# CONFIG_RTC_DRV_TEST is not set

#
# I2C RTC drivers
#
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
# CONFIG_RTC_DRV_DS1672 is not set
# CONFIG_RTC_DRV_MAX6900 is not set
# CONFIG_RTC_DRV_RS5C372 is not set
# CONFIG_RTC_DRV_ISL1208 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF8563 is not set
# CONFIG_RTC_DRV_PCF8583 is not set
# CONFIG_RTC_DRV_M41T80 is not set

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=m
# CONFIG_RTC_DRV_DS1511 is not set
# CONFIG_RTC_DRV_DS1553 is not set
# CONFIG_RTC_DRV_DS1742 is not set
# CONFIG_RTC_DRV_STK17TA8 is not set
# CONFIG_RTC_DRV_M48T86 is not set
# CONFIG_RTC_DRV_M48T59 is not set
# CONFIG_RTC_DRV_V3020 is not set

#
# on-CPU RTC drivers
#
# CONFIG_DMADEVICES is not set

#
# Userspace I/O
#
# CONFIG_UIO is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_DMIID=y

#
# File systems
#
CONFIG_EXT2_FS=m
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=m
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
# CONFIG_EXT4DEV_FS is not set
CONFIG_JBD=m
# CONFIG_JBD_DEBUG is not set
CONFIG_FS_MBCACHE=m
CONFIG_REISERFS_FS=m
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_PROC_INFO=y
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
CONFIG_FS_POSIX_ACL=y
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
CONFIG_DNOTIFY=y
CONFIG_INOTIFY=y
CONFIG_INOTIFY_USER=y
# CONFIG_QUOTA is not set
# CONFIG_AUTOFS_FS is not set
CONFIG_AUTOFS4_FS=m
CONFIG_FUSE_FS=m
CONFIG_GENERIC_ACL=y

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=m
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=866
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=m
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=m

#
# Miscellaneous filesystems
#
# CONFIG_ADFS_FS is not set
# CONFIG_AFFS_FS is not set
# CONFIG_ECRYPT_FS is not set
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
# CONFIG_BEFS_FS is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
# CONFIG_CRAMFS is not set
CONFIG_SQUASHFS=m
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
# CONFIG_SQUASHFS_VMALLOC is not set
# CONFIG_VXFS_FS is not set
# CONFIG_MINIX_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_ROMFS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_LOCKD=m
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=m
CONFIG_SUNRPC_GSS=m
# CONFIG_SUNRPC_BIND34 is not set
CONFIG_RPCSEC_GSS_KRB5=m
# CONFIG_RPCSEC_GSS_SPKM3 is not set
# CONFIG_SMB_FS is not set
CONFIG_CIFS=m
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_XATTR is not set
# CONFIG_CIFS_DEBUG2 is not set
# CONFIG_CIFS_EXPERIMENTAL is not set
# CONFIG_NCP_FS is not set
CONFIG_CODA_FS=m
# CONFIG_CODA_FS_OLD_API is not set
# CONFIG_AFS_FS is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
# CONFIG_AMIGA_PARTITION is not set
# CONFIG_ATARI_PARTITION is not set
# CONFIG_MAC_PARTITION is not set
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
# CONFIG_MINIX_SUBPARTITION is not set
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
# CONFIG_SGI_PARTITION is not set
# CONFIG_ULTRIX_PARTITION is not set
# CONFIG_SUN_PARTITION is not set
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=m
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=m
# CONFIG_NLS_CODEPAGE_850 is not set
# CONFIG_NLS_CODEPAGE_852 is not set
CONFIG_NLS_CODEPAGE_855=m
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
CONFIG_NLS_CODEPAGE_866=m
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=m
CONFIG_NLS_ASCII=m
CONFIG_NLS_ISO8859_1=m
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=m
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=m
CONFIG_NLS_KOI8_R=m
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_UTF8=m
# CONFIG_DLM is not set

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_MAGIC_SYSRQ=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_DETECT_SOFTLOCKUP=y
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
# CONFIG_SLUB_DEBUG_ON is not set
# CONFIG_SLUB_STATS is not set
# CONFIG_DEBUG_RT_MUTEXES is not set
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_SPINLOCK_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_KPROBES_SANITY_TEST is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_LKDTM is not set
# CONFIG_FAULT_INJECTION is not set
CONFIG_LATENCYTOP=y
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_SAMPLES is not set
# CONFIG_EARLY_PRINTK is not set
CONFIG_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACK_USAGE is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_DEBUG_RODATA=y
# CONFIG_DEBUG_RODATA_TEST is not set
# CONFIG_DEBUG_NX_TEST is not set
# CONFIG_4KSTACKS is not set
CONFIG_DOUBLEFAULT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set

#
# Security options
#
CONFIG_KEYS=y
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY is not set
# CONFIG_SECURITY_FILE_CAPABILITIES is not set
CONFIG_XOR_BLOCKS=m
CONFIG_ASYNC_CORE=m
CONFIG_ASYNC_MEMCPY=m
CONFIG_ASYNC_XOR=m
CONFIG_CRYPTO=y
CONFIG_CRYPTO_ALGAPI=m
CONFIG_CRYPTO_AEAD=m
CONFIG_CRYPTO_BLKCIPHER=m
CONFIG_CRYPTO_SEQIV=m
CONFIG_CRYPTO_HASH=m
CONFIG_CRYPTO_MANAGER=m
CONFIG_CRYPTO_HMAC=m
CONFIG_CRYPTO_XCBC=m
CONFIG_CRYPTO_NULL=m
CONFIG_CRYPTO_MD4=m
CONFIG_CRYPTO_MD5=m
CONFIG_CRYPTO_SHA1=m
CONFIG_CRYPTO_SHA256=m
CONFIG_CRYPTO_SHA512=m
CONFIG_CRYPTO_WP512=m
CONFIG_CRYPTO_TGR192=m
CONFIG_CRYPTO_GF128MUL=m
CONFIG_CRYPTO_ECB=m
CONFIG_CRYPTO_CBC=m
CONFIG_CRYPTO_PCBC=m
CONFIG_CRYPTO_LRW=m
CONFIG_CRYPTO_XTS=m
CONFIG_CRYPTO_CTR=m
CONFIG_CRYPTO_GCM=m
CONFIG_CRYPTO_CCM=m
# CONFIG_CRYPTO_CRYPTD is not set
CONFIG_CRYPTO_DES=m
CONFIG_CRYPTO_FCRYPT=m
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_TWOFISH_COMMON=m
CONFIG_CRYPTO_TWOFISH_586=m
CONFIG_CRYPTO_SERPENT=m
CONFIG_CRYPTO_AES=m
CONFIG_CRYPTO_AES_586=m
CONFIG_CRYPTO_CAST5=m
CONFIG_CRYPTO_CAST6=m
CONFIG_CRYPTO_TEA=m
CONFIG_CRYPTO_ARC4=m
CONFIG_CRYPTO_KHAZAD=m
CONFIG_CRYPTO_ANUBIS=m
CONFIG_CRYPTO_SEED=m
CONFIG_CRYPTO_SALSA20=m
CONFIG_CRYPTO_SALSA20_586=m
CONFIG_CRYPTO_DEFLATE=m
CONFIG_CRYPTO_MICHAEL_MIC=m
CONFIG_CRYPTO_CRC32C=m
CONFIG_CRYPTO_CAMELLIA=m
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_AUTHENC=m
CONFIG_CRYPTO_LZO=m
# CONFIG_CRYPTO_HW is not set
CONFIG_HAVE_KVM=y
# CONFIG_VIRTUALIZATION is not set

#
# Library routines
#
CONFIG_BITREVERSE=y
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
# CONFIG_CRC_ITU_T is not set
CONFIG_CRC32=y
CONFIG_CRC7=m
CONFIG_LIBCRC32C=m
CONFIG_AUDIT_GENERIC=y
CONFIG_ZLIB_INFLATE=m
CONFIG_ZLIB_DEFLATE=m
CONFIG_LZO_COMPRESS=m
CONFIG_LZO_DECOMPRESS=m
CONFIG_PLIST=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y

--Boundary-01=_jpCuHP3cXYHHfIx--

--nextPart2199787.zNLJxBX1q2
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.8 (GNU/Linux)

iEYEABECAAYFAke4KmMACgkQR6LMutpd94y3ngCgi4deXuw1kE5xmOKk8XZwLmmQ
AYMAoICz+rrTyBK1LXGZ9A6G6BHzhSsz
=K3bu
-----END PGP SIGNATURE-----

--nextPart2199787.zNLJxBX1q2--
