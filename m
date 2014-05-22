From: Jet Chen <jet.chen@intel.com>
Subject: [net] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:92
 batadv_is_on_batman_iface()
Date: Thu, 22 May 2014 12:42:24 +0800
Message-ID: <537D8030.8010403@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090000010208030005040009"
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090000010208030005040009
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steffen,

0day kernel testing robot got the below dmesg and the first bad commit is

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
commit 78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb
Author:     Steffen Klassert <steffen.klassert@secunet.com>
AuthorDate: Mon May 19 11:36:56 2014 +0200
Commit:     David S. Miller <davem@davemloft.net>
CommitDate: Wed May 21 02:08:32 2014 -0400

     ip_tunnel: Initialize the fallback device properly
         We need to initialize the fallback device to have a correct mtu
     set on this device. Otherwise the mtu is set to null and the device
     is unusable.
         Fixes: fd58156e456d ("IPIP: Use ip-tunneling code.")
     Cc: Pravin B Shelar <pshelar@nicira.com>
     Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
     Signed-off-by: David S. Miller <davem@davemloft.net>

+--------------------------------------------------------------------------------+------------+------------+
|                                                                                | d8d33c3b8a | 78ff4be45a |
+--------------------------------------------------------------------------------+------------+------------+
| boot_successes                                                                 | 60         | 0          |
| boot_failures                                                                  | 0          | 20         |
| WARNING:CPU:PID:at_net/batman-adv/hard-interface.c:batadv_is_on_batman_iface() | 0          | 20         |
| backtrace:register_netdevice_notifier                                          | 0          | 20         |
| backtrace:batadv_init                                                          | 0          | 20         |
| backtrace:kernel_init_freeable                                                 | 0          | 20         |
+--------------------------------------------------------------------------------+------------+------------+


[   31.090120] libceph: loaded (mon/osd proto 15/24)
[   31.090854] ------------[ cut here ]------------
[   31.090854] ------------[ cut here ]------------
[   31.091497] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:92 batadv_is_on_batman_iface+0x62/0x70()

git bisect start 842390939e8dc18fe8a87e257e7e8088548bd8d7 d6d211db37e75de2ddc3a4f979038c40df7cc79c --
git bisect  bad 6e8a2e89a46e99e7750d8511b94c6e964fa62041  # 18:29      0-     20  Merge 'arm-soc/keystone/dt' into devel-hourly-2014052115
git bisect  bad 732aed36300f1426c6da40602fbaf23dd79d8391  # 19:21      0-      1  Merge 'tip/irq/core' into devel-hourly-2014052115
git bisect good fd69bb2faebc552b4da42966ee51e1dea9ba77e6  # 19:28     20+      0  Merge 'block/for-3.16/drivers' into devel-hourly-2014052115
git bisect  bad 917a4d3aed6301097ff8a2b2bb74be34be5c9b23  # 19:39      0-      5  Merge 'net/master' into devel-hourly-2014052115
git bisect good 6c8b235f29b6b756379d7d5d86371a9f399afa52  # 20:04     20+      0  Merge 'hwmon/hwmon-next' into devel-hourly-2014052115
git bisect good 70c0859af3e380a0508883120adac883b456b056  # 21:09     20+      0  Merge 'kees/lsm-mnt-restrict' into devel-hourly-2014052115
git bisect good b394745df2d9d4c30bf1bcc55773bec6f3bc7c67  # 21:31     20+      0  net: phy: Don't call phy_resume if phy_init_hw failed
git bisect good 202630b445d2618d94e4f099567fcee5618dab27  # 22:25     20+      0  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
git bisect good 0d08fceb2e21c30ca3e1e462e678723f806acf18  # 23:18     20+      0  xen-netback: fix race between napi_complete() and interrupt handler
git bisect good 25175ba5c9bff9aaf0229df34bb5d54c81633ec3  # 00:28     20+      0  net: Allow for more then a single subclass for netif_addr_lock
git bisect good 5467a512216753d54f757314c73dbc60f659f9e6  # 03:39     20+      0  netfilter: nf_tables: fix goto action
git bisect good c674ac30c549596295eb0a5af7f4714c0b905b6f  # 04:12     20+      0  macvlan: Fix lockdep warnings with stacked macvlan devices
git bisect good e1618d461ca18d40f9c3ef70598abb72e75d27ae  # 07:14     20+      0  vlan: Fix build error wth vlan_get_encap_level()
git bisect good 3b084e99a3fabaeb0f9c65a0806cde30f0b2835e  # 07:47     20+      0  netfilter: nf_tables: fix trace of matching non-terminal rule
git bisect good d8d33c3b8a42fbd9ad23a61498fa5db1d83644e0  # 08:09     20+      0  Merge tag 'linux-can-fixes-for-3.15-20140519' of git://gitorious.org/linux-can/linux-can
git bisect  bad 78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb  # 08:52      0-     13  ip_tunnel: Initialize the fallback device properly
# first bad commit: [78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb] ip_tunnel: Initialize the fallback device properly
git bisect good d8d33c3b8a42fbd9ad23a61498fa5db1d83644e0  # 08:55     60+      0  Merge tag 'linux-can-fixes-for-3.15-20140519' of git://gitorious.org/linux-can/linux-can
git bisect  bad 842390939e8dc18fe8a87e257e7e8088548bd8d7  # 08:55      0-     13  0day head guard for 'devel-hourly-2014052115'
git bisect good 4b660a7f5c8099d88d1a43d8ae138965112592c7  # 09:59     60+      0  Linux 3.15-rc6
git bisect good 18e072998c67e985aaa643ca1af3e6a0dc133b71  # 11:54     60+     60  Add linux-next specific files for 20140521


This script may reproduce the error.

-----------------------------------------------------------------------------
#!/bin/bash

kernel=$1

kvm=(
	qemu-system-x86_64 -cpu kvm64 -enable-kvm 	-kernel $kernel
	-smp 2
	-m 256M
	-net nic,vlan=0,macaddr=00:00:00:00:00:00,model=virtio
	-net user,vlan=0
	-net nic,vlan=1,model=e1000
	-net user,vlan=1
	-boot order=nc
	-no-reboot
	-watchdog i6300esb
	-serial stdio
	-display none
	-monitor null
)

append=(
	debug
	sched_debug
	apic=debug
	ignore_loglevel
	sysrq_always_enabled
	panic=10
	prompt_ramdisk=0
	earlyprintk=ttyS0,115200
	console=ttyS0,115200
	console=tty0
	vga=normal
	root=/dev/ram0
	rw
)

"${kvm[@]}" --append "${append[*]}"
-----------------------------------------------------------------------------

Thanks,
Jet


--------------090000010208030005040009
Content-Type: text/plain; charset=UTF-8;
 name="dmesg-quantal-ivb42-112:20140522085222:i386-randconfig-c0-05211630:3.15.0-rc4-00068-g78ff4be:2"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename*0="dmesg-quantal-ivb42-112:20140522085222:i386-randconfig-c0-05";
 filename*1="211630:3.15.0-rc4-00068-g78ff4be:2"

early console in setup code
early console in decompress_kernel

Decompressing Linux... Parsing ELF... done.
Booting the kernel.
[    0.000000] Linux version 3.15.0-rc4-00068-g78ff4be (kbuild@jaketown) =
(gcc version 4.8.2 (Debian 4.8.2-18) ) #2 SMP Thu May 22 08:48:54 CST 201=
4
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] res=
erved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled:=
 non-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> re=
served
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped a=
t [780fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x037fffff]
[    0.000000] Base memory trampoline at [7809b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13bfffff] page 2M
[    0.000000]  [mem 0x13c00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x031df000, 0x031dffff] PGTABLE
[    0.000000] BRK [0x031e0000, 0x031e1fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 0x000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE450 000034 (v01 BOCHS  BXPCRSDT 00000001=
 BXPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001=
 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE490 0011A9 (v01 BXPC   BXDSDT   00000001=
 INTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001=
 BXPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF680 000080 (v01 BOCHS  BXPCAPIC 00000001=
 BXPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF640 000038 (v01 BOCHS  BXPCHPET 00000001=
 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000] BRK [0x031e2000, 0x031e2fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat 7ac673e0, node_mem_map =
8a52b020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI =
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, API=
C INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level=
)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, API=
C INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level=
)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, API=
C INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, API=
C INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, API=
C INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, API=
C INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, API=
C INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, API=
C INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, API=
C INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, API=
C INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, API=
C INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, API=
C INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, API=
C INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, API=
C INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, API=
C INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI device=
s
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 11 pages/cpu @8a515000 s29984 r0 d15072 u=
45056
[    0.000000] pcpu-alloc: s29984 r0 d15072 u45056 alloc=3D11*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 12517840
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dtty=
S0,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_=
timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  promp=
t_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D=
/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-c0-052116=
30/linux-devel:devel-hourly-2014052115:78ff4be45a4c51d8fb21ad92e4fabb467c=
6c3eeb:bisect-linux8/.vmlinuz-78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb-20=
140522085039-14-ivb42 branch=3Dlinux-devel/devel-hourly-2014052115 BOOT_I=
MAGE=3D/kernel/i386-randconfig-c0-05211630/78ff4be45a4c51d8fb21ad92e4fabb=
467c6c3eeb/vmlinuz-3.15.0-rc4-00068-g78ff4be drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 b=
ytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 by=
tes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 264576K/327280K available (18974K kernel code, 167=
6K rwdata, 8484K rodata, 568K init, 4860K bss, 62704K reserved, 0K highme=
m)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffa97000 - 0xfffff000   (5536 kB)
[    0.000000]     pkmap   : 0xff400000 - 0xff800000   (4096 kB)
[    0.000000]     vmalloc : 0x8c7fe000 - 0xff3fe000   (1836 MB)
[    0.000000]     lowmem  : 0x78000000 - 0x8bffe000   ( 319 MB)
[    0.000000]       .init : 0x7ac77000 - 0x7ad05000   ( 568 kB)
[    0.000000]       .data : 0x7a287c87 - 0x7ac75000   (10164 kB)
[    0.000000]       .text : 0x79000000 - 0x7a287c87   (18975 kB)
[    0.000000] Checking if this processor honours the WP bit even in supe=
rvisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_i=
ds=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3D8a00a000 soft=3D8a00c000
[    0.000000] Linux version 3.15.0-rc4-00068-g78ff4be (kbuild@jaketown) =
(gcc version 4.8.2 (Debian 4.8.2-18) ) #2 SMP Thu May 22 08:48:54 CST 201=
4
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x0000000013ffdfff] usa=
ble
[    0.000000] BIOS-e820: [mem 0x0000000013ffe000-0x0000000013ffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] res=
erved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] res=
erved
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] Notice: NX (Execute Disable) protection cannot be enabled:=
 non-PAE kernel!
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> re=
served
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] e820: last_pfn =3D 0x13ffe max_arch_pfn =3D 0x100000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdae0-0x000fdaef] mapped a=
t [780fdae0]
[    0.000000]   mpc: fdaf0-fdbe4
[    0.000000] initial memory mapped: [mem 0x00000000-0x037fffff]
[    0.000000] Base memory trampoline at [7809b000] 9b000 size 16384
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x12000000-0x123fffff]
[    0.000000]  [mem 0x12000000-0x123fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x10000000-0x11ffffff]
[    0.000000]  [mem 0x10000000-0x11ffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0fffffff]
[    0.000000]  [mem 0x00100000-0x003fffff] page 4k
[    0.000000]  [mem 0x00400000-0x0fffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x12400000-0x13ffdfff]
[    0.000000]  [mem 0x12400000-0x13bfffff] page 2M
[    0.000000]  [mem 0x13c00000-0x13ffdfff] page 4k
[    0.000000] BRK [0x031df000, 0x031dffff] PGTABLE
[    0.000000] BRK [0x031e0000, 0x031e1fff] PGTABLE
[    0.000000] RAMDISK: [mem 0x127ab000-0x13feffff]
[    0.000000] ACPI: RSDP 0x000FD950 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x13FFE450 000034 (v01 BOCHS  BXPCRSDT 00000001=
 BXPC 00000001)
[    0.000000] ACPI: FACP 0x13FFFF80 000074 (v01 BOCHS  BXPCFACP 00000001=
 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x13FFE490 0011A9 (v01 BXPC   BXDSDT   00000001=
 INTL 20100528)
[    0.000000] ACPI: FACS 0x13FFFF40 000040
[    0.000000] ACPI: SSDT 0x13FFF7A0 000796 (v01 BOCHS  BXPCSSDT 00000001=
 BXPC 00000001)
[    0.000000] ACPI: APIC 0x13FFF680 000080 (v01 BOCHS  BXPCAPIC 00000001=
 BXPC 00000001)
[    0.000000] ACPI: HPET 0x13FFF640 000038 (v01 BOCHS  BXPCHPET 00000001=
 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] 0MB HIGHMEM available.
[    0.000000] 319MB LOWMEM available.
[    0.000000]   mapped low ram: 0 - 13ffe000
[    0.000000]   low ram: 0 - 13ffe000
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:13ffd001, primary cpu clock
[    0.000000] BRK [0x031e2000, 0x031e2fff] PGTABLE
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   Normal   [mem 0x01000000-0x13ffdfff]
[    0.000000]   HighMem  empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x13ffdfff]
[    0.000000] On node 0 totalpages: 81820
[    0.000000] free_area_init_node: node 0, pgdat 7ac673e0, node_mem_map =
8a52b020
[    0.000000]   DMA zone: 32 pages used for memmap
[    0.000000]   DMA zone: 0 pages reserved
[    0.000000]   DMA zone: 3998 pages, LIFO batch:0
[    0.000000]   Normal zone: 608 pages used for memmap
[    0.000000]   Normal zone: 77822 pages, LIFO batch:15
[    0.000000] Using APIC driver default
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to         ffffc000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x00] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 0, version 17, address 0xfec00000, GSI =
0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 0, API=
C INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level=
)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 0, API=
C INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level=
)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 0, API=
C INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 0, API=
C INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high lev=
el)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 0, API=
C INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 0, API=
C INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 0, API=
C INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 0, API=
C INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 0, API=
C INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 0, API=
C INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 0, API=
C INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 0, API=
C INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 0, API=
C INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 0, API=
C INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 0, API=
C INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffb000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x14000000-0xfeffbfff] available for PCI device=
s
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:32 nr_cpumask_bits:32 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 11 pages/cpu @8a515000 s29984 r0 d15072 u=
45056
[    0.000000] pcpu-alloc: s29984 r0 d15072 u45056 alloc=3D11*4096
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 12517840
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  To=
tal pages: 81180
[    0.000000] Kernel command line: hung_task_panic=3D1 earlyprintk=3Dtty=
S0,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_=
timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  promp=
t_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D=
/dev/ram0 rw link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-c0-052116=
30/linux-devel:devel-hourly-2014052115:78ff4be45a4c51d8fb21ad92e4fabb467c=
6c3eeb:bisect-linux8/.vmlinuz-78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb-20=
140522085039-14-ivb42 branch=3Dlinux-devel/devel-hourly-2014052115 BOOT_I=
MAGE=3D/kernel/i386-randconfig-c0-05211630/78ff4be45a4c51d8fb21ad92e4fabb=
467c6c3eeb/vmlinuz-3.15.0-rc4-00068-g78ff4be drbd.minor_count=3D8
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 b=
ytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 by=
tes)
[    0.000000] Initializing CPU#0
[    0.000000] Initializing HighMem for node 0 (00000000:00000000)
[    0.000000] Memory: 264576K/327280K available (18974K kernel code, 167=
6K rwdata, 8484K rodata, 568K init, 4860K bss, 62704K reserved, 0K highme=
m)
[    0.000000] virtual kernel memory layout:
[    0.000000]     fixmap  : 0xffa97000 - 0xfffff000   (5536 kB)
[    0.000000]     pkmap   : 0xff400000 - 0xff800000   (4096 kB)
[    0.000000]     vmalloc : 0x8c7fe000 - 0xff3fe000   (1836 MB)
[    0.000000]     lowmem  : 0x78000000 - 0x8bffe000   ( 319 MB)
[    0.000000]       .init : 0x7ac77000 - 0x7ad05000   ( 568 kB)
[    0.000000]       .data : 0x7a287c87 - 0x7ac75000   (10164 kB)
[    0.000000]       .text : 0x79000000 - 0x7a287c87   (18975 kB)
[    0.000000] Checking if this processor honours the WP bit even in supe=
rvisor mode...Ok.
[    0.000000] Hierarchical RCU implementation.
[    0.000000] RCU: Adjusting geometry for rcu_fanout_leaf=3D16, nr_cpu_i=
ds=3D2
[    0.000000] NR_IRQS:2304 nr_irqs:512 16
[    0.000000] CPU 0 irqstacks, hard=3D8a00a000 soft=3D8a00c000
[    0.000000] console [ttyS0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc=
=2E, Ingo Molnar
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc=
=2E, Ingo Molnar
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
[    0.000000]  memory used by lock dependency info: 3551 kB
[    0.000000]  memory used by lock dependency info: 3551 kB
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000]  per task-struct memory footprint: 1152 bytes
[    0.000000] ------------------------
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------=
------------------
[    0.000000] ----------------------------------------------------------=
------------------
[    0.000000]                                  | spin |wlock |rlock |mut=
ex | wsem | rsem |
[    0.000000]                                  | spin |wlock |rlock |mut=
ex | wsem | rsem |
[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]                      A-A deadlock:
[    0.000000]                      A-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                  A-B-B-A deadlock:
[    0.000000]                  A-B-B-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-B-C-C-A deadlock:
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]              A-B-C-A-B-C deadlock:
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-B-C-C-D-D-A deadlock:
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-D-D-A deadlock:
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]          A-B-C-D-B-C-D-A deadlock:
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|failed|fai=
led|  ok  |  ok  |failed|failed|failed|failed|failed|failed|

[    0.000000]                     double unlock:
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                   initialize held:
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                  bad unlock order:
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]               recursive read-lock:
[    0.000000]               recursive read-lock:             |          =
   |  ok  |  ok  |             |             |failed|failed|

[    0.000000]            recursive read-lock #2:
[    0.000000]            recursive read-lock #2:             |          =
   |  ok  |  ok  |             |             |failed|failed|

[    0.000000]             mixed read-write-lock:
[    0.000000]             mixed read-write-lock:             |          =
   |failed|failed|             |             |failed|failed|

[    0.000000]             mixed write-read-lock:
[    0.000000]             mixed write-read-lock:             |          =
   |failed|failed|             |             |failed|failed|

[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/12:
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]      hard-irqs-on + irq-safe-A/21:
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]      soft-irqs-on + irq-safe-A/21:
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/12:
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]        sirq-safe-A =3D> hirqs-on/21:
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:failed|failed|failed|f=
ailed|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/12:
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/12:
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          hard-safe-A + irqs-on/21:
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]          soft-safe-A + irqs-on/21:
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/123:
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/123:
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/132:
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/132:
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/213:
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/213:
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/231:
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/231:
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/312:
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/312:
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #1/321:
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #1/321:
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/123:
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/123:
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/132:
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/132:
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/213:
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/213:
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/231:
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/231:
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/312:
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/312:
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     hard-safe-A + unsafe-B #2/321:
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]     soft-safe-A + unsafe-B #2/321:
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/123:
[    0.000000]       hard-irq lock-inversion/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/123:
[    0.000000]       soft-irq lock-inversion/123:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/132:
[    0.000000]       hard-irq lock-inversion/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/132:
[    0.000000]       soft-irq lock-inversion/132:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/213:
[    0.000000]       hard-irq lock-inversion/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/213:
[    0.000000]       soft-irq lock-inversion/213:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/231:
[    0.000000]       hard-irq lock-inversion/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/231:
[    0.000000]       soft-irq lock-inversion/231:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/312:
[    0.000000]       hard-irq lock-inversion/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/312:
[    0.000000]       soft-irq lock-inversion/312:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       hard-irq lock-inversion/321:
[    0.000000]       hard-irq lock-inversion/321:failed|failed|failed|fai=
led|  ok  |  ok  |

[    0.000000]       soft-irq lock-inversion/321:
[    0.000000]       soft-irq lock-inversion/321:failed|failed|failed|fai=
led|  ok  |  ok  |

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

[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]   --------------------------------------------------------=
------------------
[    0.000000]   | Wound/wait tests |
[    0.000000]   | Wound/wait tests |
[    0.000000]   ---------------------
[    0.000000]   ---------------------
[    0.000000]                   ww api failures:
[    0.000000]                   ww api failures:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]                ww contexts mixing:
[    0.000000]                ww contexts mixing:failed|failed|  ok  |  o=
k  |

[    0.000000]              finishing ww context:
[    0.000000]              finishing ww context:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]                locking mismatches:
[    0.000000]                locking mismatches:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]                  EDEADLK handling:
[    0.000000]                  EDEADLK handling:  ok  |  ok  |  ok  |  o=
k  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |  ok  =
|  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |

[    0.000000]            spinlock nest unlocked:
[    0.000000]            spinlock nest unlocked:  ok  |  ok  |

[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                                  |block | try  |context|
[    0.000000]                                  |block | try  |context|
[    0.000000]   -----------------------------------------------------
[    0.000000]   -----------------------------------------------------
[    0.000000]                           context:
[    0.000000]                           context:failed|failed|  ok  |  o=
k  |  ok  |  ok  |

[    0.000000]                               try:
[    0.000000]                               try:failed|failed|  ok  |  o=
k  |failed|failed|

[    0.000000]                             block:
[    0.000000]                             block:failed|failed|  ok  |  o=
k  |failed|failed|

[    0.000000]                          spinlock:
[    0.000000]                          spinlock:failed|failed|  ok  |  o=
k  |failed|failed|

[    0.000000] --------------------------------------------------------
[    0.000000] --------------------------------------------------------
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] 141 out of 253 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ----------------------------------------------------
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.526 MHz processor
[    0.000000] tsc: Detected 2693.526 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5387.05 Bo=
goMIPS (lpj=3D26935260)
5387.05 BogoMIPS (lpj=3D26935260)
[    0.020000] pid_max: default: 4096 minimum: 301
[    0.020000] pid_max: default: 4096 minimum: 301
[    0.020000] ACPI: Core revision 20140214
[    0.020000] ACPI: Core revision 20140214
[    0.020000] ACPI:=20
[    0.020000] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables=
 successfully acquired

[    0.020000] Security Framework initialized
[    0.020000] Security Framework initialized
[    0.020000] Yama: becoming mindful.
[    0.020000] Yama: becoming mindful.
[    0.020000] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes=
)
[    0.020000] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes=
)
[    0.020000] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 =
bytes)
[    0.020000] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 =
bytes)
[    0.020000] mce: CPU supports 10 MCE banks
[    0.020000] mce: CPU supports 10 MCE banks
[    0.020000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.020000] tlb_flushall_shift: 6
[    0.020000] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.020000] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.020000] tlb_flushall_shift: 6
[    0.021008] Freeing SMP alternatives memory: 52K (7ad05000 - 7ad12000)=

[    0.021008] Freeing SMP alternatives memory: 52K (7ad05000 - 7ad12000)=

[    0.025393] Getting VERSION: 50014
[    0.025393] Getting VERSION: 50014
[    0.025835] Getting VERSION: 50014
[    0.025835] Getting VERSION: 50014
[    0.026271] Getting ID: 0
[    0.026271] Getting ID: 0
[    0.026609] Getting ID: f000000
[    0.026609] Getting ID: f000000
[    0.027009] Getting LVT0: 8700
[    0.027009] Getting LVT0: 8700
[    0.027402] Getting LVT1: 8400
[    0.027402] Getting LVT1: 8400
[    0.027791] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.027791] Enabling APIC mode:  Flat.  Using 1 I/O APICs
[    0.030019] enabled ExtINT on CPU#0
[    0.030019] enabled ExtINT on CPU#0
[    0.031072] ENABLING IO-APIC IRQs
[    0.031072] ENABLING IO-APIC IRQs
[    0.031489] init IO_APIC IRQs
[    0.031489] init IO_APIC IRQs
[    0.031867]  apic 0 pin 0 not connected
[    0.031867]  apic 0 pin 0 not connected
[    0.032350] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 =
Active:0 Dest:1)
[    0.032350] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 =
Active:0 Dest:1)
[    0.033342] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 =
Active:0 Dest:1)
[    0.033342] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 =
Active:0 Dest:1)
[    0.034340] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 =
Active:0 Dest:1)
[    0.034340] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 =
Active:0 Dest:1)
[    0.035340] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 =
Active:0 Dest:1)
[    0.035340] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 =
Active:0 Dest:1)
[    0.036332] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 =
Active:0 Dest:1)
[    0.036332] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 =
Active:0 Dest:1)
[    0.037324] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 =
Active:0 Dest:1)
[    0.037324] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 =
Active:0 Dest:1)
[    0.038317] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 =
Active:0 Dest:1)
[    0.038317] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 =
Active:0 Dest:1)
[    0.039309] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 =
Active:0 Dest:1)
[    0.039309] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 =
Active:0 Dest:1)
[    0.040014] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 =
Active:0 Dest:1)
[    0.040014] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 =
Active:0 Dest:1)
[    0.041022] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:=
1 Active:0 Dest:1)
[    0.041022] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:=
1 Active:0 Dest:1)
[    0.042044] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:=
1 Active:0 Dest:1)
[    0.042044] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:=
1 Active:0 Dest:1)
[    0.043072] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:=
0 Active:0 Dest:1)
[    0.043072] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:=
0 Active:0 Dest:1)
[    0.044096] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:=
0 Active:0 Dest:1)
[    0.044096] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:=
0 Active:0 Dest:1)
[    0.045117] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:=
0 Active:0 Dest:1)
[    0.045117] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:=
0 Active:0 Dest:1)
[    0.046142] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:=
0 Active:0 Dest:1)
[    0.046142] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:=
0 Active:0 Dest:1)
[    0.047169]  apic 0 pin 16 not connected
[    0.047169]  apic 0 pin 16 not connected
[    0.047668]  apic 0 pin 17 not connected
[    0.047668]  apic 0 pin 17 not connected
[    0.048159]  apic 0 pin 18 not connected
[    0.048159]  apic 0 pin 18 not connected
[    0.048656]  apic 0 pin 19 not connected
[    0.048656]  apic 0 pin 19 not connected
[    0.049147]  apic 0 pin 20 not connected
[    0.049147]  apic 0 pin 20 not connected
[    0.050002]  apic 0 pin 21 not connected
[    0.050002]  apic 0 pin 21 not connected
[    0.050513]  apic 0 pin 22 not connected
[    0.050513]  apic 0 pin 22 not connected
[    0.051009]  apic 0 pin 23 not connected
[    0.051009]  apic 0 pin 23 not connected
[    0.051652] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.051652] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.052565] smpboot: CPU0:=20
[    0.052565] smpboot: CPU0: Intel Intel Common KVM processorCommon KVM =
processor (fam: 0f, model: 06 (fam: 0f, model: 06, stepping: 01)
, stepping: 01)
[    0.053832] Using local APIC timer interrupts.
[    0.053832] calibrating APIC timer ...
[    0.053832] Using local APIC timer interrupts.
[    0.053832] calibrating APIC timer ...
[    0.060000] ... lapic delta =3D 6248458
[    0.060000] ... lapic delta =3D 6248458
[    0.060000] ... PM-Timer delta =3D 357864
[    0.060000] ... PM-Timer delta =3D 357864
[    0.060000] ... PM-Timer result ok
[    0.060000] ... PM-Timer result ok
[    0.060000] ..... delta 6248458
[    0.060000] ..... delta 6248458
[    0.060000] ..... mult: 268369227
[    0.060000] ..... mult: 268369227
[    0.060000] ..... calibration result: 9997532
[    0.060000] ..... calibration result: 9997532
[    0.060000] ..... CPU clock speed is 2693.2175 MHz.
[    0.060000] ..... CPU clock speed is 2693.2175 MHz.
[    0.060000] ..... host bus clock speed is 999.7532 MHz.
[    0.060000] ..... host bus clock speed is 999.7532 MHz.
[    0.060000] Performance Events:=20
[    0.060000] Performance Events: unsupported Netburst CPU model 6 unsup=
ported Netburst CPU model 6 no PMU driver, software events only.
no PMU driver, software events only.
[    0.060000] CPU 1 irqstacks, hard=3D8a0ae000 soft=3D8a0b0000
[    0.060000] CPU 1 irqstacks, hard=3D8a0ae000 soft=3D8a0b0000
[    0.060000] x86: Booting SMP configuration:
[    0.060000] x86: Booting SMP configuration:
[    0.060000] .... node  #0, CPUs: =20
[    0.060000] .... node  #0, CPUs:         #1 #1
[    0.010000] Initializing CPU#1
[    0.020000] kvm-clock: cpu 1, msr 0:13ffd021, secondary cpu clock
[    0.020000] masked ExtINT on CPU#1
[    0.070048] x86: Booted up 1 node, 2 CPUs
[    0.070048] x86: Booted up 1 node, 2 CPUs
[    0.070026] KVM setup async PF for cpu 1
[    0.070026] KVM setup async PF for cpu 1
[    0.070026] kvm-stealtime: cpu 1, msr 12522840
[    0.070026] kvm-stealtime: cpu 1, msr 12522840
[    0.071653] ----------------
[    0.071653] ----------------
[    0.072027] | NMI testsuite:
[    0.072027] | NMI testsuite:
[    0.072393] --------------------
[    0.072393] --------------------
[    0.072807]   remote IPI:
[    0.072807]   remote IPI:  ok  |  ok  |

[    0.080141]    local IPI:
[    0.080141]    local IPI:  ok  |  ok  |

[    0.100009] --------------------
[    0.100009] --------------------
[    0.100428] Good, all   2 testcases passed! |
[    0.100428] Good, all   2 testcases passed! |
[    0.100987] ---------------------------------
[    0.100987] ---------------------------------
[    0.101540] smpboot: Total of 2 processors activated (10774.10 BogoMIP=
S)
[    0.101540] smpboot: Total of 2 processors activated (10774.10 BogoMIP=
S)
[    0.102666] xor: measuring software checksum speed
[    0.102666] xor: measuring software checksum speed
[    0.200007]    pIII_sse  :   114.000 MB/sec
[    0.200007]    pIII_sse  :   114.000 MB/sec
[    0.300022]    prefetch64-sse:   114.400 MB/sec
[    0.300022]    prefetch64-sse:   114.400 MB/sec
[    0.300606] xor: using function: prefetch64-sse (114.400 MB/sec)
[    0.300606] xor: using function: prefetch64-sse (114.400 MB/sec)
[    0.301567] regulator-dummy: no parameters
[    0.301567] regulator-dummy: no parameters
[    0.302339] NET: Registered protocol family 16
[    0.302339] NET: Registered protocol family 16
[    0.303869] cpuidle: using governor ladder
[    0.303869] cpuidle: using governor ladder
[    0.304397] cpuidle: using governor menu
[    0.304397] cpuidle: using governor menu
[    0.305609] ACPI: bus type PCI registered
[    0.305609] ACPI: bus type PCI registered
[    0.306362] dca service started, version 1.12.1
[    0.306362] dca service started, version 1.12.1
[    0.307016] PCI: Using configuration type 1 for base access
[    0.307016] PCI: Using configuration type 1 for base access
[    0.500006] raid6: mmxx1     5656 MB/s
[    0.500006] raid6: mmxx1     5656 MB/s
[    0.670004] raid6: mmxx2     5995 MB/s
[    0.670004] raid6: mmxx2     5995 MB/s
[    0.840011] raid6: sse1x1    4506 MB/s
[    0.840011] raid6: sse1x1    4506 MB/s
[    1.010012] raid6: sse1x2    5503 MB/s
[    1.010012] raid6: sse1x2    5503 MB/s
[    1.180007] raid6: sse2x1    8962 MB/s
[    1.180007] raid6: sse2x1    8962 MB/s
[    1.350003] raid6: sse2x2   11203 MB/s
[    1.350003] raid6: sse2x2   11203 MB/s
[    1.350475] raid6: using algorithm sse2x2 (11203 MB/s)
[    1.350475] raid6: using algorithm sse2x2 (11203 MB/s)
[    1.351112] raid6: using intx1 recovery algorithm
[    1.351112] raid6: using intx1 recovery algorithm
[    1.351877] ACPI: Added _OSI(Module Device)
[    1.351877] ACPI: Added _OSI(Module Device)
[    1.352447] ACPI: Added _OSI(Processor Device)
[    1.352447] ACPI: Added _OSI(Processor Device)
[    1.352998] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.352998] ACPI: Added _OSI(3.0 _SCP Extensions)
[    1.353577] ACPI: Added _OSI(Processor Aggregator Device)
[    1.353577] ACPI: Added _OSI(Processor Aggregator Device)
[    1.357687] ACPI: Interpreter enabled
[    1.357687] ACPI: Interpreter enabled
[    1.358175] ACPI Exception: AE_NOT_FOUND,=20
[    1.358175] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S1_]While evaluating Sleep State [\_S1_] (20140214/hwxface-580)
 (20140214/hwxface-580)
[    1.359328] ACPI Exception: AE_NOT_FOUND,=20
[    1.359328] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State=
 [\_S2_]While evaluating Sleep State [\_S2_] (20140214/hwxface-580)
 (20140214/hwxface-580)
[    1.360291] ACPI: (supports S0 S3 S5)
[    1.360291] ACPI: (supports S0 S3 S5)
[    1.360761] ACPI: Using IOAPIC for interrupt routing
[    1.360761] ACPI: Using IOAPIC for interrupt routing
[    1.361400] PCI: Using host bridge windows from ACPI; if necessary, us=
e "pci=3Dnocrs" and report a bug
[    1.361400] PCI: Using host bridge windows from ACPI; if necessary, us=
e "pci=3Dnocrs" and report a bug
[    1.367160] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.367160] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.367953] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    1.367953] acpi PNP0A03:00: _OSC: OS supports [Segments MSI]
[    1.368673] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASP=
M
[    1.368673] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASP=
M
[    1.369757] PCI host bridge to bus 0000:00
[    1.369757] PCI host bridge to bus 0000:00
[    1.370004] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.370004] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.370686] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.370686] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.371451] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.371451] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.372212] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bf=
fff]
[    1.372212] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bf=
fff]
[    1.373062] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebff=
fff]
[    1.373062] pci_bus 0000:00: root bus resource [mem 0x80000000-0xfebff=
fff]
[    1.373940] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.373940] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.375003] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.375003] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.376205] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.376205] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.378846] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.378846] pci 0000:00:01.1: reg 0x20: [io  0xc040-0xc04f]
[    1.380733] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-=
0x01f7]
[    1.380733] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-=
0x01f7]
[    1.381625] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]=

[    1.381625] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]=

[    1.382428] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-=
0x0177]
[    1.382428] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-=
0x0177]
[    1.383309] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]=

[    1.383309] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]=

[    1.384314] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.384314] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.385280] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PI=
IX4 ACPI
[    1.385280] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PI=
IX4 ACPI
[    1.386217] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PI=
IX4 SMB
[    1.386217] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PI=
IX4 SMB
[    1.387318] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.387318] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.390470] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pre=
f]
[    1.390470] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pre=
f]
[    1.392270] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.392270] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.397456] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pre=
f]
[    1.397456] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pre=
f]
[    1.398699] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.398699] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.400020] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.400020] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.401481] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.401481] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.405620] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pre=
f]
[    1.405620] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pre=
f]
[    1.406694] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.406694] pci 0000:00:04.0: [8086:25ab] type 00 class 0x088000
[    1.407807] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.407807] pci 0000:00:04.0: reg 0x10: [mem 0xfebf1000-0xfebf100f]
[    1.411364] pci_bus 0000:00: on NUMA node 0
[    1.411364] pci_bus 0000:00: on NUMA node 0
[    1.412297] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.412297] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    1.413165] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.413165] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    1.414017] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.414017] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    1.414857] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.414857] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    1.415647] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.415647] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.416759] ACPI:=20
[    1.416759] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in =
block 00 to 0F

[    1.418025] SCSI subsystem initialized
[    1.418025] SCSI subsystem initialized
[    1.418025] libata version 3.00 loaded.
[    1.418025] libata version 3.00 loaded.
[    1.418025] ACPI: bus type USB registered
[    1.418025] ACPI: bus type USB registered
[    1.420058] usbcore: registered new interface driver usbfs
[    1.420058] usbcore: registered new interface driver usbfs
[    1.420771] usbcore: registered new interface driver hub
[    1.420771] usbcore: registered new interface driver hub
[    1.421458] usbcore: registered new device driver usb
[    1.421458] usbcore: registered new device driver usb
[    1.421458] Linux video capture interface: v2.00
[    1.421458] Linux video capture interface: v2.00
[    1.421511] pps_core: LinuxPPS API ver. 1 registered
[    1.421511] pps_core: LinuxPPS API ver. 1 registered
[    1.422134] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolf=
o Giometti <giometti@linux.it>
[    1.422134] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolf=
o Giometti <giometti@linux.it>
[    1.423265] PTP clock support registered
[    1.423265] PTP clock support registered
[    1.423848] wmi: Mapper loaded
[    1.423848] wmi: Mapper loaded
[    1.423848] Advanced Linux Sound Architecture Driver Initialized.
[    1.423848] Advanced Linux Sound Architecture Driver Initialized.
[    1.423848] PCI: Using ACPI for IRQ routing
[    1.423848] PCI: Using ACPI for IRQ routing
[    1.423848] PCI: pci_cache_line_size set to 64 bytes
[    1.423848] PCI: pci_cache_line_size set to 64 bytes
[    1.423848] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.423848] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.423848] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    1.423848] e820: reserve RAM buffer [mem 0x13ffe000-0x13ffffff]
[    1.430356] irda_init()
[    1.430356] irda_init()
[    1.430734] NET: Registered protocol family 23
[    1.430734] NET: Registered protocol family 23
[    1.431324] Bluetooth: Core ver 2.19
[    1.431324] Bluetooth: Core ver 2.19
[    1.431800] NET: Registered protocol family 31
[    1.431800] NET: Registered protocol family 31
[    1.432364] Bluetooth: HCI device and connection manager initialized
[    1.432364] Bluetooth: HCI device and connection manager initialized
[    1.433161] Bluetooth: HCI socket layer initialized
[    1.433161] Bluetooth: HCI socket layer initialized
[    1.433775] Bluetooth: L2CAP socket layer initialized
[    1.433775] Bluetooth: L2CAP socket layer initialized
[    1.434426] Bluetooth: SCO socket layer initialized
[    1.434426] Bluetooth: SCO socket layer initialized
[    1.435047] NET: Registered protocol family 8
[    1.435047] NET: Registered protocol family 8
[    1.435605] NET: Registered protocol family 20
[    1.435605] NET: Registered protocol family 20
[    1.436417] nfc: nfc_init: NFC Core ver 0.1
[    1.436417] nfc: nfc_init: NFC Core ver 0.1
[    1.436417] NET: Registered protocol family 39
[    1.436417] NET: Registered protocol family 39
[    1.436417] HPET: 3 timers in total, 0 timers will be used for per-cpu=
 timer
[    1.436417] HPET: 3 timers in total, 0 timers will be used for per-cpu=
 timer
[    1.436417] cfg80211: Calling CRDA to update world regulatory domain
[    1.436417] cfg80211: Calling CRDA to update world regulatory domain
[    1.440062] Switched to clocksource kvm-clock
[    1.440062] Switched to clocksource kvm-clock
[    1.440908] FS-Cache: Loaded
[    1.440908] FS-Cache: Loaded
[    1.441341] pnp: PnP ACPI init
[    1.441341] pnp: PnP ACPI init
[    1.441765] ACPI: bus type PNP registered
[    1.441765] ACPI: bus type PNP registered
[    1.442327] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 =
Active:0 Dest:3)
[    1.442327] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 =
Active:0 Dest:3)
[    1.443431] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)=

[    1.443431] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)=

[    1.444310] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 =
Active:0 Dest:3)
[    1.444310] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 =
Active:0 Dest:3)
[    1.445368] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)=

[    1.445368] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)=

[    1.446222] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:=
0 Active:0 Dest:3)
[    1.446222] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:=
0 Active:0 Dest:3)
[    1.447323] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)=

[    1.447323] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)=

[    1.448206] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 =
Active:0 Dest:3)
[    1.448206] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 =
Active:0 Dest:3)
[    1.449248] pnp 00:03: [dma 2]
[    1.449248] pnp 00:03: [dma 2]
[    1.449687] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)=

[    1.449687] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)=

[    1.450592] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 =
Active:0 Dest:3)
[    1.450592] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 =
Active:0 Dest:3)
[    1.451664] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)=

[    1.451664] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)=

[    1.452541] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 =
Active:0 Dest:3)
[    1.452541] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 =
Active:0 Dest:3)
[    1.453585] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)=

[    1.453585] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)=

[    1.454437] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 =
Active:0 Dest:3)
[    1.454437] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 =
Active:0 Dest:3)
[    1.455486] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)=

[    1.455486] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)=

[    1.456475] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)=

[    1.456475] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)=

[    1.457424] pnp: PnP ACPI: found 8 devices
[    1.457424] pnp: PnP ACPI: found 8 devices
[    1.457937] ACPI: bus type PNP unregistered
[    1.457937] ACPI: bus type PNP unregistered
[    1.493501] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.493501] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.494201] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.494201] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.494906] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.494906] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.495685] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.495685] pci_bus 0000:00: resource 7 [mem 0x80000000-0xfebfffff]
[    1.496627] NET: Registered protocol family 2
[    1.496627] NET: Registered protocol family 2
[    1.497596] TCP established hash table entries: 4096 (order: 2, 16384 =
bytes)
[    1.497596] TCP established hash table entries: 4096 (order: 2, 16384 =
bytes)
[    1.498548] TCP bind hash table entries: 4096 (order: 5, 147456 bytes)=

[    1.498548] TCP bind hash table entries: 4096 (order: 5, 147456 bytes)=

[    1.499562] TCP: Hash tables configured (established 4096 bind 4096)
[    1.499562] TCP: Hash tables configured (established 4096 bind 4096)
[    1.500464] TCP: reno registered
[    1.500464] TCP: reno registered
[    1.500889] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    1.500889] UDP hash table entries: 256 (order: 2, 20480 bytes)
[    1.501683] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    1.501683] UDP-Lite hash table entries: 256 (order: 2, 20480 bytes)
[    1.502681] NET: Registered protocol family 1
[    1.502681] NET: Registered protocol family 1
[    1.503261] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.503261] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.504002] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.504002] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.504730] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.504730] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.505512] pci 0000:00:02.0: Boot video device
[    1.505512] pci 0000:00:02.0: Boot video device
[    1.506090] PCI: CLS 0 bytes, default 64
[    1.506090] PCI: CLS 0 bytes, default 64
[    1.506987] Trying to unpack rootfs image as initramfs...
[    1.506987] Trying to unpack rootfs image as initramfs...
[    2.057986] Freeing initrd memory: 24852K (8a7ab000 - 8bff0000)
[    2.057986] Freeing initrd memory: 24852K (8a7ab000 - 8bff0000)
[    2.059736] Machine check injector initialized
[    2.059736] Machine check injector initialized
[    2.060500] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    2.060500] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    2.061240] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    2.061240] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    2.062034] microcode: Microcode Update Driver: v2.00 <tigran@aivazian=
=2Efsnet.co.uk>, Peter Oruba
[    2.062034] microcode: Microcode Update Driver: v2.00 <tigran@aivazian=
=2Efsnet.co.uk>, Peter Oruba
[    2.063291] apm: BIOS not found.
[    2.063291] apm: BIOS not found.
[    2.065149] PCLMULQDQ-NI instructions are not detected.
[    2.065149] PCLMULQDQ-NI instructions are not detected.
[    2.065890] The force parameter has not been set to 1. The Iris powero=
ff handler will not be installed.
[    2.065890] The force parameter has not been set to 1. The Iris powero=
ff handler will not be installed.
[    2.067084] NatSemi SCx200 Driver
[    2.067084] NatSemi SCx200 Driver
[    2.068281] Initializing RT-Tester: OK
[    2.068281] Initializing RT-Tester: OK
[    2.068786] spin_lock-torture:--- Start of test: nwriters_stress=3D4 s=
tat_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_s=
ecs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    2.068786] spin_lock-torture:--- Start of test: nwriters_stress=3D4 s=
tat_interval=3D60 verbose=3D1 shuffle_interval=3D3 stutter=3D5 shutdown_s=
ecs=3D0 onoff_interval=3D0 onoff_holdoff=3D0
[    2.070782] spin_lock-torture: Creating torture_shuffle task
[    2.070782] spin_lock-torture: Creating torture_shuffle task
[    2.071584] spin_lock-torture: Creating torture_stutter task
[    2.071584] spin_lock-torture: Creating torture_stutter task
[    2.072329] spin_lock-torture: torture_shuffle task started
[    2.072329] spin_lock-torture: torture_shuffle task started
[    2.073066] spin_lock-torture: Creating lock_torture_writer task
[    2.073066] spin_lock-torture: Creating lock_torture_writer task
[    2.073107] spin_lock-torture: torture_stutter task started
[    2.073107] spin_lock-torture: torture_stutter task started
[    2.074654] spin_lock-torture: Creating lock_torture_writer task
[    2.074654] spin_lock-torture: Creating lock_torture_writer task
[    2.075444] spin_lock-torture: lock_torture_writer task started
[    2.075444] spin_lock-torture: lock_torture_writer task started
[    2.076229] spin_lock-torture: Creating lock_torture_writer task
[    2.076229] spin_lock-torture: Creating lock_torture_writer task
[    2.076272] spin_lock-torture: lock_torture_writer task started
[    2.076272] spin_lock-torture: lock_torture_writer task started
[    2.077849] spin_lock-torture: Creating lock_torture_writer task
[    2.077849] spin_lock-torture: Creating lock_torture_writer task
[    2.078629] spin_lock-torture: lock_torture_writer task started
[    2.078629] spin_lock-torture: lock_torture_writer task started
[    2.079415] spin_lock-torture: Creating lock_torture_stats task
[    2.079415] spin_lock-torture: Creating lock_torture_stats task
[    2.079458] spin_lock-torture: lock_torture_writer task started
[    2.079458] spin_lock-torture: lock_torture_writer task started
[    2.081424] futex hash table entries: 16 (order: -2, 1024 bytes)
[    2.081424] futex hash table entries: 16 (order: -2, 1024 bytes)
[    2.082196] Initialise system trusted keyring
[    2.082196] Initialise system trusted keyring
[    2.082925] spin_lock-torture: lock_torture_stats task started
[    2.082925] spin_lock-torture: lock_torture_stats task started
[    2.083993] VFS: Disk quotas dquot_6.5.2
[    2.083993] VFS: Disk quotas dquot_6.5.2
[    2.084551] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)=

[    2.084551] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)=

[    2.085692] DLM installed
[    2.085692] DLM installed
[    2.087033] ntfs: driver 2.1.30 [Flags: R/O].
[    2.087033] ntfs: driver 2.1.30 [Flags: R/O].
[    2.087718] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    2.087718] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    2.089216] ROMFS MTD (C) 2007 Red Hat, Inc.
[    2.089216] ROMFS MTD (C) 2007 Red Hat, Inc.
[    2.089822] QNX4 filesystem 0.2.3 registered.
[    2.089822] QNX4 filesystem 0.2.3 registered.
[    2.090423] QNX6 filesystem 1.0.0 registered.
[    2.090423] QNX6 filesystem 1.0.0 registered.
[    2.091053] SGI XFS with security attributes, realtime, large block/in=
ode numbers, no debug enabled
[    2.091053] SGI XFS with security attributes, realtime, large block/in=
ode numbers, no debug enabled
[    2.092788] NILFS version 2 loaded
[    2.092788] NILFS version 2 loaded
[    2.093235] befs: version: 0.9.3
[    2.093235] befs: version: 0.9.3
[    2.093916] OCFS2 User DLM kernel interface loaded
[    2.093916] OCFS2 User DLM kernel interface loaded
[    2.094997] FS-Cache: Netfs 'ceph' registered for caching
[    2.094997] FS-Cache: Netfs 'ceph' registered for caching
[    2.095708] ceph: loaded (mds proto 32)
[    2.095708] ceph: loaded (mds proto 32)
[    2.100486] alg: No test for crc32 (crc32-table)
[    2.100486] alg: No test for crc32 (crc32-table)
[    2.101317] alg: No test for stdrng (krng)
[    2.101317] alg: No test for stdrng (krng)
[    2.105222] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    2.105222] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[    2.106206] NET: Registered protocol family 38
[    2.106206] NET: Registered protocol family 38
[    2.106799] async_tx: api initialized (async)
[    2.106799] async_tx: api initialized (async)
[    2.107350] Key type asymmetric registered
[    2.107350] Key type asymmetric registered
[    2.107872] Asymmetric key parser 'x509' registered
[    2.107872] Asymmetric key parser 'x509' registered
[    2.108554] Block layer SCSI generic (bsg) driver version 0.4 loaded (=
major 250)
[    2.108554] Block layer SCSI generic (bsg) driver version 0.4 loaded (=
major 250)
[    2.109515] io scheduler noop registered
[    2.109515] io scheduler noop registered
[    2.110036] io scheduler deadline registered (default)
[    2.110036] io scheduler deadline registered (default)
[    2.110705] list_sort_test: start testing list_sort()
[    2.110705] list_sort_test: start testing list_sort()
[    2.111603] test_string_helpers: Running tests...
[    2.111603] test_string_helpers: Running tests...
[    2.112416] xz_dec_test: module loaded
[    2.112416] xz_dec_test: module loaded
[    2.112958] xz_dec_test: Create a device node with 'mknod xz_dec_test =
c 249 0' and write .xz files to it.
[    2.112958] xz_dec_test: Create a device node with 'mknod xz_dec_test =
c 249 0' and write .xz files to it.
[    2.114487] rbtree testing
[    2.114487] rbtree testing -> 8135 cycles
 -> 8135 cycles
[    2.440590] augmented rbtree testing
[    2.440590] augmented rbtree testing -> 10380 cycles
 -> 10380 cycles
[    2.858256] rivafb_setup START
[    2.858256] rivafb_setup START
[    2.858884] vmlfb: initializing
[    2.858884] vmlfb: initializing
[    2.859312] Could not find Carillo Ranch MCH device.
[    2.859312] Could not find Carillo Ranch MCH device.
[    2.860115] usbcore: registered new interface driver udlfb
[    2.860115] usbcore: registered new interface driver udlfb
[    2.860856] usbcore: registered new interface driver smscufx
[    2.860856] usbcore: registered new interface driver smscufx
[    2.861970] uvesafb: failed to execute /sbin/v86d
[    2.861970] uvesafb: failed to execute /sbin/v86d
[    2.862590] uvesafb: make sure that the v86d helper is installed and e=
xecutable
[    2.862590] uvesafb: make sure that the v86d helper is installed and e=
xecutable
[    2.863496] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    2.863496] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    2.864317] uvesafb: vbe_init() failed with -22
[    2.864317] uvesafb: vbe_init() failed with -22
[    2.864882] uvesafb: probe of uvesafb.0 failed with error -22
[    2.864882] uvesafb: probe of uvesafb.0 failed with error -22
[    2.865794] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input0
[    2.865794] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/in=
put/input0
[    2.866729] ACPI: Power Button [PWRF]
[    2.866729] ACPI: Power Button [PWRF]
[    2.867610] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    2.867610] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    2.882521] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.882521] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    2.907701] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200=
) is a 16550A
[    2.907701] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200=
) is a 16550A
[    2.909232] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw=
2 Exp $
[    2.909232] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw=
2 Exp $
[    2.910186] ac.o: No PCI boards found.
[    2.910186] ac.o: No PCI boards found.
[    2.910691] ac.o: For an ISA board you must supply memory and irq para=
meters.
[    2.910691] ac.o: For an ISA board you must supply memory and irq para=
meters.
[    2.911639] Non-volatile memory driver v1.3
[    2.911639] Non-volatile memory driver v1.3
[    2.912180] toshiba: not a supported Toshiba laptop
[    2.912180] toshiba: not a supported Toshiba laptop
[    2.912880] scx200_gpio: no SCx200 gpio present
[    2.912880] scx200_gpio: no SCx200 gpio present
[    2.913464] nsc_gpio initializing
[    2.913464] nsc_gpio initializing
[    2.913894] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    2.913894] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    2.914539] Linux agpgart interface v0.103
[    2.914539] Linux agpgart interface v0.103
[    2.915355] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 sec=
onds, margin is 60 seconds).
[    2.915355] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 sec=
onds, margin is 60 seconds).
[    2.916500] Hangcheck: Using getrawmonotonic().
[    2.916500] Hangcheck: Using getrawmonotonic().
[    2.917112] [drm] Initialized drm 1.1.0 20060810
[    2.917112] [drm] Initialized drm 1.1.0 20060810
[    2.917838] drm/i810 does not support SMP
[    2.917838] drm/i810 does not support SMP
[    2.918478] usbcore: registered new interface driver udl
[    2.918478] usbcore: registered new interface driver udl
[    2.919614] Floppy drive(s):
[    2.919614] Floppy drive(s): fd0 is 1.44M fd0 is 1.44M

[    2.923008] brd: module loaded
[    2.923008] brd: module loaded
[    2.924848] loop: module loaded
[    2.924848] loop: module loaded
[    2.925661] nbd: registered device at major 43
[    2.925661] nbd: registered device at major 43
[    2.931070] drbd: initialized. Version: 8.4.3 (api:1/proto:86-101)
[    2.931070] drbd: initialized. Version: 8.4.3 (api:1/proto:86-101)
[    2.931899] drbd: built-in
[    2.931899] drbd: built-in
[    2.932247] drbd: registered as block device major 147
[    2.932247] drbd: registered as block device major 147
[    2.933031] rbd: loaded
[    2.933031] rbd: loaded
[    2.933457] lkdtm: No crash points registered, enable through debugfs
[    2.933457] lkdtm: No crash points registered, enable through debugfs
[    2.934344] Phantom Linux Driver, version n0.9.8, init OK
[    2.934344] Phantom Linux Driver, version n0.9.8, init OK
[    2.935161] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo =
Giometti
[    2.935161] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo =
Giometti
[    2.936308] usbcore: registered new interface driver rtsx_usb
[    2.936308] usbcore: registered new interface driver rtsx_usb
[    2.937379] usbcore: registered new interface driver nfcmrvl
[    2.937379] usbcore: registered new interface driver nfcmrvl
[    2.938363] Loading iSCSI transport class v2.0-870.
[    2.938363] Loading iSCSI transport class v2.0-870.
[    2.939296] rdac: device handler registered
[    2.939296] rdac: device handler registered
[    2.939958] alua: device handler registered
[    2.939958] alua: device handler registered
[    2.940561] osst :I: Tape driver with OnStream support version 0.99.4
[    2.940561] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp=
 $
[    2.940561] osst :I: Tape driver with OnStream support version 0.99.4
[    2.940561] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp=
 $
[    2.941175] FDC 0 is a S82078B
[    2.941175] FDC 0 is a S82078B
[    2.942973] SCSI Media Changer driver v0.25=20
[    2.942973] SCSI Media Changer driver v0.25=20
[    2.943606] osd: LOADED open-osd 0.2.1
[    2.943606] osd: LOADED open-osd 0.2.1
[    2.944416] SSFDC read-only Flash Translation layer
[    2.944416] SSFDC read-only Flash Translation layer
[    2.945123] mtdoops: mtd device (mtddev=3Dname/number) must be supplie=
d
[    2.945123] mtdoops: mtd device (mtddev=3Dname/number) must be supplie=
d
[    2.946001] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    2.946001] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    2.946816] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    2.946816] scx200_docflash: NatSemi SCx200 DOCCS Flash Driver
[    2.947715] slram: not enough parameters.
[    2.947715] slram: not enough parameters.
[    2.948610] ftl_cs: FTL header not found.
[    2.948610] ftl_cs: FTL header not found.
[    2.951050] libphy: Fixed MDIO Bus: probed
[    2.951050] libphy: Fixed MDIO Bus: probed
[    2.952034] arcnet loaded.
[    2.952034] arcnet loaded.
[    2.952472] arcnet: RFC1201 "standard" (`a') encapsulation support loa=
ded.
[    2.952472] arcnet: RFC1201 "standard" (`a') encapsulation support loa=
ded.
[    2.953507] arcnet: raw mode (`r') encapsulation support loaded.
[    2.953507] arcnet: raw mode (`r') encapsulation support loaded.
[    2.954349] arcnet: cap mode (`c') encapsulation support loaded.
[    2.954349] arcnet: cap mode (`c') encapsulation support loaded.
[    2.955257] arcnet: RIM I (entirely mem-mapped) support
[    2.955257] arcnet: RIM I (entirely mem-mapped) support
[    2.956008] E-mail me if you actually test the RIM I driver, please!
[    2.956008] E-mail me if you actually test the RIM I driver, please!
[    2.956878] Given: node 00h, shmem 0h, irq 0
[    2.956878] Given: node 00h, shmem 0h, irq 0
[    2.957456] No autoprobe for RIM I; you must specify the shmem and irq=
!
[    2.957456] No autoprobe for RIM I; you must specify the shmem and irq=
!
[    2.958363] arcnet: COM20020 PCI support
[    2.958363] arcnet: COM20020 PCI support
[    2.958954] CAN device driver interface
[    2.958954] CAN device driver interface
[    2.959523] usbcore: registered new interface driver ems_usb
[    2.959523] usbcore: registered new interface driver ems_usb
[    2.960328] usbcore: registered new interface driver kvaser_usb
[    2.960328] usbcore: registered new interface driver kvaser_usb
[    2.961137] usbcore: registered new interface driver peak_usb
[    2.961137] usbcore: registered new interface driver peak_usb
[    2.961945] usbcore: registered new interface driver usb_8dev
[    2.961945] usbcore: registered new interface driver usb_8dev
[    2.962761] sja1000 CAN netdevice driver
[    2.962761] sja1000 CAN netdevice driver
[    2.963246] sja1000_isa: insufficient parameters supplied
[    2.963246] sja1000_isa: insufficient parameters supplied
[    2.964157] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.964157] baycom_ser_fdx: version 0.10
[    2.964157] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[    2.964157] baycom_ser_fdx: version 0.10
[    2.966420] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    2.966420] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[    2.967185] hdlcdrv: version 0.8
[    2.967185] hdlcdrv: version 0.8
[    2.967701] usbcore: registered new interface driver irda-usb
[    2.967701] usbcore: registered new interface driver irda-usb
[    2.968489] usbcore: registered new interface driver stir4200
[    2.968489] usbcore: registered new interface driver stir4200
[    2.969489] usbcore: registered new interface driver mcs7780
[    2.969489] usbcore: registered new interface driver mcs7780
[    2.970286] usbcore: registered new interface driver kingsun-sir
[    2.970286] usbcore: registered new interface driver kingsun-sir
[    2.971127] usbcore: registered new interface driver ksdazzle-sir
[    2.971127] usbcore: registered new interface driver ksdazzle-sir
[    2.971880] PPP generic driver version 2.4.2
[    2.971880] PPP generic driver version 2.4.2
[    2.972494] PPP BSD Compression module registered
[    2.972494] PPP BSD Compression module registered
[    2.973074] PPP Deflate Compression module registered
[    2.973074] PPP Deflate Compression module registered
[    2.973705] PPP MPPE Compression module registered
[    2.973705] PPP MPPE Compression module registered
[    2.974295] NET: Registered protocol family 24
[    2.974295] NET: Registered protocol family 24
[    2.974860] PPTP driver version 0.8.5
[    2.974860] PPTP driver version 0.8.5
[    2.975388] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.=
2.2
[    2.975388] ipw2100: Intel(R) PRO/Wireless 2100 Network Driver, git-1.=
2.2
[    2.976222] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    2.976222] ipw2100: Copyright(c) 2003-2006 Intel Corporation
[    2.976975] libipw: 802.11 data/management/control stack, git-1.1.13
[    2.976975] libipw: 802.11 data/management/control stack, git-1.1.13
[    2.977800] libipw: Copyright (C) 2004-2005 Intel Corporation <jketren=
o@linux.intel.com>
[    2.977800] libipw: Copyright (C) 2004-2005 Intel Corporation <jketren=
o@linux.intel.com>
[    2.978803] airo(): Probing for PCI adapters
[    2.978803] airo(): Probing for PCI adapters
[    2.979363] airo(): Finished probing for PCI adapters
[    2.979363] airo(): Finished probing for PCI adapters
[    2.980068] usbcore: registered new interface driver rndis_wlan
[    2.980068] usbcore: registered new interface driver rndis_wlan
[    2.980838] libertas_sdio: Libertas SDIO driver
[    2.980838] libertas_sdio: Libertas SDIO driver
[    2.981405] libertas_sdio: Copyright Pierre Ossman
[    2.981405] libertas_sdio: Copyright Pierre Ossman
[    2.982039] usbcore: registered new interface driver ath6kl_usb
[    2.982039] usbcore: registered new interface driver ath6kl_usb
[    2.982865] usbcore: registered new interface driver i2400m_usb
[    2.982865] usbcore: registered new interface driver i2400m_usb
[    2.983607] VMware vmxnet3 virtual NIC driver - version 1.2.0.0-k-NAPI=

[    2.983607] VMware vmxnet3 virtual NIC driver - version 1.2.0.0-k-NAPI=

[    2.984437] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ether=
net driver
[    2.984437] pegasus: v0.9.3 (2013/04/25), Pegasus/Pegasus II USB Ether=
net driver
[    2.985379] usbcore: registered new interface driver pegasus
[    2.985379] usbcore: registered new interface driver pegasus
[    2.986100] usbcore: registered new interface driver rtl8150
[    2.986100] usbcore: registered new interface driver rtl8150
[    2.986827] usbcore: registered new interface driver asix
[    2.986827] usbcore: registered new interface driver asix
[    2.987550] usbcore: registered new interface driver cdc_ether
[    2.987550] usbcore: registered new interface driver cdc_ether
[    2.988305] usbcore: registered new interface driver cdc_eem
[    2.988305] usbcore: registered new interface driver cdc_eem
[    2.989033] usbcore: registered new interface driver dm9601
[    2.989033] usbcore: registered new interface driver dm9601
[    2.989751] usbcore: registered new interface driver sr9700
[    2.989751] usbcore: registered new interface driver sr9700
[    2.990500] usbcore: registered new interface driver CoreChips
[    2.990500] usbcore: registered new interface driver CoreChips
[    2.991272] usbcore: registered new interface driver smsc75xx
[    2.991272] usbcore: registered new interface driver smsc75xx
[    2.992015] usbcore: registered new interface driver smsc95xx
[    2.992015] usbcore: registered new interface driver smsc95xx
[    2.992748] usbcore: registered new interface driver net1080
[    2.992748] usbcore: registered new interface driver net1080
[    2.993469] usbcore: registered new interface driver rndis_host
[    2.993469] usbcore: registered new interface driver rndis_host
[    2.994223] usbcore: registered new interface driver cdc_subset
[    2.994223] usbcore: registered new interface driver cdc_subset
[    2.994976] usbcore: registered new interface driver zaurus
[    2.994976] usbcore: registered new interface driver zaurus
[    2.995688] usbcore: registered new interface driver MOSCHIP usb-ether=
net driver
[    2.995688] usbcore: registered new interface driver MOSCHIP usb-ether=
net driver
[    2.996631] usbcore: registered new interface driver int51x1
[    2.996631] usbcore: registered new interface driver int51x1
[    2.997364] usbcore: registered new interface driver kalmia
[    2.997364] usbcore: registered new interface driver kalmia
[    2.998113] usbcore: registered new interface driver ipheth
[    2.998113] usbcore: registered new interface driver ipheth
[    2.998821] usbcore: registered new interface driver sierra_net
[    2.998821] usbcore: registered new interface driver sierra_net
[    2.999577] usbcore: registered new interface driver cdc_ncm
[    2.999577] usbcore: registered new interface driver cdc_ncm
[    3.000342] usbcore: registered new interface driver cdc_mbim
[    3.000342] usbcore: registered new interface driver cdc_mbim
[    3.001129] Madge ATM Horizon [Ultra] driver version 1.2.1
[    3.001129] Madge ATM Horizon [Ultra] driver version 1.2.1
[    3.001816] hrz: debug bitmap is 0
[    3.001816] hrz: debug bitmap is 0
[    3.002307] idt77252_init: at 7acab4d7
[    3.002307] idt77252_init: at 7acab4d7
[    3.002803] Solos PCI Driver Version 1.04
[    3.002803] Solos PCI Driver Version 1.04
[    3.003332] adummy: version 1.0
[    3.003332] adummy: version 1.0
[    3.003843] I2O subsystem v1.325
[    3.003843] I2O subsystem v1.325
[    3.004252] i2o: max drivers =3D 8
[    3.004252] i2o: max drivers =3D 8
[    3.004747] usbcore: registered new interface driver brcmfmac
[    3.004747] usbcore: registered new interface driver brcmfmac
[    3.005589] I2O Configuration OSM v1.323
[    3.005589] I2O Configuration OSM v1.323
[    3.006121] I2O Block Device OSM v1.325
[    3.006121] I2O Block Device OSM v1.325
[    3.006888] I2O ProcFS OSM v1.316
[    3.006888] I2O ProcFS OSM v1.316
[    3.007359] Fusion MPT base driver 3.04.20
[    3.007359] Fusion MPT base driver 3.04.20
[    3.007915] Copyright (c) 1999-2008 LSI Corporation
[    3.007915] Copyright (c) 1999-2008 LSI Corporation
[    3.008536] Fusion MPT SPI Host driver 3.04.20
[    3.008536] Fusion MPT SPI Host driver 3.04.20
[    3.009121] Fusion MPT FC Host driver 3.04.20
[    3.009121] Fusion MPT FC Host driver 3.04.20
[    3.010390] aoe: AoE v85 initialised.
[    3.010390] aoe: AoE v85 initialised.
[    3.011020] usbcore: registered new interface driver hwa-rc
[    3.011020] usbcore: registered new interface driver hwa-rc
[    3.011760] usbcore: registered new interface driver i1480-dfu-usb
[    3.011760] usbcore: registered new interface driver i1480-dfu-usb
[    3.012617] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver=

[    3.012617] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver=

[    3.013432] ehci-pci: EHCI PCI platform driver
[    3.013432] ehci-pci: EHCI PCI platform driver
[    3.014011] ehci-platform: EHCI generic platform driver
[    3.014011] ehci-platform: EHCI generic platform driver
[    3.014746] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.014746] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    3.015527] ohci-platform: OHCI generic platform driver
[    3.015527] ohci-platform: OHCI generic platform driver
[    3.016448] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    3.016448] fotg210_hcd: FOTG210 Host Controller (EHCI) Driver
[    3.018411] usbcore: registered new interface driver cdc_wdm
[    3.018411] usbcore: registered new interface driver cdc_wdm
[    3.019135] usbcore: registered new interface driver usbtmc
[    3.019135] usbcore: registered new interface driver usbtmc
[    3.019852] usbcore: registered new interface driver usb-storage
[    3.019852] usbcore: registered new interface driver usb-storage
[    3.020673] usbcore: registered new interface driver ums-datafab
[    3.020673] usbcore: registered new interface driver ums-datafab
[    3.021449] usbcore: registered new interface driver ums-freecom
[    3.021449] usbcore: registered new interface driver ums-freecom
[    3.022211] usbcore: registered new interface driver ums-jumpshot
[    3.022211] usbcore: registered new interface driver ums-jumpshot
[    3.022987] usbcore: registered new interface driver ums-onetouch
[    3.022987] usbcore: registered new interface driver ums-onetouch
[    3.023756] usbcore: registered new interface driver ums-sddr09
[    3.023756] usbcore: registered new interface driver ums-sddr09
[    3.024506] usbcore: registered new interface driver ums-usbat
[    3.024506] usbcore: registered new interface driver ums-usbat
[    3.025260] usbcore: registered new interface driver mdc800
[    3.025260] usbcore: registered new interface driver mdc800
[    3.025959] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 D=
igital Camera
[    3.025959] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 D=
igital Camera
[    3.026927] usbcore: registered new interface driver microtekX6
[    3.026927] usbcore: registered new interface driver microtekX6
[    3.027820] usbcore: registered new interface driver appledisplay
[    3.027820] usbcore: registered new interface driver appledisplay
[    3.028636] usbcore: registered new interface driver cypress_cy7c63
[    3.028636] usbcore: registered new interface driver cypress_cy7c63
[    3.029440] usbcore: registered new interface driver cytherm
[    3.029440] usbcore: registered new interface driver cytherm
[    3.030203] usbcore: registered new interface driver emi26 - firmware =
loader
[    3.030203] usbcore: registered new interface driver emi26 - firmware =
loader
[    3.031105] driver ftdi-elan
[    3.031105] driver ftdi-elan
[    3.031663] usbcore: registered new interface driver ftdi-elan
[    3.031663] usbcore: registered new interface driver ftdi-elan
[    3.032440] usbcore: registered new interface driver idmouse
[    3.032440] usbcore: registered new interface driver idmouse
[    3.033167] usbcore: registered new interface driver iowarrior
[    3.033167] usbcore: registered new interface driver iowarrior
[    3.033919] usbcore: registered new interface driver isight_firmware
[    3.033919] usbcore: registered new interface driver isight_firmware
[    3.034738] usbcore: registered new interface driver usblcd
[    3.034738] usbcore: registered new interface driver usblcd
[    3.035455] usbcore: registered new interface driver ldusb
[    3.035455] usbcore: registered new interface driver ldusb
[    3.036158] usbcore: registered new interface driver usbled
[    3.036158] usbcore: registered new interface driver usbled
[    3.036873] usbcore: registered new interface driver legousbtower
[    3.036873] usbcore: registered new interface driver legousbtower
[    3.037703] usbcore: registered new interface driver rio500
[    3.037703] usbcore: registered new interface driver rio500
[    3.038459] usbcore: registered new interface driver usbtest
[    3.038459] usbcore: registered new interface driver usbtest
[    3.039180] usbcore: registered new interface driver trancevibrator
[    3.039180] usbcore: registered new interface driver trancevibrator
[    3.039995] usbcore: registered new interface driver usbsevseg
[    3.039995] usbcore: registered new interface driver usbsevseg
[    3.040791] usbcore: registered new interface driver yurex
[    3.040791] usbcore: registered new interface driver yurex
[    3.041527] usbcore: registered new interface driver sisusb
[    3.041527] usbcore: registered new interface driver sisusb
[    3.042319] usbcore: registered new interface driver speedtch
[    3.042319] usbcore: registered new interface driver speedtch
[    3.043040] xusbatm: malformed module parameters
[    3.043040] xusbatm: malformed module parameters
[    3.044103] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0=
x60,0x64 irq 1,12
[    3.044103] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0=
x60,0x64 irq 1,12
[    3.045707] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.045707] serio: i8042 KBD port at 0x60,0x64 irq 1
[    3.046365] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.046365] serio: i8042 AUX port at 0x60,0x64 irq 12
[    3.047208] mousedev: PS/2 mouse device common for all mice
[    3.047208] mousedev: PS/2 mouse device common for all mice
[    3.048004] evbug: Connected device: input0 (Power Button at LNXPWRBN/=
button/input0)
[    3.048004] evbug: Connected device: input0 (Power Button at LNXPWRBN/=
button/input0)
[    3.049641] rtc_cmos 00:00: RTC can wake from S4
[    3.049641] rtc_cmos 00:00: RTC can wake from S4
[    3.050514] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    3.050514] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[    3.051411] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpe=
t irqs
[    3.051411] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpe=
t irqs
[    3.052857] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    3.052857] rtc-test rtc-test.0: rtc core: registered test as rtc1
[    3.053767] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    3.053767] rtc-test rtc-test.1: rtc core: registered test as rtc2
[    3.054780] i2c /dev entries driver
[    3.054780] i2c /dev entries driver
[    3.055512] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100,=
 revision 0
[    3.055512] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100,=
 revision 0
[    3.057049] input: AT Translated Set 2 keyboard as /devices/platform/i=
8042/serio0/input/input1
[    3.057049] input: AT Translated Set 2 keyboard as /devices/platform/i=
8042/serio0/input/input1
[    3.058300] evbug: Connected device: input1 (AT Translated Set 2 keybo=
ard at isa0060/serio0/input0)
[    3.058300] evbug: Connected device: input1 (AT Translated Set 2 keybo=
ard at isa0060/serio0/input0)
[    3.070109] tsc: Refined TSC clocksource calibration: 2693.462 MHz
[    3.070109] tsc: Refined TSC clocksource calibration: 2693.462 MHz
[    3.330536] usbcore: registered new interface driver i2c-tiny-usb
[    3.330536] usbcore: registered new interface driver i2c-tiny-usb
[    3.331394] scx200_i2c: no SCx200 gpio pins available
[    3.331394] scx200_i2c: no SCx200 gpio pins available
[    3.332434] saa7146: register extension 'budget_av'
[    3.332434] saa7146: register extension 'budget_av'
[    3.333118] saa7146: register extension 'budget_patch dvb'
[    3.333118] saa7146: register extension 'budget_patch dvb'
[    3.333900] saa7146: register extension 'av7110'
[    3.333900] saa7146: register extension 'av7110'
[    3.334583] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas=

[    3.334583] nGene PCIE bridge driver, Copyright (C) 2005-2007 Micronas=

[    3.335464] Digital Devices PCIE bridge driver, Copyright (C) 2010-11 =
Digital Devices GmbH
[    3.335464] Digital Devices PCIE bridge driver, Copyright (C) 2010-11 =
Digital Devices GmbH
[    3.336599] saa7146: register extension 'Multimedia eXtension Board'
[    3.336599] saa7146: register extension 'Multimedia eXtension Board'
[    3.337463] saa7146: register extension 'hexium HV-PCI6 Orion'
[    3.337463] saa7146: register extension 'hexium HV-PCI6 Orion'
[    3.338296] saa7146: register extension 'hexium gemini'
[    3.338296] saa7146: register extension 'hexium gemini'
[    3.339021] saa7130/34: v4l2 driver version 0, 2, 17 loaded
[    3.339021] saa7130/34: v4l2 driver version 0, 2, 17 loaded
[    3.339894] pps pps0: new PPS source ktimer
[    3.339894] pps pps0: new PPS source ktimer
[    3.340469] pps pps0: ktimer PPS source registered
[    3.340469] pps pps0: ktimer PPS source registered
[    3.341132] Driver for 1-wire Dallas network protocol.
[    3.341132] Driver for 1-wire Dallas network protocol.
[    3.341907] usbcore: registered new interface driver DS9490R
[    3.341907] usbcore: registered new interface driver DS9490R
[    3.342735] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    3.342735] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    3.343576] 1-Wire driver for the DS2760 battery monitor  chip  - (c) =
2004-2005, Szabolcs Gyurko
[    3.343576] 1-Wire driver for the DS2760 battery monitor  chip  - (c) =
2004-2005, Szabolcs Gyurko
[    3.540102] i2c i2c-0: w83795: Detection failed at addr 0x2c, check ba=
nk
[    3.540102] i2c i2c-0: w83795: Detection failed at addr 0x2c, check ba=
nk
[    3.580101] i2c i2c-0: w83795: Detection failed at addr 0x2d, check ba=
nk
[    3.580101] i2c i2c-0: w83795: Detection failed at addr 0x2d, check ba=
nk
[    3.620099] i2c i2c-0: w83795: Detection failed at addr 0x2e, check ba=
nk
[    3.620099] i2c i2c-0: w83795: Detection failed at addr 0x2e, check ba=
nk
[    3.660092] i2c i2c-0: w83795: Detection failed at addr 0x2f, check ba=
nk
[    3.660092] i2c i2c-0: w83795: Detection failed at addr 0x2f, check ba=
nk
[    4.260057] detect failed, chip not detected!
[    4.260057] detect failed, chip not detected!
[    4.340078] detect failed, chip not detected!
[    4.340078] detect failed, chip not detected!
[    4.420059] detect failed, chip not detected!
[    4.420059] detect failed, chip not detected!
[    4.500057] detect failed, chip not detected!
[    4.500057] detect failed, chip not detected!
[    4.580054] detect failed, chip not detected!
[    4.580054] detect failed, chip not detected!
[    4.660060] detect failed, chip not detected!
[    4.660060] detect failed, chip not detected!
[    4.740099] detect failed, chip not detected!
[    4.740099] detect failed, chip not detected!
[    4.820055] detect failed, chip not detected!
[    4.820055] detect failed, chip not detected!
[    4.900087] detect failed, chip not detected!
[    4.900087] detect failed, chip not detected!
[    4.960119] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    4.960119] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    4.961179] i2c i2c-0: Autodetecting device at 0,0x2c...
[    4.961179] i2c i2c-0: Autodetecting device at 0,0x2c...
[    4.961861] i2c i2c-0: Autodetection failed
[    4.961861] i2c i2c-0: Autodetection failed
[    5.020062] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    5.020062] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    5.021087] i2c i2c-0: Autodetecting device at 0,0x2d...
[    5.021087] i2c i2c-0: Autodetecting device at 0,0x2d...
[    5.021768] i2c i2c-0: Autodetection failed
[    5.021768] i2c i2c-0: Autodetection failed
[    5.080060] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    5.080060] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff a=
nd VERSTEP: 0xff
[    5.081166] i2c i2c-0: Autodetecting device at 0,0x2e...
[    5.081166] i2c i2c-0: Autodetecting device at 0,0x2e...
[    5.081826] i2c i2c-0: Autodetection failed
[    5.081826] i2c i2c-0: Autodetection failed
[    5.300095] i2c i2c-0: detect fail: address match, 0x2c
[    5.300095] i2c i2c-0: detect fail: address match, 0x2c
[    5.340092] i2c i2c-0: detect fail: address match, 0x2d
[    5.340092] i2c i2c-0: detect fail: address match, 0x2d
[    5.380101] i2c i2c-0: detect fail: address match, 0x2e
[    5.380101] i2c i2c-0: detect fail: address match, 0x2e
[    5.420095] i2c i2c-0: detect fail: address match, 0x2f
[    5.420095] i2c i2c-0: detect fail: address match, 0x2f
[    5.720059] applesmc: supported laptop not found!
[    5.720059] applesmc: supported laptop not found!
[    5.720689] applesmc: driver init failed (ret=3D-19)!
[    5.720689] applesmc: driver init failed (ret=3D-19)!
[    6.140072] f71882fg: Not a Fintek device
[    6.140072] f71882fg: Not a Fintek device
[    6.140631] f71882fg: Not a Fintek device
[    6.140631] f71882fg: Not a Fintek device
[    6.380055]  (null): Unknown chip type, skipping
[    6.380055]  (null): Unknown chip type, skipping
[    6.420053]  (null): Unknown chip type, skipping
[    6.420053]  (null): Unknown chip type, skipping
[    6.560058] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[    6.560058] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[    6.700122] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[    6.700122] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[    6.840054] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[    6.840054] i2c i2c-0: Unsupported chip (man_id=3D0xFF, chip_id=3D0xFF=
)
[   20.410105] i2c i2c-0: LM83 detection failed at 0x18
[   20.410105] i2c i2c-0: LM83 detection failed at 0x18
[   20.450102] i2c i2c-0: LM83 detection failed at 0x19
[   20.450102] i2c i2c-0: LM83 detection failed at 0x19
[   20.490121] i2c i2c-0: LM83 detection failed at 0x1a
[   20.490121] i2c i2c-0: LM83 detection failed at 0x1a
[   20.530122] i2c i2c-0: LM83 detection failed at 0x29
[   20.530122] i2c i2c-0: LM83 detection failed at 0x29
[   20.570099] i2c i2c-0: LM83 detection failed at 0x2a
[   20.570099] i2c i2c-0: LM83 detection failed at 0x2a
[   20.610092] i2c i2c-0: LM83 detection failed at 0x2b
[   20.610092] i2c i2c-0: LM83 detection failed at 0x2b
[   20.650105] i2c i2c-0: LM83 detection failed at 0x4c
[   20.650105] i2c i2c-0: LM83 detection failed at 0x4c
[   20.690093] i2c i2c-0: LM83 detection failed at 0x4d
[   20.690093] i2c i2c-0: LM83 detection failed at 0x4d
[   20.730097] i2c i2c-0: LM83 detection failed at 0x4e
[   20.730097] i2c i2c-0: LM83 detection failed at 0x4e
[   20.830111] i2c i2c-0: Unsupported chip at 0x18 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   20.830111] i2c i2c-0: Unsupported chip at 0x18 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   20.930094] i2c i2c-0: Unsupported chip at 0x19 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   20.930094] i2c i2c-0: Unsupported chip at 0x19 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.030115] i2c i2c-0: Unsupported chip at 0x1a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.030115] i2c i2c-0: Unsupported chip at 0x1a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.130112] i2c i2c-0: Unsupported chip at 0x29 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.130112] i2c i2c-0: Unsupported chip at 0x29 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.230100] i2c i2c-0: Unsupported chip at 0x2a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.230100] i2c i2c-0: Unsupported chip at 0x2a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.330103] i2c i2c-0: Unsupported chip at 0x2b (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.330103] i2c i2c-0: Unsupported chip at 0x2b (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.430120] i2c i2c-0: Unsupported chip at 0x48 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.430120] i2c i2c-0: Unsupported chip at 0x48 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.530101] i2c i2c-0: Unsupported chip at 0x49 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.530101] i2c i2c-0: Unsupported chip at 0x49 (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.630107] i2c i2c-0: Unsupported chip at 0x4a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.630107] i2c i2c-0: Unsupported chip at 0x4a (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.730098] i2c i2c-0: Unsupported chip at 0x4b (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.730098] i2c i2c-0: Unsupported chip at 0x4b (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.830096] i2c i2c-0: Unsupported chip at 0x4c (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.830096] i2c i2c-0: Unsupported chip at 0x4c (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.930097] i2c i2c-0: Unsupported chip at 0x4d (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   21.930097] i2c i2c-0: Unsupported chip at 0x4d (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   22.030116] i2c i2c-0: Unsupported chip at 0x4e (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   22.030116] i2c i2c-0: Unsupported chip at 0x4e (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   22.130102] i2c i2c-0: Unsupported chip at 0x4f (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   22.130102] i2c i2c-0: Unsupported chip at 0x4f (man_id=3D0xFF, chip_i=
d=3D0xFF)
[   22.730094] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   22.730094] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   22.770102] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   22.770102] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   22.810110] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   22.810110] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[   23.630242] pc87360: PC8736x not detected, module not inserted
[   23.630242] pc87360: PC8736x not detected, module not inserted
[   23.631010] sch56xx_common: Unsupported device id: 0xff
[   23.631010] sch56xx_common: Unsupported device id: 0xff
[   23.631655] sch56xx_common: Unsupported device id: 0xff
[   23.631655] sch56xx_common: Unsupported device id: 0xff
[   23.690101] i2c i2c-0: SMSC47M192 detection failed at 0x2c
[   23.690101] i2c i2c-0: SMSC47M192 detection failed at 0x2c
[   23.750095] i2c i2c-0: SMSC47M192 detection failed at 0x2d
[   23.750095] i2c i2c-0: SMSC47M192 detection failed at 0x2d
[   23.770134] i2c i2c-0: amc6821_detect called.
[   23.770134] i2c i2c-0: amc6821_detect called.
[   23.810098] i2c i2c-0: amc6821: detection failed at 0x18.
[   23.810098] i2c i2c-0: amc6821: detection failed at 0x18.
[   23.830096] i2c i2c-0: amc6821_detect called.
[   23.830096] i2c i2c-0: amc6821_detect called.
[   23.870095] i2c i2c-0: amc6821: detection failed at 0x19.
[   23.870095] i2c i2c-0: amc6821: detection failed at 0x19.
[   23.890099] i2c i2c-0: amc6821_detect called.
[   23.890099] i2c i2c-0: amc6821_detect called.
[   23.930101] i2c i2c-0: amc6821: detection failed at 0x1a.
[   23.930101] i2c i2c-0: amc6821: detection failed at 0x1a.
[   23.950128] i2c i2c-0: amc6821_detect called.
[   23.950128] i2c i2c-0: amc6821_detect called.
[   23.990100] i2c i2c-0: amc6821: detection failed at 0x2c.
[   23.990100] i2c i2c-0: amc6821: detection failed at 0x2c.
[   24.010108] i2c i2c-0: amc6821_detect called.
[   24.010108] i2c i2c-0: amc6821_detect called.
[   24.050107] i2c i2c-0: amc6821: detection failed at 0x2d.
[   24.050107] i2c i2c-0: amc6821: detection failed at 0x2d.
[   24.070109] i2c i2c-0: amc6821_detect called.
[   24.070109] i2c i2c-0: amc6821_detect called.
[   24.110090] i2c i2c-0: amc6821: detection failed at 0x2e.
[   24.110090] i2c i2c-0: amc6821: detection failed at 0x2e.
[   24.130120] i2c i2c-0: amc6821_detect called.
[   24.130120] i2c i2c-0: amc6821_detect called.
[   24.170098] i2c i2c-0: amc6821: detection failed at 0x4c.
[   24.170098] i2c i2c-0: amc6821: detection failed at 0x4c.
[   24.190097] i2c i2c-0: amc6821_detect called.
[   24.190097] i2c i2c-0: amc6821_detect called.
[   24.230102] i2c i2c-0: amc6821: detection failed at 0x4d.
[   24.230102] i2c i2c-0: amc6821: detection failed at 0x4d.
[   24.250100] i2c i2c-0: amc6821_detect called.
[   24.250100] i2c i2c-0: amc6821_detect called.
[   24.290103] i2c i2c-0: amc6821: detection failed at 0x4e.
[   24.290103] i2c i2c-0: amc6821: detection failed at 0x4e.
[   24.310123] thmc50: Probing for THMC50 at 0x2C on bus 0
[   24.310123] thmc50: Probing for THMC50 at 0x2C on bus 0
[   24.390092] thmc50: Probing for THMC50 at 0x2D on bus 0
[   24.390092] thmc50: Probing for THMC50 at 0x2D on bus 0
[   24.470089] thmc50: Probing for THMC50 at 0x2E on bus 0
[   24.470089] thmc50: Probing for THMC50 at 0x2E on bus 0
[   24.890056] i2c i2c-0: w83l785ts: Read 0xff from register 0x40.
[   24.890056] i2c i2c-0: w83l785ts: Read 0xff from register 0x40.
[   24.890836] i2c i2c-0: W83L785TS-S detection failed at 0x2e
[   24.890836] i2c i2c-0: W83L785TS-S detection failed at 0x2e
[   24.891782] acquirewdt: WDT driver for Acquire single board computer i=
nitialising
[   24.891782] acquirewdt: WDT driver for Acquire single board computer i=
nitialising
[   24.892865] acquirewdt: I/O address 0x0043 already in use
[   24.892865] acquirewdt: I/O address 0x0043 already in use
[   24.893574] acquirewdt: probe of acquirewdt failed with error -5
[   24.893574] acquirewdt: probe of acquirewdt failed with error -5
[   24.894411] advantechwdt: WDT driver for Advantech single board comput=
er initialising
[   24.894411] advantechwdt: WDT driver for Advantech single board comput=
er initialising
[   24.895527] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)=

[   24.895527] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)=

[   24.896450] geodewdt: No timers were available
[   24.896450] geodewdt: No timers were available
[   24.897078] ib700wdt: WDT driver for IB700 single board computer initi=
alising
[   24.897078] ib700wdt: WDT driver for IB700 single board computer initi=
alising
[   24.898072] ib700wdt: START method I/O 443 is not available
[   24.898072] ib700wdt: START method I/O 443 is not available
[   24.898809] ib700wdt: probe of ib700wdt failed with error -5
[   24.898809] ib700wdt: probe of ib700wdt failed with error -5
[   24.899625] wafer5823wdt: WDT driver for Wafer 5823 single board compu=
ter initialising
[   24.899625] wafer5823wdt: WDT driver for Wafer 5823 single board compu=
ter initialising
[   24.900692] wafer5823wdt: I/O address 0x0443 already in use
[   24.900692] wafer5823wdt: I/O address 0x0443 already in use
[   24.901458] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   24.901458] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   24.902345] i6300esb: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   24.902345] i6300esb: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   24.903217] i6300ESB timer: probe of 0000:00:04.0 failed with error -1=
6
[   24.903217] i6300ESB timer: probe of 0000:00:04.0 failed with error -1=
6
[   24.904142] sc1200wdt: build 20020303
[   24.904142] sc1200wdt: build 20020303
[   24.904661] sc1200wdt: io parameter must be specified
[   24.904661] sc1200wdt: io parameter must be specified
[   24.905357] cpu5wdt: misc_register failed
[   24.905357] cpu5wdt: misc_register failed
[   24.905909] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 =
initialising...
[   24.905909] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 =
initialising...
[   24.907960] smsc37b787_wdt: Unable to register miscdev on minor 130
[   24.907960] smsc37b787_wdt: Unable to register miscdev on minor 130
[   24.908852] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   24.908852] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   24.909634] w83697hf_wdt: watchdog not found at address 0x2e
[   24.909634] w83697hf_wdt: watchdog not found at address 0x2e
[   24.910413] w83697hf_wdt: No W83697HF/HG could be found
[   24.910413] w83697hf_wdt: No W83697HF/HG could be found
[   24.911139] w83977f_wdt: driver v1.00
[   24.911139] w83977f_wdt: driver v1.00
[   24.911593] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   24.911593] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   24.912459] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   24.912459] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   24.913246] machzwd: no ZF-Logic found
[   24.913246] machzwd: no ZF-Logic found
[   24.913798] watchdog: Software Watchdog: cannot register miscdev on mi=
nor=3D130 (err=3D-16).
[   24.913798] watchdog: Software Watchdog: cannot register miscdev on mi=
nor=3D130 (err=3D-16).
[   24.914870] watchdog: Software Watchdog: a legacy watchdog module is p=
robably present.
[   24.914870] watchdog: Software Watchdog: a legacy watchdog module is p=
robably present.
[   24.915956] softdog: Software Watchdog Timer: 0.08 initialized. soft_n=
oboot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   24.915956] softdog: Software Watchdog Timer: 0.08 initialized. soft_n=
oboot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   24.917384] md: linear personality registered for level -1
[   24.917384] md: linear personality registered for level -1
[   24.918093] md: raid0 personality registered for level 0
[   24.918093] md: raid0 personality registered for level 0
[   24.918780] md: raid1 personality registered for level 1
[   24.918780] md: raid1 personality registered for level 1
[   24.919477] md: raid10 personality registered for level 10
[   24.919477] md: raid10 personality registered for level 10
[   24.920288] md: raid6 personality registered for level 6
[   24.920288] md: raid6 personality registered for level 6
[   24.920982] md: raid5 personality registered for level 5
[   24.920982] md: raid5 personality registered for level 5
[   24.921633] md: raid4 personality registered for level 4
[   24.921633] md: raid4 personality registered for level 4
[   24.922290] md: multipath personality registered for level -4
[   24.922290] md: multipath personality registered for level -4
[   24.923000] md: faulty personality registered for level -5
[   24.923000] md: faulty personality registered for level -5
[   24.923886] device-mapper: uevent: version 1.0.3
[   24.923886] device-mapper: uevent: version 1.0.3
[   24.924607] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialise=
d: dm-devel@redhat.com
[   24.924607] device-mapper: ioctl: 4.27.0-ioctl (2013-10-30) initialise=
d: dm-devel@redhat.com
[   24.925895] device-mapper: dm-log-userspace: version 1.3.0 loaded
[   24.925895] device-mapper: dm-log-userspace: version 1.3.0 loaded
[   24.926677] device-mapper: raid: Loading target version 1.5.2
[   24.926677] device-mapper: raid: Loading target version 1.5.2
[   24.927455] device-mapper: cache-policy-mq: version 1.2.0 loaded
[   24.927455] device-mapper: cache-policy-mq: version 1.2.0 loaded
[   24.928229] device-mapper: cache cleaner: version 1.0.0 loaded
[   24.928229] device-mapper: cache cleaner: version 1.0.0 loaded
[   24.928949] Bluetooth: Virtual HCI driver ver 1.4
[   24.928949] Bluetooth: Virtual HCI driver ver 1.4
[   24.929596] usbcore: registered new interface driver bcm203x
[   24.929596] usbcore: registered new interface driver bcm203x
[   24.930359] usbcore: registered new interface driver bpa10x
[   24.930359] usbcore: registered new interface driver bpa10x
[   24.931104] usbcore: registered new interface driver bfusb
[   24.931104] usbcore: registered new interface driver bfusb
[   24.931807] usbcore: registered new interface driver btusb
[   24.931807] usbcore: registered new interface driver btusb
[   24.932525] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   24.932525] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   24.933264] wbsd: Copyright(c) Pierre Ossman
[   24.933264] wbsd: Copyright(c) Pierre Ossman
[   24.933856] VUB300 Driver rom wait states =3D 1C irqpoll timeout =3D 0=
400
[   24.933856] VUB300 Driver rom wait states =3D 1C irqpoll timeout =3D 0=
400

[   24.934840] usbcore: registered new interface driver vub300
[   24.934840] usbcore: registered new interface driver vub300
[   24.935599] usbcore: registered new interface driver ushc
[   24.935599] usbcore: registered new interface driver ushc
[   30.960057]  (null): enodev DEV ADDR =3D 0xFF
[   30.960057]  (null): enodev DEV ADDR =3D 0xFF
[   30.961561] iscsi: registered transport (iser)
[   30.961561] iscsi: registered transport (iser)
[   30.962387] dcdbas dcdbas: Dell Systems Management Base Driver (versio=
n 5.6.0-3.2)
[   30.962387] dcdbas dcdbas: Dell Systems Management Base Driver (versio=
n 5.6.0-3.2)
[   30.963421] cs5535-clockevt: Could not allocate MFGPT timer
[   30.963421] cs5535-clockevt: Could not allocate MFGPT timer
[   30.965343] usbcore: registered new interface driver usbhid
[   30.965343] usbcore: registered new interface driver usbhid
[   30.966072] usbhid: USB HID core driver
[   30.966072] usbhid: USB HID core driver
[   30.966589] usbcore: registered new interface driver Abilis Systems as=
10x usb driver
[   30.966589] usbcore: registered new interface driver Abilis Systems as=
10x usb driver
[   30.967633] usbcore: registered new interface driver go7007
[   30.967633] usbcore: registered new interface driver go7007
[   30.968372] usbcore: registered new interface driver go7007-loader
[   30.968372] usbcore: registered new interface driver go7007-loader
[   30.969232] usbcore: registered new interface driver prism2_usb
[   30.969232] usbcore: registered new interface driver prism2_usb
[   30.970055] usbcore: registered new interface driver r8712u
[   30.970055] usbcore: registered new interface driver r8712u
[   30.970814] usbcore: registered new interface driver rts5139
[   30.970814] usbcore: registered new interface driver rts5139
[   30.971554] usbcore: registered new interface driver line6usb
[   30.971554] usbcore: registered new interface driver line6usb
[   30.972513] Loading crystalhd 0.9.27
[   30.972513] Loading crystalhd 0.9.27
[   30.973075] usbcore: registered new interface driver ft1000usb
[   30.973075] usbcore: registered new interface driver ft1000usb
[   30.973919] logger: created 256K log 'log_main'
[   30.973919] logger: created 256K log 'log_main'
[   30.974537] logger: created 256K log 'log_events'
[   30.974537] logger: created 256K log 'log_events'
[   30.975203] logger: created 256K log 'log_radio'
[   30.975203] logger: created 256K log 'log_radio'
[   30.975865] logger: created 256K log 'log_system'
[   30.975865] logger: created 256K log 'log_system'
[   30.976654] ozwpan ozwpan: Ozmo Devices WPAN
[   30.976654] ozwpan ozwpan: Ozmo Devices WPAN
[   30.977224] ozwpan ozwpan: new USB bus registered, assigned bus number=
 1
[   30.977224] ozwpan ozwpan: new USB bus registered, assigned bus number=
 1
[   30.978187] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   30.978187] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0001
[   30.979056] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[   30.979056] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Se=
rialNumber=3D1
[   30.979975] usb usb1: Product: Ozmo Devices WPAN
[   30.979975] usb usb1: Product: Ozmo Devices WPAN
[   30.980572] usb usb1: Manufacturer: Linux 3.15.0-rc4-00068-g78ff4be Oz=
mo WPAN
[   30.980572] usb usb1: Manufacturer: Linux 3.15.0-rc4-00068-g78ff4be Oz=
mo WPAN
[   30.981481] usb usb1: SerialNumber: ozwpan
[   30.981481] usb usb1: SerialNumber: ozwpan
[   30.982275] hub 1-0:1.0: USB hub found
[   30.982275] hub 1-0:1.0: USB hub found
[   30.982808] hub 1-0:1.0: 8 ports detected
[   30.982808] hub 1-0:1.0: 8 ports detected
[   30.983641] usbcore: registered new interface driver cedusb
[   30.983641] usbcore: registered new interface driver cedusb
[   30.984455] hdaps: supported laptop not found!
[   30.984455] hdaps: supported laptop not found!
[   30.985054] hdaps: driver init failed (ret=3D-19)!
[   30.985054] hdaps: driver init failed (ret=3D-19)!
[   30.985665] goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Gol=
dfish MMIO.
[   30.985665] goldfish_pdev_bus goldfish_pdev_bus: unable to reserve Gol=
dfish MMIO.
[   30.986622] goldfish_pdev_bus: probe of goldfish_pdev_bus failed with =
error -16
[   30.986622] goldfish_pdev_bus: probe of goldfish_pdev_bus failed with =
error -16
[   30.988371] intel_rapl: driver does not support CPU family 15 model 6
[   30.988371] intel_rapl: driver does not support CPU family 15 model 6
[   30.989937] ASIHPI driver 4.10.01
[   30.989937] ASIHPI driver 4.10.01
[   30.991272] usbcore: registered new interface driver snd-ua101
[   30.991272] usbcore: registered new interface driver snd-ua101
[   30.992046] usbcore: registered new interface driver snd-usb-usx2y
[   30.992046] usbcore: registered new interface driver snd-usb-usx2y
[   30.992857] usbcore: registered new interface driver snd-usb-us122l
[   30.992857] usbcore: registered new interface driver snd-usb-us122l
[   30.993680] usbcore: registered new interface driver snd-usb-caiaq
[   30.993680] usbcore: registered new interface driver snd-usb-caiaq
[   30.994505] usbcore: registered new interface driver snd-usb-6fire
[   30.994505] usbcore: registered new interface driver snd-usb-6fire
[   30.995319] usbcore: registered new interface driver snd-usb-hiface
[   30.995319] usbcore: registered new interface driver snd-usb-hiface
[   30.998917] pktgen: Packet Generator for packet performance testing. V=
ersion: 2.74
[   30.998917] pktgen: Packet Generator for packet performance testing. V=
ersion: 2.74
[   31.000166] NET: Registered protocol family 26
[   31.000166] NET: Registered protocol family 26
[   31.000787] u32 classifier
[   31.000787] u32 classifier
[   31.001140]     input device check on
[   31.001140]     input device check on
[   31.001638] Netfilter messages via NETLINK v0.30.
[   31.001638] Netfilter messages via NETLINK v0.30.
[   31.002256] nfnl_acct: registering with nfnetlink.
[   31.002256] nfnl_acct: registering with nfnetlink.
[   31.002898] nf_conntrack version 0.5.0 (4523 buckets, 18092 max)
[   31.002898] nf_conntrack version 0.5.0 (4523 buckets, 18092 max)
[   31.003844] ctnetlink v0.93: registering with nfnetlink.
[   31.003844] ctnetlink v0.93: registering with nfnetlink.
[   31.005017] IPVS: Registered protocols (TCP, UDP, SCTP)
[   31.005017] IPVS: Registered protocols (TCP, UDP, SCTP)
[   31.005765] IPVS: Connection hash table configured (size=3D4096, memor=
y=3D32Kbytes)
[   31.005765] IPVS: Connection hash table configured (size=3D4096, memor=
y=3D32Kbytes)
[   31.006715] IPVS: Each connection entry needs 264 bytes at least
[   31.006715] IPVS: Each connection entry needs 264 bytes at least
[   31.007532] IPVS: Creating netns size=3D1556 id=3D0
[   31.007532] IPVS: Creating netns size=3D1556 id=3D0
[   31.008141] IPVS: ipvs loaded.
[   31.008141] IPVS: ipvs loaded.
[   31.008545] IPVS: [wrr] scheduler registered.
[   31.008545] IPVS: [wrr] scheduler registered.
[   31.009103] IPVS: [lc] scheduler registered.
[   31.009103] IPVS: [lc] scheduler registered.
[   31.009644] IPVS: [wlc] scheduler registered.
[   31.009644] IPVS: [wlc] scheduler registered.
[   31.010241] IPVS: [lblcr] scheduler registered.
[   31.010241] IPVS: [lblcr] scheduler registered.
[   31.010902] IPVS: [dh] scheduler registered.
[   31.010902] IPVS: [dh] scheduler registered.
[   31.011554] IPVS: [sh] scheduler registered.
[   31.011554] IPVS: [sh] scheduler registered.
[   31.012192] IPVS: [sed] scheduler registered.
[   31.012192] IPVS: [sed] scheduler registered.
[   31.012853] IPVS: [sip] pe registered.
[   31.012853] IPVS: [sip] pe registered.
[   31.013441] ipip: IPv4 over IPv4 tunneling driver
[   31.013441] ipip: IPv4 over IPv4 tunneling driver
[   31.014508] gre: GRE over IPv4 demultiplexor driver
[   31.014508] gre: GRE over IPv4 demultiplexor driver
[   31.015306] ip_gre: GRE over IPv4 tunneling driver
[   31.015306] ip_gre: GRE over IPv4 tunneling driver
[   31.016595] ip_tables: (C) 2000-2006 Netfilter Core Team
[   31.016595] ip_tables: (C) 2000-2006 Netfilter Core Team
[   31.017431] arp_tables: (C) 2002 David S. Miller
[   31.017431] arp_tables: (C) 2002 David S. Miller
[   31.018174] TCP: bic registered
[   31.018174] TCP: bic registered
[   31.018629] TCP: highspeed registered
[   31.018629] TCP: highspeed registered
[   31.019178] TCP: hybla registered
[   31.019178] TCP: hybla registered
[   31.019600] TCP: htcp registered
[   31.019600] TCP: htcp registered
[   31.020122] TCP: vegas registered
[   31.020122] TCP: vegas registered
[   31.020570] TCP: veno registered
[   31.020570] TCP: veno registered
[   31.021052] TCP: lp registered
[   31.021052] TCP: lp registered
[   31.021444] TCP: yeah registered
[   31.021444] TCP: yeah registered
[   31.021900] TCP: illinois registered
[   31.021900] TCP: illinois registered
[   31.022397] Initializing XFRM netlink socket
[   31.022397] Initializing XFRM netlink socket
[   31.023037] NET: Registered protocol family 17
[   31.023037] NET: Registered protocol family 17
[   31.023697] Ebtables v2.0 registered
[   31.023697] Ebtables v2.0 registered
[   31.060099] NET: Registered protocol family 9
[   31.060099] NET: Registered protocol family 9
[   31.060739] X25: Linux Version 0.2
[   31.060739] X25: Linux Version 0.2
[   31.062121] NET: Registered protocol family 6
[   31.062121] NET: Registered protocol family 6
[   31.064913] NET: Registered protocol family 11
[   31.064913] NET: Registered protocol family 11
[   31.065542] NET: Registered protocol family 3
[   31.065542] NET: Registered protocol family 3
[   31.066136] can: controller area network core (rev 20120528 abi 9)
[   31.066136] can: controller area network core (rev 20120528 abi 9)
[   31.067008] NET: Registered protocol family 29
[   31.067008] NET: Registered protocol family 29
[   31.067601] can: raw protocol (rev 20120528)
[   31.067601] can: raw protocol (rev 20120528)
[   31.068192] can: broadcast manager protocol (rev 20120528 t)
[   31.068192] can: broadcast manager protocol (rev 20120528 t)
[   31.069325] Bluetooth: RFCOMM socket layer initialized
[   31.069325] Bluetooth: RFCOMM socket layer initialized
[   31.070108] Bluetooth: RFCOMM ver 1.11
[   31.070108] Bluetooth: RFCOMM ver 1.11
[   31.070625] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   31.070625] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   31.071312] Bluetooth: BNEP socket layer initialized
[   31.071312] Bluetooth: BNEP socket layer initialized
[   31.071946] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   31.071946] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   31.072713] Bluetooth: HIDP socket layer initialized
[   31.072713] Bluetooth: HIDP socket layer initialized
[   31.073425] NET: Registered protocol family 33
[   31.073425] NET: Registered protocol family 33
[   31.074025] Key type rxrpc registered
[   31.074025] Key type rxrpc registered
[   31.074490] Key type rxrpc_s registered
[   31.074490] Key type rxrpc_s registered
[   31.075019] lec:lane_module_init: lec.c: initialized
[   31.075019] lec:lane_module_init: lec.c: initialized
[   31.075725] l2tp_core: L2TP core driver, V2.0
[   31.075725] l2tp_core: L2TP core driver, V2.0
[   31.076292] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   31.076292] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   31.076909] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   31.076909] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   31.077676] l2tp_netlink: L2TP netlink interface
[   31.077676] l2tp_netlink: L2TP netlink interface
[   31.078325] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   31.078325] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   31.079097] l2tp_debugfs: L2TP debugfs support
[   31.079097] l2tp_debugfs: L2TP debugfs support
[   31.080127] DCCP: Activated CCID 2 (TCP-like)
[   31.080127] DCCP: Activated CCID 2 (TCP-like)
[   31.080796] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   31.080796] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   31.081929] sctp: Hash tables configured (established 3276 bind 3640)
[   31.081929] sctp: Hash tables configured (established 3276 bind 3640)
[   31.082887] lib80211: common routines for IEEE802.11 drivers
[   31.082887] lib80211: common routines for IEEE802.11 drivers
[   31.083637] lib80211_crypt: registered algorithm 'NULL'
[   31.083637] lib80211_crypt: registered algorithm 'NULL'
[   31.084310] lib80211_crypt: registered algorithm 'WEP'
[   31.084310] lib80211_crypt: registered algorithm 'WEP'
[   31.084964] lib80211_crypt: registered algorithm 'CCMP'
[   31.084964] lib80211_crypt: registered algorithm 'CCMP'
[   31.085629] lib80211_crypt: registered algorithm 'TKIP'
[   31.085629] lib80211_crypt: registered algorithm 'TKIP'
[   31.086296] tipc: Activated (version 2.0.0)
[   31.086296] tipc: Activated (version 2.0.0)
[   31.087026] NET: Registered protocol family 30
[   31.087026] NET: Registered protocol family 30
[   31.087793] tipc: Started in single node mode
[   31.087793] tipc: Started in single node mode
[   31.088389] 9pnet: Installing 9P2000 support
[   31.088389] 9pnet: Installing 9P2000 support
[   31.088997] Key type dns_resolver registered
[   31.088997] Key type dns_resolver registered
[   31.089564] Key type ceph registered
[   31.089564] Key type ceph registered
[   31.090120] libceph: loaded (mon/osd proto 15/24)
[   31.090120] libceph: loaded (mon/osd proto 15/24)
[   31.090854] ------------[ cut here ]------------
[   31.090854] ------------[ cut here ]------------
[   31.091497] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:=
92 batadv_is_on_batman_iface+0x62/0x70()
[   31.091497] WARNING: CPU: 1 PID: 1 at net/batman-adv/hard-interface.c:=
92 batadv_is_on_batman_iface+0x62/0x70()
[   31.092998] Cannot find parent device
[   31.092998] Cannot find parent device

[   31.093447] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc4-00068=
-g78ff4be #2
[   31.093447] CPU: 1 PID: 1 Comm: swapper/0 Not tainted 3.15.0-rc4-00068=
-g78ff4be #2
[   31.094439]  00000000
[   31.094439]  00000000 00000000 00000000 8a04fe2c 8a04fe2c 7a270080 7a2=
70080 8a04fe6c 8a04fe6c 8a04fe5c 8a04fe5c 79045a0f 79045a0f 7aa96552 7aa9=
6552

[   31.095507]  8a04fe88
[   31.095507]  8a04fe88 00000001 00000001 7aab2b78 7aab2b78 0000005c 000=
0005c 7a23c9a2 7a23c9a2 7a23c9a2 7a23c9a2 00000000 00000000 8aeef000 8aee=
f000

[   31.096563]  00000005
[   31.096563]  00000005 8a04fe74 8a04fe74 79045a8e 79045a8e 00000009 000=
00009 8a04fe6c 8a04fe6c 7aa96552 7aa96552 8a04fe88 8a04fe88 8a04fe90 8a04=
fe90

[   31.097620] Call Trace:
[   31.097620] Call Trace:
[   31.097946]  [<7a270080>] dump_stack+0x48/0x60
[   31.097946]  [<7a270080>] dump_stack+0x48/0x60
[   31.098521]  [<79045a0f>] warn_slowpath_common+0x6f/0x90
[   31.098521]  [<79045a0f>] warn_slowpath_common+0x6f/0x90
[   31.099201]  [<7a23c9a2>] ? batadv_is_on_batman_iface+0x62/0x70
[   31.099201]  [<7a23c9a2>] ? batadv_is_on_batman_iface+0x62/0x70
[   31.099959]  [<7a23c9a2>] ? batadv_is_on_batman_iface+0x62/0x70
[   31.099959]  [<7a23c9a2>] ? batadv_is_on_batman_iface+0x62/0x70
[   31.100767]  [<79045a8e>] warn_slowpath_fmt+0x2e/0x30
[   31.100767]  [<79045a8e>] warn_slowpath_fmt+0x2e/0x30
[   31.101452]  [<7a23c9a2>] batadv_is_on_batman_iface+0x62/0x70
[   31.101452]  [<7a23c9a2>] batadv_is_on_batman_iface+0x62/0x70
[   31.102181]  [<7a23d609>] batadv_hard_if_event+0xd9/0x430
[   31.102181]  [<7a23d609>] batadv_hard_if_event+0xd9/0x430
[   31.102878]  [<7acca2c1>] ? batadv_iv_init+0x32/0x32
[   31.102878]  [<7acca2c1>] ? batadv_iv_init+0x32/0x32
[   31.103521]  [<7a00cb07>] register_netdevice_notifier+0x77/0x190
[   31.103521]  [<7a00cb07>] register_netdevice_notifier+0x77/0x190
[   31.104288]  [<7acca2c1>] ? batadv_iv_init+0x32/0x32
[   31.104288]  [<7acca2c1>] ? batadv_iv_init+0x32/0x32
[   31.104929]  [<7acca3af>] batadv_init+0xee/0x118
[   31.104929]  [<7acca3af>] batadv_init+0xee/0x118
[   31.105524]  [<7ac77b4a>] do_one_initcall+0x8d/0x127
[   31.105524]  [<7ac77b4a>] do_one_initcall+0x8d/0x127
[   31.106163]  [<7905e443>] ? parameq+0x13/0x70
[   31.106163]  [<7905e443>] ? parameq+0x13/0x70
[   31.106728]  [<7905e5a8>] ? parse_args+0x108/0x320
[   31.106728]  [<7905e5a8>] ? parse_args+0x108/0x320
[   31.107338]  [<7905780e>] ? __usermodehelper_set_disable_depth+0x3e/0x=
50
[   31.107338]  [<7905780e>] ? __usermodehelper_set_disable_depth+0x3e/0x=
50
[   31.108197]  [<7ac77cd4>] kernel_init_freeable+0xf0/0x187
[   31.108197]  [<7ac77cd4>] kernel_init_freeable+0xf0/0x187
[   31.108895]  [<7ac774fb>] ? do_early_param+0x78/0x78
[   31.108895]  [<7ac774fb>] ? do_early_param+0x78/0x78
[   31.109527]  [<7a2664eb>] kernel_init+0xb/0xd0
[   31.109527]  [<7a2664eb>] kernel_init+0xb/0xd0
[   31.110135]  [<7a286d21>] ret_from_kernel_thread+0x21/0x30
[   31.110135]  [<7a286d21>] ret_from_kernel_thread+0x21/0x30
[   31.110864]  [<7a2664e0>] ? rest_init+0xc0/0xc0
[   31.110864]  [<7a2664e0>] ? rest_init+0xc0/0xc0
[   31.111443] ---[ end trace 37329f305415ddb8 ]---
[   31.111443] ---[ end trace 37329f305415ddb8 ]---
[   31.112093] batman_adv: B.A.T.M.A.N. advanced 2014.2.0 (compatibility =
version 15) loaded
[   31.112093] batman_adv: B.A.T.M.A.N. advanced 2014.2.0 (compatibility =
version 15) loaded
[   31.113121] openvswitch: Open vSwitch switching datapath
[   31.113121] openvswitch: Open vSwitch switching datapath
[   31.113925] mpls_gso: MPLS GSO support
[   31.113925] mpls_gso: MPLS GSO support
[   31.115388]=20
[   31.115388] printing PIC contents
[   31.115388]=20
[   31.115388] printing PIC contents
[   31.116021] ... PIC  IMR: ffff
[   31.116021] ... PIC  IMR: ffff
[   31.116414] ... PIC  IRR: 1153
[   31.116414] ... PIC  IRR: 1153
[   31.116818] ... PIC  ISR: 0000
[   31.116818] ... PIC  ISR: 0000
[   31.117212] ... PIC ELCR: 0c00
[   31.117212] ... PIC ELCR: 0c00
[   31.117649] printing local APIC contents on CPU#0/0:
[   31.117649] printing local APIC contents on CPU#0/0:
[   31.118333] ... APIC ID:      00000000 (0)
[   31.118333] ... APIC ID:      00000000 (0)
[   31.118878] ... APIC VERSION: 00050014
[   31.118878] ... APIC VERSION: 00050014
[   31.119372] ... APIC TASKPRI: 00000000 (00)
[   31.119372] ... APIC TASKPRI: 00000000 (00)
[   31.119928] ... APIC PROCPRI: 00000000
[   31.119928] ... APIC PROCPRI: 00000000
[   31.120425] ... APIC LDR: 01000000
[   31.120425] ... APIC LDR: 01000000
[   31.120872] ... APIC DFR: ffffffff
[   31.120872] ... APIC DFR: ffffffff
[   31.121318] ... APIC SPIV: 000001ff
[   31.121318] ... APIC SPIV: 000001ff
[   31.121778] ... APIC ISR field:
[   31.121778] ... APIC ISR field:
[   31.122189] 00000000
[   31.122189] 0000000000000000000000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000000000000000000000

[   31.123186] ... APIC TMR field:
[   31.123186] ... APIC TMR field:
[   31.123595] 00000000
[   31.123595] 0000000002000000020000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000000000000000000000

[   31.124620] ... APIC IRR field:
[   31.124620] ... APIC IRR field:
[   31.125052] 00000000
[   31.125052] 0000000000000000000000000000000000000000000000000000000000=
00000000000000000000000000000000000000000000002000800020008000

[   31.126053] ... APIC ESR: 00000000
[   31.126053] ... APIC ESR: 00000000
[   31.126499] ... APIC ICR: 000408f6
[   31.126499] ... APIC ICR: 000408f6
[   31.126947] ... APIC ICR2: 02000000
[   31.126947] ... APIC ICR2: 02000000
[   31.127402] ... APIC LVTT: 000000ef
[   31.127402] ... APIC LVTT: 000000ef
[   31.127646] ... APIC LVTPC: 00010000
[   31.127646] ... APIC LVTPC: 00010000
[   31.127646] ... APIC LVT0: 00010700
[   31.127646] ... APIC LVT0: 00010700
[   31.127646] ... APIC LVT1: 00000400
[   31.127646] ... APIC LVT1: 00000400
[   31.127646] ... APIC LVTERR: 000000fe
[   31.127646] ... APIC LVTERR: 000000fe
[   31.127646] ... APIC TMICT: 0005d6cc
[   31.127646] ... APIC TMICT: 0005d6cc
[   31.127646] ... APIC TMCCT: 00000000
[   31.127646] ... APIC TMCCT: 00000000
[   31.127646] ... APIC TDCR: 00000003
[   31.127646] ... APIC TDCR: 00000003
[   31.127646]=20
[   31.127646]=20
[   31.131322] number of MP IRQ sources: 15.
[   31.131322] number of MP IRQ sources: 15.
[   31.131872] number of IO-APIC #0 registers: 24.
[   31.131872] number of IO-APIC #0 registers: 24.
[   31.132446] testing the IO APIC.......................
[   31.132446] testing the IO APIC.......................
[   31.133124] IO APIC #0......
[   31.133124] IO APIC #0......
[   31.133493] .... register #00: 00000000
[   31.133493] .... register #00: 00000000
[   31.133983] .......    : physical APIC id: 00
[   31.133983] .......    : physical APIC id: 00
[   31.134532] .......    : Delivery Type: 0
[   31.134532] .......    : Delivery Type: 0
[   31.135043] .......    : LTS          : 0
[   31.135043] .......    : LTS          : 0
[   31.135550] .... register #01: 00170011
[   31.135550] .... register #01: 00170011
[   31.136041] .......     : max redirection entries: 17
[   31.136041] .......     : max redirection entries: 17
[   31.136685] .......     : PRQ implemented: 0
[   31.136685] .......     : PRQ implemented: 0
[   31.137231] .......     : IO APIC version: 11
[   31.137231] .......     : IO APIC version: 11
[   31.137791] .... register #02: 00000000
[   31.137791] .... register #02: 00000000
[   31.138275] .......     : arbitration: 00
[   31.138275] .......     : arbitration: 00
[   31.138790] .... IRQ redirection table:
[   31.138790] .... IRQ redirection table:
[   31.139283] 1    0    0   0   0    0    0    00
[   31.139283] 1    0    0   0   0    0    0    00
[   31.139884] 0    0    0   0   0    1    1    31
[   31.139884] 0    0    0   0   0    1    1    31
[   31.140529] 0    0    0   0   0    1    1    30
[   31.140529] 0    0    0   0   0    1    1    30
[   31.141140] 0    0    0   0   0    1    1    33
[   31.141140] 0    0    0   0   0    1    1    33
[   31.141730] 1    0    0   0   0    1    1    34
[   31.141730] 1    0    0   0   0    1    1    34
[   31.142314] 1    1    0   0   0    1    1    35
[   31.142314] 1    1    0   0   0    1    1    35
[   31.142911] 0    0    0   0   0    1    1    36
[   31.142911] 0    0    0   0   0    1    1    36
[   31.143492] 0    0    0   0   0    1    1    37
[   31.143492] 0    0    0   0   0    1    1    37
[   31.144077] 0    0    0   0   0    1    1    38
[   31.144077] 0    0    0   0   0    1    1    38
[   31.144663] 0    1    0   0   0    1    1    39
[   31.144663] 0    1    0   0   0    1    1    39
[   31.145250] 1    1    0   0   0    1    1    3A
[   31.145250] 1    1    0   0   0    1    1    3A
[   31.145837] 1    1    0   0   0    1    1    3B
[   31.145837] 1    1    0   0   0    1    1    3B
[   31.146423] 0    0    0   0   0    1    1    3C
[   31.146423] 0    0    0   0   0    1    1    3C
[   31.147011] 0    0    0   0   0    1    1    3D
[   31.147011] 0    0    0   0   0    1    1    3D
[   31.147596] 0    0    0   0   0    1    1    3E
[   31.147596] 0    0    0   0   0    1    1    3E
[   31.148179] 0    0    0   0   0    1    1    3F
[   31.148179] 0    0    0   0   0    1    1    3F
[   31.148765] 1    0    0   0   0    0    0    00
[   31.148765] 1    0    0   0   0    0    0    00
[   31.149345] 1    0    0   0   0    0    0    00
[   31.149345] 1    0    0   0   0    0    0    00
[   31.149930] 1    0    0   0   0    0    0    00
[   31.149930] 1    0    0   0   0    0    0    00
[   31.150574] 1    0    0   0   0    0    0    00
[   31.150574] 1    0    0   0   0    0    0    00
[   31.151186] 1    0    0   0   0    0    0    00
[   31.151186] 1    0    0   0   0    0    0    00
[   31.151772] 1    0    0   0   0    0    0    00
[   31.151772] 1    0    0   0   0    0    0    00
[   31.152353] 1    0    0   0   0    0    0    00
[   31.152353] 1    0    0   0   0    0    0    00
[   31.152948] 1    0    0   0   0    0    0    00
[   31.152948] 1    0    0   0   0    0    0    00
[   31.153524] IRQ to pin mappings:
[   31.153524] IRQ to pin mappings:
[   31.153950] IRQ0=20
[   31.153950] IRQ0 -> 0:2-> 0:2

[   31.154283] IRQ1=20
[   31.154283] IRQ1 -> 0:1-> 0:1

[   31.154616] IRQ3=20
[   31.154616] IRQ3 -> 0:3-> 0:3

[   31.154966] IRQ4=20
[   31.154966] IRQ4 -> 0:4-> 0:4

[   31.155299] IRQ5=20
[   31.155299] IRQ5 -> 0:5-> 0:5

[   31.155633] IRQ6=20
[   31.155633] IRQ6 -> 0:6-> 0:6

[   31.155971] IRQ7=20
[   31.155971] IRQ7 -> 0:7-> 0:7

[   31.156303] IRQ8=20
[   31.156303] IRQ8 -> 0:8-> 0:8

[   31.156637] IRQ9=20
[   31.156637] IRQ9 -> 0:9-> 0:9

[   31.156976] IRQ10=20
[   31.156976] IRQ10 -> 0:10-> 0:10

[   31.157334] IRQ11=20
[   31.157334] IRQ11 -> 0:11-> 0:11

[   31.157692] IRQ12=20
[   31.157692] IRQ12 -> 0:12-> 0:12

[   31.158057] IRQ13=20
[   31.158057] IRQ13 -> 0:13-> 0:13

[   31.158411] IRQ14=20
[   31.158411] IRQ14 -> 0:14-> 0:14

[   31.158781] IRQ15=20
[   31.158781] IRQ15 -> 0:15-> 0:15

[   31.159133] .................................... done.
[   31.159133] .................................... done.
[   31.159788] Using IPI No-Shortcut mode
[   31.159788] Using IPI No-Shortcut mode
[   31.160408] bootconsole [earlyser0] disabled
[   31.160408] bootconsole [earlyser0] disabled
[   31.161005] Loading compiled-in X.509 certificates
[   31.161332] kAFS: Red Hat AFS client v0.1 registering.
[   31.162500] Btrfs loaded, debug=3Don, assert=3Don, integrity-checker=3D=
on
[   31.163243] Key type encrypted registered
[   31.163827] RIO: rio_register_scan for mport_id=3D-1
[   31.164315] hd: no drives specified - use hd=3Dcyl,head,sectors on ker=
nel command line
[   31.164977] saa7134 ALSA driver for DMA sound loaded
[   31.165322] saa7134 ALSA: no saa7134 cards found
[   31.165762] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   31.166178] EDD information not available.
[   31.166552] ALSA device list:
[   31.166769]   No soundcards found.
[   31.167742] Freeing unused kernel memory: 568K (7ac77000 - 7ad05000)
[   31.173283] random: init urandom read with 0 bits of entropy available=

udevd[3540]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
LNXSYSTM:': No such file or directory
udevd[3547]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv input=
:b0019v0000p0001e0000-e0,1,k74,ramlsfw': No such file or directory
udevd[3551]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00008086d00001237sv00001AF4sd00001100bc06sc00i00': No such file or direct=
ory
udevd[3580]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:dell_rbu': No such file or directory
udevd[3583]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00008086d0000100Esv00001AF4sd00001100bc02sc00i00': No such file or direct=
ory
udevd[3549]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
LNXSYBUS:': No such file or directory
udevd[3575]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00008086d00007010sv00001AF4sd00001100bc01sc01i80': No such file or direct=
ory
udevd[3576]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00008086d000025ABsv00001AF4sd00001100bc08sc80i00': No such file or direct=
ory
udevd[3577]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:Fixed MDIO bus': No such file or directory
udevd[3581]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:goldfish_pdev_bus': No such file or directory
udevd[3584]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv serio=
:ty01pr00id00ex00': No such file or directory
udevd[3578]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00001013d000000B8sv00001AF4sd00001100bc03sc00i00': No such file or direct=
ory
udevd[3582]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:uvesafb': No such file or directory
udevd[3587]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:i5k_amb': No such file or directory
udevd[3588]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv pci:v=
00008086d00007000sv00001AF4sd00001100bc06sc01i00': No such file or direct=
ory
udevd[3589]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv input=
:b0011v0001p0001eAB41-e0,1,4,11,14,k71,72,73,74,75,76,77,79,7A,7B,7C,7D,7=
E,7F,80,8C,8E,8F,9B,9C,9D,9E,9F,A3,A4,A5,A6,AC,AD,B7,B8,B9,D9,E2,ram4,l0,=
1,2,sfw': No such file or directory
udevd[3592]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
LNXSYBUS:': No such file or directory
udevd[3585]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:regulatory': No such file or directory
udevd[3586]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:microcode': No such file or directory
udevd[3591]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv platf=
orm:platform-framebuffer': No such file or directory
udevd[3598]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0C0F:': No such file or directory
udevd[3600]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0C0F:': No such file or directory
udevd[3601]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0C0F:': No such file or directory
udevd[3597]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0A03:': No such file or directory
udevd[3596]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0C0F:': No such file or directory
udevd[3594]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0103:': No such file or directory
udevd[3599]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0C0F:': No such file or directory
udevd[3593]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
LNXCPU:': No such file or directory
udevd[3595]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
LNXCPU:': No such file or directory
udevd[3605]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0303:': No such file or directory
udevd[3607]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0501:': No such file or directory
udevd[3608]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0B00:': No such file or directory
udevd[3610]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0501:': No such file or directory
udevd[3611]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0700:': No such file or directory
udevd[3606]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0400:': No such file or directory
udevd[3609]: failed to execute '/sbin/modprobe' '/sbin/modprobe -bv acpi:=
PNP0F13:': No such file or directory
[   34.311322] init: Failed to create pty - disabling logging for job
[   34.346041] init: Failed to create pty - disabling logging for job
[   34.606783] init: Failed to create pty - disabling logging for job
[   34.610972] init: Failed to create pty - disabling logging for job
[   34.612387] init: Failed to create pty - disabling logging for job
[   34.632175] init: Failed to create pty - disabling logging for job
[   34.636449] init: Failed to create pty - disabling logging for job
[   34.642546] init: Failed to create pty - disabling logging for job
[   62.080116] spin_lock-torture: Writes:  Total: 4  Max/Min: 0/0   Fail:=
 0=20
[   91.194221] init: Failed to create pty - disabling logging for job
umount: /run/lock: not mounted
 * Will now restart
[   91.448758] spin_lock-torture: Unscheduled system shutdown detected
[   91.450028] reboot: Restarting system
Elapsed time: 95
qemu-system-x86_64 -cpu kvm64 -enable-kvm -kernel /kernel/i386-randconfig=
-c0-05211630/78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb/vmlinuz-3.15.0-rc4-=
00068-g78ff4be -append 'hung_task_panic=3D1 earlyprintk=3DttyS0,115200 de=
bug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_timeout=3D10=
0 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic  prompt_ramdisk=3D=
0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal  root=3D/dev/ram0 rw=
 link=3D/kbuild-tests/run-queue/kvm/i386-randconfig-c0-05211630/linux-dev=
el:devel-hourly-2014052115:78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb:bisec=
t-linux8/.vmlinuz-78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb-20140522085039=
-14-ivb42 branch=3Dlinux-devel/devel-hourly-2014052115 BOOT_IMAGE=3D/kern=
el/i386-randconfig-c0-05211630/78ff4be45a4c51d8fb21ad92e4fabb467c6c3eeb/v=
mlinuz-3.15.0-rc4-00068-g78ff4be drbd.minor_count=3D8'  -initrd /kernel-t=
ests/initrd/quantal-core-i386.cgz -m 320 -smp 2 -net nic,vlan=3D1,model=3D=
e1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i6300esb -=
rtc base=3Dlocaltime -pidfile /dev/shm/kboot/pid-quantal-ivb42-112 -seria=
l file:/dev/shm/kboot/serial-quantal-ivb42-112 -daemonize -display none -=
monitor null=20


--------------090000010208030005040009
Content-Type: application/octet-stream;
 name="i386-randconfig-c0-05211630-842390939e8dc18fe8a87e257e7e8088548bd8d7-WARNING:---at----batadv_is_on_batman_iface+-x-129926.log"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename*0="i386-randconfig-c0-05211630-842390939e8dc18fe8a87e257e7e8088";
 filename*1="548bd8d7-WARNING:---at----batadv_is_on_batman_iface+-x-12992";
 filename*2="6.log"

SEVBRCBpcyBub3cgYXQgODQyMzkwOS4uLiAwZGF5IGhlYWQgZ3VhcmQgZm9yICdkZXZlbC1o
b3VybHktMjAxNDA1MjExNScKZ2l0IGNoZWNrb3V0IGQ2ZDIxMWRiMzdlNzVkZTJkZGMzYTRm
OTc5MDM4YzQwZGY3Y2M3OWMKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kz
ODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1kZXZlbDpkZXZlbC1ob3VybHktMjAx
NDA1MjExNTpkNmQyMTFkYjM3ZTc1ZGUyZGRjM2E0Zjk3OTAzOGM0MGRmN2NjNzljOmJpc2Vj
dC1saW51eDgKCjIwMTQtMDUtMjEtMTc6MjA6MDMgZDZkMjExZGIzN2U3NWRlMmRkYzNhNGY5
NzkwMzhjNDBkZjdjYzc5YyBjb21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWls
ZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtZDZkMjEx
ZGIzN2U3NWRlMmRkYzNhNGY5NzkwMzhjNDBkZjdjYzc5YwpDaGVjayBmb3Iga2VybmVsIGlu
IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwL2Q2ZDIxMWRiMzdlNzVkZTJk
ZGMzYTRmOTc5MDM4YzQwZGY3Y2M3OWMKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1kNmQy
MTFkYjM3ZTc1ZGUyZGRjM2E0Zjk3OTAzOGM0MGRmN2NjNzljCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29uZmlnLWMw
LTA1MjExNjMwLWQ2ZDIxMWRiMzdlNzVkZTJkZGMzYTRmOTc5MDM4YzQwZGY3Y2M3OWMKa2Vy
bmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9kNmQyMTFkYjM3ZTc1
ZGUyZGRjM2E0Zjk3OTAzOGM0MGRmN2NjNzljL3ZtbGludXotMy4xNS4wLXJjNQoKMjAxNC0w
NS0yMS0xNzo1MDowMyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMTgJMjAgU1VDQ0VTUwoK
YmlzZWN0OiBnb29kIGNvbW1pdCBkNmQyMTFkYjM3ZTc1ZGUyZGRjM2E0Zjk3OTAzOGM0MGRm
N2NjNzljCmdpdCBiaXNlY3Qgc3RhcnQgODQyMzkwOTM5ZThkYzE4ZmU4YTg3ZTI1N2U3ZTgw
ODg1NDhiZDhkNyBkNmQyMTFkYjM3ZTc1ZGUyZGRjM2E0Zjk3OTAzOGM0MGRmN2NjNzljIC0t
Ci9jL2tlcm5lbC10ZXN0cy9saW5lYXItYmlzZWN0OiBbIi1iIiwgIjg0MjM5MDkzOWU4ZGMx
OGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4ZDciLCAiLWciLCAiZDZkMjExZGIzN2U3NWRlMmRk
YzNhNGY5NzkwMzhjNDBkZjdjYzc5YyIsICIvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIiwgIi9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QiXQpC
aXNlY3Rpbmc6IDMwMTMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3Vn
aGx5IDEyIHN0ZXBzKQpbNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0
MV0gTWVyZ2UgJ2FybS1zb2Mva2V5c3RvbmUvZHQnIGludG8gZGV2ZWwtaG91cmx5LTIwMTQw
NTIxMTUKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1kZXZl
bDpkZXZlbC1ob3VybHktMjAxNDA1MjExNTo2ZThhMmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRj
NmU5NjRmYTYyMDQxOmJpc2VjdC1saW51eDgKCjIwMTQtMDUtMjEtMTc6NTI6MzUgNmU4YTJl
ODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MSBjb21waWxpbmcKUXVldWVkIGJ1
aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAtNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MQpD
aGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMw
LzZlOGEyZTg5YTQ2ZTk5ZTc3NTBkODUxMWI5NGM2ZTk2NGZhNjIwNDEKd2FpdGluZyBmb3Ig
Y29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZp
Zy1jMC0wNTIxMTYzMC02ZThhMmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQx
CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8u
aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTZlOGEyZTg5YTQ2ZTk5ZTc3NTBkODUxMWI5
NGM2ZTk2NGZhNjIwNDEKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMC82ZThhMmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL3ZtbGludXot
My4xNS4wLXJjNS0wMTc2Mi1nNmU4YTJlOAoKMjAxNC0wNS0yMS0xODoyNzozNSBkZXRlY3Rp
bmcgYm9vdCBzdGF0ZSAuLi4uIFRFU1QgRkFJTFVSRQpbICAgMzEuNTc1ODkzXSBsaWJjZXBo
OiBsb2FkZWQgKG1vbi9vc2QgcHJvdG8gMTUvMjQpClsgICAzMS41NzY3MTZdIC0tLS0tLS0t
LS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgMzEuNTc2NzE2XSAtLS0tLS0tLS0t
LS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgIDMxLjU3NzQ5NV0gV0FSTklORzogQ1BV
OiAxIFBJRDogMSBhdCAva2J1aWxkL3NyYy9jb25zdW1lci9uZXQvYmF0bWFuLWFkdi9oYXJk
LWludGVyZmFjZS5jOjkyIGJhdGFkdl9pc19vbl9iYXRtYW5faWZhY2UrMHg2Mi8weDcwKCkK
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1
MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy1xdWFudGFsLWYyLTc5OjIwMTQwNTIxMTgy
NzUzOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThh
MmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZl
OTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy1xdWFudGFsLWYzLTU5OjIwMTQw
NTIxMTgyNzMyOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYy
LWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJl
ODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy1xdWFudGFsLWYzLTg6
MjAxNDA1MjExODI3MzA6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzUt
MDE3NjItZzZlOGEyZTg6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC82
ZThhMmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL2RtZXNnLXF1YW50YWwt
ZjQtNTc6MjAxNDA1MjExODI3NDg6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUu
MC1yYzUtMDE3NjItZzZlOGEyZTg6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMC82ZThhMmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL2RtZXNnLXF1
YW50YWwtZjEtMTI4OjIwMTQwNTIxMTgyNzU0OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYz
MDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9k
bWVzZy1xdWFudGFsLWYxLTYzOjIwMTQwNTIxMTgyNzUzOmkzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2
MjA0MS9kbWVzZy1xdWFudGFsLWYxLTc1OjIwMTQwNTIxMTgyNzUxOmkzODYtcmFuZGNvbmZp
Zy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZl
OTY0ZmE2MjA0MS9kbWVzZy1xdWFudGFsLWYxLTc2OjIwMTQwNTIxMTgyNzUzOmkzODYtcmFu
ZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTEx
Yjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy1xdWFudGFsLWYyLTExNToyMDE0MDUyMTE4MjgwMzpp
Mzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS0wMTc2Mi1nNmU4YTJlODoy
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzZlOGEyZTg5YTQ2ZTk5ZTc3
NTBkODUxMWI5NGM2ZTk2NGZhNjIwNDEvZG1lc2ctcXVhbnRhbC1mMi0xMjg6MjAxNDA1MjEx
ODI4MDY6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzUtMDE3NjItZzZl
OGEyZTg6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC82ZThhMmU4OWE0
NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL2RtZXNnLXF1YW50YWwtZjItNDM6MjAx
NDA1MjExODI4MDQ6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzUtMDE3
NjItZzZlOGEyZTg6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC82ZThh
MmU4OWE0NmU5OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL2RtZXNnLXF1YW50YWwtZjMt
MTA5OjIwMTQwNTIxMTgyNzQ5OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAt
cmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2
MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy1xdWFu
dGFsLWYzLTcyOjIwMTQwNTIxMTgyNzQzOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDoz
LjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVz
Zy1xdWFudGFsLWYzLTg1OjIwMTQwNTIxMTgyNzQxOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4NTExYjk0YzZlOTY0ZmE2MjA0
MS9kbWVzZy1xdWFudGFsLWY0LTEyMjoyMDE0MDUyMTE4Mjc1ODppMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzA6My4xNS4wLXJjNS0wMTc2Mi1nNmU4YTJlODoyCi9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWMwLTA1MjExNjMwLzZlOGEyZTg5YTQ2ZTk5ZTc3NTBkODUxMWI5NGM2ZTk2
NGZhNjIwNDEvZG1lc2ctcXVhbnRhbC1mNC00OToyMDE0MDUyMTE4Mjc1MjppMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS0wMTc2Mi1nNmU4YTJlODoyCi9rZXJuZWwv
aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzZlOGEyZTg5YTQ2ZTk5ZTc3NTBkODUxMWI5
NGM2ZTk2NGZhNjIwNDEvZG1lc2cteW9jdG8tZjEtMTE4OjIwMTQwNTIxMTgyODA4OmkzODYt
cmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2ZThhMmU4OjIKL2tl
cm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNmU4YTJlODlhNDZlOTllNzc1MGQ4
NTExYjk0YzZlOTY0ZmE2MjA0MS9kbWVzZy15b2N0by1mMy02OToyMDE0MDUyMTE4MjgwMDpp
Mzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS0wMTc2Mi1nNmU4YTJlODoy
Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzZlOGEyZTg5YTQ2ZTk5ZTc3
NTBkODUxMWI5NGM2ZTk2NGZhNjIwNDEvZG1lc2cteW9jdG8tZjQtMjc6MjAxNDA1MjExODI4
MTA6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzUtMDE3NjItZzZlOGEy
ZTg6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC82ZThhMmU4OWE0NmU5
OWU3NzUwZDg1MTFiOTRjNmU5NjRmYTYyMDQxL2RtZXNnLXlvY3RvLWY0LTg2OjIwMTQwNTIx
MTgyODA1OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LTAxNzYyLWc2
ZThhMmU4OjIKMDoyMDoyMCBhbGxfZ29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAx
NC0wNS0yMSAxODoyOTozNiBSRVBFQVQgQ09VTlQ6IDIwICAjIC9rZXJuZWwtdGVzdHMvbGlu
dXg4L29iai1iaXNlY3QvLnJlcGVhdBtbMG0KCkJpc2VjdGluZzogMTY4OCByZXZpc2lvbnMg
bGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMTEgc3RlcHMpCls3MzJhZWQzNjMw
MGYxNDI2YzZkYTQwNjAyZmJhZjIzZGQ3OWQ4MzkxXSBNZXJnZSAndGlwL2lycS9jb3JlJyBp
bnRvIGRldmVsLWhvdXJseS0yMDE0MDUyMTE1CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jp
c2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlz
ZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6NzMyYWVk
MzYzMDBmMTQyNmM2ZGE0MDYwMmZiYWYyM2RkNzlkODM5MTpiaXNlY3QtbGludXg4CgoyMDE0
LTA1LTIxLTE4OjI5OjM2IDczMmFlZDM2MzAwZjE0MjZjNmRhNDA2MDJmYmFmMjNkZDc5ZDgz
OTEgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTczMmFlZDM2MzAwZjE0MjZjNmRh
NDA2MDJmYmFmMjNkZDc5ZDgzOTEKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYt
cmFuZGNvbmZpZy1jMC0wNTIxMTYzMC83MzJhZWQzNjMwMGYxNDI2YzZkYTQwNjAyZmJhZjIz
ZGQ3OWQ4MzkxCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWls
ZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNzMyYWVkMzYzMDBmMTQyNmM2
ZGE0MDYwMmZiYWYyM2RkNzlkODM5MQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC03MzJh
ZWQzNjMwMGYxNDI2YzZkYTQwNjAyZmJhZjIzZGQ3OWQ4MzkxCmtlcm5lbDogL2tlcm5lbC9p
Mzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNzMyYWVkMzYzMDBmMTQyNmM2ZGE0MDYwMmZi
YWYyM2RkNzlkODM5MS92bWxpbnV6LTMuMTUuMC1yYzUtMDE1ODktZzczMmFlZDMKCjIwMTQt
MDUtMjEtMTk6MTk6MzYgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uIFRFU1QgRkFJTFVSRQpb
ICAgMzEuMTM5Nzc3XSBsaWJjZXBoOiBsb2FkZWQgKG1vbi9vc2QgcHJvdG8gMTUvMjQpClsg
ICAzMS4xNDA1MjRdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAg
MzEuMTQwNTI0XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgIDMx
LjE0MTE0NF0gV0FSTklORzogQ1BVOiAwIFBJRDogMSBhdCAva2J1aWxkL3NyYy9jb25zdW1l
ci9uZXQvYmF0bWFuLWFkdi9oYXJkLWludGVyZmFjZS5jOjkyIGJhdGFkdl9pc19vbl9iYXRt
YW5faWZhY2UrMHg2Mi8weDcwKCkKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2
MzAvNzMyYWVkMzYzMDBmMTQyNmM2ZGE0MDYwMmZiYWYyM2RkNzlkODM5MS9kbWVzZy1xdWFu
dGFsLWY0LTExMjoyMDE0MDUyMTE5MTk0MDppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6
My4xNS4wLXJjNS0wMTU4OS1nNzMyYWVkMzozCjA6MToxIGFsbF9nb29kOmJhZDphbGxfYmFk
IGJvb3RzChtbMTszNW0yMDE0LTA1LTIxIDE5OjIxOjA3IFJFUEVBVCBDT1VOVDogMjAgICMg
L2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdC8ucmVwZWF0G1swbQoKQmlzZWN0aW5n
OiAxNTE1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMSBz
dGVwcykKW2ZkNjliYjJmYWViYzU1MmI0ZGE0Mjk2NmVlNTFlMWRlYTliYTc3ZTZdIE1lcmdl
ICdibG9jay9mb3ItMy4xNi9kcml2ZXJzJyBpbnRvIGRldmVsLWhvdXJseS0yMDE0MDUyMTE1
CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAv
a2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVu
LXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2
ZWwtaG91cmx5LTIwMTQwNTIxMTU6ZmQ2OWJiMmZhZWJjNTUyYjRkYTQyOTY2ZWU1MWUxZGVh
OWJhNzdlNjpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIxLTE5OjIxOjA4IGZkNjliYjJmYWVi
YzU1MmI0ZGE0Mjk2NmVlNTFlMWRlYTliYTc3ZTYgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0
YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1
MjExNjMwLWZkNjliYjJmYWViYzU1MmI0ZGE0Mjk2NmVlNTFlMWRlYTliYTc3ZTYKQ2hlY2sg
Zm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9mZDY5
YmIyZmFlYmM1NTJiNGRhNDI5NjZlZTUxZTFkZWE5YmE3N2U2CndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAtZmQ2OWJiMmZhZWJjNTUyYjRkYTQyOTY2ZWU1MWUxZGVhOWJhNzdlNgp3YWl0
aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYt
cmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1mZDY5YmIyZmFlYmM1NTJiNGRhNDI5NjZlZTUxZTFk
ZWE5YmE3N2U2Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAv
ZmQ2OWJiMmZhZWJjNTUyYjRkYTQyOTY2ZWU1MWUxZGVhOWJhNzdlNi92bWxpbnV6LTMuMTUu
MC1yYzUtMDA3OTUtZ2ZkNjliYjIKCjIwMTQtMDUtMjEtMTk6MjY6MDggZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgLi4uCTE1CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogNzIwIHJldmlzaW9ucyBs
ZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAxMCBzdGVwcykKWzkxN2E0ZDNhZWQ2
MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1YzliMjNdIE1lcmdlICduZXQvbWFzdGVyJyBpbnRv
IGRldmVsLWhvdXJseS0yMDE0MDUyMTE1CnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0
CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6OTE3YTRkM2Fl
ZDYzMDEwOTdmZjhhMmIyYmI3NGJlMzRiZTVjOWIyMzpiaXNlY3QtbGludXg4CgoyMDE0LTA1
LTIxLTE5OjI4OjM4IDkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1YzliMjMg
Y29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJi
MmJiNzRiZTM0YmU1YzliMjMKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1jMC0wNTIxMTYzMC85MTdhNGQzYWVkNjMwMTA5N2ZmOGEyYjJiYjc0YmUzNGJl
NWM5YjIzCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtOTE3YTRkM2FlZDYzMDEwOTdmZjhh
MmIyYmI3NGJlMzRiZTVjOWIyMwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC05MTdhNGQz
YWVkNjMwMTA5N2ZmOGEyYjJiYjc0YmUzNGJlNWM5YjIzCmtlcm5lbDogL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAvOTE3YTRkM2FlZDYzMDEwOTdmZjhhMmIyYmI3NGJl
MzRiZTVjOWIyMy92bWxpbnV6LTMuMTUuMC1yYzUtMDExMzEtZzkxN2E0ZDMKCjIwMTQtMDUt
MjEtMTk6Mzc6MzggZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLiBURVNUIEZBSUxVUkUKWyAg
IDMxLjIwNDQ4OF0gbGliY2VwaDogbG9hZGVkIChtb24vb3NkIHByb3RvIDE1LzI0KQpbICAg
MzEuMjA1Mzc1XSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgIDMx
LjIwNTM3NV0gLS0tLS0tLS0tLS0tWyBjdXQgaGVyZSBdLS0tLS0tLS0tLS0tClsgICAzMS4y
MDYxNDZdIFdBUk5JTkc6IENQVTogMCBQSUQ6IDEgYXQgL2tidWlsZC9zcmMvc21va2UvbmV0
L2JhdG1hbi1hZHYvaGFyZC1pbnRlcmZhY2UuYzo5MiBiYXRhZHZfaXNfb25fYmF0bWFuX2lm
YWNlKzB4NjIvMHg3MCgpCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzkx
N2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1YzliMjMvZG1lc2ctcXVhbnRhbC1m
My00NToyMDE0MDUyMTE5Mzc0ODppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4w
LXJjNS0wMTEzMS1nOTE3YTRkMzoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjEx
NjMwLzkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1YzliMjMvZG1lc2ctcXVh
bnRhbC1mNC0zNToyMDE0MDUyMTE5MzgwMzppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6
My4xNS4wLXJjNS0wMTEzMS1nOTE3YTRkMzoxCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMw
LTA1MjExNjMwLzkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1YzliMjMvZG1l
c2ctcXVhbnRhbC1mNC00MjoyMDE0MDUyMTE5MzgxNTppMzg2LXJhbmRjb25maWctYzAtMDUy
MTE2MzA6My4xNS4wLXJjNS0wMTEzMS1nOTE3YTRkMzoxCi9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwLzkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0YmU1Yzli
MjMvZG1lc2ctcXVhbnRhbC1mNC01NToyMDE0MDUyMTE5MzgxMDppMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzA6My4xNS4wLXJjNS0wMTEzMS1nOTE3YTRkMzoxCi9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWMwLTA1MjExNjMwLzkxN2E0ZDNhZWQ2MzAxMDk3ZmY4YTJiMmJiNzRiZTM0
YmU1YzliMjMvZG1lc2cteW9jdG8tZjItNDI6MjAxNDA1MjExOTM4MjQ6aTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzUtMDExMzEtZzkxN2E0ZDM6MQowOjU6NSBhbGxf
Z29vZDpiYWQ6YWxsX2JhZCBib290cwobWzE7MzVtMjAxNC0wNS0yMSAxOTozOTozOSBSRVBF
QVQgQ09VTlQ6IDIwICAjIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QvLnJlcGVh
dBtbMG0KCkJpc2VjdGluZzogMjYyIHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSA5IHN0ZXBzKQpbNmM4YjIzNWYyOWI2Yjc1NjM3OWQ3ZDVkODYzNzFhOWYz
OTlhZmE1Ml0gTWVyZ2UgJ2h3bW9uL2h3bW9uLW5leHQnIGludG8gZGV2ZWwtaG91cmx5LTIw
MTQwNTIxMTUKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWls
dXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10
ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1k
ZXZlbDpkZXZlbC1ob3VybHktMjAxNDA1MjExNTo2YzhiMjM1ZjI5YjZiNzU2Mzc5ZDdkNWQ4
NjM3MWE5ZjM5OWFmYTUyOmJpc2VjdC1saW51eDgKCjIwMTQtMDUtMjEtMTk6Mzk6NDAgNmM4
YjIzNWYyOWI2Yjc1NjM3OWQ3ZDVkODYzNzFhOWYzOTlhZmE1MiBjb21waWxpbmcKUXVldWVk
IGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25m
aWctYzAtMDUyMTE2MzAtNmM4YjIzNWYyOWI2Yjc1NjM3OWQ3ZDVkODYzNzFhOWYzOTlhZmE1
MgpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjEx
NjMwLzZjOGIyMzVmMjliNmI3NTYzNzlkN2Q1ZDg2MzcxYTlmMzk5YWZhNTIKd2FpdGluZyBm
b3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNv
bmZpZy1jMC0wNTIxMTYzMC02YzhiMjM1ZjI5YjZiNzU2Mzc5ZDdkNWQ4NjM3MWE5ZjM5OWFm
YTUyCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1
ZS8uaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTZjOGIyMzVmMjliNmI3NTYzNzlkN2Q1
ZDg2MzcxYTlmMzk5YWZhNTIKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMC82YzhiMjM1ZjI5YjZiNzU2Mzc5ZDdkNWQ4NjM3MWE5ZjM5OWFmYTUyL3ZtbGlu
dXotMy4xNS4wLXJjNS0wMjE1Ny1nNmM4YjIzNQoKMjAxNC0wNS0yMS0yMDowMTo0MCBkZXRl
Y3RpbmcgYm9vdCBzdGF0ZSAuLgkzCTE4CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMTMyIHJl
dmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA4IHN0ZXBzKQpbNzBj
MDg1OWFmM2UzODBhMDUwODg4MzEyMGFkYWM4ODNiNDU2YjA1Nl0gTWVyZ2UgJ2tlZXMvbHNt
LW1udC1yZXN0cmljdCcgaW50byBkZXZlbC1ob3VybHktMjAxNDA1MjExNQpydW5uaW5nIC9j
L2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0
cy9saW51eDgvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwL2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0y
MDE0MDUyMTE1OjcwYzA4NTlhZjNlMzgwYTA1MDg4ODMxMjBhZGFjODgzYjQ1NmIwNTY6Ymlz
ZWN0LWxpbnV4OAoKMjAxNC0wNS0yMS0yMDowNDoxMCA3MGMwODU5YWYzZTM4MGEwNTA4ODgz
MTIwYWRhYzg4M2I0NTZiMDU2IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1
aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC03MGMw
ODU5YWYzZTM4MGEwNTA4ODgzMTIwYWRhYzg4M2I0NTZiMDU2CkNoZWNrIGZvciBrZXJuZWwg
aW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNzBjMDg1OWFmM2UzODBh
MDUwODg4MzEyMGFkYWM4ODNiNDU2YjA1Ngp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9r
YnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTcw
YzA4NTlhZjNlMzgwYTA1MDg4ODMxMjBhZGFjODgzYjQ1NmIwNTYKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAtNzBjMDg1OWFmM2UzODBhMDUwODg4MzEyMGFkYWM4ODNiNDU2YjA1Ngpr
ZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzcwYzA4NTlhZjNl
MzgwYTA1MDg4ODMxMjBhZGFjODgzYjQ1NmIwNTYvdm1saW51ei0zLjE1LjAtcmM1LTAwOTI0
LWc3MGMwODU5CgoyMDE0LTA1LTIxLTIxOjA3OjEwIGRldGVjdGluZyBib290IHN0YXRlIC4u
LgkyMCBTVUNDRVNTCgpsaW5lYXItYmlzZWN0OiBiYWQgYnJhbmNoIG1heSBiZSBuZXQvbWFz
dGVyCmxpbmVhci1iaXNlY3Q6IGhhbmRsZSBvdmVyIHRvIGdpdCBiaXNlY3QKbGluZWFyLWJp
c2VjdDogZ2l0IGJpc2VjdCBzdGFydCA5MTdhNGQzYWVkNjMwMTA5N2ZmOGEyYjJiYjc0YmUz
NGJlNWM5YjIzIDcwYzA4NTlhZjNlMzgwYTA1MDg4ODMxMjBhZGFjODgzYjQ1NmIwNTYgLS0K
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgNzBjMDg1OS4uLiBNZXJnZSAna2Vlcy9sc20t
bW50LXJlc3RyaWN0JyBpbnRvIGRldmVsLWhvdXJseS0yMDE0MDUyMTE1CkhFQUQgaXMgbm93
IGF0IDM4NTgzZjAuLi4gTWVyZ2UgYnJhbmNoICdha3BtJyAoaW5jb21pbmcgZnJvbSBBbmRy
ZXcpCkJpc2VjdGluZzogNjcgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDYgc3RlcHMpCltiMzk0NzQ1ZGYyZDlkNGMzMGJmMWJjYzU1NzczYmVjNmYzYmM3
YzY3XSBuZXQ6IHBoeTogRG9uJ3QgY2FsbCBwaHlfcmVzdW1lIGlmIHBoeV9pbml0X2h3IGZh
aWxlZApsaW5lYXItYmlzZWN0OiBnaXQgYmlzZWN0IHJ1biAvYy9rZXJuZWwtdGVzdHMvYmlz
ZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNl
Y3QKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0cy9y
dW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1kZXZlbDpk
ZXZlbC1ob3VybHktMjAxNDA1MjExNTpiMzk0NzQ1ZGYyZDlkNGMzMGJmMWJjYzU1NzczYmVj
NmYzYmM3YzY3OmJpc2VjdC1saW51eDgKCjIwMTQtMDUtMjEtMjE6MDk6MjggYjM5NDc0NWRm
MmQ5ZDRjMzBiZjFiY2M1NTc3M2JlYzZmM2JjN2M2NyBjb21waWxpbmcKUXVldWVkIGJ1aWxk
IHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAtYjM5NDc0NWRmMmQ5ZDRjMzBiZjFiY2M1NTc3M2JlYzZmM2JjN2M2NwpDaGVj
ayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwL2Iz
OTQ3NDVkZjJkOWQ0YzMwYmYxYmNjNTU3NzNiZWM2ZjNiYzdjNjcKd2FpdGluZyBmb3IgY29t
cGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1j
MC0wNTIxMTYzMC1iMzk0NzQ1ZGYyZDlkNGMzMGJmMWJjYzU1NzczYmVjNmYzYmM3YzY3Cndh
aXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8uaTM4
Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLWIzOTQ3NDVkZjJkOWQ0YzMwYmYxYmNjNTU3NzNi
ZWM2ZjNiYzdjNjcKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYz
MC9iMzk0NzQ1ZGYyZDlkNGMzMGJmMWJjYzU1NzczYmVjNmYzYmM3YzY3L3ZtbGludXotMy4x
NS4wLXJjNC0wMDI1OC1nYjM5NDc0NQoKMjAxNC0wNS0yMS0yMToyOToyOCBkZXRlY3Rpbmcg
Ym9vdCBzdGF0ZSAuLgkyCTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMzEgcmV2aXNpb25zIGxl
ZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDUgc3RlcHMpClsyMDI2MzBiNDQ1ZDI2
MThkOTRlNGYwOTk1NjdmY2VlNTYxOGRhYjI3XSBNZXJnZSBicmFuY2ggJ2Zvci1kYXZlbScg
b2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2xpbnZp
bGxlL3dpcmVsZXNzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3Qt
ZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVp
bGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGlu
dXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6MjAyNjMwYjQ0NWQyNjE4ZDk0ZTRm
MDk5NTY3ZmNlZTU2MThkYWIyNzpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIxLTIxOjMxOjM0
IDIwMjYzMGI0NDVkMjYxOGQ5NGU0ZjA5OTU2N2ZjZWU1NjE4ZGFiMjcgY29tcGlsaW5nClF1
ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5k
Y29uZmlnLWMwLTA1MjExNjMwLTIwMjYzMGI0NDVkMjYxOGQ5NGU0ZjA5OTU2N2ZjZWU1NjE4
ZGFiMjcKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMC8yMDI2MzBiNDQ1ZDI2MThkOTRlNGYwOTk1NjdmY2VlNTYxOGRhYjI3CndhaXRp
bmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJh
bmRjb25maWctYzAtMDUyMTE2MzAtMjAyNjMwYjQ0NWQyNjE4ZDk0ZTRmMDk5NTY3ZmNlZTU2
MThkYWIyNwp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQt
cXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC0yMDI2MzBiNDQ1ZDI2MThkOTRl
NGYwOTk1NjdmY2VlNTYxOGRhYjI3Cmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAvMjAyNjMwYjQ0NWQyNjE4ZDk0ZTRmMDk5NTY3ZmNlZTU2MThkYWIyNy92
bWxpbnV6LTMuMTUuMC1yYzQtMDAyOTQtZzIwMjYzMGIKCjIwMTQtMDUtMjEtMjI6MjM6MzQg
ZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLgk4CTIwIFNVQ0NFU1MKCkJpc2VjdGluZzogMTUgcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDQgc3RlcHMpCls0NGE0
MDg1NTM4Yzg0NGU3OWQ2ZWU2YmNmNDZmYWJmN2M1N2E5YTM4XSBib25kaW5nOiBGaXggc3Rh
Y2tlZCBkZXZpY2UgZGV0ZWN0aW9uIGluIGFycCBtb25pdG9yaW5nCnJ1bm5pbmcgL2Mva2Vy
bmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xp
bnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQw
NTIxMTU6NDRhNDA4NTUzOGM4NDRlNzlkNmVlNmJjZjQ2ZmFiZjdjNTdhOWEzODpiaXNlY3Qt
bGludXg4CgoyMDE0LTA1LTIxLTIyOjI1OjEwIDQ0YTQwODU1MzhjODQ0ZTc5ZDZlZTZiY2Y0
NmZhYmY3YzU3YTlhMzggY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTQ0YTQwODU1
MzhjODQ0ZTc5ZDZlZTZiY2Y0NmZhYmY3YzU3YTlhMzgKQ2hlY2sgZm9yIGtlcm5lbCBpbiAv
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC80NGE0MDg1NTM4Yzg0NGU3OWQ2
ZWU2YmNmNDZmYWJmN2M1N2E5YTM4CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWls
ZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNDRhNDA4
NTUzOGM4NDRlNzlkNmVlNmJjZjQ2ZmFiZjdjNTdhOWEzOAp3YWl0aW5nIGZvciBjb21wbGV0
aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMC00NGE0MDg1NTM4Yzg0NGU3OWQ2ZWU2YmNmNDZmYWJmN2M1N2E5YTM4ChtbMTsz
NW0yMDE0LTA1LTIxIDIyOjU0OjEwIEtlcm5lbCBidWlsZCBmYWlsIG9yIHRpbWVvdXQbWzBt
CjIwMTQtMDUtMjEtMjI6NTQ6MTAgNDRhNDA4NTUzOGM4NDRlNzlkNmVlNmJjZjQ2ZmFiZjdj
NTdhOWEzOCBTS0lQIEJST0tFTiBCVUlMRApDaGVjayAva2J1aWxkLXRlc3RzL2J1aWxkLXNl
cnZlZC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNDRhNDA4NTUzOGM4NDRlNzlkNmVl
NmJjZjQ2ZmFiZjdjNTdhOWEzOApCaXNlY3Rpbmc6IDE1IHJldmlzaW9ucyBsZWZ0IHRvIHRl
c3QgYWZ0ZXIgdGhpcyAocm91Z2hseSA0IHN0ZXBzKQpbMGQwOGZjZWIyZTIxYzMwY2EzZTFl
NDYyZTY3ODcyM2Y4MDZhY2YxOF0geGVuLW5ldGJhY2s6IGZpeCByYWNlIGJldHdlZW4gbmFw
aV9jb21wbGV0ZSgpIGFuZCBpbnRlcnJ1cHQgaGFuZGxlcgpydW5uaW5nIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgv
b2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5k
Y29uZmlnLWMwLTA1MjExNjMwL2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDUyMTE1
OjBkMDhmY2ViMmUyMWMzMGNhM2UxZTQ2MmU2Nzg3MjNmODA2YWNmMTg6YmlzZWN0LWxpbnV4
OAoKMjAxNC0wNS0yMS0yMjo1NDoxOSAwZDA4ZmNlYjJlMjFjMzBjYTNlMWU0NjJlNjc4NzIz
ZjgwNmFjZjE4IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC0wZDA4ZmNlYjJlMjFj
MzBjYTNlMWU0NjJlNjc4NzIzZjgwNmFjZjE4CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvMGQwOGZjZWIyZTIxYzMwY2EzZTFlNDYy
ZTY3ODcyM2Y4MDZhY2YxOAp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTBkMDhmY2ViMmUy
MWMzMGNhM2UxZTQ2MmU2Nzg3MjNmODA2YWNmMTgKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2
MzAtMGQwOGZjZWIyZTIxYzMwY2EzZTFlNDYyZTY3ODcyM2Y4MDZhY2YxOAprZXJuZWw6IC9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzBkMDhmY2ViMmUyMWMzMGNhM2Ux
ZTQ2MmU2Nzg3MjNmODA2YWNmMTgvdm1saW51ei0zLjE1LjAtcmM0LTAwMjk1LWcwZDA4ZmNl
CgoyMDE0LTA1LTIxLTIzOjE2OjE5IGRldGVjdGluZyBib290IHN0YXRlIC4JMQkxOQkyMCBT
VUNDRVNTCgpCaXNlY3Rpbmc6IDE1IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhp
cyAocm91Z2hseSA0IHN0ZXBzKQpbMjUxNzViYTVjOWJmZjlhYWYwMjI5ZGYzNGJiNWQ1NGM4
MTYzM2VjM10gbmV0OiBBbGxvdyBmb3IgbW9yZSB0aGVuIGEgc2luZ2xlIHN1YmNsYXNzIGZv
ciBuZXRpZl9hZGRyX2xvY2sKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3Qt
Ym9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEg
L2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYz
MC9saW51eC1kZXZlbDpkZXZlbC1ob3VybHktMjAxNDA1MjExNToyNTE3NWJhNWM5YmZmOWFh
ZjAyMjlkZjM0YmI1ZDU0YzgxNjMzZWMzOmJpc2VjdC1saW51eDgKCjIwMTQtMDUtMjEtMjM6
MTg6MjYgMjUxNzViYTVjOWJmZjlhYWYwMjI5ZGYzNGJiNWQ1NGM4MTYzM2VjMyBjb21waWxp
bmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAtMjUxNzViYTVjOWJmZjlhYWYwMjI5ZGYzNGJiNWQ1
NGM4MTYzM2VjMwpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmln
LWMwLTA1MjExNjMwLzI1MTc1YmE1YzliZmY5YWFmMDIyOWRmMzRiYjVkNTRjODE2MzNlYzMK
d2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kz
ODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC0yNTE3NWJhNWM5YmZmOWFhZjAyMjlkZjM0YmI1
ZDU0YzgxNjMzZWMzCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9i
dWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTI1MTc1YmE1YzliZmY5
YWFmMDIyOWRmMzRiYjVkNTRjODE2MzNlYzMKa2VybmVsOiAva2VybmVsL2kzODYtcmFuZGNv
bmZpZy1jMC0wNTIxMTYzMC8yNTE3NWJhNWM5YmZmOWFhZjAyMjlkZjM0YmI1ZDU0YzgxNjMz
ZWMzL3ZtbGludXotMy4xNS4wLXJjNC0wMDA0OS1nMjUxNzViYQoKMjAxNC0wNS0yMi0wMDox
NDozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4J
MjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxMCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVy
IHRoaXMgKHJvdWdobHkgMyBzdGVwcykKWzUyNDM2OWUyMzkxZjRiNDIyZDBlZmRkMTFkNTI2
YTM3M2ExMWE0M2FdIGNhbjogY19jYW46IHJlbW92ZSBvYnNvbGV0ZSBTVFJJQ1RfRlJBTUVf
T1JERVJJTkcgS2NvbmZpZyBvcHRpb24KcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0
LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QK
bHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMC9saW51eC1kZXZlbDpkZXZlbC1ob3VybHktMjAxNDA1MjExNTo1MjQzNjllMjM5
MWY0YjQyMmQwZWZkZDExZDUyNmEzNzNhMTFhNDNhOmJpc2VjdC1saW51eDgKCjIwMTQtMDUt
MjItMDA6Mjg6MzggNTI0MzY5ZTIzOTFmNGI0MjJkMGVmZGQxMWQ1MjZhMzczYTExYTQzYSBj
b21waWxpbmcKUXVldWVkIGJ1aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1
ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNTI0MzY5ZTIzOTFmNGI0MjJkMGVmZGQx
MWQ1MjZhMzczYTExYTQzYQpDaGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWMwLTA1MjExNjMwLzUyNDM2OWUyMzkxZjRiNDIyZDBlZmRkMTFkNTI2YTM3M2Ex
MWE0M2EKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1
ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC01MjQzNjllMjM5MWY0YjQyMmQwZWZk
ZDExZDUyNmEzNzNhMTFhNDNhCndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS8uaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTUyNDM2OWUy
MzkxZjRiNDIyZDBlZmRkMTFkNTI2YTM3M2ExMWE0M2EKG1sxOzM1bTIwMTQtMDUtMjIgMDA6
Mzg6MzkgS2VybmVsIGJ1aWxkIGZhaWwgb3IgdGltZW91dBtbMG0KMjAxNC0wNS0yMi0wMDoz
ODozOSA1MjQzNjllMjM5MWY0YjQyMmQwZWZkZDExZDUyNmEzNzNhMTFhNDNhIFNLSVAgQlJP
S0VOIEJVSUxECkNoZWNrIC9rYnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNv
bmZpZy1jMC0wNTIxMTYzMC01MjQzNjllMjM5MWY0YjQyMmQwZWZkZDExZDUyNmEzNzNhMTFh
NDNhCkJpc2VjdGluZzogMTAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDMgc3RlcHMpCls0ZjMzN2VkNWMwMTQ3NTJiMDAwZjU5MzE4MmZkY2ZhM2VjZjBk
MTY2XSBNQUlOVEFJTkVSUzogUHJhdmluIFNoZWxhciBpcyBPcGVuIHZTd2l0Y2ggbWFpbnRh
aW5lci4KcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJl
LnNoIC9rZXJuZWwtdGVzdHMvbGludXg4L29iai1iaXNlY3QKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1kZXZl
bDpkZXZlbC1ob3VybHktMjAxNDA1MjExNTo0ZjMzN2VkNWMwMTQ3NTJiMDAwZjU5MzE4MmZk
Y2ZhM2VjZjBkMTY2OmJpc2VjdC1saW51eDgKCjIwMTQtMDUtMjItMDA6Mzg6NDQgNGYzMzdl
ZDVjMDE0NzUyYjAwMGY1OTMxODJmZGNmYTNlY2YwZDE2NiBjb21waWxpbmcKUXVldWVkIGJ1
aWxkIHRhc2sgdG8gL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAtNGYzMzdlZDVjMDE0NzUyYjAwMGY1OTMxODJmZGNmYTNlY2YwZDE2NgpD
aGVjayBmb3Iga2VybmVsIGluIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMw
LzRmMzM3ZWQ1YzAxNDc1MmIwMDBmNTkzMTgyZmRjZmEzZWNmMGQxNjYKd2FpdGluZyBmb3Ig
Y29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZp
Zy1jMC0wNTIxMTYzMC00ZjMzN2VkNWMwMTQ3NTJiMDAwZjU5MzE4MmZkY2ZhM2VjZjBkMTY2
CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS8u
aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTRmMzM3ZWQ1YzAxNDc1MmIwMDBmNTkzMTgy
ZmRjZmEzZWNmMGQxNjYKG1sxOzM1bTIwMTQtMDUtMjIgMDI6Mjc6NDUgS2VybmVsIGJ1aWxk
IGZhaWwgb3IgdGltZW91dBtbMG0KMjAxNC0wNS0yMi0wMjoyNzo0NSA0ZjMzN2VkNWMwMTQ3
NTJiMDAwZjU5MzE4MmZkY2ZhM2VjZjBkMTY2IFNLSVAgQlJPS0VOIEJVSUxECkNoZWNrIC9r
YnVpbGQtdGVzdHMvYnVpbGQtc2VydmVkL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC00
ZjMzN2VkNWMwMTQ3NTJiMDAwZjU5MzE4MmZkY2ZhM2VjZjBkMTY2CkJpc2VjdGluZzogMTAg
cmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDMgc3RlcHMpCls1
NDY3YTUxMjIxNjc1M2Q1NGY3NTczMTRjNzNkYmM2MGY2NTlmOWU2XSBuZXRmaWx0ZXI6IG5m
X3RhYmxlczogZml4IGdvdG8gYWN0aW9uCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0
CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6NTQ2N2E1MTIy
MTY3NTNkNTRmNzU3MzE0YzczZGJjNjBmNjU5ZjllNjpiaXNlY3QtbGludXg4CgoyMDE0LTA1
LTIyLTAyOjI3OjUxIDU0NjdhNTEyMjE2NzUzZDU0Zjc1NzMxNGM3M2RiYzYwZjY1OWY5ZTYg
Y29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTU0NjdhNTEyMjE2NzUzZDU0Zjc1NzMx
NGM3M2RiYzYwZjY1OWY5ZTYKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFu
ZGNvbmZpZy1jMC0wNTIxMTYzMC81NDY3YTUxMjIxNjc1M2Q1NGY3NTczMTRjNzNkYmM2MGY2
NTlmOWU2CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1x
dWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNTQ2N2E1MTIyMTY3NTNkNTRmNzU3
MzE0YzczZGJjNjBmNjU5ZjllNgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQt
dGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC01NDY3YTUx
MjIxNjc1M2Q1NGY3NTczMTRjNzNkYmM2MGY2NTlmOWU2Cmtlcm5lbDogL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNTQ2N2E1MTIyMTY3NTNkNTRmNzU3MzE0YzczZGJj
NjBmNjU5ZjllNi92bWxpbnV6LTMuMTUuMC1yYzEtMDA1MDItZzU0NjdhNTEKCjIwMTQtMDUt
MjItMDM6MzQ6NTIgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLgk1CTE2LgkxOAkyMCBTVUND
RVNTCgpCaXNlY3Rpbmc6IDggcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDMgc3RlcHMpCltjNjc0YWMzMGM1NDk1OTYyOTVlYjBhNWFmN2Y0NzE0YzBiOTA1
YjZmXSBtYWN2bGFuOiBGaXggbG9ja2RlcCB3YXJuaW5ncyB3aXRoIHN0YWNrZWQgbWFjdmxh
biBkZXZpY2VzCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGludXgt
ZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6YzY3NGFjMzBjNTQ5NTk2Mjk1ZWIwYTVh
ZjdmNDcxNGMwYjkwNWI2ZjpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIyLTAzOjM5OjI5IGM2
NzRhYzMwYzU0OTU5NjI5NWViMGE1YWY3ZjQ3MTRjMGI5MDViNmYgY29tcGlsaW5nClF1ZXVl
ZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwLWM2NzRhYzMwYzU0OTU5NjI5NWViMGE1YWY3ZjQ3MTRjMGI5MDVi
NmYKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMC9jNjc0YWMzMGM1NDk1OTYyOTVlYjBhNWFmN2Y0NzE0YzBiOTA1YjZmCndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzAtYzY3NGFjMzBjNTQ5NTk2Mjk1ZWIwYTVhZjdmNDcxNGMwYjkw
NWI2Zgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1jNjc0YWMzMGM1NDk1OTYyOTVlYjBh
NWFmN2Y0NzE0YzBiOTA1YjZmCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvYzY3NGFjMzBjNTQ5NTk2Mjk1ZWIwYTVhZjdmNDcxNGMwYjkwNWI2Zi92bWxp
bnV6LTMuMTUuMC1yYzQtMDAwNTEtZ2M2NzRhYzMKCjIwMTQtMDUtMjItMDQ6MTA6MjkgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uCTQJMjAgU1VDQ0VTUwoKQmlzZWN0aW5nOiA4IHJldmlz
aW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbZjYwYzM3
MDRlODdkMzkzNTZkMDBjNzFiZjUxZTU1YzJjNTVhZDRmNV0gYm9uZGluZzogRml4IGFsYiBt
b2RlIHRvIG9ubHkgdXNlIGZpcnN0IGxldmVsIHZsYW5zLgpydW5uaW5nIC9jL2tlcm5lbC10
ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgv
b2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5k
Y29uZmlnLWMwLTA1MjExNjMwL2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDUyMTE1
OmY2MGMzNzA0ZTg3ZDM5MzU2ZDAwYzcxYmY1MWU1NWMyYzU1YWQ0ZjU6YmlzZWN0LWxpbnV4
OAoKMjAxNC0wNS0yMi0wNDoxMzowNSBmNjBjMzcwNGU4N2QzOTM1NmQwMGM3MWJmNTFlNTVj
MmM1NWFkNGY1IGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3Rz
L2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1mNjBjMzcwNGU4N2Qz
OTM1NmQwMGM3MWJmNTFlNTVjMmM1NWFkNGY1CkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvZjYwYzM3MDRlODdkMzkzNTZkMDBjNzFi
ZjUxZTU1YzJjNTVhZDRmNQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLWY2MGMzNzA0ZTg3
ZDM5MzU2ZDAwYzcxYmY1MWU1NWMyYzU1YWQ0ZjUKd2FpdGluZyBmb3IgY29tcGxldGlvbiBv
ZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2
MzAtZjYwYzM3MDRlODdkMzkzNTZkMDBjNzFiZjUxZTU1YzJjNTVhZDRmNQobWzE7MzVtMjAx
NC0wNS0yMiAwNToyNjowNyBLZXJuZWwgYnVpbGQgZmFpbCBvciB0aW1lb3V0G1swbQoyMDE0
LTA1LTIyLTA1OjI2OjA3IGY2MGMzNzA0ZTg3ZDM5MzU2ZDAwYzcxYmY1MWU1NWMyYzU1YWQ0
ZjUgU0tJUCBCUk9LRU4gQlVJTEQKQ2hlY2sgL2tidWlsZC10ZXN0cy9idWlsZC1zZXJ2ZWQv
aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLWY2MGMzNzA0ZTg3ZDM5MzU2ZDAwYzcxYmY1
MWU1NWMyYzU1YWQ0ZjUKQmlzZWN0aW5nOiA4IHJldmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0
ZXIgdGhpcyAocm91Z2hseSAzIHN0ZXBzKQpbZTE2MThkNDYxY2ExOGQ0MGY5YzNlZjcwNTk4
YWJiNzJlNzVkMjdhZV0gdmxhbjogRml4IGJ1aWxkIGVycm9yIHd0aCB2bGFuX2dldF9lbmNh
cF9sZXZlbCgpCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFp
bHVyZS5zaCAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQt
dGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGludXgt
ZGV2ZWw6ZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTU6ZTE2MThkNDYxY2ExOGQ0MGY5YzNlZjcw
NTk4YWJiNzJlNzVkMjdhZTpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIyLTA1OjI2OjE1IGUx
NjE4ZDQ2MWNhMThkNDBmOWMzZWY3MDU5OGFiYjcyZTc1ZDI3YWUgY29tcGlsaW5nClF1ZXVl
ZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwLWUxNjE4ZDQ2MWNhMThkNDBmOWMzZWY3MDU5OGFiYjcyZTc1ZDI3
YWUKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMC9lMTYxOGQ0NjFjYTE4ZDQwZjljM2VmNzA1OThhYmI3MmU3NWQyN2FlCndhaXRpbmcg
Zm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzAtZTE2MThkNDYxY2ExOGQ0MGY5YzNlZjcwNTk4YWJiNzJlNzVk
MjdhZQp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVl
dWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1lMTYxOGQ0NjFjYTE4ZDQwZjljM2Vm
NzA1OThhYmI3MmU3NWQyN2FlCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvZTE2MThkNDYxY2ExOGQ0MGY5YzNlZjcwNTk4YWJiNzJlNzVkMjdhZS92bWxp
bnV6LTMuMTUuMC1yYzQtMDAwNTgtZ2UxNjE4ZDQKCjIwMTQtMDUtMjItMDc6MDk6MTYgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uLi4uCTEJMwkxMwkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6
IDQgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDIgc3RlcHMp
ClszYjA4NGU5OWEzZmFiYWViMGY5YzY1YTA4MDZjZGUzMGYwYjI4MzVlXSBuZXRmaWx0ZXI6
IG5mX3RhYmxlczogZml4IHRyYWNlIG9mIG1hdGNoaW5nIG5vbi10ZXJtaW5hbCBydWxlCnJ1
bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAva2Vy
bmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1
ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvbGludXgtZGV2ZWw6ZGV2ZWwt
aG91cmx5LTIwMTQwNTIxMTU6M2IwODRlOTlhM2ZhYmFlYjBmOWM2NWEwODA2Y2RlMzBmMGIy
ODM1ZTpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIyLTA3OjE0OjIyIDNiMDg0ZTk5YTNmYWJh
ZWIwZjljNjVhMDgwNmNkZTMwZjBiMjgzNWUgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNr
IHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjEx
NjMwLTNiMDg0ZTk5YTNmYWJhZWIwZjljNjVhMDgwNmNkZTMwZjBiMjgzNWUKQ2hlY2sgZm9y
IGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC8zYjA4NGU5
OWEzZmFiYWViMGY5YzY1YTA4MDZjZGUzMGYwYjI4MzVlCndhaXRpbmcgZm9yIGNvbXBsZXRp
b24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUy
MTE2MzAtM2IwODRlOTlhM2ZhYmFlYjBmOWM2NWEwODA2Y2RlMzBmMGIyODM1ZQp3YWl0aW5n
IGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFu
ZGNvbmZpZy1jMC0wNTIxMTYzMC0zYjA4NGU5OWEzZmFiYWViMGY5YzY1YTA4MDZjZGUzMGYw
YjI4MzVlCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvM2Iw
ODRlOTlhM2ZhYmFlYjBmOWM2NWEwODA2Y2RlMzBmMGIyODM1ZS92bWxpbnV6LTMuMTUuMC1y
YzEtMDA1MDYtZzNiMDg0ZTkKCjIwMTQtMDUtMjItMDc6Mzg6MjIgZGV0ZWN0aW5nIGJvb3Qg
c3RhdGUgLi4uLi4uLi4uLi4uLi4uCTEJOQkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDEgcmV2
aXNpb24gbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMSBzdGVwKQpbZDhkMzNj
M2I4YTQyZmJkOWFkMjNhNjE0OThmYTVkYjFkODM2NDRlMF0gTWVyZ2UgdGFnICdsaW51eC1j
YW4tZml4ZXMtZm9yLTMuMTUtMjAxNDA1MTknIG9mIGdpdDovL2dpdG9yaW91cy5vcmcvbGlu
dXgtY2FuL2xpbnV4LWNhbgpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1i
b290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9saW51eDgvb2JqLWJpc2VjdApscyAtYSAv
a2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMw
L2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0MDUyMTE1OmQ4ZDMzYzNiOGE0MmZiZDlh
ZDIzYTYxNDk4ZmE1ZGIxZDgzNjQ0ZTA6YmlzZWN0LWxpbnV4OAoKMjAxNC0wNS0yMi0wNzo0
NzoyOSBkOGQzM2MzYjhhNDJmYmQ5YWQyM2E2MTQ5OGZhNWRiMWQ4MzY0NGUwIGNvbXBpbGlu
ZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYt
cmFuZGNvbmZpZy1jMC0wNTIxMTYzMC1kOGQzM2MzYjhhNDJmYmQ5YWQyM2E2MTQ5OGZhNWRi
MWQ4MzY0NGUwCkNoZWNrIGZvciBrZXJuZWwgaW4gL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAvZDhkMzNjM2I4YTQyZmJkOWFkMjNhNjE0OThmYTVkYjFkODM2NDRlMAp3
YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4
Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLWQ4ZDMzYzNiOGE0MmZiZDlhZDIzYTYxNDk4ZmE1
ZGIxZDgzNjQ0ZTAKd2FpdGluZyBmb3IgY29tcGxldGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1
aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtZDhkMzNjM2I4YTQyZmJk
OWFkMjNhNjE0OThmYTVkYjFkODM2NDRlMAprZXJuZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwL2Q4ZDMzYzNiOGE0MmZiZDlhZDIzYTYxNDk4ZmE1ZGIxZDgzNjQ0
ZTAvdm1saW51ei0zLjE1LjAtcmM0LTAwMDY3LWdkOGQzM2MzCgoyMDE0LTA1LTIyLTA4OjA3
OjI5IGRldGVjdGluZyBib290IHN0YXRlIC4JNAkxOAkyMCBTVUNDRVNTCgpCaXNlY3Rpbmc6
IDAgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDAgc3RlcHMp
Cls3OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJlNGZhYmI0NjdjNmMzZWViXSBpcF90dW5uZWw6
IEluaXRpYWxpemUgdGhlIGZhbGxiYWNrIGRldmljZSBwcm9wZXJseQpydW5uaW5nIC9jL2tl
cm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2tlcm5lbC10ZXN0cy9s
aW51eDgvb2JqLWJpc2VjdApscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9rdm0vaTM4
Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwL2xpbnV4LWRldmVsOmRldmVsLWhvdXJseS0yMDE0
MDUyMTE1Ojc4ZmY0YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWI6YmlzZWN0
LWxpbnV4OAoKMjAxNC0wNS0yMi0wODowOTozNyA3OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJl
NGZhYmI0NjdjNmMzZWViIGNvbXBpbGluZwpRdWV1ZWQgYnVpbGQgdGFzayB0byAva2J1aWxk
LXRlc3RzL2J1aWxkLXF1ZXVlL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC03OGZmNGJl
NDVhNGM1MWQ4ZmIyMWFkOTJlNGZhYmI0NjdjNmMzZWViCkNoZWNrIGZvciBrZXJuZWwgaW4g
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNzhmZjRiZTQ1YTRjNTFkOGZi
MjFhZDkyZTRmYWJiNDY3YzZjM2VlYgp3YWl0aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVp
bGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTc4ZmY0
YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIKd2FpdGluZyBmb3IgY29tcGxl
dGlvbiBvZiAva2J1aWxkLXRlc3RzL2J1aWxkLXF1ZXVlLy5pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAtNzhmZjRiZTQ1YTRjNTFkOGZiMjFhZDkyZTRmYWJiNDY3YzZjM2VlYgprZXJu
ZWw6IC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzc4ZmY0YmU0NWE0YzUx
ZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvdm1saW51ei0zLjE1LjAtcmM0LTAwMDY4LWc3
OGZmNGJlCgoyMDE0LTA1LTIyLTA4OjUxOjM4IGRldGVjdGluZyBib290IHN0YXRlIC4uIFRF
U1QgRkFJTFVSRQpbICAgMzEuNTg2MTA0XSBsaWJjZXBoOiBsb2FkZWQgKG1vbi9vc2QgcHJv
dG8gMTUvMjQpClsgICAzMS41ODY5NzFdIC0tLS0tLS0tLS0tLVsgY3V0IGhlcmUgXS0tLS0t
LS0tLS0tLQpbICAgMzEuNTg2OTcxXSAtLS0tLS0tLS0tLS1bIGN1dCBoZXJlIF0tLS0tLS0t
LS0tLS0KWyAgIDMxLjU4NzcxMF0gV0FSTklORzogQ1BVOiAxIFBJRDogMSBhdCAva2J1aWxk
L3NyYy9jb25zdW1lci9uZXQvYmF0bWFuLWFkdi9oYXJkLWludGVyZmFjZS5jOjkyIGJhdGFk
dl9pc19vbl9iYXRtYW5faWZhY2UrMHg2Mi8weDcwKCkKL2tlcm5lbC9pMzg2LXJhbmRjb25m
aWctYzAtMDUyMTE2MzAvNzhmZjRiZTQ1YTRjNTFkOGZiMjFhZDkyZTRmYWJiNDY3YzZjM2Vl
Yi9kbWVzZy1xdWFudGFsLWl2YjQxLTg1OjIwMTQwNTIyMDg1MjIxOmkzODYtcmFuZGNvbmZp
Zy1jMC0wNTIxMTYzMDozLjE1LjAtcmM0LTAwMDY4LWc3OGZmNGJlOjIKL2tlcm5lbC9pMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNzhmZjRiZTQ1YTRjNTFkOGZiMjFhZDkyZTRmYWJi
NDY3YzZjM2VlYi9kbWVzZy1xdWFudGFsLWl2YjQyLTExMjoyMDE0MDUyMjA4NTIyMjppMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNC0wMDA2OC1nNzhmZjRiZToyCi9r
ZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzc4ZmY0YmU0NWE0YzUxZDhmYjIx
YWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvZG1lc2ctcXVhbnRhbC1pdmI0Mi03MzoyMDE0MDUyMjA4
NTIyMjppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNC0wMDA2OC1nNzhm
ZjRiZToyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzc4ZmY0YmU0NWE0
YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvZG1lc2ctcXVhbnRhbC1pdmI0My05OToy
MDE0MDUyMjA4NTIyMzppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNC0w
MDA2OC1nNzhmZjRiZToyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzc4
ZmY0YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvZG1lc2ctcXVhbnRhbC1p
dmI0MS0xMjY6MjAxNDA1MjIwODUyMjY6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMu
MTUuMC1yYzQtMDAwNjgtZzc4ZmY0YmU6Mgova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMC83OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJlNGZhYmI0NjdjNmMzZWViL2RtZXNn
LXF1YW50YWwtaXZiNDEtMTc6MjAxNDA1MjIwODUyMjY6aTM4Ni1yYW5kY29uZmlnLWMwLTA1
MjExNjMwOjMuMTUuMC1yYzQtMDAwNjgtZzc4ZmY0YmU6Mgova2VybmVsL2kzODYtcmFuZGNv
bmZpZy1jMC0wNTIxMTYzMC83OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJlNGZhYmI0NjdjNmMz
ZWViL2RtZXNnLXF1YW50YWwtaXZiNDEtNDY6MjAxNDA1MjIwODUyMjY6aTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzQtMDAwNjgtZzc4ZmY0YmU6Mgova2VybmVsL2kz
ODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC83OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJlNGZh
YmI0NjdjNmMzZWViL2RtZXNnLXF1YW50YWwtaXZiNDEtNTM6MjAxNDA1MjIwODUyMjQ6aTM4
Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMuMTUuMC1yYzQtMDAwNjgtZzc4ZmY0YmU6Mgov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC83OGZmNGJlNDVhNGM1MWQ4ZmIy
MWFkOTJlNGZhYmI0NjdjNmMzZWViL2RtZXNnLXF1YW50YWwtaXZiNDMtMTAzOjIwMTQwNTIy
MDg1MjI0OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM0LTAwMDY4LWc3
OGZmNGJlOjIKL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNzhmZjRiZTQ1
YTRjNTFkOGZiMjFhZDkyZTRmYWJiNDY3YzZjM2VlYi9kbWVzZy1xdWFudGFsLWl2YjQzLTEx
MToyMDE0MDUyMjA4NTIyNjppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJj
NC0wMDA2OC1nNzhmZjRiZToyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMw
Lzc4ZmY0YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvZG1lc2ctcXVhbnRh
bC1pdmI0My03MToyMDE0MDUyMjA4NTIyNDppMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6
My4xNS4wLXJjNC0wMDA2OC1nNzhmZjRiZToyCi9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMw
LTA1MjExNjMwLzc4ZmY0YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2YzNlZWIvZG1l
c2ctcXVhbnRhbC1pdmI0My03OToyMDE0MDUyMjA4NTIyMzppMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzA6My4xNS4wLXJjNC0wMDA2OC1nNzhmZjRiZToyCi9rZXJuZWwvaTM4Ni1yYW5k
Y29uZmlnLWMwLTA1MjExNjMwLzc4ZmY0YmU0NWE0YzUxZDhmYjIxYWQ5MmU0ZmFiYjQ2N2M2
YzNlZWIvZG1lc2ctcXVhbnRhbC1pdmI0NC0xMDoyMDE0MDUyMjA4NTIyNDppMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNC0wMDA2OC1nNzhmZjRiZToyCjA6MTM6MTMg
YWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKG1sxOzM1bTIwMTQtMDUtMjIgMDg6NTI6Mzkg
UkVQRUFUIENPVU5UOiAyMCAgIyAva2VybmVsLXRlc3RzL2xpbnV4OC9vYmotYmlzZWN0Ly5y
ZXBlYXQbWzBtCgo3OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJlNGZhYmI0NjdjNmMzZWViIGlz
IHRoZSBmaXJzdCBiYWQgY29tbWl0CmNvbW1pdCA3OGZmNGJlNDVhNGM1MWQ4ZmIyMWFkOTJl
NGZhYmI0NjdjNmMzZWViCkF1dGhvcjogU3RlZmZlbiBLbGFzc2VydCA8c3RlZmZlbi5rbGFz
c2VydEBzZWN1bmV0LmNvbT4KRGF0ZTogICBNb24gTWF5IDE5IDExOjM2OjU2IDIwMTQgKzAy
MDAKCiAgICBpcF90dW5uZWw6IEluaXRpYWxpemUgdGhlIGZhbGxiYWNrIGRldmljZSBwcm9w
ZXJseQogICAgCiAgICBXZSBuZWVkIHRvIGluaXRpYWxpemUgdGhlIGZhbGxiYWNrIGRldmlj
ZSB0byBoYXZlIGEgY29ycmVjdCBtdHUKICAgIHNldCBvbiB0aGlzIGRldmljZS4gT3RoZXJ3
aXNlIHRoZSBtdHUgaXMgc2V0IHRvIG51bGwgYW5kIHRoZSBkZXZpY2UKICAgIGlzIHVudXNh
YmxlLgogICAgCiAgICBGaXhlczogZmQ1ODE1NmU0NTZkICgiSVBJUDogVXNlIGlwLXR1bm5l
bGluZyBjb2RlLiIpCiAgICBDYzogUHJhdmluIEIgU2hlbGFyIDxwc2hlbGFyQG5pY2lyYS5j
b20+CiAgICBTaWduZWQtb2ZmLWJ5OiBTdGVmZmVuIEtsYXNzZXJ0IDxzdGVmZmVuLmtsYXNz
ZXJ0QHNlY3VuZXQuY29tPgogICAgU2lnbmVkLW9mZi1ieTogRGF2aWQgUy4gTWlsbGVyIDxk
YXZlbUBkYXZlbWxvZnQubmV0PgoKOjA0MDAwMCAwNDAwMDAgNmRjMWVkYTQ2NjQ5NDU1ZDk5
N2ZmMDM0YmEzNTQ0YjA2OWU1MDdmNyA3MDI1OTNiNjk0MGEzOTg2YWQyMTBiYTNmYTRhYWM4
MmZjNjk0MWNiIE0JbmV0CmJpc2VjdCBydW4gc3VjY2VzcwpQcmV2aW91cyBIRUFEIHBvc2l0
aW9uIHdhcyA3OGZmNGJlLi4uIGlwX3R1bm5lbDogSW5pdGlhbGl6ZSB0aGUgZmFsbGJhY2sg
ZGV2aWNlIHByb3Blcmx5CkhFQUQgaXMgbm93IGF0IGQ4ZDMzYzMuLi4gTWVyZ2UgdGFnICds
aW51eC1jYW4tZml4ZXMtZm9yLTMuMTUtMjAxNDA1MTknIG9mIGdpdDovL2dpdG9yaW91cy5v
cmcvbGludXgtY2FuL2xpbnV4LWNhbgpscyAtYSAva2J1aWxkLXRlc3RzL3J1bi1xdWV1ZS9r
dm0vaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwL2xpbnV4LWRldmVsOmRldmVsLWhvdXJs
eS0yMDE0MDUyMTE1OmQ4ZDMzYzNiOGE0MmZiZDlhZDIzYTYxNDk4ZmE1ZGIxZDgzNjQ0ZTA6
YmlzZWN0LWxpbnV4OAoKMjAxNC0wNS0yMi0wODo1Mjo1MSBkOGQzM2MzYjhhNDJmYmQ5YWQy
M2E2MTQ5OGZhNWRiMWQ4MzY0NGUwIHJldXNlIC9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMw
LTA1MjExNjMwL2Q4ZDMzYzNiOGE0MmZiZDlhZDIzYTYxNDk4ZmE1ZGIxZDgzNjQ0ZTAvdm1s
aW51ei0zLjE1LjAtcmM0LTAwMDY3LWdkOGQzM2MzCgoyMDE0LTA1LTIyLTA4OjUyOjUxIGRl
dGVjdGluZyBib290IHN0YXRlIC4uLgkyNwk0OQk2MCBTVUNDRVNTCgpQcmV2aW91cyBIRUFE
IHBvc2l0aW9uIHdhcyBkOGQzM2MzLi4uIE1lcmdlIHRhZyAnbGludXgtY2FuLWZpeGVzLWZv
ci0zLjE1LTIwMTQwNTE5JyBvZiBnaXQ6Ly9naXRvcmlvdXMub3JnL2xpbnV4LWNhbi9saW51
eC1jYW4KSEVBRCBpcyBub3cgYXQgODQyMzkwOS4uLiAwZGF5IGhlYWQgZ3VhcmQgZm9yICdk
ZXZlbC1ob3VybHktMjAxNDA1MjExNScKbHMgLWEgL2tidWlsZC10ZXN0cy9ydW4tcXVldWUv
a3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51eC1kZXZlbDpkZXZlbC1ob3Vy
bHktMjAxNDA1MjExNTo4NDIzOTA5MzllOGRjMThmZThhODdlMjU3ZTdlODA4ODU0OGJkOGQ3
OmJpc2VjdC1saW51eDgKIFRFU1QgRkFJTFVSRQpbICAgMzEuNDk5NjczXSBsaWJjZXBoOiBs
b2FkZWQgKG1vbi9vc2QgcHJvdG8gMTUvMjQpClsgICAzMS41MDAzNzRdIC0tLS0tLS0tLS0t
LVsgY3V0IGhlcmUgXS0tLS0tLS0tLS0tLQpbICAgMzEuNTAwMzc0XSAtLS0tLS0tLS0tLS1b
IGN1dCBoZXJlIF0tLS0tLS0tLS0tLS0KWyAgIDMxLjUwMDk3N10gV0FSTklORzogQ1BVOiAx
IFBJRDogMSBhdCAva2J1aWxkL3NyYy9zbW9rZS9uZXQvYmF0bWFuLWFkdi9oYXJkLWludGVy
ZmFjZS5jOjkyIGJhdGFkdl9pc19vbl9iYXRtYW5faWZhY2UrMHg2Mi8weDcwKCkKL2tlcm5l
bC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvODQyMzkwOTM5ZThkYzE4ZmU4YTg3ZTI1
N2U3ZTgwODg1NDhiZDhkNy9kbWVzZy15b2N0by1mMi0zNDoyMDE0MDUyMTE3MTg1MDppMzg2
LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS13bC0wMjU5MC1nODQyMzkwOToz
OAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC84NDIzOTA5MzllOGRjMThm
ZThhODdlMjU3ZTdlODA4ODU0OGJkOGQ3L2RtZXNnLXlvY3RvLWYzLTk5OjIwMTQwNTIxMTY1
MDU4OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LXdsLTAyNTkwLWc4
NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzg0MjM5MDkz
OWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4ZDcvZG1lc2cteW9jdG8tZjEtMTIyOjIw
MTQwNTIxMTY1MTA5OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LXds
LTAyNTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMw
Lzg0MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4ZDcvZG1lc2ctcXVhbnRh
bC1mMS0xMTQ6MjAxNDA1MjExNzE4Mjc6aTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwOjMu
MTUuMC1yYzUtd2wtMDI1OTAtZzg0MjM5MDk6MzgKL2tlcm5lbC9pMzg2LXJhbmRjb25maWct
YzAtMDUyMTE2MzAvODQyMzkwOTM5ZThkYzE4ZmU4YTg3ZTI1N2U3ZTgwODg1NDhiZDhkNy9k
bWVzZy1xdWFudGFsLWYxLTMxOjIwMTQwNTIxMTcxODI5OmkzODYtcmFuZGNvbmZpZy1jMC0w
NTIxMTYzMDozLjE1LjAtcmM1LXdsLTAyNTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1y
YW5kY29uZmlnLWMwLTA1MjExNjMwLzg0MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4
NTQ4YmQ4ZDcvZG1lc2ctcXVhbnRhbC1mMy01NjoyMDE0MDUyMTE3MTgyMzppMzg2LXJhbmRj
b25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS13bC0wMjU5MC1nODQyMzkwOTozOAova2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC84NDIzOTA5MzllOGRjMThmZThhODdl
MjU3ZTdlODA4ODU0OGJkOGQ3L2RtZXNnLXlvY3RvLWYzLTEyNToyMDE0MDUyMTE3MTgzNTpp
Mzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS13bC0wMjU5MC1nODQyMzkw
OTozOAova2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC84NDIzOTA5MzllOGRj
MThmZThhODdlMjU3ZTdlODA4ODU0OGJkOGQ3L2RtZXNnLXF1YW50YWwtZjItMTI3OjIwMTQw
NTIxMTcxODQwOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LXdsLTAy
NTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzg0
MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4ZDcvZG1lc2cteW9jdG8tZjEt
MTI1OjIwMTQwNTIxMTcxODQ2OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAt
cmM1LXdsLTAyNTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1yYW5kY29uZmlnLWMwLTA1
MjExNjMwLzg0MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4ZDcvZG1lc2ct
eW9jdG8tZjQtMTE4OjIwMTQwNTIxMTcxODQwOmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYz
MDozLjE1LjAtcmM1LXdsLTAyNTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4Ni1yYW5kY29u
ZmlnLWMwLTA1MjExNjMwLzg0MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4MDg4NTQ4YmQ4
ZDcvZG1lc2cteW9jdG8tZjMtMTE2OjIwMTQwNTIxMTY1MDU4OmkzODYtcmFuZGNvbmZpZy1j
MC0wNTIxMTYzMDozLjE1LjAtcmM1LXdsLTAyNTkwLWc4NDIzOTA5OjM4Ci9rZXJuZWwvaTM4
Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLzg0MjM5MDkzOWU4ZGMxOGZlOGE4N2UyNTdlN2U4
MDg4NTQ4YmQ4ZDcvZG1lc2ctcXVhbnRhbC1mMy0yMDoyMDE0MDUyMTE3MTgyMTppMzg2LXJh
bmRjb25maWctYzAtMDUyMTE2MzA6My4xNS4wLXJjNS13bC0wMjU5MC1nODQyMzkwOTozOAov
a2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC84NDIzOTA5MzllOGRjMThmZThh
ODdlMjU3ZTdlODA4ODU0OGJkOGQ3L2RtZXNnLXlvY3RvLWYxLTMwOjIwMTQwNTIxMTcxODM3
OmkzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMDozLjE1LjAtcmM1LXdsLTAyNTkwLWc4NDIz
OTA5OjM4CjA6MTM6MTMgYWxsX2dvb2Q6YmFkOmFsbF9iYWQgYm9vdHMKCkhFQUQgaXMgbm93
IGF0IDg0MjM5MDkgMGRheSBoZWFkIGd1YXJkIGZvciAnZGV2ZWwtaG91cmx5LTIwMTQwNTIx
MTUnCgo9PT09PT09PT0gdXBzdHJlYW0gPT09PT09PT09CkZyb20gZ2l0Oi8vZ2l0bWlycm9y
L2xpbnVzCiAgIDYwYjVmOTAuLjRiNjYwYTcgIG1hc3RlciAgICAgLT4gbGludXMvbWFzdGVy
CkZyb20gZ2l0Oi8vZ2l0bWlycm9yL2xpbnVzCiAqIFtuZXcgdGFnXSAgICAgICAgIHYzLjE1
LXJjNiAgLT4gdjMuMTUtcmM2ClByZXZpb3VzIEhFQUQgcG9zaXRpb24gd2FzIDg0MjM5MDku
Li4gMGRheSBoZWFkIGd1YXJkIGZvciAnZGV2ZWwtaG91cmx5LTIwMTQwNTIxMTUnCkhFQUQg
aXMgbm93IGF0IDRiNjYwYTcuLi4gTGludXggMy4xNS1yYzYKbHMgLWEgL2tidWlsZC10ZXN0
cy9ydW4tcXVldWUva3ZtL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC9saW51czptYXN0
ZXI6NGI2NjBhN2Y1YzgwOTlkODhkMWE0M2Q4YWUxMzg5NjUxMTI1OTJjNzpiaXNlY3QtbGlu
dXg4CgoyMDE0LTA1LTIyLTA4OjU2OjM3IDRiNjYwYTdmNWM4MDk5ZDg4ZDFhNDNkOGFlMTM4
OTY1MTEyNTkyYzcgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0YXNrIHRvIC9rYnVpbGQtdGVz
dHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1MjExNjMwLTRiNjYwYTdmNWM4
MDk5ZDg4ZDFhNDNkOGFlMTM4OTY1MTEyNTkyYzcKQ2hlY2sgZm9yIGtlcm5lbCBpbiAva2Vy
bmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC80YjY2MGE3ZjVjODA5OWQ4OGQxYTQz
ZDhhZTEzODk2NTExMjU5MmM3CndhaXRpbmcgZm9yIGNvbXBsZXRpb24gb2YgL2tidWlsZC10
ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAtNGI2NjBhN2Y1
YzgwOTlkODhkMWE0M2Q4YWUxMzg5NjUxMTI1OTJjNwp3YWl0aW5nIGZvciBjb21wbGV0aW9u
IG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYtcmFuZGNvbmZpZy1jMC0wNTIx
MTYzMC00YjY2MGE3ZjVjODA5OWQ4OGQxYTQzZDhhZTEzODk2NTExMjU5MmM3Cmtlcm5lbDog
L2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAvNGI2NjBhN2Y1YzgwOTlkODhk
MWE0M2Q4YWUxMzg5NjUxMTI1OTJjNy92bWxpbnV6LTMuMTUuMC1yYzYKCjIwMTQtMDUtMjIt
MDk6NTY6MzggZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgLi4uCTQ2CTYwIFNVQ0NFU1MKCgo9PT09
PT09PT0gbGludXgtbmV4dCA9PT09PT09PT0KRnJvbSBnaXQ6Ly9naXRtaXJyb3IvbmV4dAog
KyA2MWY4YjM4Li4uMWU4MzZmMyBha3BtICAgICAgIC0+IG5leHQvYWtwbSAgKGZvcmNlZCB1
cGRhdGUpCiArIDAwNTM4MWUuLi5iOTZiYTE5IGFrcG0tYmFzZSAgLT4gbmV4dC9ha3BtLWJh
c2UgIChmb3JjZWQgdXBkYXRlKQogKyBiMmZlZjBkLi4uMThlMDcyOSBtYXN0ZXIgICAgIC0+
IG5leHQvbWFzdGVyICAoZm9yY2VkIHVwZGF0ZSkKICAgMTQxODZmZS4uNjBiNWY5MCAgc3Rh
YmxlICAgICAtPiBuZXh0L3N0YWJsZQpGcm9tIGdpdDovL2dpdG1pcnJvci9uZXh0CiAqIFtu
ZXcgdGFnXSAgICAgICAgIG5leHQtMjAxNDA1MTYgLT4gbmV4dC0yMDE0MDUxNgogKiBbbmV3
IHRhZ10gICAgICAgICBuZXh0LTIwMTQwNTE5IC0+IG5leHQtMjAxNDA1MTkKICogW25ldyB0
YWddICAgICAgICAgbmV4dC0yMDE0MDUyMCAtPiBuZXh0LTIwMTQwNTIwCiAqIFtuZXcgdGFn
XSAgICAgICAgIG5leHQtMjAxNDA1MjEgLT4gbmV4dC0yMDE0MDUyMQpQcmV2aW91cyBIRUFE
IHBvc2l0aW9uIHdhcyA0YjY2MGE3Li4uIExpbnV4IDMuMTUtcmM2CkhFQUQgaXMgbm93IGF0
IDE4ZTA3MjkuLi4gQWRkIGxpbnV4LW5leHQgc3BlY2lmaWMgZmlsZXMgZm9yIDIwMTQwNTIx
CmxzIC1hIC9rYnVpbGQtdGVzdHMvcnVuLXF1ZXVlL2t2bS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAvbmV4dDptYXN0ZXI6MThlMDcyOTk4YzY3ZTk4NWFhYTY0M2NhMWFmM2U2YTBk
YzEzM2I3MTpiaXNlY3QtbGludXg4CgoyMDE0LTA1LTIyLTA5OjU5OjU3IDE4ZTA3Mjk5OGM2
N2U5ODVhYWE2NDNjYTFhZjNlNmEwZGMxMzNiNzEgY29tcGlsaW5nClF1ZXVlZCBidWlsZCB0
YXNrIHRvIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvaTM4Ni1yYW5kY29uZmlnLWMwLTA1
MjExNjMwLTE4ZTA3Mjk5OGM2N2U5ODVhYWE2NDNjYTFhZjNlNmEwZGMxMzNiNzEKQ2hlY2sg
Zm9yIGtlcm5lbCBpbiAva2VybmVsL2kzODYtcmFuZGNvbmZpZy1jMC0wNTIxMTYzMC8xOGUw
NzI5OThjNjdlOTg1YWFhNjQzY2ExYWYzZTZhMGRjMTMzYjcxCndhaXRpbmcgZm9yIGNvbXBs
ZXRpb24gb2YgL2tidWlsZC10ZXN0cy9idWlsZC1xdWV1ZS9pMzg2LXJhbmRjb25maWctYzAt
MDUyMTE2MzAtMThlMDcyOTk4YzY3ZTk4NWFhYTY0M2NhMWFmM2U2YTBkYzEzM2I3MQp3YWl0
aW5nIGZvciBjb21wbGV0aW9uIG9mIC9rYnVpbGQtdGVzdHMvYnVpbGQtcXVldWUvLmkzODYt
cmFuZGNvbmZpZy1jMC0wNTIxMTYzMC0xOGUwNzI5OThjNjdlOTg1YWFhNjQzY2ExYWYzZTZh
MGRjMTMzYjcxCmtlcm5lbDogL2tlcm5lbC9pMzg2LXJhbmRjb25maWctYzAtMDUyMTE2MzAv
MThlMDcyOTk4YzY3ZTk4NWFhYTY0M2NhMWFmM2U2YTBkYzEzM2I3MS92bWxpbnV6LTMuMTUu
MC1yYzUtbmV4dC0yMDE0MDUyMQoKMjAxNC0wNS0yMi0xMTo0NTo1NyBkZXRlY3RpbmcgYm9v
dCBzdGF0ZSAuLgkxOQk1Ny4uLi4uLi4uLi4uCTU5CTYwIFNVQ0NFU1MKCg==
--------------090000010208030005040009
Content-Type: text/plain; charset=UTF-8;
 name="config-3.15.0-rc4-00068-g78ff4be"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="config-3.15.0-rc4-00068-g78ff4be"

#
# Automatically generated file; DO NOT EDIT.
# Linux/i386 3.15.0-rc4 Kernel Configuration
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
CONFIG_X86_32_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-ecx -fcall-saved-edx"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
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
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
CONFIG_KERNEL_LZO=y
# CONFIG_KERNEL_LZ4 is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
# CONFIG_SYSVIPC is not set
# CONFIG_POSIX_MQUEUE is not set
CONFIG_FHANDLE=y
CONFIG_USELIB=y
# CONFIG_AUDIT is not set
CONFIG_HAVE_ARCH_AUDITSYSCALL=y

#
# IRQ subsystem
#
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_PENDING_IRQ=y
CONFIG_GENERIC_IRQ_CHIP=y
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
CONFIG_GENERIC_TIME_VSYSCALL=y
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
CONFIG_TICK_CPU_ACCOUNTING=y
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
CONFIG_RCU_FANOUT=32
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
CONFIG_RCU_NOCB_CPU=y
# CONFIG_RCU_NOCB_CPU_NONE is not set
# CONFIG_RCU_NOCB_CPU_ZERO is not set
CONFIG_RCU_NOCB_CPU_ALL=y
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_CGROUPS is not set
CONFIG_CHECKPOINT_RESTORE=y
# CONFIG_NAMESPACES is not set
# CONFIG_SCHED_AUTOGROUP is not set
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
# CONFIG_RD_LZ4 is not set
# CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
CONFIG_HAVE_UID16=y
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
# CONFIG_UID16 is not set
# CONFIG_SYSFS_SYSCALL is not set
CONFIG_SYSCTL_SYSCALL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
# CONFIG_PCSPKR_PLATFORM is not set
# CONFIG_BASE_FULL is not set
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
# CONFIG_TIMERFD is not set
# CONFIG_EVENTFD is not set
CONFIG_SHMEM=y
CONFIG_AIO=y
CONFIG_PCI_QUIRKS=y
CONFIG_EMBEDDED=y
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_COMPAT_BRK=y
CONFIG_SLAB=y
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set
CONFIG_SYSTEM_TRUSTED_KEYRING=y
CONFIG_PROFILING=y
# CONFIG_OPROFILE is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
# CONFIG_UPROBES is not set
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
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
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CC_STACKPROTECTOR=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_CC_STACKPROTECTOR_NONE is not set
CONFIG_CC_STACKPROTECTOR_REGULAR=y
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
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=1
# CONFIG_MODULES is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_LBDAF=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set
CONFIG_BLK_CMDLINE_PARSER=y

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_AMIGA_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_EFI_PARTITION=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"
CONFIG_PADATA=y
CONFIG_ASN1=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
CONFIG_X86_BIGSMP=y
CONFIG_GOLDFISH=y
CONFIG_X86_EXTENDED_PLATFORM=y
CONFIG_X86_GOLDFISH=y
CONFIG_X86_INTEL_CE=y
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_X86_RDC321X is not set
# CONFIG_X86_32_NON_STANDARD is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_X86_32_IRIS=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_HYPERVISOR_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_DEBUG is not set
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_KVM_GUEST=y
# CONFIG_KVM_DEBUG_FS is not set
# CONFIG_LGUEST_GUEST is not set
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_PARAVIRT_CLOCK=y
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
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
CONFIG_HPET_EMULATE_RTC=y
# CONFIG_DMI is not set
CONFIG_NR_CPUS=32
# CONFIG_SCHED_SMT is not set
CONFIG_SCHED_MC=y
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
# CONFIG_X86_ANCIENT_MCE is not set
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
# CONFIG_VM86 is not set
CONFIG_TOSHIBA=y
CONFIG_I8K=y
CONFIG_X86_REBOOTFIXUPS=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_EARLY=y
# CONFIG_MICROCODE_AMD_EARLY is not set
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
# CONFIG_NOHIGHMEM is not set
CONFIG_HIGHMEM4G=y
# CONFIG_HIGHMEM64G is not set
# CONFIG_VMSPLIT_3G is not set
# CONFIG_VMSPLIT_3G_OPT is not set
# CONFIG_VMSPLIT_2G is not set
CONFIG_VMSPLIT_2G_OPT=y
# CONFIG_VMSPLIT_1G is not set
CONFIG_PAGE_OFFSET=0x78000000
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
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
# CONFIG_PHYS_ADDR_T_64BIT is not set
CONFIG_ZONE_DMA_FLAG=1
# CONFIG_BOUNCE is not set
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_MEMORY_FAILURE is not set
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS=y
# CONFIG_TRANSPARENT_HUGEPAGE_MADVISE is not set
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
CONFIG_CMA=y
CONFIG_CMA_DEBUG=y
# CONFIG_ZBUD is not set
# CONFIG_MEM_SOFT_DIRTY is not set
CONFIG_ZSMALLOC=y
CONFIG_PGTABLE_MAPPING=y
CONFIG_GENERIC_EARLY_IOREMAP=y
# CONFIG_HIGHPTE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MATH_EMULATION=y
# CONFIG_MTRR is not set
# CONFIG_ARCH_RANDOM is not set
CONFIG_X86_SMAP=y
# CONFIG_EFI is not set
CONFIG_SECCOMP=y
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
CONFIG_PHYSICAL_ALIGN=0x200000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
CONFIG_DEBUG_HOTPLUG_CPU0=y
CONFIG_COMPAT_VDSO=y
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_WQ_POWER_EFFICIENT_DEFAULT=y
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_HOTPLUG_CPU=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_CUSTOM_DSDT_FILE=""
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_REDUCED_HARDWARE_ONLY is not set
# CONFIG_ACPI_APEI is not set
# CONFIG_ACPI_EXTLOG is not set
# CONFIG_SFI is not set
CONFIG_X86_APM_BOOT=y
CONFIG_APM=y
# CONFIG_APM_IGNORE_USER_SUSPEND is not set
# CONFIG_APM_DO_ENABLE is not set
# CONFIG_APM_CPU_IDLE is not set
# CONFIG_APM_DISPLAY_BLANK is not set
# CONFIG_APM_ALLOW_INTS is not set

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
CONFIG_PCI_GODIRECT=y
# CONFIG_PCI_GOANY is not set
CONFIG_PCI_DIRECT=y
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
# CONFIG_PCIEPORTBUS is not set
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
CONFIG_PCI_REALLOC_ENABLE_AUTO=y
CONFIG_PCI_STUB=y
CONFIG_HT_IRQ=y
CONFIG_PCI_ATS=y
# CONFIG_PCI_IOV is not set
CONFIG_PCI_PRI=y
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
CONFIG_PCI_LABEL=y

#
# PCI host controller drivers
#
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
CONFIG_SCx200=y
CONFIG_SCx200HR_TIMER=y
# CONFIG_OLPC is not set
# CONFIG_ALIX is not set
CONFIG_NET5501=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
# CONFIG_PCMCIA is not set
CONFIG_CARDBUS=y

#
# PC-card bridges
#
# CONFIG_YENTA is not set
# CONFIG_HOTPLUG_PCI is not set
CONFIG_RAPIDIO=y
CONFIG_RAPIDIO_DISC_TIMEOUT=30
# CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS is not set
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y

#
# RapidIO Switch drivers
#
# CONFIG_RAPIDIO_TSI57X is not set
# CONFIG_RAPIDIO_CPS_XX is not set
CONFIG_RAPIDIO_TSI568=y
CONFIG_RAPIDIO_CPS_GEN2=y
# CONFIG_X86_SYSFB is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
CONFIG_BINFMT_SCRIPT=y
CONFIG_HAVE_AOUT=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set
CONFIG_COREDUMP=y
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
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
# CONFIG_XFRM_MIGRATE is not set
# CONFIG_XFRM_STATISTICS is not set
# CONFIG_NET_KEY is not set
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
# CONFIG_IP_ADVANCED_ROUTER is not set
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
# CONFIG_IP_PNP_DHCP is not set
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
# CONFIG_INET_IPCOMP is not set
# CONFIG_INET_XFRM_TUNNEL is not set
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
# CONFIG_INET_XFRM_MODE_TUNNEL is not set
# CONFIG_INET_XFRM_MODE_BEET is not set
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
CONFIG_INET_UDP_DIAG=y
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
# CONFIG_TCP_CONG_CUBIC is not set
# CONFIG_TCP_CONG_WESTWOOD is not set
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
# CONFIG_TCP_CONG_SCALABLE is not set
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_HTCP=y
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="htcp"
# CONFIG_TCP_MD5SIG is not set
# CONFIG_IPV6 is not set
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
CONFIG_NET_PTP_CLASSIFY=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
# CONFIG_BRIDGE_NETFILTER is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
CONFIG_NETFILTER_NETLINK_ACCT=y
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
# CONFIG_NF_CONNTRACK_ZONES is not set
CONFIG_NF_CONNTRACK_PROCFS=y
# CONFIG_NF_CONNTRACK_EVENTS is not set
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
# CONFIG_NF_CONNTRACK_AMANDA is not set
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
# CONFIG_NF_CONNTRACK_SNMP is not set
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
# CONFIG_NF_CONNTRACK_TFTP is not set
CONFIG_NF_CT_NETLINK=y
CONFIG_NF_CT_NETLINK_TIMEOUT=y
# CONFIG_NF_CT_NETLINK_HELPER is not set
CONFIG_NETFILTER_NETLINK_QUEUE_CT=y
CONFIG_NETFILTER_SYNPROXY=y
# CONFIG_NF_TABLES is not set
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_HMARK=y
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
# CONFIG_NETFILTER_XT_TARGET_NFQUEUE is not set
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
# CONFIG_NETFILTER_XT_TARGET_TEE is not set
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_BPF=y
# CONFIG_NETFILTER_XT_MATCH_CLUSTER is not set
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
# CONFIG_NETFILTER_XT_MATCH_CONNBYTES is not set
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
# CONFIG_NETFILTER_XT_MATCH_DSCP is not set
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
# CONFIG_NETFILTER_XT_MATCH_HELPER is not set
CONFIG_NETFILTER_XT_MATCH_HL=y
# CONFIG_NETFILTER_XT_MATCH_IPCOMP is not set
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
CONFIG_NETFILTER_XT_MATCH_L2TP=y
# CONFIG_NETFILTER_XT_MATCH_LENGTH is not set
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
# CONFIG_NETFILTER_XT_MATCH_MARK is not set
# CONFIG_NETFILTER_XT_MATCH_MULTIPORT is not set
CONFIG_NETFILTER_XT_MATCH_NFACCT=y
# CONFIG_NETFILTER_XT_MATCH_OSF is not set
# CONFIG_NETFILTER_XT_MATCH_OWNER is not set
CONFIG_NETFILTER_XT_MATCH_POLICY=y
# CONFIG_NETFILTER_XT_MATCH_PKTTYPE is not set
# CONFIG_NETFILTER_XT_MATCH_QUOTA is not set
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
# CONFIG_NETFILTER_XT_MATCH_REALM is not set
# CONFIG_NETFILTER_XT_MATCH_RECENT is not set
# CONFIG_NETFILTER_XT_MATCH_SCTP is not set
# CONFIG_NETFILTER_XT_MATCH_SOCKET is not set
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
# CONFIG_NETFILTER_XT_MATCH_STRING is not set
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
# CONFIG_NETFILTER_XT_MATCH_TIME is not set
CONFIG_NETFILTER_XT_MATCH_U32=y
# CONFIG_IP_SET is not set
CONFIG_IP_VS=y
CONFIG_IP_VS_DEBUG=y
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
# CONFIG_IP_VS_PROTO_AH_ESP is not set
# CONFIG_IP_VS_PROTO_ESP is not set
# CONFIG_IP_VS_PROTO_AH is not set
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
# CONFIG_IP_VS_RR is not set
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
# CONFIG_IP_VS_LBLC is not set
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
# CONFIG_IP_VS_NQ is not set

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
# CONFIG_IP_VS_NFCT is not set
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
# CONFIG_NF_DEFRAG_IPV4 is not set
# CONFIG_NF_CONNTRACK_IPV4 is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_RPFILTER=y
# CONFIG_IP_NF_MATCH_TTL is not set
CONFIG_IP_NF_FILTER=y
# CONFIG_IP_NF_TARGET_REJECT is not set
CONFIG_IP_NF_TARGET_SYNPROXY=y
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_IP_NF_MANGLE is not set
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_SECURITY=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
# CONFIG_BRIDGE_EBT_T_NAT is not set
CONFIG_BRIDGE_EBT_802_3=y
# CONFIG_BRIDGE_EBT_AMONG is not set
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
# CONFIG_BRIDGE_EBT_PKTTYPE is not set
CONFIG_BRIDGE_EBT_STP=y
CONFIG_BRIDGE_EBT_VLAN=y
CONFIG_BRIDGE_EBT_ARPREPLY=y
CONFIG_BRIDGE_EBT_DNAT=y
CONFIG_BRIDGE_EBT_MARK_T=y
CONFIG_BRIDGE_EBT_REDIRECT=y
CONFIG_BRIDGE_EBT_SNAT=y
CONFIG_BRIDGE_EBT_LOG=y
CONFIG_BRIDGE_EBT_ULOG=y
CONFIG_BRIDGE_EBT_NFLOG=y
CONFIG_IP_DCCP=y
CONFIG_INET_DCCP_DIAG=y

#
# DCCP CCIDs Configuration
#
# CONFIG_IP_DCCP_CCID2_DEBUG is not set
CONFIG_IP_DCCP_CCID3=y
# CONFIG_IP_DCCP_CCID3_DEBUG is not set
CONFIG_IP_DCCP_TFRC_LIB=y

#
# DCCP Kernel Hacking
#
# CONFIG_IP_DCCP_DEBUG is not set
CONFIG_IP_SCTP=y
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
CONFIG_SCTP_COOKIE_HMAC_SHA1=y
# CONFIG_RDS is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
# CONFIG_TIPC_MEDIA_IB is not set
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=y
# CONFIG_ATM_MPOA is not set
# CONFIG_ATM_BR2684 is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
CONFIG_STP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
CONFIG_HAVE_NET_DSA=y
CONFIG_NET_DSA=y
CONFIG_NET_DSA_TAG_DSA=y
CONFIG_NET_DSA_TAG_EDSA=y
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
CONFIG_LLC=y
CONFIG_LLC2=y
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
CONFIG_X25=y
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
CONFIG_NET_SCHED=y

#
# Queueing/Scheduling
#
CONFIG_NET_SCH_CBQ=y
CONFIG_NET_SCH_HTB=y
CONFIG_NET_SCH_HFSC=y
CONFIG_NET_SCH_ATM=y
CONFIG_NET_SCH_PRIO=y
CONFIG_NET_SCH_MULTIQ=y
CONFIG_NET_SCH_RED=y
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
# CONFIG_NET_SCH_TEQL is not set
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
# CONFIG_NET_SCH_NETEM is not set
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
CONFIG_NET_SCH_CODEL=y
CONFIG_NET_SCH_FQ_CODEL=y
# CONFIG_NET_SCH_FQ is not set
CONFIG_NET_SCH_HHF=y
# CONFIG_NET_SCH_PIE is not set
# CONFIG_NET_SCH_PLUG is not set

#
# Classification
#
CONFIG_NET_CLS=y
CONFIG_NET_CLS_BASIC=y
CONFIG_NET_CLS_TCINDEX=y
CONFIG_NET_CLS_ROUTE4=y
CONFIG_NET_CLS_FW=y
CONFIG_NET_CLS_U32=y
# CONFIG_CLS_U32_PERF is not set
# CONFIG_CLS_U32_MARK is not set
# CONFIG_NET_CLS_RSVP is not set
# CONFIG_NET_CLS_RSVP6 is not set
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_BPF=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
# CONFIG_NET_EMATCH_NBYTE is not set
CONFIG_NET_EMATCH_U32=y
# CONFIG_NET_EMATCH_META is not set
CONFIG_NET_EMATCH_TEXT=y
# CONFIG_NET_EMATCH_CANID is not set
# CONFIG_NET_CLS_ACT is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
# CONFIG_BATMAN_ADV_BLA is not set
# CONFIG_BATMAN_ADV_DAT is not set
CONFIG_BATMAN_ADV_NC=y
CONFIG_BATMAN_ADV_MCAST=y
CONFIG_BATMAN_ADV_DEBUG=y
CONFIG_OPENVSWITCH=y
# CONFIG_OPENVSWITCH_GRE is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
CONFIG_NETLINK_DIAG=y
CONFIG_NET_MPLS_GSO=y
# CONFIG_HSR is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
CONFIG_NET_RX_BUSY_POLL=y
CONFIG_BQL=y
CONFIG_NET_FLOW_LIMIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
CONFIG_HAMRADIO=y

#
# Packet Radio protocols
#
CONFIG_AX25=y
# CONFIG_AX25_DAMA_SLAVE is not set
CONFIG_NETROM=y
CONFIG_ROSE=y

#
# AX.25 network device drivers
#
# CONFIG_MKISS is not set
# CONFIG_6PACK is not set
# CONFIG_BPQETHER is not set
CONFIG_BAYCOM_SER_FDX=y
# CONFIG_BAYCOM_SER_HDX is not set
# CONFIG_YAM is not set
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
# CONFIG_CAN_VCAN is not set
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
# CONFIG_CAN_CALC_BITTIMING is not set
# CONFIG_CAN_LEDS is not set
# CONFIG_CAN_JANZ_ICAN3 is not set
CONFIG_PCH_CAN=y
CONFIG_CAN_GRCAN=y
CONFIG_CAN_SJA1000=y
CONFIG_CAN_SJA1000_ISA=y
CONFIG_CAN_SJA1000_PLATFORM=y
CONFIG_CAN_EMS_PCI=y
CONFIG_CAN_PEAK_PCI=y
# CONFIG_CAN_PEAK_PCIEC is not set
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
# CONFIG_CAN_ESD_USB2 is not set
CONFIG_CAN_KVASER_USB=y
CONFIG_CAN_PEAK_USB=y
CONFIG_CAN_8DEV_USB=y
CONFIG_CAN_SOFTING=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
# CONFIG_IRCOMM is not set
CONFIG_IRDA_ULTRA=y

#
# IrDA options
#
CONFIG_IRDA_CACHE_LAST_LSAP=y
CONFIG_IRDA_FAST_RR=y
CONFIG_IRDA_DEBUG=y

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
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
# CONFIG_KS959_DONGLE is not set

#
# FIR device drivers
#
CONFIG_USB_IRDA=y
CONFIG_SIGMATEL_FIR=y
# CONFIG_NSC_FIR is not set
# CONFIG_WINBOND_FIR is not set
# CONFIG_TOSHIBA_FIR is not set
CONFIG_SMC_IRCC_FIR=y
# CONFIG_ALI_FIR is not set
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_MCS_FIR=y
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
# CONFIG_BT_RFCOMM_TTY is not set
CONFIG_BT_BNEP=y
# CONFIG_BT_BNEP_MC_FILTER is not set
# CONFIG_BT_BNEP_PROTO_FILTER is not set
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
# CONFIG_BT_HCIBTSDIO is not set
# CONFIG_BT_HCIUART is not set
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
# CONFIG_BT_ATH3K is not set
CONFIG_AF_RXRPC=y
CONFIG_AF_RXRPC_DEBUG=y
# CONFIG_RXKAD is not set
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
CONFIG_NL80211_TESTMODE=y
CONFIG_CFG80211_DEVELOPER_WARNINGS=y
CONFIG_CFG80211_REG_DEBUG=y
# CONFIG_CFG80211_CERTIFICATION_ONUS is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
# CONFIG_CFG80211_WEXT is not set
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
CONFIG_LIB80211_DEBUG=y
# CONFIG_MAC80211 is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
# CONFIG_NET_9P_RDMA is not set
CONFIG_NET_9P_DEBUG=y
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
CONFIG_NFC=y
# CONFIG_NFC_DIGITAL is not set
CONFIG_NFC_NCI=y
CONFIG_NFC_HCI=y
# CONFIG_NFC_SHDLC is not set

#
# Near Field Communication (NFC) devices
#
# CONFIG_NFC_PN533 is not set
# CONFIG_NFC_MEI_PHY is not set
# CONFIG_NFC_SIM is not set
# CONFIG_NFC_PN544 is not set
CONFIG_NFC_MICROREAD=y
CONFIG_NFC_MRVL=y
CONFIG_NFC_MRVL_USB=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
# CONFIG_DEVTMPFS is not set
# CONFIG_STANDALONE is not set
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
CONFIG_FW_LOADER=y
CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_GENERIC_CPU_AUTOPROBE=y
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
CONFIG_DMA_SHARED_BUFFER=y
# CONFIG_DMA_CMA is not set

#
# Bus devices
#
CONFIG_CONNECTOR=y
# CONFIG_PROC_EVENTS is not set
CONFIG_MTD=y
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED=y
CONFIG_MTD_REDBOOT_PARTS_READONLY=y
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_OF_PARTS=y
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
# CONFIG_INFTL is not set
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
CONFIG_SM_FTL=y
CONFIG_MTD_OOPS=y

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
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
# CONFIG_MTD_PHYSMAP is not set
# CONFIG_MTD_PHYSMAP_OF is not set
# CONFIG_MTD_SC520CDP is not set
# CONFIG_MTD_NETSC520 is not set
# CONFIG_MTD_TS5500 is not set
CONFIG_MTD_SBC_GXX=y
CONFIG_MTD_SCx200_DOCFLASH=y
CONFIG_MTD_AMD76XROM=y
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
# CONFIG_MTD_PCI is not set
CONFIG_MTD_GPIO_ADDR=y
CONFIG_MTD_INTEL_VR_NOR=y
# CONFIG_MTD_PLATRAM is not set
CONFIG_MTD_LATCH_ADDR=y

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
CONFIG_MTD_BLOCK2MTD=y

#
# Disk-On-Chip Device Drivers
#
CONFIG_MTD_DOCG3=y
CONFIG_BCH_CONST_M=14
CONFIG_BCH_CONST_T=4
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
# CONFIG_MTD_NAND is not set
CONFIG_MTD_ONENAND=y
# CONFIG_MTD_ONENAND_VERIFY_WRITE is not set
CONFIG_MTD_ONENAND_GENERIC=y
CONFIG_MTD_ONENAND_OTP=y
# CONFIG_MTD_ONENAND_2X_PROGRAM is not set

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
# CONFIG_MTD_UBI is not set
CONFIG_DTC=y
CONFIG_OF=y

#
# Device Tree and Open Firmware support
#
# CONFIG_OF_SELFTEST is not set
CONFIG_OF_FLATTREE=y
CONFIG_OF_EARLY_FLATTREE=y
CONFIG_OF_ADDRESS=y
CONFIG_OF_ADDRESS_PCI=y
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
# CONFIG_ZRAM is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
# CONFIG_BLK_DEV_UMEM is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
CONFIG_BLK_DEV_CRYPTOLOOP=y
CONFIG_BLK_DEV_DRBD=y
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
# CONFIG_BLK_DEV_OSD is not set
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_XIP=y
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
# CONFIG_VIRTIO_BLK is not set
CONFIG_BLK_DEV_HD=y
CONFIG_BLK_DEV_RBD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
# CONFIG_AD525X_DPOT is not set
# CONFIG_DUMMY_IRQ is not set
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
CONFIG_ATMEL_SSC=y
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
# CONFIG_HP_ILO is not set
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
# CONFIG_VMWARE_BALLOON is not set
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
# CONFIG_PCH_PHUB is not set
CONFIG_USB_SWITCH_FSA9480=y
CONFIG_SRAM=y
CONFIG_C2PORT=y
# CONFIG_C2PORT_DURAMAR_2150 is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_LEGACY=y
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
# CONFIG_CB710_CORE is not set

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
CONFIG_INTEL_MEI_TXE=y
# CONFIG_VMWARE_VMCI is not set

#
# Intel MIC Host Driver
#

#
# Intel MIC Card Driver
#
CONFIG_ECHO=y
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
CONFIG_SCSI_PROC_FS=y

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
# CONFIG_CHR_DEV_ST is not set
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
# CONFIG_CHR_DEV_SG is not set
CONFIG_CHR_DEV_SCH=y
# CONFIG_SCSI_MULTI_LUN is not set
# CONFIG_SCSI_CONSTANTS is not set
CONFIG_SCSI_LOGGING=y
# CONFIG_SCSI_SCAN_ASYNC is not set

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
# CONFIG_SCSI_FC_TGT_ATTRS is not set
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_SRP_TGT_ATTRS is not set
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
# CONFIG_SCSI_DH_HP_SW is not set
# CONFIG_SCSI_DH_EMC is not set
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
CONFIG_AHCI_IMX=y
CONFIG_SATA_INIC162X=y
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
# CONFIG_ATA_SFF is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
# CONFIG_MD_AUTODETECT is not set
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
CONFIG_BCACHE_DEBUG=y
CONFIG_BCACHE_CLOSURES_DEBUG=y
CONFIG_BLK_DEV_DM_BUILTIN=y
CONFIG_BLK_DEV_DM=y
CONFIG_DM_DEBUG=y
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_CACHE=y
CONFIG_DM_CACHE_MQ=y
CONFIG_DM_CACHE_CLEANER=y
CONFIG_DM_ERA=y
CONFIG_DM_MIRROR=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_RAID=y
CONFIG_DM_ZERO=y
# CONFIG_DM_MULTIPATH is not set
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=y
CONFIG_DM_VERITY=y
CONFIG_DM_SWITCH=y
# CONFIG_TARGET_CORE is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
# CONFIG_FUSION_SAS is not set
CONFIG_FUSION_MAX_SGE=128
# CONFIG_FUSION_CTL is not set
CONFIG_FUSION_LOGGING=y

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
# CONFIG_FIREWIRE_OHCI is not set
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NET=y
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_CONFIG=y
# CONFIG_I2O_CONFIG_OLD_IOCTL is not set
# CONFIG_I2O_BUS is not set
CONFIG_I2O_BLOCK=y
# CONFIG_I2O_SCSI is not set
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_MII=y
# CONFIG_NET_CORE is not set
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
# CONFIG_ARCNET_1051 is not set
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
# CONFIG_ARCNET_COM90xx is not set
# CONFIG_ARCNET_COM90xxIO is not set
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
# CONFIG_ATM_TCP is not set
CONFIG_ATM_LANAI=y
CONFIG_ATM_ENI=y
CONFIG_ATM_ENI_DEBUG=y
CONFIG_ATM_ENI_TUNE_BURST=y
# CONFIG_ATM_ENI_BURST_TX_16W is not set
CONFIG_ATM_ENI_BURST_TX_8W=y
# CONFIG_ATM_ENI_BURST_TX_4W is not set
CONFIG_ATM_ENI_BURST_TX_2W=y
CONFIG_ATM_ENI_BURST_RX_16W=y
CONFIG_ATM_ENI_BURST_RX_8W=y
# CONFIG_ATM_ENI_BURST_RX_4W is not set
# CONFIG_ATM_ENI_BURST_RX_2W is not set
# CONFIG_ATM_FIRESTREAM is not set
CONFIG_ATM_ZATM=y
# CONFIG_ATM_ZATM_DEBUG is not set
CONFIG_ATM_NICSTAR=y
CONFIG_ATM_NICSTAR_USE_SUNI=y
# CONFIG_ATM_NICSTAR_USE_IDT77105 is not set
CONFIG_ATM_IDT77252=y
CONFIG_ATM_IDT77252_DEBUG=y
CONFIG_ATM_IDT77252_RCV_ALL=y
CONFIG_ATM_IDT77252_USE_SUNI=y
# CONFIG_ATM_AMBASSADOR is not set
CONFIG_ATM_HORIZON=y
CONFIG_ATM_HORIZON_DEBUG=y
CONFIG_ATM_IA=y
CONFIG_ATM_IA_DEBUG=y
# CONFIG_ATM_FORE200E is not set
CONFIG_ATM_HE=y
# CONFIG_ATM_HE_USE_SUNI is not set
CONFIG_ATM_SOLOS=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
CONFIG_NET_DSA_MV88E6XXX=y
# CONFIG_NET_DSA_MV88E6060 is not set
CONFIG_NET_DSA_MV88E6XXX_NEED_PPU=y
CONFIG_NET_DSA_MV88E6131=y
CONFIG_NET_DSA_MV88E6123_61_65=y
# CONFIG_ETHERNET is not set
# CONFIG_FDDI is not set
# CONFIG_HIPPI is not set
# CONFIG_NET_SB1000 is not set
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
CONFIG_AMD_PHY=y
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
# CONFIG_QSEMI_PHY is not set
# CONFIG_LXT_PHY is not set
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
# CONFIG_SMSC_PHY is not set
CONFIG_BROADCOM_PHY=y
CONFIG_BCM7XXX_PHY=y
CONFIG_BCM87XX_PHY=y
# CONFIG_ICPLUS_PHY is not set
# CONFIG_REALTEK_PHY is not set
# CONFIG_NATIONAL_PHY is not set
# CONFIG_STE10XP is not set
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
CONFIG_FIXED_PHY=y
CONFIG_MDIO_BITBANG=y
CONFIG_MDIO_GPIO=y
CONFIG_MDIO_BUS_MUX=y
# CONFIG_MDIO_BUS_MUX_GPIO is not set
CONFIG_MDIO_BUS_MUX_MMIOREG=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
# CONFIG_PPP_FILTER is not set
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
# CONFIG_PPPOATM is not set
CONFIG_PPPOE=y
CONFIG_PPTP=y
CONFIG_PPPOL2TP=y
# CONFIG_PPP_ASYNC is not set
# CONFIG_PPP_SYNC_TTY is not set
# CONFIG_SLIP is not set
CONFIG_SLHC=y

#
# USB Network Adapters
#
# CONFIG_USB_CATC is not set
# CONFIG_USB_KAWETH is not set
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
# CONFIG_USB_RTL8152 is not set
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
# CONFIG_USB_NET_AX88179_178A is not set
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_HUAWEI_CDC_NCM is not set
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SR9700=y
CONFIG_USB_NET_SR9800=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
# CONFIG_USB_NET_GL620A is not set
CONFIG_USB_NET_NET1080=y
# CONFIG_USB_NET_PLUSB is not set
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
# CONFIG_USB_ALI_M5632 is not set
# CONFIG_USB_AN2720 is not set
# CONFIG_USB_BELKIN is not set
# CONFIG_USB_ARMLINUX is not set
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
# CONFIG_USB_NET_CX82310_ETH is not set
CONFIG_USB_NET_KALMIA=y
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
CONFIG_WLAN=y
CONFIG_AIRO=y
CONFIG_ATMEL=y
# CONFIG_PCI_ATMEL is not set
# CONFIG_PRISM54 is not set
# CONFIG_USB_ZD1201 is not set
CONFIG_USB_NET_RNDIS_WLAN=y
CONFIG_ATH_CARDS=y
CONFIG_ATH_DEBUG=y
# CONFIG_ATH5K_PCI is not set
CONFIG_ATH6KL=y
# CONFIG_ATH6KL_SDIO is not set
CONFIG_ATH6KL_USB=y
CONFIG_ATH6KL_DEBUG=y
# CONFIG_WIL6210 is not set
CONFIG_BRCMUTIL=y
CONFIG_BRCMFMAC=y
# CONFIG_BRCMFMAC_SDIO is not set
CONFIG_BRCMFMAC_USB=y
CONFIG_BRCM_TRACING=y
CONFIG_BRCMDBG=y
CONFIG_HOSTAP=y
# CONFIG_HOSTAP_FIRMWARE is not set
# CONFIG_HOSTAP_PLX is not set
CONFIG_HOSTAP_PCI=y
CONFIG_IPW2100=y
# CONFIG_IPW2100_MONITOR is not set
# CONFIG_IPW2100_DEBUG is not set
CONFIG_LIBIPW=y
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_LIBERTAS=y
# CONFIG_LIBERTAS_USB is not set
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_DEBUG=y
CONFIG_LIBERTAS_MESH=y
CONFIG_WL_TI=y
CONFIG_MWIFIEX=y
CONFIG_MWIFIEX_SDIO=y
CONFIG_MWIFIEX_PCIE=y
# CONFIG_MWIFIEX_USB is not set

#
# WiMAX Wireless Broadband devices
#
CONFIG_WIMAX_I2400M=y
CONFIG_WIMAX_I2400M_USB=y
CONFIG_WIMAX_I2400M_DEBUG_LEVEL=8
# CONFIG_WAN is not set
CONFIG_VMXNET3=y
# CONFIG_ISDN is not set

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
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
CONFIG_INPUT_EVBUG=y

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
CONFIG_KEYBOARD_QT1070=y
# CONFIG_KEYBOARD_QT2160 is not set
CONFIG_KEYBOARD_CLPS711X=y
# CONFIG_KEYBOARD_LKKBD is not set
CONFIG_KEYBOARD_GPIO=y
CONFIG_KEYBOARD_GPIO_POLLED=y
CONFIG_KEYBOARD_TCA6416=y
CONFIG_KEYBOARD_TCA8418=y
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
CONFIG_KEYBOARD_MCS=y
CONFIG_KEYBOARD_MPR121=y
CONFIG_KEYBOARD_NEWTON=y
# CONFIG_KEYBOARD_OPENCORES is not set
# CONFIG_KEYBOARD_GOLDFISH_EVENTS is not set
CONFIG_KEYBOARD_STOWAWAY=y
# CONFIG_KEYBOARD_SUNKBD is not set
CONFIG_KEYBOARD_SH_KEYSC=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_KEYBOARD_CROS_EC=y
# CONFIG_INPUT_MOUSE is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
# CONFIG_JOYSTICK_ADI is not set
# CONFIG_JOYSTICK_COBRA is not set
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
# CONFIG_JOYSTICK_TMDC is not set
# CONFIG_JOYSTICK_IFORCE is not set
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
# CONFIG_JOYSTICK_STINGER is not set
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_AS5011=y
CONFIG_JOYSTICK_JOYDUMP=y
# CONFIG_JOYSTICK_XPAD is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
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
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_SERIO_APBPS2=y
# CONFIG_SERIO_OLPC_APSP is not set
CONFIG_GAMEPORT=y
# CONFIG_GAMEPORT_NS558 is not set
CONFIG_GAMEPORT_L4=y
# CONFIG_GAMEPORT_EMU10K1 is not set
CONFIG_GAMEPORT_FM801=y

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
# CONFIG_GOLDFISH_TTY is not set
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
# CONFIG_SERIAL_UARTLITE is not set
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
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_GEODE=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_NVRAM=y
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y
# CONFIG_SONYPI is not set
# CONFIG_MWAVE is not set
CONFIG_SCx200_GPIO=y
# CONFIG_PC8736x_GPIO is not set
CONFIG_NSC_GPIO=y
# CONFIG_RAW_DRIVER is not set
# CONFIG_HPET is not set
CONFIG_HANGCHECK_TIMER=y
# CONFIG_TCG_TPM is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
# CONFIG_I2C_COMPAT is not set
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
CONFIG_I2C_ARB_GPIO_CHALLENGE=y
CONFIG_I2C_MUX_GPIO=y
CONFIG_I2C_MUX_PCA9541=y
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
# CONFIG_I2C_SMBUS is not set

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
CONFIG_I2C_ALI1535=y
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
# CONFIG_I2C_AMD756 is not set
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
# CONFIG_I2C_NFORCE2_S4985 is not set
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
CONFIG_I2C_DESIGNWARE_CORE=y
# CONFIG_I2C_DESIGNWARE_PLATFORM is not set
CONFIG_I2C_DESIGNWARE_PCI=y
CONFIG_I2C_EFM32=y
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
CONFIG_I2C_PXA=y
CONFIG_I2C_PXA_PCI=y
CONFIG_I2C_RIIC=y
CONFIG_I2C_SH_MOBILE=y
# CONFIG_I2C_SIMTEC is not set
# CONFIG_I2C_XILINX is not set
CONFIG_I2C_RCAR=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_DIOLAN_U2C is not set
# CONFIG_I2C_PARPORT_LIGHT is not set
# CONFIG_I2C_ROBOTFUZZ_OSIF is not set
# CONFIG_I2C_TAOS_EVM is not set
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_SCx200_I2C=y
CONFIG_SCx200_I2C_SCL=12
CONFIG_SCx200_I2C_SDA=13
CONFIG_SCx200_ACB=y
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set
CONFIG_SPMI=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set
# CONFIG_NTP_PPS is not set

#
# PPS clients support
#
CONFIG_PPS_CLIENT_KTIMER=y
# CONFIG_PPS_CLIENT_LDISC is not set
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
CONFIG_GPIOLIB=y
CONFIG_GPIO_DEVRES=y
CONFIG_OF_GPIO=y
CONFIG_GPIO_ACPI=y
CONFIG_DEBUG_GPIO=y
# CONFIG_GPIO_SYSFS is not set
CONFIG_GPIO_GENERIC=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_CLPS711X is not set
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_GPIO_DWAPB=y
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_F7188X is not set
CONFIG_GPIO_SCH311X=y
CONFIG_GPIO_SYSCON=y
CONFIG_GPIO_TS5500=y
CONFIG_GPIO_SCH=y
CONFIG_GPIO_ICH=y
CONFIG_GPIO_VX855=y
# CONFIG_GPIO_LYNXPOINT is not set
CONFIG_GPIO_GRGPIO=y

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
# CONFIG_GPIO_LP3943 is not set
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
CONFIG_GPIO_PCA953X=y
# CONFIG_GPIO_PCA953X_IRQ is not set
CONFIG_GPIO_PCF857X=y
CONFIG_GPIO_RC5T583=y
# CONFIG_GPIO_SX150X is not set
CONFIG_GPIO_TWL6040=y
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_ADP5588=y
CONFIG_GPIO_ADP5588_IRQ=y
# CONFIG_GPIO_ADNP is not set

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_AMD8111=y
# CONFIG_GPIO_INTEL_MID is not set
CONFIG_GPIO_PCH=y
# CONFIG_GPIO_ML_IOH is not set
# CONFIG_GPIO_SODAVILLE is not set
CONFIG_GPIO_TIMBERDALE=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#
CONFIG_GPIO_UCB1400=y

#
# LPC GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=y
# CONFIG_GPIO_TPS6586X is not set
# CONFIG_GPIO_TPS65910 is not set
# CONFIG_GPIO_BCM_KONA is not set

#
# USB GPIO expanders:
#
CONFIG_W1=y
# CONFIG_W1_CON is not set

#
# 1-wire Bus Masters
#
# CONFIG_W1_MASTER_MATROX is not set
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
CONFIG_W1_MASTER_MXC=y
CONFIG_W1_MASTER_DS1WM=y
CONFIG_W1_MASTER_GPIO=y

#
# 1-wire Slaves
#
CONFIG_W1_SLAVE_THERM=y
# CONFIG_W1_SLAVE_SMEM is not set
CONFIG_W1_SLAVE_DS2408=y
# CONFIG_W1_SLAVE_DS2408_READBACK is not set
CONFIG_W1_SLAVE_DS2413=y
# CONFIG_W1_SLAVE_DS2423 is not set
CONFIG_W1_SLAVE_DS2431=y
# CONFIG_W1_SLAVE_DS2433 is not set
CONFIG_W1_SLAVE_DS2760=y
CONFIG_W1_SLAVE_DS2780=y
# CONFIG_W1_SLAVE_DS2781 is not set
CONFIG_W1_SLAVE_DS28E04=y
# CONFIG_W1_SLAVE_BQ27000 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
CONFIG_GENERIC_ADC_BATTERY=y
CONFIG_MAX8925_POWER=y
CONFIG_WM831X_BACKUP=y
CONFIG_WM831X_POWER=y
CONFIG_TEST_POWER=y
CONFIG_BATTERY_88PM860X=y
CONFIG_BATTERY_DS2760=y
CONFIG_BATTERY_DS2780=y
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
CONFIG_BATTERY_SBS=y
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9030 is not set
CONFIG_BATTERY_MAX17040=y
CONFIG_BATTERY_MAX17042=y
CONFIG_CHARGER_88PM860X=y
# CONFIG_CHARGER_ISP1704 is not set
CONFIG_CHARGER_MAX8903=y
CONFIG_CHARGER_LP8727=y
CONFIG_CHARGER_GPIO=y
CONFIG_CHARGER_MANAGER=y
# CONFIG_CHARGER_MAX8998 is not set
CONFIG_CHARGER_BQ2415X=y
CONFIG_CHARGER_BQ24190=y
# CONFIG_CHARGER_BQ24735 is not set
CONFIG_CHARGER_SMB347=y
CONFIG_BATTERY_GOLDFISH=y
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADM1021=y
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
# CONFIG_SENSORS_ADM1029 is not set
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
# CONFIG_SENSORS_ADT7411 is not set
# CONFIG_SENSORS_ADT7462 is not set
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_APPLESMC=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
# CONFIG_SENSORS_DS1621 is not set
CONFIG_SENSORS_DA9055=y
CONFIG_SENSORS_I5K_AMB=y
# CONFIG_SENSORS_F71805F is not set
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_FSCHMD is not set
# CONFIG_SENSORS_GL518SM is not set
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_G762=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_CORETEMP is not set
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LTC2945=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4222=y
# CONFIG_SENSORS_LTC4245 is not set
# CONFIG_SENSORS_LTC4260 is not set
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_MAX16065=y
# CONFIG_SENSORS_MAX1619 is not set
# CONFIG_SENSORS_MAX1668 is not set
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
# CONFIG_SENSORS_MAX6650 is not set
CONFIG_SENSORS_MAX6697=y
# CONFIG_SENSORS_HTU21 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
# CONFIG_SENSORS_LM75 is not set
CONFIG_SENSORS_LM77=y
# CONFIG_SENSORS_LM78 is not set
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LM95234=y
# CONFIG_SENSORS_LM95241 is not set
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_NCT6775=y
# CONFIG_SENSORS_PCF8591 is not set
CONFIG_PMBUS=y
CONFIG_SENSORS_PMBUS=y
# CONFIG_SENSORS_ADM1275 is not set
# CONFIG_SENSORS_LM25066 is not set
# CONFIG_SENSORS_LTC2978 is not set
CONFIG_SENSORS_MAX16064=y
CONFIG_SENSORS_MAX34440=y
CONFIG_SENSORS_MAX8688=y
CONFIG_SENSORS_UCD9000=y
# CONFIG_SENSORS_UCD9200 is not set
# CONFIG_SENSORS_ZL6100 is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_DME1737 is not set
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
# CONFIG_SENSORS_EMC6W201 is not set
# CONFIG_SENSORS_SMSC47M1 is not set
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_ADC128D818=y
CONFIG_SENSORS_ADS1015=y
# CONFIG_SENSORS_ADS7828 is not set
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
CONFIG_SENSORS_INA2XX=y
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
# CONFIG_SENSORS_VIA_CPUTEMP is not set
# CONFIG_SENSORS_VIA686A is not set
CONFIG_SENSORS_VT1211=y
# CONFIG_SENSORS_VT8231 is not set
# CONFIG_SENSORS_W83781D is not set
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
# CONFIG_SENSORS_W83793 is not set
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
# CONFIG_SENSORS_W83L786NG is not set
# CONFIG_SENSORS_W83627HF is not set
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_WM831X=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_OF=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
CONFIG_THERMAL_GOV_USER_SPACE=y
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_RCAR_THERMAL is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_X86_PKG_TEMP_THERMAL=y
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
# CONFIG_DA9055_WATCHDOG is not set
CONFIG_GPIO_WATCHDOG=y
# CONFIG_WM831X_WATCHDOG is not set
CONFIG_XILINX_WATCHDOG=y
CONFIG_DW_WATCHDOG=y
CONFIG_TEGRA_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
# CONFIG_ALIM7101_WDT is not set
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
CONFIG_GEODE_WDT=y
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
CONFIG_IE6XX_WDT=y
# CONFIG_ITCO_WDT is not set
CONFIG_IT8712F_WDT=y
# CONFIG_IT87_WDT is not set
# CONFIG_HP_WATCHDOG is not set
CONFIG_SC1200_WDT=y
CONFIG_SCx200_WDT=y
# CONFIG_PC87413_WDT is not set
# CONFIG_NV_TCO is not set
# CONFIG_60XX_WDT is not set
# CONFIG_SBC8360_WDT is not set
# CONFIG_SBC7240_WDT is not set
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
CONFIG_VIA_WDT=y
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
# CONFIG_W83697UG_WDT is not set
# CONFIG_W83877F_WDT is not set
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
# CONFIG_SBC_EPX_C3_WATCHDOG is not set
CONFIG_MEN_A21_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

#
# USB-based Watchdog Cards
#
# CONFIG_USBPCWATCHDOG is not set
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
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_HOST_SOC=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
# CONFIG_MFD_AS3722 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_AAT2870_CORE is not set
CONFIG_MFD_BCM590XX=y
CONFIG_MFD_CROS_EC=y
CONFIG_MFD_CROS_EC_I2C=y
CONFIG_PMIC_DA903X=y
# CONFIG_MFD_DA9052_I2C is not set
CONFIG_MFD_DA9055=y
CONFIG_MFD_DA9063=y
# CONFIG_MFD_MC13XXX_I2C is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_KEMPLD is not set
CONFIG_MFD_88PM800=y
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
# CONFIG_MFD_MAX14577 is not set
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
# CONFIG_MFD_MAX8997 is not set
CONFIG_MFD_MAX8998=y
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_PCF50633 is not set
CONFIG_UCB1400_CORE=y
CONFIG_MFD_RDC321X=y
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RTSX_USB=y
CONFIG_MFD_RC5T583=y
CONFIG_MFD_SEC_CORE=y
CONFIG_MFD_SI476X_CORE=y
# CONFIG_MFD_SM501 is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_MFD_LP3943=y
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65090 is not set
CONFIG_MFD_TPS65217=y
# CONFIG_MFD_TPS65218 is not set
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
# CONFIG_MFD_TPS65912_I2C is not set
CONFIG_MFD_TPS80031=y
# CONFIG_TWL4030_CORE is not set
CONFIG_TWL6040_CORE=y
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_WM5102 is not set
CONFIG_MFD_WM5110=y
CONFIG_MFD_WM8997=y
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_DEBUG=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
CONFIG_REGULATOR_88PM800=y
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_ACT8865 is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ANATOP is not set
# CONFIG_REGULATOR_ARIZONA is not set
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_REGULATOR_BCM590XX=y
CONFIG_REGULATOR_DA903X=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_DA9063=y
# CONFIG_REGULATOR_DA9210 is not set
CONFIG_REGULATOR_FAN53555=y
CONFIG_REGULATOR_GPIO=y
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_LP3971 is not set
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
# CONFIG_REGULATOR_MAX8660 is not set
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_MAX8998=y
# CONFIG_REGULATOR_MAX77686 is not set
CONFIG_REGULATOR_MAX77693=y
CONFIG_REGULATOR_PBIAS=y
# CONFIG_REGULATOR_PFUZE100 is not set
# CONFIG_REGULATOR_RC5T583 is not set
# CONFIG_REGULATOR_S2MPA01 is not set
# CONFIG_REGULATOR_S2MPS11 is not set
CONFIG_REGULATOR_S5M8767=y
CONFIG_REGULATOR_TPS51632=y
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65217=y
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65910=y
# CONFIG_REGULATOR_TPS80031 is not set
# CONFIG_REGULATOR_WM831X is not set
# CONFIG_REGULATOR_WM8400 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEO_TUNER=y
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEOBUF_DVB=y
CONFIG_VIDEOBUF2_CORE=y
CONFIG_VIDEOBUF2_MEMOPS=y
CONFIG_VIDEOBUF2_DMA_CONTIG=y
CONFIG_VIDEOBUF2_VMALLOC=y
CONFIG_DVB_CORE=y
CONFIG_DVB_NET=y
CONFIG_TTPCI_EEPROM=y
CONFIG_DVB_MAX_ADAPTERS=8
CONFIG_DVB_DYNAMIC_MINORS=y

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture/analog TV support
#
# CONFIG_VIDEO_ZORAN is not set
CONFIG_VIDEO_HEXIUM_GEMINI=y
CONFIG_VIDEO_HEXIUM_ORION=y
CONFIG_VIDEO_MXB=y

#
# Media capture/analog/hybrid TV support
#
# CONFIG_VIDEO_CX25821 is not set
CONFIG_VIDEO_SAA7134=y
CONFIG_VIDEO_SAA7134_ALSA=y
CONFIG_VIDEO_SAA7134_DVB=y
# CONFIG_VIDEO_SAA7164 is not set

#
# Media digital TV PCI Adapters
#
CONFIG_DVB_AV7110=y
CONFIG_DVB_AV7110_OSD=y
CONFIG_DVB_BUDGET_CORE=y
# CONFIG_DVB_BUDGET is not set
CONFIG_DVB_BUDGET_AV=y
CONFIG_DVB_BUDGET_PATCH=y
# CONFIG_DVB_B2C2_FLEXCOP_PCI is not set
CONFIG_DVB_PLUTO2=y
# CONFIG_DVB_PT1 is not set
CONFIG_DVB_NGENE=y
CONFIG_DVB_DDBRIDGE=y

#
# Supported MMC/SDIO adapters
#
# CONFIG_SMS_SDIO_DRV is not set

#
# Supported FireWire (IEEE 1394) Adapters
#
CONFIG_DVB_FIREDTV=y
CONFIG_DVB_FIREDTV_INPUT=y
CONFIG_VIDEO_TVEEPROM=y
CONFIG_CYPRESS_FIRMWARE=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#
CONFIG_VIDEO_TDA9840=y
CONFIG_VIDEO_TEA6415C=y
CONFIG_VIDEO_TEA6420=y
CONFIG_VIDEO_UDA1342=y
CONFIG_VIDEO_SONY_BTF_MPX=y

#
# RDS decoders
#
CONFIG_VIDEO_SAA6588=y

#
# Video decoders
#
CONFIG_VIDEO_SAA711X=y
CONFIG_VIDEO_TW2804=y
CONFIG_VIDEO_TW9903=y
CONFIG_VIDEO_TW9906=y

#
# Video and audio decoders
#

#
# Video encoders
#

#
# Camera sensor devices
#
CONFIG_VIDEO_OV7640=y

#
# Flash devices
#

#
# Video improvement chips
#

#
# Audio/Video compression chips
#
CONFIG_VIDEO_SAA6752HS=y

#
# Miscellaneous helper chips
#

#
# Sensors used on soc_camera driver
#
CONFIG_MEDIA_TUNER=y
CONFIG_MEDIA_TUNER_SIMPLE=y
CONFIG_MEDIA_TUNER_TDA8290=y
CONFIG_MEDIA_TUNER_TDA827X=y
CONFIG_MEDIA_TUNER_TDA18271=y
CONFIG_MEDIA_TUNER_TDA9887=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_MT2131=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Multistandard (satellite) frontends
#
CONFIG_DVB_STB0899=y
CONFIG_DVB_STV090x=y
CONFIG_DVB_STV6110x=y

#
# Multistandard (cable + terrestrial) frontends
#
CONFIG_DVB_DRXK=y
CONFIG_DVB_TDA18271C2DD=y

#
# DVB-S (satellite) frontends
#
CONFIG_DVB_MT312=y
CONFIG_DVB_ZL10036=y
CONFIG_DVB_ZL10039=y
CONFIG_DVB_STV0299=y
CONFIG_DVB_TDA8083=y
CONFIG_DVB_TDA10086=y
CONFIG_DVB_TDA8261=y
CONFIG_DVB_VES1X93=y
CONFIG_DVB_TDA826X=y
CONFIG_DVB_TUA6100=y

#
# DVB-T (terrestrial) frontends
#
CONFIG_DVB_SP8870=y
CONFIG_DVB_L64781=y
CONFIG_DVB_TDA1004X=y
CONFIG_DVB_MT352=y
CONFIG_DVB_ZL10353=y
CONFIG_DVB_TDA10048=y

#
# DVB-C (cable) frontends
#
CONFIG_DVB_VES1820=y
CONFIG_DVB_TDA10021=y
CONFIG_DVB_TDA10023=y
CONFIG_DVB_STV0297=y

#
# ATSC (North American/Korean Terrestrial/Cable DTV) frontends
#
CONFIG_DVB_NXT200X=y
CONFIG_DVB_LGDT330X=y
CONFIG_DVB_LGDT3305=y

#
# ISDB-T (terrestrial) frontends
#

#
# Digital terrestrial only tuners/PLL
#
CONFIG_DVB_PLL=y

#
# SEC control devices for DVB-S
#
CONFIG_DVB_LNBP21=y
CONFIG_DVB_ISL6405=y
CONFIG_DVB_ISL6421=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_ALI=y
# CONFIG_AGP_ATI is not set
# CONFIG_AGP_AMD is not set
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_NVIDIA=y
CONFIG_AGP_SIS=y
CONFIG_AGP_SWORKS=y
# CONFIG_AGP_VIA is not set
CONFIG_AGP_EFFICEON=y
CONFIG_INTEL_GTT=y
# CONFIG_VGA_ARB is not set
# CONFIG_VGA_SWITCHEROO is not set

#
# Direct Rendering Manager
#
CONFIG_DRM=y
CONFIG_DRM_USB=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
CONFIG_DRM_TTM=y

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
CONFIG_DRM_I2C_SIL164=y
CONFIG_DRM_I2C_NXP_TDA998X=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
# CONFIG_DRM_RADEON is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
# CONFIG_DRM_NOUVEAU_BACKLIGHT is not set
CONFIG_DRM_I810=y
CONFIG_DRM_I915=y
# CONFIG_DRM_I915_KMS is not set
CONFIG_DRM_I915_FBDEV=y
# CONFIG_DRM_I915_PRELIMINARY_HW_SUPPORT is not set
# CONFIG_DRM_I915_UMS is not set
CONFIG_DRM_MGA=y
# CONFIG_DRM_SIS is not set
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
CONFIG_DRM_GMA500=y
# CONFIG_DRM_GMA600 is not set
CONFIG_DRM_GMA3600=y
CONFIG_DRM_UDL=y
CONFIG_DRM_AST=y
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_DRM_QXL=y
CONFIG_DRM_BOCHS=y
# CONFIG_DRM_PTN3460 is not set

#
# Frame buffer Devices
#
CONFIG_FB=y
# CONFIG_FIRMWARE_EDID is not set
CONFIG_FB_DDC=y
# CONFIG_FB_BOOT_VESA_SUPPORT is not set
CONFIG_FB_CFB_FILLRECT=y
CONFIG_FB_CFB_COPYAREA=y
CONFIG_FB_CFB_IMAGEBLIT=y
# CONFIG_FB_CFB_REV_PIXELS_IN_BYTE is not set
CONFIG_FB_SYS_FILLRECT=y
CONFIG_FB_SYS_COPYAREA=y
CONFIG_FB_SYS_IMAGEBLIT=y
CONFIG_FB_FOREIGN_ENDIAN=y
CONFIG_FB_BOTH_ENDIAN=y
# CONFIG_FB_BIG_ENDIAN is not set
# CONFIG_FB_LITTLE_ENDIAN is not set
CONFIG_FB_SYS_FOPS=y
CONFIG_FB_DEFERRED_IO=y
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
# CONFIG_FB_PM2 is not set
# CONFIG_FB_CYBER2000 is not set
CONFIG_FB_ARC=y
CONFIG_FB_ASILIANT=y
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
# CONFIG_FB_VESA is not set
# CONFIG_FB_N411 is not set
# CONFIG_FB_HGA is not set
CONFIG_FB_OPENCORES=y
# CONFIG_FB_S1D13XXX is not set
CONFIG_FB_NVIDIA=y
CONFIG_FB_NVIDIA_I2C=y
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
CONFIG_FB_RIVA=y
# CONFIG_FB_RIVA_I2C is not set
CONFIG_FB_RIVA_DEBUG=y
CONFIG_FB_RIVA_BACKLIGHT=y
CONFIG_FB_I740=y
CONFIG_FB_I810=y
CONFIG_FB_I810_GTF=y
CONFIG_FB_I810_I2C=y
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
# CONFIG_FB_MATROX is not set
# CONFIG_FB_RADEON is not set
# CONFIG_FB_ATY128 is not set
CONFIG_FB_ATY=y
# CONFIG_FB_ATY_CT is not set
# CONFIG_FB_ATY_GX is not set
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
# CONFIG_FB_S3_DDC is not set
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
CONFIG_FB_SAVAGE_ACCEL=y
# CONFIG_FB_SIS is not set
# CONFIG_FB_VIA is not set
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
# CONFIG_FB_3DFX_I2C is not set
CONFIG_FB_VOODOO1=y
# CONFIG_FB_VT8623 is not set
# CONFIG_FB_TRIDENT is not set
# CONFIG_FB_ARK is not set
CONFIG_FB_PM3=y
CONFIG_FB_CARMINE=y
# CONFIG_FB_CARMINE_DRAM_EVAL is not set
CONFIG_CARMINE_DRAM_CUSTOM=y
CONFIG_FB_GEODE=y
CONFIG_FB_GEODE_LX=y
CONFIG_FB_GEODE_GX=y
CONFIG_FB_GEODE_GX1=y
CONFIG_FB_TMIO=y
# CONFIG_FB_TMIO_ACCELL is not set
CONFIG_FB_SMSCUFX=y
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
# CONFIG_FB_MB862XX_I2C is not set
CONFIG_FB_BROADSHEET=y
# CONFIG_FB_AUO_K190X is not set
CONFIG_FB_SIMPLE=y
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_FB_SSD1307=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
CONFIG_BACKLIGHT_GENERIC=y
CONFIG_BACKLIGHT_LM3533=y
# CONFIG_BACKLIGHT_PWM is not set
CONFIG_BACKLIGHT_DA903X=y
# CONFIG_BACKLIGHT_MAX8925 is not set
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
# CONFIG_BACKLIGHT_ADP8860 is not set
CONFIG_BACKLIGHT_ADP8870=y
# CONFIG_BACKLIGHT_88PM860X is not set
CONFIG_BACKLIGHT_LM3630A=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_OT200=y
CONFIG_BACKLIGHT_TPS65217=y
CONFIG_BACKLIGHT_AS3711=y
# CONFIG_BACKLIGHT_GPIO is not set
CONFIG_BACKLIGHT_LV5207LP=y
CONFIG_BACKLIGHT_BD6107=y
CONFIG_VGASTATE=y
CONFIG_HDMI=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_DMAENGINE_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_COMPRESS_OFFLOAD=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
# CONFIG_SND_PCM_OSS is not set
CONFIG_SND_SEQUENCER_OSS=y
# CONFIG_SND_HRTIMER is not set
# CONFIG_SND_DYNAMIC_MINORS is not set
CONFIG_SND_SUPPORT_OLD_API=y
# CONFIG_SND_VERBOSE_PROCFS is not set
CONFIG_SND_VERBOSE_PRINTK=y
# CONFIG_SND_DEBUG is not set
CONFIG_SND_VMASTER=y
CONFIG_SND_KCTL_JACK=y
CONFIG_SND_DMA_SGBUF=y
CONFIG_SND_RAWMIDI_SEQ=y
CONFIG_SND_OPL3_LIB_SEQ=y
# CONFIG_SND_OPL4_LIB_SEQ is not set
# CONFIG_SND_SBAWE_SEQ is not set
CONFIG_SND_EMU10K1_SEQ=y
CONFIG_SND_MPU401_UART=y
CONFIG_SND_OPL3_LIB=y
CONFIG_SND_VX_LIB=y
CONFIG_SND_AC97_CODEC=y
# CONFIG_SND_DRIVERS is not set
CONFIG_SND_SB_COMMON=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
# CONFIG_SND_ATIIXP is not set
CONFIG_SND_ATIIXP_MODEM=y
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
# CONFIG_SND_AU8830 is not set
CONFIG_SND_AW2=y
# CONFIG_SND_AZT3328 is not set
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
# CONFIG_SND_CMIPCI is not set
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
# CONFIG_SND_CS4281 is not set
# CONFIG_SND_CS46XX is not set
# CONFIG_SND_CS5530 is not set
CONFIG_SND_CS5535AUDIO=y
# CONFIG_SND_CTXFI is not set
# CONFIG_SND_DARLA20 is not set
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
# CONFIG_SND_MONA is not set
# CONFIG_SND_MIA is not set
CONFIG_SND_ECHO3G=y
CONFIG_SND_INDIGO=y
# CONFIG_SND_INDIGOIO is not set
CONFIG_SND_INDIGODJ=y
# CONFIG_SND_INDIGOIOX is not set
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
# CONFIG_SND_EMU10K1X is not set
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_FM801=y
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=y
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=y
# CONFIG_SND_INTEL8X0M is not set
# CONFIG_SND_KORG1212 is not set
CONFIG_SND_LOLA=y
CONFIG_SND_LX6464ES=y
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=y
# CONFIG_SND_NM256 is not set
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
# CONFIG_SND_RME9652 is not set
CONFIG_SND_SIS7019=y
# CONFIG_SND_SONICVIBES is not set
CONFIG_SND_TRIDENT=y
# CONFIG_SND_VIA82XX is not set
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
# CONFIG_SND_YMFPCI is not set

#
# HD-Audio
#
CONFIG_SND_HDA=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
# CONFIG_SND_HDA_HWDEP is not set
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
# CONFIG_SND_HDA_CODEC_VIA is not set
# CONFIG_SND_HDA_CODEC_HDMI is not set
CONFIG_SND_HDA_I915=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
CONFIG_SND_HDA_CODEC_CA0110=y
# CONFIG_SND_HDA_CODEC_CA0132 is not set
# CONFIG_SND_HDA_CODEC_CMEDIA is not set
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_USB=y
# CONFIG_SND_USB_AUDIO is not set
CONFIG_SND_USB_UA101=y
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
# CONFIG_SND_USB_CAIAQ_INPUT is not set
CONFIG_SND_USB_US122L=y
CONFIG_SND_USB_6FIRE=y
CONFIG_SND_USB_HIFACE=y
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
CONFIG_SND_DICE=y
CONFIG_SND_FIREWIRE_SPEAKERS=y
# CONFIG_SND_ISIGHT is not set
# CONFIG_SND_SCS1X is not set
CONFIG_SND_SOC=y
CONFIG_SND_SOC_GENERIC_DMAENGINE_PCM=y
CONFIG_SND_SOC_ADI=y
CONFIG_SND_SOC_ADI_AXI_I2S=y
CONFIG_SND_SOC_ADI_AXI_SPDIF=y
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_BCM2835_SOC_I2S=y
CONFIG_SND_EP93XX_SOC=y
# CONFIG_SND_IMX_SOC is not set
# CONFIG_SND_KIRKWOOD_SOC is not set
# CONFIG_SND_SOC_INTEL_SST is not set
CONFIG_SND_SOC_SIRF=y
CONFIG_SND_SOC_SIRF_AUDIO=y
CONFIG_SND_SOC_SIRF_AUDIO_PORT=y
CONFIG_SND_SOC_I2C_AND_SPI=y

#
# CODEC drivers
#
CONFIG_SND_SOC_ALL_CODECS=y
CONFIG_SND_SOC_88PM860X=y
CONFIG_SND_SOC_ARIZONA=y
CONFIG_SND_SOC_WM_HUBS=y
CONFIG_SND_SOC_WM_ADSP=y
CONFIG_SND_SOC_AD193X=y
CONFIG_SND_SOC_AD193X_I2C=y
CONFIG_SND_SOC_AD73311=y
CONFIG_SND_SOC_ADAU1701=y
CONFIG_SND_SOC_ADAU1373=y
CONFIG_SND_SOC_ADAU1977=y
CONFIG_SND_SOC_ADAU1977_I2C=y
CONFIG_SND_SOC_ADAV80X=y
CONFIG_SND_SOC_ADAV803=y
CONFIG_SND_SOC_ADS117X=y
CONFIG_SND_SOC_AK4535=y
CONFIG_SND_SOC_AK4554=y
CONFIG_SND_SOC_AK4641=y
CONFIG_SND_SOC_AK4642=y
CONFIG_SND_SOC_AK4671=y
CONFIG_SND_SOC_AK5386=y
CONFIG_SND_SOC_ALC5623=y
CONFIG_SND_SOC_ALC5632=y
CONFIG_SND_SOC_CS42L51=y
CONFIG_SND_SOC_CS42L52=y
CONFIG_SND_SOC_CS42L73=y
CONFIG_SND_SOC_CS4270=y
CONFIG_SND_SOC_CS4271=y
CONFIG_SND_SOC_CS42XX8=y
CONFIG_SND_SOC_CS42XX8_I2C=y
CONFIG_SND_SOC_CX20442=y
CONFIG_SND_SOC_JZ4740_CODEC=y
CONFIG_SND_SOC_L3=y
CONFIG_SND_SOC_DA7210=y
CONFIG_SND_SOC_DA7213=y
CONFIG_SND_SOC_DA732X=y
CONFIG_SND_SOC_DA9055=y
CONFIG_SND_SOC_BT_SCO=y
CONFIG_SND_SOC_HDMI_CODEC=y
CONFIG_SND_SOC_ISABELLE=y
CONFIG_SND_SOC_LM49453=y
CONFIG_SND_SOC_MAX98088=y
CONFIG_SND_SOC_MAX98090=y
CONFIG_SND_SOC_MAX98095=y
CONFIG_SND_SOC_MAX9850=y
CONFIG_SND_SOC_PCM1681=y
CONFIG_SND_SOC_PCM3008=y
CONFIG_SND_SOC_PCM512x=y
CONFIG_SND_SOC_PCM512x_I2C=y
CONFIG_SND_SOC_RT5631=y
CONFIG_SND_SOC_RT5640=y
CONFIG_SND_SOC_SGTL5000=y
CONFIG_SND_SOC_SI476X=y
CONFIG_SND_SOC_SIGMADSP=y
CONFIG_SND_SOC_SIRF_AUDIO_CODEC=y
CONFIG_SND_SOC_SPDIF=y
CONFIG_SND_SOC_SSM2518=y
CONFIG_SND_SOC_SSM2602=y
CONFIG_SND_SOC_SSM2602_I2C=y
CONFIG_SND_SOC_STA32X=y
CONFIG_SND_SOC_STA529=y
CONFIG_SND_SOC_TAS5086=y
CONFIG_SND_SOC_TLV320AIC23=y
CONFIG_SND_SOC_TLV320AIC23_I2C=y
CONFIG_SND_SOC_TLV320AIC31XX=y
CONFIG_SND_SOC_TLV320AIC32X4=y
CONFIG_SND_SOC_TLV320AIC3X=y
CONFIG_SND_SOC_TLV320DAC33=y
CONFIG_SND_SOC_TWL6040=y
CONFIG_SND_SOC_UDA134X=y
CONFIG_SND_SOC_UDA1380=y
CONFIG_SND_SOC_WL1273=y
CONFIG_SND_SOC_WM1250_EV1=y
CONFIG_SND_SOC_WM2000=y
CONFIG_SND_SOC_WM2200=y
CONFIG_SND_SOC_WM5100=y
CONFIG_SND_SOC_WM5110=y
CONFIG_SND_SOC_WM8400=y
CONFIG_SND_SOC_WM8510=y
CONFIG_SND_SOC_WM8523=y
CONFIG_SND_SOC_WM8580=y
CONFIG_SND_SOC_WM8711=y
CONFIG_SND_SOC_WM8727=y
CONFIG_SND_SOC_WM8728=y
CONFIG_SND_SOC_WM8731=y
CONFIG_SND_SOC_WM8737=y
CONFIG_SND_SOC_WM8741=y
CONFIG_SND_SOC_WM8750=y
CONFIG_SND_SOC_WM8753=y
CONFIG_SND_SOC_WM8776=y
CONFIG_SND_SOC_WM8782=y
CONFIG_SND_SOC_WM8804=y
CONFIG_SND_SOC_WM8900=y
CONFIG_SND_SOC_WM8903=y
CONFIG_SND_SOC_WM8904=y
CONFIG_SND_SOC_WM8940=y
CONFIG_SND_SOC_WM8955=y
CONFIG_SND_SOC_WM8960=y
CONFIG_SND_SOC_WM8961=y
CONFIG_SND_SOC_WM8962=y
CONFIG_SND_SOC_WM8971=y
CONFIG_SND_SOC_WM8974=y
CONFIG_SND_SOC_WM8978=y
CONFIG_SND_SOC_WM8983=y
CONFIG_SND_SOC_WM8985=y
CONFIG_SND_SOC_WM8988=y
CONFIG_SND_SOC_WM8990=y
CONFIG_SND_SOC_WM8991=y
CONFIG_SND_SOC_WM8993=y
CONFIG_SND_SOC_WM8995=y
CONFIG_SND_SOC_WM8996=y
CONFIG_SND_SOC_WM8997=y
CONFIG_SND_SOC_WM9081=y
CONFIG_SND_SOC_WM9090=y
CONFIG_SND_SOC_LM4857=y
CONFIG_SND_SOC_MAX9768=y
CONFIG_SND_SOC_MAX9877=y
CONFIG_SND_SOC_ML26124=y
CONFIG_SND_SOC_TPA6130A2=y
# CONFIG_SND_SIMPLE_CARD is not set
CONFIG_SOUND_PRIME=y
# CONFIG_SOUND_OSS is not set
CONFIG_AC97_BUS=y

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
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_APPLEIR is not set
CONFIG_HID_AUREAL=y
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
# CONFIG_HID_CHICONY is not set
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CP2112=y
CONFIG_HID_CYPRESS=y
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_ELECOM=y
CONFIG_HID_ELO=y
CONFIG_HID_EZKEY=y
CONFIG_HID_HOLTEK=y
CONFIG_HOLTEK_FF=y
CONFIG_HID_HUION=y
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
# CONFIG_HID_LOGITECH is not set
CONFIG_HID_MAGICMOUSE=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
CONFIG_HID_MULTITOUCH=y
CONFIG_HID_NTRIG=y
CONFIG_HID_ORTEK=y
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
CONFIG_HID_PRIMAX=y
CONFIG_HID_ROCCAT=y
CONFIG_HID_SAITEK=y
# CONFIG_HID_SAMSUNG is not set
CONFIG_HID_SONY=y
# CONFIG_SONY_FF is not set
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_STEELSERIES=y
# CONFIG_HID_SUNPLUS is not set
CONFIG_HID_GREENASIA=y
# CONFIG_GREENASIA_FF is not set
CONFIG_HID_SMARTJOYPLUS=y
# CONFIG_SMARTJOYPLUS_FF is not set
CONFIG_HID_TIVO=y
# CONFIG_HID_TOPSEED is not set
CONFIG_HID_THINGM=y
# CONFIG_HID_THRUSTMASTER is not set
CONFIG_HID_WACOM=y
CONFIG_HID_WIIMOTE=y
# CONFIG_HID_XINMO is not set
CONFIG_HID_ZEROPLUS=y
# CONFIG_ZEROPLUS_FF is not set
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
# CONFIG_USB_HIDDEV is not set

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
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
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_OTG_WHITELIST=y
# CONFIG_USB_OTG_BLACKLIST_HUB is not set
# CONFIG_USB_MON is not set
# CONFIG_USB_WUSB is not set
# CONFIG_USB_WUSB_CBAF is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
CONFIG_USB_XHCI_PLATFORM=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OXU210HP_HCD=y
CONFIG_USB_ISP116X_HCD=y
CONFIG_USB_ISP1760_HCD=y
CONFIG_USB_ISP1362_HCD=y
# CONFIG_USB_FUSBH200_HCD is not set
CONFIG_USB_FOTG210_HCD=y
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_PCI is not set
CONFIG_USB_OHCI_HCD_PLATFORM=y
# CONFIG_USB_UHCI_HCD is not set
# CONFIG_USB_U132_HCD is not set
CONFIG_USB_SL811_HCD=y
CONFIG_USB_SL811_HCD_ISO=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_RENESAS_USBHS_HCD=y
# CONFIG_USB_WHCI_HCD is not set
# CONFIG_USB_HWA_HCD is not set
CONFIG_USB_HCD_BCMA=y
# CONFIG_USB_HCD_TEST_MODE is not set
CONFIG_USB_RENESAS_USBHS=y

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
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
# CONFIG_USB_STORAGE_SDDR55 is not set
CONFIG_USB_STORAGE_JUMPSHOT=y
# CONFIG_USB_STORAGE_ALAUDA is not set
CONFIG_USB_STORAGE_ONETOUCH=y
# CONFIG_USB_STORAGE_KARMA is not set
# CONFIG_USB_STORAGE_CYPRESS_ATACB is not set
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y
CONFIG_USB_MUSB_HDRC=y
# CONFIG_USB_MUSB_HOST is not set
# CONFIG_USB_MUSB_GADGET is not set
CONFIG_USB_MUSB_DUAL_ROLE=y
CONFIG_USB_MUSB_TUSB6010=y
# CONFIG_USB_MUSB_DSPS is not set
# CONFIG_USB_MUSB_UX500 is not set
CONFIG_MUSB_PIO_ONLY=y
CONFIG_USB_DWC3=y
# CONFIG_USB_DWC3_HOST is not set
# CONFIG_USB_DWC3_GADGET is not set
CONFIG_USB_DWC3_DUAL_ROLE=y

#
# Platform Glue Driver Support
#
# CONFIG_USB_DWC3_OMAP is not set
CONFIG_USB_DWC3_EXYNOS=y
CONFIG_USB_DWC3_PCI=y
CONFIG_USB_DWC3_KEYSTONE=y

#
# Debugging features
#
CONFIG_USB_DWC3_DEBUG=y
CONFIG_USB_DWC3_VERBOSE=y
# CONFIG_USB_DWC2 is not set
CONFIG_USB_CHIPIDEA=y
# CONFIG_USB_CHIPIDEA_UDC is not set
CONFIG_USB_CHIPIDEA_HOST=y
CONFIG_USB_CHIPIDEA_DEBUG=y

#
# USB port drivers
#
# CONFIG_USB_SERIAL is not set

#
# USB Miscellaneous drivers
#
# CONFIG_USB_EMI62 is not set
CONFIG_USB_EMI26=y
# CONFIG_USB_ADUTUX is not set
CONFIG_USB_SEVSEG=y
CONFIG_USB_RIO500=y
CONFIG_USB_LEGOTOWER=y
CONFIG_USB_LCD=y
CONFIG_USB_LED=y
CONFIG_USB_CYPRESS_CY7C63=y
CONFIG_USB_CYTHERM=y
CONFIG_USB_IDMOUSE=y
CONFIG_USB_FTDI_ELAN=y
CONFIG_USB_APPLEDISPLAY=y
CONFIG_USB_SISUSBVGA=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
# CONFIG_USB_EHSET_TEST_FIXTURE is not set
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
# CONFIG_USB_EZUSB_FX2 is not set
# CONFIG_USB_HSIC_USB3503 is not set
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
# CONFIG_USB_CXACRU is not set
# CONFIG_USB_UEAGLEATM is not set
CONFIG_USB_XUSBATM=y

#
# USB Physical Layer drivers
#
CONFIG_USB_PHY=y
# CONFIG_USB_OTG_FSM is not set
# CONFIG_KEYSTONE_USB_PHY is not set
CONFIG_NOP_USB_XCEIV=y
CONFIG_AM335X_CONTROL_USB=y
CONFIG_AM335X_PHY_USB=y
CONFIG_SAMSUNG_USBPHY=y
CONFIG_SAMSUNG_USB2PHY=y
# CONFIG_SAMSUNG_USB3PHY is not set
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_USB_ISP1301=y
# CONFIG_USB_RCAR_PHY is not set
# CONFIG_USB_RCAR_GEN2_PHY is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_FUSB300=y
CONFIG_USB_FOTG210_UDC=y
CONFIG_USB_GR_UDC=y
CONFIG_USB_R8A66597=y
CONFIG_USB_RENESAS_USBHS_UDC=y
CONFIG_USB_PXA27X=y
# CONFIG_USB_S3C_HSOTG is not set
CONFIG_USB_MV_UDC=y
CONFIG_USB_MV_U3D=y
# CONFIG_USB_M66592 is not set
CONFIG_USB_AMD5536UDC=y
# CONFIG_USB_NET2272 is not set
CONFIG_USB_NET2280=y
CONFIG_USB_GOKU=y
CONFIG_USB_EG20T=y
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_U_ETHER=y
CONFIG_USB_F_NCM=y
CONFIG_USB_F_RNDIS=y
CONFIG_USB_CONFIGFS=y
# CONFIG_USB_CONFIGFS_SERIAL is not set
# CONFIG_USB_CONFIGFS_ACM is not set
# CONFIG_USB_CONFIGFS_OBEX is not set
CONFIG_USB_CONFIGFS_NCM=y
# CONFIG_USB_CONFIGFS_ECM is not set
# CONFIG_USB_CONFIGFS_ECM_SUBSET is not set
CONFIG_USB_CONFIGFS_RNDIS=y
# CONFIG_USB_CONFIGFS_EEM is not set
# CONFIG_USB_CONFIGFS_MASS_STORAGE is not set
# CONFIG_USB_CONFIGFS_F_LB_SS is not set
# CONFIG_USB_CONFIGFS_F_FS is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set
# CONFIG_USB_G_WEBCAM is not set
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
# CONFIG_MMC_BLOCK is not set
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
# CONFIG_MMC_SDHCI is not set
# CONFIG_MMC_OMAP_HS is not set
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_GOLDFISH=y
# CONFIG_MMC_CB710 is not set
# CONFIG_MMC_VIA_SDMMC is not set
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
CONFIG_MMC_REALTEK_PCI=y
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
# CONFIG_MSPRO_BLOCK is not set
CONFIG_MS_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
CONFIG_MEMSTICK_TIFM_MS=y
# CONFIG_MEMSTICK_JMICRON_38X is not set
# CONFIG_MEMSTICK_R592 is not set
CONFIG_MEMSTICK_REALTEK_PCI=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
CONFIG_LEDS_LM3530=y
CONFIG_LEDS_LM3533=y
CONFIG_LEDS_LM3642=y
CONFIG_LEDS_NET48XX=y
CONFIG_LEDS_WRAP=y
# CONFIG_LEDS_PCA9532 is not set
CONFIG_LEDS_GPIO=y
# CONFIG_LEDS_LP3944 is not set
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
# CONFIG_LEDS_LP5562 is not set
CONFIG_LEDS_LP8501=y
CONFIG_LEDS_PCA955X=y
CONFIG_LEDS_PCA963X=y
# CONFIG_LEDS_PCA9685 is not set
CONFIG_LEDS_WM831X_STATUS=y
CONFIG_LEDS_DA903X=y
# CONFIG_LEDS_PWM is not set
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_LT3593 is not set
# CONFIG_LEDS_DELL_NETBOOKS is not set
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_ACCESSIBILITY=y
CONFIG_INFINIBAND=y
# CONFIG_INFINIBAND_USER_MAD is not set
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=y
# CONFIG_INFINIBAND_MTHCA_DEBUG is not set
# CONFIG_INFINIBAND_AMSO1100 is not set
CONFIG_INFINIBAND_NES=y
CONFIG_INFINIBAND_NES_DEBUG=y
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
# CONFIG_INFINIBAND_IPOIB_DEBUG is not set
CONFIG_INFINIBAND_SRP=y
CONFIG_INFINIBAND_ISER=y
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_HCTOSYS is not set
# CONFIG_RTC_SYSTOHC is not set
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
# CONFIG_RTC_INTF_SYSFS is not set
CONFIG_RTC_INTF_PROC=y
# CONFIG_RTC_INTF_DEV is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_88PM860X=y
# CONFIG_RTC_DRV_88PM80X is not set
# CONFIG_RTC_DRV_DS1307 is not set
# CONFIG_RTC_DRV_DS1374 is not set
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
# CONFIG_RTC_DRV_HYM8563 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_MAX8907=y
# CONFIG_RTC_DRV_MAX8925 is not set
CONFIG_RTC_DRV_MAX8998=y
CONFIG_RTC_DRV_MAX77686=y
# CONFIG_RTC_DRV_RS5C372 is not set
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
# CONFIG_RTC_DRV_ISL12057 is not set
# CONFIG_RTC_DRV_X1205 is not set
# CONFIG_RTC_DRV_PCF2127 is not set
CONFIG_RTC_DRV_PCF8523=y
# CONFIG_RTC_DRV_PCF8563 is not set
CONFIG_RTC_DRV_PCF8583=y
# CONFIG_RTC_DRV_M41T80 is not set
CONFIG_RTC_DRV_BQ32K=y
# CONFIG_RTC_DRV_TPS6586X is not set
CONFIG_RTC_DRV_TPS65910=y
CONFIG_RTC_DRV_TPS80031=y
# CONFIG_RTC_DRV_RC5T583 is not set
# CONFIG_RTC_DRV_S35390A is not set
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
CONFIG_RTC_DRV_EM3027=y
CONFIG_RTC_DRV_RV3029C2=y
CONFIG_RTC_DRV_S5M=y

#
# SPI RTC drivers
#

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_DA9055=y
CONFIG_RTC_DRV_STK17TA8=y
# CONFIG_RTC_DRV_M48T86 is not set
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
# CONFIG_RTC_DRV_MSM6242 is not set
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
# CONFIG_RTC_DRV_V3020 is not set
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_WM831X=y

#
# on-CPU RTC drivers
#
# CONFIG_RTC_DRV_SNVS is not set
CONFIG_RTC_DRV_MOXART=y

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
CONFIG_DMADEVICES_VDEBUG=y

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
CONFIG_DW_DMAC_CORE=y
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_PCI is not set
CONFIG_TIMB_DMA=y
CONFIG_PCH_DMA=y
CONFIG_FSL_EDMA=y
CONFIG_DMA_ENGINE=y
CONFIG_DMA_VIRTUAL_CHANNELS=y
CONFIG_DMA_ACPI=y
CONFIG_DMA_OF=y

#
# DMA Clients
#
# CONFIG_ASYNC_TX_DMA is not set
CONFIG_DMATEST=y
CONFIG_DMA_ENGINE_RAID=y
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
# CONFIG_UIO_CIF is not set
# CONFIG_UIO_PDRV_GENIRQ is not set
CONFIG_UIO_DMEM_GENIRQ=y
# CONFIG_UIO_AEC is not set
CONFIG_UIO_SERCOS3=y
# CONFIG_UIO_PCI_GENERIC is not set
CONFIG_UIO_NETX=y
CONFIG_UIO_MF624=y
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
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
# CONFIG_USBIP_CORE is not set
CONFIG_PRISM2_USB=y
CONFIG_R8712U=y
# CONFIG_R8188EU is not set
CONFIG_RTS5139=y
CONFIG_RTS5139_DEBUG=y
# CONFIG_RTS5208 is not set
# CONFIG_TRANZPORT is not set
CONFIG_LINE6_USB=y
CONFIG_LINE6_USB_IMPULSE_RESPONSE=y
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
CONFIG_AD7291=y
CONFIG_AD7606=y
CONFIG_AD7606_IFACE_PARALLEL=y
CONFIG_AD799X=y
CONFIG_AD799X_RING_BUFFER=y
CONFIG_LPC32XX_ADC=y
CONFIG_MXS_LRADC=y
# CONFIG_SPEAR_ADC is not set

#
# Analog digital bi-direction converters
#
# CONFIG_ADT7316 is not set

#
# Capacitance to digital converters
#
CONFIG_AD7150=y
# CONFIG_AD7152 is not set
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
# CONFIG_AD5933 is not set

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
CONFIG_TSL2x7x=y

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=y

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
# CONFIG_IIO_SIMPLE_DUMMY is not set
CONFIG_CRYSTALHD=y
CONFIG_FB_XGI=y
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_BCM_WIMAX is not set
CONFIG_FT1000=y
CONFIG_FT1000_USB=y

#
# Speakup console speech
#
CONFIG_TOUCHSCREEN_CLEARPAD_TM1217=y
CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4=y
CONFIG_STAGING_MEDIA=y
CONFIG_DVB_AS102=y
CONFIG_DVB_CXD2099=y
CONFIG_VIDEO_DT3155=y
CONFIG_DT3155_CCIR=y
CONFIG_DT3155_STREAMING=y
CONFIG_VIDEO_GO7007=y
CONFIG_VIDEO_GO7007_USB=y
CONFIG_VIDEO_GO7007_LOADER=y
CONFIG_VIDEO_GO7007_USB_S2250_BOARD=y
# CONFIG_SOLO6X10 is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
# CONFIG_ASHMEM is not set
CONFIG_ANDROID_LOGGER=y
CONFIG_ANDROID_TIMED_OUTPUT=y
# CONFIG_ANDROID_TIMED_GPIO is not set
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_ANDROID_INTF_ALARM_DEV is not set
CONFIG_SYNC=y
CONFIG_SW_SYNC=y
# CONFIG_SW_SYNC_USER is not set
# CONFIG_ION is not set
CONFIG_USB_WPAN_HCD=y
CONFIG_WIMAX_GDM72XX=y
# CONFIG_WIMAX_GDM72XX_QOS is not set
# CONFIG_WIMAX_GDM72XX_K_MODE is not set
# CONFIG_WIMAX_GDM72XX_WIMAX2 is not set
# CONFIG_WIMAX_GDM72XX_USB is not set
CONFIG_WIMAX_GDM72XX_SDIO=y
# CONFIG_NET_VENDOR_SILICOM is not set
CONFIG_CED1401=y
# CONFIG_DGRP is not set
# CONFIG_FIREWIRE_SERIAL is not set
# CONFIG_GOLDFISH_AUDIO is not set
# CONFIG_MTD_GOLDFISH_NAND is not set
CONFIG_XILLYBUS=y
CONFIG_XILLYBUS_PCIE=y
CONFIG_XILLYBUS_OF=y
# CONFIG_DGNC is not set
# CONFIG_DGAP is not set
# CONFIG_GS_FPGABOOT is not set
CONFIG_X86_PLATFORM_DEVICES=y
# CONFIG_ACER_WMI is not set
# CONFIG_ACERHDF is not set
# CONFIG_ALIENWARE_WMI is not set
# CONFIG_ASUS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
# CONFIG_DELL_WMI is not set
# CONFIG_DELL_WMI_AIO is not set
# CONFIG_FUJITSU_LAPTOP is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_TC1100_WMI is not set
# CONFIG_HP_ACCEL is not set
# CONFIG_HP_WIRELESS is not set
# CONFIG_HP_WMI is not set
# CONFIG_PANASONIC_LAPTOP is not set
# CONFIG_THINKPAD_ACPI is not set
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
CONFIG_ACPI_WMI=y
# CONFIG_MSI_WMI is not set
# CONFIG_TOPSTAR_LAPTOP is not set
# CONFIG_ACPI_TOSHIBA is not set
# CONFIG_TOSHIBA_BT_RFKILL is not set
# CONFIG_ACPI_CMPC is not set
# CONFIG_INTEL_IPS is not set
CONFIG_IBM_RTL=y
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set
# CONFIG_INTEL_RST is not set
# CONFIG_INTEL_SMARTCONNECT is not set
# CONFIG_PVPANIC is not set
# CONFIG_GOLDFISH_PIPE is not set
# CONFIG_CHROME_PLATFORMS is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKSRC_I8253=y
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
CONFIG_SH_TIMER_CMT=y
# CONFIG_SH_TIMER_MTU2 is not set
# CONFIG_SH_TIMER_TMU is not set
CONFIG_EM_TIMER_STI=y
CONFIG_MAILBOX=y
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
CONFIG_REMOTEPROC=y
CONFIG_STE_MODEM_RPROC=y

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
# CONFIG_DEVFREQ_GOV_POWERSAVE is not set
# CONFIG_DEVFREQ_GOV_USERSPACE is not set

#
# DEVFREQ Drivers
#
CONFIG_EXTCON=y

#
# Extcon Device Drivers
#
# CONFIG_EXTCON_GPIO is not set
CONFIG_EXTCON_ADC_JACK=y
# CONFIG_EXTCON_MAX77693 is not set
CONFIG_EXTCON_ARIZONA=y
CONFIG_MEMORY=y
CONFIG_IIO=y
CONFIG_IIO_BUFFER=y
CONFIG_IIO_BUFFER_CB=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_IIO_TRIGGER=y
CONFIG_IIO_CONSUMERS_PER_TRIGGER=2

#
# Accelerometers
#
# CONFIG_BMA180 is not set
CONFIG_IIO_ST_ACCEL_3AXIS=y
CONFIG_IIO_ST_ACCEL_I2C_3AXIS=y

#
# Analog to digital converters
#
CONFIG_EXYNOS_ADC=y
CONFIG_MAX1363=y
CONFIG_MCP3422=y
CONFIG_MEN_Z188_ADC=y
CONFIG_NAU7802=y
CONFIG_TI_ADC081C=y
# CONFIG_VF610_ADC is not set
# CONFIG_XILINX_XADC is not set

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#
CONFIG_IIO_ST_SENSORS_I2C=y
CONFIG_IIO_ST_SENSORS_CORE=y

#
# Digital to analog converters
#
CONFIG_AD5064=y
CONFIG_AD5380=y
CONFIG_AD5446=y
CONFIG_MAX517=y
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
CONFIG_IIO_ST_GYRO_3AXIS=y
CONFIG_IIO_ST_GYRO_I2C_3AXIS=y
CONFIG_ITG3200=y

#
# Humidity sensors
#
CONFIG_DHT11=y
# CONFIG_SI7005 is not set

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
# CONFIG_APDS9300 is not set
CONFIG_CM32181=y
# CONFIG_CM36651 is not set
CONFIG_GP2AP020A00F=y
CONFIG_SENSORS_LM3533=y
CONFIG_LTR501=y
# CONFIG_TCS3472 is not set
CONFIG_SENSORS_TSL2563=y
CONFIG_TSL4531=y
CONFIG_VCNL4000=y

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
CONFIG_MAG3110=y
CONFIG_IIO_ST_MAGN_3AXIS=y
CONFIG_IIO_ST_MAGN_I2C_3AXIS=y

#
# Inclinometer sensors
#

#
# Triggers - standalone
#
CONFIG_IIO_INTERRUPT_TRIGGER=y
# CONFIG_IIO_SYSFS_TRIGGER is not set

#
# Pressure sensors
#
CONFIG_MPL3115=y
# CONFIG_IIO_ST_PRESS is not set

#
# Temperature sensors
#
CONFIG_TMP006=y
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
CONFIG_PWM=y
CONFIG_PWM_SYSFS=y
CONFIG_PWM_CLPS711X=y
CONFIG_PWM_FSL_FTM=y
CONFIG_PWM_LP3943=y
# CONFIG_PWM_LPSS is not set
CONFIG_PWM_PCA9685=y
CONFIG_PWM_RENESAS_TPU=y
CONFIG_IRQCHIP=y
# CONFIG_IPACK_BUS is not set
# CONFIG_RESET_CONTROLLER is not set
CONFIG_FMC=y
# CONFIG_FMC_FAKEDEV is not set
# CONFIG_FMC_TRIVIAL is not set
CONFIG_FMC_WRITE_EEPROM=y
CONFIG_FMC_CHARDEV=y

#
# PHY Subsystem
#
CONFIG_GENERIC_PHY=y
CONFIG_PHY_EXYNOS_MIPI_VIDEO=y
# CONFIG_OMAP_CONTROL_PHY is not set
# CONFIG_PHY_EXYNOS_DP_VIDEO is not set
CONFIG_BCM_KONA_USB2_PHY=y
# CONFIG_PHY_SAMSUNG_USB2 is not set
# CONFIG_PHY_XGENE is not set
CONFIG_POWERCAP=y
CONFIG_INTEL_RAPL=y
CONFIG_MCB=y
CONFIG_MCB_PCI=y

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
CONFIG_FIRMWARE_MEMMAP=y
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
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
# CONFIG_EXT4_FS is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
# CONFIG_XFS_POSIX_ACL is not set
CONFIG_XFS_RT=y
CONFIG_XFS_WARN=y
# CONFIG_XFS_DEBUG is not set
# CONFIG_GFS2_FS is not set
CONFIG_OCFS2_FS=y
# CONFIG_OCFS2_FS_O2CB is not set
# CONFIG_OCFS2_FS_USERSPACE_CLUSTER is not set
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
# CONFIG_BTRFS_FS_RUN_SANITY_TESTS is not set
CONFIG_BTRFS_DEBUG=y
CONFIG_BTRFS_ASSERT=y
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
# CONFIG_FILE_LOCKING is not set
CONFIG_FSNOTIFY=y
# CONFIG_DNOTIFY is not set
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_PRINT_QUOTA_WARNING=y
CONFIG_QUOTA_DEBUG=y
CONFIG_QUOTA_TREE=y
# CONFIG_QFMT_V1 is not set
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
CONFIG_FSCACHE_DEBUG=y
CONFIG_FSCACHE_OBJECT_LIST=y
# CONFIG_CACHEFILES is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
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
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
# CONFIG_PROC_PAGE_MONITOR is not set
CONFIG_KERNFS=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
# CONFIG_TMPFS_POSIX_ACL is not set
# CONFIG_TMPFS_XATTR is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
CONFIG_ADFS_FS_RW=y
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
CONFIG_ECRYPT_FS_MESSAGING=y
# CONFIG_HFS_FS is not set
# CONFIG_HFSPLUS_FS is not set
CONFIG_BEFS_FS=y
CONFIG_BEFS_DEBUG=y
# CONFIG_BFS_FS is not set
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
# CONFIG_JFFS2_FS_WRITEBUFFER is not set
# CONFIG_JFFS2_SUMMARY is not set
# CONFIG_JFFS2_FS_XATTR is not set
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
# CONFIG_JFFS2_ZLIB is not set
# CONFIG_JFFS2_LZO is not set
CONFIG_JFFS2_RTIME=y
CONFIG_JFFS2_RUBIN=y
# CONFIG_JFFS2_CMODE_NONE is not set
# CONFIG_JFFS2_CMODE_PRIORITY is not set
CONFIG_JFFS2_CMODE_SIZE=y
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
# CONFIG_LOGFS is not set
CONFIG_CRAMFS=y
# CONFIG_SQUASHFS is not set
CONFIG_VXFS_FS=y
# CONFIG_MINIX_FS is not set
CONFIG_OMFS_FS=y
CONFIG_HPFS_FS=y
CONFIG_QNX4FS_FS=y
CONFIG_QNX6FS_FS=y
# CONFIG_QNX6FS_DEBUG is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
CONFIG_PSTORE_CONSOLE=y
# CONFIG_PSTORE_RAM is not set
# CONFIG_SYSV_FS is not set
CONFIG_UFS_FS=y
CONFIG_UFS_FS_WRITE=y
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
CONFIG_EXOFS_DEBUG=y
CONFIG_F2FS_FS=y
# CONFIG_F2FS_STAT_FS is not set
CONFIG_F2FS_FS_XATTR=y
CONFIG_F2FS_FS_POSIX_ACL=y
CONFIG_F2FS_FS_SECURITY=y
CONFIG_F2FS_CHECK_FS=y
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_CEPH_FS=y
CONFIG_CEPH_FSCACHE=y
CONFIG_CEPH_FS_POSIX_ACL=y
CONFIG_CIFS=y
CONFIG_CIFS_STATS=y
CONFIG_CIFS_STATS2=y
# CONFIG_CIFS_WEAK_PW_HASH is not set
# CONFIG_CIFS_UPCALL is not set
# CONFIG_CIFS_XATTR is not set
CONFIG_CIFS_DEBUG=y
CONFIG_CIFS_DEBUG2=y
CONFIG_CIFS_DFS_UPCALL=y
CONFIG_CIFS_SMB2=y
# CONFIG_CIFS_FSCACHE is not set
CONFIG_NCP_FS=y
# CONFIG_NCPFS_PACKET_SIGNING is not set
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
# CONFIG_NCPFS_EXTRAS is not set
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
CONFIG_AFS_DEBUG=y
# CONFIG_AFS_FSCACHE is not set
# CONFIG_9P_FS is not set
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
# CONFIG_NLS_CODEPAGE_855 is not set
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
# CONFIG_NLS_CODEPAGE_861 is not set
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
# CONFIG_NLS_CODEPAGE_864 is not set
CONFIG_NLS_CODEPAGE_865=y
# CONFIG_NLS_CODEPAGE_866 is not set
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
# CONFIG_NLS_CODEPAGE_950 is not set
CONFIG_NLS_CODEPAGE_932=y
CONFIG_NLS_CODEPAGE_949=y
CONFIG_NLS_CODEPAGE_874=y
CONFIG_NLS_ISO8859_8=y
CONFIG_NLS_CODEPAGE_1250=y
CONFIG_NLS_CODEPAGE_1251=y
CONFIG_NLS_ASCII=y
CONFIG_NLS_ISO8859_1=y
CONFIG_NLS_ISO8859_2=y
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_MAC_ROMAN is not set
CONFIG_NLS_MAC_CELTIC=y
CONFIG_NLS_MAC_CENTEURO=y
# CONFIG_NLS_MAC_CROATIAN is not set
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
# CONFIG_NLS_MAC_INUIT is not set
CONFIG_NLS_MAC_ROMANIAN=y
# CONFIG_NLS_MAC_TURKISH is not set
# CONFIG_NLS_UTF8 is not set
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

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
# CONFIG_DYNAMIC_DEBUG is not set

#
# Compile-time checks and compiler options
#
# CONFIG_ENABLE_WARN_DEPRECATED is not set
# CONFIG_ENABLE_MUST_CHECK is not set
CONFIG_FRAME_WARN=1024
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_MAGIC_SYSRQ=y
CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE=0x1
CONFIG_DEBUG_KERNEL=y

#
# Memory Debugging
#
# CONFIG_DEBUG_PAGEALLOC is not set
# CONFIG_DEBUG_OBJECTS is not set
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
# CONFIG_DEBUG_STACK_USAGE is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VM_RB=y
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_MEMORY_INIT is not set
# CONFIG_DEBUG_PER_CPU_MAPS is not set
CONFIG_DEBUG_HIGHMEM=y
CONFIG_HAVE_DEBUG_STACKOVERFLOW=y
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_DEBUG_SHIRQ=y

#
# Debug Lockups and Hangs
#
# CONFIG_LOCKUP_DETECTOR is not set
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_PANIC_ON_OOPS=y
CONFIG_PANIC_ON_OOPS_VALUE=1
CONFIG_PANIC_TIMEOUT=0
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y

#
# Lock Debugging (spinlocks, mutexes, etc...)
#
# CONFIG_DEBUG_RT_MUTEXES is not set
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_WW_MUTEX_SLOWPATH=y
CONFIG_DEBUG_LOCK_ALLOC=y
# CONFIG_PROVE_LOCKING is not set
CONFIG_LOCKDEP=y
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_LOCKDEP=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_LOCK_TORTURE_TEST=y
CONFIG_STACKTRACE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_LIST=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
# CONFIG_DEBUG_CREDENTIALS is not set

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_TORTURE_TEST=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=21
# CONFIG_RCU_CPU_STALL_INFO is not set
CONFIG_RCU_TRACE=y
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_CPU_NOTIFIER_ERROR_INJECT=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
CONFIG_FAIL_MMC_REQUEST=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
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
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set

#
# Runtime Testing
#
CONFIG_LKDTM=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_RBTREE_TEST=y
# CONFIG_ATOMIC64_SELFTEST is not set
# CONFIG_ASYNC_RAID6_TEST is not set
CONFIG_TEST_STRING_HELPERS=y
# CONFIG_TEST_KSTRTOX is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_DMA_API_DEBUG is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
CONFIG_EARLY_PRINTK_DBGP=y
# CONFIG_X86_PTDUMP is not set
# CONFIG_DEBUG_RODATA is not set
CONFIG_DOUBLEFAULT=y
# CONFIG_DEBUG_TLBFLUSH is not set
CONFIG_IOMMU_STRESS=y
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
# CONFIG_IO_DELAY_0X80 is not set
CONFIG_IO_DELAY_0XED=y
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=1
CONFIG_DEBUG_BOOT_PARAMS=y
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
CONFIG_DEBUG_NMI_SELFTEST=y
CONFIG_X86_DEBUG_STATIC_CPU_HAS=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_PERSISTENT_KEYRINGS is not set
# CONFIG_BIG_KEYS is not set
CONFIG_ENCRYPTED_KEYS=y
# CONFIG_KEYS_DEBUG_PROC_KEYS is not set
CONFIG_SECURITY_DMESG_RESTRICT=y
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
# CONFIG_SECURITY_NETWORK_XFRM is not set
CONFIG_SECURITY_PATH=y
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
# CONFIG_SECURITY_APPARMOR is not set
CONFIG_SECURITY_YAMA=y
CONFIG_SECURITY_YAMA_STACKED=y
# CONFIG_IMA is not set
# CONFIG_EVM is not set
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
CONFIG_CRYPTO_FIPS=y
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
CONFIG_CRYPTO_USER=y
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_ABLK_HELPER=y
CONFIG_CRYPTO_GLUE_HELPER_X86=y

#
# Authenticated Encryption with Associated Data
#
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
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
CONFIG_CRYPTO_CRC32=y
CONFIG_CRYPTO_CRC32_PCLMUL=y
CONFIG_CRYPTO_CRCT10DIF=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
# CONFIG_CRYPTO_RMD128 is not set
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
# CONFIG_CRYPTO_RMD320 is not set
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_AES_NI_INTEL is not set
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAST_COMMON=y
# CONFIG_CRYPTO_CAST5 is not set
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_SALSA20 is not set
CONFIG_CRYPTO_SALSA20_586=y
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_586=y
CONFIG_CRYPTO_TEA=y
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
# CONFIG_CRYPTO_LZ4HC is not set

#
# Random Number Generation
#
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_CRYPTO_USER_API=y
CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HASH_INFO=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_CRYPTO_DEV_GEODE=y
# CONFIG_CRYPTO_DEV_HIFN_795X is not set
CONFIG_CRYPTO_DEV_CCP=y
CONFIG_CRYPTO_DEV_CCP_DD=y
# CONFIG_CRYPTO_DEV_CCP_CRYPTO is not set
CONFIG_ASYMMETRIC_KEY_TYPE=y
CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
CONFIG_PUBLIC_KEY_ALGO_RSA=y
CONFIG_X509_CERTIFICATE_PARSER=y
CONFIG_HAVE_KVM=y
CONFIG_VIRTUALIZATION=y
# CONFIG_KVM is not set
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
CONFIG_STMP_DEVICE=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
CONFIG_CRC32_SLICEBY4=y
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
# CONFIG_AUDIT_ARCH_COMPAT_GENERIC is not set
# CONFIG_RANDOM32_SELFTEST is not set
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
CONFIG_XZ_DEC_X86=y
CONFIG_XZ_DEC_POWERPC=y
CONFIG_XZ_DEC_IA64=y
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
CONFIG_XZ_DEC_SPARC=y
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_BCH=y
CONFIG_BCH_CONST_PARAMS=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_ASSOCIATIVE_ARRAY=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT_MAP=y
CONFIG_HAS_DMA=y
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_LRU_CACHE=y
CONFIG_AVERAGE=y
CONFIG_CLZ_TAB=y
# CONFIG_CORDIC is not set
CONFIG_DDR=y
CONFIG_MPILIB=y
CONFIG_OID_REGISTRY=y


--------------090000010208030005040009
Content-Type: text/plain; charset=UTF-8;
 name="Attached Message Part"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="Attached Message Part"

_______________________________________________
LKP mailing list
LKP@linux.intel.com


--------------090000010208030005040009--
