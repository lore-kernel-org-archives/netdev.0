From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [cxgb4i] INFO: suspicious RCU usage. ]
Date: Fri, 1 Aug 2014 20:32:25 +0800
Message-ID: <20140801123225.GA6728@localhost>
References: <20140730140235.GA13959@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ReaqsoxgOBHFXBhH"
Cc: Jet Chen <jet.chen@intel.com>, Su Tao <tao.su@intel.com>,
	Yuanhan Liu <yuanhan.liu@intel.com>, LKP <lkp@01.org>,
	linux-kernel@vger.kernel.org, "Lu, Aaron" <aaron.lu@intel.com>,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Anish Bhatt <anish@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140730140235.GA13959@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Anish,

FYI, here is one more bug message for

git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
commit 759a0cc5a3e1bc2cc48fa3c0b91bdcad8b8f87d6 ("cxgb4i: Add ipv6 code to driver, call into libcxgbi ipv6 api")


[    7.671997] Key type encrypted registered
[    7.676647] 
[    7.676874] ===============================
[    7.677354] [ INFO: suspicious RCU usage. ]
[    7.677867] 3.16.0-rc6-01233-gac3d2e5 #1272 Not tainted
[    7.678466] -------------------------------
[    7.678973] include/linux/rcupdate.h:513 Illegal context switch in RCU read-side critical section!
[    7.680252] 
[    7.680252] other info that might help us debug this:
[    7.680252] 
[    7.681194] 
[    7.681194] rcu_scheduler_active = 1, debug_locks = 1
[    7.682071] 3 locks held by swapper/1:
[    7.682667]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff87bb12fc>] rtnl_lock+0x17/0x19
[    7.683990]  #1:  (rcu_read_lock){......}, at: [<ffffffff86ca617e>] __atomic_notifier_call_chain+0x5/0x105
[    7.685606]  #2:  (rcu_read_lock){......}, at: [<ffffffff8769aa05>] cxgbi_inet6addr_handler+0x5/0x202
[    7.687150] 
[    7.687150] stack backtrace:
[    7.687837] CPU: 0 PID: 1 Comm: swapper Not tainted 3.16.0-rc6-01233-gac3d2e5 #1272
[    7.689016]  0000000000000000 ffff880100d639f8 ffffffff87e25ccc ffff880100d63a28
[    7.690951]  ffffffff86cbc38c ffffffff885d9370 000000000000024a 0000000000000000
[    7.692164]  ffff880100c66000 ffff880100d63a50 ffffffff86cadfd4 ffffffff88ad4d90
[    7.693375] Call Trace:
[    7.693795]  [<ffffffff87e25ccc>] dump_stack+0x19/0x1b
[    7.694579]  [<ffffffff86cbc38c>] lockdep_rcu_suspicious+0xe9/0xf2
[    7.695533]  [<ffffffff86cadfd4>] __might_sleep+0x58/0x1e9
[    7.696372]  [<ffffffff87e3da83>] mutex_lock_nested+0x3b/0x3d3
[    7.697265]  [<ffffffff86caf1b6>] ? sched_clock_local.constprop.2+0x34/0xa1
[    7.698323]  [<ffffffff87690861>] cxgbi_device_find_by_netdev+0x63/0x102
[    7.699359]  [<ffffffff8769aaa1>] cxgbi_inet6addr_handler+0xa1/0x202
[    7.700380]  [<ffffffff8769aa05>] ? cxgbi_inet6addr_handler+0x5/0x202
[    7.701384]  [<ffffffff86ca60c2>] notifier_call_chain+0xf4/0x126
[    7.702322]  [<ffffffff86ca6215>] __atomic_notifier_call_chain+0x9c/0x105
[    7.703366]  [<ffffffff86ca617e>] ? __atomic_notifier_call_chain+0x5/0x105
[    7.704241]  [<ffffffff86ca6292>] atomic_notifier_call_chain+0x14/0x16
[    7.705234]  [<ffffffff87ce2e9c>] inet6addr_notifier_call_chain+0x1b/0x1d
[    7.706505]  [<ffffffff87c9f6e1>] ipv6_add_addr+0x218/0x544
[    7.707539]  [<ffffffff87c9f52e>] ? ipv6_add_addr+0x65/0x544
[    7.708484]  [<ffffffff87ca4a92>] add_addr+0x31/0x93
[    7.709420]  [<ffffffff87ca61ad>] addrconf_notify+0x65e/0x9b9
[    7.710559]  [<ffffffff87e414e2>] ? _raw_read_unlock+0x27/0x31
[    7.711523]  [<ffffffff86cba29c>] ? __lock_is_held+0x37/0x4f
[    7.712588]  [<ffffffff86ca60c2>] notifier_call_chain+0xf4/0x126
[    7.713683]  [<ffffffff86ca6487>] raw_notifier_call_chain+0x14/0x16
[    7.714706]  [<ffffffff87b9c1a1>] call_netdevice_notifiers_info+0x71/0x7a
[    7.715987]  [<ffffffff87b9f800>] call_netdevice_notifiers+0x13/0x15
[    7.717071]  [<ffffffff87ba39e6>] __dev_notify_flags+0x54/0x82
[    7.718127]  [<ffffffff87ba4039>] dev_change_flags+0x4d/0x58
[    7.719187]  [<ffffffff88d4cd83>] ip_auto_config+0x177/0xdbf
[    7.720146]  [<ffffffff86d4eee6>] ? slob_free+0x2cb/0x2d8
[    7.721173]  [<ffffffff88d4cc00>] ? root_nfs_parse_addr+0xa3/0xaf
[    7.722309]  [<ffffffff88cda08f>] ? do_one_initcall+0x98/0x1d0
[    7.723252]  [<ffffffff88d4cc0c>] ? root_nfs_parse_addr+0xaf/0xaf
[    7.724522]  [<ffffffff88cda1b2>] do_one_initcall+0x1bb/0x1d0
[    7.725547]  [<ffffffff86c9fe00>] ? param_array_set+0x82/0x11e
[    7.726539]  [<ffffffff86ca00a0>] ? parse_args+0x1a5/0x27f
[    7.727463]  [<ffffffff88cda2bf>] kernel_init_freeable+0xf8/0x17d
[    7.728598]  [<ffffffff88cd97fd>] ? initcall_blacklist+0x9f/0x9f
[    7.729585]  [<ffffffff87e0c212>] ? rest_init+0x136/0x136
[    7.730678]  [<ffffffff87e0c220>] kernel_init+0xe/0xda
[    7.731661]  [<ffffffff87e41eba>] ret_from_fork+0x7a/0xb0
[    7.732532]  [<ffffffff87e0c212>] ? rest_init+0x136/0x136
[    7.734390] IP-Config: Failed to open gretap0
[    7.735138] IP-Config: No network devices available
[    7.736057] ALSA device list:


Thanks,
Fengguang

--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".dmesg"
Content-Transfer-Encoding: quoted-printable

early console in setup code
early console in decompress_kernel
KASLR using RDTSC...

Decompressing Linux... Parsing ELF... Performing relocations... done.
Booting the kernel.
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.16.0-rc6-01233-gac3d2e5 (kbuild@lkp-hsx01) (=
gcc version 4.8.2 (Debian 4.8.2-18) ) #1272 Fri Jul 25 15:00:59 CST 2014
[    0.000000] Command line: user=3Dlkp job=3D/lkp/scheduled/vm-kbuild-4G-1=
/rand_boot-1-x86_64-randconfig-ha2-0725-ac3d2e5a9ef2f4d8f57c50070c4883ecb7c=
ec29f-0.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ha2-0725/=
ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-gac3d2e5 =
kconfig=3Dx86_64-randconfig-ha2-0725 commit=3Dac3d2e5a9ef2f4d8f57c50070c488=
3ecb7cec29f initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 R=
ESULT_ROOT=3D/result/vm-kbuild-4G/boot/1/x86_64-randconfig-ha2-0725/ac3d2e5=
a9ef2f4d8f57c50070c4883ecb7cec29f/0 ip=3D::::vm-kbuild-4G-1::dhcp oops=3Dpa=
nic earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabled rcup=
date.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchd=
og=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 conso=
le=3Dtty0 vga=3Dnormal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000dfffdfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000dfffe000-0x00000000dfffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000011fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x120000 max_arch_pfn =3D 0x400000000
[    0.000000] e820: last_pfn =3D 0xdfffe max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fda90-0x000fda9f] mapped at =
[ffff8800000fda90]
[    0.000000]   mpc: fdaa0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x09d01000, 0x09d01fff] PGTABLE
[    0.000000] BRK [0x09d02000, 0x09d02fff] PGTABLE
[    0.000000] BRK [0x09d03000, 0x09d03fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11fe00000-0x11fffffff]
[    0.000000]  [mem 0x11fe00000-0x11fffffff] page 4k
[    0.000000] BRK [0x09d04000, 0x09d04fff] PGTABLE
[    0.000000] BRK [0x09d05000, 0x09d05fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11c000000-0x11fdfffff]
[    0.000000]  [mem 0x11c000000-0x11fdfffff] page 4k
[    0.000000] BRK [0x09d06000, 0x09d06fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x100000000-0x11bffffff]
[    0.000000]  [mem 0x100000000-0x11bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x00100000-0xdfffdfff]
[    0.000000]  [mem 0x00100000-0xdfffdfff] page 4k
[    0.000000] cma: CMA: reserved 412 MiB at 105c00000
[    0.000000] RAMDISK: [mem 0x787d8000-0x7fffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD880 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000DFFFE380 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000DFFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000DFFFE3C0 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x00000000DFFFFF40 000040
[    0.000000] ACPI: SSDT 0x00000000DFFFF6E0 000858 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x00000000DFFFF5B0 000090 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000DFFFF570 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:5bff001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x11fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xdfffdfff]
[    0.000000]   node   0: [mem 0x100000000-0x11fffffff]
[    0.000000] On node 0 totalpages: 1048476
[    0.000000]   DMA32 zone: 14335 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 917404 pages, LIFO batch:31
[    0.000000]   Normal zone: 2048 pages used for memmap
[    0.000000]   Normal zone: 131072 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 2=
/0x2 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 3=
/0x3 ignored.
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 882fe00
[    0.000000] e820: [mem 0xe0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 1032072
[    0.000000] Kernel command line: user=3Dlkp job=3D/lkp/scheduled/vm-kbui=
ld-4G-1/rand_boot-1-x86_64-randconfig-ha2-0725-ac3d2e5a9ef2f4d8f57c50070c48=
83ecb7cec29f-0.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ha=
2-0725/ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-ga=
c3d2e5 kconfig=3Dx86_64-randconfig-ha2-0725 commit=3Dac3d2e5a9ef2f4d8f57c50=
070c4883ecb7cec29f initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev=
/ram0 RESULT_ROOT=3D/result/vm-kbuild-4G/boot/1/x86_64-randconfig-ha2-0725/=
ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/0 ip=3D::::vm-kbuild-4G-1::dhcp oo=
ps=3Dpanic earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabl=
ed rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi=
_watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,11520=
0 console=3Dtty0 vga=3Dnormal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 =
bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] Memory: 3452376K/4193904K available (18705K kernel code, 495=
8K rwdata, 8112K rodata, 1556K init, 14988K bss, 741528K reserved)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.16.0-rc6-01233-gac3d2e5 (kbuild@lkp-hsx01) (=
gcc version 4.8.2 (Debian 4.8.2-18) ) #1272 Fri Jul 25 15:00:59 CST 2014
[    0.000000] Command line: user=3Dlkp job=3D/lkp/scheduled/vm-kbuild-4G-1=
/rand_boot-1-x86_64-randconfig-ha2-0725-ac3d2e5a9ef2f4d8f57c50070c4883ecb7c=
ec29f-0.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ha2-0725/=
ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-gac3d2e5 =
kconfig=3Dx86_64-randconfig-ha2-0725 commit=3Dac3d2e5a9ef2f4d8f57c50070c488=
3ecb7cec29f initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 R=
ESULT_ROOT=3D/result/vm-kbuild-4G/boot/1/x86_64-randconfig-ha2-0725/ac3d2e5=
a9ef2f4d8f57c50070c4883ecb7cec29f/0 ip=3D::::vm-kbuild-4G-1::dhcp oops=3Dpa=
nic earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabled rcup=
date.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchd=
og=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 conso=
le=3Dtty0 vga=3Dnormal
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x00000000dfffdfff] usable
[    0.000000] BIOS-e820: [mem 0x00000000dfffe000-0x00000000dfffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000100000000-0x000000011fffffff] usable
[    0.000000] bootconsole [earlyser0] enabled
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] AGP: No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x120000 max_arch_pfn =3D 0x400000000
[    0.000000] e820: last_pfn =3D 0xdfffe max_arch_pfn =3D 0x400000000
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fda90-0x000fda9f] mapped at =
[ffff8800000fda90]
[    0.000000]   mpc: fdaa0-fdbe4
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x09d01000, 0x09d01fff] PGTABLE
[    0.000000] BRK [0x09d02000, 0x09d02fff] PGTABLE
[    0.000000] BRK [0x09d03000, 0x09d03fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11fe00000-0x11fffffff]
[    0.000000]  [mem 0x11fe00000-0x11fffffff] page 4k
[    0.000000] BRK [0x09d04000, 0x09d04fff] PGTABLE
[    0.000000] BRK [0x09d05000, 0x09d05fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x11c000000-0x11fdfffff]
[    0.000000]  [mem 0x11c000000-0x11fdfffff] page 4k
[    0.000000] BRK [0x09d06000, 0x09d06fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x100000000-0x11bffffff]
[    0.000000]  [mem 0x100000000-0x11bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x00100000-0xdfffdfff]
[    0.000000]  [mem 0x00100000-0xdfffdfff] page 4k
[    0.000000] cma: CMA: reserved 412 MiB at 105c00000
[    0.000000] RAMDISK: [mem 0x787d8000-0x7fffffff]
[    0.000000] ACPI: Early table checksum verification disabled
[    0.000000] ACPI: RSDP 0x00000000000FD880 000014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 0x00000000DFFFE380 000034 (v01 BOCHS  BXPCRSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: FACP 0x00000000DFFFFF80 000074 (v01 BOCHS  BXPCFACP 00=
000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 0x00000000DFFFE3C0 0011A9 (v01 BXPC   BXDSDT   00=
000001 INTL 20100528)
[    0.000000] ACPI: FACS 0x00000000DFFFFF40 000040
[    0.000000] ACPI: SSDT 0x00000000DFFFF6E0 000858 (v01 BOCHS  BXPCSSDT 00=
000001 BXPC 00000001)
[    0.000000] ACPI: APIC 0x00000000DFFFF5B0 000090 (v01 BOCHS  BXPCAPIC 00=
000001 BXPC 00000001)
[    0.000000] ACPI: HPET 0x00000000DFFFF570 000038 (v01 BOCHS  BXPCHPET 00=
000001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 1:5bff001, primary cpu clock
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   [mem 0x100000000-0x11fffffff]
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0xdfffdfff]
[    0.000000]   node   0: [mem 0x100000000-0x11fffffff]
[    0.000000] On node 0 totalpages: 1048476
[    0.000000]   DMA32 zone: 14335 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 917404 pages, LIFO batch:31
[    0.000000]   Normal zone: 2048 pages used for memmap
[    0.000000]   Normal zone: 131072 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1=
/0x1 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 2=
/0x2 ignored.
[    0.000000] ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 3=
/0x3 ignored.
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 882fe00
[    0.000000] e820: [mem 0xe0000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=3D1*32768
[    0.000000] pcpu-alloc: [0] 0=20
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Tota=
l pages: 1032072
[    0.000000] Kernel command line: user=3Dlkp job=3D/lkp/scheduled/vm-kbui=
ld-4G-1/rand_boot-1-x86_64-randconfig-ha2-0725-ac3d2e5a9ef2f4d8f57c50070c48=
83ecb7cec29f-0.yaml ARCH=3Dx86_64 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ha=
2-0725/ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-ga=
c3d2e5 kconfig=3Dx86_64-randconfig-ha2-0725 commit=3Dac3d2e5a9ef2f4d8f57c50=
070c4883ecb7cec29f initrd=3D/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev=
/ram0 RESULT_ROOT=3D/result/vm-kbuild-4G/boot/1/x86_64-randconfig-ha2-0725/=
ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/0 ip=3D::::vm-kbuild-4G-1::dhcp oo=
ps=3Dpanic earlyprintk=3DttyS0,115200 debug apic=3Ddebug sysrq_always_enabl=
ed rcupdate.rcu_cpu_stall_timeout=3D100 panic=3D10 softlockup_panic=3D1 nmi=
_watchdog=3Dpanic load_ramdisk=3D2 prompt_ramdisk=3D0 console=3DttyS0,11520=
0 console=3Dtty0 vga=3Dnormal
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 4096 (order: 3, 32768 bytes)
[    0.000000] Dentry cache hash table entries: 524288 (order: 10, 4194304 =
bytes)
[    0.000000] Inode-cache hash table entries: 262144 (order: 9, 2097152 by=
tes)
[    0.000000] AGP: Checking aperture...
[    0.000000] AGP: No AGP bridge found
[    0.000000] Memory: 3452376K/4193904K available (18705K kernel code, 495=
8K rwdata, 8112K rodata, 1556K init, 14988K bss, 741528K reserved)
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
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
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  memory used by lock dependency info: 8671 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] hpet clockevent registered
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.332 MHz processor
[    0.000000] tsc: Detected 2693.332 MHz processor
[    0.020000] Calibrating delay loop (skipped) preset value..=20
[    0.020000] Calibrating delay loop (skipped) preset value.. 5386.66 Bogo=
MIPS (lpj=3D26933320)
5386.66 BogoMIPS (lpj=3D26933320)
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] pid_max: default: 32768 minimum: 301
[    0.020000] ACPI: Core revision 20140424
[    0.020000] ACPI: Core revision 20140424
[    0.027029] ACPI:=20
[    0.027029] ACPI: All ACPI Tables successfully acquiredAll ACPI Tables s=
uccessfully acquired

[    0.028207] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.028207] Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
[    0.029560] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 b=
ytes)
[    0.029560] Mountpoint-cache hash table entries: 8192 (order: 4, 65536 b=
ytes)
[    0.031292] Initializing cgroup subsys devices
[    0.031292] Initializing cgroup subsys devices
[    0.032762] Initializing cgroup subsys freezer
[    0.032762] Initializing cgroup subsys freezer
[    0.034286] Initializing cgroup subsys net_cls
[    0.034286] Initializing cgroup subsys net_cls
[    0.035228] Initializing cgroup subsys blkio
[    0.035228] Initializing cgroup subsys blkio
[    0.036126] Initializing cgroup subsys perf_event
[    0.036126] Initializing cgroup subsys perf_event
[    0.037108] Initializing cgroup subsys debug
[    0.037108] Initializing cgroup subsys debug
[    0.038126] mce: CPU supports 10 MCE banks
[    0.038126] mce: CPU supports 10 MCE banks
[    0.040016] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.040016] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.040016] tlb_flushall_shift: 6
[    0.040016] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.040016] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0, 1GB 0
[    0.040016] tlb_flushall_shift: 6
[    0.043182] CPU:=20
[    0.043182] CPU: Intel Intel QEMU Virtual CPU version 1.7.1QEMU Virtual =
CPU version 1.7.1 (fam: 06, model: 06 (fam: 06, model: 06, stepping: 03)
, stepping: 03)
[    0.050510] ftrace: allocating 63345 entries in 248 pages
[    0.050510] ftrace: allocating 63345 entries in 248 pages
[    0.070215] Performance Events:=20
[    0.070215] Performance Events: Broken PMU hardware detected, using soft=
ware events only.
Broken PMU hardware detected, using software events only.
[    0.081628] Failed to access perfctr msr (MSR c1 is 0)
[    0.081628] Failed to access perfctr msr (MSR c1 is 0)
[    0.083429]=20
[    0.083429] **********************************************************
[    0.083429]=20
[    0.083429] **********************************************************
[    0.090018] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.090018] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.092154] **                                                      **
[    0.092154] **                                                      **
[    0.093549] ** trace_printk() being used. Allocating extra memory.  **
[    0.093549] ** trace_printk() being used. Allocating extra memory.  **
[    0.095420] **                                                      **
[    0.095420] **                                                      **
[    0.097152] ** This means that this is a DEBUG kernel and it is     **
[    0.097152] ** This means that this is a DEBUG kernel and it is     **
[    0.098757] ** unsafe for produciton use.                           **
[    0.098757] ** unsafe for produciton use.                           **
[    0.100011] **                                                      **
[    0.100011] **                                                      **
[    0.101326] ** If you see this message and you are not debugging    **
[    0.101326] ** If you see this message and you are not debugging    **
[    0.102641] ** the kernel, report this immediately to your vendor!  **
[    0.102641] ** the kernel, report this immediately to your vendor!  **
[    0.103945] **                                                      **
[    0.103945] **                                                      **
[    0.105252] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.105252] **   NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE   **
[    0.106580] **********************************************************
[    0.106580] **********************************************************
[    0.111748] Getting VERSION: 50014
[    0.111748] Getting VERSION: 50014
[    0.112459] Getting VERSION: 50014
[    0.112459] Getting VERSION: 50014
[    0.113144] Getting ID: 0
[    0.113144] Getting ID: 0
[    0.113692] Getting ID: ff000000
[    0.113692] Getting ID: ff000000
[    0.114357] Getting LVT0: 8700
[    0.114357] Getting LVT0: 8700
[    0.114975] Getting LVT1: 8400
[    0.114975] Getting LVT1: 8400
[    0.115654] enabled ExtINT on CPU#0
[    0.115654] enabled ExtINT on CPU#0
[    0.117139] ENABLING IO-APIC IRQs
[    0.117139] ENABLING IO-APIC IRQs
[    0.117834] init IO_APIC IRQs
[    0.117834] init IO_APIC IRQs
[    0.118440]  apic 0 pin 0 not connected
[    0.118440]  apic 0 pin 0 not connected
[    0.119230] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.119230] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.120028] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.120028] IOAPIC[0]: Set routing entry (0-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.121774] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.121774] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.123637] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.123637] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.125233] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.125233] IOAPIC[0]: Set routing entry (0-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.126843] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.126843] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.128443] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.128443] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.130025] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.130025] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.131610] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.131610] IOAPIC[0]: Set routing entry (0-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.133631] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.133631] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.136164] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.136164] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.138671] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.138671] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.140043] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.140043] IOAPIC[0]: Set routing entry (0-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.142049] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.142049] IOAPIC[0]: Set routing entry (0-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.143666] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.143666] IOAPIC[0]: Set routing entry (0-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.145793]  apic 0 pin 16 not connected
[    0.145793]  apic 0 pin 16 not connected
[    0.146915]  apic 0 pin 17 not connected
[    0.146915]  apic 0 pin 17 not connected
[    0.150011]  apic 0 pin 18 not connected
[    0.150011]  apic 0 pin 18 not connected
[    0.151158]  apic 0 pin 19 not connected
[    0.151158]  apic 0 pin 19 not connected
[    0.152240]  apic 0 pin 20 not connected
[    0.152240]  apic 0 pin 20 not connected
[    0.153326]  apic 0 pin 21 not connected
[    0.153326]  apic 0 pin 21 not connected
[    0.154615]  apic 0 pin 22 not connected
[    0.154615]  apic 0 pin 22 not connected
[    0.155651]  apic 0 pin 23 not connected
[    0.155651]  apic 0 pin 23 not connected
[    0.156970] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.156970] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.158723] Using local APIC timer interrupts.
[    0.158723] calibrating APIC timer ...
[    0.158723] Using local APIC timer interrupts.
[    0.158723] calibrating APIC timer ...
[    0.170000] ... lapic delta =3D 6251840
[    0.170000] ... lapic delta =3D 6251840
[    0.170000] ... PM-Timer delta =3D 358072
[    0.170000] ... PM-Timer delta =3D 358072
[    0.170000] ... PM-Timer result ok
[    0.170000] ... PM-Timer result ok
[    0.170000] ..... delta 6251840
[    0.170000] ..... delta 6251840
[    0.170000] ..... mult: 268514483
[    0.170000] ..... mult: 268514483
[    0.170000] ..... calibration result: 10002944
[    0.170000] ..... calibration result: 10002944
[    0.170000] ..... CPU clock speed is 2694.3288 MHz.
[    0.170000] ..... CPU clock speed is 2694.3288 MHz.
[    0.170000] ..... host bus clock speed is 1000.2944 MHz.
[    0.170000] ..... host bus clock speed is 1000.2944 MHz.
[    0.170000] xor: measuring software checksum speed
[    0.170000] xor: measuring software checksum speed
[    0.260038]    prefetch64-sse:   110.000 MB/sec
[    0.260038]    prefetch64-sse:   110.000 MB/sec
[    0.360011]    generic_sse:   110.800 MB/sec
[    0.360011]    generic_sse:   110.800 MB/sec
[    0.361014] xor: using function: generic_sse (110.800 MB/sec)
[    0.361014] xor: using function: generic_sse (110.800 MB/sec)
[    0.362327] pinctrl core: initialized pinctrl subsystem
[    0.362327] pinctrl core: initialized pinctrl subsystem
[    0.374190] NET: Registered protocol family 16
[    0.374190] NET: Registered protocol family 16
[    0.377554] cpuidle: using governor menu
[    0.377554] cpuidle: using governor menu
[    0.380428] ACPI: bus type PCI registered
[    0.380428] ACPI: bus type PCI registered
[    0.381392] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.381392] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    0.382998] PCI: Using configuration type 1 for base access
[    0.382998] PCI: Using configuration type 1 for base access
[    0.640019] raid6: sse2x1    6417 MB/s
[    0.640019] raid6: sse2x1    6417 MB/s
[    0.810018] raid6: sse2x2    9523 MB/s
[    0.810018] raid6: sse2x2    9523 MB/s
[    0.980017] raid6: sse2x4   10645 MB/s
[    0.980017] raid6: sse2x4   10645 MB/s
[    0.980972] raid6: using algorithm sse2x4 (10645 MB/s)
[    0.980972] raid6: using algorithm sse2x4 (10645 MB/s)
[    0.982414] raid6: using intx1 recovery algorithm
[    0.982414] raid6: using intx1 recovery algorithm
[    0.983640] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.983640] gpio-f7188x: Not a Fintek device at 0x0000002e
[    0.985187] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.985187] gpio-f7188x: Not a Fintek device at 0x0000004e
[    0.987357] ACPI: Added _OSI(Module Device)
[    0.987357] ACPI: Added _OSI(Module Device)
[    0.988384] ACPI: Added _OSI(Processor Device)
[    0.988384] ACPI: Added _OSI(Processor Device)
[    0.989469] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.989469] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.990011] ACPI: Added _OSI(Processor Aggregator Device)
[    0.990011] ACPI: Added _OSI(Processor Aggregator Device)
[    1.004825] ACPI: Interpreter enabled
[    1.004825] ACPI: Interpreter enabled
[    1.005900] ACPI: (supports S0 S5)
[    1.005900] ACPI: (supports S0 S5)
[    1.006698] ACPI: Using IOAPIC for interrupt routing
[    1.006698] ACPI: Using IOAPIC for interrupt routing
[    1.008133] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.008133] PCI: Using host bridge windows from ACPI; if necessary, use =
"pci=3Dnocrs" and report a bug
[    1.033922] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.033922] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    1.035579] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MS=
I]
[    1.035579] acpi PNP0A03:00: _OSC: OS supports [ASPM ClockPM Segments MS=
I]
[    1.037464] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.037464] acpi PNP0A03:00: _OSC failed (AE_NOT_FOUND); disabling ASPM
[    1.040847] acpiphp: Slot [3] registered
[    1.040847] acpiphp: Slot [3] registered
[    1.042146] acpiphp: Slot [4] registered
[    1.042146] acpiphp: Slot [4] registered
[    1.043292] acpiphp: Slot [5] registered
[    1.043292] acpiphp: Slot [5] registered
[    1.044409] acpiphp: Slot [6] registered
[    1.044409] acpiphp: Slot [6] registered
[    1.045753] acpiphp: Slot [7] registered
[    1.045753] acpiphp: Slot [7] registered
[    1.046842] acpiphp: Slot [8] registered
[    1.046842] acpiphp: Slot [8] registered
[    1.048046] acpiphp: Slot [9] registered
[    1.048046] acpiphp: Slot [9] registered
[    1.049078] acpiphp: Slot [10] registered
[    1.049078] acpiphp: Slot [10] registered
[    1.050121] acpiphp: Slot [11] registered
[    1.050121] acpiphp: Slot [11] registered
[    1.051172] acpiphp: Slot [12] registered
[    1.051172] acpiphp: Slot [12] registered
[    1.052197] acpiphp: Slot [13] registered
[    1.052197] acpiphp: Slot [13] registered
[    1.053422] acpiphp: Slot [14] registered
[    1.053422] acpiphp: Slot [14] registered
[    1.054484] acpiphp: Slot [15] registered
[    1.054484] acpiphp: Slot [15] registered
[    1.055997] acpiphp: Slot [24] registered
[    1.055997] acpiphp: Slot [24] registered
[    1.057015] acpiphp: Slot [25] registered
[    1.057015] acpiphp: Slot [25] registered
[    1.058345] acpiphp: Slot [26] registered
[    1.058345] acpiphp: Slot [26] registered
[    1.059459] acpiphp: Slot [27] registered
[    1.059459] acpiphp: Slot [27] registered
[    1.060135] acpiphp: Slot [28] registered
[    1.060135] acpiphp: Slot [28] registered
[    1.061282] acpiphp: Slot [29] registered
[    1.061282] acpiphp: Slot [29] registered
[    1.062566] acpiphp: Slot [30] registered
[    1.062566] acpiphp: Slot [30] registered
[    1.063664] acpiphp: Slot [31] registered
[    1.063664] acpiphp: Slot [31] registered
[    1.064650] PCI host bridge to bus 0000:00
[    1.064650] PCI host bridge to bus 0000:00
[    1.065861] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.065861] pci_bus 0000:00: root bus resource [bus 00-ff]
[    1.067187] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.067187] pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7]
[    1.068885] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.068885] pci_bus 0000:00: root bus resource [io  0x0d00-0xffff]
[    1.070018] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.070018] pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bfff=
f]
[    1.072387] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfebffff=
f]
[    1.072387] pci_bus 0000:00: root bus resource [mem 0xe0000000-0xfebffff=
f]
[    1.074824] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.074824] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    1.080013] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.080013] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    1.083670] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.083670] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    1.087934] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    1.087934] pci 0000:00:01.1: reg 0x20: [io  0xc1c0-0xc1cf]
[    1.090322] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.090322] pci 0000:00:01.1: legacy IDE quirk: reg 0x10: [io  0x01f0-0x=
01f7]
[    1.091927] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.091927] pci 0000:00:01.1: legacy IDE quirk: reg 0x14: [io  0x03f6]
[    1.093419] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.093419] pci 0000:00:01.1: legacy IDE quirk: reg 0x18: [io  0x0170-0x=
0177]
[    1.095031] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.095031] pci 0000:00:01.1: legacy IDE quirk: reg 0x1c: [io  0x0376]
[    1.097316] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.097316] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    1.099056] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.099056] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    1.100022] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.100022] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    1.102523] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.102523] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    1.110802] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.110802] pci 0000:00:02.0: reg 0x10: [mem 0xfc000000-0xfdffffff pref]
[    1.120076] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.120076] pci 0000:00:02.0: reg 0x14: [mem 0xfebf0000-0xfebf0fff]
[    1.129673] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.129673] pci 0000:00:02.0: reg 0x30: [mem 0xfebe0000-0xfebeffff pref]
[    1.131776] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.131776] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    1.134704] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.134704] pci 0000:00:03.0: reg 0x10: [mem 0xfeba0000-0xfebbffff]
[    1.137598] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.137598] pci 0000:00:03.0: reg 0x14: [io  0xc000-0xc03f]
[    1.145730] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.145730] pci 0000:00:03.0: reg 0x30: [mem 0xfebc0000-0xfebdffff pref]
[    1.148202] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    1.148202] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    1.151125] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    1.151125] pci 0000:00:04.0: reg 0x10: [io  0xc040-0xc07f]
[    1.153564] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    1.153564] pci 0000:00:04.0: reg 0x14: [mem 0xfebf1000-0xfebf1fff]
[    1.162077] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.162077] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    1.164646] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.164646] pci 0000:00:05.0: reg 0x10: [io  0xc080-0xc0bf]
[    1.167040] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.167040] pci 0000:00:05.0: reg 0x14: [mem 0xfebf2000-0xfebf2fff]
[    1.176084] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.176084] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    1.178801] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.178801] pci 0000:00:06.0: reg 0x10: [io  0xc0c0-0xc0ff]
[    1.181192] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.181192] pci 0000:00:06.0: reg 0x14: [mem 0xfebf3000-0xfebf3fff]
[    1.190702] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.190702] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    1.193562] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.193562] pci 0000:00:07.0: reg 0x10: [io  0xc100-0xc13f]
[    1.195927] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.195927] pci 0000:00:07.0: reg 0x14: [mem 0xfebf4000-0xfebf4fff]
[    1.204819] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.204819] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    1.207284] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.207284] pci 0000:00:08.0: reg 0x10: [io  0xc140-0xc17f]
[    1.209655] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.209655] pci 0000:00:08.0: reg 0x14: [mem 0xfebf5000-0xfebf5fff]
[    1.217227] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.217227] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    1.221093] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.221093] pci 0000:00:09.0: reg 0x10: [io  0xc180-0xc1bf]
[    1.223420] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.223420] pci 0000:00:09.0: reg 0x14: [mem 0xfebf6000-0xfebf6fff]
[    1.232316] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    1.232316] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    1.234308] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    1.234308] pci 0000:00:0a.0: reg 0x10: [mem 0xfebf7000-0xfebf700f]
[    1.240447] pci_bus 0000:00: on NUMA node 0
[    1.240447] pci_bus 0000:00: on NUMA node 0
[    1.243781] ACPI: PCI Interrupt Link [LNKA] (IRQs
[    1.243781] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 5 *10 *10 11 11))

[    1.245861] ACPI: PCI Interrupt Link [LNKB] (IRQs
[    1.245861] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 5 *10 *10 11 11))

[    1.247672] ACPI: PCI Interrupt Link [LNKC] (IRQs
[    1.247672] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 5 10 10 *11 *11))

[    1.249437] ACPI: PCI Interrupt Link [LNKD] (IRQs
[    1.249437] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 5 10 10 *11 *11))

[    1.250537] ACPI: PCI Interrupt Link [LNKS] (IRQs
[    1.250537] ACPI: PCI Interrupt Link [LNKS] (IRQs *9 *9))

[    1.254249] ACPI:=20
[    1.254249] ACPI: Enabled 16 GPEs in block 00 to 0FEnabled 16 GPEs in bl=
ock 00 to 0F

[    1.258013] SCSI subsystem initialized
[    1.258013] SCSI subsystem initialized
[    1.259200] libata version 3.00 loaded.
[    1.259200] libata version 3.00 loaded.
[    1.260655] Linux video capture interface: v2.00
[    1.260655] Linux video capture interface: v2.00
[    1.262130] pps_core: LinuxPPS API ver. 1 registered
[    1.262130] pps_core: LinuxPPS API ver. 1 registered
[    1.263359] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.263359] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    1.265911] PTP clock support registered
[    1.265911] PTP clock support registered
[    1.267488] wmi: Mapper loaded
[    1.267488] wmi: Mapper loaded
[    1.268413] Advanced Linux Sound Architecture Driver Initialized.
[    1.268413] Advanced Linux Sound Architecture Driver Initialized.
[    1.270019] PCI: Using ACPI for IRQ routing
[    1.270019] PCI: Using ACPI for IRQ routing
[    1.271095] PCI: pci_cache_line_size set to 64 bytes
[    1.271095] PCI: pci_cache_line_size set to 64 bytes
[    1.272567] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.272567] e820: reserve RAM buffer [mem 0x0009fc00-0x0009ffff]
[    1.274973] e820: reserve RAM buffer [mem 0xdfffe000-0xdfffffff]
[    1.274973] e820: reserve RAM buffer [mem 0xdfffe000-0xdfffffff]
[    1.277821] irda_init()
[    1.277821] irda_init()
[    1.278628] NET: Registered protocol family 23
[    1.278628] NET: Registered protocol family 23
[    1.280057] Bluetooth: Core ver 2.19
[    1.280057] Bluetooth: Core ver 2.19
[    1.281130] NET: Registered protocol family 31
[    1.281130] NET: Registered protocol family 31
[    1.282291] Bluetooth: HCI device and connection manager initialized
[    1.282291] Bluetooth: HCI device and connection manager initialized
[    1.284072] Bluetooth: HCI socket layer initialized
[    1.284072] Bluetooth: HCI socket layer initialized
[    1.285247] Bluetooth: L2CAP socket layer initialized
[    1.285247] Bluetooth: L2CAP socket layer initialized
[    1.286541] Bluetooth: SCO socket layer initialized
[    1.286541] Bluetooth: SCO socket layer initialized
[    1.287804] NET: Registered protocol family 8
[    1.287804] NET: Registered protocol family 8
[    1.288897] NET: Registered protocol family 20
[    1.288897] NET: Registered protocol family 20
[    1.291623] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.291623] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    1.293608] Switched to clocksource kvm-clock
[    1.293608] Switched to clocksource kvm-clock
[    1.295559] Warning: could not register annotated branches stats
[    1.295559] Warning: could not register annotated branches stats
[    1.425441] FS-Cache: Loaded
[    1.425441] FS-Cache: Loaded
[    1.426372] CacheFiles: Loaded
[    1.426372] CacheFiles: Loaded
[    1.427223] pnp: PnP ACPI init
[    1.427223] pnp: PnP ACPI init
[    1.428052] ACPI: bus type PNP registered
[    1.428052] ACPI: bus type PNP registered
[    1.429128] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    1.429128] IOAPIC[0]: Set routing entry (0-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    1.431234] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.431234] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.432850] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.432850] IOAPIC[0]: Set routing entry (0-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    1.434842] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.434842] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.436366] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.436366] IOAPIC[0]: Set routing entry (0-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    1.438193] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.438193] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.439764] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.439764] IOAPIC[0]: Set routing entry (0-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    1.441607] pnp 00:03: [dma 2]
[    1.441607] pnp 00:03: [dma 2]
[    1.442411] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.442411] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.444098] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.444098] IOAPIC[0]: Set routing entry (0-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    1.446446] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.446446] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.448485] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.448485] IOAPIC[0]: Set routing entry (0-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    1.450627] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.450627] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.452532] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    1.452532] IOAPIC[0]: Set routing entry (0-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    1.454486] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.454486] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.457260] pnp: PnP ACPI: found 7 devices
[    1.457260] pnp: PnP ACPI: found 7 devices
[    1.458211] ACPI: bus type PNP unregistered
[    1.458211] ACPI: bus type PNP unregistered
[    1.466293] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.466293] pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7]
[    1.468064] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.468064] pci_bus 0000:00: resource 5 [io  0x0d00-0xffff]
[    1.469384] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.469384] pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff]
[    1.471175] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfebfffff]
[    1.471175] pci_bus 0000:00: resource 7 [mem 0xe0000000-0xfebfffff]
[    1.473024] NET: Registered protocol family 2
[    1.473024] NET: Registered protocol family 2
[    1.474607] TCP established hash table entries: 32768 (order: 6, 262144 =
bytes)
[    1.474607] TCP established hash table entries: 32768 (order: 6, 262144 =
bytes)
[    1.477993] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.477993] TCP bind hash table entries: 32768 (order: 9, 2621440 bytes)
[    1.485205] TCP: Hash tables configured (established 32768 bind 32768)
[    1.485205] TCP: Hash tables configured (established 32768 bind 32768)
[    1.487261] TCP: reno registered
[    1.487261] TCP: reno registered
[    1.488074] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.488074] UDP hash table entries: 2048 (order: 6, 393216 bytes)
[    1.490076] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.490076] UDP-Lite hash table entries: 2048 (order: 6, 393216 bytes)
[    1.492357] NET: Registered protocol family 1
[    1.492357] NET: Registered protocol family 1
[    1.493778] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.493778] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.495913] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.495913] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.497434] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.497434] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.498850] pci 0000:00:02.0: Boot video device
[    1.498850] pci 0000:00:02.0: Boot video device
[    1.499960] PCI: CLS 0 bytes, default 64
[    1.499960] PCI: CLS 0 bytes, default 64
[    1.501426] Unpacking initramfs...
[    1.501426] Unpacking initramfs...
[    6.327087] debug: unmapping init [mem 0xffff8800787d8000-0xffff88007fff=
ffff]
[    6.327087] debug: unmapping init [mem 0xffff8800787d8000-0xffff88007fff=
ffff]
[    6.330583] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    6.330583] PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
[    6.332045] software IO TLB [mem 0xdbffe000-0xdfffe000] (64MB) mapped at=
 [ffff8800dbffe000-ffff8800dfffdfff]
[    6.332045] software IO TLB [mem 0xdbffe000-0xdfffe000] (64MB) mapped at=
 [ffff8800dbffe000-ffff8800dfffdfff]
[    6.342259] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/usab=
le.
[    6.342259] sha1_ssse3: Neither AVX nor AVX2 nor SSSE3 is available/usab=
le.
[    6.343877] PCLMULQDQ-NI instructions are not detected.
[    6.343877] PCLMULQDQ-NI instructions are not detected.
[    6.345065] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.345065] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.346496] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.346496] sha512_ssse3: Neither AVX nor SSSE3 is available/usable.
[    6.348057] AVX instructions are not detected.
[    6.348057] AVX instructions are not detected.
[    6.349065] AVX instructions are not detected.
[    6.349065] AVX instructions are not detected.
[    6.350117] AVX instructions are not detected.
[    6.350117] AVX instructions are not detected.
[    6.351143] AVX2 instructions are not detected.
[    6.351143] AVX2 instructions are not detected.
[    6.353209] futex hash table entries: 256 (order: 2, 24576 bytes)
[    6.353209] futex hash table entries: 256 (order: 2, 24576 bytes)
[    6.354651] Initialise system trusted keyring
[    6.354651] Initialise system trusted keyring
[    6.363138] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    6.363138] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    6.365006] VFS: Disk quotas dquot_6.5.2
[    6.365006] VFS: Disk quotas dquot_6.5.2
[    6.365927] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    6.365927] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    6.369258] efs: 1.0a - http://aeschi.ch.eu.org/efs/
[    6.369258] efs: 1.0a - http://aeschi.ch.eu.org/efs/
[    6.370419] QNX6 filesystem 1.0.0 registered.
[    6.370419] QNX6 filesystem 1.0.0 registered.
[    6.371590] fuse init (API version 7.23)
[    6.371590] fuse init (API version 7.23)
[    6.372866] SGI XFS with security attributes, realtime, large block/inod=
e numbers, debug enabled
[    6.372866] SGI XFS with security attributes, realtime, large block/inod=
e numbers, debug enabled
[    6.375241] 9p: Installing v9fs 9p2000 file system support
[    6.375241] 9p: Installing v9fs 9p2000 file system support
[    6.376527] FS-Cache: Netfs '9p' registered for caching
[    6.376527] FS-Cache: Netfs '9p' registered for caching
[    6.377880] NILFS version 2 loaded
[    6.377880] NILFS version 2 loaded
[    6.378821] ocfs2 stack glue: unable to register sysctl
[    6.378821] ocfs2 stack glue: unable to register sysctl
[    6.380267] OCFS2 User DLM kernel interface loaded
[    6.380267] OCFS2 User DLM kernel interface loaded
[    6.383946] gfs2: GFS2 installed
[    6.383946] gfs2: GFS2 installed
[    6.384778] FS-Cache: Netfs 'ceph' registered for caching
[    6.384778] FS-Cache: Netfs 'ceph' registered for caching
[    6.386013] ceph: loaded (mds proto 32)
[    6.386013] ceph: loaded (mds proto 32)
[    6.386945] msgmni has been set to 7566
[    6.386945] msgmni has been set to 7566
[    6.387912] Key type big_key registered
[    6.387912] Key type big_key registered
[    6.405866] alg: No test for lz4 (lz4-generic)
[    6.405866] alg: No test for lz4 (lz4-generic)
[    6.407025] alg: No test for stdrng (krng)
[    6.407025] alg: No test for stdrng (krng)
[    6.414719] NET: Registered protocol family 38
[    6.414719] NET: Registered protocol family 38
[    6.415806] Key type asymmetric registered
[    6.415806] Key type asymmetric registered
[    6.416764] Asymmetric key parser 'x509' registered
[    6.416764] Asymmetric key parser 'x509' registered
[    6.417924] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    6.417924] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[    6.419808] io scheduler noop registered
[    6.419808] io scheduler noop registered
[    6.420764] io scheduler deadline registered
[    6.420764] io scheduler deadline registered
[    6.421769] io scheduler cfq registered (default)
[    6.421769] io scheduler cfq registered (default)
[    6.422861] start plist test
[    6.422861] start plist test
[    6.425896] end plist test
[    6.425896] end plist test
[    6.427988] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    6.427988] crc32: CRC_LE_BITS =3D 8, CRC_BE BITS =3D 8
[    6.429112] crc32: self tests passed, processed 225944 bytes in 679349 n=
sec
[    6.429112] crc32: self tests passed, processed 225944 bytes in 679349 n=
sec
[    6.431346] crc32c: CRC_LE_BITS =3D 8
[    6.431346] crc32c: CRC_LE_BITS =3D 8
[    6.432151] crc32c: self tests passed, processed 225944 bytes in 329261 =
nsec
[    6.432151] crc32c: self tests passed, processed 225944 bytes in 329261 =
nsec
[    6.467872] crc32_combine: 8373 self tests passed
[    6.467872] crc32_combine: 8373 self tests passed
[    6.532730] crc32c_combine: 8373 self tests passed
[    6.532730] crc32c_combine: 8373 self tests passed
[    6.537788] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.537788] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.539931] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    6.539931] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    6.542850] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.542850] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.550577] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    6.550577] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    6.554803] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    6.554803] cr_bllcd: INTEL CARILLO RANCH LPC not found.
[    6.556519] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    6.556519] cr_bllcd: Carillo Ranch Backlight Driver Initialized.
[    6.559576] rivafb_setup START
[    6.559576] rivafb_setup START
[    6.561042] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    6.561042] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    6.564195] vmlfb: initializing
[    6.564195] vmlfb: initializing
[    6.565566] Could not find Carillo Ranch MCH device.
[    6.565566] Could not find Carillo Ranch MCH device.
[    6.567191] no IO addresses supplied
[    6.567191] no IO addresses supplied
[    6.568927] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM =
(4096 kB) at 0xfc000000
[    6.568927] cirrusfb 0000:00:02.0: Cirrus Logic chipset on PCI bus, RAM =
(4096 kB) at 0xfc000000
[    6.574158] ipmi message handler version 39.2
[    6.574158] ipmi message handler version 39.2
[    6.575906] ipmi device interface
[    6.575906] ipmi device interface
[    6.577885] IPMI System Interface driver.
[    6.577885] IPMI System Interface driver.
[    6.579655] ipmi_si: Adding default-specified kcs state machine
[    6.579655] ipmi_si: Adding default-specified kcs state machine

[    6.582065] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    6.582065] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    6.585553] ipmi_si: Interface detection failed
[    6.585553] ipmi_si: Interface detection failed
[    6.587369] ipmi_si: Adding default-specified smic state machine
[    6.587369] ipmi_si: Adding default-specified smic state machine

[    6.589339] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    6.589339] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    6.593280] ipmi_si: Interface detection failed
[    6.593280] ipmi_si: Interface detection failed
[    6.594868] ipmi_si: Adding default-specified bt state machine
[    6.594868] ipmi_si: Adding default-specified bt state machine

[    6.596971] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    6.596971] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    6.600834] ipmi_si: Interface detection failed
[    6.600834] ipmi_si: Interface detection failed
[    6.602158] ipmi_si: Unable to find any System Interface(s)
[    6.602158] ipmi_si: Unable to find any System Interface(s)
[    6.604224] IPMI Watchdog: driver initialized
[    6.604224] IPMI Watchdog: driver initialized
[    6.605907] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    6.605907] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    6.610785] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    6.610785] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    6.613291] ACPI: Power Button [PWRF]
[    6.613291] ACPI: Power Button [PWRF]
[    6.616426] ERST DBG: ERST support is disabled.
[    6.616426] ERST DBG: ERST support is disabled.
[    6.620826] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    6.620826] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    6.622965] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    6.622965] IOAPIC[0]: Set routing entry (0-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    6.630454] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    6.630454] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    6.632633] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    6.632633] IOAPIC[0]: Set routing entry (0-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    6.640105] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    6.640105] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    6.647541] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    6.647541] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    6.663916] r3964: Philips r3964 Driver $Revision: 1.10 $
[    6.663916] r3964: Philips r3964 Driver $Revision: 1.10 $
[    6.665418] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    6.665418] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    6.697198] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    6.697198] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4, base_baud =3D 115200) =
is a 16550A
[    6.703807] serial: Freescale lpuart driver
[    6.703807] serial: Freescale lpuart driver
[    6.705474] Cyclades driver 2.6
[    6.705474] Cyclades driver 2.6
[    6.706746] MOXA Smartio/Industio family driver version 2.0.5
[    6.706746] MOXA Smartio/Industio family driver version 2.0.5
[    6.708933] SyncLink GT
[    6.708933] SyncLink GT
[    6.709834] SyncLink GT, tty major#244
[    6.709834] SyncLink GT, tty major#244
[    6.711363] SyncLink GT no devices found
[    6.711363] SyncLink GT no devices found
[    6.712765] SyncLink MultiPort driver $Revision: 4.38 $
[    6.712765] SyncLink MultiPort driver $Revision: 4.38 $
[    6.739475] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[    6.739475] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[    6.742463] lp: driver loaded but no devices found
[    6.742463] lp: driver loaded but no devices found
[    6.744147] Non-volatile memory driver v1.3
[    6.744147] Non-volatile memory driver v1.3
[    6.746020] ppdev: user-space parallel port driver
[    6.746020] ppdev: user-space parallel port driver
[    6.747564] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    6.747564] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    6.749189] smapi::smapi_init, ERROR invalid usSmapiID
[    6.749189] smapi::smapi_init, ERROR invalid usSmapiID
[    6.750843] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    6.750843] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    6.753742] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    6.753742] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    6.755997] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    6.755997] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    6.757959] Linux agpgart interface v0.103
[    6.757959] Linux agpgart interface v0.103
[    6.760262] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    6.760262] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    6.763049] Hangcheck: Using getrawmonotonic().
[    6.763049] Hangcheck: Using getrawmonotonic().
[    6.765354] [drm] Initialized drm 1.1.0 20060810
[    6.765354] [drm] Initialized drm 1.1.0 20060810
[    6.781917] loop: module loaded
[    6.781917] loop: module loaded
[    6.783037] HP CISS Driver (v 3.6.26)
[    6.783037] HP CISS Driver (v 3.6.26)
[    6.785176] skd:  v2.2.1-b0260 loaded
[    6.785176] skd:  v2.2.1-b0260 loaded
[    6.793963] nbd: registered device at major 43
[    6.793963] nbd: registered device at major 43
[    6.819722] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[    6.819722] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[    6.821764] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[    6.821764] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[    6.827662]  vda: unknown partition table
[    6.827662]  vda: unknown partition table
[    6.831817] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[    6.831817] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[    6.835563] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[    6.835563] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[    6.841315]  vdb: unknown partition table
[    6.841315]  vdb: unknown partition table
[    6.846895] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[    6.846895] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[    6.849017] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[    6.849017] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[    6.853909]  vdc: unknown partition table
[    6.853909]  vdc: unknown partition table
[    6.856721] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[    6.856721] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[    6.858663] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[    6.858663] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[    6.864984]  vdd: unknown partition table
[    6.864984]  vdd: unknown partition table
[    6.870182] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[    6.870182] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[    6.872089] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[    6.872089] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[    6.877137]  vde: unknown partition table
[    6.877137]  vde: unknown partition table
[    6.881497] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[    6.881497] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[    6.883437] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[    6.883437] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[    6.890076]  vdf: unknown partition table
[    6.890076]  vdf: unknown partition table
[    6.895004] rbd: loaded
[    6.895004] rbd: loaded
[    6.897430]  nullb0: unknown partition table
[    6.897430]  nullb0: unknown partition table
[    6.900970]  nullb1: unknown partition table
[    6.900970]  nullb1: unknown partition table
[    6.902956] null: module loaded
[    6.902956] null: module loaded
[    6.904162] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    6.904162] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    6.907552] lkdtm: No crash points registered, enable through debugfs
[    6.907552] lkdtm: No crash points registered, enable through debugfs
[    6.913236] Guest personality initialized and is inactive
[    6.913236] Guest personality initialized and is inactive
[    6.915568] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D60)
[    6.915568] VMCI host device registered (name=3Dvmci, major=3D10, minor=
=3D60)
[    6.918098] Initialized host personality
[    6.918098] Initialized host personality
[    6.921477] Uniform Multi-Platform E-IDE driver
[    6.921477] Uniform Multi-Platform E-IDE driver
[    6.925703] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    6.925703] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    6.929076] ide-gd driver 1.18
[    6.929076] ide-gd driver 1.18
[    6.930119] ide-cd driver 5.00
[    6.930119] ide-cd driver 5.00
[    6.932859] Loading iSCSI transport class v2.0-870.
[    6.932859] Loading iSCSI transport class v2.0-870.
[    6.935858] emc: device handler registered
[    6.935858] emc: device handler registered
[    6.937132] alua: device handler registered
[    6.937132] alua: device handler registered
[    6.939245] fnic: Cisco FCoE HBA Driver, ver 1.6.0.10
[    6.939245] fnic: Cisco FCoE HBA Driver, ver 1.6.0.10
[    6.941233] fnic: Successfully Initialized Trace Buffer
[    6.941233] fnic: Successfully Initialized Trace Buffer
[    6.943626] fnic: Successfully Initialized FC_CTLR Trace Buffer
[    6.943626] fnic: Successfully Initialized FC_CTLR Trace Buffer
[    6.946712] iscsi: registered transport (tcp)
[    6.946712] iscsi: registered transport (tcp)
[    6.949847] Adaptec aacraid driver 1.2-0[30300]-ms
[    6.949847] Adaptec aacraid driver 1.2-0[30300]-ms
[    6.951776] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    6.951776] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    6.954482] scsi: <fdomain> Detection failed (no card)
[    6.954482] scsi: <fdomain> Detection failed (no card)
[    6.956566] iscsi: registered transport (qla4xxx)
[    6.956566] iscsi: registered transport (qla4xxx)
[    6.958383] QLogic iSCSI HBA Driver
[    6.958383] QLogic iSCSI HBA Driver
[    6.959645] Brocade BFA FC/FCOE SCSI driver - version: 3.2.23.0
[    6.959645] Brocade BFA FC/FCOE SCSI driver - version: 3.2.23.0
[    6.961214] csiostor: Chelsio FCoE driver 1.0.0
[    6.961214] csiostor: Chelsio FCoE driver 1.0.0
[    6.962827] DC390: clustering now enabled by default. If you get problem=
s load
[    6.962827] DC390: clustering now enabled by default. If you get problem=
s load
[    6.964490]        with "disable_clustering=3D1" and report to maintaine=
rs
[    6.964490]        with "disable_clustering=3D1" and report to maintaine=
rs
[    6.966347] mpt3sas version 02.100.00.00 loaded
[    6.966347] mpt3sas version 02.100.00.00 loaded
[    6.967730] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    6.967730] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    6.969423] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[    6.969423] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[    6.971177] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (Novem=
ber 16, 2012)
[    6.971177] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (Novem=
ber 16, 2012)
[    6.973176] RocketRAID 3xxx/4xxx Controller driver v1.8
[    6.973176] RocketRAID 3xxx/4xxx Controller driver v1.8
[    6.975001] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    6.975001] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    6.977799] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age =
0xf, 4 bits.
[    6.977799] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age =
0xf, 4 bits.
[    6.980786] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx=
 0.
[    6.980786] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx=
 0.
[    6.983414] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[    6.983414] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[    6.985936] iscsi: registered transport (cxgb3i)
[    6.985936] iscsi: registered transport (cxgb3i)
[    6.987727] Chelsio T4/T5 iSCSI Driver cxgb4i v0.9.4
[    6.987727] Chelsio T4/T5 iSCSI Driver cxgb4i v0.9.4
[    6.989875] iscsi: registered transport (cxgb4i)
[    6.989875] iscsi: registered transport (cxgb4i)
[    6.991722] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.6.2 (Jun 06, 2=
013)
[    6.991722] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.6.2 (Jun 06, 2=
013)
[    6.994590] iscsi: registered transport (bnx2i)
[    6.994590] iscsi: registered transport (bnx2i)
[    6.996005] iscsi: registered transport (be2iscsi)
[    6.996005] iscsi: registered transport (be2iscsi)
[    6.997124] In beiscsi_module_init, tt=3Dffffffff88ad6a10
[    6.997124] In beiscsi_module_init, tt=3Dffffffff88ad6a10
[    6.998564] esas2r: driver will not be loaded because no ATTO esas2r dev=
ices were found
[    6.998564] esas2r: driver will not be loaded because no ATTO esas2r dev=
ices were found
[    7.001859] VMware PVSCSI driver - version 1.0.5.0-k
[    7.001859] VMware PVSCSI driver - version 1.0.5.0-k
[    7.003196] osst :I: Tape driver with OnStream support version 0.99.4
[    7.003196] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    7.003196] osst :I: Tape driver with OnStream support version 0.99.4
[    7.003196] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    7.007284] SCSI Media Changer driver v0.25=20
[    7.007284] SCSI Media Changer driver v0.25=20
[    7.031869] scsi_debug: host protection
[    7.031869] scsi_debug: host protection
[    7.033281] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    7.033281] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    7.038741] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    7.038741] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    7.045763] scsi 0:0:0:0: Attached scsi generic sg0 type 0
[    7.045763] scsi 0:0:0:0: Attached scsi generic sg0 type 0
[    7.052374] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    7.052374] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[    7.056494] HSI/SSI char device loaded
[    7.056494] HSI/SSI char device loaded
[    7.061340] arcnet loaded.
[    7.061340] arcnet loaded.
[    7.062379] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[    7.062379] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[    7.064906] arcnet: COM90xx chipset support
[    7.064906] arcnet: COM90xx chipset support
[    7.066748] S1: No ARCnet cards found.
[    7.066748] S1: No ARCnet cards found.
[    7.068152] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[    7.068152] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[    7.070805] E-mail me if you actually test this driver, please!
[    7.070805] E-mail me if you actually test this driver, please!
[    7.072940]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[    7.072940]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[    7.075812] arcnet: RIM I (entirely mem-mapped) support
[    7.075812] arcnet: RIM I (entirely mem-mapped) support
[    7.077670] E-mail me if you actually test the RIM I driver, please!
[    7.077670] E-mail me if you actually test the RIM I driver, please!
[    7.079969] Given: node 00h, shmem 0h, irq 0
[    7.079969] Given: node 00h, shmem 0h, irq 0
[    7.081127] No autoprobe for RIM I; you must specify the shmem and irq!
[    7.081127] No autoprobe for RIM I; you must specify the shmem and irq!
[    7.082662] arcnet: COM20020 PCI support
[    7.082662] arcnet: COM20020 PCI support
[    7.084037] vcan: Virtual CAN interface driver
[    7.084037] vcan: Virtual CAN interface driver
[    7.085228] slcan: serial line CAN interface driver
[    7.085228] slcan: serial line CAN interface driver
[    7.086381] slcan: 10 dynamic interface channels.
[    7.086381] slcan: 10 dynamic interface channels.
[    7.087517] CAN device driver interface
[    7.087517] CAN device driver interface
[    7.088386] sja1000 CAN netdevice driver
[    7.088386] sja1000 CAN netdevice driver
[    7.089283] sja1000_isa: insufficient parameters supplied
[    7.089283] sja1000_isa: insufficient parameters supplied
[    7.091302] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[    7.091302] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[    7.093909] cnic: QLogic NetXtreme II CNIC Driver cnic v2.5.20 (March 14=
, 2014)
[    7.093909] cnic: QLogic NetXtreme II CNIC Driver cnic v2.5.20 (March 14=
, 2014)
[    7.096508] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.19-0 (2014/02/10)
[    7.096508] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.19-0 (2014/02/10)
[    7.102599] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.67
[    7.102599] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.67
[    7.105307] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    7.105307] jme: JMicron JMC2XX ethernet driver version 1.0.8
[    7.109828] Solarflare NET driver v4.0
[    7.109828] Solarflare NET driver v4.0
[    7.111714] tlan: ThunderLAN driver v1.17
[    7.111714] tlan: ThunderLAN driver v1.17
[    7.113263] tlan: 0 devices installed, PCI: 0  EISA: 0
[    7.113263] tlan: 0 devices installed, PCI: 0  EISA: 0
[    7.115494] PPP generic driver version 2.4.2
[    7.115494] PPP generic driver version 2.4.2
[    7.117328] PPP BSD Compression module registered
[    7.117328] PPP BSD Compression module registered
[    7.119081] PPP Deflate Compression module registered
[    7.119081] PPP Deflate Compression module registered
[    7.120978] PPP MPPE Compression module registered
[    7.120978] PPP MPPE Compression module registered
[    7.122723] NET: Registered protocol family 24
[    7.122723] NET: Registered protocol family 24
[    7.124412] PPTP driver version 0.8.5
[    7.124412] PPTP driver version 0.8.5
[    7.127037] LAPB Ethernet driver version 0.02
[    7.127037] LAPB Ethernet driver version 0.02
[    7.128688] VMware vmxnet3 virtual NIC driver - version 1.2.0.0-k-NAPI
[    7.128688] VMware vmxnet3 virtual NIC driver - version 1.2.0.0-k-NAPI
[    7.131230] Fusion MPT base driver 3.04.20
[    7.131230] Fusion MPT base driver 3.04.20
[    7.132857] Copyright (c) 1999-2008 LSI Corporation
[    7.132857] Copyright (c) 1999-2008 LSI Corporation
[    7.134641] Fusion MPT SPI Host driver 3.04.20
[    7.134641] Fusion MPT SPI Host driver 3.04.20
[    7.136543] Fusion MPT FC Host driver 3.04.20
[    7.136543] Fusion MPT FC Host driver 3.04.20
[    7.138476] Fusion MPT SAS Host driver 3.04.20
[    7.138476] Fusion MPT SAS Host driver 3.04.20
[    7.140596] Fusion MPT misc device (ioctl) driver 3.04.20
[    7.140596] Fusion MPT misc device (ioctl) driver 3.04.20
[    7.143024] mptctl: Registered with Fusion MPT base driver
[    7.143024] mptctl: Registered with Fusion MPT base driver
[    7.145052] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[    7.145052] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[    7.151186] aoe: AoE v85 initialised.
[    7.151186] aoe: AoE v85 initialised.
[    7.154177] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.154177] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[    7.158743] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.158743] serio: i8042 KBD port at 0x60,0x64 irq 1
[    7.160734] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.160734] serio: i8042 AUX port at 0x60,0x64 irq 12
[    7.168998] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.168998] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[    7.176811] mk712: device not present
[    7.176811] mk712: device not present
[    7.185413] i2c-parport-light: adapter type unspecified
[    7.185413] i2c-parport-light: adapter type unspecified
[    7.194668] pps pps0: new PPS source ktimer
[    7.194668] pps pps0: new PPS source ktimer
[    7.196113] pps pps0: ktimer PPS source registered
[    7.196113] pps pps0: ktimer PPS source registered
[    7.197924] pps_parport: parallel port PPS client
[    7.197924] pps_parport: parallel port PPS client
[    7.199879] Driver for 1-wire Dallas network protocol.
[    7.199879] Driver for 1-wire Dallas network protocol.
[    7.202941] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.202941] DS1WM w1 busmaster driver - (c) 2004 Szabolcs Gyurko
[    7.214660] pc87360: PC8736x not detected, module not inserted
[    7.214660] pc87360: PC8736x not detected, module not inserted
[    7.216861] sch56xx_common: Unsupported device id: 0xff
[    7.216861] sch56xx_common: Unsupported device id: 0xff
[    7.218798] sch56xx_common: Unsupported device id: 0xff
[    7.218798] sch56xx_common: Unsupported device id: 0xff
[    7.221855] intel_powerclamp: Intel powerclamp does not run on family 6 =
model 6
[    7.221855] intel_powerclamp: Intel powerclamp does not run on family 6 =
model 6
[    7.224896] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    7.224896] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[    7.228453] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    7.228453] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[    7.230828] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[    7.230828] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[    7.232835] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[    7.232835] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[    7.235157] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    7.235157] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[    7.238131] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[    7.238131] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[    7.241260] ib700wdt: START method I/O 443 is not available
[    7.241260] ib700wdt: START method I/O 443 is not available
[    7.243338] ib700wdt: probe of ib700wdt failed with error -5
[    7.243338] ib700wdt: probe of ib700wdt failed with error -5
[    7.245959] it87_wdt: no device
[    7.245959] it87_wdt: no device
[    7.247142] nv_tco: NV TCO WatchDog Timer Driver v0.01
[    7.247142] nv_tco: NV TCO WatchDog Timer Driver v0.01
[    7.249709] sbc60xxwdt: I/O address 0x0443 already in use
[    7.249709] sbc60xxwdt: I/O address 0x0443 already in use
[    7.251750] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    7.251750] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[    7.255749] smsc37b787_wdt: Unable to register miscdev on minor 130
[    7.255749] smsc37b787_wdt: Unable to register miscdev on minor 130
[    7.258141] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    7.258141] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    7.260386] machzwd: no ZF-Logic found
[    7.260386] machzwd: no ZF-Logic found
[    7.261784] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.261784] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[    7.264992] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    7.264992] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[    7.267966] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    7.267966] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[    7.271392] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    7.271392] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[    7.275431] Bluetooth: HCI UART driver ver 2.2
[    7.275431] Bluetooth: HCI UART driver ver 2.2
[    7.277087] Bluetooth: HCI H4 protocol initialized
[    7.277087] Bluetooth: HCI H4 protocol initialized
[    7.278851] Bluetooth: HCI BCSP protocol initialized
[    7.278851] Bluetooth: HCI BCSP protocol initialized
[    7.280724] Bluetooth: HCILL protocol initialized
[    7.280724] Bluetooth: HCILL protocol initialized
[    7.282466] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[    7.282466] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[    7.285092] sdhci: Secure Digital Host Controller Interface driver
[    7.285092] sdhci: Secure Digital Host Controller Interface driver
[    7.287268] sdhci: Copyright(c) Pierre Ossman
[    7.287268] sdhci: Copyright(c) Pierre Ossman
[    7.289481] sdhci-pltfm: SDHCI platform and OF driver helper
[    7.289481] sdhci-pltfm: SDHCI platform and OF driver helper
[    7.300410] rdma_ucm: couldn't register sysctl paths
[    7.300410] rdma_ucm: couldn't register sysctl paths
[    7.303420] ib_qib: Unable to register ipathfs
[    7.303420] ib_qib: Unable to register ipathfs
[    7.306056] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    7.306056] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[    7.308813] No iBFT detected.
[    7.308813] No iBFT detected.
[    7.311560] alg: skcipher: encryption failed on test 1 for ecb-aes-ccp: =
ret=3D19
[    7.311560] alg: skcipher: encryption failed on test 1 for ecb-aes-ccp: =
ret=3D19
[    7.318412] alg: hash: digest failed on test 1 for cmac-aes-ccp: ret=3D19
[    7.318412] alg: hash: digest failed on test 1 for cmac-aes-ccp: ret=3D19
[    7.321513] alg: hash: digest failed on test 1 for sha1-ccp: ret=3D19
[    7.321513] alg: hash: digest failed on test 1 for sha1-ccp: ret=3D19
[    7.324060] alg: hash: digest failed on test 1 for hmac-sha1-ccp: ret=3D=
19
[    7.324060] alg: hash: digest failed on test 1 for hmac-sha1-ccp: ret=3D=
19
[    7.326880] alg: hash: digest failed on test 1 for sha224-ccp: ret=3D19
[    7.326880] alg: hash: digest failed on test 1 for sha224-ccp: ret=3D19
[    7.330550] alg: hash: digest failed on test 1 for hmac-sha224-ccp: ret=
=3D19
[    7.330550] alg: hash: digest failed on test 1 for hmac-sha224-ccp: ret=
=3D19
[    7.333690] alg: hash: digest failed on test 1 for sha256-ccp: ret=3D19
[    7.333690] alg: hash: digest failed on test 1 for sha256-ccp: ret=3D19
[    7.337509] alg: hash: digest failed on test 1 for hmac-sha256-ccp: ret=
=3D19
[    7.337509] alg: hash: digest failed on test 1 for hmac-sha256-ccp: ret=
=3D19
[    7.340239] cs5535-clockevt: Could not allocate MFGPT timer
[    7.340239] cs5535-clockevt: Could not allocate MFGPT timer
[    7.348952] asus_wmi: Asus Management GUID not found
[    7.348952] asus_wmi: Asus Management GUID not found
[    7.351657] dell_wmi: No known WMI GUID found
[    7.351657] dell_wmi: No known WMI GUID found
[    7.353402] acer_wmi: Acer Laptop ACPI-WMI Extras
[    7.353402] acer_wmi: Acer Laptop ACPI-WMI Extras
[    7.355207] acer_wmi: No or unsupported WMI interface, unable to load
[    7.355207] acer_wmi: No or unsupported WMI interface, unable to load
[    7.357657] acerhdf: error getting hardware information
[    7.357657] acerhdf: error getting hardware information
[    7.359641] Initializing HPQ6001 module
[    7.359641] Initializing HPQ6001 module
[    7.361447] hdaps: supported laptop not found!
[    7.361447] hdaps: supported laptop not found!
[    7.363131] hdaps: driver init failed (ret=3D-19)!
[    7.363131] hdaps: driver init failed (ret=3D-19)!
[    7.366651] fujitsu_laptop: driver 0.6.0 successfully loaded
[    7.366651] fujitsu_laptop: driver 0.6.0 successfully loaded
[    7.369141] msi_wmi: This machine doesn't have neither MSI-hotkeys nor b=
acklight through WMI
[    7.369141] msi_wmi: This machine doesn't have neither MSI-hotkeys nor b=
acklight through WMI
[    7.372754] intel_oaktrail: Platform not recognized (You could try the m=
odule's force-parameter)
[    7.372754] intel_oaktrail: Platform not recognized (You could try the m=
odule's force-parameter)

[    7.376486] alienware_wmi: alienware-wmi: No known WMI GUID found
[    7.376486] alienware_wmi: alienware-wmi: No known WMI GUID found
[    7.379775] intel_rapl: driver does not support CPU family 6 model 6
[    7.379775] intel_rapl: driver does not support CPU family 6 model 6
[    7.391898] Motu MidiTimePiece on parallel port irq: 7 ioport: 0x378
[    7.391898] Motu MidiTimePiece on parallel port irq: 7 ioport: 0x378
[    7.394969] NET: Registered protocol family 26
[    7.394969] NET: Registered protocol family 26
[    7.396408] Netfilter messages via NETLINK v0.30.
[    7.396408] Netfilter messages via NETLINK v0.30.
[    7.398212] nfnl_acct: registering with nfnetlink.
[    7.398212] nfnl_acct: registering with nfnetlink.
[    7.399884] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    7.399884] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[    7.402547] ctnetlink v0.93: registering with nfnetlink.
[    7.402547] ctnetlink v0.93: registering with nfnetlink.
[    7.406422] xt_time: kernel timezone is -0000
[    7.406422] xt_time: kernel timezone is -0000
[    7.407847] ip_set: protocol 6
[    7.407847] ip_set: protocol 6
[    7.409005] gre: GRE over IPv4 demultiplexor driver
[    7.409005] gre: GRE over IPv4 demultiplexor driver
[    7.410840] ip_gre: GRE over IPv4 tunneling driver
[    7.410840] ip_gre: GRE over IPv4 tunneling driver
[    7.415437] IPv4 over IPSec tunneling driver
[    7.415437] IPv4 over IPSec tunneling driver
[    7.418816] arp_tables: (C) 2002 David S. Miller
[    7.418816] arp_tables: (C) 2002 David S. Miller
[    7.420957] TCP: cubic registered
[    7.420957] TCP: cubic registered
[    7.422329] NET: Registered protocol family 10
[    7.422329] NET: Registered protocol family 10
[    7.424746] tsc: Refined TSC clocksource calibration: 2693.506 MHz
[    7.424746] tsc: Refined TSC clocksource calibration: 2693.506 MHz
[    7.428344] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    7.428344] ip6_tables: (C) 2000-2006 Netfilter Core Team
[    7.432051] sit: IPv6 over IPv4 tunneling driver
[    7.432051] sit: IPv6 over IPv4 tunneling driver
[    7.436050] ip6_gre: GRE over IPv6 tunneling driver
[    7.436050] ip6_gre: GRE over IPv6 tunneling driver
[    7.439093] NET: Registered protocol family 15
[    7.439093] NET: Registered protocol family 15
[    7.440745] Bridge firewalling registered
[    7.440745] Bridge firewalling registered
[    7.442160] NET: Registered protocol family 4
[    7.442160] NET: Registered protocol family 4
[    7.443551] NET: Registered protocol family 9
[    7.443551] NET: Registered protocol family 9
[    7.445012] X25: Linux Version 0.2
[    7.445012] X25: Linux Version 0.2
[    7.446271] can: controller area network core (rev 20120528 abi 9)
[    7.446271] can: controller area network core (rev 20120528 abi 9)
[    7.448565] can: failed to create /proc/net/can . CONFIG_PROC_FS missing?
[    7.448565] can: failed to create /proc/net/can . CONFIG_PROC_FS missing?
[    7.451063] NET: Registered protocol family 29
[    7.451063] NET: Registered protocol family 29
[    7.452703] can: netlink gateway (rev 20130117) max_hops=3D1
[    7.452703] can: netlink gateway (rev 20130117) max_hops=3D1
[    7.455700] IrCOMM protocol (Dag Brattli)
[    7.455700] IrCOMM protocol (Dag Brattli)
[    7.465179] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    7.465179] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[    7.467087] Bluetooth: BNEP filters: protocol=20
[    7.467087] Bluetooth: BNEP filters: protocol=20
[    7.468579] Bluetooth: BNEP socket layer initialized
[    7.468579] Bluetooth: BNEP socket layer initialized
[    7.470501] NET: Registered protocol family 33
[    7.470501] NET: Registered protocol family 33
[    7.472049] Key type rxrpc registered
[    7.472049] Key type rxrpc registered
[    7.473415] Key type rxrpc_s registered
[    7.473415] Key type rxrpc_s registered
[    7.475486] RxRPC: Registered security type 2 'rxkad'
[    7.475486] RxRPC: Registered security type 2 'rxkad'
[    7.477299] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    7.477299] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[    7.480183] DECnet: Routing cache hash table of 1024 buckets, 80Kbytes
[    7.480183] DECnet: Routing cache hash table of 1024 buckets, 80Kbytes
[    7.482693] NET: Registered protocol family 12
[    7.482693] NET: Registered protocol family 12
[    7.485253] 8021q: 802.1Q VLAN Support v1.8
[    7.485253] 8021q: 802.1Q VLAN Support v1.8
[    7.499963] DCCP: Activated CCID 2 (TCP-like)
[    7.499963] DCCP: Activated CCID 2 (TCP-like)
[    7.518409] sctp: Hash tables configured (established 58254 bind 52428)
[    7.518409] sctp: Hash tables configured (established 58254 bind 52428)
[    7.521291] 9pnet: Installing 9P2000 support
[    7.521291] 9pnet: Installing 9P2000 support
[    7.523014] NET: Registered protocol family 37
[    7.523014] NET: Registered protocol family 37
[    7.524677] Key type dns_resolver registered
[    7.524677] Key type dns_resolver registered
[    7.526241] Key type ceph registered
[    7.526241] Key type ceph registered
[    7.528927] libceph: loaded (mon/osd proto 15/24)
[    7.528927] libceph: loaded (mon/osd proto 15/24)
[    7.532475] batman_adv: B.A.T.M.A.N. advanced 2014.3.0 (compatibility ve=
rsion 15) loaded
[    7.532475] batman_adv: B.A.T.M.A.N. advanced 2014.3.0 (compatibility ve=
rsion 15) loaded
[    7.535819] NET: Registered protocol family 40
[    7.535819] NET: Registered protocol family 40
[    7.537456] mpls_gso: MPLS GSO support
[    7.537456] mpls_gso: MPLS GSO support
[    7.541400]=20
[    7.541400] printing PIC contents
[    7.541400]=20
[    7.541400] printing PIC contents
[    7.543174] ... PIC  IMR: ffff
[    7.543174] ... PIC  IMR: ffff
[    7.544233] ... PIC  IRR: 1013
[    7.544233] ... PIC  IRR: 1013
[    7.545357] ... PIC  ISR: 0000
[    7.545357] ... PIC  ISR: 0000
[    7.546415] ... PIC ELCR: 0c00
[    7.546415] ... PIC ELCR: 0c00
[    7.547529] printing local APIC contents on CPU#0/0:
[    7.547529] printing local APIC contents on CPU#0/0:
[    7.549247] ... APIC ID:      00000000 (0)
[    7.549247] ... APIC ID:      00000000 (0)
[    7.550026] ... APIC VERSION: 00050014
[    7.550026] ... APIC VERSION: 00050014
[    7.550026] ... APIC TASKPRI: 00000000 (00)
[    7.550026] ... APIC TASKPRI: 00000000 (00)
[    7.550026] ... APIC PROCPRI: 00000000
[    7.550026] ... APIC PROCPRI: 00000000
[    7.550026] ... APIC LDR: 01000000
[    7.550026] ... APIC LDR: 01000000
[    7.550026] ... APIC DFR: ffffffff
[    7.550026] ... APIC DFR: ffffffff
[    7.550026] ... APIC SPIV: 000001ff
[    7.550026] ... APIC SPIV: 000001ff
[    7.550026] ... APIC ISR field:
[    7.550026] ... APIC ISR field:
[    7.550026] 00000000
[    7.550026] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    7.550026] ... APIC TMR field:
[    7.550026] ... APIC TMR field:
[    7.550026] 00000000
[    7.550026] 000000000200000002000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000000000000000

[    7.550026] ... APIC IRR field:
[    7.550026] ... APIC IRR field:
[    7.550026] 00000000
[    7.550026] 000000000000000000000000000000000000000000000000000000000000=
000000000000000000000000000000000000000000000000800000008000

[    7.550026] ... APIC ESR: 00000000
[    7.550026] ... APIC ESR: 00000000
[    7.550026] ... APIC ICR: 00000831
[    7.550026] ... APIC ICR: 00000831
[    7.550026] ... APIC ICR2: 01000000
[    7.550026] ... APIC ICR2: 01000000
[    7.550026] ... APIC LVTT: 000000ef
[    7.550026] ... APIC LVTT: 000000ef
[    7.550026] ... APIC LVTPC: 00000400
[    7.550026] ... APIC LVTPC: 00000400
[    7.550026] ... APIC LVT0: 00010700
[    7.550026] ... APIC LVT0: 00010700
[    7.550026] ... APIC LVT1: 00000400
[    7.550026] ... APIC LVT1: 00000400
[    7.550026] ... APIC LVTERR: 000000fe
[    7.550026] ... APIC LVTERR: 000000fe
[    7.550026] ... APIC TMICT: 00098219
[    7.550026] ... APIC TMICT: 00098219
[    7.550026] ... APIC TMCCT: 00000000
[    7.550026] ... APIC TMCCT: 00000000
[    7.550026] ... APIC TDCR: 00000003
[    7.550026] ... APIC TDCR: 00000003
[    7.550026]=20
[    7.550026]=20
[    7.584561] number of MP IRQ sources: 15.
[    7.584561] number of MP IRQ sources: 15.
[    7.585955] number of IO-APIC #0 registers: 24.
[    7.585955] number of IO-APIC #0 registers: 24.
[    7.587604] testing the IO APIC.......................
[    7.587604] testing the IO APIC.......................
[    7.589393] IO APIC #0......
[    7.589393] IO APIC #0......
[    7.590497] .... register #00: 00000000
[    7.590497] .... register #00: 00000000
[    7.591504] .......    : physical APIC id: 00
[    7.591504] .......    : physical APIC id: 00
[    7.592484] .......    : Delivery Type: 0
[    7.592484] .......    : Delivery Type: 0
[    7.593922] .......    : LTS          : 0
[    7.593922] .......    : LTS          : 0
[    7.595288] .... register #01: 00170011
[    7.595288] .... register #01: 00170011
[    7.596689] .......     : max redirection entries: 17
[    7.596689] .......     : max redirection entries: 17
[    7.598401] .......     : PRQ implemented: 0
[    7.598401] .......     : PRQ implemented: 0
[    7.599943] .......     : IO APIC version: 11
[    7.599943] .......     : IO APIC version: 11
[    7.601493] .... register #02: 00000000
[    7.601493] .... register #02: 00000000
[    7.602886] .......     : arbitration: 00
[    7.602886] .......     : arbitration: 00
[    7.604254] .... IRQ redirection table:
[    7.604254] .... IRQ redirection table:
[    7.605699] 1    0    0   0   0    0    0    00
[    7.605699] 1    0    0   0   0    0    0    00
[    7.607296] 0    0    0   0   0    1    1    31
[    7.607296] 0    0    0   0   0    1    1    31
[    7.608952] 0    0    0   0   0    1    1    30
[    7.608952] 0    0    0   0   0    1    1    30
[    7.610607] 0    0    0   0   0    1    1    33
[    7.610607] 0    0    0   0   0    1    1    33
[    7.612179] 1    0    0   0   0    1    1    34
[    7.612179] 1    0    0   0   0    1    1    34
[    7.613843] 1    1    0   0   0    1    1    35
[    7.613843] 1    1    0   0   0    1    1    35
[    7.615435] 0    0    0   0   0    1    1    36
[    7.615435] 0    0    0   0   0    1    1    36
[    7.617106] 0    0    0   0   0    1    1    37
[    7.617106] 0    0    0   0   0    1    1    37
[    7.618265] 0    0    0   0   0    1    1    38
[    7.618265] 0    0    0   0   0    1    1    38
[    7.619513] 0    1    0   0   0    1    1    39
[    7.619513] 0    1    0   0   0    1    1    39
[    7.621221] 1    1    0   0   0    1    1    3A
[    7.621221] 1    1    0   0   0    1    1    3A
[    7.622831] 1    1    0   0   0    1    1    3B
[    7.622831] 1    1    0   0   0    1    1    3B
[    7.624457] 0    0    0   0   0    1    1    3C
[    7.624457] 0    0    0   0   0    1    1    3C
[    7.626102] 0    0    0   0   0    1    1    3D
[    7.626102] 0    0    0   0   0    1    1    3D
[    7.627668] 0    0    0   0   0    1    1    3E
[    7.627668] 0    0    0   0   0    1    1    3E
[    7.629331] 0    0    0   0   0    1    1    3F
[    7.629331] 0    0    0   0   0    1    1    3F
[    7.630979] 1    0    0   0   0    0    0    00
[    7.630979] 1    0    0   0   0    0    0    00
[    7.632210] 1    0    0   0   0    0    0    00
[    7.632210] 1    0    0   0   0    0    0    00
[    7.633239] 1    0    0   0   0    0    0    00
[    7.633239] 1    0    0   0   0    0    0    00
[    7.634269] 1    0    0   0   0    0    0    00
[    7.634269] 1    0    0   0   0    0    0    00
[    7.635304] 1    0    0   0   0    0    0    00
[    7.635304] 1    0    0   0   0    0    0    00
[    7.636343] 1    0    0   0   0    0    0    00
[    7.636343] 1    0    0   0   0    0    0    00
[    7.637372] 1    0    0   0   0    0    0    00
[    7.637372] 1    0    0   0   0    0    0    00
[    7.638400] 1    0    0   0   0    0    0    00
[    7.638400] 1    0    0   0   0    0    0    00
[    7.639428] IRQ to pin mappings:
[    7.639428] IRQ to pin mappings:
[    7.640193] IRQ0=20
[    7.640193] IRQ0 -> 0:2-> 0:2

[    7.640795] IRQ1=20
[    7.640795] IRQ1 -> 0:1-> 0:1

[    7.641434] IRQ3=20
[    7.641434] IRQ3 -> 0:3-> 0:3

[    7.642403] IRQ4=20
[    7.642403] IRQ4 -> 0:4-> 0:4

[    7.643086] IRQ5=20
[    7.643086] IRQ5 -> 0:5-> 0:5

[    7.643695] IRQ6=20
[    7.643695] IRQ6 -> 0:6-> 0:6

[    7.644296] IRQ7=20
[    7.644296] IRQ7 -> 0:7-> 0:7

[    7.644904] IRQ8=20
[    7.644904] IRQ8 -> 0:8-> 0:8

[    7.645782] IRQ9=20
[    7.645782] IRQ9 -> 0:9-> 0:9

[    7.646407] IRQ10=20
[    7.646407] IRQ10 -> 0:10-> 0:10

[    7.647051] IRQ11=20
[    7.647051] IRQ11 -> 0:11-> 0:11

[    7.647696] IRQ12=20
[    7.647696] IRQ12 -> 0:12-> 0:12

[    7.648330] IRQ13=20
[    7.648330] IRQ13 -> 0:13-> 0:13

[    7.648976] IRQ14=20
[    7.648976] IRQ14 -> 0:14-> 0:14

[    7.649622] IRQ15=20
[    7.649622] IRQ15 -> 0:15-> 0:15

[    7.650301] .................................... done.
[    7.650301] .................................... done.
[    7.652176] bootconsole [earlyser0] disabled
[    7.652176] bootconsole [earlyser0] disabled
[    7.653268] Loading compiled-in X.509 certificates
[    7.654917] registered taskstats version 1
[    7.670591] Btrfs loaded, assert=3Don, integrity-checker=3Don
[    7.671997] Key type encrypted registered
[    7.676647]=20
[    7.676874] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[    7.677354] [ INFO: suspicious RCU usage. ]
[    7.677867] 3.16.0-rc6-01233-gac3d2e5 #1272 Not tainted
[    7.678466] -------------------------------
[    7.678973] include/linux/rcupdate.h:513 Illegal context switch in RCU r=
ead-side critical section!
[    7.680252]=20
[    7.680252] other info that might help us debug this:
[    7.680252]=20
[    7.681194]=20
[    7.681194] rcu_scheduler_active =3D 1, debug_locks =3D 1
[    7.682071] 3 locks held by swapper/1:
[    7.682667]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff87bb12fc>] rtnl_lo=
ck+0x17/0x19
[    7.683990]  #1:  (rcu_read_lock){......}, at: [<ffffffff86ca617e>] __at=
omic_notifier_call_chain+0x5/0x105
[    7.685606]  #2:  (rcu_read_lock){......}, at: [<ffffffff8769aa05>] cxgb=
i_inet6addr_handler+0x5/0x202
[    7.687150]=20
[    7.687150] stack backtrace:
[    7.687837] CPU: 0 PID: 1 Comm: swapper Not tainted 3.16.0-rc6-01233-gac=
3d2e5 #1272
[    7.689016]  0000000000000000 ffff880100d639f8 ffffffff87e25ccc ffff8801=
00d63a28
[    7.690951]  ffffffff86cbc38c ffffffff885d9370 000000000000024a 00000000=
00000000
[    7.692164]  ffff880100c66000 ffff880100d63a50 ffffffff86cadfd4 ffffffff=
88ad4d90
[    7.693375] Call Trace:
[    7.693795]  [<ffffffff87e25ccc>] dump_stack+0x19/0x1b
[    7.694579]  [<ffffffff86cbc38c>] lockdep_rcu_suspicious+0xe9/0xf2
[    7.695533]  [<ffffffff86cadfd4>] __might_sleep+0x58/0x1e9
[    7.696372]  [<ffffffff87e3da83>] mutex_lock_nested+0x3b/0x3d3
[    7.697265]  [<ffffffff86caf1b6>] ? sched_clock_local.constprop.2+0x34/0=
xa1
[    7.698323]  [<ffffffff87690861>] cxgbi_device_find_by_netdev+0x63/0x102
[    7.699359]  [<ffffffff8769aaa1>] cxgbi_inet6addr_handler+0xa1/0x202
[    7.700380]  [<ffffffff8769aa05>] ? cxgbi_inet6addr_handler+0x5/0x202
[    7.701384]  [<ffffffff86ca60c2>] notifier_call_chain+0xf4/0x126
[    7.702322]  [<ffffffff86ca6215>] __atomic_notifier_call_chain+0x9c/0x105
[    7.703366]  [<ffffffff86ca617e>] ? __atomic_notifier_call_chain+0x5/0x1=
05
[    7.704241]  [<ffffffff86ca6292>] atomic_notifier_call_chain+0x14/0x16
[    7.705234]  [<ffffffff87ce2e9c>] inet6addr_notifier_call_chain+0x1b/0x1d
[    7.706505]  [<ffffffff87c9f6e1>] ipv6_add_addr+0x218/0x544
[    7.707539]  [<ffffffff87c9f52e>] ? ipv6_add_addr+0x65/0x544
[    7.708484]  [<ffffffff87ca4a92>] add_addr+0x31/0x93
[    7.709420]  [<ffffffff87ca61ad>] addrconf_notify+0x65e/0x9b9
[    7.710559]  [<ffffffff87e414e2>] ? _raw_read_unlock+0x27/0x31
[    7.711523]  [<ffffffff86cba29c>] ? __lock_is_held+0x37/0x4f
[    7.712588]  [<ffffffff86ca60c2>] notifier_call_chain+0xf4/0x126
[    7.713683]  [<ffffffff86ca6487>] raw_notifier_call_chain+0x14/0x16
[    7.714706]  [<ffffffff87b9c1a1>] call_netdevice_notifiers_info+0x71/0x7a
[    7.715987]  [<ffffffff87b9f800>] call_netdevice_notifiers+0x13/0x15
[    7.717071]  [<ffffffff87ba39e6>] __dev_notify_flags+0x54/0x82
[    7.718127]  [<ffffffff87ba4039>] dev_change_flags+0x4d/0x58
[    7.719187]  [<ffffffff88d4cd83>] ip_auto_config+0x177/0xdbf
[    7.720146]  [<ffffffff86d4eee6>] ? slob_free+0x2cb/0x2d8
[    7.721173]  [<ffffffff88d4cc00>] ? root_nfs_parse_addr+0xa3/0xaf
[    7.722309]  [<ffffffff88cda08f>] ? do_one_initcall+0x98/0x1d0
[    7.723252]  [<ffffffff88d4cc0c>] ? root_nfs_parse_addr+0xaf/0xaf
[    7.724522]  [<ffffffff88cda1b2>] do_one_initcall+0x1bb/0x1d0
[    7.725547]  [<ffffffff86c9fe00>] ? param_array_set+0x82/0x11e
[    7.726539]  [<ffffffff86ca00a0>] ? parse_args+0x1a5/0x27f
[    7.727463]  [<ffffffff88cda2bf>] kernel_init_freeable+0xf8/0x17d
[    7.728598]  [<ffffffff88cd97fd>] ? initcall_blacklist+0x9f/0x9f
[    7.729585]  [<ffffffff87e0c212>] ? rest_init+0x136/0x136
[    7.730678]  [<ffffffff87e0c220>] kernel_init+0xe/0xda
[    7.731661]  [<ffffffff87e41eba>] ret_from_fork+0x7a/0xb0
[    7.732532]  [<ffffffff87e0c212>] ? rest_init+0x136/0x136
[    7.734390] IP-Config: Failed to open gretap0
[    7.735138] IP-Config: No network devices available
[    7.736057] ALSA device list:
[    7.736614]   #0: Loopback 1
[    7.737155]   #1: MTPAV on parallel port at 0x378
[    7.740205] debug: unmapping init [mem 0xffffffff88cd9000-0xffffffff88e5=
dfff]
[    7.741562] Write protecting the kernel read-only data: 28672k
[    7.743524] debug: unmapping init [mem 0xffff880007e46000-0xffff880007ff=
ffff]
[    7.744921] debug: unmapping init [mem 0xffff8800087ec000-0xffff8800087f=
ffff]
Mount failed for selinuxfs on /sys/fs/selinux:  No such file or directory
mount: proc has wrong device number or fs type proc not supported
[    8.132823] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input4
grep: /proc/filesystems: No such file or directory
Loading fuse module failed!
hwclock: Cannot access the Hardware Clock via any known method.
hwclock: Use the --debug option to see the details of our search for an acc=
ess method.
findmnt: can't read /proc/mounts: No such file or directory
warning: failed to read mtab
mount: can't find /run in /etc/fstab or /etc/mtab
warning: failed to read mtab
mount: can't find /run/lock in /etc/fstab or /etc/mtab
warning: failed to read mtab
mount: can't find /run/shm in /etc/fstab or /etc/mtab
[....] Setting up LVM Volume Groups...  /proc/mounts: _get_sysfs_dir fopen =
failed: No such file or directory
  /dev/mapper/control: open failed: No such device
  Failure to communicate with kernel device-mapper driver.
  Check that device-mapper is available in the kernel.
  /proc/devices: fopen failed: No such file or directory
  Failed to create lvm type filter
  /proc/mounts: _get_sysfs_dir fopen failed: No such file or directory
  /dev/mapper/control: open failed: No such device
  Failure to communicate with kernel device-mapper driver.
  Check that device-mapper is available in the kernel.
  /proc/devices: fopen failed: No such file or directory
  Failed to create lvm type filter
[....] Checking file systems...fsck from util-linux 2.20.1
df: Warning: cannot read table of mounted file systems: No such file or dir=
ectory
[   10.694145] random: dd urandom read with 15 bits of entropy available
[....] Configuring network interfaces...ifup: failed to lock statefile /run=
/network/ifstate: Permission denied
[....] Starting rpcbind daemon...start-stop-daemon: nothing in /proc - not =
mounted?
[....] Starting NFS common utilities: statd
[....] Starting NFS common utilities: statd
[....] Starting rpcbind daemon...start-stop-daemon: nothing in /proc - not =
mounted?
/etc/init.d/nfsroot: line 17: /proc/cmdline: No such file or directory
25 Jul 15:07:09 ntpdate[1251]: no servers can be used, exiting
grep: /proc/mounts: No such file or directory

=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
Kernel tests: Boot OK!
PATH=3D/sbin:/usr/sbin:/bin:/usr/bin

=3D=3D> /lkp/lkp/src/tmp/err_log <=3D=3D
cp: cannot stat '/proc/uptime': No such file or directory
=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
Kernel tests: Boot OK!
PATH=3D/sbin:/usr/sbin:/bin:/usr/bin

=3D=3D> /lkp/lkp/src/tmp/err_log <=3D=3D
cp: cannot stat '/proc/uptime': No such file or directory

=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
downloading latest lkp src code

=3D=3D> /lkp/lkp/src/tmp/run_log <=3D=3D
downloading latest lkp src code
download failed
download failed
error: '/etc/init.d/rc' exited outside the expected code flow.
[....] Stopping quota service: rpc.rquotadstart-stop-daemon: nothing in /pr=
oc - not mounted?
[....] Asking all remaining processes to terminate...mount: proc has wrong =
device number or fs type proc not supported
killall5: mount returned non-zero exit status
killall5: /proc not mounted, failed to mount.
mount: proc has wrong device number or fs type proc not supported
killall5: mount returned non-zero exit status
killall5: /proc not mounted, failed to mount.
/etc/init.d/umountnfs.sh: line 34: /etc/mtab: No such file or directory
[....] Stopping NFS common utilities: statdstart-stop-daemon: nothing in /p=
roc - not mounted?
hwclock: Cannot access the Hardware Clock via any known method.
hwclock: Use the --debug option to see the details of our search for an acc=
ess method.
[....] Stopping rpcbind daemon...start-stop-daemon: nothing in /proc - not =
mounted?
[....] Deconfiguring network interfaces...ifdown: failed to lock statefile =
/run/network/ifstate: Permission denied
sed: can't read /proc/mounts: No such file or directory
/etc/init.d/umountfs: line 19: /proc/mounts: No such file or directory
cat: /sys/kernel/kexec_loaded: No such file or directory
[  316.820382] Unregister pv shared memory for cpu 0
[  316.823708] reboot: Restarting system
[  316.824493] reboot: machine restart
Elapsed time: 340
qemu-system-x86_64 -enable-kvm -kernel /kernel/x86_64-randconfig-ha2-0725/a=
c3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-gac3d2e5 -=
append 'user=3Dlkp job=3D/lkp/scheduled/vm-kbuild-4G-1/rand_boot-1-x86_64-r=
andconfig-ha2-0725-ac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f-0.yaml ARCH=3Dx=
86_64 BOOT_IMAGE=3D/kernel/x86_64-randconfig-ha2-0725/ac3d2e5a9ef2f4d8f57c5=
0070c4883ecb7cec29f/vmlinuz-3.16.0-rc6-01233-gac3d2e5 kconfig=3Dx86_64-rand=
config-ha2-0725 commit=3Dac3d2e5a9ef2f4d8f57c50070c4883ecb7cec29f initrd=3D=
/kernel-tests/initrd/lkp-rootfs.cgz root=3D/dev/ram0 RESULT_ROOT=3D/result/=
vm-kbuild-4G/boot/1/x86_64-randconfig-ha2-0725/ac3d2e5a9ef2f4d8f57c50070c48=
83ecb7cec29f/0 ip=3D::::vm-kbuild-4G-1::dhcp oops=3Dpanic earlyprintk=3Dtty=
S0,115200 debug apic=3Ddebug sysrq_always_enabled rcupdate.rcu_cpu_stall_ti=
meout=3D100 panic=3D10 softlockup_panic=3D1 nmi_watchdog=3Dpanic load_ramdi=
sk=3D2 prompt_ramdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnorma=
l'  -initrd /fs/sdd1/initrd-vm-kbuild-4G-1 -m 4096 -smp 4 -net nic,vlan=3D1=
,model=3De1000 -net user,vlan=3D1 -boot order=3Dnc -no-reboot -watchdog i63=
00esb -rtc base=3Dlocaltime -drive file=3D/fs/sdd1/disk0-vm-kbuild-4G-1,med=
ia=3Ddisk,if=3Dvirtio -drive file=3D/fs/sdd1/disk1-vm-kbuild-4G-1,media=3Dd=
isk,if=3Dvirtio -drive file=3D/fs/sdd1/disk2-vm-kbuild-4G-1,media=3Ddisk,if=
=3Dvirtio -drive file=3D/fs/sdd1/disk3-vm-kbuild-4G-1,media=3Ddisk,if=3Dvir=
tio -drive file=3D/fs/sdd1/disk4-vm-kbuild-4G-1,media=3Ddisk,if=3Dvirtio -d=
rive file=3D/fs/sdd1/disk5-vm-kbuild-4G-1,media=3Ddisk,if=3Dvirtio -pidfile=
 /dev/shm/kboot/pid-vm-kbuild-4G-1 -serial file:/dev/shm/kboot/serial-vm-kb=
uild-4G-1 -daemonize -display none -monitor null=20

--ReaqsoxgOBHFXBhH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--ReaqsoxgOBHFXBhH--
