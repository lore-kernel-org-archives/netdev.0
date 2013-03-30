From: Fengguang Wu <fengguang.wu@intel.com>
Subject: WARNING: at net/batman-adv/hard-interface.c:92
 batadv_is_on_batman_iface()
Date: Sat, 30 Mar 2013 17:36:35 +0800
Message-ID: <20130330093635.GA31605@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:39257 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755285Ab3C3JhB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Mar 2013 05:37:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below WARNING in net-next/master (head commit f498354793d5)
and the first bad commit is

commit c54419321455631079c7d6e60bc732dd0c5914c5
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Mon Mar 25 14:49:35 2013 +0000

    GRE: Refactor GRE tunneling code.
    
    Following patch refactors GRE code into ip tunneling code and GRE
    specific code. Common tunneling code is moved to ip_tunnel module.
    ip_tunnel module is written as generic library which can be used
    by different tunneling implementations.
    
    ip_tunnel module contains following components:
     - packet xmit and rcv generic code. xmit flow looks like
       (gre_xmit/ipip_xmit)->ip_tunnel_xmit->ip_local_out.
     - hash table of all devices.
     - lookup for tunnel devices.
     - control plane operations like device create, destroy, ioctl, netlink
       operations code.
     - registration for tunneling modules, like gre, ipip etc.
     - define single pcpu_tstats dev->tstats.
     - struct tnl_ptk_info added to pass parsed tunnel packet parameters.
    
    ipip.h header is renamed to ip_tunnel.h
    
    Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

[   27.507156] libceph: loaded (mon/osd proto 15/24)
[   27.515409] ------------[ cut here ]------------
[   27.518917] WARNING: at /c/kernel-tests/src/stable/net/batman-adv/hard-interface.c:92 batadv_is_on_batman_iface+0x5c/0x7a()
[   27.521935] Hardware name: Bochs
[   27.525356] Cannot find parent device
[   27.528296] Modules linked in:
[   27.529923] Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc4-00896-g03ba910 #794
[   27.531747] Call Trace:
[   27.534683]  [<ffffffff81098ab4>] warn_slowpath_common+0x83/0x9e
[   27.536338]  [<ffffffff81098b72>] warn_slowpath_fmt+0x46/0x48
[   27.537872]  [<ffffffff828e6402>] ? rcu_read_unlock+0x1c/0x2d
[   27.539441]  [<ffffffff810ca498>] ? local_clock+0x19/0x52
[   27.541023]  [<ffffffff82c0e796>] batadv_is_on_batman_iface+0x5c/0x7a
[   27.542803]  [<ffffffff82c0efe2>] batadv_hard_if_event+0x8f/0x285
[   27.544551]  [<ffffffff828e4ff0>] register_netdevice_notifier+0x71/0x17e
[   27.550617]  [<ffffffff8420a030>] ? batadv_iv_init+0x3f/0x3f
[   27.552248]  [<ffffffff8420a114>] batadv_init+0xe4/0x104
[   27.553770]  [<ffffffff810020be>] do_one_initcall+0x7f/0x13d
[   27.555386]  [<ffffffff84177eb0>] kernel_init_freeable+0x141/0x1d0
[   27.557177]  [<ffffffff84177734>] ? do_early_param+0x8c/0x8c
[   27.558813]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
[   27.560348]  [<ffffffff82c1f154>] kernel_init+0xe/0xdb
[   27.561813]  [<ffffffff82c694ac>] ret_from_fork+0x7c/0xb0
[   27.563356]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
[   27.564974] ---[ end trace f78f9f0651ffcb0b ]---

git bisect start 03ba9107c92bdc2eec1d14ea19d5a00209969d87 v3.8 --
git bisect good cb715a836642e0ec69350670d1c2f800f3e2d2e4  #    10  2013-03-29 14:42:04  Merge branch 'x86-cpu-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect good b67bfe0d42cac56c512dd5da4b1b347a23f4b70a  #    10  2013-03-29 17:23:34  hlist: drop the node parameter from iterators
git bisect good 59d8e5eb2bd5593d8220db0e25206cdfc42e83ea  #    10  2013-03-29 20:04:53  Merge branch 'akpm' (fixes from Andrew)
git bisect good 71420228feb826b365b3fef4de01e83c00e9151d  #    10  2013-03-29 22:46:41  Merge remote-tracking branch 'origin/drm-intel-fixes' into drm-intel-nightly
git bisect good 5470b462c3f0c6fa980c320968a165bd0f34ca8d  #    10  2013-03-30 00:08:49  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem
git bisect  bad 38502af77e07b5d6650b9ff99a0b482d86366592  #     0  2013-03-30 00:16:41  tuntap: set transport header before passing it to kernel
git bisect good 0465277f6b3fd0535428ae935644ac30ce903de0  #    10  2013-03-30 01:46:40  ipv4: provide addr and netconf dump consistency info
git bisect good 21168245031062212c0b805d0bd466ee6dd4a16f  #    10  2013-03-30 04:28:14  dsa: factor freeing of dsa_platform_data
git bisect  bad cb6bf35502d53364d15737295bc64f804c4587ce  #     0  2013-03-30 05:47:34  firewire net, ipv6: IPv6 over Firewire (RFC3146) support.
git bisect  bad 206aaafcd279e2cb836d772282517540c6cb3814  #     0  2013-03-30 05:55:36  VXLAN: Use IP Tunnels tunnel ENC encap API
git bisect good 25c7704d8bdcf6746dab4397953df51759924b37  #    10  2013-03-30 07:21:49  ipv4: Fix ip-header identification for gso packets.
git bisect  bad c54419321455631079c7d6e60bc732dd0c5914c5  #     0  2013-03-30 08:42:46  GRE: Refactor GRE tunneling code.
git bisect good eaac5f3d3ad33547b299935e6db0cfc7be9a576a  #    10  2013-03-30 10:11:30  net: Print functions in /proc/net/ptype without the offset.
git bisect good eaac5f3d3ad33547b299935e6db0cfc7be9a576a  #    30  2013-03-30 14:14:09  net: Print functions in /proc/net/ptype without the offset.
git bisect  bad 03ba9107c92bdc2eec1d14ea19d5a00209969d87  #     0  2013-03-30 15:34:09  Merge remote-tracking branch 'net-next/master' into devel-inn-x86_64-2013-03-27-06-54

Thanks,
Fengguang

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-inn-39711-2013-03-27-09-08-30-3.9.0-rc4-00896-g03ba910-794"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.9.0-rc4-00896-g03ba910 (kbuild@inn) (gcc ver=
sion 4.7.1 (Debian 4.7.1-6) ) #794 SMP Wed Mar 27 07:36:14 CST 2013
[    0.000000] Command line: hung_task_panic=3D1 rcutree.rcu_cpu_stall_time=
out=3D100 branch=3Dlinux-devel/devel-inn-x86_64-2013-03-27-06-54 log_buf_le=
n=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dynamic_printk sysrq_=
always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=3D0 console=3Dtty=
S0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::kvm::dhcp nfsroot=3D10.239.9=
7.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock,rsize=3D524288,wsize=3D=
524288 rw link=3Dvmlinuz-2013-03-27-07-37-41-devel-inn-x86_64-2013-03-27-06=
-54:03ba9107c92bdc2eec1d14ea19d5a00209969d87-03ba9107c92bdc2eec1d14ea19d5a0=
0209969d87-x86_64-allyesdebian-5-inn BOOT_IMAGE=3D/kernel/x86_64-allyesdebi=
an/03ba9107c92bdc2eec1d14ea19d5a00209969d87/vmlinuz-3.9.0-rc4-00896-g03ba910
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffe000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x1fffe max_arch_pfn =3D 0x400000000
[    0.000000] MTRR default type: write-back
[    0.000000] MTRR fixed ranges enabled:
[    0.000000]   00000-9FFFF write-back
[    0.000000]   A0000-BFFFF uncachable
[    0.000000]   C0000-FFFFF write-protect
[    0.000000] MTRR variable ranges enabled:
[    0.000000]   0 base 00E0000000 mask FFE0000000 uncachable
[    0.000000]   1 disabled
[    0.000000]   2 disabled
[    0.000000]   3 disabled
[    0.000000]   4 disabled
[    0.000000]   5 disabled
[    0.000000]   6 disabled
[    0.000000]   7 disabled
[    0.000000] x86 PAT enabled: cpu 0, old 0x70406, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000fdab0-0x000fdabf] mapped at =
[ffff8800000fdab0]
[    0.000000]   mpc: fdac0-fdbe4
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x0501d000, 0x0501dfff] PGTABLE
[    0.000000] BRK [0x0501e000, 0x0501efff] PGTABLE
[    0.000000] BRK [0x0501f000, 0x0501ffff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1fc00000-0x1fdfffff]
[    0.000000]  [mem 0x1fc00000-0x1fdfffff] page 4k
[    0.000000] BRK [0x05020000, 0x05020fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x1c000000-0x1fbfffff]
[    0.000000]  [mem 0x1c000000-0x1fbfffff] page 4k
[    0.000000] BRK [0x05021000, 0x05021fff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x00100000-0x1bffffff]
[    0.000000]  [mem 0x00100000-0x1bffffff] page 4k
[    0.000000] init_memory_mapping: [mem 0x1fe00000-0x1fffdfff]
[    0.000000]  [mem 0x1fe00000-0x1fffdfff] page 4k
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127184(97%)
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffe550 00038 (v01 BOCHS  BXPCRSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001fffff80 00074 (v01 BOCHS  BXPCFACP 00000=
001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffe590 01121 (v01   BXPC   BXDSDT 00000=
001 INTL 20100528)
[    0.000000] ACPI: FACS 000000001fffff40 00040
[    0.000000] ACPI: SSDT 000000001ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000=
001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001ffffd10 00038 (v01 BOCHS  BXPCHPET 00000=
001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000001ffff6c0 00644 (v01   BXPC BXSSDTPC 00000=
001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffdfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffdfff]
[    0.000000]   NODE_DATA [mem 0x1fff9000-0x1fffdfff]
[    0.000000] kvm-clock: Using msrs 4b564d01 and 4b564d00
[    0.000000] kvm-clock: cpu 0, msr 0:1fff1001, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e40000=
0-ffff88001ebfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00001000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffdfff]
[    0.000000] On node 0 totalpages: 130960
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 21 pages reserved
[    0.000000]   DMA zone: 3986 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 126974 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5f3000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-=
23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC =
INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC =
INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC =
INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC =
INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC =
INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC =
INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC =
INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC =
INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC =
INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC =
INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC =
INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC =
INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC =
INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC =
INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC =
INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] smpboot: Allowing 2 CPUs, 0 hotplug CPUs
[    0.000000] mapped IOAPIC to ffffffffff5f2000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 0000000000093000 - 00000000000=
94000
[    0.000000] PM: Registered nosave memory: 0000000000094000 - 00000000000=
a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000=
f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000001=
00000
[    0.000000] e820: [mem 0x20000000-0xfeffbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 478 pages/cpu @ffff88001f000000 s1927320 r8=
192 d22376 u2097152
[    0.000000] pcpu-alloc: s1927320 r8192 d22376 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1fff1001, primary cpu clock
[    0.000000] KVM setup async PF for cpu 0
[    0.000000] kvm-stealtime: cpu 0, msr 1f00e1c0
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128891
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: hung_task_panic=3D1 rcutree.rcu_cpu_sta=
ll_timeout=3D100 branch=3Dlinux-devel/devel-inn-x86_64-2013-03-27-06-54 log=
_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dynamic_printk=
 sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=3D0 consol=
e=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::kvm::dhcp nfsroot=3D1=
0.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock,rsize=3D524288,w=
size=3D524288 rw link=3Dvmlinuz-2013-03-27-07-37-41-devel-inn-x86_64-2013-0=
3-27-06-54:03ba9107c92bdc2eec1d14ea19d5a00209969d87-03ba9107c92bdc2eec1d14e=
a19d5a00209969d87-x86_64-allyesdebian-5-inn BOOT_IMAGE=3D/kernel/x86_64-all=
yesdebian/03ba9107c92bdc2eec1d14ea19d5a00209969d87/vmlinuz-3.9.0-rc4-00896-=
g03ba910
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 436072k/524280k available (29117k kernel code, 440k =
absent, 87768k reserved, 19647k data, 4164k init)
[    0.000000] Hierarchical RCU implementation.
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000]=20
[    0.000000] NR_IRQS:33024 nr_irqs:512 16
[    0.000000] Console: colour VGA+ 80x25
[    0.000000] console [tty0] enabled
[    0.000000] console [ttyS0] enabled
[    0.000000] Lock dependency validator: Copyright (c) 2006 Red Hat, Inc.,=
 Ingo Molnar
[    0.000000] ... MAX_LOCKDEP_SUBCLASSES:  8
[    0.000000] ... MAX_LOCK_DEPTH:          48
[    0.000000] ... MAX_LOCKDEP_KEYS:        8191
[    0.000000] ... CLASSHASH_SIZE:          4096
[    0.000000] ... MAX_LOCKDEP_ENTRIES:     16384
[    0.000000] ... MAX_LOCKDEP_CHAINS:      32768
[    0.000000] ... CHAINHASH_SIZE:          16384
[    0.000000]  memory used by lock dependency info: 6367 kB
[    0.000000]  per task-struct memory footprint: 2688 bytes
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ------------------------------------------------------------=
----------------
[    0.000000]                                  | spin |wlock |rlock |mutex=
 | wsem | rsem |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]                      A-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  A-B-B-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-B-C-C-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]              A-B-C-A-B-C deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-B-C-C-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-D-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]          A-B-C-D-B-C-D-A deadlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                     double unlock:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                   initialize held:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok =
 |  ok  |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]               recursive read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]            recursive read-lock #2:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed read-write-lock:             |  ok  |     =
        |  ok  |
[    0.000000]             mixed write-read-lock:             |  ok  |     =
        |  ok  |
[    0.000000]   ----------------------------------------------------------=
----------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:  ok  |  ok  |  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]        sirq-safe-A =3D> hirqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:  ok  |  ok  |  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:  ok  |  ok  |  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/123:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/132:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/213:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/231:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/312:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       soft-irq lock-inversion/321:  ok  |  ok  |  ok  |
[    0.000000]       hard-irq read-recursion/123:  ok  |
[    0.000000]       soft-irq read-recursion/123:  ok  |
[    0.000000]       hard-irq read-recursion/132:  ok  |
[    0.000000]       soft-irq read-recursion/132:  ok  |
[    0.000000]       hard-irq read-recursion/213:  ok  |
[    0.000000]       soft-irq read-recursion/213:  ok  |
[    0.000000]       hard-irq read-recursion/231:  ok  |
[    0.000000]       soft-irq read-recursion/231:  ok  |
[    0.000000]       hard-irq read-recursion/312:  ok  |
[    0.000000]       soft-irq read-recursion/312:  ok  |
[    0.000000]       hard-irq read-recursion/321:  ok  |
[    0.000000]       soft-irq read-recursion/321:  ok  |
[    0.000000] -------------------------------------------------------
[    0.000000] Good, all 218 testcases passed! |
[    0.000000] ---------------------------------
[    0.000000] ODEBUG: 0 of 0 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Detected 2693.560 MHz processor
[    0.008000] Calibrating delay loop (skipped) preset value.. 5387.12 Bogo=
MIPS (lpj=3D10774240)
[    0.009362] pid_max: default: 32768 minimum: 301
[    0.012166] Security Framework initialized
[    0.013484] AppArmor: AppArmor disabled by boot time parameter
[    0.015589] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.016205] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.018177] Mount-cache hash table entries: 256
[    0.024790] Initializing cgroup subsys devices
[    0.026251] Initializing cgroup subsys freezer
[    0.027626] Initializing cgroup subsys net_cls
[    0.028025] Initializing cgroup subsys blkio
[    0.029778] mce: CPU supports 10 MCE banks
[    0.031178] numa_add_cpu cpu 0 node 0: mask now 0
[    0.032021] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.032021] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.032021] tlb_flushall_shift: 6
[    0.036058] debug: unmapping init [mem 0xffffffff843b1000-0xffffffff843b=
cfff]
[    0.044336] ACPI: Core revision 20130117
[    0.049527] ACPI: All ACPI Tables successfully acquired
[    0.052071] ftrace: allocating 112303 entries in 439 pages
[    0.088596] Getting VERSION: 50014
[    0.089722] Getting VERSION: 50014
[    0.092025] Getting ID: 0
[    0.093043] Getting ID: ff000000
[    0.094153] Getting LVT0: 8700
[    0.095177] Getting LVT1: 8400
[    0.096000] enabled ExtINT on CPU#0
[    0.097061] ENABLING IO-APIC IRQs
[    0.098170] init IO_APIC IRQs
[    0.100016]  apic 2 pin 0 not connected
[    0.101311] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.104055] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.108046] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.110488] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.112000] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.112104] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.114578] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.116051] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.120061] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.124049] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.128058] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.132060] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.134501] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.136000] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.136057] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.140046]  apic 2 pin 16 not connected
[    0.141324]  apic 2 pin 17 not connected
[    0.144010]  apic 2 pin 18 not connected
[    0.145268]  apic 2 pin 19 not connected
[    0.148015]  apic 2 pin 20 not connected
[    0.149193]  apic 2 pin 21 not connected
[    0.150483]  apic 2 pin 22 not connected
[    0.151878]  apic 2 pin 23 not connected
[    0.152000] ..TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.152015] smpboot: CPU0: Intel Common KVM processor (fam: 0f, model: 0=
6, stepping: 01)
[    0.155269] Using local APIC timer interrupts.
[    0.155269] calibrating APIC timer ...
[    0.160000] ... lapic delta =3D 6143980
[    0.160000] ... PM-Timer delta =3D 351870
[    0.160000] APIC calibration not consistent with PM-Timer: 98ms instead =
of 100ms
[    0.160000] APIC delta adjusted to PM-Timer: 6250212 (6143980)
[    0.160000] TSC delta adjusted to PM-Timer: 269346996 (264769014)
[    0.160000] ..... delta 6250212
[    0.160000] ..... mult: 268444561
[    0.160000] ..... calibration result: 4000135
[    0.160000] ..... CPU clock speed is 2693.1879 MHz.
[    0.160000] ..... host bus clock speed is 1000.0135 MHz.
[    0.160115] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.166400] Testing tracer nop: PASSED
[    0.169542] NMI watchdog: disabled (cpu0): hardware events not enabled
[    0.174678] SMP alternatives: lockdep: fixing up alternatives
[    0.176049] smpboot: Booting Node   0, Processors  #1 OK
[    0.008000] kvm-clock: cpu 1, msr 0:1fff1041, secondary cpu clock
[    0.008000] masked ExtINT on CPU#1
[    0.008000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.200245] Brought up 2 CPUs
[    0.201442] ----------------
[    0.202562] | NMI testsuite:
[    0.204034] --------------------
[    0.204032] KVM setup async PF for cpu 1
[    0.204040] kvm-stealtime: cpu 1, msr 1f20e1c0
[    0.208010]   remote IPI:  ok  |
[    0.212012]    local IPI:  ok  |
[    0.216031] --------------------
[    0.217146] Good, all   2 testcases passed! |
[    0.220009] ---------------------------------
[    0.221317] smpboot: Total of 2 processors activated (10774.24 BogoMIPS)
[    0.224358] CPU0 attaching sched-domain:
[    0.225560]  domain 0: span 0-1 level CPU
[    0.228713]   groups: 0 (cpu_power =3D 1023) 1
[    0.230481] CPU1 attaching sched-domain:
[    0.232015]  domain 0: span 0-1 level CPU
[    0.233385]   groups: 1 0 (cpu_power =3D 1023)
[    0.244811] devtmpfs: initialized
[    0.268069] Testing tracer function: PASSED
[    0.766937] Testing dynamic ftrace: PASSED
[    1.436640] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 =
3 1 32) (2 2 4 1 221) PASSED
[    2.588778] Testing dynamic ftrace ops #2: (1 0 1 16 0) (1 1 2 267 0) (2=
 1 3 1 263) (2 2 4 198 460) PASSED
[    3.692010] Testing ftrace recursion: PASSED
[    3.783055] Testing ftrace recursion safe: PASSED
[    3.878734] Testing ftrace regs: PASSED
[    3.988058] Testing tracer irqsoff: PASSED
[    4.792065] Testing tracer wakeup: ret =3D 0
[    5.668175] ftrace-test (21) used greatest stack depth: 6336 bytes left
[    5.676049] PASSED
[    5.680042] Testing tracer wakeup_rt: ret =3D 0
[    6.620076] PASSED
[    6.624076] Testing tracer function_graph: PASSED
[    7.547110] xor: measuring software checksum speed
[    7.588045]    prefetch64-sse:   159.000 MB/sec
[    7.628046]    generic_sse:   160.000 MB/sec
[    7.629445] xor: using function: generic_sse (160.000 MB/sec)
[    7.631242] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    7.633333] regulator-dummy: no parameters
[    7.637277] NET: Registered protocol family 16
[    7.646235] ACPI: bus type PCI registered
[    7.647972] dca service started, version 1.12.1
[    7.648193] PCI: Using configuration type 1 for base access
[    7.812946] bio: create slab <bio-0> at 0
[    7.888027] raid6: sse2x1    4411 MB/s
[    7.956023] raid6: sse2x2    6202 MB/s
[    8.024021] raid6: sse2x4    7061 MB/s
[    8.025198] raid6: using algorithm sse2x4 (7061 MB/s)
[    8.026632] raid6: using intx1 recovery algorithm
[    8.028450] ACPI: Added _OSI(Module Device)
[    8.029774] ACPI: Added _OSI(Processor Device)
[    8.031055] ACPI: Added _OSI(3.0 _SCP Extensions)
[    8.032022] ACPI: Added _OSI(Processor Aggregator Device)
[    8.038335] ACPI: EC: Look up EC in DSDT
[    8.051655] ACPI: Interpreter enabled
[    8.052030] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S1_] (20130117/hwxface-568)
[    8.054820] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [=
\_S2_] (20130117/hwxface-568)
[    8.057995] ACPI: (supports S0 S3 S4 S5)
[    8.059209] ACPI: Using IOAPIC for interrupt routing
[    8.060172] PCI: Ignoring host bridge windows from ACPI; if necessary, u=
se "pci=3Duse_crs" and report a bug
[    8.092500] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    8.094285] acpi PNP0A03:00: ACPI _OSC support notification failed, disa=
bling PCIe ASPM
[    8.096022] acpi PNP0A03:00: Unable to request _OSC control (_OSC suppor=
t mask: 0x08)
[    8.098501] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ign=
ored)
[    8.100027] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ign=
ored)
[    8.104019] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bff=
ff] (ignored)
[    8.106267] acpi PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfff=
ff] (ignored)
[    8.108039] PCI: root bus 00: using default resources
[    8.109468] acpi PNP0A03:00: fail to add MMCONFIG information, can't acc=
ess extended PCI configuration space under this bridge.
[    8.112454] PCI host bridge to bus 0000:00
[    8.116025] pci_bus 0000:00: root bus resource [bus 00-ff]
[    8.117597] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    8.119359] pci_bus 0000:00: root bus resource [mem 0x00000000-0xfffffff=
fff]
[    8.120155] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    8.125008] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    8.127686] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    8.130356] pci 0000:00:01.1: reg 20: [io  0xc1e0-0xc1ef]
[    8.133817] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    8.136702] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    8.138737] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    8.140751] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    8.148631] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    8.153337] pci 0000:00:02.0: reg 14: [mem 0xfebe0000-0xfebe0fff]
[    8.161710] pci 0000:00:02.0: reg 30: [mem 0xfebc0000-0xfebcffff pref]
[    8.164670] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    8.166846] pci 0000:00:03.0: reg 10: [mem 0xfeb80000-0xfeb9ffff]
[    8.168781] pci 0000:00:03.0: reg 14: [io  0xc000-0xc03f]
[    8.174457] pci 0000:00:03.0: reg 30: [mem 0xfeba0000-0xfebbffff pref]
[    8.176785] pci 0000:00:04.0: [1af4:1000] type 00 class 0x020000
[    8.179246] pci 0000:00:04.0: reg 10: [io  0xc1c0-0xc1df]
[    8.180782] pci 0000:00:04.0: reg 14: [mem 0xfebe1000-0xfebe1fff]
[    8.187361] pci 0000:00:04.0: reg 30: [mem 0xfebd0000-0xfebdffff pref]
[    8.188881] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    8.192465] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    8.194827] pci 0000:00:05.0: reg 14: [mem 0xfebe2000-0xfebe2fff]
[    8.202278] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    8.204975] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    8.207403] pci 0000:00:06.0: reg 14: [mem 0xfebe3000-0xfebe3fff]
[    8.214192] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    8.217008] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    8.219439] pci 0000:00:07.0: reg 14: [mem 0xfebe4000-0xfebe4fff]
[    8.226609] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    8.228976] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    8.231323] pci 0000:00:08.0: reg 14: [mem 0xfebe5000-0xfebe5fff]
[    8.238269] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    8.241007] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    8.243428] pci 0000:00:09.0: reg 14: [mem 0xfebe6000-0xfebe6fff]
[    8.250291] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    8.252966] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    8.255372] pci 0000:00:0a.0: reg 14: [mem 0xfebe7000-0xfebe7fff]
[    8.262630] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    8.264693] pci 0000:00:0b.0: reg 10: [mem 0xfebe8000-0xfebe800f]
[    8.270605] ACPI _OSC control for PCIe not granted, disabling ASPM
[    8.280834] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    8.283795] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    8.285825] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    8.289421] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    8.292418] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    8.295814] ACPI: Enabled 16 GPEs in block 00 to 0F
[    8.300039] acpi root: \_SB_.PCI0 notify handler is installed
[    8.302137] Found 1 acpi root devices
[    8.308227] ACPI: No dock devices found.
[    8.312274] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    8.316040] vgaarb: loaded
[    8.320007] vgaarb: bridge control possible 0000:00:02.0
[    8.324250] tps65010: version 2 May 2005
[    8.356160] tps65010: no chip?
[    8.358904] SCSI subsystem initialized
[    8.360042] ACPI: bus type ATA registered
[    8.361511] libata version 3.00 loaded.
[    8.361779] ACPI: bus type USB registered
[    8.364341] usbcore: registered new interface driver usbfs
[    8.365963] usbcore: registered new interface driver hub
[    8.368253] usbcore: registered new device driver usb
[    8.370051] pps_core: LinuxPPS API ver. 1 registered
[    8.371425] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    8.372084] PTP clock support registered
[    8.376113] EDAC MC: Ver: 3.0.0
[    8.378218] wmi: Mapper loaded
[    8.380366] Advanced Linux Sound Architecture Driver Initialized.
[    8.382324] PCI: Using ACPI for IRQ routing
[    8.383623] PCI: pci_cache_line_size set to 64 bytes
[    8.384427] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    8.386167] e820: reserve RAM buffer [mem 0x1fffe000-0x1fffffff]
[    8.389686] NET: Registered protocol family 23
[    8.392358] Bluetooth: Core ver 2.16
[    8.393601] NET: Registered protocol family 31
[    8.395060] Bluetooth: HCI device and connection manager initialized
[    8.396152] Bluetooth: HCI socket layer initialized
[    8.400066] Bluetooth: L2CAP socket layer initialized
[    8.401923] Bluetooth: SCO socket layer initialized
[    8.404028] NET: Registered protocol family 8
[    8.405314] NET: Registered protocol family 20
[    8.408698] cfg80211: Calling CRDA to update world regulatory domain
[    8.416436] nfc: nfc_init: NFC Core ver 0.1
[    8.417924] NET: Registered protocol family 39
[    8.423100] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    8.424084] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    8.426121] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    8.432063] Switching to clocksource kvm-clock
[    9.047880] FS-Cache: Loaded
[    9.052624] CacheFiles: Loaded
[    9.053818] pnp: PnP ACPI init
[    9.054994] ACPI: bus type PNP registered
[    9.056450] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:3)
[    9.059009] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    9.061005] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:3)
[    9.064631] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    9.066567] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 =
Active:0 Dest:3)
[    9.069240] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    9.071201] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:3)
[    9.073629] pnp 00:03: [dma 2]
[    9.074842] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    9.076931] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:3)
[    9.079629] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    9.081655] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:3)
[    9.084206] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    9.086997] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    9.089542] pnp: PnP ACPI: found 7 devices
[    9.090746] ACPI: bus type PNP unregistered
[    9.200660] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    9.202230] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    9.205598] NET: Registered protocol family 2
[    9.214670] TCP established hash table entries: 4096 (order: 4, 65536 by=
tes)
[    9.217085] TCP bind hash table entries: 4096 (order: 6, 327680 bytes)
[    9.219648] TCP: Hash tables configured (established 4096 bind 4096)
[    9.221628] TCP: reno registered
[    9.222731] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    9.224535] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    9.227507] NET: Registered protocol family 1
[    9.246162] RPC: Registered named UNIX socket transport module.
[    9.248322] RPC: Registered udp transport module.
[    9.249692] RPC: Registered tcp transport module.
[    9.251015] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    9.253023] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    9.254677] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    9.256332] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    9.258055] pci 0000:00:02.0: Boot video device
[    9.259439] PCI: CLS 0 bytes, default 64
[    9.367999] DMA-API: preallocated 65536 debug entries
[    9.369563] DMA-API: debugging enabled by kernel config
[    9.386688] kvm: no hardware support
[    9.388051] has_svm: not amd
[    9.389090] kvm: no hardware support
[    9.394807] Machine check injector initialized
[    9.410221] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    9.411928] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    9.415284] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    9.419432] blowfish-x86_64: performance on this CPU would be suboptimal=
: disabling blowfish-x86_64.
[    9.422539] cryptomgr_test (35) used greatest stack depth: 5984 bytes le=
ft
[    9.428846] twofish-x86_64-3way: performance on this CPU would be subopt=
imal: disabling twofish-x86_64-3way.
[    9.433184] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    9.465301] Initializing RT-Tester: OK
[    9.467160] audit: initializing netlink socket (disabled)
[    9.469034] type=3D2000 audit(1364346487.468:1): initialized
[    9.582675] Kprobe smoke test started
[    9.707599] Kprobe smoke test passed successfully
[    9.723369] bounce pool size: 64 pages
[    9.724887] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    9.730881] VFS: Disk quotas dquot_6.5.2
[    9.732510] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    9.744909] DLM installed
[    9.753095] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    9.765094] FS-Cache: Netfs 'nfs' registered for caching
[    9.774153] NFS: Registering the id_resolver key type
[    9.775568] Key type id_resolver registered
[    9.776631] Key type id_legacy registered
[    9.777766] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    9.791793] FS-Cache: Netfs 'cifs' registered for caching
[    9.801179] Key type cifs.spnego registered
[    9.802633] Key type cifs.idmap registered
[    9.804216] NTFS driver 2.1.30 [Flags: R/W].
[    9.806260] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    9.807896] jffs2: version 2.2. (NAND) (SUMMARY) =20
[    9.811833] ROMFS MTD (C) 2007 Red Hat, Inc.
[    9.813416] QNX4 filesystem 0.2.3 registered.
[    9.817330] fuse init (API version 7.21)
[    9.826317] JFS: nTxBlock =3D 3406, nTxLock =3D 27254
[    9.844730] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, no debug enabled
[    9.869008] 9p: Installing v9fs 9p2000 file system support
[    9.870874] FS-Cache: Netfs '9p' registered for caching
[    9.872935] NILFS version 2 loaded
[    9.874128] BeFS version: 0.9.3
[    9.875376] OCFS2 1.5.0
[    9.880977] ocfs2: Registered cluster interface o2cb
[    9.884788] ocfs2: Registered cluster interface user
[    9.886149] OCFS2 DLMFS 1.5.0
[    9.894746] OCFS2 User DLM kernel interface loaded
[    9.896359] OCFS2 Node Manager 1.5.0
[    9.898805] OCFS2 DLM 1.5.0
[    9.907842] Btrfs loaded
[    9.925059] GFS2 installed
[    9.926919] ceph: loaded (mds proto 32)
[    9.928182] msgmni has been set to 851
[    9.938698] alg: No test for cipher_null (cipher_null-generic)
[    9.943685] alg: No test for ecb(cipher_null) (ecb-cipher_null)
[    9.949721] alg: No test for compress_null (compress_null-generic)
[    9.954691] alg: No test for digest_null (digest_null-generic)
[    9.957085] cryptomgr_test (70) used greatest stack depth: 5600 bytes le=
ft
[    9.971161] cryptomgr_test (74) used greatest stack depth: 5408 bytes le=
ft
[   10.114158] cryptomgr_test (101) used greatest stack depth: 5104 bytes l=
eft
[   10.150688] alg: No test for stdrng (krng)
[   10.176229] alg: No test for fips(ansi_cprng) (fips_ansi_cprng)
[   10.183709] NET: Registered protocol family 38
[   10.185292] async_tx: api initialized (async)
[   10.191765] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 250)
[   10.194123] io scheduler noop registered
[   10.195433] io scheduler deadline registered
[   10.197301] io scheduler cfq registered (default)
[   10.199964] list_sort_test: start testing list_sort()
[   10.206274] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[   10.208169] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[   10.209968] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[   10.214490] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver =
version: 0.1
[   10.216840] cpcihp_generic: not configured, disabling.
[   10.218490] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[   10.220375] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[   10.222561] acpiphp: Slot [3] registered
[   10.223970] acpiphp: Slot [4] registered
[   10.225438] acpiphp: Slot [5] registered
[   10.226821] acpiphp: Slot [6] registered
[   10.228220] acpiphp: Slot [7] registered
[   10.229628] acpiphp: Slot [8] registered
[   10.231003] acpiphp: Slot [9] registered
[   10.232426] acpiphp: Slot [10] registered
[   10.246755] acpiphp: Slot [11] registered
[   10.248184] acpiphp: Slot [12] registered
[   10.249547] acpiphp: Slot [13] registered
[   10.250915] acpiphp: Slot [14] registered
[   10.252356] acpiphp: Slot [15] registered
[   10.253817] acpiphp: Slot [16] registered
[   10.255236] acpiphp: Slot [17] registered
[   10.256654] acpiphp: Slot [18] registered
[   10.258057] acpiphp: Slot [19] registered
[   10.259427] acpiphp: Slot [20] registered
[   10.260769] acpiphp: Slot [21] registered
[   10.262126] acpiphp: Slot [22] registered
[   10.263513] acpiphp: Slot [23] registered
[   10.264919] acpiphp: Slot [24] registered
[   10.266319] acpiphp: Slot [25] registered
[   10.267719] acpiphp: Slot [26] registered
[   10.269153] acpiphp: Slot [27] registered
[   10.270516] acpiphp: Slot [28] registered
[   10.271903] acpiphp: Slot [29] registered
[   10.273330] acpiphp: Slot [30] registered
[   10.274766] acpiphp: Slot [31] registered
[   10.281658] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[   10.285239] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[   10.287887] vmlfb: initializing
[   10.289052] Could not find Carillo Ranch MCH device.
[   10.290817] no IO addresses supplied
[   10.292373] hgafb: HGA card not detected.
[   10.293714] hgafb: probe of hgafb.0 failed with error -22
[   10.295909] usbcore: registered new interface driver udlfb
[   10.309619] uvesafb: failed to execute /sbin/v86d
[   10.311135] uvesafb: make sure that the v86d helper is installed and exe=
cutable
[   10.313610] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[   10.315625] uvesafb: vbe_init() failed with -22
[   10.317146] uvesafb: probe of uvesafb.0 failed with error -22
[   10.319888] ipmi message handler version 39.2
[   10.321399] ipmi device interface
[   10.322840] IPMI System Interface driver.
[   10.324497] ipmi_si: Adding default-specified kcs state machine
[   10.326567] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[   10.329705] ipmi_si: Interface detection failed
[   10.331411] ipmi_si: Adding default-specified smic state machine
[   10.333358] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[   10.336381] ipmi_si: Interface detection failed
[   10.337941] ipmi_si: Adding default-specified bt state machine
[   10.339796] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[   10.342552] ipmi_si: Interface detection failed
[   10.344294] ipmi_si: Unable to find any System Interface(s)
[   10.345910] IPMI Watchdog: driver initialized
[   10.347182] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[   10.350414] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[   10.352952] ACPI: Power Button [PWRF]
[   10.367585] GHES: HEST is not enabled!
[   10.369066] ioatdma: Intel(R) QuickData Technology Driver 4.00
[   10.373032] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[   10.374860] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 =
Active:0 Dest:3)
[   10.377676] virtio-pci 0000:00:04.0: setting latency timer to 64
[   10.381581] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[   10.383379] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 =
Active:0 Dest:3)
[   10.386042] virtio-pci 0000:00:05.0: setting latency timer to 64
[   10.389849] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[   10.391482] virtio-pci 0000:00:06.0: setting latency timer to 64
[   10.392892] tsc: Refined TSC clocksource calibration: 2693.503 MHz
[   10.398837] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[   10.400727] virtio-pci 0000:00:07.0: setting latency timer to 64
[   10.406423] virtio-pci 0000:00:08.0: setting latency timer to 64
[   10.409847] virtio-pci 0000:00:09.0: setting latency timer to 64
[   10.413409] virtio-pci 0000:00:0a.0: setting latency timer to 64
[   10.416302] XENFS: not registering filesystem on non-xen platform
[   10.418947] HDLC line discipline maxframe=3D4096
[   10.420358] N_HDLC line discipline registered.
[   10.421871] r3964: Philips r3964 Driver $Revision: 1.10 $
[   10.423336] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[   10.455233] 00:05: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[   10.461189] Cyclades driver 2.6
[   10.462857] MOXA Intellio family driver version 6.0k
[   10.464755] MOXA Smartio/Industio family driver version 2.0.5
[   10.466708] Initializing Nozomi driver 2.1d
[   10.468364] RocketPort device driver module, version 2.09, 12-June-2003
[   10.470496] No rocketport ports found; unloading driver
[   10.474338] SyncLink GT
[   10.475486] SyncLink GT, tty major#244
[   10.477005] SyncLink GT no devices found
[   10.478288] SyncLink MultiPort driver $Revision: 4.38 $
[   10.511373] SyncLink MultiPort driver $Revision: 4.38 $, tty major#243
[   10.513288] SyncLink serial driver $Revision: 4.38 $
[   10.545424] SyncLink serial driver $Revision: 4.38 $, tty major#242
[   10.557746] lp: driver loaded but no devices found
[   10.559279] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 =
Exp $
[   10.561295] ac.o: No PCI boards found.
[   10.562487] ac.o: For an ISA board you must supply memory and irq parame=
ters.
[   10.573206] Non-volatile memory driver v1.3
[   10.581673] ppdev: user-space parallel port driver
[   10.583223] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[   10.588010] smapi::smapi_init, ERROR invalid usSmapiID
[   10.589574] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[   10.592362] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[   10.594563] mwave: mwavedd::mwave_init: Error: Failed to initialize
[   10.596472] Linux agpgart interface v0.103
[   10.602123] SyncLink PC Card driver $Revision: 4.34 $, tty major#240
[   10.604327] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[   10.606988] Hangcheck: Using getrawmonotonic().
[   10.609011] [drm] Initialized drm 1.1.0 20060810
[   10.610997] [drm] radeon kernel modesetting enabled.
[   10.613975] parport_pc 00:04: reported by Plug and Play ACPI
[   10.615887] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[   10.717868] lp0: using parport0 (interrupt-driven).
[   10.727436] Floppy drive(s): fd0 is 1.44M
[   10.742883] brd: module loaded
[   10.749093] FDC 0 is a S82078B
[   10.752142] loop: module loaded
[   10.755369] Compaq SMART2 Driver (v 2.6.0)
[   10.757167] HP CISS Driver (v 3.6.26)
[   10.764332] MM: desc_per_page =3D 128
[   10.772275] nbd: registered device at major 43
[   10.792163] virtio-pci 0000:00:05.0: irq 40 for MSI/MSI-X
[   10.793960] virtio-pci 0000:00:05.0: irq 41 for MSI/MSI-X
[   10.832694]  vda: unknown partition table
[   10.840973] virtio-pci 0000:00:06.0: irq 42 for MSI/MSI-X
[   10.842661] virtio-pci 0000:00:06.0: irq 43 for MSI/MSI-X
[   10.893723]  vdb: unknown partition table
[   10.896395] virtio-pci 0000:00:07.0: irq 44 for MSI/MSI-X
[   10.901235] virtio-pci 0000:00:07.0: irq 45 for MSI/MSI-X
[   10.963690]  vdc: unknown partition table
[   10.966353] virtio-pci 0000:00:08.0: irq 46 for MSI/MSI-X
[   10.969303] virtio-pci 0000:00:08.0: irq 47 for MSI/MSI-X
[   11.018748]  vdd: unknown partition table
[   11.021298] virtio-pci 0000:00:09.0: irq 48 for MSI/MSI-X
[   11.023059] virtio-pci 0000:00:09.0: irq 49 for MSI/MSI-X
[   11.062096]  vde: unknown partition table
[   11.064797] virtio-pci 0000:00:0a.0: irq 50 for MSI/MSI-X
[   11.066533] virtio-pci 0000:00:0a.0: irq 51 for MSI/MSI-X
[   11.130127]  vdf: unknown partition table
[   11.134649] events: mcg drbd: 10
[   11.184705] drbd: initialized. Version: 8.4.2 (api:1/proto:86-101)
[   11.186599] drbd: built-in
[   11.187638] drbd: registered as block device major 147
[   11.189511] rbd: loaded rbd (rados block device)
[   11.191209] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[   11.193962] lkdtm: No crash points registered, enable through debugfs
[   11.196294] Phantom Linux Driver, version n0.9.8, init OK
[   11.198640] i2c-core: driver [apds9802als] using legacy suspend method
[   11.200567] i2c-core: driver [apds9802als] using legacy resume method
[   11.202548] i2c-core: driver [isl29003] using legacy suspend method
[   11.204490] i2c-core: driver [isl29003] using legacy resume method
[   11.206513] i2c-core: driver [tsl2550] using legacy suspend method
[   11.208389] i2c-core: driver [tsl2550] using legacy resume method
[   11.210531] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[   11.213395] c2port c2port0: C2 port uc added
[   11.214692] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[   11.218446] usbcore: registered new interface driver pn533
[   11.220082] Uniform Multi-Platform E-IDE driver
[   11.221908] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[   11.224158] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[   11.226284] pci 0000:00:01.1: setting latency timer to 64
[   11.227972]     ide0: BM-DMA at 0xc1e0-0xc1e7
[   11.229563]     ide1: BM-DMA at 0xc1e8-0xc1ef
[   11.231006] Probing IDE interface ide0...
[   11.802028] Probing IDE interface ide1...
[   12.540961] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[   13.213132] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[   13.215189] hdc: MWDMA2 mode selected
[   13.216835] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[   13.218512] ide1 at 0x170-0x177,0x376 on irq 15
[   13.223194] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[   13.226146] ide-gd driver 1.18
[   13.227245] ide-cd driver 5.00
[   13.246866] ide-cd: hdc: ATAPI 4X DVD-ROM drive, 512kB Cache
[   13.252514] cdrom: Uniform CD-ROM driver Revision: 3.20
[   13.259019] Loading iSCSI transport class v2.0-870.
[   13.264315] rdac: device handler registered
[   13.268690] hp_sw: device handler registered
[   13.270043] emc: device handler registered
[   13.271277] alua: device handler registered
[   13.288069] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[   13.289908] fnic: Successfully Initialized Trace Buffer
[   13.294901] bnx2fc: Broadcom NetXtreme II FCoE Driver bnx2fc v1.0.13 (De=
c 21, 2012)
[   13.300224] iscsi: registered transport (tcp)
[   13.302078] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[   13.304881] Detecting Adaptec I2O RAID controllers...
[   13.306957] Adaptec aacraid driver 1.2-0[30000]-ms
[   13.308952] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[   13.312244] isci: Intel(R) C600 SAS Controller Driver - version 1.1.0
[   13.314482] scsi: <fdomain> Detection failed (no card)
[   13.316671] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driv=
er: 8.04.00.08-k.
[   13.319560] iscsi: registered transport (qla4xxx)
[   13.321118] QLogic iSCSI HBA Driver
[   13.322223] Brocade BFA FC/FCOE SCSI driver - version: 3.1.2.1
[   13.324697] DC390: clustering now enabled by default. If you get problem=
s load
[   13.326852]        with "disable_clustering=3D1" and report to maintaine=
rs
[   13.329056] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[   13.332083] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[   13.334093] megasas: 06.506.00.00-rc1 Sat. Feb. 9 17:00:00 PDT 2013
[   13.337111] mpt2sas version 14.100.00.00 loaded
[   13.340230] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[   13.342404] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[   13.345517] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[   13.347801] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v=
3.26.02.000.
[   13.350243] ppa: Version 2.07 (for Linux 2.4.x)
[   13.354207] imm: Version 2.05 (for Linux 2.4.0)
[   13.356263] ipr: IBM Power RAID SCSI Device Driver version: 2.6.0 (Novem=
ber 16, 2012)
[   13.358759] RocketRAID 3xxx/4xxx Controller driver v1.8
[   13.360394] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[   13.362687] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age =
0xf, 4 bits.
[   13.364988] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx=
 0.
[   13.366797] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[   13.368658] iscsi: registered transport (cxgb3i)
[   13.370124] Chelsio T4 iSCSI Driver cxgb4i v0.9.1 (Aug. 2010)
[   13.371928] iscsi: registered transport (cxgb4i)
[   13.373398] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2=
012)
[   13.375545] iscsi: registered transport (bnx2i)
[   13.380969] iscsi: registered transport (be2iscsi)
[   13.382398] In beiscsi_module_init, tt=3Dffffffff83d83cc0
[   13.384890] VMware PVSCSI driver - version 1.0.2.0-k
[   13.386448] hv_vmbus: registering driver hv_storvsc
[   13.387898] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[   13.389793] osst :I: Tape driver with OnStream support version 0.99.4
[   13.389793] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[   13.395033] SCSI Media Changer driver v0.25=20
[   13.396645] osd: LOADED open-osd 0.2.1
[   13.412758] scsi_debug: host protection
[   13.414003] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[   13.419629] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[   13.424238] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[   13.427319] sd 0:0:0:0: Attached scsi generic sg0 type 0
[   13.429049] sd 0:0:0:0: [sda] Write Protect is off
[   13.430435] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[   13.435520] Rounding down aligned max_sectors from 4294967295 to 4294967=
288
[   13.436550] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[   13.472882]  sda: unknown partition table
[   13.483175] SSFDC read-only Flash Translation layer
[   13.484987] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[   13.489550] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[   13.491298] Could not find PAR responsible for SC520CDP Flash Bank #0
[   13.492778] sd 0:0:0:0: [sda] Attached SCSI disk
[   13.494286] Trying default address 0x8400000
[   13.495525] Could not find PAR responsible for SC520CDP Flash Bank #1
[   13.497361] Trying default address 0x8c00000
[   13.498602] Could not find PAR responsible for SC520CDP DIL Flash
[   13.500260] Trying default address 0x9400000
[   13.501613] SC520 CDP flash device: 0x800000 at 0x8400000
[   13.503062] Failed to ioremap_nocache
[   13.504156] NetSc520 flash device: 0x100000 at 0x200000
[   13.505570] Failed to ioremap_nocache
[   13.506673] Failed to ioremap_nocache
[   13.508047] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[   13.533810] No recognised DiskOnChip devices found
[   13.535257] slram: not enough parameters.
[   13.536607] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel =
Networks.
[   13.538938] pmc551: not detected
[   13.547575] ftl_cs: FTL header not found.
[   13.583518] No valid DiskOnChip devices found
[   13.585165] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.587772] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.590452] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.593089] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.595751] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.598437] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[   13.601069] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba N=
AND 128MiB 1,8V 8-bit), 128MiB, page size: 512, OOB size: 16
[   13.604564] flash size: 128 MiB
[   13.605648] page size: 512 bytes
[   13.606653] OOB area size: 16 bytes
[   13.607748] sector size: 16 KiB
[   13.608849] pages number: 262144
[   13.609882] pages per sector: 32
[   13.610948] bus width: 8
[   13.611832] bits in sector size: 14
[   13.612998] bits in page size: 9
[   13.614072] bits in OOB size: 4
[   13.615097] flash size with OOB: 135168 KiB
[   13.616394] page address bytes: 4
[   13.617432] sector address bytes: 3
[   13.618521] options: 0x42
[   13.623337] Scanning device for bad blocks
[   13.748907] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[   13.750580] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[   13.755732] ftl_cs: FTL header not found.
[   13.759595] usbcore: registered new interface driver alauda
[   13.808370] onenand_wait: timeout! ctrl=3D0x0000 intr=3D0x0000
[   13.810006] OneNAND Manufacturer: Samsung (0xec)
[   13.811382] OneNAND 16MB 1.8V 16-bit (0x04)
[   13.812718] OneNAND version =3D 0x001e
[   13.813857] Lock scheme is Continuous Lock
[   13.815167] Scanning device for bad blocks
[   13.819949] Creating 1 MTD partitions on "OneNAND simulator":
[   13.821685] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[   13.825120] ftl_cs: FTL header not found.
[   13.955131] parport_pc 00:04: master is unqueued, this is deprecated
[   13.959179] parport0: AVR Butterfly
[   13.960479] parport0: cannot grant exclusive access for device spi-lm70l=
lp
[   13.962425] spi-lm70llp: spi_lm70llp probe fail, status -12
[   13.964452] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[   13.978200] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S.=
 Miller (davem@redhat.com)
[   13.989023] tun: Universal TUN/TAP device driver, 1.6
[   13.990511] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[   13.993192] netif_napi_add() called with weight 128 on device eth%d
[   13.995370] virtio-pci 0000:00:04.0: irq 52 for MSI/MSI-X
[   13.997044] virtio-pci 0000:00:04.0: irq 53 for MSI/MSI-X
[   13.998665] virtio-pci 0000:00:04.0: irq 54 for MSI/MSI-X
[   14.053623] arcnet loaded.
[   14.054561] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[   14.061712] arcnet: RFC1051 "simple standard" (`s') encapsulation suppor=
t loaded.
[   14.064002] arcnet: raw mode (`r') encapsulation support loaded.
[   14.065730] arcnet: cap mode (`c') encapsulation support loaded.
[   14.067403] arcnet: COM90xx chipset support
[   14.376245] S3: No ARCnet cards found.
[   14.377585] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[   14.379731] E-mail me if you actually test this driver, please!
[   14.381529]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[   14.383968] arcnet: RIM I (entirely mem-mapped) support
[   14.404728] E-mail me if you actually test the RIM I driver, please!
[   14.406482] Given: node 00h, shmem 0h, irq 0
[   14.407736] No autoprobe for RIM I; you must specify the shmem and irq!
[   14.409650] arcnet: COM20020 PCI support
[   14.411269] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[   14.414355] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <joh=
ns393@maroon.tc.umn.edu>
[   14.417017] vcan: Virtual CAN interface driver
[   14.418308] slcan: serial line CAN interface driver
[   14.419707] slcan: 10 dynamic interface channels.
[   14.421117] CAN device driver interface
[   14.422497] usbcore: registered new interface driver ems_usb
[   14.436767] usbcore: registered new interface driver esd_usb2
[   14.438528] sja1000 CAN netdevice driver
[   14.441672] pcnet32: pcnet32.c:v1.35 21.Apr.2008 tsbogend@alpha.franken.=
de
[   14.443788] Atheros(R) L2 Ethernet Driver - version 2.2.3
[   14.445461] Copyright (c) 2007 Atheros Corporation.
[   14.447580] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.16 (Dec 05=
, 2012)
[   14.464737] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.78.02-0 (2013/01/14)
[   14.468465] Brocade 10G Ethernet driver - version: 3.1.2.1
[   14.471143] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[   14.473298] dmfe: Davicom DM9xxx net driver, version 1.36.4 (2002-01-17)
[   14.475318] v1.01-e (2.4 port) Sep-11-2006  Donald Becker <becker@scyld.=
com>
[   14.475318]   http://www.scyld.com/network/drivers.html
[   14.479151] uli526x: ULi M5261/M5263 net driver, version 0.9.3 (2005-7-2=
9)
[   14.481875] vxge: Copyright(c) 2002-2010 Exar Corp.
[   14.483261] vxge: Driver version: 2.5.3.22640-k
[   14.484924] e100: Intel(R) PRO/100 Network Driver, 3.5.24-k2-NAPI
[   14.486372] e100: Copyright(c) 1999-2006 Intel Corporation
[   14.488142] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   14.490041] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   14.492692] e1000 0000:00:03.0: setting latency timer to 64
[   14.880161] e1000 0000:00:03.0 eth1: (PCI:33MHz:32-bit) 52:54:00:12:34:56
[   14.882669] e1000 0000:00:03.0 eth1: Intel(R) PRO/1000 Network Connection
[   14.884863] e1000e: Intel(R) PRO/1000 Network Driver - 2.2.14-k
[   14.886609] e1000e: Copyright(c) 1999 - 2013 Intel Corporation.
[   14.888539] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.1.=
2-k
[   14.890285] igb: Copyright (c) 2007-2013 Intel Corporation.
[   14.892611] igbvf: Intel(R) Gigabit Virtual Function Network Driver - ve=
rsion 2.0.2-k
[   14.894690] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   14.896528] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.11.33-k
[   14.898872] ixgbe: Copyright (c) 1999-2013 Intel Corporation.
[   14.900847] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Ne=
twork Driver - version 2.7.12-k
[   14.903452] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[   14.905193] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[   14.907007] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   14.909012] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   14.910760] sky2: driver version 1.30
[   14.912732] myri10ge: Version 1.5.3-1.534
[   14.914320] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   14.916149] pch_gbe: EG20T PCH Gigabit Ethernet Driver - version 1.01
[   14.917660] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.1.38
[   14.919010] QLogic/NetXen Network Driver v4.0.80
[   14.920596] atp.c:v1.09=3Dac 2002/10/01 Donald Becker <becker@scyld.com>
[   14.923162] Solarflare NET driver v3.2
[   14.927046] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[   14.928819] tehuti: Options: hw_csum=20
[   14.930136] tlan: ThunderLAN driver v1.17
[   14.931430] tlan: 0 devices installed, PCI: 0  EISA: 0
[   14.933619] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   14.935094] AX.25: 6pack driver, Revision: 0.3.0
[   14.936442] YAM driver version 0.8 by F1OAT/F6FBB
[   14.940638] AX.25: bpqether driver version 004
[   14.941940] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   14.941940] baycom_ser_fdx: version 0.10
[   14.947744] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   14.949510] hdlcdrv: version 0.8
[   14.950550] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   14.950550] baycom_ser_hdx: version 0.10
[   14.956117] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   14.956117] baycom_par: version 0.9
[   14.961425] usbcore: registered new interface driver irda-usb
[   14.963172] usbcore: registered new interface driver stir4200
[   14.966533] usbcore: registered new interface driver mcs7780
[   14.985161] usbcore: registered new interface driver kingsun-sir
[   14.986923] usbcore: registered new interface driver ksdazzle-sir
[   14.988780] usbcore: registered new interface driver ks959-sir
[   14.991323] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   14.992898] plip0: Parallel port at 0x378, using IRQ 7.
[   14.994338] PPP generic driver version 2.4.2
[   14.996391] PPP BSD Compression module registered
[   14.997781] PPP Deflate Compression module registered
[   14.999341] PPP MPPE Compression module registered
[   15.000819] NET: Registered protocol family 24
[   15.002255] PPTP driver version 0.8.5
[   15.004497] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[   15.007173] CSLIP: code copyright 1989 Regents of the University of Cali=
fornia.
[   15.009451] SLIP linefill/keepalive option.
[   15.010896] hdlc: HDLC support module revision 1.22
[   15.012777] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   15.014768] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2=
=2E2kmprq
[   15.017038] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   15.018913] libipw: 802.11 data/management/control stack, git-1.1.13
[   15.020734] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@=
linux.intel.com>
[   15.023143] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, P=
avel Roskin <proski@gnu.org>, et al)
[   15.026099] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibso=
n <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   15.029614] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   15.031452] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <=
disdos@traum404.de>)
[   15.034305] usbcore: registered new interface driver orinoco_usb
[   15.036132] airo(): Probing for PCI adapters
[   15.037510] airo(): Finished probing for PCI adapters
[   15.039192] Atmel at76x USB Wireless LAN Driver 0.17 loading
[   15.041015] usbcore: registered new interface driver at76c50x-usb
[   15.043359] Broadcom 43xx driver loaded [ Features: PMNLS ]
[   15.045175] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[   15.054943] usbcore: registered new interface driver zd1211rw
[   15.057086] usbcore: registered new interface driver rtl8187
[   15.058979] usbcore: registered new interface driver rtl8192cu
[   15.065602] usbcore: registered new interface driver rndis_wlan
[   15.067379] usbcore: registered new interface driver zd1201
[   15.069215] usbcore: registered new interface driver usb8xxx
[   15.070879] libertas_sdio: Libertas SDIO driver
[   15.072256] libertas_sdio: Copyright Pierre Ossman
[   15.073775] libertas_spi: Libertas SPI driver
[   15.078822] usbcore: registered new interface driver lbtf_usb
[   15.080905] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   15.082574] Copyright(c) 2003-2013 Intel Corporation
[   15.084326] iwl4965: Intel(R) Wireless WiFi 4965 driver for Linux, in-tr=
ee:
[   15.086155] iwl4965: Copyright(c) 2003-2011 Intel Corporation
[   15.087932] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection=
 driver for Linux, in-tree:s
[   15.093586] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   15.095950] usbcore: registered new interface driver rt2500usb
[   15.097664] usbcore: registered new interface driver rt73usb
[   15.099297] usbcore: registered new interface driver rt2800usb
[   15.101070] usbcore: registered new interface driver p54usb
[   15.102856] mac80211_hwsim: Initializing radio 0
[   15.105744] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   15.108818] ieee80211 phy0: hwaddr 020000000000 registered
[   15.110492] mac80211_hwsim: Initializing radio 1
[   15.113745] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[   15.116569] ieee80211 phy1: hwaddr 020000000100 registered
[   15.118967] mac80211_hwsim: initializing netlink
[   15.121153] usbcore: registered new interface driver i2400m_usb
[   15.124094] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[   15.126352] VMware vmxnet3 virtual NIC driver - version 1.1.30.0-k-NAPI
[   15.128614] usbcore: registered new interface driver catc
[   15.130213] usbcore: registered new interface driver kaweth
[   15.131775] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethern=
et driver
[   15.134415] usbcore: registered new interface driver pegasus
[   15.136842] usbcore: registered new interface driver rtl8150
[   15.138611] hso: /c/kernel-tests/src/stable/drivers/net/usb/hso.c: Optio=
n Wireless
[   15.141066] usbcore: registered new interface driver hso
[   15.142678] usbcore: registered new interface driver asix
[   15.144756] usbcore: registered new interface driver ax88179_178a
[   15.147424] usbcore: registered new interface driver cdc_ether
[   15.150012] usbcore: registered new interface driver cdc_eem
[   15.152530] usbcore: registered new interface driver dm9601
[   15.155056] usbcore: registered new interface driver smsc75xx
[   15.157516] usbcore: registered new interface driver smsc95xx
[   15.159855] usbcore: registered new interface driver gl620a
[   15.161871] usbcore: registered new interface driver net1080
[   15.163524] usbcore: registered new interface driver plusb
[   15.165843] usbcore: registered new interface driver rndis_host
[   15.168405] usbcore: registered new interface driver cdc_subset
[   15.170800] usbcore: registered new interface driver zaurus
[   15.173212] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[   15.175813] usbcore: registered new interface driver int51x1
[   15.177513] usbcore: registered new interface driver cdc_phonet
[   15.179223] usbcore: registered new interface driver kalmia
[   15.180890] usbcore: registered new interface driver ipheth
[   15.182504] usbcore: registered new interface driver sierra_net
[   15.184260] usbcore: registered new interface driver cx82310_eth
[   15.186037] usbcore: registered new interface driver cdc_ncm
[   15.187673] usbcore: registered new interface driver lg-vl600
[   15.189352] hv_vmbus: registering driver hv_netvsc
[   15.191148] Madge ATM Ambassador driver version 1.2.4
[   15.192822] Madge ATM Horizon [Ultra] driver version 1.2.1
[   15.194658] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   15.196763] idt77252_init: at ffffffff841d7564
[   15.198226] Solos PCI Driver Version 1.04
[   15.199563] adummy: version 1.0
[   15.201569] I2O subsystem v1.325
[   15.202617] i2o: max drivers =3D 8
[   15.204473] I2O Configuration OSM v1.323
[   15.206120] I2O Bus Adapter OSM v1.317
[   15.219884] I2O Block Device OSM v1.325
[   15.234878] I2O SCSI Peripheral OSM v1.316
[   15.236268] I2O ProcFS OSM v1.316
[   15.237556] Fusion MPT base driver 3.04.20
[   15.238822] Copyright (c) 1999-2008 LSI Corporation
[   15.240384] Fusion MPT SPI Host driver 3.04.20
[   15.241919] Fusion MPT FC Host driver 3.04.20
[   15.243384] Fusion MPT SAS Host driver 3.04.20
[   15.244890] Fusion MPT misc device (ioctl) driver 3.04.20
[   15.246821] mptctl: Registered with Fusion MPT base driver
[   15.251764] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[   15.253278] Fusion MPT LAN driver 3.04.20
[   15.279428] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[   15.285159] aoe: AoE v81 initialised.
[   15.287994] usbcore: registered new interface driver hwa-rc
[   15.289662] usbcore: registered new interface driver i1480-dfu-usb
[   15.295214] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   15.297034] ehci-pci: EHCI PCI platform driver
[   15.298577] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   15.300485] uhci_hcd: USB Universal Host Controller Interface driver
[   15.302833] driver u132_hcd
[   15.310027] usbcore: registered new interface driver hwa-hc
[   15.314874] usbcore: registered new interface driver wusb-cbaf
[   15.316763] usbcore: registered new interface driver cdc_acm
[   15.318363] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[   15.320945] usbcore: registered new interface driver usblp
[   15.322557] usbcore: registered new interface driver cdc_wdm
[   15.324349] usbcore: registered new interface driver usbtmc
[   15.325941] Initializing USB Mass Storage driver...
[   15.327525] usbcore: registered new interface driver usb-storage
[   15.329282] USB Mass Storage support registered.
[   15.334019] usbcore: registered new interface driver ums-alauda
[   15.335725] usbcore: registered new interface driver ums-cypress
[   15.337513] usbcore: registered new interface driver ums-datafab
[   15.339207] usbcore: registered new interface driver ums_eneub6250
[   15.340970] usbcore: registered new interface driver ums-freecom
[   15.342691] usbcore: registered new interface driver ums-isd200
[   15.344456] usbcore: registered new interface driver ums-jumpshot
[   15.346255] usbcore: registered new interface driver ums-karma
[   15.347954] usbcore: registered new interface driver ums-onetouch
[   15.349791] usbcore: registered new interface driver ums-realtek
[   15.351486] usbcore: registered new interface driver ums-sddr09
[   15.353205] usbcore: registered new interface driver ums-sddr55
[   15.354977] usbcore: registered new interface driver ums-usbat
[   15.356826] usbcore: registered new interface driver mdc800
[   15.358351] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Dig=
ital Camera
[   15.363923] usbcore: registered new interface driver microtekX6
[   15.366002] usbcore: registered new interface driver usbserial
[   15.367831] usbcore: registered new interface driver usbserial_generic
[   15.369941] usbserial: USB Serial support registered for generic
[   15.371735] usbcore: registered new interface driver aircable
[   15.373597] usbserial: USB Serial support registered for aircable
[   15.375476] usbcore: registered new interface driver ark3116
[   15.380428] usbserial: USB Serial support registered for ark3116
[   15.382237] usbcore: registered new interface driver belkin_sa
[   15.384001] usbserial: USB Serial support registered for Belkin / Peraco=
m / GoHubs USB Serial Adapter
[   15.386745] usbcore: registered new interface driver ch341
[   15.388371] usbserial: USB Serial support registered for ch341-uart
[   15.390143] usbcore: registered new interface driver cp210x
[   15.391766] usbserial: USB Serial support registered for cp210x
[   15.393663] usbcore: registered new interface driver cyberjack
[   15.395404] usbserial: USB Serial support registered for Reiner SCT Cybe=
rjack USB card reader
[   15.398004] usbcore: registered new interface driver cypress_m8
[   15.399743] usbserial: USB Serial support registered for DeLorme Earthma=
te USB
[   15.401915] usbserial: USB Serial support registered for HID->COM RS232 =
Adapter
[   15.404200] usbserial: USB Serial support registered for Nokia CA-42 V2 =
Adapter
[   15.406563] usbcore: registered new interface driver usb_debug
[   15.408335] usbserial: USB Serial support registered for debug
[   15.410031] usbcore: registered new interface driver digi_acceleport
[   15.411858] usbserial: USB Serial support registered for Digi 2 port USB=
 adapter
[   15.414259] usbserial: USB Serial support registered for Digi 4 port USB=
 adapter
[   15.416868] usbcore: registered new interface driver io_edgeport
[   15.418749] usbserial: USB Serial support registered for Edgeport 2 port=
 adapter
[   15.421142] usbserial: USB Serial support registered for Edgeport 4 port=
 adapter
[   15.423382] usbserial: USB Serial support registered for Edgeport 8 port=
 adapter
[   15.425742] usbserial: USB Serial support registered for EPiC device
[   15.427565] usbcore: registered new interface driver io_ti
[   15.429229] usbserial: USB Serial support registered for Edgeport TI 1 p=
ort adapter
[   15.431535] usbserial: USB Serial support registered for Edgeport TI 2 p=
ort adapter
[   15.433926] usbcore: registered new interface driver empeg
[   15.435656] usbserial: USB Serial support registered for empeg
[   15.437601] usbcore: registered new interface driver ftdi_sio
[   15.439368] usbserial: USB Serial support registered for FTDI USB Serial=
 Device
[   15.441734] usbcore: registered new interface driver funsoft
[   15.443428] usbserial: USB Serial support registered for funsoft
[   15.445334] usbcore: registered new interface driver garmin_gps
[   15.446984] usbserial: USB Serial support registered for Garmin GPS usb/=
tty
[   15.449046] usbcore: registered new interface driver hp4x
[   15.450712] usbserial: USB Serial support registered for hp4X
[   15.452530] usbcore: registered new interface driver ipaq
[   15.454134] usbserial: USB Serial support registered for PocketPC PDA
[   15.456093] usbcore: registered new interface driver ipw
[   15.457735] usbserial: USB Serial support registered for IPWireless conv=
erter
[   15.459698] usbcore: registered new interface driver ir_usb
[   15.461388] usbserial: USB Serial support registered for IR Dongle
[   15.463177] usbcore: registered new interface driver iuu_phoenix
[   15.465050] usbserial: USB Serial support registered for iuu_phoenix
[   15.466966] usbcore: registered new interface driver keyspan
[   15.468719] usbserial: USB Serial support registered for Keyspan - (with=
out firmware)
[   15.471116] usbserial: USB Serial support registered for Keyspan 1 port =
adapter
[   15.473329] usbserial: USB Serial support registered for Keyspan 2 port =
adapter
[   15.475653] usbserial: USB Serial support registered for Keyspan 4 port =
adapter
[   15.477983] usbcore: registered new interface driver keyspan_pda
[   15.479821] usbserial: USB Serial support registered for Keyspan PDA
[   15.481692] usbserial: USB Serial support registered for Keyspan PDA - (=
prerenumeration)
[   15.484264] usbserial: USB Serial support registered for Xircom / Entreg=
ra PGS - (prerenumeration)
[   15.486899] usbcore: registered new interface driver kl5kusb105
[   15.488742] usbserial: USB Serial support registered for KL5KUSB105D / P=
almConnect
[   15.490956] usbcore: registered new interface driver kobil_sct
[   15.492614] usbserial: USB Serial support registered for KOBIL USB smart=
 card terminal
[   15.495039] usbcore: registered new interface driver mct_u232
[   15.496795] usbserial: USB Serial support registered for MCT U232
[   15.498597] usbcore: registered new interface driver mos7720
[   15.500319] usbserial: USB Serial support registered for Moschip 2 port =
adapter
[   15.502498] usbcore: registered new interface driver mos7840
[   15.504286] usbserial: USB Serial support registered for Moschip 7840/78=
20 USB Serial Driver
[   15.506908] usbcore: registered new interface driver moto_modem
[   15.508730] usbserial: USB Serial support registered for moto-modem
[   15.510564] usbcore: registered new interface driver navman
[   15.512267] usbserial: USB Serial support registered for navman
[   15.514084] usbcore: registered new interface driver omninet
[   15.515784] usbserial: USB Serial support registered for ZyXEL - omni.ne=
t lcd plus usb
[   15.518205] usbcore: registered new interface driver opticon
[   15.519822] usbserial: USB Serial support registered for opticon
[   15.521611] usbcore: registered new interface driver option
[   15.523279] usbserial: USB Serial support registered for GSM modem (1-po=
rt)
[   15.525513] usbcore: registered new interface driver oti6858
[   15.527260] usbserial: USB Serial support registered for oti6858
[   15.529153] usbcore: registered new interface driver pl2303
[   15.530819] usbserial: USB Serial support registered for pl2303
[   15.532749] usbcore: registered new interface driver qcaux
[   15.534374] usbserial: USB Serial support registered for qcaux
[   15.536192] usbcore: registered new interface driver qcserial
[   15.537917] usbserial: USB Serial support registered for Qualcomm USB mo=
dem
[   15.539914] usbcore: registered new interface driver safe_serial
[   15.541740] usbserial: USB Serial support registered for safe_serial
[   15.543530] usbcore: registered new interface driver siemens_mpi
[   15.545459] usbserial: USB Serial support registered for siemens_mpi
[   15.547247] usbcore: registered new interface driver sierra
[   15.548909] usbserial: USB Serial support registered for Sierra USB modem
[   15.550801] usbcore: registered new interface driver spcp8x5
[   15.552644] usbserial: USB Serial support registered for SPCP8x5
[   15.554361] usbcore: registered new interface driver ssu100
[   15.555996] usbserial: USB Serial support registered for Quatech SSU-100=
 USB to Serial Driver
[   15.558524] usbcore: registered new interface driver symbolserial
[   15.560300] usbserial: USB Serial support registered for symbol
[   15.562084] usbcore: registered new interface driver ti_usb_3410_5052
[   15.563834] usbserial: USB Serial support registered for TI USB 3410 1 p=
ort adapter
[   15.566384] usbserial: USB Serial support registered for TI USB 5052 2 p=
ort adapter
[   15.568917] usbcore: registered new interface driver visor
[   15.570551] usbserial: USB Serial support registered for Handspring Viso=
r / Palm OS
[   15.584820] usbserial: USB Serial support registered for Sony Clie 5.0
[   15.586635] usbserial: USB Serial support registered for Sony Clie 3.5
[   15.588642] usbcore: registered new interface driver whiteheat
[   15.590284] usbserial: USB Serial support registered for Connect Tech - =
WhiteHEAT - (prerenumeration)
[   15.592952] usbserial: USB Serial support registered for Connect Tech - =
WhiteHEAT
[   15.595183] usbcore: registered new interface driver vivopay_serial
[   15.597077] usbserial: USB Serial support registered for vivopay-serial
[   15.598963] usbcore: registered new interface driver zio
[   15.600635] usbserial: USB Serial support registered for zio
[   15.602364] usbcore: registered new interface driver adutux
[   15.604505] usbcore: registered new interface driver appledisplay
[   15.606322] usbcore: registered new interface driver cypress_cy7c63
[   15.608296] usbcore: registered new interface driver cytherm
[   15.610020] usbcore: registered new interface driver emi26 - firmware lo=
ader
[   15.612081] usbcore: registered new interface driver emi62 - firmware lo=
ader
[   15.613975] driver ftdi-elan
[   15.627866] usbcore: registered new interface driver ftdi-elan
[   15.629652] usbcore: registered new interface driver idmouse
[   15.631303] usbcore: registered new interface driver iowarrior
[   15.633000] usbcore: registered new interface driver isight_firmware
[   15.634739] usbcore: registered new interface driver usblcd
[   15.636413] usbcore: registered new interface driver ldusb
[   15.638078] usbcore: registered new interface driver usbled
[   15.639798] usbcore: registered new interface driver legousbtower
[   15.641683] usbcore: registered new interface driver rio500
[   15.643335] usbcore: registered new interface driver usbtest
[   15.645069] usbcore: registered new interface driver trancevibrator
[   15.646788] usbcore: registered new interface driver uss720
[   15.648441] uss720: v0.6:USB Parport Cable driver for Cables using the L=
ucent Technologies USS720 Chip
[   15.650982] uss720: NOTE: this is a special purpose driver to allow nons=
tandard
[   15.653115] uss720: protocols (eg. bitbang) over USS720 usb to parallel =
cables
[   15.655159] uss720: If you just want to connect to a printer, use usblp =
instead
[   15.657447] usbcore: registered new interface driver usbsevseg
[   15.659238] usbcore: registered new interface driver yurex
[   15.661069] usbcore: registered new interface driver sisusb
[   15.662838] usbcore: registered new interface driver cxacru
[   15.664739] usbcore: registered new interface driver speedtch
[   15.666568] usbcore: registered new interface driver ueagle-atm
[   15.668371] xusbatm: malformed module parameters
[   15.670300] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   15.674531] serio: i8042 KBD port at 0x60,0x64 irq 1
[   15.676305] serio: i8042 AUX port at 0x60,0x64 irq 12
[   15.678576] parport0: cannot grant exclusive access for device parkbd
[   15.766939] mousedev: PS/2 mouse device common for all mice
[   15.770842] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   15.774554] usbcore: registered new interface driver appletouch
[   15.776522] usbcore: registered new interface driver bcm5974
[   15.780079] usbcore: registered new interface driver iforce
[   15.782933] usbcore: registered new interface driver xpad
[   15.785692] parport0: cannot grant exclusive access for device walkera07=
01
[   15.787678] walkera0701: failed to register parport device
[   15.789545] usbcore: registered new interface driver usb_acecad
[   15.791381] usbcore: registered new interface driver aiptek
[   15.793237] usbcore: registered new interface driver gtco
[   15.795195] usbcore: registered new interface driver hanwang
[   15.797094] usbcore: registered new interface driver kbtab
[   15.798888] usbcore: registered new interface driver wacom
[   15.801731] mk712: device not present
[   15.804229] usbcore: registered new interface driver usbtouchscreen
[   15.806962] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   15.810047] usbcore: registered new interface driver ati_remote2
[   15.811972] cm109: Keymap for Komunikate KIP1000 phone loaded
[   15.815035] usbcore: registered new interface driver cm109
[   15.816731] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[   15.818883] usbcore: registered new interface driver keyspan_remote
[   15.821340] input: PC Speaker as /devices/platform/pcspkr/input/input2
[   15.824073] usbcore: registered new interface driver powermate
[   15.826337] usbcore: registered new interface driver yealink
[   15.828450] rtc_cmos 00:00: RTC can wake from S4
[   15.831119] rtc_cmos 00:00: rtc core: registered rtc_cmos as rtc0
[   15.833233] rtc_cmos 00:00: alarms up to one day, 114 bytes nvram, hpet =
irqs
[   15.838251] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   15.844970] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   15.847073] i2c /dev entries driver
[   15.849730] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, r=
evision 0
[   15.966196] usbcore: registered new interface driver i2c-diolan-u2c
[   15.968079] i2c-parport: adapter type unspecified
[   15.969531] i2c-parport-light: adapter type unspecified
[   15.971434] usbcore: registered new interface driver i2c-tiny-usb
[   15.973244] pps_ldisc: PPS line discipline registered
[   15.974773] pps_parport: parallel port PPS client
[   15.976348] parport0: cannot grant exclusive access for device pps_parpo=
rt
[   15.978299] pps_parport: couldn't register with parport0
[   15.980261] Driver for 1-wire Dallas network protocol.
[   15.982376] usbcore: registered new interface driver DS9490R
[   15.984368] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[   15.987274] i2c-core: driver [ds2782-battery] using legacy suspend method
[   15.990271] i2c-core: driver [ds2782-battery] using legacy resume method
[   15.992497] i2c-core: driver [max17040] using legacy suspend method
[   15.994198] i2c-core: driver [max17040] using legacy resume method
[   16.801001] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[   17.284244] i2c i2c-0: detect fail: address match, 0x2c
[   17.300241] i2c i2c-0: detect fail: address match, 0x2d
[   17.316612] i2c i2c-0: detect fail: address match, 0x2e
[   17.332190] i2c i2c-0: detect fail: address match, 0x2f
[   17.532206] applesmc: supported laptop not found!
[   17.533696] applesmc: driver init failed (ret=3D-19)!
[   25.885215] pc87360: PC8736x not detected, module not inserted
[   26.388839] usbcore: registered new interface driver pcwd_usb
[   26.390849] acquirewdt: WDT driver for Acquire single board computer ini=
tialising
[   26.393991] acquirewdt: I/O address 0x0043 already in use
[   26.395882] acquirewdt: probe of acquirewdt failed with error -5
[   26.397929] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   26.401770] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   26.403856] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   26.405734] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   26.407475] sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver v0.05
[   26.409866] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[   26.411780] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[   26.414219] ib700wdt: START method I/O 443 is not available
[   26.415899] ib700wdt: probe of ib700wdt failed with error -5
[   26.417548] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[   26.419892] wafer5823wdt: I/O address 0x0443 already in use
[   26.421766] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   26.423826] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[   26.425872] i6300ESB timer: probe of 0000:00:0b.0 failed with error -16
[   26.427768] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   26.429448] iTCO_vendor_support: vendor-support=3D0
[   26.430919] it87_wdt: no device
[   26.432195] sc1200wdt: build 20020303
[   26.433498] sc1200wdt: io parameter must be specified
[   26.435424] pc87413_wdt: Version 1.1 at io 0x2E
[   26.438233] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   26.441647] nv_tco: NV TCO WatchDog Timer Driver v0.01
[   26.444900] sbc60xxwdt: I/O address 0x0443 already in use
[   26.446958] sbc8360: failed to register misc device
[   26.448534] cpu5wdt: misc_register failed
[   26.450161] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[   26.453998] smsc37b787_wdt: Unable to register miscdev on minor 130
[   26.456341] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[   26.459897] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[   26.462412] w83627hf_wdt: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   26.464603] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   26.466628] w83697hf_wdt: watchdog not found at address 0x2e
[   26.468284] w83697hf_wdt: No W83697HF/HG could be found
[   26.469999] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[   26.472860] w83697ug_wdt: No W83697UG/UF could be found
[   26.474512] w83877f_wdt: I/O address 0x0443 already in use
[   26.476236] w83977f_wdt: driver v1.00
[   26.477474] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   26.480178] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   26.481954] machzwd: no ZF-Logic found
[   26.483204] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   26.485405] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   26.487917] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[   26.490847] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   26.494040] md: linear personality registered for level -1
[   26.495796] md: raid0 personality registered for level 0
[   26.497303] md: raid1 personality registered for level 1
[   26.499266] md: raid10 personality registered for level 10
[   26.502435] md: raid6 personality registered for level 6
[   26.505538] md: raid5 personality registered for level 5
[   26.508589] md: raid4 personality registered for level 4
[   26.511232] md: multipath personality registered for level -4
[   26.514271] md: faulty personality registered for level -5
[   26.518228] device-mapper: uevent: version 1.0.3
[   26.522584] device-mapper: ioctl: 4.24.0-ioctl (2013-01-15) initialised:=
 dm-devel@redhat.com
[   26.558841] device-mapper: multipath: version 1.5.1 loaded
[   26.563318] device-mapper: multipath round-robin: version 1.0.0 loaded
[   26.567949] device-mapper: multipath queue-length: version 0.1.0 loaded
[   26.573562] device-mapper: multipath service-time: version 0.2.0 loaded
[   26.581160] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   26.585949] device-mapper: raid: Loading target version 1.4.2
[   26.590500] Bluetooth: Virtual HCI driver ver 1.3
[   26.595451] Bluetooth: HCI UART driver ver 2.2
[   26.600137] Bluetooth: HCI H4 protocol initialized
[   26.603746] Bluetooth: HCI BCSP protocol initialized
[   26.607850] Bluetooth: HCILL protocol initialized
[   26.611318] Bluetooth: HCIATH3K protocol initialized
[   26.615561] usbcore: registered new interface driver bcm203x
[   26.620423] usbcore: registered new interface driver bpa10x
[   26.625004] usbcore: registered new interface driver bfusb
[   26.630913] usbcore: registered new interface driver btusb
[   26.635303] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   26.641182] usbcore: registered new interface driver ath3k
[   26.649316] CAPI 2.0 started up with major 68 (middleware)
[   26.654132] Modular ISDN core version 1.1.29
[   26.658900] NET: Registered protocol family 34
[   26.662301] DSP module 2.0
[   26.665061] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffie=
s.
[   26.676934] mISDN: Layer-1-over-IP driver Rev. 2.00
[   26.682139] 0 virtual devices registered
[   26.686309] b1pci: revision 1.1.2.2
[   26.689764] b1: revision 1.1.2.2
[   26.692487] b1dma: revision 1.1.2.3
[   26.695787] b1pci: revision 1.1.2.2
[   26.700326] t1pci: revision 1.1.2.2
[   26.704511] c4: revision 1.1.2.2
[   26.708631] mISDN: HFC-multi driver 2.03
[   26.712865] usbcore: registered new interface driver HFC-S_USB
[   26.716808] AVM Fritz PCI driver Rev. 2.3
[   26.721580] Sedlbauer Speedfax+ Driver Rev. 2.0
[   26.725510] Infineon ISDN Driver Rev. 1.0
[   26.726914] Winbond W6692 PCI driver Rev. 2.0
[   26.728390] mISDNipac module version 2.0
[   26.729538] mISDN: ISAR driver Rev. 2.1
[   26.730667] gigaset: Driver for Gigaset 307x
[   26.731897] gigaset: Kernel CAPI interface
[   26.733492] usbcore: registered new interface driver usb_gigaset
[   26.735195] usb_gigaset: USB Driver for Gigaset 307x using M105
[   26.737148] usbcore: registered new interface driver bas_gigaset
[   26.738791] bas_gigaset: USB Driver for Gigaset 307x
[   26.742236] AMD64 EDAC driver v3.4.0
[   26.743762] cpuidle: using governor ladder
[   26.745022] cpuidle: using governor menu
[   26.746398] sdhci: Secure Digital Host Controller Interface driver
[   26.748112] sdhci: Copyright(c) Pierre Ossman
[   26.749628] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   26.751282] wbsd: Copyright(c) Pierre Ossman
[   26.753141] VUB300 Driver rom wait states =3D 1C irqpoll timeout =3D 0400
[   26.765001] usbcore: registered new interface driver vub300
[   26.767147] usbcore: registered new interface driver ushc
[   26.768722] sdhci-pltfm: SDHCI platform and OF driver helper
[   26.775946] leds_ss4200: no LED devices found
[   26.803833] user_mad: couldn't register device number
[   26.805402] user_verbs: couldn't register device number
[   26.806894] ucm: couldn't register device number
[   26.814857] ib_qib: Unable to register ipathfs
[   26.853582] iscsi: registered transport (iser)
[   26.855686] EFI Variables Facility v0.08 2004-May-17
[   26.858791] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   26.860996] No iBFT detected.
[   26.865271] hidraw: raw HID events driver (C) Jiri Kosina
[   26.871280] usbcore: registered new interface driver usbhid
[   26.872885] usbhid: USB HID core driver
[   26.874839] usbip_core: USB/IP Core v1.0.0
[   26.876568] vhci_hcd vhci_hcd: USB/IP Virtual Host Controller
[   26.879133] vhci_hcd vhci_hcd: new USB bus registered, assigned bus numb=
er 1
[   26.908404] usb usb1: New USB device found, idVendor=3D1d6b, idProduct=
=3D0002
[   26.910271] usb usb1: New USB device strings: Mfr=3D3, Product=3D2, Seri=
alNumber=3D1
[   26.912410] usb usb1: Product: USB/IP Virtual Host Controller
[   26.914000] usb usb1: Manufacturer: Linux 3.9.0-rc4-00896-g03ba910 vhci_=
hcd
[   26.928690] usb usb1: SerialNumber: vhci_hcd
[   26.931536] hub 1-0:1.0: USB hub found
[   26.932945] hub 1-0:1.0: 8 ports detected
[   26.936160] vhci_hcd: USB/IP 'Virtual' Host Controller (VHCI) Driver v1.=
0.0
[   26.938433] usbcore: registered new interface driver usbip-host
[   26.940145] usbip_host: USB/IP Host Driver v1.0.0
[   26.941660] usbcore: registered new interface driver prism2_usb
[   26.943433] usbcore: registered new interface driver r8712u
[   26.946045] zram: Created 1 device(s) ...
[   26.947707] input: Speakup as /devices/virtual/input/input4
[   26.950232] initialized device: /dev/synth, node (MAJOR 10, MINOR 25)
[   26.952495] speakup 3.1.6: initialized
[   26.953680] synth name on entry is: (null)
[   26.955425] asus_wmi: Asus Management GUID not found
[   26.956933] asus_wmi: Management GUID not found
[   26.959316] asus_wmi: Management GUID not found
[   26.960904] msi_laptop: Brightness ignored, must be controlled by ACPI v=
ideo driver
[   26.964153] compal_laptop: Motherboard not recognized (You could try the=
 module's force-parameter)
[   26.967176] dell_wmi: No known WMI GUID found
[   26.968525] dell_wmi_aio: No known WMI GUID found
[   26.970053] acer_wmi: Acer Laptop ACPI-WMI Extras
[   26.971527] acer_wmi: No or unsupported WMI interface, unable to load
[   26.973469] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   26.975245] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Boch=
s, please report, aborting!
[   26.978236] hdaps: supported laptop not found!
[   26.979560] hdaps: driver init failed (ret=3D-19)!
[   26.982111] fujitsu_laptop: driver 0.6.0 successfully loaded
[   26.993313] msi_wmi: This machine doesn't have neither MSI-hotkeys nor b=
acklight through WMI
[   26.996608] intel_oaktrail: Platform not recognized (You could try the m=
odule's force-parameter)
[   26.998878] hv_utils: Registering HyperV Utility Driver
[   27.000934] hv_vmbus: registering driver hv_util
[   27.032834] vhci_hcd: changed 0
[   27.040995] no UART detected at 0x1
[   27.043070] MTVAP port 0x378 is busy
[   27.044453] snd_mtpav: probe of snd_mtpav failed with error -16
[   27.046691] snd_mts64: probe of snd_mts64.0 failed with error -5
[   27.049307] snd_portman2x4: probe of snd_portman2x4.0 failed with error =
-5
[   27.051690] Error: Driver 'pcspkr' is already registered, aborting...
[   27.059910] ASIHPI driver 4.10.01
[   27.068368] usbcore: registered new interface driver snd-usb-audio
[   27.070339] usbcore: registered new interface driver snd-ua101
[   27.072252] usbcore: registered new interface driver snd-usb-usx2y
[   27.074307] usbcore: registered new interface driver snd-usb-us122l
[   27.076262] usbcore: registered new interface driver snd-usb-caiaq
[   27.078244] usbcore: registered new interface driver snd-usb-6fire
[   27.080477] oprofile: using NMI interrupt.
[   27.082312] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[   27.086242] drop_monitor: Initializing network drop monitor service
[   27.088859] NET: Registered protocol family 26
[   27.090281] GACT probability on
[   27.091476] Mirror/redirect action on
[   27.092697] Simple TC action Loaded
[   27.095013] netem: version 1.3
[   27.096365] u32 classifier
[   27.097313]     Performance counters on
[   27.098695]     input device check on
[   27.099832]     Actions configured
[   27.101362] Netfilter messages via NETLINK v0.30.
[   27.103187] nf_conntrack version 0.5.0 (3406 buckets, 13624 max)
[   27.106374] ctnetlink v0.93: registering with nfnetlink.
[   27.108529] NF_TPROXY: Transparent proxy support initialized, version 4.=
1.0
[   27.110404] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   27.113271] xt_time: kernel timezone is -0000
[   27.114841] ip_set: protocol 6
[   27.115964] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   27.124774] IPVS: Connection hash table configured (size=3D4096, memory=
=3D64Kbytes)
[   27.127646] IPVS: Creating netns size=3D3096 id=3D0
[   27.129359] IPVS: ipvs loaded.
[   27.130510] IPVS: [rr] scheduler registered.
[   27.131895] IPVS: [wrr] scheduler registered.
[   27.135441] IPVS: [lc] scheduler registered.
[   27.136836] IPVS: [wlc] scheduler registered.
[   27.138283] IPVS: [lblc] scheduler registered.
[   27.142856] IPVS: [lblcr] scheduler registered.
[   27.144237] IPVS: [dh] scheduler registered.
[   27.145478] IPVS: [sh] scheduler registered.
[   27.146709] IPVS: [sed] scheduler registered.
[   27.147978] IPVS: [nq] scheduler registered.
[   27.152434] IPVS: [sip] pe registered.
[   27.153655] ipip: IPv4 over IPv4 tunneling driver
[   27.159138] gre: GRE over IPv4 demultiplexor driver
[   27.160693] ip_gre: GRE over IPv4 tunneling driver
[   27.168828] ip_tables: (C) 2000-2006 Netfilter Core Team
[   27.171004] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   27.172951] arp_tables: (C) 2002 David S. Miller
[   27.174474] TCP: bic registered
[   27.178728] TCP: cubic registered
[   27.179873] TCP: westwood registered
[   27.181120] TCP: highspeed registered
[   27.182332] TCP: hybla registered
[   27.183457] TCP: htcp registered
[   27.188691] TCP: vegas registered
[   27.189765] TCP: veno registered
[   27.190886] TCP: scalable registered
[   27.192110] TCP: lp registered
[   27.193149] TCP: yeah registered
[   27.206881] TCP: illinois registered
[   27.207991] Initializing XFRM netlink socket
[   27.210371] NET: Registered protocol family 10
[   27.218792] mip6: Mobile IPv6
[   27.220089] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   27.222203] sit: IPv6 over IPv4 tunneling driver
[   27.225717] NET: Registered protocol family 17
[   27.227275] NET: Registered protocol family 15
[   27.229083] Bridge firewalling registered
[   27.230317] Ebtables v2.0 registered
[   27.232056] NET: Registered protocol family 4
[   27.233560] NET: Registered protocol family 5
[   27.238382] NET: Registered protocol family 6
[   27.247082] NET: Registered protocol family 11
[   27.249065] NET: Registered protocol family 3
[   27.250480] can: controller area network core (rev 20120528 abi 9)
[   27.252703] NET: Registered protocol family 29
[   27.254083] can: raw protocol (rev 20120528)
[   27.255413] can: broadcast manager protocol (rev 20120528 t)
[   27.257090] can: netlink gateway (rev 20130117) max_hops=3D1
[   27.260699] IrCOMM protocol (Dag Brattli)
[   27.273937] Bluetooth: Can't register RFCOMM TTY driver
[   27.279668] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
[   27.281372] Bluetooth: BNEP filters: protocol multicast
[   27.283057] Bluetooth: BNEP socket layer initialized
[   27.287680] Bluetooth: CMTP (CAPI Emulation) ver 1.0
[   27.289330] Bluetooth: CMTP socket layer initialized
[   27.290832] Bluetooth: HIDP (Human Interface Emulation) ver 1.2
[   27.292737] Bluetooth: HIDP socket layer initialized
[   27.294844] RPC: Registered rdma transport module.
[   27.297041] NET: Registered protocol family 33
[   27.298463] Key type rxrpc registered
[   27.299665] Key type rxrpc_s registered
[   27.320809] RxRPC: Registered security type 2 'rxkad'
[   27.322531] lec:lane_module_init: lec.c: initialized
[   27.324076] mpoa:atm_mpoa_init: mpc.c: initialized
[   27.325627] l2tp_core: L2TP core driver, V2.0
[   27.327060] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   27.328546] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   27.333502] l2tp_netlink: L2TP netlink interface
[   27.335032] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   27.336810] l2tp_debugfs: L2TP debugfs support
[   27.338115] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   27.343686] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   27.347087] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   27.349036] NET: Registered protocol family 12
[   27.350659] NET: Registered protocol family 35
[   27.352598] 8021q: 802.1Q VLAN Support v1.8
[   27.356439] DCCP: Activated CCID 2 (TCP-like)
[   27.358111] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   27.388278] DCCP watch registered (port=3D0)
[   27.390747] sctp: Hash tables configured (established 1638 bind 1638)
[   27.443051] sctp_probe: probe registered (port=3D0)
[   27.451145] NET: Registered protocol family 21
[   27.452854] Registered RDS/iwarp transport
[   27.456759] Registered RDS/infiniband transport
[   27.465102] Registered RDS/tcp transport
[   27.466946] lib80211: common routines for IEEE802.11 drivers
[   27.468554] lib80211_crypt: registered algorithm 'NULL'
[   27.472447] lib80211_crypt: registered algorithm 'WEP'
[   27.474433] lib80211_crypt: registered algorithm 'CCMP'
[   27.478206] lib80211_crypt: registered algorithm 'TKIP'
[   27.481964] tipc: Activated (version 2.0.0)
[   27.490608] NET: Registered protocol family 30
[   27.491970] tipc: Started in single node mode
[   27.496141] 9pnet: Installing 9P2000 support
[   27.498038] NET: Registered protocol family 36
[   27.501828] Key type dns_resolver registered
[   27.503321] Key type ceph registered
[   27.507156] libceph: loaded (mon/osd proto 15/24)
[   27.515409] ------------[ cut here ]------------
[   27.518917] WARNING: at /c/kernel-tests/src/stable/net/batman-adv/hard-i=
nterface.c:92 batadv_is_on_batman_iface+0x5c/0x7a()
[   27.521935] Hardware name: Bochs
[   27.525356] Cannot find parent device
[   27.528296] Modules linked in:
[   27.529923] Pid: 1, comm: swapper/0 Not tainted 3.9.0-rc4-00896-g03ba910=
 #794
[   27.531747] Call Trace:
[   27.534683]  [<ffffffff81098ab4>] warn_slowpath_common+0x83/0x9e
[   27.536338]  [<ffffffff81098b72>] warn_slowpath_fmt+0x46/0x48
[   27.537872]  [<ffffffff828e6402>] ? rcu_read_unlock+0x1c/0x2d
[   27.539441]  [<ffffffff810ca498>] ? local_clock+0x19/0x52
[   27.541023]  [<ffffffff82c0e796>] batadv_is_on_batman_iface+0x5c/0x7a
[   27.542803]  [<ffffffff82c0efe2>] batadv_hard_if_event+0x8f/0x285
[   27.544551]  [<ffffffff828e4ff0>] register_netdevice_notifier+0x71/0x17e
[   27.550617]  [<ffffffff8420a030>] ? batadv_iv_init+0x3f/0x3f
[   27.552248]  [<ffffffff8420a114>] batadv_init+0xe4/0x104
[   27.553770]  [<ffffffff810020be>] do_one_initcall+0x7f/0x13d
[   27.555386]  [<ffffffff84177eb0>] kernel_init_freeable+0x141/0x1d0
[   27.557177]  [<ffffffff84177734>] ? do_early_param+0x8c/0x8c
[   27.558813]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
[   27.560348]  [<ffffffff82c1f154>] kernel_init+0xe/0xdb
[   27.561813]  [<ffffffff82c694ac>] ret_from_fork+0x7c/0xb0
[   27.563356]  [<ffffffff82c1f146>] ? rest_init+0xda/0xda
[   27.564974] ---[ end trace f78f9f0651ffcb0b ]---
[   27.566477] batman_adv: B.A.T.M.A.N. advanced 2013.1.0 (compatibility ve=
rsion 14) loaded
[   27.572975]=20
[   27.572975] printing PIC contents
[   27.574682] ... PIC  IMR: ffff
[   27.575652] ... PIC  IRR: 9153
[   27.576696] ... PIC  ISR: 0000
[   27.577660] ... PIC ELCR: 0c00
[   27.578632] printing local APIC contents on CPU#0/0:
[   27.580021] ... APIC ID:      00000000 (0)
[   27.580673] ... APIC VERSION: 00050014
[   27.580673] ... APIC TASKPRI: 00000000 (00)
[   27.580673] ... APIC PROCPRI: 00000000
[   27.580673] ... APIC LDR: 01000000
[   27.580673] ... APIC DFR: ffffffff
[   27.580673] ... APIC SPIV: 000001ff
[   27.580673] ... APIC ISR field:
[   27.580673] 000000000000000000000000000000000000000000000000000000000000=
0000
[   27.580673] ... APIC TMR field:
[   27.580673] 000000000000000000000000000000000000000000000000000000000000=
0000
[   27.580673] ... APIC IRR field:
[   27.580673] 000000000000000000000000000000000000000000000000000000000000=
8000
[   27.580673] ... APIC ESR: 00000000
[   27.580673] ... APIC ICR: 000008fd
[   27.580673] ... APIC ICR2: 02000000
[   27.580673] ... APIC LVTT: 000000ef
[   27.580673] ... APIC LVTPC: 00010000
[   27.580673] ... APIC LVT0: 00010700
[   27.580673] ... APIC LVT1: 00000400
[   27.580673] ... APIC LVTERR: 000000fe
[   27.580673] ... APIC TMICT: 000329c6
[   27.580673] ... APIC TMCCT: 00000000
[   27.580673] ... APIC TDCR: 00000003
[   27.580673]=20
[   27.611693] number of MP IRQ sources: 15.
[   27.612784] number of IO-APIC #2 registers: 24.
[   27.613920] testing the IO APIC.......................
[   27.615299] IO APIC #2......
[   27.616273] .... register #00: 00000000
[   27.617297] .......    : physical APIC id: 00
[   27.618410] .......    : Delivery Type: 0
[   27.619463] .......    : LTS          : 0
[   27.620576] .... register #01: 00170011
[   27.621610] .......     : max redirection entries: 17
[   27.622854] .......     : PRQ implemented: 0
[   27.623959] .......     : IO APIC version: 11
[   27.625181] .... register #02: 00000000
[   27.626195] .......     : arbitration: 00
[   27.627237] .... IRQ redirection table:
[   27.628318] 1    0    0   0   0    0    0    00
[   27.629484] 0    0    0   0   0    1    1    31
[   27.630641] 0    0    0   0   0    1    1    30
[   27.631925] 0    0    0   0   0    1    1    33
[   27.633371] 1    0    0   0   0    1    1    34
[   27.634751] 1    1    0   0   0    1    1    35
[   27.636218] 0    0    0   0   0    1    1    36
[   27.637531] 0    0    0   0   0    1    1    37
[   27.638864] 0    0    0   0   0    1    1    38
[   27.640275] 0    1    0   0   0    1    1    39
[   27.641642] 1    1    0   0   0    1    1    3A
[   27.643025] 1    1    0   0   0    1    1    3B
[   27.644446] 0    0    0   0   0    1    1    3C
[   27.645870] 0    0    0   0   0    1    1    3D
[   27.647227] 0    0    0   0   0    1    1    3E
[   27.648598] 0    0    0   0   0    1    1    3F
[   27.649943] 1    0    0   0   0    0    0    00
[   27.651323] 1    0    0   0   0    0    0    00
[   27.652781] 1    0    0   0   0    0    0    00
[   27.654115] 1    0    0   0   0    0    0    00
[   27.655484] 1    0    0   0   0    0    0    00
[   27.656878] 1    0    0   0   0    0    0    00
[   27.658165] 1    0    0   0   0    0    0    00
[   27.659444] 1    0    0   0   0    0    0    00
[   27.660775] IRQ to pin mappings:
[   27.661799] IRQ0 -> 0:2
[   27.662907] IRQ1 -> 0:1
[   27.664006] IRQ3 -> 0:3
[   27.665202] IRQ4 -> 0:4
[   27.666313] IRQ5 -> 0:5
[   27.667427] IRQ6 -> 0:6
[   27.668610] IRQ7 -> 0:7
[   27.669696] IRQ8 -> 0:8
[   27.670802] IRQ9 -> 0:9
[   27.671904] IRQ10 -> 0:10
[   27.684624] IRQ11 -> 0:11
[   27.685810] IRQ12 -> 0:12
[   27.686984] IRQ13 -> 0:13
[   27.688272] IRQ14 -> 0:14
[   27.689523] IRQ15 -> 0:15
[   27.690802] .................................... done.
[   27.700915] PM: Hibernation image not present or could not be loaded.
[   27.702941] registered taskstats version 1
[   27.704335] Running tests on trace events:
[   27.708755] Testing event 9p_client_req: OK
[   27.733759] Testing event 9p_client_res: OK
[   27.755728] Testing event 9p_protocol_dump: OK
[   27.778062] Testing event drv_return_void: OK
[   27.799802] Testing event drv_return_int: OK
[   27.823803] Testing event drv_return_bool: OK
[   27.848862] Testing event drv_return_u64: OK
[   27.869761] Testing event drv_start: OK
[   27.893773] Testing event drv_get_et_strings: OK
[   27.915718] Testing event drv_get_et_sset_count: OK
[   27.938737] Testing event drv_get_et_stats: OK
[   27.969869] Testing event drv_suspend: OK
[   27.989993] Testing event drv_resume: OK
[   28.009948] Testing event drv_set_wakeup: OK
[   28.037263] Testing event drv_stop: OK
[   28.056077] Testing event drv_add_interface: OK
[   28.073944] Testing event drv_change_interface: OK
[   28.100126] Testing event drv_remove_interface: OK
[   28.118940] Testing event drv_config: OK
[   28.145710] Testing event drv_bss_info_changed: OK
[   28.173704] Testing event drv_prepare_multicast: OK
[   28.199684] Testing event drv_configure_filter: OK
[   28.221768] Testing event drv_set_tim: OK
[   28.237231] Testing event drv_set_key: OK
[   28.253497] Testing event drv_update_tkip_key: OK
[   28.269832] Testing event drv_hw_scan: OK
[   28.292066] Testing event drv_cancel_hw_scan: OK
[   28.310107] Testing event drv_sched_scan_start: OK
[   28.330214] Testing event drv_sched_scan_stop: OK
[   28.355082] Testing event drv_sw_scan_start: OK
[   28.379080] Testing event drv_sw_scan_complete: OK
[   28.398736] Testing event drv_get_stats: OK
[   28.427917] Testing event drv_get_tkip_seq: OK
[   28.459486] Testing event drv_set_frag_threshold: OK
[   28.483527] Testing event drv_set_rts_threshold: OK
[   28.505684] Testing event drv_set_coverage_class: OK
[   28.525330] Testing event drv_sta_notify: OK
[   28.545775] Testing event drv_sta_state: OK
[   28.565613] Testing event drv_sta_rc_update: OK
[   28.587581] Testing event drv_sta_add: OK
[   28.605554] Testing event drv_sta_remove: OK
[   28.630905] Testing event drv_conf_tx: OK
[   28.650350] Testing event drv_get_tsf: OK
[   28.670817] Testing event drv_set_tsf: OK
[   28.689732] Testing event drv_reset_tsf: OK
[   28.711541] Testing event drv_tx_last_beacon: OK
[   28.731685] Testing event drv_ampdu_action: OK
[   28.755710] Testing event drv_get_survey: OK
[   28.780924] Testing event drv_flush: OK
[   28.806716] Testing event drv_channel_switch: OK
[   28.825821] Testing event drv_set_antenna: OK
[   28.845724] Testing event drv_get_antenna: OK
[   28.870931] Testing event drv_remain_on_channel: OK
[   28.889258] Testing event drv_cancel_remain_on_channel: OK
[   28.915896] Testing event drv_set_ringparam: OK
[   28.937496] Testing event drv_get_ringparam: OK
[   28.953359] Testing event drv_tx_frames_pending: OK
[   28.969366] Testing event drv_offchannel_tx_cancel_wait: OK
[   28.994801] Testing event drv_set_bitrate_mask: OK
[   29.013318] Testing event drv_set_rekey_data: OK
[   29.033350] Testing event drv_rssi_callback: OK
[   29.054728] Testing event drv_release_buffered_frames: OK
[   29.073323] Testing event drv_allow_buffered_frames: OK
[   29.091039] Testing event drv_get_rssi: OK
[   29.109396] Testing event drv_mgd_prepare_tx: OK
[   29.125438] Testing event drv_add_chanctx: OK
[   29.145804] Testing event drv_remove_chanctx: OK
[   29.161870] Testing event drv_change_chanctx: OK
[   29.178845] Testing event drv_assign_vif_chanctx: OK
[   29.197942] Testing event drv_unassign_vif_chanctx: OK
[   29.218820] Testing event drv_start_ap: OK
[   29.238645] Testing event drv_stop_ap: OK
[   29.261333] Testing event drv_restart_complete: OK
[   29.278098] Testing event drv_ipv6_addr_change: OK
[   29.297210] Testing event api_start_tx_ba_session: OK
[   29.313279] Testing event api_start_tx_ba_cb: OK
[   29.334345] Testing event api_stop_tx_ba_session: OK
[   29.353872] Testing event api_stop_tx_ba_cb: OK
[   29.377391] Testing event api_restart_hw: OK
[   29.393674] Testing event api_beacon_loss: OK
[   29.409483] Testing event api_connection_loss: OK
[   29.435799] Testing event api_cqm_rssi_notify: OK
[   29.458066] Testing event api_scan_completed: OK
[   29.478651] Testing event api_sched_scan_results: OK
[   29.500743] Testing event api_sched_scan_stopped: OK
[   29.525766] Testing event api_sta_block_awake: OK
[   29.541810] Testing event api_chswitch_done: OK
[   29.565217] Testing event api_ready_on_channel: OK
[   29.581474] Testing event api_remain_on_channel_expired: OK
[   29.598793] Testing event api_gtk_rekey_notify: OK
[   29.621913] Testing event api_enable_rssi_reports: OK
[   29.651161] Testing event api_eosp: OK
[   29.671401] Testing event wake_queue: OK
[   29.697573] Testing event stop_queue: OK
[   29.719930] Testing event drv_set_default_unicast_key: OK
[   29.738839] Testing event api_radar_detected: OK
[   29.759880] Testing event rdev_suspend: OK
[   29.795932] Testing event rdev_return_int: OK
[   29.823858] Testing event rdev_scan: OK
[   29.845922] Testing event rdev_resume: OK
[   29.869889] Testing event rdev_return_void: OK
[   29.888204] Testing event rdev_get_ringparam: OK
[   29.905403] Testing event rdev_get_antenna: OK
[   29.923815] Testing event rdev_rfkill_poll: OK
[   29.941885] Testing event rdev_set_wakeup: OK
[   29.957701] Testing event rdev_add_virtual_intf: OK
[   29.973277] Testing event rdev_return_wdev: OK
[   29.993195] Testing event rdev_del_virtual_intf: OK
[   30.013371] Testing event rdev_change_virtual_intf: OK
[   30.034304] Testing event rdev_add_key: OK
[   30.059628] Testing event rdev_get_key: OK
[   30.083599] Testing event rdev_del_key: OK
[   30.105969] Testing event rdev_set_default_key: OK
[   30.123879] Testing event rdev_set_default_mgmt_key: OK
[   30.143017] Testing event rdev_start_ap: OK
[   30.161275] Testing event rdev_change_beacon: OK
[   30.183561] Testing event rdev_stop_ap: OK
[   30.210289] Testing event rdev_get_et_stats: OK
[   30.230626] Testing event rdev_sched_scan_stop: OK
[   30.253913] Testing event rdev_set_rekey_data: OK
[   30.274065] Testing event rdev_get_mesh_config: OK
[   30.293995] Testing event rdev_leave_mesh: OK
[   30.313770] Testing event rdev_leave_ibss: OK
[   30.334216] Testing event rdev_flush_pmksa: OK
[   30.355515] Testing event rdev_add_station: OK
[   30.376901] Testing event rdev_change_station: OK
[   30.402581] Testing event rdev_del_station: OK
[   30.428526] Testing event rdev_get_station: OK
[   30.446535] Testing event rdev_del_mpath: OK
[   30.467613] Testing event rdev_set_wds_peer: OK
[   30.496217] Testing event rdev_dump_station: OK
[   30.513925] Testing event rdev_return_int_station_info: OK
[   30.533713] Testing event rdev_add_mpath: OK
[   30.553881] Testing event rdev_change_mpath: OK
[   30.569578] Testing event rdev_get_mpath: OK
[   30.585948] Testing event rdev_dump_mpath: OK
[   30.606190] Testing event rdev_return_int_mpath_info: OK
[   30.625351] Testing event rdev_return_int_mesh_config: OK
[   30.643660] Testing event rdev_update_mesh_config: OK
[   30.665577] Testing event rdev_join_mesh: OK
[   30.688746] Testing event rdev_change_bss: OK
[   30.712688] Testing event rdev_set_txq_params: OK
[   30.733619] Testing event rdev_libertas_set_mesh_channel:=20
--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="03ba9107c92bdc2eec1d14ea19d5a00209969d87-bisect.log"

bisect: skip c4052ba9dad9cc86cb3a1f0f8cb032514fa414be: not a good merge base
git checkout v3.8
Previous HEAD position was 03ba910... Merge remote-tracking branch 'net-next/master' into devel-inn-x86_64-2013-03-27-06-54
HEAD is now at 19f949f... Linux 3.8

2013-03-29-10:31:25 19f949f52599ba7c3f67a5897ac6be14bfcb1200 compiling
/home/wfg/mm

2013-03-29-10:39:30 detecting boot state 3.8.0-bisect3 #126 	5	6..............................................................................................................................................................	10 SUCCESS
bisect: good commit v3.8
git bisect start 03ba9107c92bdc2eec1d14ea19d5a00209969d87 v3.8 --
Previous HEAD position was 19f949f... Linux 3.8
HEAD is now at 3c0eee3... Linux 2.6.37
Bisecting: 6461 revisions left to test after this (roughly 13 steps)
[cb715a836642e0ec69350670d1c2f800f3e2d2e4] Merge branch 'x86-cpu-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip
git bisect run /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-29-12:01:09 cb715a836642e0ec69350670d1c2f800f3e2d2e4 compiling
/home/wfg/mm

2013-03-29-12:09:16 detecting boot state 3.8.0-bisect3-06275-gcb715a8 #127 ..............................................................................................................................................	5	10...............................................................................................................................................................	15 SUCCESS
Bisecting: 3251 revisions left to test after this (roughly 12 steps)
[b67bfe0d42cac56c512dd5da4b1b347a23f4b70a] hlist: drop the node parameter from iterators
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-29-14:42:10 b67bfe0d42cac56c512dd5da4b1b347a23f4b70a compiling
/home/wfg/mm

2013-03-29-14:57:49 detecting boot state 3.8.0-bisect3-03098-gb67bfe0 #128 ...............................................................................................................................	4	8	10...............................................................................................................................................................	15 SUCCESS
Bisecting: 1625 revisions left to test after this (roughly 11 steps)
[59d8e5eb2bd5593d8220db0e25206cdfc42e83ea] Merge branch 'akpm' (fixes from Andrew)
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-29-17:23:39 59d8e5eb2bd5593d8220db0e25206cdfc42e83ea compiling
/home/wfg/mm

2013-03-29-17:36:08 detecting boot state 3.9.0-rc1-bisect3-00239-g59d8e5e #129 ......................................................................................................................................	4	10...............................................................................................................................................................	14 SUCCESS
Bisecting: 787 revisions left to test after this (roughly 10 steps)
[71420228feb826b365b3fef4de01e83c00e9151d] Merge remote-tracking branch 'origin/drm-intel-fixes' into drm-intel-nightly
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-29-20:04:57 71420228feb826b365b3fef4de01e83c00e9151d compiling
/home/wfg/mm

2013-03-29-20:16:26 detecting boot state 3.9.0-rc4-bisect3-00108-g7142022 #130 ........................................................................................................................................	4	8	10...............................................................................................................................................................	15 SUCCESS
Bisecting: 285 revisions left to test after this (roughly 9 steps)
[5470b462c3f0c6fa980c320968a165bd0f34ca8d] Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next into for-davem
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-29-22:46:46 5470b462c3f0c6fa980c320968a165bd0f34ca8d compiling
/home/wfg/mm

2013-03-29-22:57:12 detecting boot state 3.9.0-rc3-bisect3-00642-g5470b46 #131 ..........................................................................................................................................	4	7	10	14 SUCCESS
Bisecting: 142 revisions left to test after this (roughly 7 steps)
[38502af77e07b5d6650b9ff99a0b482d86366592] tuntap: set transport header before passing it to kernel
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-00:08:51 38502af77e07b5d6650b9ff99a0b482d86366592 compiling
/home/wfg/mm

2013-03-30-00:15:41 detecting boot state 3.9.0-rc3-bisect3-00785-g38502af #132 	4 TEST FAILURE
Bisecting: 71 revisions left to test after this (roughly 6 steps)
[0465277f6b3fd0535428ae935644ac30ce903de0] ipv4: provide addr and netconf dump consistency info
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-00:16:42 0465277f6b3fd0535428ae935644ac30ce903de0 compiling
/home/wfg/mm

2013-03-30-00:22:29 detecting boot state 3.9.0-rc3-bisect3-00713-g0465277 #133 	3	8....	9.........................................................................................................................................................	10	13	17	18... SUCCESS
Bisecting: 35 revisions left to test after this (roughly 5 steps)
[21168245031062212c0b805d0bd466ee6dd4a16f] dsa: factor freeing of dsa_platform_data
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-01:46:43 21168245031062212c0b805d0bd466ee6dd4a16f compiling
/home/wfg/mm

2013-03-30-01:55:27 detecting boot state 3.9.0-rc3-bisect3-00749-g2116824 #134 ........................................................................................................................................	2	5	9....	10..........................................................................................................................................................	12	15	19... SUCCESS
Bisecting: 17 revisions left to test after this (roughly 4 steps)
[cb6bf35502d53364d15737295bc64f804c4587ce] firewire net, ipv6: IPv6 over Firewire (RFC3146) support.
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-04:28:15 cb6bf35502d53364d15737295bc64f804c4587ce compiling
/home/wfg/mm

2013-03-30-04:35:57 detecting boot state 3.9.0-rc3-bisect3-00767-gcb6bf35 #135 ...........................................................................................................................................	1	3	5 TEST FAILURE
Bisecting: 8 revisions left to test after this (roughly 3 steps)
[206aaafcd279e2cb836d772282517540c6cb3814] VXLAN: Use IP Tunnels tunnel ENC encap API
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-05:47:35 206aaafcd279e2cb836d772282517540c6cb3814 compiling
/home/wfg/mm

2013-03-30-05:54:06 detecting boot state 3.9.0-rc3-bisect3-00758-g206aaaf #136 	1	7 TEST FAILURE
Bisecting: 4 revisions left to test after this (roughly 2 steps)
[25c7704d8bdcf6746dab4397953df51759924b37] ipv4: Fix ip-header identification for gso packets.
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-05:55:37 25c7704d8bdcf6746dab4397953df51759924b37 compiling
/home/wfg/mm

2013-03-30-05:59:41 detecting boot state 3.9.0-rc3-bisect3-00753-g25c7704 #137 	5	7...............................................................................................................................................................	10	15 SUCCESS
Bisecting: 2 revisions left to test after this (roughly 1 step)
[c54419321455631079c7d6e60bc732dd0c5914c5] GRE: Refactor GRE tunneling code.
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-07:21:52 c54419321455631079c7d6e60bc732dd0c5914c5 compiling
/home/wfg/mm

2013-03-30-07:29:39 detecting boot state 3.9.0-rc3-bisect3-00755-gc544193 #138 ...............................................................................................................................................	4	9 TEST FAILURE
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[eaac5f3d3ad33547b299935e6db0cfc7be9a576a] net: Print functions in /proc/net/ptype without the offset.
running /c/kernel-tests/bisect-test-boot-failure.sh obj-bisect-x86_64

2013-03-30-08:42:48 eaac5f3d3ad33547b299935e6db0cfc7be9a576a compiling
/home/wfg/mm

2013-03-30-08:49:22 detecting boot state 3.9.0-rc3-bisect3-00754-geaac5f3 #139 	3	7	8..............................................................................................................................................................	12	14 SUCCESS
c54419321455631079c7d6e60bc732dd0c5914c5 is the first bad commit
commit c54419321455631079c7d6e60bc732dd0c5914c5
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Mon Mar 25 14:49:35 2013 +0000

    GRE: Refactor GRE tunneling code.
    
    Following patch refactors GRE code into ip tunneling code and GRE
    specific code. Common tunneling code is moved to ip_tunnel module.
    ip_tunnel module is written as generic library which can be used
    by different tunneling implementations.
    
    ip_tunnel module contains following components:
     - packet xmit and rcv generic code. xmit flow looks like
       (gre_xmit/ipip_xmit)->ip_tunnel_xmit->ip_local_out.
     - hash table of all devices.
     - lookup for tunnel devices.
     - control plane operations like device create, destroy, ioctl, netlink
       operations code.
     - registration for tunneling modules, like gre, ipip etc.
     - define single pcpu_tstats dev->tstats.
     - struct tnl_ptk_info added to pass parsed tunnel packet parameters.
    
    ipip.h header is renamed to ip_tunnel.h
    
    Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 4f10e7662cf0302f48c7c5c6fd97a83a6c67c9c1 f9a6476615af01f366a2fc5d4cfb4abe0ddf0ba4 M	drivers
:040000 040000 06ccd7a9157d5ae3537cb142e58de969ef56079e 6f1103dd9b7d074783954a2947301f2d88b19abe M	include
:040000 040000 4509ab4bb7ba1dcd51e9838c0cb8b1a60306e29d ec0d7bf4fe69fcd538ea6e7d9934cfd2c6da9747 M	net
bisect run success

2013-03-30-10:11:34 eaac5f3d3ad33547b299935e6db0cfc7be9a576a compiling
/home/wfg/mm

2013-03-30-10:13:43 detecting boot state 3.9.0-rc3-bisect3-00754-geaac5f3 #139 ..........................................................................................................................................................	4	6	10...............................................................................................................................................................	14	17	20..............................................................................................................................................................	24	26 SUCCESS

2013-03-30-14:14:11 03ba9107c92bdc2eec1d14ea19d5a00209969d87 compiling
/home/wfg/mm

2013-03-30-14:24:02 detecting boot state 3.9.0-rc4-bisect3-00896-g03ba910 #140 ..........................................................................................................................................	4 TEST FAILURE
ERROR# 1: /c/kernel-tests/bisect:58: main: $BISECT_TEST $KBUILD_OUTPUT
[detached HEAD 204a74e] Revert "GRE: Refactor GRE tunneling code."
 18 files changed, 1301 insertions(+), 1612 deletions(-)
 rewrite include/net/gre.h (71%)
 delete mode 100644 include/net/ip_tunnels.h
 create mode 100644 include/net/ipip.h
 delete mode 100644 net/ipv4/ip_tunnel.c

2013-03-30-15:34:11 204a74e72d7c3fffafcb78f52e6dd6d5787e5d2f compiling
2013-03-30-15:36:32 204a74e72d7c3fffafcb78f52e6dd6d5787e5d2f SKIP BROKEN BUILD
LANG=C MAKE=/usr/bin/make --keep-going /usr/bin/make -C source O=/cc/wfg/mm-bisect3-x86_64 -j64 -l129 ARCH=x86_64 distclean
make: Entering directory `/c/wfg/mm'
  CLEAN   .
  CLEAN   arch/x86/realmode/rm
  CLEAN   arch/x86/vdso
  CLEAN   arch/x86/kernel/cpu
  CLEAN   arch/x86/lib
  CLEAN   arch/x86/kernel
  CLEAN   crypto/asymmetric_keys
  CLEAN   drivers/gpu/drm/radeon
  CLEAN   firmware
  CLEAN   drivers/net/wan
  CLEAN   drivers/scsi/aic7xxx
  CLEAN   drivers/tty/vt
  CLEAN   lib/raid6
  CLEAN   kernel/debug/kdb
  CLEAN   security/apparmor
  CLEAN   drivers/video/logo
  CLEAN   security/selinux
  CLEAN   sound/oss
  CLEAN   usr
  CLEAN   kernel
  CLEAN   Documentation/accounting
  CLEAN   Documentation/auxdisplay
  CLEAN   Documentation/connector
  CLEAN   Documentation/filesystems
  CLEAN   Documentation/laptops
  CLEAN   Documentation/pcmcia
  CLEAN   Documentation/ia64
  CLEAN   Documentation/spi
  CLEAN   Documentation/timers
  CLEAN   Documentation/misc-devices/mei
  CLEAN   Documentation/watchdog/src
  CLEAN   Documentation/networking/timestamping
  CLEAN   Documentation/networking
  CLEAN   lib
  CLEAN   scripts/basic
  CLEAN   scripts/genksyms
  CLEAN   scripts/mod
  CLEAN   scripts/kconfig
  CLEAN   scripts/selinux/genheaders
  CLEAN   scripts/selinux/mdp
  CLEAN   arch/x86/boot/compressed
  CLEAN   scripts
  CLEAN   arch/x86/boot
  CLEAN   arch/x86/tools
  CLEAN   .tmp_versions
  CLEAN   include/config usr/include include/generated arch/x86/include/generated
  CLEAN   .config .config.old .version include/generated/uapi/linux/version.h Module.symvers signing_key.priv signing_key.x509 x509.genkey extra_certificates
make: Leaving directory `/c/wfg/mm'
ERROR# 125: /c/kernel-tests/bisect:61: main: $BISECT_TEST $KBUILD_OUTPUT

========= linux-next =========
Fetching next

2013-03-30-15:40:23 da17d7bda957ae4697b6abc0793f74fb9b50b58f compiling
2013-03-30-15:44:13 da17d7bda957ae4697b6abc0793f74fb9b50b58f SKIP BROKEN BUILD
LANG=C MAKE=/usr/bin/make --keep-going /usr/bin/make -C source O=/cc/wfg/mm-bisect3-x86_64 -j64 -l128 ARCH=x86_64 distclean
make: Entering directory `/c/wfg/mm'
  CLEAN   .
  CLEAN   arch/x86/vdso
  CLEAN   arch/x86/realmode/rm
  CLEAN   arch/x86/kernel/cpu
  CLEAN   arch/x86/kernel
  CLEAN   arch/x86/lib
  CLEAN   drivers/gpu/drm/radeon
  CLEAN   drivers/net/wan
  CLEAN   drivers/scsi/aic7xxx
  CLEAN   drivers/tty/vt
  CLEAN   kernel
  CLEAN   lib/raid6
  CLEAN   lib
  CLEAN   security/selinux
  CLEAN   security/apparmor
  CLEAN   usr
  CLEAN   arch/x86/tools
  CLEAN   scripts/basic
  CLEAN   scripts/mod
  CLEAN   scripts/kconfig
  CLEAN   scripts/selinux/genheaders
  CLEAN   scripts/selinux/mdp
  CLEAN   scripts/genksyms
  CLEAN   scripts
  CLEAN   .tmp_versions
  CLEAN   include/config include/generated arch/x86/include/generated
  CLEAN   .config .config.old .version include/generated/uapi/linux/version.h
make: Leaving directory `/c/wfg/mm'
ERROR# 125: /c/kernel-tests/bisect:72: main: $BISECT_TEST $KBUILD_OUTPUT

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.9.0-rc4 Kernel Configuration
#
CONFIG_64BIT=y
CONFIG_X86_64=y
CONFIG_X86=y
CONFIG_INSTRUCTION_DECODER=y
CONFIG_OUTPUT_FORMAT="elf64-x86-64"
CONFIG_ARCH_DEFCONFIG="arch/x86/configs/x86_64_defconfig"
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_STACKTRACE_SUPPORT=y
CONFIG_HAVE_LATENCYTOP_SUPPORT=y
CONFIG_MMU=y
CONFIG_NEED_DMA_MAP_STATE=y
CONFIG_NEED_SG_DMA_LENGTH=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_BUG=y
CONFIG_GENERIC_BUG_RELATIVE_POINTERS=y
CONFIG_GENERIC_HWEIGHT=y
CONFIG_GENERIC_GPIO=y
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
CONFIG_ZONE_DMA32=y
CONFIG_AUDIT_ARCH=y
CONFIG_ARCH_SUPPORTS_OPTIMIZED_INLINING=y
CONFIG_ARCH_SUPPORTS_DEBUG_PAGEALLOC=y
CONFIG_HAVE_INTEL_TXT=y
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
CONFIG_LOCALVERSION_AUTO=y
CONFIG_HAVE_KERNEL_GZIP=y
CONFIG_HAVE_KERNEL_BZIP2=y
CONFIG_HAVE_KERNEL_LZMA=y
CONFIG_HAVE_KERNEL_XZ=y
CONFIG_HAVE_KERNEL_LZO=y
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_SYSVIPC_SYSCTL=y
CONFIG_POSIX_MQUEUE=y
CONFIG_POSIX_MQUEUE_SYSCTL=y
CONFIG_FHANDLE=y
CONFIG_AUDIT=y
CONFIG_AUDITSYSCALL=y
CONFIG_AUDIT_WATCH=y
CONFIG_AUDIT_TREE=y
# CONFIG_AUDIT_LOGINUID_IMMUTABLE is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
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
CONFIG_ALWAYS_USE_PERSISTENT_CLOCK=y
CONFIG_GENERIC_TIME_VSYSCALL=y
CONFIG_GENERIC_CLOCKEVENTS=y
CONFIG_GENERIC_CLOCKEVENTS_BUILD=y
CONFIG_GENERIC_CLOCKEVENTS_BROADCAST=y
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
# CONFIG_VIRT_CPU_ACCOUNTING_GEN is not set
# CONFIG_IRQ_TIME_ACCOUNTING is not set
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y

#
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_STALL_COMMON=y
# CONFIG_RCU_USER_QS is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_RCU_NOCB_CPU is not set
CONFIG_IKCONFIG=y
# CONFIG_IKCONFIG_PROC is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
# CONFIG_NUMA_BALANCING is not set
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
# CONFIG_CGROUP_CPUACCT is not set
CONFIG_RESOURCE_COUNTERS=y
# CONFIG_MEMCG is not set
# CONFIG_CGROUP_HUGETLB is not set
# CONFIG_CGROUP_PERF is not set
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
# CONFIG_RT_GROUP_SCHED is not set
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
CONFIG_UTS_NS=y
CONFIG_IPC_NS=y
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_SCHED_AUTOGROUP=y
# CONFIG_SYSFS_DEPRECATED is not set
CONFIG_RELAY=y
CONFIG_BLK_DEV_INITRD=y
CONFIG_INITRAMFS_SOURCE=""
CONFIG_RD_GZIP=y
CONFIG_RD_BZIP2=y
CONFIG_RD_LZMA=y
CONFIG_RD_XZ=y
CONFIG_RD_LZO=y
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_HAVE_UID16=y
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_PCSPKR_PLATFORM=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SIGNALFD=y
CONFIG_TIMERFD=y
CONFIG_EVENTFD=y
CONFIG_SHMEM=y
CONFIG_AIO=y
# CONFIG_EMBEDDED is not set
CONFIG_HAVE_PERF_EVENTS=y

#
# Kernel Performance Events And Counters
#
CONFIG_PERF_EVENTS=y
# CONFIG_DEBUG_PERF_USE_VMALLOC is not set
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_PCI_QUIRKS=y
# CONFIG_COMPAT_BRK is not set
CONFIG_SLAB=y
# CONFIG_SLUB is not set
CONFIG_PROFILING=y
CONFIG_TRACEPOINTS=y
CONFIG_OPROFILE=y
# CONFIG_OPROFILE_EVENT_MULTIPLEX is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
CONFIG_KPROBES=y
# CONFIG_JUMP_LABEL is not set
CONFIG_OPTPROBES=y
CONFIG_KPROBES_ON_FTRACE=y
# CONFIG_HAVE_64BIT_ALIGNED_ACCESS is not set
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_ARCH_USE_BUILTIN_BSWAP=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
CONFIG_HAVE_KPROBES_ON_FTRACE=y
CONFIG_HAVE_ARCH_TRACEHOOK=y
CONFIG_HAVE_DMA_ATTRS=y
CONFIG_USE_GENERIC_SMP_HELPERS=y
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
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_RELA=y
CONFIG_OLD_SIGSUSPEND3=y
CONFIG_COMPAT_OLD_SIGACTION=y

#
# GCOV-based kernel profiling
#
# CONFIG_GCOV_KERNEL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_SLABINFO=y
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
CONFIG_MODULES=y
CONFIG_MODULE_FORCE_LOAD=y
CONFIG_MODULE_UNLOAD=y
CONFIG_MODULE_FORCE_UNLOAD=y
CONFIG_MODVERSIONS=y
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_MODULE_SIG is not set
CONFIG_STOP_MACHINE=y
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_BLK_DEV_THROTTLING is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
CONFIG_ACORN_PARTITION=y
# CONFIG_ACORN_PARTITION_CUMANA is not set
# CONFIG_ACORN_PARTITION_EESOX is not set
CONFIG_ACORN_PARTITION_ICS=y
# CONFIG_ACORN_PARTITION_ADFS is not set
# CONFIG_ACORN_PARTITION_POWERTEC is not set
CONFIG_ACORN_PARTITION_RISCIX=y
CONFIG_OSF_PARTITION=y
CONFIG_AMIGA_PARTITION=y
CONFIG_ATARI_PARTITION=y
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
CONFIG_SOLARIS_X86_PARTITION=y
CONFIG_UNIXWARE_DISKLABEL=y
CONFIG_LDM_PARTITION=y
# CONFIG_LDM_DEBUG is not set
CONFIG_SGI_PARTITION=y
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
CONFIG_EFI_PARTITION=y
# CONFIG_SYSV68_PARTITION is not set
CONFIG_BLOCK_COMPAT=y

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
CONFIG_IOSCHED_DEADLINE=y
CONFIG_IOSCHED_CFQ=y
CONFIG_CFQ_GROUP_IOSCHED=y
# CONFIG_DEFAULT_DEADLINE is not set
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_PREEMPT_NOTIFIERS=y
CONFIG_PADATA=y
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_X2APIC=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_KVM_GUEST=y
CONFIG_PARAVIRT=y
# CONFIG_PARAVIRT_SPINLOCKS is not set
CONFIG_PARAVIRT_CLOCK=y
# CONFIG_PARAVIRT_DEBUG is not set
CONFIG_NO_BOOTMEM=y
CONFIG_MEMTEST=y
# CONFIG_MK8 is not set
# CONFIG_MPSC is not set
# CONFIG_MCORE2 is not set
# CONFIG_MATOM is not set
CONFIG_GENERIC_CPU=y
CONFIG_X86_INTERNODE_CACHE_SHIFT=6
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_TSC=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_CMOV=y
CONFIG_X86_MINIMUM_CPU_FAMILY=64
CONFIG_X86_DEBUGCTLMSR=y
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_HPET_EMULATE_RTC=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
CONFIG_CALGARY_IOMMU=y
CONFIG_CALGARY_IOMMU_ENABLED_BY_DEFAULT=y
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
# CONFIG_MAXSMP is not set
CONFIG_NR_CPUS=512
CONFIG_SCHED_SMT=y
CONFIG_SCHED_MC=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
CONFIG_X86_MCE=y
CONFIG_X86_MCE_INTEL=y
CONFIG_X86_MCE_AMD=y
CONFIG_X86_MCE_THRESHOLD=y
CONFIG_X86_MCE_INJECT=y
CONFIG_X86_THERMAL_VECTOR=y
CONFIG_I8K=y
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
CONFIG_MICROCODE_AMD=y
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_EARLY=y
CONFIG_X86_MSR=y
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
CONFIG_DIRECT_GBPAGES=y
CONFIG_NUMA=y
CONFIG_AMD_NUMA=y
CONFIG_X86_64_ACPI_NUMA=y
CONFIG_NODES_SPAN_OTHER_NODES=y
CONFIG_NUMA_EMU=y
CONFIG_NODES_SHIFT=6
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ARCH_PROC_KCORE_TEXT=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_NEED_MULTIPLE_NODES=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
CONFIG_SPARSEMEM_VMEMMAP=y
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
CONFIG_MEMORY_ISOLATION=y
# CONFIG_MOVABLE_NODE is not set
CONFIG_HAVE_BOOTMEM_INFO_NODE=y
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_BALLOON_COMPACTION=y
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_NEED_BOUNCE_POOL=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
CONFIG_TRANSPARENT_HUGEPAGE=y
# CONFIG_TRANSPARENT_HUGEPAGE_ALWAYS is not set
CONFIG_TRANSPARENT_HUGEPAGE_MADVISE=y
CONFIG_CROSS_MEMORY_ATTACH=y
# CONFIG_CLEANCACHE is not set
# CONFIG_FRONTSWAP is not set
# CONFIG_X86_CHECK_BIOS_CORRUPTION is not set
CONFIG_X86_RESERVE_LOW=64
CONFIG_MTRR=y
CONFIG_MTRR_SANITIZER=y
CONFIG_MTRR_SANITIZER_ENABLE_DEFAULT=0
CONFIG_MTRR_SANITIZER_SPARE_REG_NR_DEFAULT=1
CONFIG_X86_PAT=y
CONFIG_ARCH_USES_PG_UNCACHED=y
CONFIG_ARCH_RANDOM=y
CONFIG_X86_SMAP=y
CONFIG_EFI=y
# CONFIG_EFI_STUB is not set
CONFIG_SECCOMP=y
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_300 is not set
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
# CONFIG_KEXEC_JUMP is not set
CONFIG_PHYSICAL_START=0x1000000
CONFIG_RELOCATABLE=y
CONFIG_PHYSICAL_ALIGN=0x1000000
CONFIG_HOTPLUG_CPU=y
# CONFIG_BOOTPARAM_HOTPLUG_CPU0 is not set
# CONFIG_DEBUG_HOTPLUG_CPU0 is not set
# CONFIG_COMPAT_VDSO is not set
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y
CONFIG_USE_PERCPU_NUMA_NODE_ID=y

#
# Power management and ACPI options
#
CONFIG_ARCH_HIBERNATION_HEADER=y
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_HIBERNATE_CALLBACKS=y
CONFIG_HIBERNATION=y
CONFIG_PM_STD_PARTITION=""
CONFIG_PM_SLEEP=y
CONFIG_PM_SLEEP_SMP=y
# CONFIG_PM_AUTOSLEEP is not set
# CONFIG_PM_WAKELOCKS is not set
CONFIG_PM_RUNTIME=y
CONFIG_PM=y
CONFIG_PM_DEBUG=y
CONFIG_PM_ADVANCED_DEBUG=y
CONFIG_PM_TEST_SUSPEND=y
CONFIG_PM_SLEEP_DEBUG=y
# CONFIG_PM_TRACE_RTC is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_PROCFS is not set
# CONFIG_ACPI_PROCFS_POWER is not set
# CONFIG_ACPI_EC_DEBUGFS is not set
# CONFIG_ACPI_PROC_EVENT is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
CONFIG_ACPI_VIDEO=y
CONFIG_ACPI_FAN=y
CONFIG_ACPI_DOCK=y
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
CONFIG_ACPI_IPMI=y
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
CONFIG_ACPI_PCI_SLOT=y
CONFIG_X86_PM_TIMER=y
CONFIG_ACPI_CONTAINER=y
CONFIG_ACPI_HOTPLUG_MEMORY=y
CONFIG_ACPI_SBS=y
CONFIG_ACPI_HED=y
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_BGRT is not set
CONFIG_ACPI_APEI=y
CONFIG_ACPI_APEI_GHES=y
CONFIG_ACPI_APEI_PCIEAER=y
CONFIG_ACPI_APEI_MEMORY_FAILURE=y
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
CONFIG_CPU_FREQ_STAT=y
# CONFIG_CPU_FREQ_STAT_DETAILS is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND=y
# CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE is not set
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
# CONFIG_X86_INTEL_PSTATE is not set
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ_CPB=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_CPU_IDLE=y
# CONFIG_CPU_IDLE_MULTIPLE_DRIVERS is not set
CONFIG_CPU_IDLE_GOV_LADDER=y
CONFIG_CPU_IDLE_GOV_MENU=y
# CONFIG_ARCH_NEEDS_CPU_IDLE_COUPLED is not set
CONFIG_INTEL_IDLE=y

#
# Memory power savings
#
CONFIG_I7300_IDLE_IOAT_CHANNEL=y
CONFIG_I7300_IDLE=y

#
# Bus options (PCI etc.)
#
CONFIG_PCI=y
CONFIG_PCI_DIRECT=y
CONFIG_PCI_MMCONFIG=y
CONFIG_PCI_XEN=y
CONFIG_PCI_DOMAINS=y
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
CONFIG_PCIEAER_INJECT=y
CONFIG_PCIEASPM=y
CONFIG_PCIEASPM_DEBUG=y
CONFIG_PCIEASPM_DEFAULT=y
# CONFIG_PCIEASPM_POWERSAVE is not set
# CONFIG_PCIEASPM_PERFORMANCE is not set
CONFIG_PCIE_PME=y
CONFIG_ARCH_SUPPORTS_MSI=y
CONFIG_PCI_MSI=y
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
CONFIG_PCI_STUB=y
CONFIG_XEN_PCIDEV_FRONTEND=y
CONFIG_HT_IRQ=y
# CONFIG_PCI_ATS is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
CONFIG_PCI_IOAPIC=y
CONFIG_PCI_LABEL=y
CONFIG_ISA_DMA_API=y
CONFIG_AMD_NB=y
CONFIG_PCCARD=y
CONFIG_PCMCIA=y
CONFIG_PCMCIA_LOAD_CIS=y
CONFIG_CARDBUS=y

#
# PC-card bridges
#
CONFIG_YENTA=y
CONFIG_YENTA_O2=y
CONFIG_YENTA_RICOH=y
CONFIG_YENTA_TI=y
CONFIG_YENTA_ENE_TUNE=y
CONFIG_YENTA_TOSHIBA=y
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
CONFIG_HOTPLUG_PCI_ACPI=y
CONFIG_HOTPLUG_PCI_ACPI_IBM=y
CONFIG_HOTPLUG_PCI_CPCI=y
CONFIG_HOTPLUG_PCI_CPCI_ZT5550=y
CONFIG_HOTPLUG_PCI_CPCI_GENERIC=y
CONFIG_HOTPLUG_PCI_SHPC=y
# CONFIG_RAPIDIO is not set

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_COMPAT_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
CONFIG_IA32_EMULATION=y
CONFIG_IA32_AOUT=y
# CONFIG_X86_X32 is not set
CONFIG_COMPAT=y
CONFIG_COMPAT_FOR_U64_ALIGNMENT=y
CONFIG_SYSVIPC_COMPAT=y
CONFIG_KEYS_COMPAT=y
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y
CONFIG_COMPAT_NETLINK_MESSAGES=y

#
# Networking options
#
CONFIG_PACKET=y
# CONFIG_PACKET_DIAG is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
CONFIG_XFRM=y
CONFIG_XFRM_ALGO=y
CONFIG_XFRM_USER=y
CONFIG_XFRM_SUB_POLICY=y
CONFIG_XFRM_MIGRATE=y
# CONFIG_XFRM_STATISTICS is not set
CONFIG_XFRM_IPCOMP=y
CONFIG_NET_KEY=y
CONFIG_NET_KEY_MIGRATE=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_FIB_TRIE_STATS=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
CONFIG_NET_IPGRE_DEMUX=y
CONFIG_NET_IP_TUNNEL=y
CONFIG_NET_IPGRE=y
CONFIG_NET_IPGRE_BROADCAST=y
CONFIG_IP_MROUTE=y
CONFIG_IP_MROUTE_MULTIPLE_TABLES=y
CONFIG_IP_PIMSM_V1=y
CONFIG_IP_PIMSM_V2=y
# CONFIG_ARPD is not set
CONFIG_SYN_COOKIES=y
# CONFIG_NET_IPVTI is not set
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_TUNNEL=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET_LRO=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_INET_UDP_DIAG is not set
CONFIG_TCP_CONG_ADVANCED=y
CONFIG_TCP_CONG_BIC=y
CONFIG_TCP_CONG_CUBIC=y
CONFIG_TCP_CONG_WESTWOOD=y
CONFIG_TCP_CONG_HTCP=y
CONFIG_TCP_CONG_HSTCP=y
CONFIG_TCP_CONG_HYBLA=y
CONFIG_TCP_CONG_VEGAS=y
CONFIG_TCP_CONG_SCALABLE=y
CONFIG_TCP_CONG_LP=y
CONFIG_TCP_CONG_VENO=y
CONFIG_TCP_CONG_YEAH=y
CONFIG_TCP_CONG_ILLINOIS=y
# CONFIG_DEFAULT_BIC is not set
CONFIG_DEFAULT_CUBIC=y
# CONFIG_DEFAULT_HTCP is not set
# CONFIG_DEFAULT_HYBLA is not set
# CONFIG_DEFAULT_VEGAS is not set
# CONFIG_DEFAULT_VENO is not set
# CONFIG_DEFAULT_WESTWOOD is not set
# CONFIG_DEFAULT_RENO is not set
CONFIG_DEFAULT_TCP_CONG="cubic"
CONFIG_TCP_MD5SIG=y
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
CONFIG_IPV6_OPTIMISTIC_DAD=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_IPV6_MIP6=y
CONFIG_INET6_XFRM_TUNNEL=y
CONFIG_INET6_TUNNEL=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION=y
CONFIG_IPV6_SIT=y
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=y
# CONFIG_IPV6_GRE is not set
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y
# CONFIG_NETLABEL is not set
CONFIG_NETWORK_SECMARK=y
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set
CONFIG_NETFILTER_ADVANCED=y
CONFIG_BRIDGE_NETFILTER=y

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=y
# CONFIG_NETFILTER_NETLINK_ACCT is not set
CONFIG_NETFILTER_NETLINK_QUEUE=y
CONFIG_NETFILTER_NETLINK_LOG=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_MARK=y
CONFIG_NF_CONNTRACK_SECMARK=y
CONFIG_NF_CONNTRACK_ZONES=y
CONFIG_NF_CONNTRACK_PROCFS=y
CONFIG_NF_CONNTRACK_EVENTS=y
# CONFIG_NF_CONNTRACK_TIMEOUT is not set
CONFIG_NF_CONNTRACK_TIMESTAMP=y
CONFIG_NF_CT_PROTO_DCCP=y
CONFIG_NF_CT_PROTO_GRE=y
CONFIG_NF_CT_PROTO_SCTP=y
CONFIG_NF_CT_PROTO_UDPLITE=y
CONFIG_NF_CONNTRACK_AMANDA=y
CONFIG_NF_CONNTRACK_FTP=y
CONFIG_NF_CONNTRACK_H323=y
CONFIG_NF_CONNTRACK_IRC=y
CONFIG_NF_CONNTRACK_BROADCAST=y
CONFIG_NF_CONNTRACK_NETBIOS_NS=y
CONFIG_NF_CONNTRACK_SNMP=y
CONFIG_NF_CONNTRACK_PPTP=y
CONFIG_NF_CONNTRACK_SANE=y
CONFIG_NF_CONNTRACK_SIP=y
CONFIG_NF_CONNTRACK_TFTP=y
CONFIG_NF_CT_NETLINK=y
# CONFIG_NF_CT_NETLINK_TIMEOUT is not set
# CONFIG_NETFILTER_NETLINK_QUEUE_CT is not set
CONFIG_NETFILTER_TPROXY=y
CONFIG_NETFILTER_XTABLES=y

#
# Xtables combined modules
#
CONFIG_NETFILTER_XT_MARK=y
CONFIG_NETFILTER_XT_CONNMARK=y
CONFIG_NETFILTER_XT_SET=y

#
# Xtables targets
#
CONFIG_NETFILTER_XT_TARGET_AUDIT=y
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
CONFIG_NETFILTER_XT_TARGET_IDLETIMER=y
CONFIG_NETFILTER_XT_TARGET_LED=y
# CONFIG_NETFILTER_XT_TARGET_LOG is not set
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFLOG=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_TARGET_RATEEST=y
CONFIG_NETFILTER_XT_TARGET_TEE=y
CONFIG_NETFILTER_XT_TARGET_TPROXY=y
CONFIG_NETFILTER_XT_TARGET_TRACE=y
CONFIG_NETFILTER_XT_TARGET_SECMARK=y
CONFIG_NETFILTER_XT_TARGET_TCPMSS=y
CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=y

#
# Xtables matches
#
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
# CONFIG_NETFILTER_XT_MATCH_BPF is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
# CONFIG_NETFILTER_XT_MATCH_CONNLABEL is not set
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_CPU=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_DEVGROUP=y
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
CONFIG_NETFILTER_XT_MATCH_IPVS=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_MULTIPORT=y
# CONFIG_NETFILTER_XT_MATCH_NFACCT is not set
CONFIG_NETFILTER_XT_MATCH_OSF=y
CONFIG_NETFILTER_XT_MATCH_OWNER=y
CONFIG_NETFILTER_XT_MATCH_POLICY=y
CONFIG_NETFILTER_XT_MATCH_PHYSDEV=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_QUOTA=y
CONFIG_NETFILTER_XT_MATCH_RATEEST=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_RECENT=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_SOCKET=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STATISTIC=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y
CONFIG_NETFILTER_XT_MATCH_TIME=y
CONFIG_NETFILTER_XT_MATCH_U32=y
CONFIG_IP_SET=y
CONFIG_IP_SET_MAX=256
CONFIG_IP_SET_BITMAP_IP=y
CONFIG_IP_SET_BITMAP_IPMAC=y
CONFIG_IP_SET_BITMAP_PORT=y
CONFIG_IP_SET_HASH_IP=y
CONFIG_IP_SET_HASH_IPPORT=y
CONFIG_IP_SET_HASH_IPPORTIP=y
CONFIG_IP_SET_HASH_IPPORTNET=y
CONFIG_IP_SET_HASH_NET=y
CONFIG_IP_SET_HASH_NETPORT=y
CONFIG_IP_SET_HASH_NETIFACE=y
CONFIG_IP_SET_LIST_SET=y
CONFIG_IP_VS=y
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12

#
# IPVS transport protocol load balancing support
#
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y

#
# IPVS scheduler
#
CONFIG_IP_VS_RR=y
CONFIG_IP_VS_WRR=y
CONFIG_IP_VS_LC=y
CONFIG_IP_VS_WLC=y
CONFIG_IP_VS_LBLC=y
CONFIG_IP_VS_LBLCR=y
CONFIG_IP_VS_DH=y
CONFIG_IP_VS_SH=y
CONFIG_IP_VS_SED=y
CONFIG_IP_VS_NQ=y

#
# IPVS SH scheduler
#
CONFIG_IP_VS_SH_TAB_BITS=8

#
# IPVS application helper
#
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=y

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
# CONFIG_NF_NAT_IPV4 is not set
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_CLUSTERIP=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_SECURITY=y
CONFIG_IP_NF_ARPTABLES=y
CONFIG_IP_NF_ARPFILTER=y
CONFIG_IP_NF_ARP_MANGLE=y

#
# IPv6: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV6=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_MATCH_AH=y
CONFIG_IP6_NF_MATCH_EUI64=y
CONFIG_IP6_NF_MATCH_FRAG=y
CONFIG_IP6_NF_MATCH_OPTS=y
CONFIG_IP6_NF_MATCH_HL=y
CONFIG_IP6_NF_MATCH_IPV6HEADER=y
CONFIG_IP6_NF_MATCH_MH=y
# CONFIG_IP6_NF_MATCH_RPFILTER is not set
CONFIG_IP6_NF_MATCH_RT=y
CONFIG_IP6_NF_TARGET_HL=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_RAW=y
CONFIG_IP6_NF_SECURITY=y
# CONFIG_NF_NAT_IPV6 is not set

#
# DECnet: Netfilter Configuration
#
CONFIG_DECNET_NF_GRABULATOR=y
CONFIG_BRIDGE_NF_EBTABLES=y
CONFIG_BRIDGE_EBT_BROUTE=y
CONFIG_BRIDGE_EBT_T_FILTER=y
CONFIG_BRIDGE_EBT_T_NAT=y
CONFIG_BRIDGE_EBT_802_3=y
CONFIG_BRIDGE_EBT_AMONG=y
CONFIG_BRIDGE_EBT_ARP=y
CONFIG_BRIDGE_EBT_IP=y
CONFIG_BRIDGE_EBT_IP6=y
CONFIG_BRIDGE_EBT_LIMIT=y
CONFIG_BRIDGE_EBT_MARK=y
CONFIG_BRIDGE_EBT_PKTTYPE=y
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
CONFIG_NET_DCCPPROBE=y
CONFIG_IP_SCTP=y
CONFIG_NET_SCTPPROBE=y
# CONFIG_SCTP_DBG_MSG is not set
# CONFIG_SCTP_DBG_OBJCNT is not set
CONFIG_SCTP_DEFAULT_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_SHA1 is not set
# CONFIG_SCTP_DEFAULT_COOKIE_HMAC_NONE is not set
CONFIG_SCTP_COOKIE_HMAC_MD5=y
# CONFIG_SCTP_COOKIE_HMAC_SHA1 is not set
CONFIG_RDS=y
CONFIG_RDS_RDMA=y
CONFIG_RDS_TCP=y
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_PORTS=8191
CONFIG_ATM=y
CONFIG_ATM_CLIP=y
# CONFIG_ATM_CLIP_NO_ICMP is not set
CONFIG_ATM_LANE=y
CONFIG_ATM_MPOA=y
CONFIG_ATM_BR2684=y
# CONFIG_ATM_BR2684_IPFILTER is not set
CONFIG_L2TP=y
CONFIG_L2TP_DEBUGFS=y
CONFIG_L2TP_V3=y
CONFIG_L2TP_IP=y
CONFIG_L2TP_ETH=y
CONFIG_STP=y
CONFIG_GARP=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_IGMP_SNOOPING=y
# CONFIG_BRIDGE_VLAN_FILTERING is not set
CONFIG_HAVE_NET_DSA=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
# CONFIG_VLAN_8021Q_MVRP is not set
CONFIG_DECNET=y
# CONFIG_DECNET_ROUTER is not set
CONFIG_LLC=y
CONFIG_LLC2=y
CONFIG_IPX=y
# CONFIG_IPX_INTERN is not set
CONFIG_ATALK=y
CONFIG_DEV_APPLETALK=y
CONFIG_IPDDP=y
CONFIG_IPDDP_ENCAP=y
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
CONFIG_IEEE802154_6LOWPAN=y
# CONFIG_MAC802154 is not set
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
CONFIG_NET_SCH_SFB=y
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
CONFIG_NET_SCH_MQPRIO=y
CONFIG_NET_SCH_CHOKE=y
CONFIG_NET_SCH_QFQ=y
# CONFIG_NET_SCH_CODEL is not set
# CONFIG_NET_SCH_FQ_CODEL is not set
CONFIG_NET_SCH_INGRESS=y
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
CONFIG_CLS_U32_PERF=y
CONFIG_CLS_U32_MARK=y
CONFIG_NET_CLS_RSVP=y
CONFIG_NET_CLS_RSVP6=y
CONFIG_NET_CLS_FLOW=y
CONFIG_NET_CLS_CGROUP=y
CONFIG_NET_EMATCH=y
CONFIG_NET_EMATCH_STACK=32
CONFIG_NET_EMATCH_CMP=y
CONFIG_NET_EMATCH_NBYTE=y
CONFIG_NET_EMATCH_U32=y
CONFIG_NET_EMATCH_META=y
CONFIG_NET_EMATCH_TEXT=y
# CONFIG_NET_EMATCH_CANID is not set
# CONFIG_NET_EMATCH_IPSET is not set
CONFIG_NET_CLS_ACT=y
CONFIG_NET_ACT_POLICE=y
CONFIG_NET_ACT_GACT=y
CONFIG_GACT_PROB=y
CONFIG_NET_ACT_MIRRED=y
CONFIG_NET_ACT_IPT=y
CONFIG_NET_ACT_NAT=y
CONFIG_NET_ACT_PEDIT=y
CONFIG_NET_ACT_SIMP=y
CONFIG_NET_ACT_SKBEDIT=y
CONFIG_NET_ACT_CSUM=y
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
CONFIG_BATMAN_ADV=y
CONFIG_BATMAN_ADV_BLA=y
# CONFIG_BATMAN_ADV_DAT is not set
# CONFIG_BATMAN_ADV_NC is not set
# CONFIG_BATMAN_ADV_DEBUG is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_DIAG is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
CONFIG_BPF_JIT=y

#
# Network testing
#
CONFIG_NET_PKTGEN=y
# CONFIG_NET_TCPPROBE is not set
CONFIG_NET_DROP_MONITOR=y
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
CONFIG_MKISS=y
CONFIG_6PACK=y
CONFIG_BPQETHER=y
CONFIG_BAYCOM_SER_FDX=y
CONFIG_BAYCOM_SER_HDX=y
CONFIG_BAYCOM_PAR=y
CONFIG_YAM=y
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_BCM=y
CONFIG_CAN_GW=y

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
CONFIG_CAN_SLCAN=y
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
# CONFIG_CAN_LEDS is not set
CONFIG_CAN_MCP251X=y
CONFIG_PCH_CAN=y
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
CONFIG_CAN_EMS_PCMCIA=y
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
CONFIG_CAN_PEAK_PCI=y
CONFIG_CAN_PEAK_PCIEC=y
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
CONFIG_CAN_ESD_USB2=y
# CONFIG_CAN_KVASER_USB is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_8DEV_USB is not set
CONFIG_CAN_SOFTING=y
CONFIG_CAN_SOFTING_CS=y
# CONFIG_CAN_DEBUG_DEVICES is not set
CONFIG_IRDA=y

#
# IrDA protocols
#
CONFIG_IRLAN=y
CONFIG_IRNET=y
CONFIG_IRCOMM=y
# CONFIG_IRDA_ULTRA is not set

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
CONFIG_IRTTY_SIR=y

#
# Dongle support
#
CONFIG_DONGLE=y
CONFIG_ESI_DONGLE=y
CONFIG_ACTISYS_DONGLE=y
CONFIG_TEKRAM_DONGLE=y
CONFIG_TOIM3232_DONGLE=y
CONFIG_LITELINK_DONGLE=y
CONFIG_MA600_DONGLE=y
CONFIG_GIRBIL_DONGLE=y
CONFIG_MCP2120_DONGLE=y
CONFIG_OLD_BELKIN_DONGLE=y
CONFIG_ACT200L_DONGLE=y
CONFIG_KINGSUN_DONGLE=y
CONFIG_KSDAZZLE_DONGLE=y
CONFIG_KS959_DONGLE=y

#
# FIR device drivers
#
CONFIG_USB_IRDA=y
CONFIG_SIGMATEL_FIR=y
CONFIG_NSC_FIR=y
CONFIG_WINBOND_FIR=y
CONFIG_SMC_IRCC_FIR=y
CONFIG_ALI_FIR=y
CONFIG_VLSI_FIR=y
CONFIG_VIA_FIR=y
CONFIG_MCS_FIR=y
CONFIG_BT=y
CONFIG_BT_RFCOMM=y
CONFIG_BT_RFCOMM_TTY=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_CMTP=y
CONFIG_BT_HIDP=y

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
CONFIG_BT_HCIUART_ATH3K=y
CONFIG_BT_HCIUART_LL=y
# CONFIG_BT_HCIUART_3WIRE is not set
CONFIG_BT_HCIBCM203X=y
CONFIG_BT_HCIBPA10X=y
CONFIG_BT_HCIBFUSB=y
CONFIG_BT_HCIDTL1=y
CONFIG_BT_HCIBT3C=y
CONFIG_BT_HCIBLUECARD=y
CONFIG_BT_HCIBTUART=y
CONFIG_BT_HCIVHCI=y
CONFIG_BT_MRVL=y
CONFIG_BT_MRVL_SDIO=y
CONFIG_BT_ATH3K=y
CONFIG_AF_RXRPC=y
# CONFIG_AF_RXRPC_DEBUG is not set
CONFIG_RXKAD=y
CONFIG_FIB_RULES=y
CONFIG_WIRELESS=y
CONFIG_WIRELESS_EXT=y
CONFIG_WEXT_CORE=y
CONFIG_WEXT_PROC=y
CONFIG_WEXT_SPY=y
CONFIG_WEXT_PRIV=y
CONFIG_CFG80211=y
# CONFIG_NL80211_TESTMODE is not set
# CONFIG_CFG80211_DEVELOPER_WARNINGS is not set
# CONFIG_CFG80211_REG_DEBUG is not set
CONFIG_CFG80211_DEFAULT_PS=y
# CONFIG_CFG80211_DEBUGFS is not set
# CONFIG_CFG80211_INTERNAL_REGDB is not set
CONFIG_CFG80211_WEXT=y
CONFIG_LIB80211=y
CONFIG_LIB80211_CRYPT_WEP=y
CONFIG_LIB80211_CRYPT_CCMP=y
CONFIG_LIB80211_CRYPT_TKIP=y
# CONFIG_LIB80211_DEBUG is not set
CONFIG_MAC80211=y
CONFIG_MAC80211_HAS_RC=y
CONFIG_MAC80211_RC_MINSTREL=y
CONFIG_MAC80211_RC_MINSTREL_HT=y
CONFIG_MAC80211_RC_DEFAULT_MINSTREL=y
CONFIG_MAC80211_RC_DEFAULT="minstrel_ht"
CONFIG_MAC80211_MESH=y
CONFIG_MAC80211_LEDS=y
# CONFIG_MAC80211_DEBUGFS is not set
# CONFIG_MAC80211_MESSAGE_TRACING is not set
# CONFIG_MAC80211_DEBUG_MENU is not set
CONFIG_WIMAX=y
CONFIG_WIMAX_DEBUG_LEVEL=8
CONFIG_RFKILL=y
CONFIG_RFKILL_LEDS=y
CONFIG_RFKILL_INPUT=y
# CONFIG_RFKILL_REGULATOR is not set
CONFIG_NET_9P=y
CONFIG_NET_9P_VIRTIO=y
CONFIG_NET_9P_RDMA=y
# CONFIG_NET_9P_DEBUG is not set
# CONFIG_CAIF is not set
CONFIG_CEPH_LIB=y
# CONFIG_CEPH_LIB_PRETTYDEBUG is not set
# CONFIG_CEPH_LIB_USE_DNS_RESOLVER is not set
CONFIG_NFC=y
CONFIG_NFC_NCI=y
# CONFIG_NFC_HCI is not set
# CONFIG_NFC_LLCP is not set

#
# Near Field Communication (NFC) devices
#
CONFIG_NFC_PN533=y
CONFIG_HAVE_BPF_JIT=y

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_UEVENT_HELPER_PATH=""
CONFIG_DEVTMPFS=y
# CONFIG_DEVTMPFS_MOUNT is not set
CONFIG_STANDALONE=y
CONFIG_PREVENT_FIRMWARE_BUILD=y
CONFIG_FW_LOADER=y
# CONFIG_FIRMWARE_IN_KERNEL is not set
CONFIG_EXTRA_FIRMWARE=""
CONFIG_FW_LOADER_USER_HELPER=y
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_DMA_SHARED_BUFFER=y

#
# Bus devices
#
CONFIG_CONNECTOR=y
CONFIG_PROC_EVENTS=y
CONFIG_MTD=y
# CONFIG_MTD_TESTS is not set
CONFIG_MTD_REDBOOT_PARTS=y
CONFIG_MTD_REDBOOT_DIRECTORY_BLOCK=-1
# CONFIG_MTD_REDBOOT_PARTS_UNALLOCATED is not set
# CONFIG_MTD_REDBOOT_PARTS_READONLY is not set
# CONFIG_MTD_CMDLINE_PARTS is not set
CONFIG_MTD_AR7_PARTS=y

#
# User Modules And Translation Layers
#
CONFIG_MTD_CHAR=y
CONFIG_MTD_BLKDEVS=y
CONFIG_MTD_BLOCK=y
CONFIG_FTL=y
CONFIG_NFTL=y
CONFIG_NFTL_RW=y
CONFIG_INFTL=y
CONFIG_RFD_FTL=y
CONFIG_SSFDC=y
# CONFIG_SM_FTL is not set
CONFIG_MTD_OOPS=y
CONFIG_MTD_SWAP=y

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
CONFIG_MTD_ROM=y
CONFIG_MTD_ABSENT=y

#
# Mapping drivers for chip access
#
CONFIG_MTD_COMPLEX_MAPPINGS=y
CONFIG_MTD_PHYSMAP=y
# CONFIG_MTD_PHYSMAP_COMPAT is not set
CONFIG_MTD_SC520CDP=y
CONFIG_MTD_NETSC520=y
CONFIG_MTD_TS5500=y
CONFIG_MTD_SBC_GXX=y
# CONFIG_MTD_AMD76XROM is not set
# CONFIG_MTD_ICHXROM is not set
# CONFIG_MTD_ESB2ROM is not set
# CONFIG_MTD_CK804XROM is not set
# CONFIG_MTD_SCB2_FLASH is not set
# CONFIG_MTD_NETtel is not set
# CONFIG_MTD_L440GX is not set
CONFIG_MTD_PCI=y
CONFIG_MTD_PCMCIA=y
# CONFIG_MTD_PCMCIA_ANONYMOUS is not set
# CONFIG_MTD_GPIO_ADDR is not set
CONFIG_MTD_INTEL_VR_NOR=y
CONFIG_MTD_PLATRAM=y
# CONFIG_MTD_LATCH_ADDR is not set

#
# Self-contained MTD device drivers
#
CONFIG_MTD_PMC551=y
# CONFIG_MTD_PMC551_BUGFIX is not set
# CONFIG_MTD_PMC551_DEBUG is not set
CONFIG_MTD_DATAFLASH=y
# CONFIG_MTD_DATAFLASH_WRITE_VERIFY is not set
# CONFIG_MTD_DATAFLASH_OTP is not set
CONFIG_MTD_M25P80=y
CONFIG_M25PXX_USE_FAST_READ=y
CONFIG_MTD_SST25L=y
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
CONFIG_MTD_DOC2000=y
CONFIG_MTD_DOC2001=y
CONFIG_MTD_DOC2001PLUS=y
# CONFIG_MTD_DOCG3 is not set
CONFIG_MTD_DOCPROBE=y
CONFIG_MTD_DOCECC=y
# CONFIG_MTD_DOCPROBE_ADVANCED is not set
CONFIG_MTD_DOCPROBE_ADDRESS=0x0
CONFIG_MTD_NAND_ECC=y
# CONFIG_MTD_NAND_ECC_SMC is not set
CONFIG_MTD_NAND=y
# CONFIG_MTD_NAND_ECC_BCH is not set
CONFIG_MTD_SM_COMMON=y
# CONFIG_MTD_NAND_MUSEUM_IDS is not set
# CONFIG_MTD_NAND_DENALI is not set
CONFIG_MTD_NAND_IDS=y
CONFIG_MTD_NAND_RICOH=y
CONFIG_MTD_NAND_DISKONCHIP=y
# CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADVANCED is not set
CONFIG_MTD_NAND_DISKONCHIP_PROBE_ADDRESS=0
# CONFIG_MTD_NAND_DISKONCHIP_BBTWRITE is not set
# CONFIG_MTD_NAND_DOCG4 is not set
CONFIG_MTD_NAND_CAFE=y
CONFIG_MTD_NAND_NANDSIM=y
CONFIG_MTD_NAND_PLATFORM=y
CONFIG_MTD_ALAUDA=y
CONFIG_MTD_ONENAND=y
CONFIG_MTD_ONENAND_VERIFY_WRITE=y
CONFIG_MTD_ONENAND_GENERIC=y
# CONFIG_MTD_ONENAND_OTP is not set
CONFIG_MTD_ONENAND_2X_PROGRAM=y
CONFIG_MTD_ONENAND_SIM=y

#
# LPDDR flash memory drivers
#
CONFIG_MTD_LPDDR=y
CONFIG_MTD_QINFO_PROBE=y
CONFIG_MTD_UBI=y
CONFIG_MTD_UBI_WL_THRESHOLD=4096
CONFIG_MTD_UBI_BEB_LIMIT=20
# CONFIG_MTD_UBI_FASTMAP is not set
# CONFIG_MTD_UBI_GLUEBI is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
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
CONFIG_BLK_DEV_FD=y
CONFIG_PARIDE=m

#
# Parallel IDE high-level drivers
#
CONFIG_PARIDE_PD=m
CONFIG_PARIDE_PCD=m
CONFIG_PARIDE_PF=m
CONFIG_PARIDE_PT=m
CONFIG_PARIDE_PG=m

#
# Parallel IDE protocol modules
#
CONFIG_PARIDE_ATEN=m
CONFIG_PARIDE_BPCK=m
CONFIG_PARIDE_COMM=m
CONFIG_PARIDE_DSTR=m
CONFIG_PARIDE_FIT2=m
CONFIG_PARIDE_FIT3=m
CONFIG_PARIDE_EPAT=m
# CONFIG_PARIDE_EPATC8 is not set
CONFIG_PARIDE_EPIA=m
CONFIG_PARIDE_FRIQ=m
CONFIG_PARIDE_FRPW=m
CONFIG_PARIDE_KBIC=m
CONFIG_PARIDE_KTTI=m
CONFIG_PARIDE_ON20=m
CONFIG_PARIDE_ON26=m
# CONFIG_BLK_DEV_PCIESSD_MTIP32XX is not set
CONFIG_BLK_CPQ_DA=y
CONFIG_BLK_CPQ_CISS_DA=y
CONFIG_CISS_SCSI_TAPE=y
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set
CONFIG_BLK_DEV_DRBD=y
# CONFIG_DRBD_FAULT_INJECTION is not set
CONFIG_BLK_DEV_NBD=y
# CONFIG_BLK_DEV_NVME is not set
CONFIG_BLK_DEV_OSD=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
CONFIG_XEN_BLKDEV_BACKEND=y
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
CONFIG_BLK_DEV_RBD=y
# CONFIG_BLK_DEV_RSXX is not set

#
# Misc devices
#
CONFIG_SENSORS_LIS3LV02D=y
CONFIG_AD525X_DPOT=y
CONFIG_AD525X_DPOT_I2C=y
CONFIG_AD525X_DPOT_SPI=y
CONFIG_IBM_ASM=y
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
CONFIG_SGI_IOC4=y
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
# CONFIG_ATMEL_SSC is not set
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
CONFIG_ISL29020=y
CONFIG_SENSORS_TSL2550=y
CONFIG_SENSORS_BH1780=y
CONFIG_SENSORS_BH1770=y
CONFIG_SENSORS_APDS990X=y
CONFIG_HMC6352=y
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
CONFIG_PCH_PHUB=y
# CONFIG_USB_SWITCH_FSA9480 is not set
# CONFIG_LATTICE_ECP3_CONFIG is not set
CONFIG_C2PORT=y
CONFIG_C2PORT_DURAMAR_2150=y

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
CONFIG_EEPROM_AT25=y
CONFIG_EEPROM_LEGACY=y
CONFIG_EEPROM_MAX6875=y
CONFIG_EEPROM_93CX6=y
# CONFIG_EEPROM_93XX46 is not set
CONFIG_CB710_CORE=y
# CONFIG_CB710_DEBUG is not set
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
CONFIG_SENSORS_LIS3_I2C=y

#
# Altera FPGA firmware download module
#
# CONFIG_ALTERA_STAPL is not set
# CONFIG_INTEL_MEI is not set
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
CONFIG_IDE=y

#
# Please see Documentation/ide/ide.txt for help/info on IDE drives
#
CONFIG_IDE_XFER_MODE=y
CONFIG_IDE_ATAPI=y
# CONFIG_BLK_DEV_IDE_SATA is not set
CONFIG_IDE_GD=y
CONFIG_IDE_GD_ATA=y
CONFIG_IDE_GD_ATAPI=y
# CONFIG_BLK_DEV_IDECS is not set
CONFIG_BLK_DEV_DELKIN=y
CONFIG_BLK_DEV_IDECD=y
CONFIG_BLK_DEV_IDECD_VERBOSE_ERRORS=y
CONFIG_BLK_DEV_IDETAPE=y
# CONFIG_BLK_DEV_IDEACPI is not set
# CONFIG_IDE_TASK_IOCTL is not set
CONFIG_IDE_PROC_FS=y

#
# IDE chipset support/bugfixes
#
CONFIG_IDE_GENERIC=y
# CONFIG_BLK_DEV_PLATFORM is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPNP=y
CONFIG_BLK_DEV_IDEDMA_SFF=y

#
# PCI IDE chipsets support
#
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_PCIBUS_ORDER=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
CONFIG_BLK_DEV_OPTI621=y
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CS5520 is not set
# CONFIG_BLK_DEV_CS5530 is not set
CONFIG_BLK_DEV_HPT366=y
# CONFIG_BLK_DEV_JMICRON is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
CONFIG_BLK_DEV_IT8172=y
CONFIG_BLK_DEV_IT8213=y
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
CONFIG_BLK_DEV_TRM290=y
# CONFIG_BLK_DEV_VIA82CXXX is not set
CONFIG_BLK_DEV_TC86C001=y
CONFIG_BLK_DEV_IDEDMA=y

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
CONFIG_RAID_ATTRS=y
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
CONFIG_SCSI_TGT=y
CONFIG_SCSI_NETLINK=y
# CONFIG_SCSI_PROC_FS is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
CONFIG_BLK_DEV_SR_VENDOR=y
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_ENCLOSURE=y
CONFIG_SCSI_MULTI_LUN=y
CONFIG_SCSI_CONSTANTS=y
CONFIG_SCSI_LOGGING=y
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
CONFIG_SCSI_SPI_ATTRS=y
CONFIG_SCSI_FC_ATTRS=y
CONFIG_SCSI_FC_TGT_ATTRS=y
CONFIG_SCSI_ISCSI_ATTRS=y
CONFIG_SCSI_SAS_ATTRS=y
CONFIG_SCSI_SAS_LIBSAS=y
CONFIG_SCSI_SAS_ATA=y
CONFIG_SCSI_SAS_HOST_SMP=y
CONFIG_SCSI_SRP_ATTRS=y
CONFIG_SCSI_SRP_TGT_ATTRS=y
CONFIG_SCSI_LOWLEVEL=y
CONFIG_ISCSI_TCP=y
CONFIG_ISCSI_BOOT_SYSFS=y
CONFIG_SCSI_CXGB3_ISCSI=y
CONFIG_SCSI_CXGB4_ISCSI=y
CONFIG_SCSI_BNX2_ISCSI=y
CONFIG_SCSI_BNX2X_FCOE=y
CONFIG_BE2ISCSI=y
CONFIG_BLK_DEV_3W_XXXX_RAID=y
CONFIG_SCSI_HPSA=y
CONFIG_SCSI_3W_9XXX=y
CONFIG_SCSI_3W_SAS=y
CONFIG_SCSI_ACARD=y
CONFIG_SCSI_AACRAID=y
CONFIG_SCSI_AIC7XXX=y
CONFIG_AIC7XXX_CMDS_PER_DEVICE=8
CONFIG_AIC7XXX_RESET_DELAY_MS=15000
CONFIG_AIC7XXX_DEBUG_ENABLE=y
CONFIG_AIC7XXX_DEBUG_MASK=0
CONFIG_AIC7XXX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC7XXX_OLD=y
CONFIG_SCSI_AIC79XX=y
CONFIG_AIC79XX_CMDS_PER_DEVICE=32
CONFIG_AIC79XX_RESET_DELAY_MS=15000
CONFIG_AIC79XX_DEBUG_ENABLE=y
CONFIG_AIC79XX_DEBUG_MASK=0
CONFIG_AIC79XX_REG_PRETTY_PRINT=y
CONFIG_SCSI_AIC94XX=y
# CONFIG_AIC94XX_DEBUG is not set
CONFIG_SCSI_MVSAS=y
# CONFIG_SCSI_MVSAS_DEBUG is not set
# CONFIG_SCSI_MVSAS_TASKLET is not set
CONFIG_SCSI_MVUMI=y
CONFIG_SCSI_DPT_I2O=y
CONFIG_SCSI_ADVANSYS=y
CONFIG_SCSI_ARCMSR=y
CONFIG_MEGARAID_NEWGEN=y
CONFIG_MEGARAID_MM=y
CONFIG_MEGARAID_MAILBOX=y
CONFIG_MEGARAID_LEGACY=y
CONFIG_MEGARAID_SAS=y
CONFIG_SCSI_MPT2SAS=y
CONFIG_SCSI_MPT2SAS_MAX_SGE=128
# CONFIG_SCSI_MPT2SAS_LOGGING is not set
# CONFIG_SCSI_MPT3SAS is not set
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
CONFIG_VMWARE_PVSCSI=y
CONFIG_HYPERV_STORAGE=y
CONFIG_LIBFC=y
CONFIG_LIBFCOE=y
CONFIG_FCOE=y
CONFIG_FCOE_FNIC=y
CONFIG_SCSI_DMX3191D=y
CONFIG_SCSI_EATA=y
CONFIG_SCSI_EATA_TAGGED_QUEUE=y
CONFIG_SCSI_EATA_LINKED_COMMANDS=y
CONFIG_SCSI_EATA_MAX_TAGS=16
CONFIG_SCSI_FUTURE_DOMAIN=y
CONFIG_SCSI_GDTH=y
CONFIG_SCSI_ISCI=y
CONFIG_SCSI_IPS=y
CONFIG_SCSI_INITIO=y
CONFIG_SCSI_INIA100=y
CONFIG_SCSI_PPA=y
CONFIG_SCSI_IMM=y
# CONFIG_SCSI_IZIP_EPP16 is not set
# CONFIG_SCSI_IZIP_SLOW_CTR is not set
CONFIG_SCSI_STEX=y
CONFIG_SCSI_SYM53C8XX_2=y
CONFIG_SCSI_SYM53C8XX_DMA_ADDRESSING_MODE=1
CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS=16
CONFIG_SCSI_SYM53C8XX_MAX_TAGS=64
CONFIG_SCSI_SYM53C8XX_MMIO=y
CONFIG_SCSI_IPR=y
# CONFIG_SCSI_IPR_TRACE is not set
# CONFIG_SCSI_IPR_DUMP is not set
CONFIG_SCSI_QLOGIC_1280=y
CONFIG_SCSI_QLA_FC=y
# CONFIG_TCM_QLA2XXX is not set
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
CONFIG_SCSI_VIRTIO=y
# CONFIG_SCSI_CHELSIO_FCOE is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_PCMCIA_AHA152X=m
CONFIG_PCMCIA_FDOMAIN=m
CONFIG_PCMCIA_QLOGIC=m
CONFIG_PCMCIA_SYM53C500=m
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
CONFIG_SCSI_DH_HP_SW=y
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
CONFIG_SCSI_OSD_ULD=y
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
CONFIG_ATA_VERBOSE_ERROR=y
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
CONFIG_SATA_ACARD_AHCI=y
CONFIG_SATA_SIL24=y
# CONFIG_ATA_SFF is not set

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
CONFIG_SATA_QSTOR=y
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
# CONFIG_SATA_HIGHBANK is not set
CONFIG_SATA_MV=y
CONFIG_SATA_NV=y
CONFIG_SATA_PROMISE=y
CONFIG_SATA_SIL=y
CONFIG_SATA_SIS=y
CONFIG_SATA_SVW=y
CONFIG_SATA_ULI=y
CONFIG_SATA_VIA=y
CONFIG_SATA_VITESSE=y

#
# PATA SFF controllers with BMDMA
#
CONFIG_PATA_ALI=y
CONFIG_PATA_AMD=y
CONFIG_PATA_ARASAN_CF=y
CONFIG_PATA_ARTOP=y
CONFIG_PATA_ATIIXP=y
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
CONFIG_PATA_CS5530=y
# CONFIG_PATA_CS5536 is not set
# CONFIG_PATA_CYPRESS is not set
CONFIG_PATA_EFAR=y
# CONFIG_PATA_HPT366 is not set
# CONFIG_PATA_HPT37X is not set
# CONFIG_PATA_HPT3X2N is not set
# CONFIG_PATA_HPT3X3 is not set
# CONFIG_PATA_IT8213 is not set
CONFIG_PATA_IT821X=y
CONFIG_PATA_JMICRON=y
CONFIG_PATA_MARVELL=y
CONFIG_PATA_NETCELL=y
# CONFIG_PATA_NINJA32 is not set
CONFIG_PATA_NS87415=y
CONFIG_PATA_OLDPIIX=y
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
# CONFIG_PATA_RADISYS is not set
CONFIG_PATA_RDC=y
CONFIG_PATA_SC1200=y
CONFIG_PATA_SCH=y
CONFIG_PATA_SERVERWORKS=y
CONFIG_PATA_SIL680=y
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
CONFIG_PATA_TRIFLEX=y
CONFIG_PATA_VIA=y
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
# CONFIG_PATA_CMD640_PCI is not set
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
# CONFIG_PATA_LEGACY is not set
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
CONFIG_MD_RAID456=y
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_BUFIO=y
CONFIG_DM_BIO_PRISON=y
CONFIG_DM_PERSISTENT_DATA=y
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
CONFIG_DM_THIN_PROVISIONING=y
# CONFIG_DM_DEBUG_BLOCK_STACK_TRACING is not set
# CONFIG_DM_CACHE is not set
CONFIG_DM_MIRROR=y
CONFIG_DM_RAID=y
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
CONFIG_DM_FLAKEY=y
# CONFIG_DM_VERITY is not set
CONFIG_TARGET_CORE=y
CONFIG_TCM_IBLOCK=y
CONFIG_TCM_FILEIO=y
CONFIG_TCM_PSCSI=y
CONFIG_LOOPBACK_TARGET=y
CONFIG_TCM_FC=y
CONFIG_ISCSI_TARGET=y
# CONFIG_SBP_TARGET is not set
CONFIG_FUSION=y
CONFIG_FUSION_SPI=y
CONFIG_FUSION_FC=y
CONFIG_FUSION_SAS=y
CONFIG_FUSION_MAX_SGE=128
CONFIG_FUSION_CTL=y
CONFIG_FUSION_LAN=y
# CONFIG_FUSION_LOGGING is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NET=y
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
CONFIG_I2O_LCT_NOTIFY_ON_CHANGES=y
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=y
CONFIG_I2O_CONFIG_OLD_IOCTL=y
CONFIG_I2O_BUS=y
CONFIG_I2O_BLOCK=y
CONFIG_I2O_SCSI=y
CONFIG_I2O_PROC=y
CONFIG_MACINTOSH_DRIVERS=y
CONFIG_MAC_EMUMOUSEBTN=y
CONFIG_NETDEVICES=y
CONFIG_NET_CORE=y
CONFIG_BONDING=y
CONFIG_DUMMY=y
CONFIG_EQUALIZER=y
CONFIG_NET_FC=y
CONFIG_MII=y
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
# CONFIG_VXLAN is not set
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
CONFIG_SUNGEM_PHY=y
CONFIG_ARCNET=y
CONFIG_ARCNET_1201=y
CONFIG_ARCNET_1051=y
CONFIG_ARCNET_RAW=y
CONFIG_ARCNET_CAP=y
CONFIG_ARCNET_COM90xx=y
CONFIG_ARCNET_COM90xxIO=y
CONFIG_ARCNET_RIM_I=y
CONFIG_ARCNET_COM20020=y
CONFIG_ARCNET_COM20020_PCI=y
CONFIG_ARCNET_COM20020_CS=y
CONFIG_ATM_DRIVERS=y
CONFIG_ATM_DUMMY=y
CONFIG_ATM_TCP=y
CONFIG_ATM_LANAI=y
CONFIG_ATM_ENI=y
# CONFIG_ATM_ENI_DEBUG is not set
# CONFIG_ATM_ENI_TUNE_BURST is not set
CONFIG_ATM_FIRESTREAM=y
CONFIG_ATM_ZATM=y
# CONFIG_ATM_ZATM_DEBUG is not set
CONFIG_ATM_NICSTAR=y
CONFIG_ATM_NICSTAR_USE_SUNI=y
CONFIG_ATM_NICSTAR_USE_IDT77105=y
CONFIG_ATM_IDT77252=y
# CONFIG_ATM_IDT77252_DEBUG is not set
# CONFIG_ATM_IDT77252_RCV_ALL is not set
CONFIG_ATM_IDT77252_USE_SUNI=y
CONFIG_ATM_AMBASSADOR=y
# CONFIG_ATM_AMBASSADOR_DEBUG is not set
CONFIG_ATM_HORIZON=y
# CONFIG_ATM_HORIZON_DEBUG is not set
CONFIG_ATM_IA=y
# CONFIG_ATM_IA_DEBUG is not set
CONFIG_ATM_FORE200E=y
# CONFIG_ATM_FORE200E_USE_TASKLET is not set
CONFIG_ATM_FORE200E_TX_RETRY=16
CONFIG_ATM_FORE200E_DEBUG=0
CONFIG_ATM_HE=y
CONFIG_ATM_HE_USE_SUNI=y
CONFIG_ATM_SOLOS=y

#
# CAIF transport drivers
#

#
# Distributed Switch Architecture drivers
#
# CONFIG_NET_DSA_MV88E6XXX is not set
# CONFIG_NET_DSA_MV88E6060 is not set
# CONFIG_NET_DSA_MV88E6XXX_NEED_PPU is not set
# CONFIG_NET_DSA_MV88E6131 is not set
# CONFIG_NET_DSA_MV88E6123_61_65 is not set
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
CONFIG_PCMCIA_3C574=y
CONFIG_PCMCIA_3C589=y
CONFIG_VORTEX=y
CONFIG_TYPHOON=y
CONFIG_NET_VENDOR_ADAPTEC=y
CONFIG_ADAPTEC_STARFIRE=y
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
CONFIG_AMD8111_ETH=y
CONFIG_PCNET32=y
CONFIG_PCMCIA_NMCLAN=y
CONFIG_NET_VENDOR_ATHEROS=y
CONFIG_ATL2=y
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_CADENCE=y
# CONFIG_ARM_AT91_ETHER is not set
# CONFIG_MACB is not set
CONFIG_NET_VENDOR_BROADCOM=y
CONFIG_B44=y
CONFIG_B44_PCI_AUTOSELECT=y
CONFIG_B44_PCICORE_AUTOSELECT=y
CONFIG_B44_PCI=y
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_BNX2X_SRIOV=y
CONFIG_NET_VENDOR_BROCADE=y
CONFIG_BNA=y
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
CONFIG_CHELSIO_T4VF=y
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
CONFIG_DNET=y
CONFIG_NET_VENDOR_DEC=y
CONFIG_NET_TULIP=y
CONFIG_DE2104X=y
CONFIG_DE2104X_DSL=0
CONFIG_TULIP=y
# CONFIG_TULIP_MWI is not set
# CONFIG_TULIP_MMIO is not set
CONFIG_TULIP_NAPI=y
CONFIG_TULIP_NAPI_HW_MITIGATION=y
CONFIG_DE4X5=y
CONFIG_WINBOND_840=y
CONFIG_DM9102=y
CONFIG_ULI526X=y
CONFIG_PCMCIA_XIRCOM=y
CONFIG_NET_VENDOR_DLINK=y
CONFIG_DL2K=y
CONFIG_SUNDANCE=y
# CONFIG_SUNDANCE_MMIO is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
CONFIG_PCMCIA_FMVJ18X=y
CONFIG_NET_VENDOR_HP=y
CONFIG_HP100=y
CONFIG_NET_VENDOR_INTEL=y
CONFIG_E100=y
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_HWMON=y
CONFIG_IGB_DCA=y
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
# CONFIG_MVMDIO is not set
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
CONFIG_SKGE_GENESIS=y
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
CONFIG_KS8842=y
CONFIG_KS8851=y
CONFIG_KS8851_MLL=y
CONFIG_KSZ884X_PCI=y
CONFIG_NET_VENDOR_MICROCHIP=y
CONFIG_ENC28J60=y
# CONFIG_ENC28J60_WRITEVERIFY is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
CONFIG_FEALNX=y
CONFIG_NET_VENDOR_NATSEMI=y
CONFIG_NATSEMI=y
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
CONFIG_PCMCIA_AXNET=y
CONFIG_NE2K_PCI=y
CONFIG_PCMCIA_PCNET=y
CONFIG_NET_VENDOR_NVIDIA=y
CONFIG_FORCEDETH=y
CONFIG_NET_VENDOR_OKI=y
CONFIG_PCH_GBE=y
CONFIG_ETHOC=y
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
CONFIG_ATP=y
CONFIG_8139CP=y
CONFIG_8139TOO=y
CONFIG_8139TOO_PIO=y
CONFIG_8139TOO_TUNE_TWISTER=y
CONFIG_8139TOO_8129=y
# CONFIG_8139_OLD_RX_RESET is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
CONFIG_R6040=y
CONFIG_NET_VENDOR_SEEQ=y
CONFIG_NET_VENDOR_SILAN=y
CONFIG_SC92031=y
CONFIG_NET_VENDOR_SIS=y
CONFIG_SIS900=y
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
CONFIG_PCMCIA_SMC91C92=y
CONFIG_EPIC100=y
CONFIG_SMSC9420=y
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
CONFIG_HAPPYMEAL=y
CONFIG_SUNGEM=y
CONFIG_CASSINI=y
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
CONFIG_TLAN=y
CONFIG_NET_VENDOR_VIA=y
CONFIG_VIA_RHINE=y
# CONFIG_VIA_RHINE_MMIO is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
CONFIG_PCMCIA_XIRC2PS=y
CONFIG_FDDI=y
CONFIG_DEFXX=y
# CONFIG_DEFXX_MMIO is not set
CONFIG_SKFP=y
CONFIG_HIPPI=y
CONFIG_ROADRUNNER=y
# CONFIG_ROADRUNNER_LARGE_RINGS is not set
CONFIG_NET_SB1000=y
CONFIG_PHYLIB=y

#
# MII PHY device drivers
#
# CONFIG_AT803X_PHY is not set
# CONFIG_AMD_PHY is not set
CONFIG_MARVELL_PHY=y
CONFIG_DAVICOM_PHY=y
CONFIG_QSEMI_PHY=y
CONFIG_LXT_PHY=y
CONFIG_CICADA_PHY=y
CONFIG_VITESSE_PHY=y
CONFIG_SMSC_PHY=y
CONFIG_BROADCOM_PHY=y
# CONFIG_BCM87XX_PHY is not set
CONFIG_ICPLUS_PHY=y
CONFIG_REALTEK_PHY=y
CONFIG_NATIONAL_PHY=y
CONFIG_STE10XP=y
CONFIG_LSI_ET1011C_PHY=y
CONFIG_MICREL_PHY=y
# CONFIG_FIXED_PHY is not set
CONFIG_MDIO_BITBANG=y
# CONFIG_MDIO_GPIO is not set
# CONFIG_MICREL_KS8995MA is not set
CONFIG_PLIP=y
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_FILTER=y
CONFIG_PPP_MPPE=y
CONFIG_PPP_MULTILINK=y
CONFIG_PPPOATM=y
CONFIG_PPPOE=y
CONFIG_PPTP=y
CONFIG_PPPOL2TP=y
CONFIG_PPP_ASYNC=y
CONFIG_PPP_SYNC_TTY=y
CONFIG_SLIP=y
CONFIG_SLHC=y
CONFIG_SLIP_COMPRESSED=y
CONFIG_SLIP_SMART=y
CONFIG_SLIP_MODE_SLIP6=y

#
# USB Network Adapters
#
CONFIG_USB_CATC=y
CONFIG_USB_KAWETH=y
CONFIG_USB_PEGASUS=y
CONFIG_USB_RTL8150=y
CONFIG_USB_USBNET=y
CONFIG_USB_NET_AX8817X=y
CONFIG_USB_NET_AX88179_178A=y
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
# CONFIG_USB_NET_CDC_MBIM is not set
CONFIG_USB_NET_DM9601=y
CONFIG_USB_NET_SMSC75XX=y
CONFIG_USB_NET_SMSC95XX=y
CONFIG_USB_NET_GL620A=y
CONFIG_USB_NET_NET1080=y
CONFIG_USB_NET_PLUSB=y
CONFIG_USB_NET_MCS7830=y
CONFIG_USB_NET_RNDIS_HOST=y
CONFIG_USB_NET_CDC_SUBSET=y
CONFIG_USB_ALI_M5632=y
CONFIG_USB_AN2720=y
CONFIG_USB_BELKIN=y
CONFIG_USB_ARMLINUX=y
CONFIG_USB_EPSON2888=y
CONFIG_USB_KC2190=y
CONFIG_USB_NET_ZAURUS=y
CONFIG_USB_NET_CX82310_ETH=y
CONFIG_USB_NET_KALMIA=y
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_HSO=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
CONFIG_USB_VL600=y
CONFIG_WLAN=y
CONFIG_PCMCIA_RAYCS=y
CONFIG_LIBERTAS_THINFIRM=y
# CONFIG_LIBERTAS_THINFIRM_DEBUG is not set
CONFIG_LIBERTAS_THINFIRM_USB=y
CONFIG_AIRO=y
CONFIG_ATMEL=y
CONFIG_PCI_ATMEL=y
CONFIG_PCMCIA_ATMEL=y
CONFIG_AT76C50X_USB=y
CONFIG_AIRO_CS=y
CONFIG_PCMCIA_WL3501=y
# CONFIG_PRISM54 is not set
CONFIG_USB_ZD1201=y
CONFIG_USB_NET_RNDIS_WLAN=y
CONFIG_RTL8180=y
CONFIG_RTL8187=y
CONFIG_RTL8187_LEDS=y
CONFIG_ADM8211=y
CONFIG_MAC80211_HWSIM=y
CONFIG_MWL8K=y
# CONFIG_ATH_CARDS is not set
CONFIG_B43=y
CONFIG_B43_BCMA=y
# CONFIG_B43_BCMA_EXTRA is not set
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_BCMA_PIO=y
CONFIG_B43_PIO=y
CONFIG_B43_PHY_N=y
CONFIG_B43_PHY_LP=y
CONFIG_B43_PHY_HT=y
CONFIG_B43_LEDS=y
CONFIG_B43_HWRNG=y
# CONFIG_B43_DEBUG is not set
CONFIG_B43LEGACY=y
CONFIG_B43LEGACY_PCI_AUTOSELECT=y
CONFIG_B43LEGACY_PCICORE_AUTOSELECT=y
CONFIG_B43LEGACY_LEDS=y
CONFIG_B43LEGACY_HWRNG=y
CONFIG_B43LEGACY_DEBUG=y
CONFIG_B43LEGACY_DMA=y
CONFIG_B43LEGACY_PIO=y
CONFIG_B43LEGACY_DMA_AND_PIO_MODE=y
# CONFIG_B43LEGACY_DMA_MODE is not set
# CONFIG_B43LEGACY_PIO_MODE is not set
CONFIG_BRCMUTIL=y
CONFIG_BRCMSMAC=y
# CONFIG_BRCMFMAC is not set
# CONFIG_BRCM_TRACING is not set
# CONFIG_BRCMDBG is not set
CONFIG_HOSTAP=y
CONFIG_HOSTAP_FIRMWARE=y
# CONFIG_HOSTAP_FIRMWARE_NVRAM is not set
CONFIG_HOSTAP_PLX=y
CONFIG_HOSTAP_PCI=y
CONFIG_HOSTAP_CS=y
# CONFIG_IPW2100 is not set
CONFIG_IPW2200=y
CONFIG_IPW2200_MONITOR=y
CONFIG_IPW2200_RADIOTAP=y
CONFIG_IPW2200_PROMISCUOUS=y
CONFIG_IPW2200_QOS=y
# CONFIG_IPW2200_DEBUG is not set
CONFIG_LIBIPW=y
# CONFIG_LIBIPW_DEBUG is not set
CONFIG_IWLWIFI=y
CONFIG_IWLDVM=y
# CONFIG_IWLMVM is not set

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_IWLWIFI_P2P=y
CONFIG_IWLEGACY=y
CONFIG_IWL4965=y
CONFIG_IWL3945=y

#
# iwl3945 / iwl4965 Debugging Options
#
# CONFIG_IWLEGACY_DEBUG is not set
CONFIG_LIBERTAS=y
CONFIG_LIBERTAS_USB=y
CONFIG_LIBERTAS_CS=y
CONFIG_LIBERTAS_SDIO=y
CONFIG_LIBERTAS_SPI=y
# CONFIG_LIBERTAS_DEBUG is not set
CONFIG_LIBERTAS_MESH=y
CONFIG_HERMES=y
# CONFIG_HERMES_PRISM is not set
CONFIG_HERMES_CACHE_FW_ON_INIT=y
CONFIG_PLX_HERMES=y
CONFIG_TMD_HERMES=y
CONFIG_NORTEL_HERMES=y
CONFIG_PCMCIA_HERMES=y
CONFIG_PCMCIA_SPECTRUM=y
CONFIG_ORINOCO_USB=y
CONFIG_P54_COMMON=y
CONFIG_P54_USB=y
CONFIG_P54_PCI=y
CONFIG_P54_SPI=y
# CONFIG_P54_SPI_DEFAULT_EEPROM is not set
CONFIG_P54_LEDS=y
CONFIG_RT2X00=y
CONFIG_RT2400PCI=y
CONFIG_RT2500PCI=y
CONFIG_RT61PCI=y
CONFIG_RT2800PCI=y
CONFIG_RT2800PCI_RT33XX=y
CONFIG_RT2800PCI_RT35XX=y
CONFIG_RT2800PCI_RT53XX=y
CONFIG_RT2800PCI_RT3290=y
CONFIG_RT2500USB=y
CONFIG_RT73USB=y
CONFIG_RT2800USB=y
CONFIG_RT2800USB_RT33XX=y
CONFIG_RT2800USB_RT35XX=y
CONFIG_RT2800USB_RT53XX=y
# CONFIG_RT2800USB_RT55XX is not set
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
CONFIG_RTLWIFI=y
CONFIG_RTLWIFI_DEBUG=y
CONFIG_RTL8192CE=y
CONFIG_RTL8192SE=y
CONFIG_RTL8192DE=y
# CONFIG_RTL8723AE is not set
CONFIG_RTL8192CU=y
CONFIG_RTL8192C_COMMON=y
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
# CONFIG_ZD1211RW_DEBUG is not set
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
CONFIG_WAN=y
CONFIG_LANMEDIA=y
CONFIG_HDLC=y
CONFIG_HDLC_RAW=y
CONFIG_HDLC_RAW_ETH=y
CONFIG_HDLC_CISCO=y
CONFIG_HDLC_FR=y
CONFIG_HDLC_PPP=y
# CONFIG_HDLC_X25 is not set
CONFIG_PCI200SYN=y
CONFIG_WANXL=y
# CONFIG_PC300TOO is not set
CONFIG_FARSYNC=y
CONFIG_DSCC4=m
CONFIG_DSCC4_PCISYNC=y
CONFIG_DSCC4_PCI_RST=y
CONFIG_DLCI=y
CONFIG_DLCI_MAX=8
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_XEN_NETDEV_FRONTEND=y
CONFIG_XEN_NETDEV_BACKEND=y
CONFIG_VMXNET3=y
CONFIG_HYPERV_NET=y
CONFIG_ISDN=y
# CONFIG_ISDN_I4L is not set
CONFIG_ISDN_CAPI=y
CONFIG_ISDN_DRV_AVMB1_VERBOSE_REASON=y
CONFIG_CAPI_TRACE=y
CONFIG_ISDN_CAPI_MIDDLEWARE=y
CONFIG_ISDN_CAPI_CAPI20=y

#
# CAPI hardware drivers
#
CONFIG_CAPI_AVM=y
CONFIG_ISDN_DRV_AVMB1_B1PCI=y
CONFIG_ISDN_DRV_AVMB1_B1PCIV4=y
CONFIG_ISDN_DRV_AVMB1_B1PCMCIA=y
CONFIG_ISDN_DRV_AVMB1_AVM_CS=y
CONFIG_ISDN_DRV_AVMB1_T1PCI=y
CONFIG_ISDN_DRV_AVMB1_C4=y
# CONFIG_CAPI_EICON is not set
CONFIG_ISDN_DRV_GIGASET=y
CONFIG_GIGASET_CAPI=y
# CONFIG_GIGASET_DUMMYLL is not set
CONFIG_GIGASET_BASE=y
CONFIG_GIGASET_M105=y
CONFIG_GIGASET_M101=y
# CONFIG_GIGASET_DEBUG is not set
CONFIG_HYSDN=m
CONFIG_HYSDN_CAPI=y
CONFIG_MISDN=y
CONFIG_MISDN_DSP=y
CONFIG_MISDN_L1OIP=y

#
# mISDN hardware drivers
#
CONFIG_MISDN_HFCPCI=y
CONFIG_MISDN_HFCMULTI=y
CONFIG_MISDN_HFCUSB=y
CONFIG_MISDN_AVMFRITZ=y
CONFIG_MISDN_SPEEDFAX=y
CONFIG_MISDN_INFINEON=y
CONFIG_MISDN_W6692=y
# CONFIG_MISDN_NETJET is not set
CONFIG_MISDN_IPAC=y
CONFIG_MISDN_ISAR=y

#
# Input device support
#
CONFIG_INPUT=y
CONFIG_INPUT_FF_MEMLESS=y
CONFIG_INPUT_POLLDEV=y
CONFIG_INPUT_SPARSEKMAP=y
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
CONFIG_INPUT_JOYDEV=y
CONFIG_INPUT_EVDEV=y
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ADP5588=y
# CONFIG_KEYBOARD_ADP5589 is not set
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_QT1070 is not set
CONFIG_KEYBOARD_QT2160=y
CONFIG_KEYBOARD_LKKBD=y
# CONFIG_KEYBOARD_GPIO is not set
# CONFIG_KEYBOARD_GPIO_POLLED is not set
# CONFIG_KEYBOARD_TCA6416 is not set
# CONFIG_KEYBOARD_TCA8418 is not set
# CONFIG_KEYBOARD_MATRIX is not set
CONFIG_KEYBOARD_LM8323=y
# CONFIG_KEYBOARD_LM8333 is not set
CONFIG_KEYBOARD_MAX7359=y
# CONFIG_KEYBOARD_MCS is not set
# CONFIG_KEYBOARD_MPR121 is not set
CONFIG_KEYBOARD_NEWTON=y
CONFIG_KEYBOARD_OPENCORES=y
CONFIG_KEYBOARD_STOWAWAY=y
CONFIG_KEYBOARD_SUNKBD=y
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
# CONFIG_MOUSE_CYAPA is not set
CONFIG_MOUSE_VSXXXAA=y
# CONFIG_MOUSE_GPIO is not set
CONFIG_MOUSE_SYNAPTICS_I2C=y
# CONFIG_MOUSE_SYNAPTICS_USB is not set
CONFIG_INPUT_JOYSTICK=y
CONFIG_JOYSTICK_ANALOG=y
CONFIG_JOYSTICK_A3D=y
CONFIG_JOYSTICK_ADI=y
CONFIG_JOYSTICK_COBRA=y
CONFIG_JOYSTICK_GF2K=y
CONFIG_JOYSTICK_GRIP=y
CONFIG_JOYSTICK_GRIP_MP=y
CONFIG_JOYSTICK_GUILLEMOT=y
CONFIG_JOYSTICK_INTERACT=y
CONFIG_JOYSTICK_SIDEWINDER=y
CONFIG_JOYSTICK_TMDC=y
CONFIG_JOYSTICK_IFORCE=y
CONFIG_JOYSTICK_IFORCE_USB=y
CONFIG_JOYSTICK_IFORCE_232=y
CONFIG_JOYSTICK_WARRIOR=y
CONFIG_JOYSTICK_MAGELLAN=y
CONFIG_JOYSTICK_SPACEORB=y
CONFIG_JOYSTICK_SPACEBALL=y
CONFIG_JOYSTICK_STINGER=y
CONFIG_JOYSTICK_TWIDJOY=y
CONFIG_JOYSTICK_ZHENHUA=y
CONFIG_JOYSTICK_DB9=y
CONFIG_JOYSTICK_GAMECON=y
CONFIG_JOYSTICK_TURBOGRAFX=y
# CONFIG_JOYSTICK_AS5011 is not set
CONFIG_JOYSTICK_JOYDUMP=y
CONFIG_JOYSTICK_XPAD=y
CONFIG_JOYSTICK_XPAD_FF=y
CONFIG_JOYSTICK_XPAD_LEDS=y
CONFIG_JOYSTICK_WALKERA0701=y
CONFIG_INPUT_TABLET=y
CONFIG_TABLET_USB_ACECAD=y
CONFIG_TABLET_USB_AIPTEK=y
CONFIG_TABLET_USB_GTCO=y
CONFIG_TABLET_USB_HANWANG=y
CONFIG_TABLET_USB_KBTAB=y
CONFIG_TABLET_USB_WACOM=y
CONFIG_INPUT_TOUCHSCREEN=y
CONFIG_TOUCHSCREEN_ADS7846=y
CONFIG_TOUCHSCREEN_AD7877=y
CONFIG_TOUCHSCREEN_AD7879=y
CONFIG_TOUCHSCREEN_AD7879_I2C=y
# CONFIG_TOUCHSCREEN_AD7879_SPI is not set
# CONFIG_TOUCHSCREEN_ATMEL_MXT is not set
# CONFIG_TOUCHSCREEN_AUO_PIXCIR is not set
# CONFIG_TOUCHSCREEN_BU21013 is not set
# CONFIG_TOUCHSCREEN_CY8CTMG110 is not set
# CONFIG_TOUCHSCREEN_CYTTSP_CORE is not set
CONFIG_TOUCHSCREEN_DYNAPRO=y
CONFIG_TOUCHSCREEN_HAMPSHIRE=y
CONFIG_TOUCHSCREEN_EETI=y
CONFIG_TOUCHSCREEN_FUJITSU=y
# CONFIG_TOUCHSCREEN_ILI210X is not set
CONFIG_TOUCHSCREEN_GUNZE=y
CONFIG_TOUCHSCREEN_ELO=y
CONFIG_TOUCHSCREEN_WACOM_W8001=y
# CONFIG_TOUCHSCREEN_WACOM_I2C is not set
# CONFIG_TOUCHSCREEN_MAX11801 is not set
CONFIG_TOUCHSCREEN_MCS5000=y
# CONFIG_TOUCHSCREEN_MMS114 is not set
CONFIG_TOUCHSCREEN_MTOUCH=y
CONFIG_TOUCHSCREEN_INEXIO=y
CONFIG_TOUCHSCREEN_MK712=y
CONFIG_TOUCHSCREEN_PENMOUNT=y
# CONFIG_TOUCHSCREEN_EDT_FT5X06 is not set
CONFIG_TOUCHSCREEN_TOUCHRIGHT=y
CONFIG_TOUCHSCREEN_TOUCHWIN=y
# CONFIG_TOUCHSCREEN_PIXCIR is not set
CONFIG_TOUCHSCREEN_WM97XX=y
CONFIG_TOUCHSCREEN_WM9705=y
CONFIG_TOUCHSCREEN_WM9712=y
CONFIG_TOUCHSCREEN_WM9713=y
CONFIG_TOUCHSCREEN_USB_COMPOSITE=y
CONFIG_TOUCHSCREEN_USB_EGALAX=y
CONFIG_TOUCHSCREEN_USB_PANJIT=y
CONFIG_TOUCHSCREEN_USB_3M=y
CONFIG_TOUCHSCREEN_USB_ITM=y
CONFIG_TOUCHSCREEN_USB_ETURBO=y
CONFIG_TOUCHSCREEN_USB_GUNZE=y
CONFIG_TOUCHSCREEN_USB_DMC_TSC10=y
CONFIG_TOUCHSCREEN_USB_IRTOUCH=y
CONFIG_TOUCHSCREEN_USB_IDEALTEK=y
CONFIG_TOUCHSCREEN_USB_GENERAL_TOUCH=y
CONFIG_TOUCHSCREEN_USB_GOTOP=y
CONFIG_TOUCHSCREEN_USB_JASTEC=y
CONFIG_TOUCHSCREEN_USB_ELO=y
CONFIG_TOUCHSCREEN_USB_E2I=y
CONFIG_TOUCHSCREEN_USB_ZYTRONIC=y
CONFIG_TOUCHSCREEN_USB_ETT_TC45USB=y
CONFIG_TOUCHSCREEN_USB_NEXIO=y
CONFIG_TOUCHSCREEN_USB_EASYTOUCH=y
CONFIG_TOUCHSCREEN_TOUCHIT213=y
# CONFIG_TOUCHSCREEN_TSC_SERIO is not set
# CONFIG_TOUCHSCREEN_TSC2005 is not set
CONFIG_TOUCHSCREEN_TSC2007=y
# CONFIG_TOUCHSCREEN_ST1232 is not set
CONFIG_TOUCHSCREEN_TPS6507X=y
CONFIG_INPUT_MISC=y
# CONFIG_INPUT_AD714X is not set
# CONFIG_INPUT_BMA150 is not set
CONFIG_INPUT_PCSPKR=y
# CONFIG_INPUT_MMA8450 is not set
# CONFIG_INPUT_MPU3050 is not set
CONFIG_INPUT_APANEL=y
# CONFIG_INPUT_GP2A is not set
# CONFIG_INPUT_GPIO_TILT_POLLED is not set
CONFIG_INPUT_ATLAS_BTNS=y
CONFIG_INPUT_ATI_REMOTE2=y
CONFIG_INPUT_KEYSPAN_REMOTE=y
# CONFIG_INPUT_KXTJ9 is not set
CONFIG_INPUT_POWERMATE=y
CONFIG_INPUT_YEALINK=y
CONFIG_INPUT_CM109=y
CONFIG_INPUT_UINPUT=y
CONFIG_INPUT_PCF50633_PMU=y
# CONFIG_INPUT_PCF8574 is not set
# CONFIG_INPUT_GPIO_ROTARY_ENCODER is not set
# CONFIG_INPUT_ADXL34X is not set
# CONFIG_INPUT_CMA3000 is not set
CONFIG_INPUT_XEN_KBDDEV_FRONTEND=y

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
CONFIG_SERIO_CT82C710=y
CONFIG_SERIO_PARKBD=y
CONFIG_SERIO_PCIPS2=y
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
# CONFIG_SERIO_PS2MULT is not set
# CONFIG_SERIO_ARC_PS2 is not set
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
CONFIG_TTY=y
CONFIG_VT=y
CONFIG_CONSOLE_TRANSLATIONS=y
CONFIG_VT_CONSOLE=y
CONFIG_VT_CONSOLE_SLEEP=y
CONFIG_HW_CONSOLE=y
CONFIG_VT_HW_CONSOLE_BINDING=y
CONFIG_UNIX98_PTYS=y
CONFIG_DEVPTS_MULTIPLE_INSTANCES=y
# CONFIG_LEGACY_PTYS is not set
CONFIG_SERIAL_NONSTANDARD=y
CONFIG_ROCKETPORT=y
CONFIG_CYCLADES=y
# CONFIG_CYZ_INTR is not set
CONFIG_MOXA_INTELLIO=y
CONFIG_MOXA_SMARTIO=y
CONFIG_SYNCLINK=y
CONFIG_SYNCLINKMP=y
CONFIG_SYNCLINK_GT=y
CONFIG_NOZOMI=y
CONFIG_ISI=y
CONFIG_N_HDLC=y
CONFIG_N_GSM=y
# CONFIG_TRACE_SINK is not set
# CONFIG_DEVKMEM is not set
CONFIG_STALDRV=y

#
# Serial drivers
#
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_DMA=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX310X is not set
CONFIG_SERIAL_MFD_HSU=y
# CONFIG_SERIAL_MFD_HSU_CONSOLE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
CONFIG_SERIAL_PCH_UART=y
# CONFIG_SERIAL_PCH_UART_CONSOLE is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
CONFIG_PRINTER=y
# CONFIG_LP_CONSOLE is not set
CONFIG_PPDEV=y
CONFIG_HVC_DRIVER=y
CONFIG_HVC_IRQ=y
CONFIG_HVC_XEN=y
CONFIG_HVC_XEN_FRONTEND=y
CONFIG_VIRTIO_CONSOLE=y
CONFIG_IPMI_HANDLER=y
# CONFIG_IPMI_PANIC_EVENT is not set
CONFIG_IPMI_DEVICE_INTERFACE=y
CONFIG_IPMI_SI=y
CONFIG_IPMI_WATCHDOG=y
CONFIG_IPMI_POWEROFF=y
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
CONFIG_HW_RANDOM_VIA=y
CONFIG_HW_RANDOM_VIRTIO=y
CONFIG_HW_RANDOM_TPM=y
CONFIG_NVRAM=y
CONFIG_R3964=y
CONFIG_APPLICOM=y

#
# PCMCIA character devices
#
CONFIG_SYNCLINK_CS=y
CONFIG_CARDMAN_4000=y
CONFIG_CARDMAN_4040=y
CONFIG_IPWIRELESS=y
CONFIG_MWAVE=y
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
CONFIG_HPET=y
CONFIG_HPET_MMAP=y
CONFIG_HANGCHECK_TIMER=y
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
# CONFIG_TCG_TIS_I2C_INFINEON is not set
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
# CONFIG_TCG_ST33_I2C is not set
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
CONFIG_I2C_ALI1563=y
CONFIG_I2C_ALI15X3=y
CONFIG_I2C_AMD756=y
CONFIG_I2C_AMD756_S4882=y
CONFIG_I2C_AMD8111=y
CONFIG_I2C_I801=y
CONFIG_I2C_ISCH=y
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
CONFIG_I2C_NFORCE2=y
CONFIG_I2C_NFORCE2_S4985=y
CONFIG_I2C_SIS5595=y
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
CONFIG_I2C_VIA=y
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
CONFIG_I2C_SCMI=y

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
# CONFIG_I2C_CBUS_GPIO is not set
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
# CONFIG_I2C_GPIO is not set
# CONFIG_I2C_INTEL_MID is not set
CONFIG_I2C_OCORES=y
CONFIG_I2C_PCA_PLATFORM=y
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
# CONFIG_I2C_XILINX is not set

#
# External I2C/SMBus adapter drivers
#
CONFIG_I2C_DIOLAN_U2C=y
CONFIG_I2C_PARPORT=y
CONFIG_I2C_PARPORT_LIGHT=y
CONFIG_I2C_TAOS_EVM=y
CONFIG_I2C_TINY_USB=y

#
# Other I2C/SMBus bus drivers
#
CONFIG_I2C_STUB=m
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
CONFIG_SPI=y
# CONFIG_SPI_DEBUG is not set
CONFIG_SPI_MASTER=y

#
# SPI Master Controller Drivers
#
# CONFIG_SPI_ALTERA is not set
CONFIG_SPI_BITBANG=y
CONFIG_SPI_BUTTERFLY=y
# CONFIG_SPI_GPIO is not set
CONFIG_SPI_LM70_LLP=y
# CONFIG_SPI_OC_TINY is not set
# CONFIG_SPI_PXA2XX is not set
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_SC18IS602 is not set
CONFIG_SPI_TOPCLIFF_PCH=y
# CONFIG_SPI_XCOMM is not set
# CONFIG_SPI_XILINX is not set
# CONFIG_SPI_DESIGNWARE is not set

#
# SPI Protocol Masters
#
# CONFIG_SPI_SPIDEV is not set
CONFIG_SPI_TLE62X0=y
# CONFIG_HSI is not set

#
# PPS support
#
CONFIG_PPS=y
# CONFIG_PPS_DEBUG is not set

#
# PPS clients support
#
# CONFIG_PPS_CLIENT_KTIMER is not set
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
CONFIG_GPIO_DEVRES=y
CONFIG_GPIOLIB=y
CONFIG_GPIO_ACPI=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_TS5500 is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
# CONFIG_GPIO_MAX7300 is not set
# CONFIG_GPIO_MAX732X is not set
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_ADP5588 is not set

#
# PCI GPIO expanders:
#
# CONFIG_GPIO_BT8XX is not set
# CONFIG_GPIO_AMD8111 is not set
# CONFIG_GPIO_LANGWELL is not set
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MAX7301 is not set
# CONFIG_GPIO_MCP23S08 is not set
# CONFIG_GPIO_MC33880 is not set
# CONFIG_GPIO_74X164 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#

#
# USB GPIO expanders:
#
CONFIG_W1=y
CONFIG_W1_CON=y

#
# 1-wire Bus Masters
#
CONFIG_W1_MASTER_MATROX=y
CONFIG_W1_MASTER_DS2490=y
CONFIG_W1_MASTER_DS2482=y
# CONFIG_W1_MASTER_DS1WM is not set
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
CONFIG_W1_SLAVE_DS2433=y
# CONFIG_W1_SLAVE_DS2433_CRC is not set
CONFIG_W1_SLAVE_DS2760=y
# CONFIG_W1_SLAVE_DS2780 is not set
# CONFIG_W1_SLAVE_DS2781 is not set
# CONFIG_W1_SLAVE_DS28E04 is not set
CONFIG_W1_SLAVE_BQ27000=y
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
CONFIG_PDA_POWER=y
# CONFIG_TEST_POWER is not set
CONFIG_BATTERY_DS2760=y
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
CONFIG_BATTERY_DS2782=y
# CONFIG_BATTERY_WM97XX is not set
# CONFIG_BATTERY_SBS is not set
CONFIG_BATTERY_BQ27x00=y
CONFIG_BATTERY_BQ27X00_I2C=y
CONFIG_BATTERY_BQ27X00_PLATFORM=y
CONFIG_BATTERY_MAX17040=y
# CONFIG_BATTERY_MAX17042 is not set
CONFIG_CHARGER_PCF50633=y
# CONFIG_CHARGER_ISP1704 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_MANAGER is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
# CONFIG_POWER_AVS is not set
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
# CONFIG_HWMON_DEBUG_CHIP is not set

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
CONFIG_SENSORS_ABITUGURU3=y
# CONFIG_SENSORS_AD7314 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
CONFIG_SENSORS_ADCXX=y
CONFIG_SENSORS_ADM1021=y
CONFIG_SENSORS_ADM1025=y
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
# CONFIG_SENSORS_ADT7410 is not set
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
CONFIG_SENSORS_FAM15H_POWER=y
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
CONFIG_SENSORS_DS620=y
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
CONFIG_SENSORS_FSCHMD=y
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
# CONFIG_SENSORS_GPIO_FAN is not set
# CONFIG_SENSORS_HIH6130 is not set
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IBMAEM=y
CONFIG_SENSORS_IBMPEX=y
CONFIG_SENSORS_IT87=y
# CONFIG_SENSORS_JC42 is not set
CONFIG_SENSORS_LINEAGE=y
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM70=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
CONFIG_SENSORS_LM83=y
CONFIG_SENSORS_LM85=y
CONFIG_SENSORS_LM87=y
CONFIG_SENSORS_LM90=y
CONFIG_SENSORS_LM92=y
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95241=y
CONFIG_SENSORS_LM95245=y
CONFIG_SENSORS_MAX1111=y
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
# CONFIG_SENSORS_MAX197 is not set
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NTC_THERMISTOR=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
CONFIG_SENSORS_SHT21=y
CONFIG_SENSORS_SIS5595=y
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
CONFIG_SENSORS_SCH5627=y
# CONFIG_SENSORS_SCH5636 is not set
CONFIG_SENSORS_ADS1015=y
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
# CONFIG_SENSORS_INA209 is not set
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
CONFIG_SENSORS_TMP421=y
CONFIG_SENSORS_VIA_CPUTEMP=y
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
# CONFIG_SENSORS_W83795_FANCTRL is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
CONFIG_SENSORS_ACPI_POWER=y
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
CONFIG_THERMAL_DEFAULT_GOV_STEP_WISE=y
# CONFIG_THERMAL_DEFAULT_GOV_FAIR_SHARE is not set
# CONFIG_THERMAL_DEFAULT_GOV_USER_SPACE is not set
# CONFIG_THERMAL_GOV_FAIR_SHARE is not set
CONFIG_THERMAL_GOV_STEP_WISE=y
# CONFIG_THERMAL_GOV_USER_SPACE is not set
# CONFIG_CPU_THERMAL is not set
# CONFIG_THERMAL_EMULATION is not set
# CONFIG_INTEL_POWERCLAMP is not set
CONFIG_WATCHDOG=y
CONFIG_WATCHDOG_CORE=y
# CONFIG_WATCHDOG_NOWAYOUT is not set

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
CONFIG_ACQUIRE_WDT=y
CONFIG_ADVANTECH_WDT=y
CONFIG_ALIM1535_WDT=y
CONFIG_ALIM7101_WDT=y
CONFIG_F71808E_WDT=y
CONFIG_SP5100_TCO=y
CONFIG_SC520_WDT=y
CONFIG_SBC_FITPC2_WATCHDOG=y
# CONFIG_EUROTECH_WDT is not set
CONFIG_IB700_WDT=y
CONFIG_IBMASR=y
CONFIG_WAFER_WDT=y
CONFIG_I6300ESB_WDT=y
# CONFIG_IE6XX_WDT is not set
CONFIG_ITCO_WDT=y
CONFIG_ITCO_VENDOR_SUPPORT=y
CONFIG_IT8712F_WDT=y
CONFIG_IT87_WDT=y
CONFIG_HP_WATCHDOG=y
CONFIG_HPWDT_NMI_DECODING=y
CONFIG_SC1200_WDT=y
CONFIG_PC87413_WDT=y
CONFIG_NV_TCO=y
CONFIG_60XX_WDT=y
CONFIG_SBC8360_WDT=y
CONFIG_CPU5_WDT=y
CONFIG_SMSC_SCH311X_WDT=y
CONFIG_SMSC37B787_WDT=y
# CONFIG_VIA_WDT is not set
CONFIG_W83627HF_WDT=y
CONFIG_W83697HF_WDT=y
CONFIG_W83697UG_WDT=y
CONFIG_W83877F_WDT=y
CONFIG_W83977F_WDT=y
CONFIG_MACHZ_WDT=y
CONFIG_SBC_EPX_C3_WATCHDOG=y
CONFIG_XEN_WDT=y

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y

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
CONFIG_SSB_BLOCKIO=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
CONFIG_SSB_PCIHOST=y
CONFIG_SSB_B43_PCI_BRIDGE=y
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
# CONFIG_SSB_DEBUG is not set
CONFIG_SSB_DRIVER_PCICORE_POSSIBLE=y
CONFIG_SSB_DRIVER_PCICORE=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_BLOCKIO=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
# CONFIG_BCMA_DRIVER_GMAC_CMN is not set
# CONFIG_BCMA_DRIVER_GPIO is not set
# CONFIG_BCMA_DEBUG is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
# CONFIG_MFD_RTSX_PCI is not set
# CONFIG_MFD_TI_AM335X_TSCADC is not set
CONFIG_HTC_PASIC3=y
# CONFIG_HTC_I2CPLD is not set
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_LM3533 is not set
# CONFIG_TPS6105X is not set
CONFIG_TPS65010=y
# CONFIG_TPS6507X is not set
# CONFIG_MFD_TPS65217 is not set
# CONFIG_MFD_TPS6586X is not set
# CONFIG_MFD_TPS65910 is not set
# CONFIG_MFD_TPS65912_I2C is not set
# CONFIG_MFD_TPS65912_SPI is not set
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_MFD_SMSC is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_MFD_DA9055 is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_LP8788 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
# CONFIG_MFD_MAX8907 is not set
# CONFIG_MFD_MAX8925 is not set
# CONFIG_MFD_MAX8997 is not set
# CONFIG_MFD_MAX8998 is not set
# CONFIG_MFD_SEC_CORE is not set
# CONFIG_MFD_ARIZONA_I2C is not set
# CONFIG_MFD_ARIZONA_SPI is not set
CONFIG_MFD_WM8400=y
# CONFIG_MFD_WM831X_I2C is not set
# CONFIG_MFD_WM831X_SPI is not set
# CONFIG_MFD_WM8350_I2C is not set
# CONFIG_MFD_WM8994 is not set
CONFIG_MFD_PCF50633=y
CONFIG_PCF50633_ADC=y
CONFIG_PCF50633_GPIO=y
# CONFIG_MFD_MC13XXX_SPI is not set
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_ABX500_CORE is not set
# CONFIG_EZX_PCAP is not set
# CONFIG_MFD_CS5535 is not set
# CONFIG_MFD_TIMBERDALE is not set
CONFIG_LPC_SCH=y
CONFIG_LPC_ICH=y
# CONFIG_MFD_RDC321X is not set
# CONFIG_MFD_JANZ_CMODIO is not set
# CONFIG_MFD_VX855 is not set
CONFIG_MFD_WL1273_CORE=y
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
# CONFIG_MFD_VIPERBOARD is not set
# CONFIG_MFD_RETU is not set
# CONFIG_MFD_AS3711 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_FAN53555 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8952 is not set
# CONFIG_REGULATOR_MAX8973 is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_PCF50633=y
# CONFIG_REGULATOR_TPS51632 is not set
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
CONFIG_REGULATOR_TPS6507X=y
# CONFIG_REGULATOR_TPS6524X is not set
CONFIG_REGULATOR_WM8400=y
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
# CONFIG_MEDIA_ANALOG_TV_SUPPORT is not set
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
# CONFIG_MEDIA_RADIO_SUPPORT is not set
# CONFIG_MEDIA_RC_SUPPORT is not set
# CONFIG_VIDEO_ADV_DEBUG is not set
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
# CONFIG_MEDIA_USB_SUPPORT is not set
# CONFIG_MEDIA_PCI_SUPPORT is not set

#
# Supported MMC/SDIO adapters
#

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#

#
# Customise DVB Frontends
#
CONFIG_DVB_TUNER_DIB0070=y
CONFIG_DVB_TUNER_DIB0090=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
CONFIG_AGP=y
CONFIG_AGP_AMD64=y
CONFIG_AGP_INTEL=y
CONFIG_AGP_SIS=y
CONFIG_AGP_VIA=y
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
CONFIG_VGA_SWITCHEROO=y
CONFIG_DRM=y
CONFIG_DRM_KMS_HELPER=y
# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set
# CONFIG_DRM_TTM is not set

#
# I2C encoder or helper chips
#
CONFIG_DRM_I2C_CH7006=y
CONFIG_DRM_I2C_SIL164=y
# CONFIG_DRM_I2C_NXP_TDA998X is not set
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
# CONFIG_DRM_RADEON_UMS is not set
CONFIG_DRM_NOUVEAU=y
CONFIG_NOUVEAU_DEBUG=5
CONFIG_NOUVEAU_DEBUG_DEFAULT=3
CONFIG_DRM_NOUVEAU_BACKLIGHT=y
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
CONFIG_DRM_VMWGFX=y
# CONFIG_DRM_VMWGFX_FBCON is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
CONFIG_VGASTATE=y
CONFIG_VIDEO_OUTPUT_CONTROL=y
CONFIG_HDMI=y
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
CONFIG_FB_SVGALIB=y
# CONFIG_FB_MACMODES is not set
CONFIG_FB_BACKLIGHT=y
CONFIG_FB_MODE_HELPERS=y
CONFIG_FB_TILEBLITTING=y

#
# Frame buffer hardware drivers
#
# CONFIG_FB_CIRRUS is not set
CONFIG_FB_PM2=y
CONFIG_FB_PM2_FIFO_DISCONNECT=y
CONFIG_FB_CYBER2000=y
CONFIG_FB_CYBER2000_DDC=y
CONFIG_FB_ARC=y
# CONFIG_FB_ASILIANT is not set
# CONFIG_FB_IMSTT is not set
# CONFIG_FB_VGA16 is not set
CONFIG_FB_UVESA=y
CONFIG_FB_VESA=y
CONFIG_FB_EFI=y
CONFIG_FB_N411=y
CONFIG_FB_HGA=y
CONFIG_FB_S1D13XXX=y
CONFIG_FB_NVIDIA=y
# CONFIG_FB_NVIDIA_I2C is not set
# CONFIG_FB_NVIDIA_DEBUG is not set
CONFIG_FB_NVIDIA_BACKLIGHT=y
# CONFIG_FB_RIVA is not set
# CONFIG_FB_I740 is not set
CONFIG_FB_LE80578=y
CONFIG_FB_CARILLO_RANCH=y
CONFIG_FB_MATROX=y
CONFIG_FB_MATROX_MILLENIUM=y
CONFIG_FB_MATROX_MYSTIQUE=y
CONFIG_FB_MATROX_G=y
CONFIG_FB_MATROX_I2C=y
CONFIG_FB_MATROX_MAVEN=y
CONFIG_FB_RADEON=y
CONFIG_FB_RADEON_I2C=y
CONFIG_FB_RADEON_BACKLIGHT=y
# CONFIG_FB_RADEON_DEBUG is not set
CONFIG_FB_ATY128=y
CONFIG_FB_ATY128_BACKLIGHT=y
CONFIG_FB_ATY=y
CONFIG_FB_ATY_CT=y
# CONFIG_FB_ATY_GENERIC_LCD is not set
CONFIG_FB_ATY_GX=y
CONFIG_FB_ATY_BACKLIGHT=y
CONFIG_FB_S3=y
CONFIG_FB_S3_DDC=y
CONFIG_FB_SAVAGE=y
# CONFIG_FB_SAVAGE_I2C is not set
# CONFIG_FB_SAVAGE_ACCEL is not set
CONFIG_FB_SIS=y
CONFIG_FB_SIS_300=y
CONFIG_FB_SIS_315=y
CONFIG_FB_VIA=y
# CONFIG_FB_VIA_DIRECT_PROCFS is not set
CONFIG_FB_VIA_X_COMPATIBILITY=y
CONFIG_FB_NEOMAGIC=y
CONFIG_FB_KYRO=y
CONFIG_FB_3DFX=y
# CONFIG_FB_3DFX_ACCEL is not set
CONFIG_FB_3DFX_I2C=y
CONFIG_FB_VOODOO1=y
CONFIG_FB_VT8623=y
CONFIG_FB_TRIDENT=y
CONFIG_FB_ARK=y
CONFIG_FB_PM3=y
# CONFIG_FB_CARMINE is not set
# CONFIG_FB_GEODE is not set
# CONFIG_FB_TMIO is not set
CONFIG_FB_SM501=y
# CONFIG_FB_SMSCUFX is not set
CONFIG_FB_UDL=y
# CONFIG_FB_GOLDFISH is not set
CONFIG_FB_VIRTUAL=y
CONFIG_XEN_FBDEV_FRONTEND=y
CONFIG_FB_METRONOME=y
CONFIG_FB_MB862XX=y
CONFIG_FB_MB862XX_PCI_GDC=y
CONFIG_FB_MB862XX_I2C=y
# CONFIG_FB_BROADSHEET is not set
# CONFIG_FB_AUO_K190X is not set
# CONFIG_EXYNOS_VIDEO is not set
CONFIG_BACKLIGHT_LCD_SUPPORT=y
# CONFIG_LCD_CLASS_DEVICE is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_APPLE=y
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
# CONFIG_BACKLIGHT_LM3630 is not set
# CONFIG_BACKLIGHT_LM3639 is not set
# CONFIG_BACKLIGHT_LP855X is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
# CONFIG_VGACON_SOFT_SCROLLBACK is not set
CONFIG_DUMMY_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
CONFIG_FRAMEBUFFER_CONSOLE_ROTATION=y
# CONFIG_FONTS is not set
CONFIG_FONT_8x8=y
CONFIG_FONT_8x16=y
# CONFIG_LOGO is not set
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
CONFIG_SND_HWDEP=y
CONFIG_SND_RAWMIDI=y
CONFIG_SND_JACK=y
CONFIG_SND_SEQUENCER=y
CONFIG_SND_SEQ_DUMMY=y
CONFIG_SND_OSSEMUL=y
CONFIG_SND_MIXER_OSS=y
CONFIG_SND_PCM_OSS=y
CONFIG_SND_PCM_OSS_PLUGINS=y
# CONFIG_SND_SEQUENCER_OSS is not set
CONFIG_SND_HRTIMER=y
CONFIG_SND_SEQ_HRTIMER_DEFAULT=y
CONFIG_SND_DYNAMIC_MINORS=y
CONFIG_SND_SUPPORT_OLD_API=y
CONFIG_SND_VERBOSE_PROCFS=y
# CONFIG_SND_VERBOSE_PRINTK is not set
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
CONFIG_SND_DRIVERS=y
CONFIG_SND_PCSP=y
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
CONFIG_SND_MTS64=y
CONFIG_SND_SERIAL_U16550=y
CONFIG_SND_MPU401=y
CONFIG_SND_PORTMAN2X4=y
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
CONFIG_SND_ALI5451=y
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
CONFIG_SND_ATIIXP_MODEM=y
CONFIG_SND_AU8810=y
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
# CONFIG_SND_AW2 is not set
CONFIG_SND_AZT3328=y
CONFIG_SND_BT87X=y
# CONFIG_SND_BT87X_OVERCLOCK is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
CONFIG_SND_OXYGEN=y
CONFIG_SND_CS4281=y
CONFIG_SND_CS46XX=y
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CS5530=y
CONFIG_SND_CS5535AUDIO=y
CONFIG_SND_CTXFI=y
CONFIG_SND_DARLA20=y
CONFIG_SND_GINA20=y
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
CONFIG_SND_MONA=y
CONFIG_SND_MIA=y
CONFIG_SND_ECHO3G=y
CONFIG_SND_INDIGO=y
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
CONFIG_SND_INDIGOIOX=y
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
CONFIG_SND_ES1938=y
CONFIG_SND_ES1968=y
CONFIG_SND_ES1968_INPUT=y
CONFIG_SND_FM801=y
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
CONFIG_SND_HDA_INPUT_BEEP=y
CONFIG_SND_HDA_INPUT_BEEP_MODE=1
CONFIG_SND_HDA_INPUT_JACK=y
CONFIG_SND_HDA_PATCH_LOADER=y
CONFIG_SND_HDA_CODEC_REALTEK=y
CONFIG_SND_HDA_CODEC_ANALOG=y
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
CONFIG_SND_HDA_CODEC_HDMI=y
CONFIG_SND_HDA_CODEC_CIRRUS=y
CONFIG_SND_HDA_CODEC_CONEXANT=y
CONFIG_SND_HDA_CODEC_CA0110=y
CONFIG_SND_HDA_CODEC_CA0132=y
# CONFIG_SND_HDA_CODEC_CA0132_DSP is not set
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
CONFIG_SND_HDSPM=y
CONFIG_SND_ICE1712=y
CONFIG_SND_ICE1724=y
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
CONFIG_SND_KORG1212=y
CONFIG_SND_LOLA=y
CONFIG_SND_LX6464ES=y
CONFIG_SND_MAESTRO3=y
CONFIG_SND_MAESTRO3_INPUT=y
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
CONFIG_SND_PCXHR=y
CONFIG_SND_RIPTIDE=y
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
CONFIG_SND_RME9652=y
CONFIG_SND_SONICVIBES=y
CONFIG_SND_TRIDENT=y
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y
CONFIG_SND_SPI=y
CONFIG_SND_USB=y
CONFIG_SND_USB_AUDIO=y
CONFIG_SND_USB_UA101=y
CONFIG_SND_USB_USX2Y=y
CONFIG_SND_USB_CAIAQ=y
CONFIG_SND_USB_CAIAQ_INPUT=y
CONFIG_SND_USB_US122L=y
CONFIG_SND_USB_6FIRE=y
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
CONFIG_SND_FIREWIRE_SPEAKERS=y
CONFIG_SND_ISIGHT=y
# CONFIG_SND_SCS1X is not set
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
# CONFIG_SND_SOC is not set
# CONFIG_SOUND_PRIME is not set
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
CONFIG_HID_BATTERY_STRENGTH=y
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
CONFIG_HID_ACRUX=y
# CONFIG_HID_ACRUX_FF is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
CONFIG_HID_EMS_FF=y
CONFIG_HID_ELECOM=y
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
CONFIG_HID_KEYTOUCH=y
CONFIG_HID_KYE=y
CONFIG_HID_UCLOGIC=y
CONFIG_HID_WALTOP=y
CONFIG_HID_GYRATION=y
# CONFIG_HID_ICADE is not set
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
CONFIG_HID_LCPOWER=y
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=y
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
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
CONFIG_HID_PICOLCD_LEDS=y
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_PS3REMOTE is not set
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
# CONFIG_HID_HYPERV_MOUSE is not set
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
# CONFIG_HID_THINGM is not set
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_WACOM=y
# CONFIG_HID_WIIMOTE is not set
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y
# CONFIG_HID_SENSOR_HUB is not set

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y

#
# I2C HID support
#
# CONFIG_I2C_HID is not set
CONFIG_USB_ARCH_HAS_OHCI=y
CONFIG_USB_ARCH_HAS_EHCI=y
CONFIG_USB_ARCH_HAS_XHCI=y
CONFIG_USB_SUPPORT=y
CONFIG_USB_COMMON=y
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB=y
# CONFIG_USB_DEBUG is not set
CONFIG_USB_ANNOUNCE_NEW_DEVICES=y

#
# Miscellaneous USB options
#
CONFIG_USB_DYNAMIC_MINORS=y
CONFIG_USB_SUSPEND=y
# CONFIG_USB_OTG is not set
# CONFIG_USB_DWC3 is not set
CONFIG_USB_MON=y
CONFIG_USB_WUSB=y
CONFIG_USB_WUSB_CBAF=y
# CONFIG_USB_WUSB_CBAF_DEBUG is not set

#
# USB Host Controller Drivers
#
CONFIG_USB_C67X00_HCD=y
CONFIG_USB_XHCI_HCD=y
# CONFIG_USB_XHCI_HCD_DEBUGGING is not set
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_TT_NEWSCHED=y
CONFIG_USB_EHCI_PCI=y
# CONFIG_USB_OXU210HP_HCD is not set
CONFIG_USB_ISP116X_HCD=y
# CONFIG_USB_ISP1760_HCD is not set
# CONFIG_USB_ISP1362_HCD is not set
CONFIG_USB_OHCI_HCD=y
# CONFIG_USB_OHCI_HCD_SSB is not set
# CONFIG_USB_OHCI_HCD_PLATFORM is not set
# CONFIG_USB_EHCI_HCD_PLATFORM is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_DESC is not set
# CONFIG_USB_OHCI_BIG_ENDIAN_MMIO is not set
CONFIG_USB_OHCI_LITTLE_ENDIAN=y
CONFIG_USB_UHCI_HCD=y
CONFIG_USB_U132_HCD=y
CONFIG_USB_SL811_HCD=y
# CONFIG_USB_SL811_HCD_ISO is not set
CONFIG_USB_SL811_CS=y
CONFIG_USB_R8A66597_HCD=y
CONFIG_USB_WHCI_HCD=y
CONFIG_USB_HWA_HCD=y
# CONFIG_USB_HCD_BCMA is not set
# CONFIG_USB_HCD_SSB is not set
# CONFIG_USB_MUSB_HDRC is not set
# CONFIG_USB_CHIPIDEA is not set
# CONFIG_USB_RENESAS_USBHS is not set

#
# USB Device Class drivers
#
CONFIG_USB_ACM=y
CONFIG_USB_PRINTER=y
CONFIG_USB_WDM=y
CONFIG_USB_TMC=y

#
# NOTE: USB_STORAGE depends on SCSI but BLK_DEV_SD may
#

#
# also be needed; see USB_STORAGE Help for more info
#
CONFIG_USB_STORAGE=y
# CONFIG_USB_STORAGE_DEBUG is not set
CONFIG_USB_STORAGE_REALTEK=y
CONFIG_REALTEK_AUTOPM=y
CONFIG_USB_STORAGE_DATAFAB=y
CONFIG_USB_STORAGE_FREECOM=y
CONFIG_USB_STORAGE_ISD200=y
CONFIG_USB_STORAGE_USBAT=y
CONFIG_USB_STORAGE_SDDR09=y
CONFIG_USB_STORAGE_SDDR55=y
CONFIG_USB_STORAGE_JUMPSHOT=y
CONFIG_USB_STORAGE_ALAUDA=y
CONFIG_USB_STORAGE_ONETOUCH=y
CONFIG_USB_STORAGE_KARMA=y
CONFIG_USB_STORAGE_CYPRESS_ATACB=y
CONFIG_USB_STORAGE_ENE_UB6250=y

#
# USB Imaging devices
#
CONFIG_USB_MDC800=y
CONFIG_USB_MICROTEK=y

#
# USB port drivers
#
CONFIG_USB_USS720=y
CONFIG_USB_SERIAL=y
# CONFIG_USB_SERIAL_CONSOLE is not set
CONFIG_USB_SERIAL_GENERIC=y
CONFIG_USB_SERIAL_AIRCABLE=y
CONFIG_USB_SERIAL_ARK3116=y
CONFIG_USB_SERIAL_BELKIN=y
CONFIG_USB_SERIAL_CH341=y
CONFIG_USB_SERIAL_WHITEHEAT=y
CONFIG_USB_SERIAL_DIGI_ACCELEPORT=y
CONFIG_USB_SERIAL_CP210X=y
CONFIG_USB_SERIAL_CYPRESS_M8=y
CONFIG_USB_SERIAL_EMPEG=y
CONFIG_USB_SERIAL_FTDI_SIO=y
CONFIG_USB_SERIAL_FUNSOFT=y
CONFIG_USB_SERIAL_VISOR=y
CONFIG_USB_SERIAL_IPAQ=y
CONFIG_USB_SERIAL_IR=y
CONFIG_USB_SERIAL_EDGEPORT=y
CONFIG_USB_SERIAL_EDGEPORT_TI=y
# CONFIG_USB_SERIAL_F81232 is not set
CONFIG_USB_SERIAL_GARMIN=y
CONFIG_USB_SERIAL_IPW=y
CONFIG_USB_SERIAL_IUU=y
CONFIG_USB_SERIAL_KEYSPAN_PDA=y
CONFIG_USB_SERIAL_KEYSPAN=y
CONFIG_USB_SERIAL_KLSI=y
CONFIG_USB_SERIAL_KOBIL_SCT=y
CONFIG_USB_SERIAL_MCT_U232=y
# CONFIG_USB_SERIAL_METRO is not set
CONFIG_USB_SERIAL_MOS7720=y
CONFIG_USB_SERIAL_MOS7715_PARPORT=y
CONFIG_USB_SERIAL_MOS7840=y
CONFIG_USB_SERIAL_MOTOROLA=y
CONFIG_USB_SERIAL_NAVMAN=y
CONFIG_USB_SERIAL_PL2303=y
CONFIG_USB_SERIAL_OTI6858=y
CONFIG_USB_SERIAL_QCAUX=y
CONFIG_USB_SERIAL_QUALCOMM=y
CONFIG_USB_SERIAL_SPCP8X5=y
CONFIG_USB_SERIAL_HP4X=y
CONFIG_USB_SERIAL_SAFE=y
# CONFIG_USB_SERIAL_SAFE_PADDED is not set
CONFIG_USB_SERIAL_SIEMENS_MPI=y
CONFIG_USB_SERIAL_SIERRAWIRELESS=y
CONFIG_USB_SERIAL_SYMBOL=y
CONFIG_USB_SERIAL_TI=y
CONFIG_USB_SERIAL_CYBERJACK=y
CONFIG_USB_SERIAL_XIRCOM=y
CONFIG_USB_SERIAL_WWAN=y
CONFIG_USB_SERIAL_OPTION=y
CONFIG_USB_SERIAL_OMNINET=y
CONFIG_USB_SERIAL_OPTICON=y
CONFIG_USB_SERIAL_VIVOPAY_SERIAL=y
# CONFIG_USB_SERIAL_XSENS_MT is not set
CONFIG_USB_SERIAL_ZIO=y
# CONFIG_USB_SERIAL_ZTE is not set
CONFIG_USB_SERIAL_SSU100=y
# CONFIG_USB_SERIAL_QT2 is not set
CONFIG_USB_SERIAL_DEBUG=y

#
# USB Miscellaneous drivers
#
CONFIG_USB_EMI62=y
CONFIG_USB_EMI26=y
CONFIG_USB_ADUTUX=y
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
CONFIG_USB_SISUSBVGA_CON=y
CONFIG_USB_LD=y
CONFIG_USB_TRANCEVIBRATOR=y
CONFIG_USB_IOWARRIOR=y
CONFIG_USB_TEST=y
CONFIG_USB_ISIGHTFW=y
CONFIG_USB_YUREX=y
CONFIG_USB_EZUSB_FX2=y
# CONFIG_USB_HSIC_USB3503 is not set

#
# USB Physical Layer drivers
#
# CONFIG_OMAP_USB3 is not set
# CONFIG_OMAP_CONTROL_USB is not set
# CONFIG_USB_ISP1301 is not set
# CONFIG_USB_RCAR_PHY is not set
CONFIG_USB_ATM=y
CONFIG_USB_SPEEDTOUCH=y
CONFIG_USB_CXACRU=y
CONFIG_USB_UEAGLEATM=y
CONFIG_USB_XUSBATM=y
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
# CONFIG_USB_GADGET_DEBUG_FILES is not set
# CONFIG_USB_GADGET_DEBUG_FS is not set
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
# CONFIG_USB_R8A66597 is not set
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=y
# CONFIG_USB_DUMMY_HCD is not set
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_MASS_STORAGE is not set
# CONFIG_USB_GADGET_TARGET is not set
# CONFIG_USB_G_SERIAL is not set
# CONFIG_USB_MIDI_GADGET is not set
# CONFIG_USB_G_PRINTER is not set
# CONFIG_USB_CDC_COMPOSITE is not set
# CONFIG_USB_G_NOKIA is not set
# CONFIG_USB_G_ACM_MS is not set
# CONFIG_USB_G_MULTI is not set
# CONFIG_USB_G_HID is not set
# CONFIG_USB_G_DBGP is not set

#
# OTG and related infrastructure
#
CONFIG_USB_OTG_UTILS=y
# CONFIG_USB_GPIO_VBUS is not set
CONFIG_NOP_USB_XCEIV=y
CONFIG_UWB=y
CONFIG_UWB_HWA=y
CONFIG_UWB_WHCI=y
CONFIG_UWB_I1480U=y
CONFIG_MMC=y
# CONFIG_MMC_DEBUG is not set
# CONFIG_MMC_UNSAFE_RESUME is not set
# CONFIG_MMC_CLKGATE is not set

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
CONFIG_SDIO_UART=y
# CONFIG_MMC_TEST is not set

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PCI=y
CONFIG_MMC_RICOH_MMC=y
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
CONFIG_MMC_VUB300=y
CONFIG_MMC_USHC=y
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
CONFIG_MEMSTICK_TIFM_MS=y
CONFIG_MEMSTICK_JMICRON_38X=y
CONFIG_MEMSTICK_R592=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3642 is not set
CONFIG_LEDS_PCA9532=y
# CONFIG_LEDS_PCA9532_GPIO is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_CLEVO_MAIL=y
CONFIG_LEDS_PCA955X=y
# CONFIG_LEDS_PCA9633 is not set
CONFIG_LEDS_DAC124S085=y
CONFIG_LEDS_REGULATOR=y
CONFIG_LEDS_BD2802=y
CONFIG_LEDS_INTEL_SS4200=y
CONFIG_LEDS_LT3593=y
CONFIG_LEDS_DELL_NETBOOKS=y
# CONFIG_LEDS_TCA6507 is not set
# CONFIG_LEDS_LM355x is not set
# CONFIG_LEDS_OT200 is not set
# CONFIG_LEDS_BLINKM is not set
CONFIG_LEDS_TRIGGERS=y

#
# LED Triggers
#
CONFIG_LEDS_TRIGGER_TIMER=y
# CONFIG_LEDS_TRIGGER_ONESHOT is not set
CONFIG_LEDS_TRIGGER_IDE_DISK=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_BACKLIGHT=y
# CONFIG_LEDS_TRIGGER_CPU is not set
# CONFIG_LEDS_TRIGGER_GPIO is not set
CONFIG_LEDS_TRIGGER_DEFAULT_ON=y

#
# iptables trigger is under Netfilter config (LED target)
#
# CONFIG_LEDS_TRIGGER_TRANSIENT is not set
CONFIG_ACCESSIBILITY=y
CONFIG_A11Y_BRAILLE_CONSOLE=y
CONFIG_INFINIBAND=y
CONFIG_INFINIBAND_USER_MAD=y
CONFIG_INFINIBAND_USER_ACCESS=y
CONFIG_INFINIBAND_USER_MEM=y
CONFIG_INFINIBAND_ADDR_TRANS=y
CONFIG_INFINIBAND_MTHCA=y
CONFIG_INFINIBAND_MTHCA_DEBUG=y
CONFIG_INFINIBAND_IPATH=y
CONFIG_INFINIBAND_QIB=y
CONFIG_INFINIBAND_AMSO1100=y
# CONFIG_INFINIBAND_AMSO1100_DEBUG is not set
CONFIG_INFINIBAND_CXGB3=y
# CONFIG_INFINIBAND_CXGB3_DEBUG is not set
CONFIG_INFINIBAND_CXGB4=y
CONFIG_MLX4_INFINIBAND=y
CONFIG_INFINIBAND_NES=y
# CONFIG_INFINIBAND_NES_DEBUG is not set
# CONFIG_INFINIBAND_OCRDMA is not set
CONFIG_INFINIBAND_IPOIB=y
CONFIG_INFINIBAND_IPOIB_CM=y
CONFIG_INFINIBAND_IPOIB_DEBUG=y
# CONFIG_INFINIBAND_IPOIB_DEBUG_DATA is not set
CONFIG_INFINIBAND_SRP=y
# CONFIG_INFINIBAND_SRPT is not set
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
CONFIG_EDAC_GHES=y
CONFIG_EDAC_AMD64=y
# CONFIG_EDAC_AMD64_ERROR_INJECTION is not set
CONFIG_EDAC_E752X=y
CONFIG_EDAC_I82975X=y
CONFIG_EDAC_I3000=y
CONFIG_EDAC_I3200=y
CONFIG_EDAC_X38=y
CONFIG_EDAC_I5400=y
CONFIG_EDAC_I7CORE=y
CONFIG_EDAC_I5000=y
CONFIG_EDAC_I5100=y
CONFIG_EDAC_I7300=y
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
# CONFIG_RTC_DEBUG is not set

#
# RTC interfaces
#
CONFIG_RTC_INTF_SYSFS=y
CONFIG_RTC_INTF_PROC=y
CONFIG_RTC_INTF_DEV=y
# CONFIG_RTC_INTF_DEV_UIE_EMUL is not set
CONFIG_RTC_DRV_TEST=y

#
# I2C RTC drivers
#
CONFIG_RTC_DRV_DS1307=y
CONFIG_RTC_DRV_DS1374=y
CONFIG_RTC_DRV_DS1672=y
# CONFIG_RTC_DRV_DS3232 is not set
CONFIG_RTC_DRV_MAX6900=y
CONFIG_RTC_DRV_RS5C372=y
CONFIG_RTC_DRV_ISL1208=y
# CONFIG_RTC_DRV_ISL12022 is not set
CONFIG_RTC_DRV_X1205=y
# CONFIG_RTC_DRV_PCF8523 is not set
CONFIG_RTC_DRV_PCF8563=y
CONFIG_RTC_DRV_PCF8583=y
CONFIG_RTC_DRV_M41T80=y
# CONFIG_RTC_DRV_M41T80_WDT is not set
CONFIG_RTC_DRV_BQ32K=y
CONFIG_RTC_DRV_S35390A=y
CONFIG_RTC_DRV_FM3130=y
CONFIG_RTC_DRV_RX8581=y
CONFIG_RTC_DRV_RX8025=y
# CONFIG_RTC_DRV_EM3027 is not set
# CONFIG_RTC_DRV_RV3029C2 is not set

#
# SPI RTC drivers
#
# CONFIG_RTC_DRV_M41T93 is not set
CONFIG_RTC_DRV_M41T94=y
CONFIG_RTC_DRV_DS1305=y
CONFIG_RTC_DRV_DS1390=y
CONFIG_RTC_DRV_MAX6902=y
CONFIG_RTC_DRV_R9701=y
CONFIG_RTC_DRV_RS5C348=y
CONFIG_RTC_DRV_DS3234=y
CONFIG_RTC_DRV_PCF2123=y
# CONFIG_RTC_DRV_RX4581 is not set

#
# Platform RTC drivers
#
CONFIG_RTC_DRV_CMOS=y
CONFIG_RTC_DRV_DS1286=y
CONFIG_RTC_DRV_DS1511=y
CONFIG_RTC_DRV_DS1553=y
CONFIG_RTC_DRV_DS1742=y
CONFIG_RTC_DRV_STK17TA8=y
CONFIG_RTC_DRV_M48T86=y
CONFIG_RTC_DRV_M48T35=y
CONFIG_RTC_DRV_M48T59=y
CONFIG_RTC_DRV_MSM6242=y
CONFIG_RTC_DRV_BQ4802=y
CONFIG_RTC_DRV_RP5C01=y
CONFIG_RTC_DRV_V3020=y
# CONFIG_RTC_DRV_DS2404 is not set
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#

#
# HID Sensor RTC drivers
#
# CONFIG_RTC_DRV_HID_SENSOR_TIME is not set
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_DW_DMAC is not set
# CONFIG_TIMB_DMA is not set
CONFIG_PCH_DMA=y
CONFIG_DMA_ENGINE=y

#
# DMA Clients
#
CONFIG_NET_DMA=y
CONFIG_ASYNC_TX_DMA=y
# CONFIG_DMATEST is not set
CONFIG_DCA=y
# CONFIG_AUXDISPLAY is not set
CONFIG_UIO=y
CONFIG_UIO_CIF=y
CONFIG_UIO_PDRV=y
CONFIG_UIO_PDRV_GENIRQ=y
# CONFIG_UIO_DMEM_GENIRQ is not set
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VFIO is not set
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
CONFIG_VIRTIO_MMIO=y
# CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES is not set

#
# Microsoft Hyper-V guest support
#
CONFIG_HYPERV=y
CONFIG_HYPERV_UTILS=y
# CONFIG_HYPERV_BALLOON is not set

#
# Xen driver support
#
CONFIG_XEN_BALLOON=y
# CONFIG_XEN_BALLOON_MEMORY_HOTPLUG is not set
CONFIG_XEN_SCRUB_PAGES=y
CONFIG_XEN_DEV_EVTCHN=y
CONFIG_XEN_BACKEND=y
CONFIG_XENFS=y
CONFIG_XEN_COMPAT_XENFS=y
CONFIG_XEN_SYS_HYPERVISOR=y
CONFIG_XEN_XENBUS_FRONTEND=y
CONFIG_XEN_GNTDEV=y
CONFIG_XEN_GRANT_DEV_ALLOC=y
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=y
CONFIG_XEN_PRIVCMD=y
# CONFIG_XEN_STUB is not set
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_XEN_HAVE_PVMMU=y
CONFIG_STAGING=y
CONFIG_ET131X=y
# CONFIG_SLICOSS is not set
CONFIG_USBIP_CORE=y
CONFIG_USBIP_VHCI_HCD=y
CONFIG_USBIP_HOST=y
# CONFIG_USBIP_DEBUG is not set
# CONFIG_W35UND is not set
CONFIG_PRISM2_USB=y
# CONFIG_ECHO is not set
CONFIG_COMEDI=m
# CONFIG_COMEDI_DEBUG is not set
CONFIG_COMEDI_DEFAULT_BUF_SIZE_KB=2048
CONFIG_COMEDI_DEFAULT_BUF_MAXSIZE_KB=20480
# CONFIG_COMEDI_MISC_DRIVERS is not set
# CONFIG_COMEDI_PCI_DRIVERS is not set
# CONFIG_COMEDI_PCMCIA_DRIVERS is not set
# CONFIG_COMEDI_USB_DRIVERS is not set
CONFIG_COMEDI_8255=m
# CONFIG_ASUS_OLED is not set
# CONFIG_PANEL is not set
CONFIG_R8187SE=m
CONFIG_RTL8192U=m
# CONFIG_RTLLIB is not set
CONFIG_R8712U=y
# CONFIG_RTS5139 is not set
# CONFIG_TRANZPORT is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_VT6655 is not set
CONFIG_VT6656=m
# CONFIG_DX_SEP is not set
CONFIG_ZRAM=y
# CONFIG_ZRAM_DEBUG is not set
CONFIG_ZSMALLOC=y
# CONFIG_WLAGS49_H2 is not set
# CONFIG_WLAGS49_H25 is not set
# CONFIG_FB_SM7XX is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_CXT1E1 is not set
# CONFIG_FB_XGI is not set
# CONFIG_ACPI_QUICKSTART is not set
# CONFIG_SBE_2T3E3 is not set
# CONFIG_USB_ENESTORAGE is not set
# CONFIG_BCM_WIMAX is not set
# CONFIG_FT1000 is not set

#
# Speakup console speech
#
CONFIG_SPEAKUP=y
CONFIG_SPEAKUP_SYNTH_ACNTSA=y
CONFIG_SPEAKUP_SYNTH_ACNTPC=y
CONFIG_SPEAKUP_SYNTH_APOLLO=y
CONFIG_SPEAKUP_SYNTH_AUDPTR=y
CONFIG_SPEAKUP_SYNTH_BNS=y
CONFIG_SPEAKUP_SYNTH_DECTLK=y
CONFIG_SPEAKUP_SYNTH_DECEXT=y
# CONFIG_SPEAKUP_SYNTH_DECPC is not set
CONFIG_SPEAKUP_SYNTH_DTLK=y
CONFIG_SPEAKUP_SYNTH_KEYPC=y
CONFIG_SPEAKUP_SYNTH_LTLK=y
CONFIG_SPEAKUP_SYNTH_SOFT=y
CONFIG_SPEAKUP_SYNTH_SPKOUT=y
CONFIG_SPEAKUP_SYNTH_TXPRT=y
CONFIG_SPEAKUP_SYNTH_DUMMY=y
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
CONFIG_STAGING_MEDIA=y

#
# Android
#
# CONFIG_ANDROID is not set
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_USB_G_CCG is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_CSR_WIFI is not set
# CONFIG_NET_VENDOR_SILICOM is not set
# CONFIG_CED1401 is not set
# CONFIG_DGRP is not set
# CONFIG_FIREWIRE_SERIAL is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
# CONFIG_CHROMEOS_LAPTOP is not set
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
CONFIG_DELL_WMI_AIO=y
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
CONFIG_AMILO_RFKILL=y
CONFIG_HP_ACCEL=y
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
CONFIG_IDEAPAD_LAPTOP=y
CONFIG_THINKPAD_ACPI=y
CONFIG_THINKPAD_ACPI_ALSA_SUPPORT=y
# CONFIG_THINKPAD_ACPI_DEBUGFACILITIES is not set
# CONFIG_THINKPAD_ACPI_DEBUG is not set
# CONFIG_THINKPAD_ACPI_UNSAFE_LEDS is not set
CONFIG_THINKPAD_ACPI_VIDEO=y
CONFIG_THINKPAD_ACPI_HOTKEY_POLL=y
CONFIG_SENSORS_HDAPS=y
# CONFIG_INTEL_MENLOW is not set
CONFIG_EEEPC_LAPTOP=y
CONFIG_ASUS_WMI=y
CONFIG_ASUS_NB_WMI=y
CONFIG_EEEPC_WMI=y
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
CONFIG_INTEL_IPS=y
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
CONFIG_SAMSUNG_LAPTOP=y
CONFIG_MXM_WMI=y
CONFIG_INTEL_OAKTRAIL=y
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
# CONFIG_AMD_IOMMU_V2 is not set
CONFIG_DMAR_TABLE=y
CONFIG_INTEL_IOMMU=y
# CONFIG_INTEL_IOMMU_DEFAULT_ON is not set
CONFIG_INTEL_IOMMU_FLOPPY_WA=y
CONFIG_IRQ_REMAP=y

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_NTB is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set
# CONFIG_IPACK_BUS is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
# CONFIG_EDD_OFF is not set
CONFIG_FIRMWARE_MEMMAP=y
CONFIG_EFI_VARS=y
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
CONFIG_ISCSI_IBFT_FIND=y
CONFIG_ISCSI_IBFT=y
# CONFIG_GOOGLE_FIRMWARE is not set

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
# CONFIG_JBD_DEBUG is not set
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_PROC_INFO is not set
CONFIG_REISERFS_FS_XATTR=y
CONFIG_REISERFS_FS_POSIX_ACL=y
CONFIG_REISERFS_FS_SECURITY=y
CONFIG_JFS_FS=y
CONFIG_JFS_POSIX_ACL=y
CONFIG_JFS_SECURITY=y
# CONFIG_JFS_DEBUG is not set
# CONFIG_JFS_STATISTICS is not set
CONFIG_XFS_FS=y
CONFIG_XFS_QUOTA=y
CONFIG_XFS_POSIX_ACL=y
CONFIG_XFS_RT=y
# CONFIG_XFS_DEBUG is not set
CONFIG_GFS2_FS=y
CONFIG_GFS2_FS_LOCKING_DLM=y
CONFIG_OCFS2_FS=y
CONFIG_OCFS2_FS_O2CB=y
CONFIG_OCFS2_FS_USERSPACE_CLUSTER=y
CONFIG_OCFS2_FS_STATS=y
CONFIG_OCFS2_DEBUG_MASKLOG=y
# CONFIG_OCFS2_DEBUG_FS is not set
CONFIG_BTRFS_FS=y
CONFIG_BTRFS_FS_POSIX_ACL=y
# CONFIG_BTRFS_FS_CHECK_INTEGRITY is not set
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_EXPORTFS=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_FANOTIFY_ACCESS_PERMISSIONS is not set
CONFIG_QUOTA=y
CONFIG_QUOTA_NETLINK_INTERFACE=y
CONFIG_PRINT_QUOTA_WARNING=y
# CONFIG_QUOTA_DEBUG is not set
CONFIG_QUOTA_TREE=y
CONFIG_QFMT_V1=y
CONFIG_QFMT_V2=y
CONFIG_QUOTACTL=y
CONFIG_QUOTACTL_COMPAT=y
CONFIG_AUTOFS4_FS=y
CONFIG_FUSE_FS=y
CONFIG_CUSE=y
CONFIG_GENERIC_ACL=y

#
# Caches
#
CONFIG_FSCACHE=y
CONFIG_FSCACHE_STATS=y
# CONFIG_FSCACHE_HISTOGRAM is not set
# CONFIG_FSCACHE_DEBUG is not set
# CONFIG_FSCACHE_OBJECT_LIST is not set
CONFIG_CACHEFILES=y
# CONFIG_CACHEFILES_DEBUG is not set
# CONFIG_CACHEFILES_HISTOGRAM is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=y
CONFIG_JOLIET=y
CONFIG_ZISOFS=y
CONFIG_UDF_FS=y
CONFIG_UDF_NLS=y

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="utf8"
CONFIG_NTFS_FS=y
# CONFIG_NTFS_DEBUG is not set
CONFIG_NTFS_RW=y

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_PROC_SYSCTL=y
CONFIG_PROC_PAGE_MONITOR=y
CONFIG_SYSFS=y
CONFIG_TMPFS=y
CONFIG_TMPFS_POSIX_ACL=y
CONFIG_TMPFS_XATTR=y
CONFIG_HUGETLBFS=y
CONFIG_HUGETLB_PAGE=y
CONFIG_CONFIGFS_FS=y
CONFIG_MISC_FILESYSTEMS=y
CONFIG_ADFS_FS=y
# CONFIG_ADFS_FS_RW is not set
CONFIG_AFFS_FS=y
CONFIG_ECRYPT_FS=y
# CONFIG_ECRYPT_FS_MESSAGING is not set
CONFIG_HFS_FS=y
CONFIG_HFSPLUS_FS=y
CONFIG_BEFS_FS=y
# CONFIG_BEFS_DEBUG is not set
CONFIG_BFS_FS=y
CONFIG_EFS_FS=y
CONFIG_JFFS2_FS=y
CONFIG_JFFS2_FS_DEBUG=0
CONFIG_JFFS2_FS_WRITEBUFFER=y
# CONFIG_JFFS2_FS_WBUF_VERIFY is not set
CONFIG_JFFS2_SUMMARY=y
CONFIG_JFFS2_FS_XATTR=y
CONFIG_JFFS2_FS_POSIX_ACL=y
CONFIG_JFFS2_FS_SECURITY=y
CONFIG_JFFS2_COMPRESSION_OPTIONS=y
CONFIG_JFFS2_ZLIB=y
CONFIG_JFFS2_LZO=y
CONFIG_JFFS2_RTIME=y
# CONFIG_JFFS2_RUBIN is not set
# CONFIG_JFFS2_CMODE_NONE is not set
CONFIG_JFFS2_CMODE_PRIORITY=y
# CONFIG_JFFS2_CMODE_SIZE is not set
# CONFIG_JFFS2_CMODE_FAVOURLZO is not set
CONFIG_UBIFS_FS=y
CONFIG_UBIFS_FS_ADVANCED_COMPR=y
CONFIG_UBIFS_FS_LZO=y
CONFIG_UBIFS_FS_ZLIB=y
CONFIG_LOGFS=y
CONFIG_CRAMFS=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_ZLIB=y
CONFIG_SQUASHFS_LZO=y
CONFIG_SQUASHFS_XZ=y
# CONFIG_SQUASHFS_4K_DEVBLK_SIZE is not set
# CONFIG_SQUASHFS_EMBEDDED is not set
CONFIG_SQUASHFS_FRAGMENT_CACHE_SIZE=3
CONFIG_VXFS_FS=y
CONFIG_MINIX_FS=y
CONFIG_OMFS_FS=y
# CONFIG_HPFS_FS is not set
CONFIG_QNX4FS_FS=y
# CONFIG_QNX6FS_FS is not set
CONFIG_ROMFS_FS=y
# CONFIG_ROMFS_BACKED_BY_BLOCK is not set
# CONFIG_ROMFS_BACKED_BY_MTD is not set
CONFIG_ROMFS_BACKED_BY_BOTH=y
CONFIG_ROMFS_ON_BLOCK=y
CONFIG_ROMFS_ON_MTD=y
CONFIG_PSTORE=y
# CONFIG_PSTORE_CONSOLE is not set
# CONFIG_PSTORE_FTRACE is not set
# CONFIG_PSTORE_RAM is not set
CONFIG_SYSV_FS=y
CONFIG_UFS_FS=y
# CONFIG_UFS_FS_WRITE is not set
# CONFIG_UFS_DEBUG is not set
CONFIG_EXOFS_FS=y
# CONFIG_EXOFS_DEBUG is not set
# CONFIG_F2FS_FS is not set
CONFIG_ORE=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFS_FS=y
CONFIG_NFS_V2=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
CONFIG_NFS_V4_1=y
CONFIG_PNFS_FILE_LAYOUT=m
CONFIG_PNFS_BLOCK=m
CONFIG_PNFS_OBJLAYOUT=m
CONFIG_NFS_V4_1_IMPLEMENTATION_ID_DOMAIN="kernel.org"
CONFIG_ROOT_NFS=y
CONFIG_NFS_FSCACHE=y
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
# CONFIG_NFSD_FAULT_INJECTION is not set
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_SUNRPC_XPRT_RDMA=y
CONFIG_RPCSEC_GSS_KRB5=y
# CONFIG_SUNRPC_DEBUG is not set
CONFIG_CEPH_FS=y
CONFIG_CIFS=y
# CONFIG_CIFS_STATS is not set
CONFIG_CIFS_WEAK_PW_HASH=y
CONFIG_CIFS_UPCALL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_POSIX=y
CONFIG_CIFS_ACL=y
CONFIG_CIFS_DEBUG=y
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_SMB2 is not set
CONFIG_CIFS_FSCACHE=y
CONFIG_NCP_FS=y
CONFIG_NCPFS_PACKET_SIGNING=y
CONFIG_NCPFS_IOCTL_LOCKING=y
CONFIG_NCPFS_STRONG=y
CONFIG_NCPFS_NFS_NS=y
CONFIG_NCPFS_OS2_NS=y
# CONFIG_NCPFS_SMALLDOS is not set
CONFIG_NCPFS_NLS=y
CONFIG_NCPFS_EXTRAS=y
CONFIG_CODA_FS=y
CONFIG_AFS_FS=y
# CONFIG_AFS_DEBUG is not set
CONFIG_AFS_FSCACHE=y
CONFIG_9P_FS=y
CONFIG_9P_FSCACHE=y
CONFIG_9P_FS_POSIX_ACL=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="utf8"
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_CODEPAGE_737=y
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
CONFIG_NLS_CODEPAGE_862=y
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
CONFIG_NLS_CODEPAGE_869=y
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
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
CONFIG_NLS_ISO8859_5=y
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
CONFIG_NLS_ISO8859_13=y
CONFIG_NLS_ISO8859_14=y
CONFIG_NLS_ISO8859_15=y
CONFIG_NLS_KOI8_R=y
CONFIG_NLS_KOI8_U=y
# CONFIG_NLS_MAC_ROMAN is not set
# CONFIG_NLS_MAC_CELTIC is not set
# CONFIG_NLS_MAC_CENTEURO is not set
# CONFIG_NLS_MAC_CROATIAN is not set
# CONFIG_NLS_MAC_CYRILLIC is not set
# CONFIG_NLS_MAC_GAELIC is not set
# CONFIG_NLS_MAC_GREEK is not set
# CONFIG_NLS_MAC_ICELAND is not set
# CONFIG_NLS_MAC_INUIT is not set
# CONFIG_NLS_MAC_ROMANIAN is not set
# CONFIG_NLS_MAC_TURKISH is not set
CONFIG_NLS_UTF8=y
CONFIG_DLM=y
CONFIG_DLM_DEBUG=y

#
# Kernel hacking
#
CONFIG_TRACE_IRQFLAGS_SUPPORT=y
CONFIG_PRINTK_TIME=y
CONFIG_DEFAULT_MESSAGE_LOGLEVEL=4
CONFIG_ENABLE_WARN_DEPRECATED=y
CONFIG_ENABLE_MUST_CHECK=y
CONFIG_FRAME_WARN=2048
CONFIG_MAGIC_SYSRQ=y
CONFIG_STRIP_ASM_SYMS=y
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
# CONFIG_HEADERS_CHECK is not set
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
CONFIG_LOCKUP_DETECTOR=y
CONFIG_HARDLOCKUP_DETECTOR=y
# CONFIG_BOOTPARAM_HARDLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_HARDLOCKUP_PANIC_VALUE=0
# CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC is not set
CONFIG_BOOTPARAM_SOFTLOCKUP_PANIC_VALUE=0
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=300
CONFIG_BOOTPARAM_HUNG_TASK_PANIC=y
CONFIG_BOOTPARAM_HUNG_TASK_PANIC_VALUE=1
CONFIG_SCHED_DEBUG=y
CONFIG_SCHEDSTATS=y
CONFIG_TIMER_STATS=y
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
# CONFIG_DEBUG_OBJECTS_TIMERS is not set
# CONFIG_DEBUG_OBJECTS_WORK is not set
# CONFIG_DEBUG_OBJECTS_RCU_HEAD is not set
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
CONFIG_DEBUG_SLAB=y
# CONFIG_DEBUG_SLAB_LEAK is not set
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_VM=y
# CONFIG_DEBUG_VM_RB is not set
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
CONFIG_TEST_LIST_SORT=y
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y

#
# RCU Debugging
#
# CONFIG_PROVE_RCU is not set
CONFIG_SPARSE_RCU_POINTER=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
CONFIG_RCU_CPU_STALL_INFO=y
CONFIG_RCU_TRACE=y
CONFIG_KPROBES_SANITY_TEST=y
# CONFIG_BACKTRACE_SELF_TEST is not set
CONFIG_DEBUG_BLOCK_EXT_DEVT=y
CONFIG_DEBUG_FORCE_WEAK_PER_CPU=y
CONFIG_DEBUG_PER_CPU_MAPS=y
CONFIG_LKDTM=y
# CONFIG_NOTIFIER_ERROR_INJECTION is not set
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
# CONFIG_FAIL_PAGE_ALLOC is not set
# CONFIG_FAIL_MAKE_REQUEST is not set
# CONFIG_FAIL_IO_TIMEOUT is not set
# CONFIG_FAIL_MMC_REQUEST is not set
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_LATENCYTOP=y
CONFIG_DEBUG_PAGEALLOC=y
CONFIG_WANT_PAGE_DEBUG_FLAGS=y
CONFIG_PAGE_GUARD=y
CONFIG_USER_STACKTRACE_SUPPORT=y
CONFIG_NOP_TRACER=y
CONFIG_HAVE_FUNCTION_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=y
CONFIG_HAVE_FUNCTION_GRAPH_FP_TEST=y
CONFIG_HAVE_FUNCTION_TRACE_MCOUNT_TEST=y
CONFIG_HAVE_DYNAMIC_FTRACE=y
CONFIG_HAVE_DYNAMIC_FTRACE_WITH_REGS=y
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_FENTRY=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_TRACE_CLOCK=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_CONTEXT_SWITCH_TRACER=y
CONFIG_RING_BUFFER_ALLOW_SWAP=y
CONFIG_TRACING=y
CONFIG_GENERIC_TRACER=y
CONFIG_TRACING_SUPPORT=y
CONFIG_FTRACE=y
CONFIG_FUNCTION_TRACER=y
CONFIG_FUNCTION_GRAPH_TRACER=y
CONFIG_IRQSOFF_TRACER=y
CONFIG_SCHED_TRACER=y
CONFIG_FTRACE_SYSCALLS=y
# CONFIG_TRACER_SNAPSHOT is not set
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
CONFIG_DYNAMIC_FTRACE_WITH_REGS=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
# CONFIG_EVENT_TRACE_TEST_SYSCALLS is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
# CONFIG_RBTREE_TEST is not set
# CONFIG_INTERVAL_TREE_TEST is not set
# CONFIG_PROVIDE_OHCI1394_DMA_INIT is not set
# CONFIG_FIREWIRE_OHCI_REMOTE_DMA is not set
# CONFIG_DYNAMIC_DEBUG is not set
CONFIG_DMA_API_DEBUG=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_ASYNC_RAID6_TEST is not set
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_TEST_KSTRTOX is not set
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
CONFIG_EARLY_PRINTK=y
# CONFIG_EARLY_PRINTK_DBGP is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_X86_PTDUMP=y
CONFIG_DEBUG_RODATA=y
CONFIG_DEBUG_RODATA_TEST=y
CONFIG_DEBUG_SET_MODULE_RONX=y
CONFIG_DEBUG_NX_TEST=m
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
CONFIG_HAVE_MMIOTRACE_SUPPORT=y
# CONFIG_X86_DECODER_SELFTEST is not set
CONFIG_IO_DELAY_TYPE_0X80=0
CONFIG_IO_DELAY_TYPE_0XED=1
CONFIG_IO_DELAY_TYPE_UDELAY=2
CONFIG_IO_DELAY_TYPE_NONE=3
CONFIG_IO_DELAY_0X80=y
# CONFIG_IO_DELAY_0XED is not set
# CONFIG_IO_DELAY_UDELAY is not set
# CONFIG_IO_DELAY_NONE is not set
CONFIG_DEFAULT_IO_DELAY_TYPE=0
# CONFIG_DEBUG_BOOT_PARAMS is not set
# CONFIG_CPA_DEBUG is not set
CONFIG_OPTIMIZE_INLINING=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
CONFIG_DEBUG_NMI_SELFTEST=y

#
# Security options
#
CONFIG_KEYS=y
# CONFIG_TRUSTED_KEYS is not set
# CONFIG_ENCRYPTED_KEYS is not set
CONFIG_KEYS_DEBUG_PROC_KEYS=y
# CONFIG_SECURITY_DMESG_RESTRICT is not set
CONFIG_SECURITY=y
CONFIG_SECURITYFS=y
CONFIG_SECURITY_NETWORK=y
CONFIG_SECURITY_NETWORK_XFRM=y
CONFIG_SECURITY_PATH=y
# CONFIG_INTEL_TXT is not set
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
# CONFIG_SECURITY_SMACK is not set
# CONFIG_SECURITY_TOMOYO is not set
CONFIG_SECURITY_APPARMOR=y
CONFIG_SECURITY_APPARMOR_BOOTPARAM_VALUE=1
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_APPARMOR is not set
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
CONFIG_ASYNC_CORE=y
CONFIG_ASYNC_MEMCPY=y
CONFIG_ASYNC_XOR=y
CONFIG_ASYNC_PQ=y
CONFIG_ASYNC_RAID6_RECOV=y
CONFIG_ASYNC_TX_DISABLE_PQ_VAL_DMA=y
CONFIG_ASYNC_TX_DISABLE_XOR_VAL_DMA=y
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
CONFIG_CRYPTO_PCOMP=y
CONFIG_CRYPTO_PCOMP2=y
CONFIG_CRYPTO_MANAGER=y
CONFIG_CRYPTO_MANAGER2=y
# CONFIG_CRYPTO_USER is not set
# CONFIG_CRYPTO_MANAGER_DISABLE_TESTS is not set
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y
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
CONFIG_CRYPTO_HMAC=y
CONFIG_CRYPTO_XCBC=y
CONFIG_CRYPTO_VMAC=y

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
CONFIG_CRYPTO_CRC32C_X86_64=y
CONFIG_CRYPTO_CRC32C_INTEL=y
# CONFIG_CRYPTO_CRC32 is not set
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_TGR192=y
CONFIG_CRYPTO_WP512=y
CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL=y

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=y
CONFIG_CRYPTO_ANUBIS=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
# CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
# CONFIG_CRYPTO_CAST5_AVX_X86_64 is not set
CONFIG_CRYPTO_CAST6=y
# CONFIG_CRYPTO_CAST6_AVX_X86_64 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_FCRYPT=y
CONFIG_CRYPTO_KHAZAD=y
CONFIG_CRYPTO_SALSA20=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_SEED=y
CONFIG_CRYPTO_SERPENT=y
# CONFIG_CRYPTO_SERPENT_SSE2_X86_64 is not set
# CONFIG_CRYPTO_SERPENT_AVX_X86_64 is not set
CONFIG_CRYPTO_TEA=y
CONFIG_CRYPTO_TWOFISH=y
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
# CONFIG_CRYPTO_TWOFISH_AVX_X86_64 is not set

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
CONFIG_CRYPTO_USER_API_HASH=y
CONFIG_CRYPTO_USER_API_SKCIPHER=y
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
# CONFIG_ASYMMETRIC_KEY_TYPE is not set
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
# CONFIG_TCM_VHOST is not set
CONFIG_BINARY_PRINTF=y

#
# Library routines
#
CONFIG_RAID6_PQ=y
CONFIG_BITREVERSE=y
CONFIG_GENERIC_STRNCPY_FROM_USER=y
CONFIG_GENERIC_STRNLEN_USER=y
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
CONFIG_CRC_CCITT=y
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
CONFIG_CRC32_SLICEBY8=y
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
# CONFIG_CRC32_BIT is not set
CONFIG_CRC7=y
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
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
# CONFIG_XZ_DEC_TEST is not set
CONFIG_DECOMPRESS_GZIP=y
CONFIG_DECOMPRESS_BZIP2=y
CONFIG_DECOMPRESS_LZMA=y
CONFIG_DECOMPRESS_XZ=y
CONFIG_DECOMPRESS_LZO=y
CONFIG_GENERIC_ALLOCATOR=y
CONFIG_REED_SOLOMON=y
CONFIG_REED_SOLOMON_DEC16=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_BTREE=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_CHECK_SIGNATURE=y
# CONFIG_CPUMASK_OFFSTACK is not set
CONFIG_CPU_RMAP=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
CONFIG_LRU_CACHE=y
CONFIG_AVERAGE=y
CONFIG_CORDIC=y
# CONFIG_DDR is not set
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_ISDN_DRV_LOOP is not set

--C7zPtVaVf+AK4Oqc--
