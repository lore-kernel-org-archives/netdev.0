From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [iwlwifi] BUG: unable to handle kernel
Date: Thu, 18 Dec 2014 09:13:09 -0800
Message-ID: <20141218171309.GD9298@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="JYK4vJDZwFMowpUq"
Cc: LKP <lkp@01.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-leds@vger.kernel.org
To: Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <linux-leds-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-leds-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi All,

I don't see any relationship between the BUG and this bisected commit.
Anyway, it's better to report it to the lists than to ignore.

git://git.kernel.org/pub/scm/linux/kernel/git/iwlwifi/iwlwifi-fixes.git master

commit 03d6c3b0fa4f5f0379cede079ec828a6c999fe43
Author:     Emmanuel Grumbach <emmanuel.grumbach@intel.com>
AuthorDate: Wed Dec 3 10:39:07 2014 +0200
Commit:     Emmanuel Grumbach <emmanuel.grumbach@intel.com>
CommitDate: Sun Dec 14 10:20:29 2014 +0200

    iwlwifi: pcie: re-ACK all interrupts after device reset
    
    When we reset the device, the CSR_INT gets cleared as well
    as CSR_INT_MASK. Meaning that we shouldn't get any interrupt
    but, due to a hardware bug, recent devices will keep sending
    interrupts. This leads to an interrupt storm while stopping
    the device.
    The way to fix this is to ACK all the interrupts after the
    device is reset so that the value of CSR_INT will stay
    0xffffffff.
    
    Fixes: 522713c81e4e ("iwlwifi: pcie: properly reset the device")
    Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach@intel.com>

+------------------------------------------+------------+------------+------------+
|                                          | 0a79a0c011 | 03d6c3b0fa | iwlwifi-fi |
+------------------------------------------+------------+------------+------------+
| boot_successes                           | 60         | 19         | 3          |
| boot_failures                            | 0          | 1          | 9          |
| BUG:unable_to_handle_kernel              | 0          | 1          | 9          |
| Oops                                     | 0          | 1          | 9          |
| RIP:strcmp                               | 0          | 1          | 9          |
| Kernel_panic-not_syncing:Fatal_exception | 0          | 1          | 9          |
| backtrace:led_trigger_register_simple    | 0          | 1          | 9          |
| backtrace:ledtrig_usb_init               | 0          | 1          | 9          |
| backtrace:kernel_init_freeable           | 0          | 1          | 9          |
+------------------------------------------+------------+------------+------------+

[    5.345018] g_serial gadget: Gadget Serial v2.4
[    5.345927] g_serial gadget: g_serial ready
[    5.345927] g_serial gadget: g_serial ready
[    5.346777] BUG: unable to handle kernel 
[    5.346777] BUG: unable to handle kernel paging requestpaging request at ffff88000004e5f0
 at ffff88000004e5f0
[    5.348183] IP:
[    5.348183] IP: [<ffffffff81446a68>] strcmp+0x6/0x20
 [<ffffffff81446a68>] strcmp+0x6/0x20
[    5.349183] PGD 37f1067 
[    5.349183] PGD 37f1067 PUD 37f2067 PUD 37f2067 PMD 37f3067 PMD 37f3067 PTE 800000000004e060PTE 800000000004e060

[    5.350498] Oops: 0000 [#1] 
[    5.350498] Oops: 0000 [#1] DEBUG_PAGEALLOCDEBUG_PAGEALLOC

[    5.351360] CPU: 0 PID: 1 Comm: swapper Not tainted 3.18.0-g03d6c3b #1
[    5.351360] CPU: 0 PID: 1 Comm: swapper Not tainted 3.18.0-g03d6c3b #1
[    5.352660] task: ffff880012060000 ti: ffff88001204c000 task.ti: ffff88001204c000
[    5.352660] task: ffff880012060000 ti: ffff88001204c000 task.ti: ffff88001204c000
[    5.354143] RIP: 0010:[<ffffffff81446a68>] 
[    5.354143] RIP: 0010:[<ffffffff81446a68>]  [<ffffffff81446a68>] strcmp+0x6/0x20
 [<ffffffff81446a68>] strcmp+0x6/0x20
[    5.354451] RSP: 0000:ffff88001204fe28  EFLAGS: 00010246
[    5.354451] RSP: 0000:ffff88001204fe28  EFLAGS: 00010246
[    5.354451] RAX: 0000000000000000 RBX: ffff88000c08fe00 RCX: ffffffff81d35310
[    5.354451] RAX: 0000000000000000 RBX: ffff88000c08fe00 RCX: ffffffff81d35310
[    5.354451] RDX: ffff88000c08fe68 RSI: ffffffff826d05be RDI: ffff88000004e5f0
[    5.354451] RDX: ffff88000c08fe68 RSI: ffffffff826d05be RDI: ffff88000004e5f0
[    5.354451] RBP: ffff88001204fe28 R08: 0000000000000001 R09: 000000000000033a
[    5.354451] RBP: ffff88001204fe28 R08: 0000000000000001 R09: 000000000000033a
[    5.354451] R10: 0000000000000000 R11: ffffffff82531cd1 R12: ffff88000c19fa00
[    5.354451] R10: 0000000000000000 R11: ffffffff82531cd1 R12: ffff88000c19fa00
[    5.354451] R13: 0000000000000000 R14: ffffffff837958b8 R15: 0000000000000000
[    5.354451] R13: 0000000000000000 R14: ffffffff837958b8 R15: 0000000000000000
[    5.354451] FS:  0000000000000000(0000) GS:ffffffff82789000(0000) knlGS:0000000000000000
[    5.354451] FS:  0000000000000000(0000) GS:ffffffff82789000(0000) knlGS:0000000000000000
[    5.354451] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    5.354451] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    5.354451] CR2: ffff88000004e5f0 CR3: 0000000002776000 CR4: 00000000000006b0
[    5.354451] CR2: ffff88000004e5f0 CR3: 0000000002776000 CR4: 00000000000006b0
[    5.354451] Stack:
[    5.354451] Stack:
[    5.354451]  ffff88001204fe58
[    5.354451]  ffff88001204fe58 ffffffff81d35334 ffffffff81d35334 0000000000000000 0000000000000000 ffff88000c19fa00 ffff88000c19fa00

[    5.354451]  ffffffff826d05be
[    5.354451]  ffffffff826d05be 0000000000000000 0000000000000000 ffff88001204fe88 ffff88001204fe88 ffffffff81d35648 ffffffff81d35648

[    5.354451]  ffff88000e3bbcc0
[    5.354451]  ffff88000e3bbcc0 ffffffff82b3fe61 ffffffff82b3fe61 0000000000000000 0000000000000000 ffffffff82b98910 ffffffff82b98910

[    5.354451] Call Trace:
[    5.354451] Call Trace:
[    5.354451]  [<ffffffff81d35334>] led_trigger_register+0x63/0x129
[    5.354451]  [<ffffffff81d35334>] led_trigger_register+0x63/0x129
[    5.354451]  [<ffffffff81d35648>] led_trigger_register_simple+0x35/0x79
[    5.354451]  [<ffffffff81d35648>] led_trigger_register_simple+0x35/0x79
[    5.354451]  [<ffffffff82b3fe61>] ? gs_bind+0xea/0xea
[    5.354451]  [<ffffffff82b3fe61>] ? gs_bind+0xea/0xea
[    5.354451]  [<ffffffff82b3fe78>] ledtrig_usb_init+0x17/0x2e
[    5.354451]  [<ffffffff82b3fe78>] ledtrig_usb_init+0x17/0x2e
[    5.354451]  [<ffffffff82b00044>] do_one_initcall+0xe6/0x171
[    5.354451]  [<ffffffff82b00044>] do_one_initcall+0xe6/0x171
[    5.354451]  [<ffffffff82b001c7>] kernel_init_freeable+0xf8/0x180
[    5.354451]  [<ffffffff82b001c7>] kernel_init_freeable+0xf8/0x180
[    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
[    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
[    5.354451]  [<ffffffff8206079a>] kernel_init+0x9/0xd0
[    5.354451]  [<ffffffff8206079a>] kernel_init+0x9/0xd0
[    5.354451]  [<ffffffff8207d2ba>] ret_from_fork+0x7a/0xb0
[    5.354451]  [<ffffffff8207d2ba>] ret_from_fork+0x7a/0xb0
[    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
[    5.354451]  [<ffffffff82060791>] ? rest_init+0xbd/0xbd
[    5.354451] Code: 
[    5.354451] Code: c0 c0 eb eb f5 f5 31 31 c9 c9 40 40 8a 8a 3c 3c 0e 0e 4d 4d 8d 8d 0c 0c 08 08 40 40 84 84 ff ff 41 41 88 88 3c 3c 08 08 74 74 0d 0d 48 48 ff ff c1 c1 48 48 39 39 ca ca 75 75 e7 e7 41 41 c6 c6 41 41 01 01 00 00 5d 5d c3 c3 55 55 31 31 c0 c0 48 48 89 89 e5 e5 <8a> <8a> 14 14 07 07 3a 3a 14 14 06 06 74 74 07 07 19 19 c0 c0 83 83 c8 c8 01 01 eb eb 09 09 48 48 ff ff c0 c0 84 84 d2 d2 75 75 

[    5.354451] RIP 
[    5.354451] RIP  [<ffffffff81446a68>] strcmp+0x6/0x20
 [<ffffffff81446a68>] strcmp+0x6/0x20
[    5.354451]  RSP <ffff88001204fe28>
[    5.354451]  RSP <ffff88001204fe28>
[    5.354451] CR2: ffff88000004e5f0
[    5.354451] CR2: ffff88000004e5f0
[    5.354451] ---[ end trace 8f9377b34c860a0c ]---
[    5.354451] ---[ end trace 8f9377b34c860a0c ]---

git bisect start baa21e834941ee5fbe4bd421c871f7c0c5f9a086 70e71ca0af244f48a5dcf56dc435243792e3a495 --
git bisect  bad 03d6c3b0fa4f5f0379cede079ec828a6c999fe43  # 16:23      0-      1  iwlwifi: pcie: re-ACK all interrupts after device reset
git bisect good 0a79a0c011cb291675e3b80760a452fcba5c59d9  # 16:28     20+      0  iwlwifi: mvm: clear IN_HW_RESTART flag on stop()
# first bad commit: [03d6c3b0fa4f5f0379cede079ec828a6c999fe43] iwlwifi: pcie: re-ACK all interrupts after device reset
git bisect good 0a79a0c011cb291675e3b80760a452fcba5c59d9  # 16:30     60+      0  iwlwifi: mvm: clear IN_HW_RESTART flag on stop()
# extra tests on HEAD of iwlwifi-fixes/master
git bisect  bad baa21e834941ee5fbe4bd421c871f7c0c5f9a086  # 16:30      0-      9  iwlwifi: pcie: limit fw chunk sizes given to fh
# extra tests on tree/branch iwlwifi-fixes/master
git bisect  bad baa21e834941ee5fbe4bd421c871f7c0c5f9a086  # 16:30      0-      9  iwlwifi: pcie: limit fw chunk sizes given to fh
# extra tests on tree/branch linus/master
git bisect good 44e8967d591686463e84a88b46b03beba3ab49fb  # 16:32     60+      0  Ceph: remove left-over reject file
# extra tests on tree/branch next/master
git bisect good cfaa3a95dd2b402599b1d8122dc3107478db8717  # 16:35     60+      1  Add linux-next specific files for 20141218


This script may reproduce the error.

----------------------------------------------------------------------------
#!/bin/bash

kernel=$1
initrd=quantal-core-x86_64.cgz

wget --no-clobber https://github.com/fengguang/reproduce-kernel-bug/raw/master/initrd/$initrd

kvm=(
	qemu-system-x86_64
	-cpu kvm64
	-enable-kvm
	-kernel $kernel
	-initrd $initrd
	-m 320
	-smp 2
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-rtc base=localtime
	-serial stdio
	-display none
	-monitor null 
)

append=(
	hung_task_panic=1
	earlyprintk=ttyS0,115200
	debug
	apic=debug
	sysrq_always_enabled
	rcupdate.rcu_cpu_stall_timeout=100
	panic=-1
	softlockup_panic=1
	nmi_watchdog=panic
	oops=panic
	load_ramdisk=2
	prompt_ramdisk=0
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
	drbd.minor_count=8
)

"${kvm[@]}" --append "${append[*]}"
----------------------------------------------------------------------------

Thanks,
Fengguang

--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-client7-20:20141218162251:x86_64-randconfig-n0-12110707:3.18.0-g03d6c3b:1"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-g03d6c3b (kbuild@lkp-nhm1) (gcc version=
 4.9.1 (Debian 4.9.1-19) ) #1 Thu Dec 18 16:19:30 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-n0-12110707/iwlwifi-fixes:master:03d6c3b0fa4f5f0379cede079ec828a6c999f=
e43:bisect-linux-1/.vmlinuz-03d6c3b0fa4f5f0379cede079ec828a6c999fe43-201412=
18161947-16-client7 branch=3Diwlwifi-fixes/master BOOT_IMAGE=3D/kernel/x86_=
64-randconfig-n0-12110707/03d6c3b0fa4f5f0379cede079ec828a6c999fe43/vmlinuz-=
3.18.0-g03d6c3b drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[ffff8800000f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x037f1000, 0x037f1fff] PGTABLE
[    0.000000] BRK [0x037f2000, 0x037f2fff] PGTABLE
[    0.000000] BRK [0x037f3000, 0x037f3fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x037f4000, 0x037f4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x037f5000, 0x037f5fff] PGTABLE
[    0.000000] BRK [0x037f6000, 0x037f6fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13fdffff] page 4k
[    0.000000] RAMDISK: [mem 0x12925000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13fdffff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13fdffff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 27906c0
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-n0-12110707/iwlwifi-fixes:master:03d6c3b0fa4f5f0379cede079ec828=
a6c999fe43:bisect-linux-1/.vmlinuz-03d6c3b0fa4f5f0379cede079ec828a6c999fe43=
-20141218161947-16-client7 branch=3Diwlwifi-fixes/master BOOT_IMAGE=3D/kern=
el/x86_64-randconfig-n0-12110707/03d6c3b0fa4f5f0379cede079ec828a6c999fe43/v=
mlinuz-3.18.0-g03d6c3b drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 255256K/327160K available (16893K kernel code, 3681K=
 rwdata, 7056K rodata, 888K init, 12368K bss, 71904K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 0
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.18.0-g03d6c3b (kbuild@lkp-nhm1) (gcc version=
 4.9.1 (Debian 4.9.1-19) ) #1 Thu Dec 18 16:19:30 CST 2014
[    0.000000] Command line: hung_task_panic=3D1 earlyprintk=3DttyS0,115200=
 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D1=
00 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic load_r=
amdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dn=
ormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64-randco=
nfig-n0-12110707/iwlwifi-fixes:master:03d6c3b0fa4f5f0379cede079ec828a6c999f=
e43:bisect-linux-1/.vmlinuz-03d6c3b0fa4f5f0379cede079ec828a6c999fe43-201412=
18161947-16-client7 branch=3Diwlwifi-fixes/master BOOT_IMAGE=3D/kernel/x86_=
64-randconfig-n0-12110707/03d6c3b0fa4f5f0379cede079ec828a6c999fe43/vmlinuz-=
3.18.0-g03d6c3b drbd.minor_count=3D8
[    0.000000] KERNEL supported cpus:
[    0.000000]   Centaur CentaurHauls
[    0.000000] CPU: vendor_id 'GenuineIntel' unknown, using generic init.
[    0.000000] CPU: Your system may be unstable.
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013fdffff] usable
[    0.000000] BIOS-e820: [mem 0x0000000013fe0000-0x0000000013ffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13fe0 max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 0080000000 mask FF80000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f0eb0-0x000f0ebf] mapped at =
[ffff8800000f0eb0]
[    0.000000]   mpc: f0ec0-f0fa4
[    0.000000] Scanning 1 areas for low memory corruption
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x037f1000, 0x037f1fff] PGTABLE
[    0.000000] BRK [0x037f2000, 0x037f2fff] PGTABLE
[    0.000000] BRK [0x037f3000, 0x037f3fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x12600000-0x127fffff]
[    0.000000]  [mem 0x12600000-0x127fffff] page 4k
[    0.000000] BRK [0x037f4000, 0x037f4fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x10000000-0x125fffff]
[    0.000000]  [mem 0x10000000-0x125fffff] page 4k
[    0.000000] BRK [0x037f5000, 0x037f5fff] PGTABLE
[    0.000000] BRK [0x037f6000, 0x037f6fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x0fffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12800000-0x13fdffff]
[    0.000000]  [mem 0x12800000-0x13fdffff] page 4k
[    0.000000] RAMDISK: [mem 0x12925000-0x13fd7fff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000F0C90 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0000000013FE18BD 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x0000000013FE0B37 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x0000000013FE0040 000AF7 (v01 BOCHS  BXPCDSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACS 0x0000000013FE0000 000040
[    0.000000] ACPI: SSDT 0x0000000013FE0BAB 000C5A (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x0000000013FE1805 000080 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x0000000013FE1885 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13fdf001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13fdffff]
[    0.000000] Initmem setup node 0 [mem 0x00001000-0x13fdffff]
[    0.000000] On node 0 totalpages: 81790
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1216 pages used for memmap
[    0.000000]   DMA32 zone: 77792 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0x608
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, APIC =
INT 01
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5fb000 (fec00000)
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 27906c0
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 80489
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_time=
out=3D100 panic=3D-1 softlockup_panic=3D1 nmi_watchdog=3Dpanic oops=3Dpanic=
 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 =
vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/x86_64=
-randconfig-n0-12110707/iwlwifi-fixes:master:03d6c3b0fa4f5f0379cede079ec828=
a6c999fe43:bisect-linux-1/.vmlinuz-03d6c3b0fa4f5f0379cede079ec828a6c999fe43=
-20141218161947-16-client7 branch=3Diwlwifi-fixes/master BOOT_IMAGE=3D/kern=
el/x86_64-randconfig-n0-12110707/03d6c3b0fa4f5f0379cede079ec828a6c999fe43/v=
mlinuz-3.18.0-g03d6c3b drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.000000] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.000000] Memory: 255256K/327160K available (16893K kernel code, 3681K=
 rwdata, 7056K rodata, 888K init, 12368K bss, 71904K reserved)
[    0.000000] SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D1, N=
odes=3D1
[    0.000000] NR_IRQS:4352 nr_irqs:256 0
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... MAX_LOCKDEP_CHAINS:      65536
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000] ... CHAINHASH_SIZE:          32768
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  memory used by lock dependency info: 8639 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|faile=
d|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |failed|failed|

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |failed|failed|             |             |failed|failed|

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|faile=
d|  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/123:
[    0.000000]       hard-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/123:
[    0.000000]       soft-irq read-recursion/123:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/132:
[    0.000000]       hard-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/132:
[    0.000000]       soft-irq read-recursion/132:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/213:
[    0.000000]       hard-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/213:
[    0.000000]       soft-irq read-recursion/213:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/231:
[    0.000000]       hard-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/231:
[    0.000000]       soft-irq read-recursion/231:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/312:
[    0.000000]       hard-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/312:
[    0.000000]       soft-irq read-recursion/312:  ok  |  ok  |

[    0.000000]       hard-irq read-recursion/321:
[    0.000000]       hard-irq read-recursion/321:  ok  |  ok  |

[    0.000000]       soft-irq read-recursion/321:
[    0.000000]       soft-irq read-recursion/321:  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:failed|failed|  ok  |  ok =
 |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:failed|failed|  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                             block:
[    0.000000]                             block:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:failed|failed|  ok  |  ok =
 |failed|failed|

[    0.000000] --------------------------------------------------------
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ----------------------------------------------------
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.000000] tsc: Detected 2925.998 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5851.99 Bogo=
MIPS (lpj=3D29259980)
5851.99 BogoMIPS (lpj=3D29259980)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] ACPI: Core revision 20141107
[    0.020000] ACPI: Core revision 20141107
[    0.020000] ACPI:=20
[    0.020000] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.020147] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.020147] Mount-cache hash table entries: 1024 (order: 1, 8192 bytes)
[    0.021733] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.021733] Mountpoint-cache hash table entries: 1024 (order: 1, 8192 by=
tes)
[    0.023647] Initializing cgroup subsys net_cls
[    0.023647] Initializing cgroup subsys net_cls
[    0.024739] Initializing cgroup subsys blkio
[    0.024739] Initializing cgroup subsys blkio
[    0.025770] Initializing cgroup subsys perf_event
[    0.025770] Initializing cgroup subsys perf_event
[    0.026911] Initializing cgroup subsys hugetlb
[    0.026911] Initializing cgroup subsys hugetlb
[    0.028031] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.028031] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.028031] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.028031] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.030006] CPU:=20
[    0.030006] CPU: GenuineIntel GenuineIntel Common KVM processorCommon KV=
M processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.034676] Performance Events:=20
[    0.034676] Performance Events: no PMU driver, software events only.
no PMU driver, software events only.
[    0.035981] Getting VERSION: 1050014
[    0.035981] Getting VERSION: 1050014
[    0.036592] Getting VERSION: 1050014
[    0.036592] Getting VERSION: 1050014
[    0.037212] Getting ID: 0
[    0.037212] Getting ID: 0
[    0.037680] Getting ID: ff000000
[    0.037680] Getting ID: ff000000
[    0.038238] Getting LVT0: 8700
[    0.038238] Getting LVT0: 8700
[    0.038776] Getting LVT1: 8400
[    0.038776] Getting LVT1: 8400
[    0.040047] enabled ExtINT on CPU#0
[    0.040047] enabled ExtINT on CPU#0
[    0.041278] ENABLING IO-APIC IRQs
[    0.041278] ENABLING IO-APIC IRQs
[    0.041860] init IO_APIC IRQs
[    0.041860] init IO_APIC IRQs
[    0.042379]  apic 0 pin 0 not connected
[    0.042379]  apic 0 pin 0 not connected
[    0.043032] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.043032] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.044379] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.044379] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.045727] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.045727] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.047070] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.047070] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.048425] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.048425] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.050021] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.050021] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.051345] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.051345] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.052667] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.052667] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.053990] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.053990] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.055315] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.055315] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.056647] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.056647] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.057990] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.057990] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.059344] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.059344] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.060021] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.060021] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.061389] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.061389] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.062756] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.062756] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.064119]  apic 0 pin 16 not connected
[    0.064119]  apic 0 pin 16 not connected
[    0.064782]  apic 0 pin 17 not connected
[    0.064782]  apic 0 pin 17 not connected
[    0.065436]  apic 0 pin 18 not connected
[    0.065436]  apic 0 pin 18 not connected
[    0.066100]  apic 0 pin 19 not connected
[    0.066100]  apic 0 pin 19 not connected
[    0.066760]  apic 0 pin 20 not connected
[    0.066760]  apic 0 pin 20 not connected
[    0.067416]  apic 0 pin 21 not connected
[    0.067416]  apic 0 pin 21 not connected
[    0.068075]  apic 0 pin 22 not connected
[    0.068075]  apic 0 pin 22 not connected
[    0.068732]  apic 0 pin 23 not connected
[    0.068732]  apic 0 pin 23 not connected
[    0.070148] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.070148] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.071387] Using local APIC timer interrupts.
[    0.071387] calibrating APIC timer ...
[    0.071387] Using local APIC timer interrupts.
[    0.071387] calibrating APIC timer ...
[    0.080000] ... lapic delta =3D 6250518
[    0.080000] ... lapic delta =3D 6250518
[    0.080000] ... PM-Timer delta =3D 357989
[    0.080000] ... PM-Timer delta =3D 357989
[    0.080000] ... PM-Timer result ok
[    0.080000] ... PM-Timer result ok
[    0.080000] ..... delta 6250518
[    0.080000] ..... delta 6250518
[    0.080000] ..... mult: 268457703
[    0.080000] ..... mult: 268457703
[    0.080000] ..... calibration result: 10000828
[    0.080000] ..... calibration result: 10000828
[    0.080000] ..... CPU clock speed is 2926.2818 MHz.
[    0.080000] ..... CPU clock speed is 2926.2818 MHz.
[    0.080000] ..... host bus clock speed is 1000.0828 MHz.
[    0.080000] ..... host bus clock speed is 1000.0828 MHz.
[    0.080000] prandom: seed boundary self test passed
[    0.080000] prandom: seed boundary self test passed
[    0.080000] prandom: 100 self tests passed
[    0.080000] prandom: 100 self tests passed
[    0.080000] regulator-dummy: no parameters
[    0.080000] regulator-dummy: no parameters
[    0.080000] NET: Registered protocol family 16
[    0.080000] NET: Registered protocol family 16
[    0.080000] cpuidle: using governor ladder
[    0.080000] cpuidle: using governor ladder
[    0.080000] cpuidle: using governor menu
[    0.080000] cpuidle: using governor menu
[    0.080000] ACPI: bus type PCI registered
[    0.080000] ACPI: bus type PCI registered
[    0.080040] dca service started, version 1.12.1
[    0.080040] dca service started, version 1.12.1
[    0.081003] PCI: Using configuration type 1 for base access
[    0.081003] PCI: Using configuration type 1 for base access
[    0.098573] Running resizable hashtable tests...
[    0.098573] Running resizable hashtable tests...
[    0.099539]   Adding 2048 keys
[    0.099539]   Adding 2048 keys
[    0.100518]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.100518]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.101974]   Table expansion iteration 0...
[    0.101974]   Table expansion iteration 0...
[    0.103080]   Verifying lookups...
[    0.103080]   Verifying lookups...
[    0.103849]   Table expansion iteration 1...
[    0.103849]   Table expansion iteration 1...
[    0.105577]   Verifying lookups...
[    0.105577]   Verifying lookups...
[    0.106909]   Table expansion iteration 2...
[    0.106909]   Table expansion iteration 2...
[    0.109030]   Verifying lookups...
[    0.109030]   Verifying lookups...
[    0.110151]   Table expansion iteration 3...
[    0.110151]   Table expansion iteration 3...
[    0.112929]   Verifying lookups...
[    0.112929]   Verifying lookups...
[    0.114317]   Table shrinkage iteration 0...
[    0.114317]   Table shrinkage iteration 0...
[    0.116040]   Verifying lookups...
[    0.116040]   Verifying lookups...
[    0.117375]   Table shrinkage iteration 1...
[    0.117375]   Table shrinkage iteration 1...
[    0.119116]   Verifying lookups...
[    0.119116]   Verifying lookups...
[    0.120149]   Table shrinkage iteration 2...
[    0.120149]   Table shrinkage iteration 2...
[    0.121718]   Verifying lookups...
[    0.121718]   Verifying lookups...
[    0.123087]   Table shrinkage iteration 3...
[    0.123087]   Table shrinkage iteration 3...
[    0.124664]   Verifying lookups...
[    0.124664]   Verifying lookups...
[    0.126078]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.126078]   Traversal complete: counted=3D2048, nelems=3D2048, entries=
=3D2048
[    0.128328]   Deleting 2048 keys
[    0.128328]   Deleting 2048 keys
[    0.130466] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.130466] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.132289] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.132289] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.134199] ACPI: Added _OSI(Module Device)
[    0.134199] ACPI: Added _OSI(Module Device)
[    0.135586] ACPI: Added _OSI(Processor Device)
[    0.135586] ACPI: Added _OSI(Processor Device)
[    0.136968] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.136968] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.138438] ACPI: Added _OSI(Processor Aggregator Device)
[    0.138438] ACPI: Added _OSI(Processor Aggregator Device)
[    0.142228] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.142228] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.148352] ACPI: Interpreter enabled
[    0.148352] ACPI: Interpreter enabled
[    0.149605] ACPI: (supports S0 S5)
[    0.149605] ACPI: (supports S0 S5)
[    0.150005] ACPI: Using IOAPIC for interrupt routing
[    0.150005] ACPI: Using IOAPIC for interrupt routing
[    0.151130] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.151130] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.158579] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.158579] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.160008] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.160008] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.161107] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.161107] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.162439] PCI host bridge to bus 0000:00
[    0.162439] PCI host bridge to bus 0000:00
[    0.163304] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.163304] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.164418] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.164418] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.165745] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    0.165745] pci_bus 0000:00: root bus resource [io  0x0d00-0xadff]
[    0.167037] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    0.167037] pci_bus 0000:00: root bus resource [io  0xae0f-0xaeff]
[    0.168325] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    0.168325] pci_bus 0000:00: root bus resource [io  0xaf20-0xafdf]
[    0.170005] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    0.170005] pci_bus 0000:00: root bus resource [io  0xafe4-0xffff]
[    0.171268] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.171268] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.172687] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    0.172687] pci_bus 0000:00: root bus resource [mem 0x14000000-0xfebffff=
f]
[    0.174179] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.174179] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.175838] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.175838] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.177507] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.177507] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.181229] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.181229] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    0.183176] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.183176] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    0.184583] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.184583] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    0.185928] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.185928] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    0.187593] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.187593] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    0.190391] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.190391] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.193015] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.193015] pci 0000:00:01.3: quirk: [io  0x0600-0x063f] claimed by PIIX=
4 ACPI
[    0.195422] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.195422] pci 0000:00:01.3: quirk: [io  0x0700-0x070f] claimed by PIIX=
4 SMB
[    0.197968] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.197968] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.200612] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.200612] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.203505] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.203505] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.209041] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.209041] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.210277] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.210277] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.212251] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.212251] pci 0000:00:03.0: reg 0x10: [mem 0xfebc0000-0xfebdffff]
[    0.214338] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.214338] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.222107] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.222107] pci 0000:00:03.0: reg 0x30: [mem 0xfeb80000-0xfebbffff pref]
[    0.224456] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.224456] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    0.226820] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.226820] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    0.230984] pci_bus 0000:00: on NUMA node 0
[    0.230984] pci_bus 0000:00: on NUMA node 0
[    0.232305] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.232305] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.233606] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.233606] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.234873] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.234873] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.236099] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.236099] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.237313] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.237313] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.238823] ACPI:=20
[    0.238823] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.240435] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.240435] vgaarb: setting as boot device: PCI:0000:00:02.0
[    0.241503] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.241503] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.243035] vgaarb: loaded
[    0.243035] vgaarb: loaded
[    0.243567] vgaarb: bridge control possible 0000:00:02.0
[    0.243567] vgaarb: bridge control possible 0000:00:02.0
[    0.244977] SCSI subsystem initialized
[    0.244977] SCSI subsystem initialized
[    0.245771] libata version 3.00 loaded.
[    0.245771] libata version 3.00 loaded.
[    0.246610] ACPI: bus type USB registered
[    0.246610] ACPI: bus type USB registered
[    0.247435] usbcore: registered new interface driver usbfs
[    0.247435] usbcore: registered new interface driver usbfs
[    0.248513] usbcore: registered new interface driver hub
[    0.248513] usbcore: registered new interface driver hub
[    0.249556] usbcore: registered new device driver usb
[    0.249556] usbcore: registered new device driver usb
[    0.250111] pps_core: LinuxPPS API ver. 1 registered
[    0.250111] pps_core: LinuxPPS API ver. 1 registered
[    0.251077] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.251077] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.252841] PTP clock support registered
[    0.252841] PTP clock support registered
[    0.253646] PCI: Using ACPI for IRQ routing
[    0.253646] PCI: Using ACPI for IRQ routing
[    0.254470] PCI: pci_cache_line_size set to 64 bytes
[    0.254470] PCI: pci_cache_line_size set to 64 bytes
[    0.256135] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.256135] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.257972] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.257972] e820: reserve RAM buffer [mem 0x13fe0000-0x13ffffff]
[    0.260349] NET: Registered protocol family 23
[    0.260349] NET: Registered protocol family 23
[    0.261743] Bluetooth: Core ver 2.20
[    0.261743] Bluetooth: Core ver 2.20
[    0.262924] NET: Registered protocol family 31
[    0.262924] NET: Registered protocol family 31
[    0.264355] Bluetooth: HCI device and connection manager initialized
[    0.264355] Bluetooth: HCI device and connection manager initialized
[    0.266381] Bluetooth: HCI socket layer initialized
[    0.266381] Bluetooth: HCI socket layer initialized
[    0.267939] Bluetooth: L2CAP socket layer initialized
[    0.267939] Bluetooth: L2CAP socket layer initialized
[    0.269598] Bluetooth: SCO socket layer initialized
[    0.269598] Bluetooth: SCO socket layer initialized
[    0.270017] NET: Registered protocol family 8
[    0.270017] NET: Registered protocol family 8
[    0.271466] NET: Registered protocol family 20
[    0.271466] NET: Registered protocol family 20
[    0.272618] nfc: nfc_init: NFC Core ver 0.1
[    0.272618] nfc: nfc_init: NFC Core ver 0.1
[    0.273427] NET: Registered protocol family 39
[    0.273427] NET: Registered protocol family 39
[    0.275000] Switched to clocksource kvm-clock
[    0.275000] Switched to clocksource kvm-clock
[    0.275881] FS-Cache: Loaded
[    0.275881] FS-Cache: Loaded
[    0.276471] pnp: PnP ACPI init
[    0.276471] pnp: PnP ACPI init
[    0.277122] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.277122] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.277122] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.277122] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.277122] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.277122] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.277122] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.277122] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.277745] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.277745] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.279320] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.279320] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.280590] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.280590] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.282089] pnp 00:03: [dma 2]
[    0.282089] pnp 00:03: [dma 2]
[    0.282703] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.282703] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.283990] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.283990] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.285500] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.285500] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.286760] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.286760] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.288286] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.288286] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.289857] pnp: PnP ACPI: found 6 devices
[    0.289857] pnp: PnP ACPI: found 6 devices
[    0.295807] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.295807] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    0.296865] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    0.296865] pci_bus 0000:00: resource 5 [io  0x0d00-0xadff]
[    0.297895] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    0.297895] pci_bus 0000:00: resource 6 [io  0xae0f-0xaeff]
[    0.298924] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    0.298924] pci_bus 0000:00: resource 7 [io  0xaf20-0xafdf]
[    0.299945] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    0.299945] pci_bus 0000:00: resource 8 [io  0xafe4-0xffff]
[    0.300976] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    0.300976] pci_bus 0000:00: resource 9 [mem 0x000a0000-0x000bffff]
[    0.302127] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    0.302127] pci_bus 0000:00: resource 10 [mem 0x14000000-0xfebfffff]
[    0.303327] NET: Registered protocol family 2
[    0.303327] NET: Registered protocol family 2
[    0.304271] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    0.304271] TCP established hash table entries: 4096 (order: 3, 32768 by=
tes)
[    0.305629] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.305629] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    0.306965] TCP: Hash tables configured (established 4096 bind 4096)
[    0.306965] TCP: Hash tables configured (established 4096 bind 4096)
[    0.308172] TCP: reno registered
[    0.308172] TCP: reno registered
[    0.308795] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.308795] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    0.309910] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.309910] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    0.311191] NET: Registered protocol family 1
[    0.311191] NET: Registered protocol family 1
[    0.312170] RPC: Registered named UNIX socket transport module.
[    0.312170] RPC: Registered named UNIX socket transport module.
[    0.313286] RPC: Registered udp transport module.
[    0.313286] RPC: Registered udp transport module.
[    0.314167] RPC: Registered tcp transport module.
[    0.314167] RPC: Registered tcp transport module.
[    0.315039] RPC: Registered tcp NFSv4.1 backchannel transport module
--JYK4vJDZwFMowpUq
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--JYK4vJDZwFMowpUq--
