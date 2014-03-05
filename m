From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [mac80211_hwsim] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47
 kobject_get()
Date: Wed, 5 Mar 2014 20:57:03 +0800
Message-ID: <20140305125703.GA7193@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Cc: Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Martin Pitt <martin.pitt@ubuntu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit 9ea927748ced4953f1e9a0f1fa1fdeacd1018b4e
Author:     Martin Pitt <martin.pitt@ubuntu.com>
AuthorDate: Mon Apr 8 11:30:01 2013 +0200
Commit:     Johannes Berg <johannes.berg@intel.com>
CommitDate: Wed Apr 10 20:23:50 2013 +0200

    mac80211_hwsim: Register and bind to driver
    
[    3.588600] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    3.590170] ------------[ cut here ]------------
[    3.590170] ------------[ cut here ]------------
[    3.591332] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47 kobject_get+0x33/0x50()
...
[    3.695323] WARNING: CPU: 0 PID: 1 at fs/kernfs/dir.c:1216 kernfs_remove_by_name_ns+0x31/0x80()
...
[    3.814723] BUG: unable to handle kernel paging requestpaging request at 883d11f0

Bisect log shows that the problems are also present in linux-next.

git bisect start v3.10 v3.9 --
git bisect  bad ff89acc563a0bd49965674f56552ad6620415fe2  # 22:47      0-      6  Merge branch 'rcu/urgent' of git://git.kernel.org/pub/scm/linux/kernel/git/paulmck/linux-rcu
git bisect  bad 24d0c2542b38963ae4d5171ecc0a2c1326c656bc  # 22:52      0-      2  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs
git bisect good 151173e8ce9b95bbbbd7eedb9035cfaffbdb7cb2  # 23:00     23+     23  Merge tag 'for-v3.10' of git://git.infradead.org/battery-2.6
git bisect  bad e95893004104054d49406fd108fefa3ddc054366  # 23:03      0-      1  Merge tag 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost
git bisect good 8a72f3820c4d14b27ad5336aed00063a7a7f1bef  # 23:09     23+     23  Merge git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile
git bisect  bad 600fe9751aeb6f6b72de84076a05c5b8c04152c0  # 23:12      0-      3  ipc_schedule_free() can do vfree() directly now
git bisect  bad 126de6b20bfb82cc19012d5048f11f339ae5a021  # 23:16      0-      3  linkage.h: fix build breakage due to symbol prefix handling
git bisect good 251df49db3327c64bf917bfdba94491fde2b4ee0  # 23:22     23+     23  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/dtor/input
git bisect  bad 73287a43cc79ca06629a88d1a199cd283f42456a  # 23:25      0-      1  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next
git bisect good 953c96e0d85615d1ab1f100e525d376053294dc2  # 23:37     23+      0  tg3: Use bool not int
git bisect  bad 4fc4118cdb29ab946b8a586fc766ebb6ae1e1c90  # 23:42      0-      7  wil6210: more Rx descriptor accessor functions
git bisect good e73dcfbf061b524fe9aaef56cf3c2e234a45ec19  # 23:52     23+      0  Bluetooth: hidp: fix sending output reports on intr channel
git bisect good d5590bba37f3c7d496195648532d5313abb43891  # 23:58     23+      0  NFC: pn533: Re-group fields in struct pn533
git bisect  bad 06d961a8e210035bff7e82f466107f9ab4a8fd94  # 00:07      0-     16  mac80211/minstrel: use the new rate control API
git bisect  bad 97990a060e6757f48b931a3946b17c1c4362c3fb  # 00:11      0-      4  nl80211: allow using wdev identifiers to get scan results
git bisect  bad 85220d71bf3ca1ba9129e0744247ae5f61bec559  # 00:12      0-      1  mac80211: support secondary channel offset in CSA
git bisect  bad 0ca54f6c5fd4ce58aa044d1fc7f00d7f6cf2801c  # 00:14      0-      1  mac80211: provide SSID in IBSS mode
git bisect  bad 3088f7d2db42925808c4b43a6258647ee4d1dd5f  # 00:15      0-      2  mac80211: stringify another plink state
git bisect  bad 9d6d6f4924133567a108a862d9cf949cd03f71cb  # 00:17      0-      1  mac80211: unset FC retry bit in mesh fwding path
git bisect  bad 9ea927748ced4953f1e9a0f1fa1fdeacd1018b4e  # 00:21      0-      2  mac80211_hwsim: Register and bind to driver
# first bad commit: [9ea927748ced4953f1e9a0f1fa1fdeacd1018b4e] mac80211_hwsim: Register and bind to driver
git bisect good ddc4db2e3d5393ede7a9222bb3b7522a603a4678  # 00:35     69+      0  mac80211: make ieee802_11_parse_elems an inline
git bisect  bad faa2e6fb0a98c9caa8995acf3222db9f7f029395  # 00:35      0-     19  Add linux-next specific files for 20140221
git bisect  bad 8427defd087ae6c5eaea9d609dfe7f165568accd  # 00:38      0-      2  MAINTAINERS: add maintainer entry for Armada DRM driver
git bisect  bad b148a42ba7823e34971cd4e5b05a5c74fa3311ed  # 00:41      0-      2  Add linux-next specific files for 20140228

Thanks,
Fengguang

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-quantal-inn-32:20140224035628:i386-randconfig-xp1-02240043::"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel
KASLR using RDTSC...

Decompressing Linux... Parsing ELF... Performing relocations... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-next-20140221-04488-gfaa2e6f (kbuil=
d@xps) (gcc version 4.8.1 (Debian 4.8.1-8) ) #1 PREEMPT Mon Feb 24 02:43:12=
 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[800fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] initial memory mapped: [mem 0x00000000-0x07ffffff]
[    0.000000] Base memory trampoline at [8009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e000000-0x0e3fffff]
[    0.000000]  [mem 0x0e000000-0x0e3fffff] page 4k
[    0.000000] BRK [0x07af5000, 0x07af5fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0dffffff]
[    0.000000]  [mem 0x08000000-0x0dffffff] page 4k
[    0.000000] BRK [0x07af6000, 0x07af6fff] PGTABLE
[    0.000000] BRK [0x07af7000, 0x07af7fff] PGTABLE
[    0.000000] BRK [0x07af8000, 0x07af8fff] PGTABLE
[    0.000000] BRK [0x07af9000, 0x07af9fff] PGTABLE
[    0.000000] BRK [0x07afa000, 0x07afafff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e400000-0x0fffdfff]
[    0.000000]  [mem 0x0e400000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0e7ab000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0FFFE450 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x0FFFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x0FFFE490 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x0FFFFF40 000040
[    0.000000] ACPI: SSDT 0x0FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x0FFFF680 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x0FFFF640 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat 874aad60, node_mem_map 8e=
56b024
[    0.000000]   Normal zone: 576 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
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
[    0.000000] ACPI: IRQ2 used by override.
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
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 72ab4c0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64860
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-xp1-02240043/next:master/.vmlinuz-faa2e6fb0a98c9caa8995a=
cf3222db9f7f029395-20140224024829-1-inn branch=3Dnext/master BOOT_IMAGE=3D/=
kernel/i386-randconfig-xp1-02240043/faa2e6fb0a98c9caa8995acf3222db9f7f02939=
5/vmlinuz-3.14.0-rc3-next-20140221-04488-gfaa2e6f
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 210620K/261744K available (10433K kernel code, 2292K=
 rwdata, 4512K rodata, 432K init, 5700K bss, 51124K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff8c000 - 0xfffff000   ( 460 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0x907fe000 - 0xff7fe000   (1776 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x8fffe000   ( 255 MB)
[    0.000000]       .init : 0x874d8000 - 0x87544000   ( 432 kB)
[    0.000000]       .data : 0x86e30918 - 0x874d7280   (6810 kB)
[    0.000000]       .text : 0x86400000 - 0x86e30918   (10434 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:256 16
[    0.000000] CPU 0 irqstacks, hard=3D80090000 soft=3D80092000
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.14.0-rc3-next-20140221-04488-gfaa2e6f (kbuil=
d@xps) (gcc version 4.8.1 (Debian 4.8.1-8) ) #1 PREEMPT Mon Feb 24 02:43:12=
 CST 2014
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled: n=
on-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0xfffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdac0-0x000fdacf] mapped at =
[800fdac0]
[    0.000000]   mpc: fdad0-fdbec
[    0.000000] initial memory mapped: [mem 0x00000000-0x07ffffff]
[    0.000000] Base memory trampoline at [8009b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e000000-0x0e3fffff]
[    0.000000]  [mem 0x0e000000-0x0e3fffff] page 4k
[    0.000000] BRK [0x07af5000, 0x07af5fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x08000000-0x0dffffff]
[    0.000000]  [mem 0x08000000-0x0dffffff] page 4k
[    0.000000] BRK [0x07af6000, 0x07af6fff] PGTABLE
[    0.000000] BRK [0x07af7000, 0x07af7fff] PGTABLE
[    0.000000] BRK [0x07af8000, 0x07af8fff] PGTABLE
[    0.000000] BRK [0x07af9000, 0x07af9fff] PGTABLE
[    0.000000] BRK [0x07afa000, 0x07afafff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x07ffffff]
[    0.000000]  [mem 0x00100000-0x07ffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x0e400000-0x0fffdfff]
[    0.000000]  [mem 0x0e400000-0x0fffdfff] page 4k
[    0.000000] RAMDISK: [mem 0x0e7ab000-0x0ffeffff]
[    0.000000] ACPI: RSDP 0x000FD930 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x0FFFE450 000034 (v01 BOCHS  BXPCRSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: FACP 0x0FFFFF80 000074 (v01 BOCHS  BXPCFACP 00000001 B=
XPC 00000001)
[    0.000000] ACPI: DSDT 0x0FFFE490 0011A9 (v01 BXPC   BXDSDT   00000001 I=
NTL 20100528)
[    0.000000] ACPI: FACS 0x0FFFFF40 000040
[    0.000000] ACPI: SSDT 0x0FFFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001 B=
XPC 00000001)
[    0.000000] ACPI: APIC 0x0FFFF680 000080 (v01 BOCHS  BXPCAPIC 00000001 B=
XPC 00000001)
[    0.000000] ACPI: HPET 0x0FFFF640 000038 (v01 BOCHS  BXPCHPET 00000001 B=
XPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 255MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 0fffe000
[    0.000000]   low ram: 0 - 0fffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:fffd001, boot clock
[    0.000000] Zone ranges:
[    0.000000]   Normal   [mem 0x00001000-0x0fffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65436
[    0.000000] free_area_init_node: node 0, pgdat 874aad60, node_mem_map 8e=
56b024
[    0.000000]   Normal zone: 576 pages used for memmap
[    0.000000]   Normal zone: 0 pages reserved
[    0.000000]   Normal zone: 65436 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffb000 (        fee00000)
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
[    0.000000] ACPI: IRQ2 used by override.
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
[    0.000000] mapped IOAPIC to ffffa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 72ab4c0
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 64860
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3DttyS0=
,115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-xp1-02240043/next:master/.vmlinuz-faa2e6fb0a98c9caa8995a=
cf3222db9f7f029395-20140224024829-1-inn branch=3Dnext/master BOOT_IMAGE=3D/=
kernel/i386-randconfig-xp1-02240043/faa2e6fb0a98c9caa8995acf3222db9f7f02939=
5/vmlinuz-3.14.0-rc3-next-20140221-04488-gfaa2e6f
[    0.000000] PID hash table entries: 1024 (order: 0, 4096 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 5, 131072 byt=
es)
[    0.000000] Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 210620K/261744K available (10433K kernel code, 2292K=
 rwdata, 4512K rodata, 432K init, 5700K bss, 51124K reserved, 0K highmem)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xfff8c000 - 0xfffff000   ( 460 kB)
[    0.000000]     pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
[    0.000000]     vmalloc : 0x907fe000 - 0xff7fe000   (1776 MB)
[    0.000000]     lowmem  : 0x80000000 - 0x8fffe000   ( 255 MB)
[    0.000000]       .init : 0x874d8000 - 0x87544000   ( 432 kB)
[    0.000000]       .data : 0x86e30918 - 0x874d7280   (6810 kB)
[    0.000000]       .text : 0x86400000 - 0x86e30918   (10434 kB)
[    0.000000] Checking if this processor honours the WP bit even in superv=
isor mode...Ok.
[    0.000000] Preemptible hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:2304 nr_irqs:256 16
[    0.000000] CPU 0 irqstacks, hard=3D80090000 soft=3D80092000
[    0.000000] ACPI: Core revision 20140114
[    0.000000] ACPI: All ACPI Tables successfully acquired
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
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 3823 kB
[    0.000000]  memory used by lock dependency info: 3823 kB
[    0.000000]  per task-struct memory footprint: 1920 bytes
[    0.000000]  per task-struct memory footprint: 1920 bytes
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
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

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
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |            =
 |  ok  |  ok  |             |             |  ok  |  ok  |

[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

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
[    0.000000]                ww contexts mixing:  ok  |  ok  |  ok  |  ok =
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
[    0.000000]                           context:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                             block:
[    0.000000]                             block:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |

[    0.000000] -------------------------------------------------------
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] Good, all 253 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ---------------------------------
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.514 MHz processor
[    0.000000] tsc: Detected 2693.514 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value..=20
[    0.008000] Calibrating delay loop (skipped) preset value.. 5387.02 Bogo=
MIPS (lpj=3D10774056)
5387.02 BogoMIPS (lpj=3D10774056)
[    0.008010] pid_max: default: 4096 minimum: 301
[    0.008010] pid_max: default: 4096 minimum: 301
[    0.009226] Security Framework initialized
[    0.009226] Security Framework initialized
[    0.010267] Yama: becoming mindful.
[    0.010267] Yama: becoming mindful.
[    0.011164] Mount-cache hash table entries: 512
[    0.011164] Mount-cache hash table entries: 512
[    0.012457] Initializing cgroup subsys net_cls
[    0.012457] Initializing cgroup subsys net_cls
[    0.013647] Initializing cgroup subsys perf_event
[    0.013647] Initializing cgroup subsys perf_event
[    0.014888] Initializing cgroup subsys net_prio
[    0.014888] Initializing cgroup subsys net_prio
[    0.016129] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.016129] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.016129] tlb_flushall_shift: 6
[    0.016129] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.016129] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.016129] tlb_flushall_shift: 6
[    0.020011] CPU:=20
[    0.020011] CPU: Intel Intel Common KVM processorCommon KVM processor (f=
am: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.027707] Performance Events:=20
[    0.027707] Performance Events: unsupported Netburst CPU model 6 unsuppo=
rted Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.034690] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.034690] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.036027] Getting VERSION: 50014
[    0.036027] Getting VERSION: 50014
[    0.036928] Getting VERSION: 50014
[    0.036928] Getting VERSION: 50014
[    0.037787] Getting ID: 0
[    0.037787] Getting ID: 0
[    0.038458] Getting ID: f000000
[    0.038458] Getting ID: f000000
[    0.039255] Getting LVT0: 8700
[    0.039255] Getting LVT0: 8700
[    0.040014] Getting LVT1: 8400
[    0.040014] Getting LVT1: 8400
[    0.040867] enabled ExtINT on CPU#0
[    0.040867] enabled ExtINT on CPU#0
[    0.043088] ENABLING IO-APIC IRQs
[    0.043088] ENABLING IO-APIC IRQs
[    0.044015] init IO_APIC IRQs
[    0.044015] init IO_APIC IRQs
[    0.044794]  apic 0 pin 0 not connected
[    0.044794]  apic 0 pin 0 not connected
[    0.045831] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.045831] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.048041] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.048041] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.050179] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.050179] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.052035] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.052035] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.054101] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.054101] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.056035] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.056035] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.058020] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.058020] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.060037] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.060037] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.062125] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.062125] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.064035] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.064035] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.066079] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.066079] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.068034] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.068034] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.070066] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.070066] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.072035] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.072035] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.074151] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.074151] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.076031]  apic 0 pin 16 not connected
[    0.076031]  apic 0 pin 16 not connected
[    0.077046]  apic 0 pin 17 not connected
[    0.077046]  apic 0 pin 17 not connected
[    0.078088]  apic 0 pin 18 not connected
[    0.078088]  apic 0 pin 18 not connected
[    0.080006]  apic 0 pin 19 not connected
[    0.080006]  apic 0 pin 19 not connected
[    0.081020]  apic 0 pin 20 not connected
[    0.081020]  apic 0 pin 20 not connected
[    0.082007]  apic 0 pin 21 not connected
[    0.082007]  apic 0 pin 21 not connected
[    0.084007]  apic 0 pin 22 not connected
[    0.084007]  apic 0 pin 22 not connected
[    0.084990]  apic 0 pin 23 not connected
[    0.084990]  apic 0 pin 23 not connected
[    0.086111] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.086111] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.088007] Using local APIC timer interrupts.
[    0.088007] calibrating APIC timer ...
[    0.088007] Using local APIC timer interrupts.
[    0.088007] calibrating APIC timer ...
[    0.092000] ... lapic delta =3D 6249809
[    0.092000] ... lapic delta =3D 6249809
[    0.092000] ... PM-Timer delta =3D 357942
[    0.092000] ... PM-Timer delta =3D 357942
[    0.092000] ... PM-Timer result ok
[    0.092000] ... PM-Timer result ok
[    0.092000] ..... delta 6249809
[    0.092000] ..... delta 6249809
[    0.092000] ..... mult: 268427252
[    0.092000] ..... mult: 268427252
[    0.092000] ..... calibration result: 3999877
[    0.092000] ..... calibration result: 3999877
[    0.092000] ..... CPU clock speed is 2693.1302 MHz.
[    0.092000] ..... CPU clock speed is 2693.1302 MHz.
[    0.092000] ..... host bus clock speed is 999.3877 MHz.
[    0.092000] ..... host bus clock speed is 999.3877 MHz.
[    0.092693] devtmpfs: initialized
[    0.092693] devtmpfs: initialized
[    0.095750] xor: measuring software checksum speed
[    0.095750] xor: measuring software checksum speed
[    0.136031]    pIII_sse  :  7930.000 MB/sec
[    0.136031]    pIII_sse  :  7930.000 MB/sec
[    0.176010]    prefetch64-sse:  9587.000 MB/sec
[    0.176010]    prefetch64-sse:  9587.000 MB/sec
[    0.177781] xor: using function: prefetch64-sse (9587.000 MB/sec)
[    0.177781] xor: using function: prefetch64-sse (9587.000 MB/sec)
[    0.180021] atomic64 test passed for i586+ platform with CX8 and with SSE
[    0.180021] atomic64 test passed for i586+ platform with CX8 and with SSE
[    0.183269] regulator-dummy: no parameters
[    0.183269] regulator-dummy: no parameters
[    0.184337] NET: Registered protocol family 16
[    0.184337] NET: Registered protocol family 16
[    0.187024] cpuidle: using governor ladder
[    0.187024] cpuidle: using governor ladder
[    0.188008] cpuidle: using governor menu
[    0.188008] cpuidle: using governor menu
[    0.189995] ACPI: bus type PCI registered
[    0.189995] ACPI: bus type PCI registered
[    0.192247] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.192247] PCI: PCI BIOS revision 2.10 entry at 0xfc6d5, last bus=3D0
[    0.194572] PCI: Using configuration type 1 for base access
[    0.194572] PCI: Using configuration type 1 for base access
[    0.304042] raid6: mmxx1     2576 MB/s
[    0.304042] raid6: mmxx1     2576 MB/s
[    0.372017] raid6: mmxx2     3365 MB/s
[    0.372017] raid6: mmxx2     3365 MB/s
[    0.440013] raid6: sse1x1    2687 MB/s
[    0.440013] raid6: sse1x1    2687 MB/s
[    0.508020] raid6: sse1x2    3204 MB/s
[    0.508020] raid6: sse1x2    3204 MB/s
[    0.576017] raid6: sse2x1    4307 MB/s
[    0.576017] raid6: sse2x1    4307 MB/s
[    0.644012] raid6: sse2x2    6959 MB/s
[    0.644012] raid6: sse2x2    6959 MB/s
[    0.645418] raid6: using algorithm sse2x2 (6959 MB/s)
[    0.645418] raid6: using algorithm sse2x2 (6959 MB/s)
[    0.647255] raid6: using intx1 recovery algorithm
[    0.647255] raid6: using intx1 recovery algorithm
[    0.648720] ACPI: Added _OSI(Module Device)
[    0.648720] ACPI: Added _OSI(Module Device)
[    0.650274] ACPI: Added _OSI(Processor Device)
[    0.650274] ACPI: Added _OSI(Processor Device)
[    0.652008] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.652008] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.653872] ACPI: Added _OSI(Processor Aggregator Device)
[    0.653872] ACPI: Added _OSI(Processor Aggregator Device)
[    0.672114] ACPI: Interpreter enabled
[    0.672114] ACPI: Interpreter enabled
[    0.673621] ACPI: (supports S0 S5)
[    0.673621] ACPI: (supports S0 S5)
[    0.674989] ACPI: Using IOAPIC for interrupt routing
[    0.674989] ACPI: Using IOAPIC for interrupt routing
[    0.676078] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.676078] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    0.701705] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.701705] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.704015] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.704015] acpi PNP0A03:00: _OSC: OS supports [Segments]
[    0.706046] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.706046] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    0.708912] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.708912] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    0.712319] PCI host bridge to bus 0000:00
[    0.712319] PCI host bridge to bus 0000:00
[    0.716010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.716010] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.720012] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.720012] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    0.722478] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.722478] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    0.724009] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.724009] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    0.728011] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.728011] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebffff=
f]
[    0.732107] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.732107] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.737061] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.737061] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.740667] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.740667] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.746533] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.746533] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    0.750253] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.750253] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.752485] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.752485] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.756021] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.756021] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.760696] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.760696] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.764897] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.764897] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    0.769837] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.769837] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    0.782638] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.782638] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    0.785338] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.785338] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.789434] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.789434] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    0.793396] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.793396] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    0.804010] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.804010] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    0.807777] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.807777] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.809489] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.809489] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    0.813394] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.813394] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    0.825696] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.825696] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.829452] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.829452] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    0.833392] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.833392] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    0.844199] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.844199] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.848008] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.848008] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    0.852009] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.852009] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    0.862493] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.862493] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.865359] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.865359] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    0.869302] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.869302] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    0.879769] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.879769] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.881370] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.881370] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    0.885281] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.885281] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    0.896841] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.896841] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.900710] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.900710] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    0.904013] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.904013] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    0.913851] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.913851] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.916756] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.916756] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    0.924722] pci_bus 0000:00: on NUMA node 0
[    0.924722] pci_bus 0000:00: on NUMA node 0
[    0.927630] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    0.927630] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    0.928913] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    0.928913] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    0.932639] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    0.932639] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    0.935469] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    0.935469] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    0.936792] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    0.936792] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    0.941861] ACPI:=20
[    0.941861] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    0.945607] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.945607] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.948014] vgaarb: loaded
[    0.948014] vgaarb: loaded
[    0.948964] vgaarb: bridge control possible 0000:00:02.0
[    0.948964] vgaarb: bridge control possible 0000:00:02.0
[    0.953139] SCSI subsystem initialized
[    0.953139] SCSI subsystem initialized
[    0.954673] ACPI: bus type USB registered
[    0.954673] ACPI: bus type USB registered
[    0.956206] usbcore: registered new interface driver usbfs
[    0.956206] usbcore: registered new interface driver usbfs
[    0.958186] usbcore: registered new interface driver hub
[    0.958186] usbcore: registered new interface driver hub
[    0.960200] usbcore: registered new device driver usb
[    0.960200] usbcore: registered new device driver usb
[    0.962602] pps_core: LinuxPPS API ver. 1 registered
[    0.962602] pps_core: LinuxPPS API ver. 1 registered
[    0.964037] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.964037] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.967450] EDAC MC: Ver: 3.0.0
[    0.967450] EDAC MC: Ver: 3.0.0
[    0.968526] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.968526] EDAC DEBUG: edac_mc_sysfs_init: device mc created
[    0.972113] PCI: Using ACPI for IRQ routing
[    0.972113] PCI: Using ACPI for IRQ routing
[    0.973587] PCI: pci_cache_line_size set to 64 bytes
[    0.973587] PCI: pci_cache_line_size set to 64 bytes
[    0.975571] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.975571] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    0.976033] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.976033] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.980659] NET: Registered protocol family 8
[    0.980659] NET: Registered protocol family 8
[    0.982216] NET: Registered protocol family 20
[    0.982216] NET: Registered protocol family 20
[    0.984502] nfc: nfc_init: NFC Core ver 0.1
[    0.984502] nfc: nfc_init: NFC Core ver 0.1
[    0.986060] NET: Registered protocol family 39
[    0.986060] NET: Registered protocol family 39
[    0.988066] cfg80211: Calling CRDA to update world regulatory domain
[    0.988066] cfg80211: Calling CRDA to update world regulatory domain
[    0.990604] Switched to clocksource kvm-clock
[    0.990604] Switched to clocksource kvm-clock
[    0.992000] FS-Cache: Loaded
[    0.992000] FS-Cache: Loaded
[    0.992000] CacheFiles: Loaded
[    0.992000] CacheFiles: Loaded
[    0.992363] pnp: PnP ACPI init
[    0.992363] pnp: PnP ACPI init
[    0.993510] ACPI: bus type PNP registered
[    0.993510] ACPI: bus type PNP registered
[    0.995014] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.995014] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.998076] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.998076] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.000465] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.000465] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.003368] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.003368] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.005756] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.005756] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.008829] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.008829] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.011202] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.011202] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.014004] pnp 00:03: [dma 2]
[    1.014004] pnp 00:03: [dma 2]
[    1.015195] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.015195] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.017635] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.017635] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.020650] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.020650] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.023043] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.023043] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.025954] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.025954] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.029077] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.029077] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.031813] pnp: PnP ACPI: found 7 devices
[    1.031813] pnp: PnP ACPI: found 7 devices
[    1.033273] ACPI: bus type PNP unregistered
[    1.033273] ACPI: bus type PNP unregistered
[    1.071607] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.071607] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.073874] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.073874] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.076097] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.076097] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.078574] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.078574] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.081099] NET: Registered protocol family 1
[    1.081099] NET: Registered protocol family 1
[    1.082865] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.082865] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.085418] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.085418] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.087818] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.087818] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.090291] pci 0000:00:02.0: Boot video device
[    1.090291] pci 0000:00:02.0: Boot video device
[    1.092247] PCI: CLS 0 bytes, default 64
[    1.092247] PCI: CLS 0 bytes, default 64
[    1.094388] Unpacking initramfs...
[    1.094388] Unpacking initramfs...
[    2.365169] debug: unmapping init [mem 0x8e7ab000-0x8ffeffff]
[    2.365169] debug: unmapping init [mem 0x8e7ab000-0x8ffeffff]
[    2.368538] kvm: no hardware support
[    2.368538] kvm: no hardware support
[    2.369999] has_svm: not amd
[    2.369999] has_svm: not amd
[    2.371181] kvm: no hardware support
[    2.371181] kvm: no hardware support
[    2.374092] cryptomgr_test (27) used greatest stack depth: 7048 bytes le=
ft
[    2.374092] cryptomgr_test (27) used greatest stack depth: 7048 bytes le=
ft
[    2.378762] cryptomgr_test (35) used greatest stack depth: 6388 bytes le=
ft
[    2.378762] cryptomgr_test (35) used greatest stack depth: 6388 bytes le=
ft
[    2.382324] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    2.382324] The force parameter has not been set to 1. The Iris poweroff=
 handler will not be installed.
[    2.386249] NatSemi SCx200 Driver
[    2.386249] NatSemi SCx200 Driver
[    2.389377] futex hash table entries: 16 (order: -3, 768 bytes)
[    2.389377] futex hash table entries: 16 (order: -3, 768 bytes)
[    2.391838] audit: initializing netlink subsys (disabled)
[    2.391838] audit: initializing netlink subsys (disabled)
[    2.394606] audit: type=3D2000 audit(1393185381.382:1): initialized
[    2.394606] audit: type=3D2000 audit(1393185381.382:1): initialized
[    2.398712] jffs2: version 2.2. (NAND)=20
[    2.398712] jffs2: version 2.2. (NAND)=20
[    2.401538] QNX4 filesystem 0.2.3 registered.
[    2.401538] QNX4 filesystem 0.2.3 registered.
[    2.403286] QNX6 filesystem 1.0.0 registered.
[    2.403286] QNX6 filesystem 1.0.0 registered.
[    2.405050] fuse init (API version 7.22)
[    2.405050] fuse init (API version 7.22)
[    2.407402] BeFS version: 0.9.3
[    2.407402] BeFS version: 0.9.3
[    2.408745] msgmni has been set to 411
[    2.408745] msgmni has been set to 411
[    2.420004] alg: No test for lz4hc (lz4hc-generic)
[    2.420004] alg: No test for lz4hc (lz4hc-generic)
[    2.422337] alg: No test for stdrng (krng)
[    2.422337] alg: No test for stdrng (krng)
[    2.423997] async_tx: api initialized (async)
[    2.423997] async_tx: api initialized (async)
[    2.426039] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    2.426039] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    2.429118] io scheduler noop registered (default)
[    2.429118] io scheduler noop registered (default)
[    2.431052] io scheduler deadline registered
[    2.431052] io scheduler deadline registered
[    2.432919] io scheduler cfq registered
[    2.432919] io scheduler cfq registered
[    2.435839] test_string_helpers: Running tests...
[    2.435839] test_string_helpers: Running tests...
[    2.442988] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    2.442988] crc32: CRC_LE_BITS =3D 1, CRC_BE BITS =3D 1
[    2.445000] crc32: self tests passed, processed 225944 bytes in 2525769 =
nsec
[    2.445000] crc32: self tests passed, processed 225944 bytes in 2525769 =
nsec
[    2.450578] crc32c: CRC_LE_BITS =3D 1
[    2.450578] crc32c: CRC_LE_BITS =3D 1
[    2.452079] crc32c: self tests passed, processed 225944 bytes in 1381671=
 nsec
[    2.452079] crc32c: self tests passed, processed 225944 bytes in 1381671=
 nsec
[    2.755390] crc32_combine: 8373 self tests passed
[    2.755390] crc32_combine: 8373 self tests passed
[    3.057623] crc32c_combine: 8373 self tests passed
[    3.057623] crc32c_combine: 8373 self tests passed
[    3.061674] usbcore: registered new interface driver udlfb
[    3.061674] usbcore: registered new interface driver udlfb
[    3.063927] usbcore: registered new interface driver smscufx
[    3.063927] usbcore: registered new interface driver smscufx
[    3.067017] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.067017] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    3.070004] ACPI: Power Button [PWRF]
[    3.070004] ACPI: Power Button [PWRF]
[    3.182449] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.182449] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    3.209780] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    3.209780] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    3.216457] toshiba: not a supported Toshiba laptop
[    3.216457] toshiba: not a supported Toshiba laptop
[    3.218414] scx200_gpio: no SCx200 gpio present
[    3.218414] scx200_gpio: no SCx200 gpio present
[    3.220241] nsc_gpio initializing
[    3.220241] nsc_gpio initializing
[    3.221618] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    3.221618] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    3.223612] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    3.223612] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    3.227170] Hangcheck: Using getrawmonotonic().
[    3.227170] Hangcheck: Using getrawmonotonic().
[    3.230311] Floppy drive(s):
[    3.230311] Floppy drive(s): fd0 is 1.44M fd0 is 1.44M

[    3.240919] loop: module loaded
[    3.240919] loop: module loaded
[    3.243525] nbd: registered device at major 43
[    3.243525] nbd: registered device at major 43
[    3.251330] FDC 0 is a S82078B
[    3.251330] FDC 0 is a S82078B
[    3.265178] dummy-irq: no IRQ given.  Use irq=3DN
[    3.265178] dummy-irq: no IRQ given.  Use irq=3DN
[    3.267118] lkdtm: No crash points registered, enable through debugfs
[    3.267118] lkdtm: No crash points registered, enable through debugfs
[    3.270438] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    3.270438] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    3.274162] c2port c2port0: C2 port uc added
[    3.274162] c2port c2port0: C2 port uc added
[    3.275871] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    3.275871] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    3.279946] usbcore: registered new interface driver viperboard
[    3.279946] usbcore: registered new interface driver viperboard
[    3.282542] usbcore: registered new interface driver pn533
[    3.282542] usbcore: registered new interface driver pn533
[    3.286321] rdac: device handler registered
[    3.286321] rdac: device handler registered
[    3.288588] alua: device handler registered
[    3.288588] alua: device handler registered
[    3.291543] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    3.291543] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    3.294224] osst :I: Tape driver with OnStream support version 0.99.4
[    3.294224] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    3.294224] osst :I: Tape driver with OnStream support version 0.99.4
[    3.294224] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    3.300314] osd: LOADED open-osd 0.2.1
[    3.300314] osd: LOADED open-osd 0.2.1
[    3.316503] scsi_debug: host protection
[    3.316503] scsi_debug: host protection
[    3.318072] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    3.318072] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    3.322633] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    3.322633] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    3.328332] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    3.328332] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    3.331691] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.331691] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    3.333913] sd 0:0:0:0: [sda] Write Protect is off
[    3.333913] sd 0:0:0:0: [sda] Write Protect is off
[    3.335810] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    3.335810] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    3.340176] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    3.340176] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    3.344186] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    3.344186] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    3.353138] SSFDC read-only Flash Translation layer
[    3.353138] SSFDC read-only Flash Translation layer
[    3.355107] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    3.355107] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    3.357795] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    3.357795] L440GX flash mapping: failed to find PIIX4 ISA bridge, canno=
t continue
[    3.361034] Could not find PAR responsible for SC520CDP Flash Bank #1
[    3.361034] Could not find PAR responsible for SC520CDP Flash Bank #1
[    3.363613] Trying default address 0x8c00000
[    3.363613] Trying default address 0x8c00000
[    3.366020] SC520 CDP flash device: 0x800000 at 0x8800000
[    3.366020] SC520 CDP flash device: 0x800000 at 0x8800000
[    3.368475] Failed to ioremap_nocache
[    3.368475] Failed to ioremap_nocache
[    3.369952] Failed to ioremap_nocache
[    3.369952] Failed to ioremap_nocache
[    3.371451] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    3.371451] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    3.373939] tsc: Refined TSC clocksource calibration: 2693.432 MHz
[    3.373939] tsc: Refined TSC clocksource calibration: 2693.432 MHz
[    3.377402] slram: not enough parameters.
[    3.377402] slram: not enough parameters.
[    3.380070]  sda: unknown partition table
[    3.380070]  sda: unknown partition table
[    3.385967] ftl_cs: FTL header not found.
[    3.385967] ftl_cs: FTL header not found.
[    3.392987] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.392987] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.397521] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.397521] sd 0:0:0:0: [sda] Attached SCSI disk
[    3.399484] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.399484] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.403304] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.403304] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.407038] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.407038] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.410771] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.410771] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.414686] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.414686] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    3.418601] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[    3.418601] nand: device found, Manufacturer ID: 0x98, Chip ID: 0x39
[    3.421251] nand: Toshiba NAND 128MiB 1,8V 8-bit
[    3.421251] nand: Toshiba NAND 128MiB 1,8V 8-bit
[    3.423098] nand: 128MiB, SLC, page size: 512, OOB size: 16
[    3.423098] nand: 128MiB, SLC, page size: 512, OOB size: 16
[    3.426038] flash size: 128 MiB
[    3.426038] flash size: 128 MiB
[    3.427313] page size: 512 bytes
[    3.427313] page size: 512 bytes
[    3.428624] OOB area size: 16 bytes
[    3.428624] OOB area size: 16 bytes
[    3.430017] sector size: 16 KiB
[    3.430017] sector size: 16 KiB
[    3.431311] pages number: 262144
[    3.431311] pages number: 262144
[    3.432688] pages per sector: 32
[    3.432688] pages per sector: 32
[    3.434036] bus width: 8
[    3.434036] bus width: 8
[    3.435098] bits in sector size: 14
[    3.435098] bits in sector size: 14
[    3.436584] bits in page size: 9
[    3.436584] bits in page size: 9
[    3.437933] bits in OOB size: 4
[    3.437933] bits in OOB size: 4
[    3.439248] flash size with OOB: 135168 KiB
[    3.439248] flash size with OOB: 135168 KiB
[    3.441019] page address bytes: 4
[    3.441019] page address bytes: 4
[    3.442358] sector address bytes: 3
[    3.442358] sector address bytes: 3
[    3.443741] options: 0x42
[    3.443741] options: 0x42
[    3.446605] Scanning device for bad blocks
[    3.446605] Scanning device for bad blocks
[    3.517431] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    3.517431] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    3.519900] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    3.519900] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    3.524686] ftl_cs: FTL header not found.
[    3.524686] ftl_cs: FTL header not found.
[    3.529792] libphy: Fixed MDIO Bus: probed
[    3.529792] libphy: Fixed MDIO Bus: probed
[    3.532243] vcan: Virtual CAN interface driver
[    3.532243] vcan: Virtual CAN interface driver
[    3.535126] PPP generic driver version 2.4.2
[    3.535126] PPP generic driver version 2.4.2
[    3.537209] PPP Deflate Compression module registered
[    3.537209] PPP Deflate Compression module registered
[    3.539241] PPP MPPE Compression module registered
[    3.539241] PPP MPPE Compression module registered
[    3.541180] NET: Registered protocol family 24
[    3.541180] NET: Registered protocol family 24
[    3.543003] Atmel at76x USB Wireless LAN Driver 0.17 loading
[    3.543003] Atmel at76x USB Wireless LAN Driver 0.17 loading
[    3.545334] usbcore: registered new interface driver at76c50x-usb
[    3.545334] usbcore: registered new interface driver at76c50x-usb
[    3.548543] Broadcom 43xx-legacy driver loaded [ Features: PLI ]
[    3.548543] Broadcom 43xx-legacy driver loaded [ Features: PLI ]
[    3.550938] zd1211rw usb_init()
[    3.550938] zd1211rw usb_init()
[    3.552417] usbcore: registered new interface driver zd1211rw
[    3.552417] usbcore: registered new interface driver zd1211rw
[    3.554690] zd1211rw initialized
[    3.554690] zd1211rw initialized
[    3.556083] usbcore: registered new interface driver rtl8187
[    3.556083] usbcore: registered new interface driver rtl8187
[    3.558391] usbcore: registered new interface driver rndis_wlan
[    3.558391] usbcore: registered new interface driver rndis_wlan
[    3.560852] usbcore: registered new interface driver usb8xxx
[    3.560852] usbcore: registered new interface driver usb8xxx
[    3.563105] libertas_sdio: Libertas SDIO driver
[    3.563105] libertas_sdio: Libertas SDIO driver
[    3.564937] libertas_sdio: Copyright Pierre Ossman
[    3.564937] libertas_sdio: Copyright Pierre Ossman
[    3.567884] usbcore: registered new interface driver lbtf_usb
[    3.567884] usbcore: registered new interface driver lbtf_usb
[    3.570282] usbcore: registered new interface driver rt2500usb
[    3.570282] usbcore: registered new interface driver rt2500usb
[    3.572711] usbcore: registered new interface driver rt73usb
[    3.572711] usbcore: registered new interface driver rt73usb
[    3.577006] ieee80211 phy0: Failed to select rate control algorithm
[    3.577006] ieee80211 phy0: Failed to select rate control algorithm
[    3.579508] ieee80211 phy0: Failed to initialize rate control algorithm
[    3.579508] ieee80211 phy0: Failed to initialize rate control algorithm
[    3.588600] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    3.588600] mac80211_hwsim: ieee80211_register_hw failed (-2)
[    3.590170] ------------[ cut here ]------------
[    3.590170] ------------[ cut here ]------------
[    3.591332] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47 kobject_ge=
t+0x33/0x50()
[    3.591332] WARNING: CPU: 0 PID: 1 at include/linux/kref.h:47 kobject_ge=
t+0x33/0x50()
[    3.593762] CPU: 0 PID: 1 Comm: swapper Not tainted 3.14.0-rc3-next-2014=
0221-04488-gfaa2e6f #1
[    3.593762] CPU: 0 PID: 1 Comm: swapper Not tainted 3.14.0-rc3-next-2014=
0221-04488-gfaa2e6f #1
[    3.595814]  00000000
[    3.595814]  00000000 00000000 00000000 80021e40 80021e40 86e237f4 86e23=
7f4 80021e70 80021e70 864717ab 864717ab 87147724 87147724 00000000 00000000

[    3.598836]  00000001
[    3.598836]  00000001 8714762c 8714762c 0000002f 0000002f 866cb5a3 866cb=
5a3 866cb5a3 866cb5a3 883cf520 883cf520 87447154 87447154 87aaa5ac 87aaa5ac

[    3.602365]  80021e80
[    3.602365]  80021e80 8647186d 8647186d 00000009 00000009 00000000 00000=
000 80021e8c 80021e8c 866cb5a3 866cb5a3 883cf518 883cf518 80021e94 80021e94

[    3.606685] Call Trace:
[    3.606685] Call Trace:
[    3.607697]  [<86e237f4>] dump_stack+0x16/0x18
[    3.607697]  [<86e237f4>] dump_stack+0x16/0x18
[    3.609515]  [<864717ab>] warn_slowpath_common+0x6b/0x90
[    3.609515]  [<864717ab>] warn_slowpath_common+0x6b/0x90
[    3.611613]  [<866cb5a3>] ? kobject_get+0x33/0x50
[    3.611613]  [<866cb5a3>] ? kobject_get+0x33/0x50
[    3.613349]  [<866cb5a3>] ? kobject_get+0x33/0x50
[    3.613349]  [<866cb5a3>] ? kobject_get+0x33/0x50
[    3.615046]  [<8647186d>] warn_slowpath_null+0x1d/0x20
[    3.615046]  [<8647186d>] warn_slowpath_null+0x1d/0x20
[    3.616939]  [<866cb5a3>] kobject_get+0x33/0x50
[    3.616939]  [<866cb5a3>] kobject_get+0x33/0x50
[    3.618584]  [<86794bff>] get_device+0xf/0x20
[    3.618584]  [<86794bff>] get_device+0xf/0x20
[    3.621793]  [<86797f8d>] driver_detach+0x3d/0xa0
[    3.621793]  [<86797f8d>] driver_detach+0x3d/0xa0
[    3.625230]  [<86796d1f>] bus_remove_driver+0x8f/0xb0
[    3.625230]  [<86796d1f>] bus_remove_driver+0x8f/0xb0
[    3.628880]  [<86798720>] ? class_unregister+0x40/0x80
[    3.628880]  [<86798720>] ? class_unregister+0x40/0x80
[    3.632605]  [<86798287>] driver_unregister+0x47/0x50
[    3.632605]  [<86798287>] driver_unregister+0x47/0x50
[    3.636582]  [<867987d3>] ? class_destroy+0x13/0x20
[    3.636582]  [<867987d3>] ? class_destroy+0x13/0x20
[    3.639190]  [<8679963b>] platform_driver_unregister+0xb/0x10
[    3.639190]  [<8679963b>] platform_driver_unregister+0xb/0x10
[    3.645615]  [<87508fca>] init_mac80211_hwsim+0x3e4/0x3f4
[    3.645615]  [<87508fca>] init_mac80211_hwsim+0x3e4/0x3f4
[    3.651227]  [<87508be6>] ? rt73usb_driver_init+0x16/0x16
[    3.651227]  [<87508be6>] ? rt73usb_driver_init+0x16/0x16
[    3.657131]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.657131]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.662333]  [<86486a93>] ? parameq+0x13/0x70
[    3.662333]  [<86486a93>] ? parameq+0x13/0x70
[    3.666820]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.666820]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.672611]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.672611]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.675364]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.675364]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.678344]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.678344]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.680664]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.680664]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.682878]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.682878]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.685672]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.685672]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.688518]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.688518]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.690712] ---[ end trace 50f295b48f81b0dd ]---
[    3.690712] ---[ end trace 50f295b48f81b0dd ]---
[    3.693080] ------------[ cut here ]------------
[    3.693080] ------------[ cut here ]------------
[    3.695323] WARNING: CPU: 0 PID: 1 at fs/kernfs/dir.c:1216 kernfs_remove=
_by_name_ns+0x31/0x80()
[    3.695323] WARNING: CPU: 0 PID: 1 at fs/kernfs/dir.c:1216 kernfs_remove=
_by_name_ns+0x31/0x80()
[    3.701322] kernfs: can not remove 'driver', no directory
[    3.701322] kernfs: can not remove 'driver', no directory
[    3.704007] CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.14.0-rc=
3-next-20140221-04488-gfaa2e6f #1
[    3.704007] CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.14.0-rc=
3-next-20140221-04488-gfaa2e6f #1
[    3.709027]  80021e44
[    3.709027]  80021e44 80021e44 80021e44 80021e04 80021e04 86e237f4 86e23=
7f4 80021e34 80021e34 864717ab 864717ab 871510b0 871510b0 80021e60 80021e60

[    3.713083]  00000001
[    3.713083]  00000001 87151024 87151024 000004c0 000004c0 86556fd1 86556=
fd1 86556fd1 86556fd1 00000000 00000000 87143c83 87143c83 883cf54c 883cf54c

[    3.717098]  80021e4c
[    3.717098]  80021e4c 8647181e 8647181e 00000009 00000009 80021e44 80021=
e44 871510b0 871510b0 80021e60 80021e60 80021e70 80021e70 86556fd1 86556fd1

[    3.721463] Call Trace:
[    3.721463] Call Trace:
[    3.722768]  [<86e237f4>] dump_stack+0x16/0x18
[    3.722768]  [<86e237f4>] dump_stack+0x16/0x18
[    3.725207]  [<864717ab>] warn_slowpath_common+0x6b/0x90
[    3.725207]  [<864717ab>] warn_slowpath_common+0x6b/0x90
[    3.727635]  [<86556fd1>] ? kernfs_remove_by_name_ns+0x31/0x80
[    3.727635]  [<86556fd1>] ? kernfs_remove_by_name_ns+0x31/0x80
[    3.730468]  [<86556fd1>] ? kernfs_remove_by_name_ns+0x31/0x80
[    3.730468]  [<86556fd1>] ? kernfs_remove_by_name_ns+0x31/0x80
[    3.733840]  [<8647181e>] warn_slowpath_fmt+0x2e/0x30
[    3.733840]  [<8647181e>] warn_slowpath_fmt+0x2e/0x30
[    3.736280]  [<86556fd1>] kernfs_remove_by_name_ns+0x31/0x80
[    3.736280]  [<86556fd1>] kernfs_remove_by_name_ns+0x31/0x80
[    3.739158]  [<86558bfa>] sysfs_remove_link+0x1a/0x20
[    3.739158]  [<86558bfa>] sysfs_remove_link+0x1a/0x20
[    3.741550]  [<86797738>] driver_sysfs_remove+0x28/0x30
[    3.741550]  [<86797738>] driver_sysfs_remove+0x28/0x30
[    3.744223]  [<86797e86>] __device_release_driver+0x26/0xc0
[    3.744223]  [<86797e86>] __device_release_driver+0x26/0xc0
[    3.747649]  [<86797fc3>] driver_detach+0x73/0xa0
[    3.747649]  [<86797fc3>] driver_detach+0x73/0xa0
[    3.750175]  [<86796d1f>] bus_remove_driver+0x8f/0xb0
[    3.750175]  [<86796d1f>] bus_remove_driver+0x8f/0xb0
[    3.752585]  [<86798720>] ? class_unregister+0x40/0x80
[    3.752585]  [<86798720>] ? class_unregister+0x40/0x80
[    3.755160]  [<86798287>] driver_unregister+0x47/0x50
[    3.755160]  [<86798287>] driver_unregister+0x47/0x50
[    3.758235]  [<867987d3>] ? class_destroy+0x13/0x20
[    3.758235]  [<867987d3>] ? class_destroy+0x13/0x20
[    3.760635]  [<8679963b>] platform_driver_unregister+0xb/0x10
[    3.760635]  [<8679963b>] platform_driver_unregister+0xb/0x10
[    3.763539]  [<87508fca>] init_mac80211_hwsim+0x3e4/0x3f4
[    3.763539]  [<87508fca>] init_mac80211_hwsim+0x3e4/0x3f4
[    3.766278]  [<87508be6>] ? rt73usb_driver_init+0x16/0x16
[    3.766278]  [<87508be6>] ? rt73usb_driver_init+0x16/0x16
[    3.769745]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.769745]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.772229]  [<86486a93>] ? parameq+0x13/0x70
[    3.772229]  [<86486a93>] ? parameq+0x13/0x70
[    3.774755]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.774755]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.777328]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.777328]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.779844]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.779844]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.782985]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.782985]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.785455]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.785455]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.787590]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.787590]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.790050]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.790050]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.793205]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.793205]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.795421] ---[ end trace 50f295b48f81b0de ]---
[    3.795421] ---[ end trace 50f295b48f81b0de ]---
[    3.798088] Error: Driver 'usb8xxx' is already registered, aborting...
[    3.798088] Error: Driver 'usb8xxx' is already registered, aborting...
[    3.801330] mwifiex_usb: Driver register failed!
[    3.801330] mwifiex_usb: Driver register failed!
[    3.804856] usbcore: registered new interface driver kaweth
[    3.804856] usbcore: registered new interface driver kaweth
[    3.807705] usbcore: registered new interface driver rtl8150
[    3.807705] usbcore: registered new interface driver rtl8150
[    3.811867] usbcore: registered new interface driver asix
[    3.811867] usbcore: registered new interface driver asix
[    3.814723] BUG: unable to handle kernel=20
[    3.814723] BUG: unable to handle kernel paging requestpaging request at=
 883d11f0
 at 883d11f0
[    3.818218] IP:
[    3.818218] IP: [<86509f48>] slob_page_alloc+0x38/0x2c0
 [<86509f48>] slob_page_alloc+0x38/0x2c0
[    3.818592] *pde =3D 07af6067=20
[    3.818592] *pde =3D 07af6067 *pte =3D 083d1060 *pte =3D 083d1060=20

[    3.818592] Oops: 0000 [#1]=20
[    3.818592] Oops: 0000 [#1] PREEMPT PREEMPT DEBUG_PAGEALLOCDEBUG_PAGEALL=
OC

[    3.818592] CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.14.0-rc=
3-next-20140221-04488-gfaa2e6f #1
[    3.818592] CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.14.0-rc=
3-next-20140221-04488-gfaa2e6f #1
[    3.818592] task: 80011000 ti: 80020000 task.ti: 80020000
[    3.818592] task: 80011000 ti: 80020000 task.ti: 80020000
[    3.818592] EIP: 0060:[<86509f48>] EFLAGS: 00010006 CPU: 0
[    3.818592] EIP: 0060:[<86509f48>] EFLAGS: 00010006 CPU: 0
[    3.818592] EIP is at slob_page_alloc+0x38/0x2c0
[    3.818592] EIP is at slob_page_alloc+0x38/0x2c0
[    3.818592] EAX: 883d11f0 EBX: 00000000 ECX: 883cd000 EDX: 883d11f0
[    3.818592] EAX: 883d11f0 EBX: 00000000 ECX: 883cd000 EDX: 883d11f0
[    3.818592] ESI: 00000001 EDI: 883cdf68 EBP: 80021df0 ESP: 80021dc8
[    3.818592] ESI: 00000001 EDI: 883cdf68 EBP: 80021df0 ESP: 80021dc8
[    3.818592]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    3.818592]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[    3.818592] CR0: 8005003b CR2: 883d11f0 CR3: 07547000 CR4: 00000690
[    3.818592] CR0: 8005003b CR2: 883d11f0 CR3: 07547000 CR4: 00000690
[    3.818592] Stack:
[    3.818592] Stack:
[    3.818592]  8e6938d4
[    3.818592]  8e6938d4 fffffff8 fffffff8 00000007 00000007 00000008 00000=
008 00010001 00010001 883cdf68 883cdf68 00000013 00000013 8e6938d4 8e6938d4

[    3.818592]  873f5278
[    3.818592]  873f5278 00000013 00000013 80021e18 80021e18 8650a68a 8650a=
68a 873f5278 873f5278 00000286 00000286 00000008 00000008 000080d0 000080d0

[    3.818592]  00000026
[    3.818592]  00000026 000080d0 000080d0 0000001e 0000001e 0000001e 00000=
01e 80021e28 80021e28 8650a7f6 8650a7f6 000000d0 000000d0 00000000 00000000

[    3.818592] Call Trace:
[    3.818592] Call Trace:
[    3.818592]  [<8650a68a>] slob_alloc.isra.13+0x6a/0x1a0
[    3.818592]  [<8650a68a>] slob_alloc.isra.13+0x6a/0x1a0
[    3.818592]  [<8650a7f6>] __kmalloc+0x36/0x80
[    3.818592]  [<8650a7f6>] __kmalloc+0x36/0x80
[    3.818592]  [<866cb3c0>] kobject_get_path+0x50/0xf0
[    3.818592]  [<866cb3c0>] kobject_get_path+0x50/0xf0
[    3.818592]  [<866cc7cf>] kobject_uevent_env+0x1bf/0x690
[    3.818592]  [<866cc7cf>] kobject_uevent_env+0x1bf/0x690
[    3.818592]  [<8655859c>] ? sysfs_create_file_ns+0x2c/0x30
[    3.818592]  [<8655859c>] ? sysfs_create_file_ns+0x2c/0x30
[    3.818592]  [<867981f1>] ? driver_create_file+0x11/0x20
[    3.818592]  [<867981f1>] ? driver_create_file+0x11/0x20
[    3.818592]  [<866cccaa>] kobject_uevent+0xa/0x10
[    3.818592]  [<866cccaa>] kobject_uevent+0xa/0x10
[    3.818592]  [<86798382>] driver_register+0xb2/0xc0
[    3.818592]  [<86798382>] driver_register+0xb2/0xc0
[    3.818592]  [<869fbc61>] usb_register_driver+0x71/0x140
[    3.818592]  [<869fbc61>] usb_register_driver+0x71/0x140
[    3.818592]  [<8750907c>] ? asix_driver_init+0x16/0x16
[    3.818592]  [<8750907c>] ? asix_driver_init+0x16/0x16
[    3.818592]  [<87509090>] ax88179_178a_driver_init+0x14/0x16
[    3.818592]  [<87509090>] ax88179_178a_driver_init+0x14/0x16
[    3.818592]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.818592]  [<874d8b1c>] do_one_initcall+0xad/0x13e
[    3.818592]  [<86486a93>] ? parameq+0x13/0x70
[    3.818592]  [<86486a93>] ? parameq+0x13/0x70
[    3.818592]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.818592]  [<874d84de>] ? repair_env_string+0x12/0x51
[    3.818592]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.818592]  [<86486d85>] ? parse_args+0x295/0x3e0
[    3.818592]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.818592]  [<874d8d3a>] kernel_init_freeable+0x18d/0x231
[    3.818592]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.818592]  [<874d84cc>] ? do_early_param+0x7a/0x7a
[    3.818592]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.818592]  [<86e1e39b>] kernel_init+0xb/0xe0
[    3.818592]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.818592]  [<864901c2>] ? schedule_tail+0x12/0x40
[    3.818592]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.818592]  [<86e2e2d7>] ret_from_kernel_thread+0x1b/0x28
[    3.818592]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.818592]  [<86e1e390>] ? rest_init+0xc0/0xc0
[    3.818592] Code:
[    3.818592] Code: 83 83 ec ec 1c 1c 8b 8b 56 56 08 08 89 89 7d 7d f0 f0 =
d1 d1 6d 6d f0 f0 89 89 45 45 d8 d8 89 89 c8 c8 8d 8d 70 70 ff ff f7 f7 d8 =
d8 89 89 4d 4d e4 e4 31 31 c9 c9 c7 c7 45 45 ec ec 00 00 00 00 00 00 00 00 =
89 89 cf cf 89 89 75 75 e0 e0 89 89 45 45 dc dc 90 90 <0f> <0f> b7 b7 02 02=
 66 66 85 85 c0 c0 7e 7e 10 10 0f 0f bf bf f0 f0 66 66 89 89 45 45 ea ea eb=
 eb 15 15 8d 8d b4 b4 26 26 00 00

[    3.818592] EIP: [<86509f48>]=20
[    3.818592] EIP: [<86509f48>] slob_page_alloc+0x38/0x2c0slob_page_alloc+=
0x38/0x2c0 SS:ESP 0068:80021dc8
 SS:ESP 0068:80021dc8
[    3.818592] CR2: 00000000883d11f0
[    3.818592] CR2: 00000000883d11f0
[    3.818592] ---[ end trace 50f295b48f81b0df ]---
[    3.818592] ---[ end trace 50f295b48f81b0df ]---
[    3.818592] Kernel panic - not syncing: Fatal exception
[    3.818592] Kernel panic - not syncing: Fatal exception
[    3.818592] Kernel Offset: 0x5400000 from 0x81000000 (relocation range: =
0x80000000-0x907fdfff)
[    3.818592] Kernel Offset: 0x5400000 from 0x81000000 (relocation range: =
0x80000000-0x907fdfff)
[    3.818592] Rebooting in 10 seconds..
[    3.818592] Rebooting in 10 seconds..
Elapsed time: 10
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig-x=
p1-02240043/faa2e6fb0a98c9caa8995acf3222db9f7f029395/vmlinuz-3.14.0-rc3-nex=
t-20140221-04488-gfaa2e6f -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,=
115200 debug apic=3Ddebug sysrq_always_enabled panic=3D10 softlockup_panic=
=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D0 console=3DttyS0,115200 consol=
e=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw link=3D/kernel-tests/run-queue/k=
vm/i386-randconfig-xp1-02240043/next:master/.vmlinuz-faa2e6fb0a98c9caa8995a=
cf3222db9f7f029395-20140224024829-1-inn branch=3Dnext/master BOOT_IMAGE=3D/=
kernel/i386-randconfig-xp1-02240043/faa2e6fb0a98c9caa8995acf3222db9f7f02939=
5/vmlinuz-3.14.0-rc3-next-20140221-04488-gfaa2e6f'  -initrd /kernel-tests/i=
nitrd/quantal-core-i386.cgz -m 256 -smp 2 -net nic,vlan=3D1,model=3De1000 -=
net user,vlan=3D1,hostfwd=3Dtcp::52388-:22 -boot order=3Dnc -no-reboot -wat=
chdog i6300esb -rtc base=3Dlocaltime -drive file=3D/fs/LABEL=3DKVM/disk0-qu=
antal-inn-32,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk1-q=
uantal-inn-32,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk2-=
quantal-inn-32,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk3=
-quantal-inn-32,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/disk=
4-quantal-inn-32,media=3Ddisk,if=3Dvirtio -drive file=3D/fs/LABEL=3DKVM/dis=
k5-quantal-inn-32,media=3Ddisk,if=3Dvirtio -pidfile /dev/shm/kboot/pid-quan=
tal-inn-32 -serial file:/dev/shm/kboot/serial-quantal-inn-32 -daemonize -di=
splay none -monitor null=20

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.14.0-rc3-next-20140221-04488-gfaa2e6f"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.14.0-rc3 Kernel Configuration
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
CONFIG_ARCH_HAS_CACHE_LINE_SIZE=y
CONFIG_HAVE_SETUP_PER_CPU_AREA=y
CONFIG_NEED_PER_CPU_EMBED_FIRST_CHUNK=y
CONFIG_NEED_PER_CPU_PAGE_FIRST_CHUNK=y
CONFIG_ARCH_HIBERNATION_POSSIBLE=y
CONFIG_ARCH_SUSPEND_POSSIBLE=y
CONFIG_ARCH_WANT_HUGE_PMD_SHARE=y
CONFIG_ARCH_WANT_GENERAL_HUGETLB=y
# CONFIG_ZONE_DMA32 is not set
# CONFIG_AUDIT_ARCH is not set
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_X86_32_LAZY_GS=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_COMPILE_TEST=y
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_HAVE_KERNEL_LZ4=y
# CONFIG_KERNEL_GZIP is not set
# CONFIG_KERNEL_BZIP2 is not set
CONFIG_KERNEL_LZMA=y
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y

#
# IRQ subsystem
#
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
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
CONFIG_GENERIC_CLOCKEVENTS_MIN_ADJUST=y
CONFIG_GENERIC_CMOS_UPDATE=y

#
# Timers subsystem
#
CONFIG_TICK_ONESHOT=y
CONFIG_NO_HZ_COMMON=y
# CONFIG_HZ_PERIODIC is not set
CONFIG_NO_HZ_IDLE=y
# CONFIG_NO_HZ is not set
CONFIG_HIGH_RES_TIMERS=y

#
# CPU/Task time and stats accounting
#
# CONFIG_TICK_CPU_ACCOUNTING is not set
CONFIG_IRQ_TIME_ACCOUNTING=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
# CONFIG_TASK_IO_ACCOUNTING is not set

#
# RCU Subsystem
#
CONFIG_TREE_PREEMPT_RCU=y
CONFIG_PREEMPT_RCU=y
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
CONFIG_RCU_FANOUT_EXACT=y
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_BOOST=y
CONFIG_RCU_BOOST_PRIO=1
CONFIG_RCU_BOOST_DELAY=500
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
# CONFIG_CGROUP_DEVICE is not set
CONFIG_CPUSETS=y
# CONFIG_PROC_PID_CPUSET is not set
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
CONFIG_CFS_BANDWIDTH=y
CONFIG_RT_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
CONFIG_CHECKPOINT_RESTORE=y
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
# CONFIG_IPC_NS is not set
CONFIG_USER_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
# CONFIG_RELAY is not set
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
CONFIG_RD_LZO=y
CONFIG_RD_LZ4=y
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
CONFIG_SYSFS_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y
CONFIG_PERF_USE_VMALLOC=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
CONFIG_DEBUG_PERF_USE_VMALLOC=y
# CONFIG_VM_EVENT_COUNTERS is not set
# CONFIG_COMPAT_BRK is not set
# CONFIG_SLAB is not set
# CONFIG_SLUB is not set
CONFIG_SLOB=y
CONFIG_PROFILING=y
CONFIG_OPROFILE=y
CONFIG_OPROFILE_EVENT_MULTIPLEX=y
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
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
CONFIG_HAVE_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR is not set
CONFIG_CC_STACKPROTECTOR_NONE=y
# CONFIG_CC_STACKPROTECTOR_REGULAR is not set
# CONFIG_CC_STACKPROTECTOR_STRONG is not set
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_HAVE_ARCH_SOFT_DIRTY=y
CONFIG_MODULES_USE_ELF_REL=y
CONFIG_CLONE_BACKWARDS=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
CONFIG_HAVE_GENERIC_DMA_COHERENT=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
CONFIG_AIX_PARTITION=y
# CONFIG_OSF_PARTITION is not set
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
# CONFIG_BSD_DISKLABEL is not set
CONFIG_MINIX_SUBPARTITION=y
# CONFIG_SOLARIS_X86_PARTITION is not set
CONFIG_UNIXWARE_DISKLABEL=y
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
# CONFIG_KARMA_PARTITION is not set
# CONFIG_EFI_PARTITION is not set
CONFIG_SYSV68_PARTITION=y
CONFIG_CMDLINE_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
# CONFIG_DEFAULT_DEADLINE is not set
# CONFIG_DEFAULT_CFQ is not set
CONFIG_DEFAULT_NOOP=y
CONFIG_DEFAULT_IOSCHED="noop"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_FREEZER is not set

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
CONFIG_X86_MPPARSE=y
CONFIG_X86_EXTENDED_PLATFORM=y
# CONFIG_X86_GOLDFISH is not set
# CONFIG_X86_INTEL_MID is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_RDC321X=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_XEN_PRIVILEGED_GUEST is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
# CONFIG_MEMTEST is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
CONFIG_M686=y
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
# CONFIG_MELAN is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_MVIAC7 is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_INTERNODE_CACHE_SHIFT=5
CONFIG_X86_L1_CACHE_SHIFT=5
# CONFIG_X86_PPRO_FENCE is not set
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=5
CONFIG_X86_DEBUGCTLMSR=y
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_CYRIX_32=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_CPU_SUP_TRANSMETA_32=y
CONFIG_CPU_SUP_UMC_32=y
CONFIG_HPET_TIMER=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
# CONFIG_PREEMPT_VOLUNTARY is not set
CONFIG_PREEMPT=y
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_UP_APIC=y
CONFIG_X86_UP_IOAPIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
CONFIG_VM86=y
CONFIG_TOSHIBA=y
# CONFIG_I8K is not set
CONFIG_X86_REBOOTFIXUPS=y
# CONFIG_MICROCODE is not set
# CONFIG_MICROCODE_INTEL_EARLY is not set
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_X86_MSR=y
# CONFIG_X86_CPUID is not set
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
CONFIG_VMSPLIT_2G=y
# CONFIG_VMSPLIT_2G_OPT is not set
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x80000000
CONFIG_HIGHMEM=y
CONFIG_ARCH_FLATMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ILLEGAL_POINTER_VALUE=0
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_FLATMEM_MANUAL=y
# CONFIG_SPARSEMEM_MANUAL is not set
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
CONFIG_SPARSEMEM_STATIC=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_BALLOON_COMPACTION is not set
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=0
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_NEED_PER_CPU_KM=y
CONFIG_CLEANCACHE=y
CONFIG_CMA=y
# CONFIG_CMA_DEBUG is not set
# CONFIG_ZBUD is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_HIGHPTE is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_RANDOMIZE_BASE=y
CONFIG_RANDOMIZE_BASE_MAX_OFFSET=0x20000000
CONFIG_X86_NEED_RELOCS=y
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
# CONFIG_SUSPEND is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
# CONFIG_WQ_POWER_EFFICIENT_DEFAULT is not set
CONFIG_ACPI=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# CPU Idle
#
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
# CONFIG_INTEL_IDLE is not set

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
# CONFIG_PCI_GOOLPC is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_OLPC=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
CONFIG_SCx200=y
# CONFIG_SCx200HR_TIMER is not set
CONFIG_OLPC=y
# CONFIG_OLPC_XO15_SCI is not set
CONFIG_ALIX=y
CONFIG_NET5501=y
CONFIG_AMD_NB=y
# CONFIG_PCCARD is not set
# CONFIG_HOTPLUG_PCI is not set
# CONFIG_RAPIDIO is not set
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
CONFIG_BINFMT_AOUT=y
CONFIG_BINFMT_MISC=y
# CONFIG_COREDUMP is not set
CONFIG_HAVE_ATOMIC_IOMAP=y
CONFIG_NET=y

#
# Networking options
#
CONFIG_PACKET=y
CONFIG_PACKET_DIAG=y
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
# CONFIG_XFRM_SUB_POLICY is not set
CONFIG_XFRM_MIGRATE=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
# CONFIG_INET is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y

#
# DECnet: Netfilter Configuration
#
# CONFIG_DECNET_NF_GRABULATOR is not set
CONFIG_ATM=y
# CONFIG_ATM_LANE is not set
# CONFIG_BRIDGE is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
# CONFIG_VLAN_8021Q is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
CONFIG_ATALK=y
# CONFIG_DEV_APPLETALK is not set
CONFIG_X25=y
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_MAC802154=y
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
# CONFIG_NET_SCH_HTB is not set
# CONFIG_NET_SCH_HFSC is not set
CONFIG_NET_SCH_ATM=y
# CONFIG_NET_SCH_PRIO is not set
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
# CONFIG_NET_SCH_GRED is not set
# CONFIG_NET_SCH_DSMARK is not set
CONFIG_NET_SCH_NETEM=y
# CONFIG_NET_SCH_DRR is not set
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
CONFIG_NET_SCH_FQ_CODEL=y
CONFIG_NET_SCH_FQ=y
# CONFIG_NET_SCH_HHF is not set
CONFIG_NET_SCH_PIE=y
CONFIG_NET_SCH_PLUG=y

#
# Classification
#
CONFIG_NET_CLS=y
# CONFIG_NET_CLS_BASIC is not set
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
# CONFIG_NET_CLS_BPF is not set
# CONFIG_NET_EMATCH is not set
# CONFIG_NET_CLS_ACT is not set
# CONFIG_NET_CLS_IND is not set
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_NC=y
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_OPENVSWITCH=y
CONFIG_VSOCKETS=y
CONFIG_NETLINK_MMAP=y
# CONFIG_NETLINK_DIAG is not set
CONFIG_NET_MPLS_GSO=y
CONFIG_HSR=y
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y

#
# Network testing
#
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
# CONFIG_AX25 is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
# CONFIG_CAN_BCM is not set
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
# CONFIG_CAN_DEV is not set
# CONFIG_CAN_DEBUG_DEVICES is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
# CONFIG_CFG80211_REG_DEBUG is not set
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
CONFIG_CFG80211_DEBUGFS=y
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
CONFIG_MAC80211=y
# CONFIG_MAC80211_RC_PID is not set
# CONFIG_MAC80211_RC_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT=""

#
# Some wireless drivers require a rate control algorithm
#
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
CONFIG_MAC80211_DEBUGFS=y
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
CONFIG_RFKILL_REGULATOR=y
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_DEBUG=y
CONFIG_CAIF=y
CONFIG_CAIF_DEBUG=y
CONFIG_CAIF_NETDEV=y
CONFIG_CAIF_USB=y
CONFIG_NFC=y
# CONFIG_NFC_DIGITAL is not set
# CONFIG_NFC_NCI is not set
CONFIG_NFC_HCI=y
CONFIG_NFC_SHDLC=y

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
CONFIG_NFC_SIM=y
CONFIG_NFC_PN544=y
# CONFIG_NFC_PN544_I2C is not set
# CONFIG_NFC_MICROREAD is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
# CONFIG_STANDALONE is not set
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
# CONFIG_MTD_OF_PARTS is not set
# CONFIG_MTD_AR7_PARTS is not set

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
# CONFIG_MTD_BLOCK is not set
# CONFIG_MTD_BLOCK_RO is not set
CONFIG_FTL=y
CONFIG_NFTL=y
# CONFIG_NFTL_RW is not set
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y

#
# RAM/ROM/Flash chip drivers
#
CONFIG_MTD_CFI=y
CONFIG_MTD_JEDECPROBE=y
CONFIG_MTD_GEN_PROBE=y
CONFIG_MTD_CFI_ADV_OPTIONS=y
CONFIG_MTD_CFI_NOSWAP=y
# CONFIG_MTD_CFI_BE_BYTE_SWAP is not set
# CONFIG_MTD_CFI_LE_BYTE_SWAP is not set
CONFIG_MTD_CFI_GEOMETRY=y
CONFIG_MTD_MAP_BANK_WIDTH_1=y
CONFIG_MTD_MAP_BANK_WIDTH_2=y
CONFIG_MTD_MAP_BANK_WIDTH_4=y
CONFIG_MTD_MAP_BANK_WIDTH_8=y
CONFIG_MTD_MAP_BANK_WIDTH_16=y
# CONFIG_MTD_MAP_BANK_WIDTH_32 is not set
# CONFIG_MTD_CFI_I1 is not set
CONFIG_MTD_CFI_I2=y
# CONFIG_MTD_CFI_I4 is not set
CONFIG_MTD_CFI_I8=y
# CONFIG_MTD_OTP is not set
CONFIG_MTD_CFI_INTELEXT=y
CONFIG_MTD_CFI_AMDSTD=y
CONFIG_MTD_CFI_STAA=y
CONFIG_MTD_CFI_UTIL=y
CONFIG_MTD_RAM=y
CONFIG_MTD_ROM=y
# CONFIG_MTD_ABSENT is not set

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
CONFIG_MTD_PHYSMAP_OF=y
CONFIG_MTD_SC520CDP=y
# CONFIG_MTD_NETSC520 is not set
CONFIG_MTD_TS5500=y
# CONFIG_MTD_SBC_GXX is not set
CONFIG_MTD_SCx200_DOCFLASH=y
CONFIG_MTD_AMD76XROM=y
CONFIG_MTD_ICHXROM=y
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
CONFIG_MTD_L440GX=y
# CONFIG_MTD_PCI is not set
CONFIG_MTD_GPIO_ADDR=y
# CONFIG_MTD_INTEL_VR_NOR is not set
# CONFIG_MTD_PLATRAM is not set
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
# CONFIG_MTD_PMC551 is not set
CONFIG_MTD_SLRAM=y
CONFIG_MTD_PHRAM=y
CONFIG_MTD_MTDRAM=y
CONFIG_MTDRAM_TOTAL_SIZE=4096
CONFIG_MTDRAM_ERASE_SIZE=128
CONFIG_MTDRAM_ABS_POS=0
# CONFIG_MTD_BLOCK2MTD is not set

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
CONFIG_MTD_NAND_BCH=y
CONFIG_MTD_NAND_ECC_BCH=y
# CONFIG_MTD_SM_COMMON is not set
CONFIG_MTD_NAND_DENALI=y
# CONFIG_MTD_NAND_DENALI_PCI is not set
CONFIG_MTD_NAND_GPIO=y
CONFIG_MTD_NAND_IDS=y
# CONFIG_MTD_NAND_RICOH is not set
# CONFIG_MTD_NAND_DISKONCHIP is not set
CONFIG_MTD_NAND_DOCG4=y
# CONFIG_MTD_NAND_CAFE is not set
# CONFIG_MTD_NAND_CS553X is not set
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_NAND_SH_FLCTL=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR flash memory drivers
#
# CONFIG_MTD_LPDDR is not set
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
CONFIG_MTD_UBI_FASTMAP=y
CONFIG_MTD_UBI_GLUEBI=y
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_OF_SELFTEST is not set
CONFIG_OF_PROMTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_IRQ=y
CONFIG_OF_NET=y
CONFIG_OF_MDIO=y
CONFIG_OF_PCI=y
CONFIG_OF_PCI_IRQ=y
CONFIG_OF_MTD=y
# CONFIG_PARPORT is not set
CONFIG_ARCH_MIGHT_HAVE_PC_PARPORT=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
# CONFIG_BLK_DEV_NULL_BLK is not set
CONFIG_BLK_DEV_FD=y
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_OSD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
# CONFIG_CDROM_PKTCDVD is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_VIRTIO_BLK=y
CONFIG_BLK_DEV_HD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
# CONFIG_PHANTOM is not set
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
# CONFIG_TIFM_CORE is not set
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
# CONFIG_ENCLOSURE_SERVICES is not set
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
# CONFIG_ISL29003 is not set
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
# CONFIG_BMP085_I2C is not set
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
# CONFIG_EEPROM_AT24 is not set
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_INTEL_MEI_ME is not set
# CONFIG_INTEL_MEI_TXE is not set
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
CONFIG_SCSI_NETLINK=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
# CONFIG_CHR_DEV_SCH is not set
# CONFIG_SCSI_MULTI_LUN is not set
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_ISCSI_ATTRS is not set
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_SAS_HOST_SMP is not set
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_BOOT_SYSFS=y
# CONFIG_SCSI_BNX2_ISCSI is not set
# CONFIG_SCSI_BNX2X_FCOE is not set
# CONFIG_BE2ISCSI is not set
# CONFIG_BLK_DEV_3W_XXXX_RAID is not set
# CONFIG_SCSI_HPSA is not set
# CONFIG_SCSI_3W_9XXX is not set
# CONFIG_SCSI_3W_SAS is not set
# CONFIG_SCSI_ACARD is not set
# CONFIG_SCSI_AACRAID is not set
# CONFIG_SCSI_AIC7XXX is not set
# CONFIG_SCSI_AIC79XX is not set
# CONFIG_SCSI_AIC94XX is not set
# CONFIG_SCSI_MVSAS is not set
# CONFIG_SCSI_MVUMI is not set
# CONFIG_SCSI_DPT_I2O is not set
# CONFIG_SCSI_ADVANSYS is not set
# CONFIG_SCSI_ARCMSR is not set
# CONFIG_SCSI_ESAS2R is not set
# CONFIG_MEGARAID_NEWGEN is not set
# CONFIG_MEGARAID_LEGACY is not set
# CONFIG_MEGARAID_SAS is not set
# CONFIG_SCSI_MPT2SAS is not set
# CONFIG_SCSI_MPT3SAS is not set
CONFIG_SCSI_UFSHCD=y
# CONFIG_SCSI_UFSHCD_PCI is not set
CONFIG_SCSI_UFSHCD_PLATFORM=y
# CONFIG_SCSI_HPTIOP is not set
# CONFIG_SCSI_BUSLOGIC is not set
# CONFIG_VMWARE_PVSCSI is not set
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
# CONFIG_FCOE is not set
# CONFIG_FCOE_FNIC is not set
# CONFIG_SCSI_DMX3191D is not set
# CONFIG_SCSI_EATA is not set
# CONFIG_SCSI_FUTURE_DOMAIN is not set
# CONFIG_SCSI_GDTH is not set
# CONFIG_SCSI_ISCI is not set
# CONFIG_SCSI_IPS is not set
# CONFIG_SCSI_INITIO is not set
# CONFIG_SCSI_INIA100 is not set
# CONFIG_SCSI_STEX is not set
# CONFIG_SCSI_SYM53C8XX_2 is not set
# CONFIG_SCSI_QLOGIC_1280 is not set
# CONFIG_SCSI_QLA_FC is not set
# CONFIG_SCSI_QLA_ISCSI is not set
# CONFIG_SCSI_LPFC is not set
# CONFIG_SCSI_DC395x is not set
# CONFIG_SCSI_DC390T is not set
# CONFIG_SCSI_NSP32 is not set
CONFIG_SCSI_DEBUG=y
# CONFIG_SCSI_PMCRAID is not set
# CONFIG_SCSI_PM8001 is not set
# CONFIG_SCSI_SRP is not set
# CONFIG_SCSI_BFA_FC is not set
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
# CONFIG_ATA is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
# CONFIG_MD_LINEAR is not set
# CONFIG_MD_RAID0 is not set
# CONFIG_MD_RAID1 is not set
# CONFIG_MD_RAID10 is not set
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
# CONFIG_BCACHE is not set
# CONFIG_BLK_DEV_DM is not set
CONFIG_TARGET_CORE=y
# CONFIG_TCM_IBLOCK is not set
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_FIREWIRE is not set
# CONFIG_FIREWIRE_NOSY is not set
# CONFIG_I2O is not set
# CONFIG_MACINTOSH_DRIVERS is not set
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
# CONFIG_ARCNET is not set
CONFIG_ATM_DRIVERS=y
# CONFIG_ATM_DUMMY is not set
# CONFIG_ATM_LANAI is not set
# CONFIG_ATM_ENI is not set
# CONFIG_ATM_FIRESTREAM is not set
# CONFIG_ATM_ZATM is not set
# CONFIG_ATM_NICSTAR is not set
# CONFIG_ATM_IDT77252 is not set
# CONFIG_ATM_AMBASSADOR is not set
# CONFIG_ATM_HORIZON is not set
# CONFIG_ATM_IA is not set
# CONFIG_ATM_FORE200E is not set
# CONFIG_ATM_HE is not set
# CONFIG_ATM_SOLOS is not set

#
# CAIF transport drivers
#
# CONFIG_CAIF_TTY is not set
CONFIG_CAIF_SPI_SLAVE=y
# CONFIG_CAIF_SPI_SYNC is not set
CONFIG_CAIF_HSI=y
# CONFIG_CAIF_VIRTIO is not set
CONFIG_VHOST_NET=y
CONFIG_VHOST_RING=y
CONFIG_VHOST=y

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
CONFIG_NET_DSA_MV88E6123_61_65=y
CONFIG_ETHERNET=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
# CONFIG_ACENIC is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
CONFIG_NET_VENDOR_ARC=y
CONFIG_ARC_EMAC=y
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
# CONFIG_ATL1 is not set
# CONFIG_ATL1E is not set
# CONFIG_ATL1C is not set
# CONFIG_ALX is not set
CONFIG_NET_CADENCE=y
CONFIG_ARM_AT91_ETHER=y
CONFIG_MACB=y
# CONFIG_NET_VENDOR_BROADCOM is not set
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
# CONFIG_CHELSIO_T1 is not set
# CONFIG_CHELSIO_T4 is not set
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
# CONFIG_ENIC is not set
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DL2K is not set
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
# CONFIG_BE2NET is not set
CONFIG_NET_VENDOR_EXAR=y
# CONFIG_S2IO is not set
# CONFIG_VXGE is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
# CONFIG_NET_VENDOR_INTEL is not set
# CONFIG_IP1000 is not set
# CONFIG_JME is not set
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
# CONFIG_SKGE is not set
# CONFIG_SKY2 is not set
CONFIG_NET_VENDOR_MELLANOX=y
# CONFIG_MLX4_EN is not set
# CONFIG_MLX4_CORE is not set
# CONFIG_MLX5_CORE is not set
# CONFIG_NET_VENDOR_MICREL is not set
# CONFIG_FEALNX is not set
# CONFIG_NET_VENDOR_NATSEMI is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
# CONFIG_HAMACHI is not set
# CONFIG_YELLOWFIN is not set
CONFIG_NET_VENDOR_QLOGIC=y
# CONFIG_QLA3XXX is not set
# CONFIG_QLCNIC is not set
# CONFIG_QLGE is not set
# CONFIG_NETXEN_NIC is not set
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
# CONFIG_R8169 is not set
CONFIG_SH_ETH=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
# CONFIG_SIS190 is not set
# CONFIG_SFC is not set
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_EPIC100 is not set
# CONFIG_SMSC911X is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
# CONFIG_NIU is not set
CONFIG_NET_VENDOR_TEHUTI=y
# CONFIG_TEHUTI is not set
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_NET_VENDOR_WIZNET is not set
# CONFIG_FDDI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
CONFIG_AT803X_PHY=y
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
# CONFIG_DAVICOM_PHY is not set
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
# CONFIG_CICADA_PHY is not set
# CONFIG_VITESSE_PHY is not set
CONFIG_SMSC_PHY=y
# CONFIG_BROADCOM_PHY is not set
# CONFIG_BCM7XXX_PHY is not set
CONFIG_BCM87XX_PHY=y
CONFIG_ICPLUS_PHY=y
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
# CONFIG_LSI_ET1011C_PHY is not set
# CONFIG_MICREL_PHY is not set
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_BUS_MUX=y
# CONFIG_MDIO_BUS_MUX_GPIO is not set
CONFIG_MDIO_BUS_MUX_MMIOREG=y
CONFIG_PPP=y
# CONFIG_PPP_BSDCOMP is not set
CONFIG_PPP_DEFLATE=y
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
CONFIG_USB_KAWETH=y
# CONFIG_USB_PEGASUS is not set
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
# CONFIG_USB_NET_SR9700 is not set
CONFIG_USB_NET_SR9800=y
# CONFIG_USB_NET_SMSC75XX is not set
CONFIG_USB_NET_SMSC95XX=y
# CONFIG_USB_NET_GL620A is not set
# CONFIG_USB_NET_NET1080 is not set
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
# CONFIG_USB_ARMLINUX is not set
# CONFIG_USB_EPSON2888 is not set
# CONFIG_USB_KC2190 is not set
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_NET_KALMIA=y
CONFIG_USB_NET_QMI_WWAN=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
# CONFIG_USB_SIERRA_NET is not set
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=y
# CONFIG_AIRO is not set
# CONFIG_ATMEL is not set
CONFIG_AT76C50X_USB=y
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
CONFIG_USB_NET_RNDIS_WLAN=y
# CONFIG_RTL8180 is not set
CONFIG_RTL8187=y
CONFIG_RTL8187_LEDS=y
# CONFIG_ADM8211 is not set
CONFIG_MAC80211_HWSIM=y
# CONFIG_MWL8K is not set
# CONFIG_ATH_CARDS is not set
# CONFIG_B43 is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_PIO=y
# CONFIG_B43LEGACY_DMA_AND_PIO_MODE is not set
# CONFIG_B43LEGACY_DMA_MODE is not set
CONFIG_B43LEGACY_PIO_MODE=y
CONFIG_BRCMUTIL=y
CONFIG_BRCMSMAC=y
CONFIG_BRCMFMAC=y
CONFIG_BRCMFMAC_SDIO=y
# CONFIG_BRCMFMAC_USB is not set
# CONFIG_BRCM_TRACING is not set
# CONFIG_BRCMDBG is not set
CONFIG_HOSTAP=y
# CONFIG_HOSTAP_FIRMWARE is not set
# CONFIG_HOSTAP_PLX is not set
# CONFIG_HOSTAP_PCI is not set
# CONFIG_IPW2100 is not set
# CONFIG_IWLWIFI is not set
# CONFIG_IWL4965 is not set
# CONFIG_IWL3945 is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
CONFIG_LIBERTAS_SDIO=y
# CONFIG_LIBERTAS_DEBUG is not set
# CONFIG_LIBERTAS_MESH is not set
CONFIG_P54_COMMON=y
# CONFIG_P54_USB is not set
# CONFIG_P54_PCI is not set
CONFIG_P54_LEDS=y
CONFIG_RT2X00=y
# CONFIG_RT2400PCI is not set
# CONFIG_RT2500PCI is not set
# CONFIG_RT61PCI is not set
# CONFIG_RT2800PCI is not set
CONFIG_RT2500USB=y
CONFIG_RT73USB=y
# CONFIG_RT2800USB is not set
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
CONFIG_RT2X00_LIB_DEBUGFS=y
CONFIG_RT2X00_DEBUG=y
CONFIG_RTL_CARDS=y
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8723AE is not set
# CONFIG_RTL8188EE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
CONFIG_ZD1211RW_DEBUG=y
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
# CONFIG_MWIFIEX_PCIE is not set
CONFIG_MWIFIEX_USB=y
# CONFIG_CW1200 is not set

#
# Enable WiMAX (Networking options) to see the WiMAX drivers
#
CONFIG_WAN=y
# CONFIG_HDLC is not set
# CONFIG_DLCI is not set
# CONFIG_LAPBETHER is not set
# CONFIG_X25_ASY is not set
CONFIG_SBNI=y
CONFIG_SBNI_MULTILINE=y
# CONFIG_IEEE802154_DRIVERS is not set
# CONFIG_ISDN is not set

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
CONFIG_INPUT_EVBUG=y

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
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
# CONFIG_KEYBOARD_LM8323 is not set
# CONFIG_KEYBOARD_LM8333 is not set
# CONFIG_KEYBOARD_MAX7359 is not set
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_STOWAWAY is not set
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_SH_KEYSC is not set
# CONFIG_KEYBOARD_TWL4030 is not set
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_LEDS=y
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
# CONFIG_TABLET_USB_AIPTEK is not set
# CONFIG_TABLET_USB_GTCO is not set
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_WACOM=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_88PM860X=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
CONFIG_TOUCHSCREEN_ATMEL_MXT=y
CONFIG_TOUCHSCREEN_AUO_PIXCIR=y
CONFIG_TOUCHSCREEN_BU21013=y
CONFIG_TOUCHSCREEN_CY8CTMG110=y
CONFIG_TOUCHSCREEN_CYTTSP_CORE=y
CONFIG_TOUCHSCREEN_CYTTSP_I2C=y
CONFIG_TOUCHSCREEN_CYTTSP4_CORE=y
# CONFIG_TOUCHSCREEN_CYTTSP4_I2C is not set
# CONFIG_TOUCHSCREEN_DA9052 is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
# CONFIG_TOUCHSCREEN_HAMPSHIRE is not set
CONFIG_TOUCHSCREEN_EETI=y
# CONFIG_TOUCHSCREEN_EGALAX is not set
CONFIG_TOUCHSCREEN_FUJITSU=y
CONFIG_TOUCHSCREEN_ILI210X=y
# CONFIG_TOUCHSCREEN_GUNZE is not set
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
CONFIG_TOUCHSCREEN_WACOM_I2C=y
CONFIG_TOUCHSCREEN_MAX11801=y
# CONFIG_TOUCHSCREEN_MCS5000 is not set
CONFIG_TOUCHSCREEN_MMS114=y
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
# CONFIG_TOUCHSCREEN_MK712 is not set
# CONFIG_TOUCHSCREEN_PENMOUNT is not set
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
# CONFIG_TOUCHSCREEN_TOUCHWIN is not set
# CONFIG_TOUCHSCREEN_TI_AM335X_TSC is not set
CONFIG_TOUCHSCREEN_PIXCIR=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_MC13783=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
# CONFIG_TOUCHSCREEN_USB_3M is not set
CONFIG_TOUCHSCREEN_USB_ITM=y
# CONFIG_TOUCHSCREEN_USB_ETURBO is not set
CONFIG_TOUCHSCREEN_USB_GUNZE=y
# CONFIG_TOUCHSCREEN_USB_DMC_TSC10 is not set
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
# CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH is not set
# CONFIG_TOUCHSCREEN_USB_GOTOP is not set
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_ELO=y
# CONFIG_TOUCHSCREEN_USB_E2I is not set
# CONFIG_TOUCHSCREEN_USB_ZYTRONIC is not set
# CONFIG_TOUCHSCREEN_USB_ETT_TC45USB is not set
# CONFIG_TOUCHSCREEN_USB_NEXIO is not set
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
CONFIG_TOUCHSCREEN_TSC_SERIO=y
CONFIG_TOUCHSCREEN_TSC2007=y
CONFIG_TOUCHSCREEN_ST1232=y
# CONFIG_TOUCHSCREEN_SUR40 is not set
# CONFIG_TOUCHSCREEN_TPS6507X is not set
CONFIG_TOUCHSCREEN_ZFORCE=y
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_ARCH_MIGHT_HAVE_PC_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
# CONFIG_SERIO_ALTERA_PS2 is not set
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_SERIO_APBPS2 is not set
CONFIG_SERIO_OLPC_APSP=y
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
# CONFIG_GAMEPORT_FM801 is not set

#
# Character devices
#
CONFIG_TTY=y
# CONFIG_VT is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_DEVPTS_MULTIPLE_INSTANCES is not set
CONFIG_LEGACY_PTYS=y
CONFIG_LEGACY_PTY_COUNT=256
# CONFIG_SERIAL_NONSTANDARD is not set
# CONFIG_NOZOMI is not set
# CONFIG_N_GSM is not set
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_DEPRECATED_OPTIONS=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_CLPS711X is not set
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_SH_SCI is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_OF_PLATFORM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_SERIAL_FSL_LPUART is not set
# CONFIG_SERIAL_ST_ASC is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_ARB_GPIO_CHALLENGE is not set
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
# CONFIG_I2C_ALGOPCF is not set
CONFIG_I2C_ALGOPCA=y

#
# I2C Hardware Bus support
#

#
# PC SMBus host controller drivers
#
# CONFIG_I2C_ALI1535 is not set
# CONFIG_I2C_ALI1563 is not set
# CONFIG_I2C_ALI15X3 is not set
# CONFIG_I2C_AMD756 is not set
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
# CONFIG_I2C_PIIX4 is not set
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
# CONFIG_I2C_SIS630 is not set
# CONFIG_I2C_SIS96X is not set
# CONFIG_I2C_VIA is not set
# CONFIG_I2C_VIAPRO is not set

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
CONFIG_I2C_DESIGNWARE_CORE=y
CONFIG_I2C_DESIGNWARE_PLATFORM=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
CONFIG_I2C_GPIO=y
CONFIG_I2C_KEMPLD=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_RIIC=y
# CONFIG_I2C_SH_MOBILE is not set
# CONFIG_I2C_SIMTEC is not set
CONFIG_I2C_XILINX=y
# CONFIG_I2C_RCAR is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y
CONFIG_I2C_VIPERBOARD=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_SCx200_I2C=y
CONFIG_SCx200_I2C_SCL=12
CONFIG_SCx200_I2C_SDA=13
# CONFIG_SCx200_ACB is not set
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
# CONFIG_SPMI is not set
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
CONFIG_NTP_PPS=y

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
CONFIG_PPS_CLIENT_GPIO=y

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set

#
# Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks.
#
# CONFIG_PTP_1588_CLOCK_PCH is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
CONFIG_GPIO_CLPS711X=y
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_F7188X is not set
# CONFIG_GPIO_SCH311X is not set
CONFIG_GPIO_TS5500=y
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_GRGPIO=y

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
CONFIG_GPIO_PCA953X_IRQ=y
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_SX150X=y
# CONFIG_GPIO_TPS65912 is not set
CONFIG_GPIO_TWL4030=y
# CONFIG_GPIO_TWL6040 is not set
# CONFIG_GPIO_WM8350 is not set
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
# CONFIG_GPIO_ADNP is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_INTEL_MID is not set
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_SODAVILLE is not set
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
CONFIG_GPIO_MCP23S08=y

#
# AC97 GPIO expanders:
#

#
# LPC GPIO expanders:
#
CONFIG_GPIO_KEMPLD=y

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_TPS6586X=y
CONFIG_GPIO_TPS65910=y
CONFIG_GPIO_BCM_KONA=y

#
# USB GPIO expanders:
#
CONFIG_GPIO_VIPERBOARD=y
CONFIG_W1=y

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_DS1WM=y
# CONFIG_W1_MASTER_GPIO is not set

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
CONFIG_W1_SLAVE_SMEM=y
# CONFIG_W1_SLAVE_DS2408 is not set
# CONFIG_W1_SLAVE_DS2413 is not set
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
CONFIG_W1_SLAVE_DS2781=y
CONFIG_W1_SLAVE_DS28E04=y
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
# CONFIG_WM8350_POWER is not set
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
# CONFIG_BATTERY_DS2760 is not set
CONFIG_BATTERY_DS2780=y
CONFIG_BATTERY_DS2781=y
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_OLPC=y
CONFIG_BATTERY_SBS=y
CONFIG_BATTERY_BQ27x00=y
# CONFIG_BATTERY_BQ27X00_I2C is not set
CONFIG_BATTERY_BQ27X00_PLATFORM=y
# CONFIG_BATTERY_DA9052 is not set
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_88PM860X is not set
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
CONFIG_CHARGER_TWL4030=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
# CONFIG_CHARGER_MANAGER is not set
CONFIG_CHARGER_MAX8998=y
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
CONFIG_CHARGER_BQ24735=y
# CONFIG_CHARGER_SMB347 is not set
CONFIG_CHARGER_TPS65090=y
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
# CONFIG_SENSORS_AD7414 is not set
# CONFIG_SENSORS_AD7418 is not set
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
# CONFIG_SENSORS_ADM9240 is not set
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
# CONFIG_SENSORS_ADT7470 is not set
CONFIG_SENSORS_ADT7475=y
# CONFIG_SENSORS_ASC7621 is not set
# CONFIG_SENSORS_K8TEMP is not set
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
# CONFIG_SENSORS_APPLESMC is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9052_ADC=y
CONFIG_SENSORS_DA9055=y
# CONFIG_SENSORS_I5K_AMB is not set
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_MC13783_ADC is not set
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_G760A is not set
# CONFIG_SENSORS_G762 is not set
# CONFIG_SENSORS_GPIO_FAN is not set
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
CONFIG_SENSORS_CORETEMP=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC4151=y
# CONFIG_SENSORS_LTC4215 is not set
CONFIG_SENSORS_LTC4222=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4260=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
# CONFIG_SENSORS_MAX6639 is not set
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
CONFIG_SENSORS_MAX6697=y
CONFIG_SENSORS_HTU21=y
CONFIG_SENSORS_MCP3021=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
CONFIG_SENSORS_LM85=y
# CONFIG_SENSORS_LM87 is not set
# CONFIG_SENSORS_LM90 is not set
CONFIG_SENSORS_LM92=y
# CONFIG_SENSORS_LM93 is not set
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PCF8591=y
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
CONFIG_SENSORS_ADM1275=y
# CONFIG_SENSORS_LM25066 is not set
CONFIG_SENSORS_LTC2978=y
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
# CONFIG_SENSORS_UCD9000 is not set
CONFIG_SENSORS_UCD9200=y
CONFIG_SENSORS_ZL6100=y
CONFIG_SENSORS_SHT15=y
# CONFIG_SENSORS_SHT21 is not set
# CONFIG_SENSORS_SIS5595 is not set
# CONFIG_SENSORS_DME1737 is not set
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
CONFIG_SENSORS_SCH5636=y
CONFIG_SENSORS_SMM665=y
# CONFIG_SENSORS_ADC128D818 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_AMC6821=y
CONFIG_SENSORS_INA209=y
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
# CONFIG_SENSORS_TMP102 is not set
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
CONFIG_SENSORS_VIA_CPUTEMP=y
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
CONFIG_SENSORS_W83781D=y
# CONFIG_SENSORS_W83791D is not set
# CONFIG_SENSORS_W83792D is not set
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM8350 is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
# CONFIG_THERMAL_HWMON is not set
# CONFIG_THERMAL_OF is not set
# CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE is not set
CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
CONFIG_THERMAL_GOV_FAIR_SHARE=y
# CONFIG_THERMAL_GOV_STEP_WISE is not set
CONFIG_THERMAL_GOV_USER_SPACE=y
CONFIG_THERMAL_EMULATION=y
CONFIG_RCAR_THERMAL=y
CONFIG_INTEL_POWERCLAMP=y
# CONFIG_ACPI_INT3403_THERMAL is not set

#
# Texas Instruments thermal drivers
#
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_DA9052_WATCHDOG=y
# CONFIG_DA9055_WATCHDOG is not set
CONFIG_GPIO_WATCHDOG=y
CONFIG_WM8350_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
CONFIG_TWL4030_WATCHDOG=y
CONFIG_RETU_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
# CONFIG_IE6XX_WDT is not set
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
# CONFIG_HP_WATCHDOG is not set
CONFIG_KEMPLD_WDT=y
CONFIG_SC1200_WDT=y
# CONFIG_SCx200_WDT is not set
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
CONFIG_RDC321X_WDT=y
CONFIG_60XX_WDT=y
# CONFIG_SBC8360_WDT is not set
CONFIG_SBC7240_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
# CONFIG_SMSC37B787_WDT is not set
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
# CONFIG_W83977F_WDT is not set
# CONFIG_MACHZ_WDT is not set
CONFIG_SBC_EPX_C3_WATCHDOG=y
# CONFIG_MEN_A21_WDT is not set

#
# PCI-based Watchdog Cards
#
# CONFIG_PCIPCWATCHDOG is not set
# CONFIG_WDTPCI is not set

#
# USB-based Watchdog Cards
#
CONFIG_USBPCWATCHDOG=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_SILENT is not set
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
CONFIG_SSB_DRIVER_GPIO=y
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_MFD_AS3722=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_DA9063 is not set
CONFIG_MFD_MC13XXX=y
CONFIG_MFD_MC13XXX_I2C=y
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_LPC_ICH is not set
# CONFIG_LPC_SCH is not set
# CONFIG_MFD_JANZ_CMODIO is not set
CONFIG_MFD_KEMPLD=y
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
CONFIG_MFD_VIPERBOARD=y
CONFIG_MFD_RETU=y
# CONFIG_MFD_PCF50633 is not set
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_TPS6105X is not set
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
# CONFIG_MFD_TPS65217 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
CONFIG_MFD_TPS80031=y
CONFIG_TWL4030_CORE=y
# CONFIG_TWL4030_MADC is not set
# CONFIG_MFD_TWL4030_AUDIO is not set
CONFIG_TWL6040_CORE=y
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_MFD_TIMBERDALE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_VX855 is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_WM8400 is not set
# CONFIG_MFD_WM831X_I2C is not set
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
CONFIG_REGULATOR_88PM800=y
CONFIG_REGULATOR_88PM8607=y
CONFIG_REGULATOR_ACT8865=y
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_AAT2870 is not set
# CONFIG_REGULATOR_AS3722 is not set
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9210=y
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_LP8755=y
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8907 is not set
CONFIG_REGULATOR_MAX8925=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
CONFIG_REGULATOR_MC13XXX_CORE=y
CONFIG_REGULATOR_MC13783=y
CONFIG_REGULATOR_MC13892=y
CONFIG_REGULATOR_PFUZE100=y
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
CONFIG_REGULATOR_TPS65090=y
CONFIG_REGULATOR_TPS6586X=y
# CONFIG_REGULATOR_TPS65910 is not set
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_TPS80031=y
CONFIG_REGULATOR_TWL4030=y
CONFIG_REGULATOR_WM8350=y
# CONFIG_MEDIA_SUPPORT is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
# CONFIG_VIDEO_OUTPUT_CONTROL is not set
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
# CONFIG_FB_DDC is not set
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
# CONFIG_FB_FOREIGN_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
# CONFIG_FB_SVGALIB is not set
# CONFIG_FB_MACMODES is not set
# CONFIG_FB_BACKLIGHT is not set
CONFIG_FB_MODE_HELPERS=y
# CONFIG_FB_TILEBLITTING is not set

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
CONFIG_FB_S1D13XXX=y
# CONFIG_FB_NVIDIA is not set
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
# CONFIG_FB_LE80578 is not set
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
# CONFIG_FB_ATY is not set
# CONFIG_FB_S3 is not set
# CONFIG_FB_SAVAGE is not set
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
# CONFIG_FB_NEOMAGIC is not set
# CONFIG_FB_KYRO is not set
# CONFIG_FB_3DFX is not set
# CONFIG_FB_VOODOO1 is not set
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
# CONFIG_FB_PM3 is not set
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
CONFIG_FB_TMIO=y
CONFIG_FB_TMIO_ACCELL=y
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
CONFIG_FB_GOLDFISH=y
CONFIG_FB_VIRTUAL=y
# CONFIG_FB_METRONOME is not set
# CONFIG_FB_MB862XX is not set
# CONFIG_FB_BROADSHEET is not set
CONFIG_FB_AUO_K190X=y
CONFIG_FB_AUO_K1900=y
CONFIG_FB_AUO_K1901=y
# CONFIG_FB_SIMPLE is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
CONFIG_LCD_PLATFORM=y
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_AAT2870=y
# CONFIG_BACKLIGHT_LM3630A is not set
CONFIG_BACKLIGHT_LM3639=y
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_PANDORA=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
# CONFIG_BACKLIGHT_BD6107 is not set
CONFIG_LOGO=y
CONFIG_LOGO_LINUX_MONO=y
# CONFIG_LOGO_LINUX_VGA16 is not set
# CONFIG_LOGO_LINUX_CLUT224 is not set
# CONFIG_FB_SSD1307 is not set
CONFIG_SOUND=y
# CONFIG_SOUND_OSS_CORE is not set
# CONFIG_SND is not set
# CONFIG_SOUND_PRIME is not set

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
CONFIG_UHID=y
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
CONFIG_HID_APPLEIR=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
# CONFIG_DRAGONRISE_FF is not set
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
# CONFIG_HID_ELO is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_HUION is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
CONFIG_HID_ICADE=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
CONFIG_HID_LENOVO_TPKBD=y
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
# CONFIG_LOGITECH_FF is not set
CONFIG_LOGIRUMBLEPAD2_FF=y
# CONFIG_LOGIG940_FF is not set
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
CONFIG_HID_PANTHERLORD=y
CONFIG_PANTHERLORD_FF=y
CONFIG_HID_PETALYNX=y
CONFIG_HID_PICOLCD=y
CONFIG_HID_PICOLCD_FB=y
CONFIG_HID_PICOLCD_BACKLIGHT=y
# CONFIG_HID_PICOLCD_LCD is not set
# CONFIG_HID_PICOLCD_LEDS is not set
CONFIG_HID_PRIMAX=y
# CONFIG_HID_ROCCAT is not set
CONFIG_HID_SAITEK=y
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_SONY_FF is not set
CONFIG_HID_SPEEDLINK=y
CONFIG_HID_STEELSERIES=y
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
# CONFIG_THRUSTMASTER_FF is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_XINMO is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
CONFIG_HID_SENSOR_HUB=y

#
# USB HID support
#
CONFIG_USB_HID=y
# CONFIG_HID_PID is not set
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
CONFIG_I2C_HID=y
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DEFAULT_PERSIST=y
# CONFIG_USB_DYNAMIC_MINORS is not set
CONFIG_USB_OTG=y
# CONFIG_USB_OTG_WHITELIST is not set
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
# CONFIG_USB_XHCI_HCD is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
# CONFIG_USB_OXU210HP_HCD is not set
# CONFIG_USB_ISP116X_HCD is not set
# CONFIG_USB_ISP1760_HCD is not set
CONFIG_USB_ISP1362_HCD=y
CONFIG_USB_FUSBH200_HCD=y
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PCI=y
# CONFIG_USB_OHCI_HCD_SSB is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_HCD_BCMA=y
CONFIG_USB_HCD_SSB=y
# CONFIG_USB_HCD_TEST_MODE is not set

#
# USB Device Class drivers
#
# CONFIG_USB_ACM is not set
# CONFIG_USB_PRINTER is not set
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
CONFIG_USB_STORAGE_DEBUG=y
# CONFIG_USB_STORAGE_REALTEK is not set
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
# CONFIG_USB_STORAGE_ISD200 is not set
# CONFIG_USB_STORAGE_USBAT is not set
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
# CONFIG_USB_STORAGE_ALAUDA is not set
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
CONFIG_USB_STORAGE_ENE_UB6250=y

#
# USB Imaging devices
#
# CONFIG_USB_MDC800 is not set
CONFIG_USB_MICROTEK=y
CONFIG_USB_MUSB_HDRC=y
CONFIG_USB_MUSB_HOST=y
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_HOST=y

#
# Platform Glue Driver Support
#
CONFIG_USB_DWC3_OMAP=y
# CONFIG_USB_DWC3_EXYNOS is not set
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_KEYSTONE=y

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
# CONFIG_USB_DWC3_VERBOSE is not set
CONFIG_USB_DWC2=y
# CONFIG_USB_DWC2_DEBUG is not set
CONFIG_USB_DWC2_TRACK_MISSED_SOFS=y
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_HOST=y
# CONFIG_USB_CHIPIDEA_DEBUG is not set

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
# CONFIG_USB_SEVSEG is not set
# CONFIG_USB_RIO500 is not set
CONFIG_USB_LEGOTOWER=y
# CONFIG_USB_LCD is not set
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
# CONFIG_USB_SISUSBVGA is not set
# CONFIG_USB_LD is not set
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
# CONFIG_USB_TEST is not set
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
CONFIG_USB_HSIC_USB3503=y
CONFIG_USB_ATM=y
# CONFIG_USB_SPEEDTOUCH is not set
CONFIG_USB_CXACRU=y
# CONFIG_USB_UEAGLEATM is not set
CONFIG_USB_XUSBATM=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
CONFIG_USB_OTG_FSM=y
# CONFIG_KEYSTONE_USB_PHY is not set
# CONFIG_NOP_USB_XCEIV is not set
CONFIG_OMAP_CONTROL_USB=y
CONFIG_OMAP_USB3=y
# CONFIG_AM335X_PHY_USB is not set
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
CONFIG_SAMSUNG_USB3PHY=y
CONFIG_USB_GPIO_VBUS=y
CONFIG_TAHVO_USB=y
# CONFIG_TAHVO_USB_HOST_BY_DEFAULT is not set
# CONFIG_USB_ISP1301 is not set
CONFIG_USB_RCAR_PHY=y
# CONFIG_USB_RCAR_GEN2_PHY is not set
# CONFIG_USB_GADGET is not set
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
# CONFIG_MMC_BLOCK_BOUNCE is not set
# CONFIG_SDIO_UART is not set
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_SDHCI_OF_ARASAN=y
CONFIG_MMC_OMAP_HS=y
# CONFIG_MMC_WBSD is not set
# CONFIG_MMC_TIFM_SD is not set
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_SH_MMCIF=y
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_LM3530=y
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_NET48XX=y
# CONFIG_LEDS_WRAP is not set
CONFIG_LEDS_PCA9532=y
CONFIG_LEDS_PCA9532_GPIO=y
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
CONFIG_LEDS_LP5523=y
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8501=y
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA963X=y
CONFIG_LEDS_PCA9685=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_REGULATOR=y
# CONFIG_LEDS_BD2802 is not set
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_MC13783=y
# CONFIG_LEDS_TCA6507 is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
# CONFIG_LEDS_BLINKM is not set

#
# LED Triggers
#
CONFIG_LEDS_TRIGGERS=y
CONFIG_LEDS_TRIGGER_TIMER=y
CONFIG_LEDS_TRIGGER_ONESHOT=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_LEDS_TRIGGER_GPIO=y
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_LEDS_TRIGGER_CAMERA=y
# CONFIG_ACCESSIBILITY is not set
CONFIG_EDAC=y
# CONFIG_EDAC_LEGACY_SYSFS is not set
CONFIG_EDAC_DEBUG=y
CONFIG_EDAC_MM_EDAC=y
# CONFIG_EDAC_AMD76X is not set
# CONFIG_EDAC_E7XXX is not set
# CONFIG_EDAC_E752X is not set
# CONFIG_EDAC_I82875P is not set
# CONFIG_EDAC_I82975X is not set
# CONFIG_EDAC_I3000 is not set
# CONFIG_EDAC_I3200 is not set
# CONFIG_EDAC_X38 is not set
# CONFIG_EDAC_I5400 is not set
# CONFIG_EDAC_I82860 is not set
# CONFIG_EDAC_R82600 is not set
# CONFIG_EDAC_I5000 is not set
# CONFIG_EDAC_I5100 is not set
# CONFIG_EDAC_I7300 is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

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
CONFIG_RTC_DRV_88PM80X=y
CONFIG_RTC_DRV_AS3722=y
# CONFIG_RTC_DRV_DS1307 is not set
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
CONFIG_RTC_DRV_DS3232=y
# CONFIG_RTC_DRV_HYM8563 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
CONFIG_RTC_DRV_MAX8925=y
CONFIG_RTC_DRV_MAX8998=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
CONFIG_RTC_DRV_ISL12022=y
CONFIG_RTC_DRV_ISL12057=y
CONFIG_RTC_DRV_X1205=y
CONFIG_RTC_DRV_PCF2127=y
CONFIG_RTC_DRV_PCF8523=y
CONFIG_RTC_DRV_PCF8563=y
# CONFIG_RTC_DRV_PCF8583 is not set
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_TWL4030 is not set
# CONFIG_RTC_DRV_TPS6586X is not set
CONFIG_RTC_DRV_TPS65910=y
# CONFIG_RTC_DRV_TPS80031 is not set
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
# CONFIG_RTC_DRV_RX8025 is not set
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
# CONFIG_RTC_DRV_CMOS is not set
# CONFIG_RTC_DRV_DS1286 is not set
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
# CONFIG_RTC_DRV_DA9052 is not set
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set
# CONFIG_RTC_DRV_WM8350 is not set

#
# on-CPU RTC drivers
#
CONFIG_RTC_DRV_MC13XXX=y
CONFIG_RTC_DRV_SNVS=y
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
CONFIG_RTC_DRV_HID_SENSOR_TIME=y
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_TIMB_DMA=y
# CONFIG_PCH_DMA is not set
CONFIG_FSL_EDMA=y
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
# CONFIG_DMATEST is not set
CONFIG_AUXDISPLAY=y
# CONFIG_UIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
# CONFIG_VIRTIO_PCI is not set
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_USBIP_CORE is not set
CONFIG_W35UND=y
CONFIG_PRISM2_USB=y
CONFIG_ECHO=y
CONFIG_FB_OLPC_DCON=y
CONFIG_FB_OLPC_DCON_1_5=y
CONFIG_R8712U=y
CONFIG_R8188EU=y
# CONFIG_88EU_AP_MODE is not set
# CONFIG_88EU_P2P is not set
CONFIG_RTS5139=y
# CONFIG_RTS5139_DEBUG is not set
# CONFIG_RTS5208 is not set
# CONFIG_TRANZPORT is not set
# CONFIG_DX_SEP is not set

#
# IIO staging drivers
#

#
# Accelerometers
#

#
# Analog to digital converters
#
# CONFIG_AD7291 is not set
# CONFIG_AD7606 is not set
CONFIG_AD799X=y
CONFIG_AD799X_RING_BUFFER=y
CONFIG_LPC32XX_ADC=y
# CONFIG_MXS_LRADC is not set
CONFIG_SPEAR_ADC=y

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
CONFIG_AD7152=y
CONFIG_AD7746=y

#
# Direct Digital Synthesis
#

#
# Digital gyroscope sensors
#

#
# Network Analyzer, Impedance Converters
#
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
CONFIG_SENSORS_ISL29028=y
CONFIG_TSL2583=y
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
# CONFIG_SENSORS_HMC5843 is not set

#
# Active energy metering IC
#
# CONFIG_ADE7854 is not set

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_PERIODIC_RTC_TRIGGER is not set
CONFIG_IIO_SIMPLE_DUMMY=y
# CONFIG_IIO_SIMPLE_DUMMY_EVENTS is not set
CONFIG_IIO_SIMPLE_DUMMY_BUFFER=y
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_BCM_WIMAX=y
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_USB_WPAN_HCD=y
CONFIG_WIMAX_GDM72XX=y
# CONFIG_WIMAX_GDM72XX_QOS is not set
CONFIG_WIMAX_GDM72XX_K_MODE=y
# CONFIG_WIMAX_GDM72XX_WIMAX2 is not set
# CONFIG_WIMAX_GDM72XX_USB is not set
CONFIG_WIMAX_GDM72XX_SDIO=y
# CONFIG_NET_VENDOR_SILICOM is not set
CONFIG_CED1401=y
# CONFIG_DGRP is not set
CONFIG_XILLYBUS=y
# CONFIG_XILLYBUS_PCIE is not set
# CONFIG_XILLYBUS_OF is not set
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACERHDF is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
# CONFIG_ACPI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
CONFIG_CHROME_PLATFORMS=y
CONFIG_CHROMEOS_PSTORE=y

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_SUPPORT=y
CONFIG_OF_IOMMU=y

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
# CONFIG_PM_DEVFREQ is not set
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
CONFIG_OF_EXTCON=y
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_MEMORY is not set
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
# CONFIG_IIO_BUFFER_CB is not set
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
# CONFIG_HID_SENSOR_ACCEL_3D is not set
# CONFIG_IIO_ST_ACCEL_3AXIS is not set

#
# Analog to digital converters
#
# CONFIG_EXYNOS_ADC is not set
CONFIG_MAX1363=y
# CONFIG_MCP3422 is not set
CONFIG_NAU7802=y
# CONFIG_TI_ADC081C is not set
CONFIG_TI_AM335X_ADC=y
# CONFIG_TWL6030_GPADC is not set
CONFIG_VIPERBOARD_ADC=y

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_HID_SENSOR_IIO_COMMON=y
CONFIG_HID_SENSOR_IIO_TRIGGER=y
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
# CONFIG_AD5064 is not set
# CONFIG_AD5380 is not set
CONFIG_AD5446=y
# CONFIG_MAX517 is not set
CONFIG_MCP4725=y

#
# Frequency Synthesizers DDS/PLL
#

#
# Clock Generator/Distribution
#

#
# Phase-Locked Loop (PLL) frequency synthesizers
#

#
# Digital gyroscope sensors
#
CONFIG_HID_SENSOR_GYRO_3D=y
# CONFIG_IIO_ST_GYRO_3AXIS is not set
# CONFIG_ITG3200 is not set

#
# Humidity sensors
#
CONFIG_DHT11=y
CONFIG_SI7005=y

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
CONFIG_ADJD_S311=y
CONFIG_APDS9300=y
# CONFIG_CM32181 is not set
CONFIG_CM36651=y
CONFIG_GP2AP020A00F=y
# CONFIG_HID_SENSOR_ALS is not set
CONFIG_LTR501=y
CONFIG_TCS3472=y
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
CONFIG_AK8975=y
CONFIG_MAG3110=y
CONFIG_HID_SENSOR_MAGNETOMETER_3D=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y

#
# Inclinometer sensors
#
CONFIG_HID_SENSOR_INCLINOMETER_3D=y

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
CONFIG_IIO_SYSFS_TRIGGER=y

#
# Pressure sensors
#
CONFIG_MPL3115=y
# CONFIG_IIO_ST_PRESS is not set

#
# Temperature sensors
#
# CONFIG_TMP006 is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
CONFIG_IRQCHIP=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
CONFIG_RESET_CONTROLLER=y
# CONFIG_FMC is not set

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
CONFIG_PHY_EXYNOS_DP_VIDEO=y
CONFIG_BCM_KONA_USB2_PHY=y
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y

#
# Firmware Drivers
#
# CONFIG_EDD is not set
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
# CONFIG_ISCSI_IBFT_FIND is not set
CONFIG_GOOGLE_FIRMWARE=y

#
# Google Firmware Drivers
#

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
CONFIG_EXT2_FS=y
CONFIG_EXT2_FS_XATTR=y
CONFIG_EXT2_FS_POSIX_ACL=y
CONFIG_EXT2_FS_SECURITY=y
# CONFIG_EXT2_FS_XIP is not set
CONFIG_EXT3_FS=y
CONFIG_EXT3_DEFAULTS_TO_ORDERED=y
CONFIG_EXT3_FS_XATTR=y
CONFIG_EXT3_FS_POSIX_ACL=y
CONFIG_EXT3_FS_SECURITY=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
CONFIG_EXT4_FS_SECURITY=y
# CONFIG_EXT4_DEBUG is not set
CONFIG_JBD=y
CONFIG_JBD_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
# CONFIG_JFS_FS is not set
# CONFIG_XFS_FS is not set
# CONFIG_GFS2_FS is not set
# CONFIG_OCFS2_FS is not set
# CONFIG_BTRFS_FS is not set
# CONFIG_NILFS2_FS is not set
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
# CONFIG_INOTIFY_USER is not set
CONFIG_FANOTIFY=y
CONFIG_FANOTIFY_ACCESS_PERMISSIONS=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTACTL is not set
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_DEBUG=y
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set

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
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
# CONFIG_ADFS_FS is not set
CONFIG_AFFS_FS=y
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_HFSPLUS_FS_POSIX_ACL=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
# CONFIG_BFS_FS is not set
# CONFIG_EFS_FS is not set
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
# CONFIG_JFFS2_RTIME is not set
CONFIG_JFFS2_RUBIN=y
# CONFIG_JFFS2_CMODE_NONE is not set
# CONFIG_JFFS2_CMODE_PRIORITY is not set
# CONFIG_JFFS2_CMODE_SIZE is not set
CONFIG_JFFS2_CMODE_FAVOURLZO=y
# CONFIG_UBIFS_FS is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
# CONFIG_OMFS_FS is not set
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
# CONFIG_ROMFS_FS is not set
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
CONFIG_PSTORE_RAM=y
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
CONFIG_EXOFS_DEBUG=y
# CONFIG_F2FS_FS is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
CONFIG_NLS_CODEPAGE_1250=y
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
# CONFIG_NLS_ISO8859_1 is not set
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
# CONFIG_NLS_ISO8859_4 is not set
CONFIG_NLS_ISO8859_5=y
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
# CONFIG_NLS_ISO8859_14 is not set
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
# CONFIG_NLS_MAC_GREEK is not set
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
CONFIG_NLS_MAC_ROMANIAN=y
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y

#
# printk and dmesg options
#
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_BOOT_PRINTK_DELAY=y
CONFIG_DYNAMIC_DEBUG=y

#
# Compile-time checks and compiler options
#
CONFIG_ENABLE_WARN_DEPRECATED=y
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
# CONFIG_STRIP_ASM_SYMS is not set
CONFIG_READABLE_ASM=y
# CONFIG_UNUSED_SYMBOLS is not set
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
# CONFIG_MAGIC_SYSRQ is not set
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
# CONFIG_DEBUG_STACKOVERFLOW is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_DEBUG_SHIRQ is not set

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
# CONFIG_BOOTPARAM_HUNG_TASK_PANIC is not set
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=0
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
# CONFIG_DEBUG_PREEMPT is not set

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
# CONFIG_RT_MUTEX_TESTER is not set
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
# CONFIG_LOCK_TORTURE_TEST is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_LIST is not set
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
# CONFIG_PROVE_RCU_DELAY is not set
CONFIG_SPARSE_RCU_POINTER=y
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_VERBOSE is not set
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
CONFIG_FAIL_IO_TIMEOUT=y
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
# CONFIG_TEST_LIST_SORT is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_RBTREE_TEST is not set
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
CONFIG_BUILD_DOCSRC=y
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DOUBLEFAULT is not set
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
CONFIG_IO_DELAY_NONE=y
CONFIG_DEFAULT_IO_DELAY_TYPE=3
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y
# CONFIG_X86_DEBUG_STATIC_CPU_HAS is not set

#
# Security options
#
# CONFIG_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_YAMA_STACKED=y
# CONFIG_IMA is not set
CONFIG_DEFAULT_SECURITY_YAMA=y
# CONFIG_DEFAULT_SECURITY_DAC is not set
CONFIG_DEFAULT_SECURITY="yama"
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
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
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
# CONFIG_CRYPTO_AUTHENC is not set
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
# CONFIG_CRYPTO_GCM is not set
CONFIG_CRYPTO_SEQIV=y

#
# Block modes
#
CONFIG_CRYPTO_CBC=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_ECB=y
CONFIG_CRYPTO_LRW=y
CONFIG_CRYPTO_PCBC=y
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_CRCT10DIF=y
# CONFIG_CRYPTO_GHASH is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
# CONFIG_CRYPTO_RMD256 is not set
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
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
# CONFIG_CRYPTO_BLOWFISH is not set
# CONFIG_CRYPTO_CAMELLIA is not set
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_586=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_586=y

#
# Compression
#
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_ZLIB is not set
CONFIG_CRYPTO_LZO=y
# CONFIG_CRYPTO_LZ4 is not set
CONFIG_CRYPTO_LZ4HC=y

#
# Random Number Generation
#
# CONFIG_CRYPTO_ANSI_CPRNG is not set
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
# CONFIG_CRYPTO_DEV_PADLOCK_AES is not set
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_CRYPTO_DEV_GEODE is not set
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
# CONFIG_CRYPTO_DEV_CCP is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_IRQ_ROUTING=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_KVM_VFIO=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_LGUEST is not set
# CONFIG_BINARY_PRINTF is not set

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_NET_UTILS=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
CONFIG_CRC32_SELFTEST=y
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
# CONFIG_CRC8 is not set
CONFIG_CRC64_ECMA=y
CONFIG_AUDIT_GENERIC=y
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_LZ4HC_COMPRESS=y
CONFIG_LZ4_DECOMPRESS=y
# CONFIG_XZ_DEC is not set
# CONFIG_XZ_DEC_BCJ is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_DECOMPRESS_LZ4=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_ENC8=y
CONFIG_REED_SOLOMON_DEC8=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_AVERAGE=y
CONFIG_CORDIC=y
CONFIG_DDR=y

--y0ulUmNC+osPPQO6--
