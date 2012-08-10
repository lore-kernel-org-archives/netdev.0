From: Fengguang Wu <fengguang.wu@intel.com>
Subject: NULL pointer dereference BUG in ip_send_skb()
Date: Sat, 11 Aug 2012 00:31:12 +0800
Message-ID: <20120810163112.GA32544@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Stultz <johnstul@us.ibm.com>,
	Paul Moore <paul@paul-moore.com>,
	Eric Paris <eparis@parisplace.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55269 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753838Ab2HJQbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 12:31:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Eric,

This line triggers a NULL deference since commit 3a7c384 ("ipv4: tcp:
unicast_sock should not land outside of TCP stack").

        int ip_send_skb(struct sk_buff *skb)
        {       
==>             struct net *net = sock_net(skb->sk);

[   77.914805] md: autorun ...
[   77.915703] md: ... autorun DONE.
[   77.926545] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   77.928884] IP: [<ffffffff8250e980>] ip_send_skb+0xf/0x3d
[   77.929523] PGD 0 
[   77.929523] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   77.929523] Modules linked in:
[   77.929523] CPU 0 
[   77.929523] Pid: 171, comm: kworker/0:2 Not tainted 3.6.0-rc1+ #1720 Bochs Bochs
[   77.929523] RIP: 0010:[<ffffffff8250e980>]  [<ffffffff8250e980>] ip_send_skb+0xf/0x3d
[   77.929523] RSP: 0018:ffff88001f203938  EFLAGS: 00010286
[   77.929523] RAX: 0000000000000000 RBX: ffff88001f3d2580 RCX: ffff880012e75eb8
[   77.929523] RDX: ffff88001f2039b8 RSI: ffff880012e9dd28 RDI: ffff880012903f00
[   77.929523] RBP: ffff88001f203948 R08: 0000000000000000 R09: 0000000000000000
[   77.929523] R10: ffff88001f3d2810 R11: ffff880012e75e00 R12: ffff880012e5cf00
[   77.929523] R13: ffff880012903f00 R14: ffff88001f203a88 R15: ffff88001f3d2820
[   77.929523] FS:  0000000000000000(0000) GS:ffff88001f200000(0000) knlGS:0000000000000000
[   77.929523] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   77.929523] CR2: 0000000000000030 CR3: 0000000003614000 CR4: 00000000000006f0
[   77.929523] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   77.929523] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   77.929523] Process kworker/0:2 (pid: 171, threadinfo ffff880013d9a000, task ffff880013d9c180)
[   77.929523] Stack:
[   77.929523]  ffff880012e9dd28 ffff88001f3d2580 ffff88001f203958 ffffffff8250e9d7
[   77.929523]  ffff88001f203a58 ffffffff8250edcd ffff88001f2039a0 ffff88001f203998
[   77.929523]  ffff880000000040 ffffffff810d312d 000000000f02000a 0000001424c86afd
[   77.929523] Call Trace:
[   77.929523]  <IRQ> 
[   77.929523]  [<ffffffff8250e9d7>] ip_push_pending_frames+0x29/0x2f
[   77.929523]  [<ffffffff8250edcd>] ip_send_unicast_reply+0x297/0x2ce
[   77.929523]  [<ffffffff810d312d>] ? trace_hardirqs_off_caller+0x1f/0x9e
[   77.929523]  [<ffffffff810b9f00>] ? local_clock+0x25/0x52
[   77.929523]  [<ffffffff810d36ca>] ? lock_is_held+0x82/0x94
[   77.929523]  [<ffffffff82526999>] tcp_v4_send_ack+0x1f9/0x218
[   77.929523]  [<ffffffff810b9f16>] ? local_clock+0x3b/0x52
[   77.929523]  [<ffffffff82527ff2>] tcp_v4_rcv+0x6a7/0x754
[   77.929523]  [<ffffffff82509846>] ? __xfrm_policy_check2.constprop.8+0x5b/0x5b
[   77.929523]  [<ffffffff825099c1>] ip_local_deliver_finish+0x17b/0x20f
[   77.929523]  [<ffffffff8250988d>] ? ip_local_deliver_finish+0x47/0x20f
[   77.929523]  [<ffffffff82509ba1>] ip_local_deliver+0x53/0x84
[   77.929523]  [<ffffffff825094bf>] ? skb_dst.isra.5+0x37/0x5b
[   77.929523]  [<ffffffff810b9ef4>] ? local_clock+0x19/0x52
[   77.929523]  [<ffffffff825097b3>] ip_rcv_finish+0x2d0/0x308
[   77.929523]  [<ffffffff82509de2>] ip_rcv+0x210/0x26a
[   77.929523]  [<ffffffff8248253a>] ? rcu_lock_acquire+0x27/0x29
[   77.929523]  [<ffffffff82482513>] ? dev_seq_stop+0x10/0x10
[   77.929523]  [<ffffffff824868b9>] __netif_receive_skb+0x469/0x572
[   77.929523]  [<ffffffff82486b8a>] netif_receive_skb+0x65/0x9c
[   77.929523]  [<ffffffff824870e3>] ? __napi_gro_receive+0xf2/0xfe
[   77.929523]  [<ffffffff82486c4f>] napi_skb_finish+0x27/0x59
[   77.929523]  [<ffffffff824871e2>] napi_gro_receive+0x2f/0x34
[   77.929523]  [<ffffffff81caf06e>] e1000_receive_skb+0x57/0x60
[   77.929523]  [<ffffffff81cb1ebb>] e1000_clean_rx_irq+0x2f2/0x387
[   77.929523]  [<ffffffff81cafdb4>] e1000_clean+0x541/0x695
[   77.929523]  [<ffffffff810d6d1c>] ? mark_held_locks+0x71/0x99
[   77.929523]  [<ffffffff82487432>] ? net_rx_action+0x1ae/0x1ee
[   77.929523]  [<ffffffff82487337>] net_rx_action+0xb3/0x1ee
[   77.929523]  [<ffffffff81090178>] ? __do_softirq+0x83/0x1f5
[   77.929523]  [<ffffffff810901be>] __do_softirq+0xc9/0x1f5
[   77.929523]  [<ffffffff8286b3bc>] call_softirq+0x1c/0x30
[   77.929523]  <EOI> 
[   77.929523]  [<ffffffff8104ac90>] do_softirq+0x4a/0xa2
[   77.929523]  [<ffffffff825184cc>] ? tcp_close+0x2e7/0x303
[   77.929523]  [<ffffffff8108fcfa>] _local_bh_enable_ip+0xa7/0xd8
[   77.929523]  [<ffffffff8108fd4d>] local_bh_enable+0x12/0x14
[   77.929523]  [<ffffffff825184cc>] tcp_close+0x2e7/0x303
[   77.929523]  [<ffffffff82535559>] inet_release+0x7e/0x85
[   77.929523]  [<ffffffff824739f4>] sock_release+0x1f/0x77
[   77.929523]  [<ffffffff82618a94>] xs_reset_transport+0xb8/0xc1
[   77.929523]  [<ffffffff82618ab0>] xs_close+0x13/0x42
[   77.929523]  [<ffffffff82618b04>] xs_destroy+0x25/0x59
[   77.929523]  [<ffffffff82616b17>] xprt_destroy+0x73/0x77
[   77.929523]  [<ffffffff82618196>] xprt_put+0x18/0x1a
[   77.929523]  [<ffffffff82615e6a>] rpc_free_client+0x8e/0xa0
[   77.929523]  [<ffffffff82615dab>] rpc_release_client+0x4f/0x80
[   77.929523]  [<ffffffff82616179>] rpc_task_release_client+0x4b/0x54
[   77.929523]  [<ffffffff8261b9cb>] rpc_release_resources_task+0x39/0x3e
[   77.929523]  [<ffffffff8261ce33>] __rpc_execute+0x12e/0x22b
[   77.929523]  [<ffffffff810d6e67>] ? trace_hardirqs_on_caller+0x123/0x17f
[   77.929523]  [<ffffffff8261cf58>] rpc_async_schedule+0x28/0x34
[   77.929523]  [<ffffffff810a1ecf>] process_one_work+0x1ef/0x3cc
[   77.929523]  [<ffffffff810a1e62>] ? process_one_work+0x182/0x3cc
[   77.929523]  [<ffffffff810d4d4c>] ? lock_acquired+0x1fa/0x22b
[   77.929523]  [<ffffffff8261cf30>] ? __rpc_execute+0x22b/0x22b
[   77.929523]  [<ffffffff810a2412>] worker_thread+0x1ac/0x250
[   77.929523]  [<ffffffff810a2266>] ? rescuer_thread+0x18b/0x18b
[   77.929523]  [<ffffffff810a8ec4>] kthread+0x8a/0x92
[   77.929523]  [<ffffffff8167be8e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   77.929523]  [<ffffffff8286b2c4>] kernel_thread_helper+0x4/0x10
[   77.929523]  [<ffffffff82863930>] ? retint_restore_args+0x13/0x13
[   77.929523]  [<ffffffff810a8e3a>] ? __init_kthread_worker+0x5a/0x5a
[   77.929523]  [<ffffffff8286b2c0>] ? gs_change+0x13/0x13
[   77.929523] Code: 87 84 fe ff ff e9 7a fe ff ff 48 83 c4 38 4c 89 e8 5b 41 5c 41 5d 41 5e 41 5f 5d c3 55 48 89 e5 53 56 0f 1f 44 00 00 48 8b 47 18 <48> 8b 58 30 e8 d1 f1 ff ff 83 f8 00 74 1c 7e 0e 83 f8 02 75 04 
[   77.929523] RIP  [<ffffffff8250e980>] ip_send_skb+0xf/0x3d
[   77.929523]  RSP <ffff88001f203938>
[   77.929523] CR2: 0000000000000030

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git master
head:   63d02d157ec4124990258d66517b6c11fd6df0cf
commit: 3a7c384ffd57ef5fbd95f48edaa2ca4eb3d9f2ee  ipv4: tcp: unicast_sock should not land outside of TCP stack

Thanks,
Fengguang

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-waimea-4771-2012-08-10-17-39-13-3.6.0-rc1+-1720"
Content-Transfer-Encoding: quoted-printable

[    0.000000] Initializing cgroup subsys cpuset
[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.6.0-rc1+ (kbuild@bee) (gcc version 4.7.1 (De=
bian 4.7.1-6) ) #1720 SMP Fri Aug 10 17:36:49 CST 2012
[    0.000000] Command line: trinity=3D2m hung_task_panic=3D1 branch=3Dnet/=
master log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddebug dyna=
mic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_ramdisk=
=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::kvm::dhcp =
nfsroot=3D10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock,rsize=
=3D524288,wsize=3D524288 rw link=3Dvmlinuz-2012-08-10-17-37-30-net:master:6=
3d02d1-63d02d1-x86_64-allyesdebian-2-waimea BOOT_IMAGE=3Dkernel-tests/kerne=
ls/x86_64-allyesdebian/63d02d1/vmlinuz-3.6.0-rc1+
[    0.000000] Disabled fast string operations
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009f3ff] usable
[    0.000000] BIOS-e820: [mem 0x000000000009f400-0x000000000009ffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000001fffcfff] usable
[    0.000000] BIOS-e820: [mem 0x000000001fffd000-0x000000001fffffff] reser=
ved
[    0.000000] BIOS-e820: [mem 0x00000000fffbc000-0x00000000ffffffff] reser=
ved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] DMI 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] Hypervisor detected: KVM
[    0.000000] e820: update [mem 0x00000000-0x0000ffff] usable =3D=3D> rese=
rved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn =3D 0x1fffd max_arch_pfn =3D 0x400000000
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
[    0.000000] x86 PAT enabled: cpu 0, old 0x70106, new 0x7010600070106
[    0.000000] Scan for SMP in [mem 0x00000000-0x000003ff]
[    0.000000] Scan for SMP in [mem 0x0009fc00-0x0009ffff]
[    0.000000] Scan for SMP in [mem 0x000f0000-0x000fffff]
[    0.000000] found SMP MP-table at [mem 0x000f8860-0x000f886f] mapped at =
[ffff8800000f8860]
[    0.000000]   mpc: f8870-f898c
[    0.000000] initial memory mapped: [mem 0x00000000-0x1fffffff]
[    0.000000] Base memory trampoline at [ffff880000099000] 99000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x1fffcfff]
[    0.000000]  [mem 0x00000000-0x1fffcfff] page 4k
[    0.000000] kernel direct mapping tables up to 0x1fffcfff @ [mem 0x1fefb=
000-0x1fffcfff]
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 127972(97%)
[    0.000000] ACPI: RSDP 00000000000f8810 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000001fffde10 00034 (v01 BOCHS  BXPCRSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000001ffffe40 00074 (v01 BOCHS  BXPCFACP 00000=
001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000001fffdfd0 01E22 (v01   BXPC   BXDSDT 00000=
001 INTL 20090123)
[    0.000000] ACPI: FACS 000000001ffffe00 00040
[    0.000000] ACPI: SSDT 000000001fffdf80 00044 (v01 BOCHS  BXPCSSDT 00000=
001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000001fffde90 0007A (v01 BOCHS  BXPCAPIC 00000=
001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000001fffde50 00038 (v01 BOCHS  BXPCHPET 00000=
001 BXPC 00000001)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] No NUMA configuration found
[    0.000000] Faking a node at [mem 0x0000000000000000-0x000000001fffcfff]
[    0.000000] Initmem setup node 0 [mem 0x00000000-0x1fffcfff]
[    0.000000]   NODE_DATA [mem 0x1f6f6000-0x1f6fafff]
[    0.000000] kvm-clock: Using msrs 12 and 11
[    0.000000] kvm-clock: cpu 0, msr 0:3adb141, boot clock
[    0.000000]  [ffffea0000000000-ffffea00007fffff] PMD -> [ffff88001e60000=
0-ffff88001edfffff] on node 0
[    0.000000] Zone ranges:
[    0.000000]   DMA      [mem 0x00010000-0x00ffffff]
[    0.000000]   DMA32    [mem 0x01000000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00010000-0x0009efff]
[    0.000000]   node   0: [mem 0x00100000-0x1fffcfff]
[    0.000000] On node 0 totalpages: 130956
[    0.000000]   DMA zone: 64 pages used for memmap
[    0.000000]   DMA zone: 6 pages reserved
[    0.000000]   DMA zone: 3913 pages, LIFO batch:0
[    0.000000]   DMA32 zone: 1984 pages used for memmap
[    0.000000]   DMA32 zone: 124989 pages, LIFO batch:31
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fb000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
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
[    0.000000] mapped IOAPIC to ffffffffff5fa000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] PM: Registered nosave memory: 000000000009f000 - 00000000000=
a0000
[    0.000000] PM: Registered nosave memory: 00000000000a0000 - 00000000000=
f0000
[    0.000000] PM: Registered nosave memory: 00000000000f0000 - 00000000001=
00000
[    0.000000] e820: [mem 0x20000000-0xfffbbfff] available for PCI devices
[    0.000000] Booting paravirtualized kernel on KVM
[    0.000000] setup_percpu: NR_CPUS:512 nr_cpumask_bits:512 nr_cpu_ids:2 n=
r_node_ids:1
[    0.000000] PERCPU: Embedded 478 pages/cpu @ffff88001f200000 s1925912 r8=
192 d23784 u2097152
[    0.000000] pcpu-alloc: s1925912 r8192 d23784 u2097152 alloc=3D1*2097152
[    0.000000] pcpu-alloc: [0] 0 [0] 1=20
[    0.000000] kvm-clock: cpu 0, msr 0:1f3d5141, primary cpu clock
[    0.000000] Built 1 zonelists in Node order, mobility grouping on.  Tota=
l pages: 128902
[    0.000000] Policy zone: DMA32
[    0.000000] Kernel command line: trinity=3D2m hung_task_panic=3D1 branch=
=3Dnet/master log_buf_len=3D8M ignore_loglevel debug sched_debug apic=3Ddeb=
ug dynamic_printk sysrq_always_enabled panic=3D10 load_ramdisk=3D2 prompt_r=
amdisk=3D0 console=3DttyS0,115200 console=3Dtty0 vga=3Dnormal ip=3D::::kvm:=
:dhcp nfsroot=3D10.239.97.14:/nfsroot/wfg,tcp,v3,nocto,actimeo=3D600,nolock=
,rsize=3D524288,wsize=3D524288 rw link=3Dvmlinuz-2012-08-10-17-37-30-net:ma=
ster:63d02d1-63d02d1-x86_64-allyesdebian-2-waimea BOOT_IMAGE=3Dkernel-tests=
/kernels/x86_64-allyesdebian/63d02d1/vmlinuz-3.6.0-rc1+
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 2048 (order: 2, 16384 bytes)
[    0.000000] __ex_table already sorted, skipping sort
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Calgary: detecting Calgary via BIOS EBDA area
[    0.000000] Calgary: Unable to locate Rio Grande table in EBDA - bailing!
[    0.000000] Memory: 443188k/524276k available (25023k kernel code, 452k =
absent, 80636k reserved, 16978k data, 3680k init)
[    0.000000] Hierarchical RCU implementation.
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
[    0.000000] tsc: Detected 3300.196 MHz processor
[    0.004000] Calibrating delay loop (skipped) preset value.. 6600.39 Bogo=
MIPS (lpj=3D13200784)
[    0.004000] pid_max: default: 32768 minimum: 301
[    0.004333] Security Framework initialized
[    0.005427] Dentry cache hash table entries: 65536 (order: 7, 524288 byt=
es)
[    0.007046] Inode-cache hash table entries: 32768 (order: 6, 262144 byte=
s)
[    0.008201] Mount-cache hash table entries: 256
[    0.011083] Initializing cgroup subsys cpuacct
[    0.012008] Initializing cgroup subsys devices
[    0.012863] Initializing cgroup subsys freezer
[    0.013685] Initializing cgroup subsys net_cls
[    0.014536] Initializing cgroup subsys blkio
[    0.015535] Disabled fast string operations
[    0.016018] mce: CPU supports 10 MCE banks
[    0.016836] numa_add_cpu cpu 0 node 0: mask now 0
[    0.017755] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017755] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017755] tlb_flushall_shift is 0x6
[    0.021341] ACPI: Core revision 20120711
[    0.025779] ftrace: allocating 95742 entries in 374 pages
[    0.044266] Getting VERSION: 50014
[    0.048014] Getting VERSION: 50014
[    0.048736] Getting ID: 0
[    0.049294] Getting ID: ff000000
[    0.049933] Getting LVT0: 8700
[    0.050553] Getting LVT1: 8400
[    0.051208] enabled ExtINT on CPU#0
[    0.052672] ENABLING IO-APIC IRQs
[    0.053337] init IO_APIC IRQs
[    0.053963]  apic 2 pin 0 not connected
[    0.054711] IOAPIC[0]: Set routing entry (2-1 -> 0x41 -> IRQ 1 Mode:0 Ac=
tive:0 Dest:1)
[    0.056033] IOAPIC[0]: Set routing entry (2-2 -> 0x51 -> IRQ 0 Mode:0 Ac=
tive:0 Dest:1)
[    0.057571] IOAPIC[0]: Set routing entry (2-3 -> 0x61 -> IRQ 3 Mode:0 Ac=
tive:0 Dest:1)
[    0.058980] IOAPIC[0]: Set routing entry (2-4 -> 0x71 -> IRQ 4 Mode:0 Ac=
tive:0 Dest:1)
[    0.060042] IOAPIC[0]: Set routing entry (2-5 -> 0x81 -> IRQ 5 Mode:1 Ac=
tive:0 Dest:1)
[    0.061424] IOAPIC[0]: Set routing entry (2-6 -> 0x91 -> IRQ 6 Mode:0 Ac=
tive:0 Dest:1)
[    0.062855] IOAPIC[0]: Set routing entry (2-7 -> 0xa1 -> IRQ 7 Mode:0 Ac=
tive:0 Dest:1)
[    0.064035] IOAPIC[0]: Set routing entry (2-8 -> 0xb1 -> IRQ 8 Mode:0 Ac=
tive:0 Dest:1)
[    0.065423] IOAPIC[0]: Set routing entry (2-9 -> 0xc1 -> IRQ 9 Mode:1 Ac=
tive:0 Dest:1)
[    0.068024] IOAPIC[0]: Set routing entry (2-10 -> 0xd1 -> IRQ 10 Mode:1 =
Active:0 Dest:1)
[    0.069545] IOAPIC[0]: Set routing entry (2-11 -> 0xe1 -> IRQ 11 Mode:1 =
Active:0 Dest:1)
[    0.070960] IOAPIC[0]: Set routing entry (2-12 -> 0x22 -> IRQ 12 Mode:0 =
Active:0 Dest:1)
[    0.072024] IOAPIC[0]: Set routing entry (2-13 -> 0x42 -> IRQ 13 Mode:0 =
Active:0 Dest:1)
[    0.073532] IOAPIC[0]: Set routing entry (2-14 -> 0x52 -> IRQ 14 Mode:0 =
Active:0 Dest:1)
[    0.074961] IOAPIC[0]: Set routing entry (2-15 -> 0x62 -> IRQ 15 Mode:0 =
Active:0 Dest:1)
[    0.076021]  apic 2 pin 16 not connected
[    0.076842]  apic 2 pin 17 not connected
[    0.077574]  apic 2 pin 18 not connected
[    0.078266]  apic 2 pin 19 not connected
[    0.080010]  apic 2 pin 20 not connected
[    0.080783]  apic 2 pin 21 not connected
[    0.081562]  apic 2 pin 22 not connected
[    0.082246]  apic 2 pin 23 not connected
[    0.083083] ..TIMER: vector=3D0x51 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D=
-1
[    0.084010] smpboot: CPU0: Intel Common KVM processor stepping 01
[    0.085718] Using local APIC timer interrupts.
[    0.085718] calibrating APIC timer ...
[    0.092005] ... lapic delta =3D 6250625
[    0.092005] ... PM-Timer delta =3D 357997
[    0.092005] ... PM-Timer result ok
[    0.092005] ..... delta 6250625
[    0.092005] ..... mult: 268445521
[    0.092005] ..... calibration result: 4000400
[    0.092005] ..... CPU clock speed is 3300.2248 MHz.
[    0.092005] ..... host bus clock speed is 1000.0400 MHz.
[    0.092085] Performance Events: unsupported Netburst CPU model 6 no PMU =
driver, software events only.
[    0.095868] Testing tracer nop: PASSED
[    0.098166] SMP alternatives: lockdep: fixing up alternatives
[    0.100016] smpboot: Booting Node   0, Processors  #1 OK
[    0.004000] kvm-clock: cpu 1, msr 0:1f5d5141, secondary cpu clock
[    0.004000] masked ExtINT on CPU#1
[    0.004000] Disabled fast string operations
[    0.004000] numa_add_cpu cpu 1 node 0: mask now 0-1
[    0.116007] TSC synchronization [CPU#0 -> CPU#1]:
[    0.116007] Measured 4465 cycles TSC warp between CPUs, turning off TSC =
clock.
[    0.116007] tsc: Marking TSC unstable due to check_tsc_sync_source failed
[    0.120252] Brought up 2 CPUs
[    0.124013] smpboot: Total of 2 processors activated (13200.78 BogoMIPS)
[    0.125395] CPU0 attaching sched-domain:
[    0.126145]  domain 0: span 0-1 level CPU
[    0.127036]   groups: 0 1
[    0.128047] CPU1 attaching sched-domain:
[    0.128730]  domain 0: span 0-1 level CPU
[    0.129493]   groups: 1 0
[    0.130662] devtmpfs: initialized
[    0.138375] xor: automatically using best checksumming function:
[    0.176754]    generic_sse:   214.000 MB/sec
[    0.177575] atomic64 test passed for x86-64 platform with CX8 and with S=
SE
[    0.179351] dummy:=20
[    0.180555] NET: Registered protocol family 16
[    0.185414] ACPI: bus type pci registered
[    0.186326] dca service started, version 1.12.1
[    0.187406] PCI: Using configuration type 1 for base access
[    0.189850] mtrr: your CPUs had inconsistent variable MTRR settings
[    0.191057] mtrr: your CPUs had inconsistent MTRRdefType settings
[    0.192017] mtrr: probably your BIOS does not setup all CPUs.
[    0.192963] mtrr: corrected configuration.
[    0.260781] bio: create slab <bio-0> at 0
[    0.324765] raid6: sse2x1    6414 MB/s
[    0.392756] raid6: sse2x2    7379 MB/s
[    0.460770] raid6: sse2x4    9898 MB/s
[    0.461437] raid6: using algorithm sse2x4 (9898 MB/s)
[    0.462347] raid6: using intx1 recovery algorithm
[    0.463580] ACPI: Added _OSI(Module Device)
[    0.464037] ACPI: Added _OSI(Processor Device)
[    0.464845] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.465673] ACPI: Added _OSI(Processor Aggregator Device)
[    0.469017] ACPI: EC: Look up EC in DSDT
[    0.475689] ACPI: Interpreter enabled
[    0.476037] ACPI: (supports S0 S3 S4 S5)
[    0.477606] ACPI: Using IOAPIC for interrupt routing
[    0.497073] ACPI: No dock devices found.
[    0.498097] PCI: Ignoring host bridge windows from ACPI; if necessary, u=
se "pci=3Duse_crs" and report a bug
[    0.500139] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.501674] pci_root PNP0A03:00: host bridge window [io  0x0000-0x0cf7] =
(ignored)
[    0.504039] pci_root PNP0A03:00: host bridge window [io  0x0d00-0xffff] =
(ignored)
[    0.505886] pci_root PNP0A03:00: host bridge window [mem 0x000a0000-0x00=
0bffff] (ignored)
[    0.508041] pci_root PNP0A03:00: host bridge window [mem 0xe0000000-0xfe=
bfffff] (ignored)
[    0.510016] PCI: root bus 00: using default resources
[    0.511361] pci_root PNP0A03:00: fail to add MMCONFIG information, can't=
 access extended PCI configuration space under this bridge.
[    0.516324] PCI host bridge to bus 0000:00
[    0.517491] pci_bus 0000:00: busn_res: [bus 00-ff] is inserted under dom=
ain [bus 00-ff]
[    0.520040] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.521351] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.522787] pci_bus 0000:00: root bus resource [mem 0x00000000-0xfffffff=
fff]
[    0.522787] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.523660] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.528715] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.530584] pci 0000:00:01.1: reg 20: [io  0xc000-0xc00f]
[    0.532378] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.534409] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX=
4 ACPI
[    0.536057] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX=
4 SMB
[    0.537996] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.539356] pci 0000:00:02.0: reg 10: [mem 0xf0000000-0xf1ffffff pref]
[    0.545486] pci 0000:00:02.0: reg 14: [mem 0xf2000000-0xf2000fff]
[    0.551339] pci 0000:00:02.0: reg 30: [mem 0xf2010000-0xf201ffff pref]
[    0.557020] pci 0000:00:03.0: [8086:100e] type 00 class 0x020000
[    0.558723] pci 0000:00:03.0: reg 10: [mem 0xf2020000-0xf203ffff]
[    0.560177] pci 0000:00:03.0: reg 14: [io  0xc040-0xc07f]
[    0.562577] pci 0000:00:03.0: reg 30: [mem 0xf2040000-0xf2047fff pref]
[    0.564497] pci 0000:00:04.0: [1af4:1001] type 00 class 0x010000
[    0.566087] pci 0000:00:04.0: reg 10: [io  0xc080-0xc0bf]
[    0.567412] pci 0000:00:04.0: reg 14: [mem 0xf2048000-0xf2048fff]
[    0.567412] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.568211] pci 0000:00:05.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.569557] pci 0000:00:05.0: reg 14: [mem 0xf2049000-0xf2049fff]
[    0.572494] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.574050] pci 0000:00:06.0: reg 10: [io  0xc100-0xc13f]
[    0.575489] pci 0000:00:06.0: reg 14: [mem 0xf204a000-0xf204afff]
[    0.580910] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.582516] pci 0000:00:07.0: reg 10: [io  0xc140-0xc17f]
[    0.583831] pci 0000:00:07.0: reg 14: [mem 0xf204b000-0xf204bfff]
[    0.583831] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.584217] pci 0000:00:08.0: reg 10: [io  0xc180-0xc1bf]
[    0.585564] pci 0000:00:08.0: reg 14: [mem 0xf204c000-0xf204cfff]
[    0.588549] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.590130] pci 0000:00:09.0: reg 10: [io  0xc1c0-0xc1ff]
[    0.591610] pci 0000:00:09.0: reg 14: [mem 0xf204d000-0xf204dfff]
[    0.596882] pci 0000:00:0a.0: [8086:25ab] type 00 class 0x088000
[    0.598368] pci 0000:00:0a.0: reg 10: [mem 0xf204e000-0xf204e00f]
[    0.601061] ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
[    0.603209]  pci0000:00: ACPI _OSC support notification failed, disablin=
g PCIe ASPM
[    0.604049]  pci0000:00: Unable to request _OSC control (_OSC support ma=
sk: 0x08)
[    0.632924] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.635144] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.637277] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.639461] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.642492] vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=
=3Dio+mem,locks=3Dnone
[    0.648072] vgaarb: loaded
[    0.648826] vgaarb: bridge control possible 0000:00:02.0
[    0.650619] tps65010: version 2 May 2005
[    0.684130] tps65010: no chip?
[    0.686241] SCSI subsystem initialized
[    0.687374] ACPI: bus type scsi registered
[    0.692204] libata version 3.00 loaded.
[    0.693521] ACPI: bus type usb registered
[    0.694785] usbcore: registered new interface driver usbfs
[    0.694785] usbcore: registered new interface driver hub
[    0.696165] usbcore: registered new device driver usb
[    0.696528] pps_core: LinuxPPS API ver. 1 registered
[    0.698157] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo =
Giometti <giometti@linux.it>
[    0.704482] wmi: Mapper loaded
[    0.705913] Advanced Linux Sound Architecture Driver Version 1.0.25.
[    0.716111] PCI: Using ACPI for IRQ routing
[    0.717150] PCI: pci_cache_line_size set to 64 bytes
[    0.718849] e820: reserve RAM buffer [mem 0x0009f400-0x0009ffff]
[    0.718849] e820: reserve RAM buffer [mem 0x1fffd000-0x1fffffff]
[    0.720245] Sangoma WANPIPE Router v1.1 (c) 1995-2000 Sangoma Technologi=
es Inc.
[    0.722235] NET: Registered protocol family 23
[    0.723713] Bluetooth: Core ver 2.16
[    0.724168] NET: Registered protocol family 31
[    0.725242] Bluetooth: HCI device and connection manager initialized
[    0.726760] Bluetooth: HCI socket layer initialized
[    0.728054] Bluetooth: L2CAP socket layer initialized
[    0.729250] Bluetooth: SCO socket layer initialized
[    0.730488] NET: Registered protocol family 8
[    0.732052] NET: Registered protocol family 20
[    0.736164] cfg80211: Calling CRDA to update world regulatory domain
[    0.742678] HPET: 3 timers in total, 0 timers will be used for per-cpu t=
imer
[    0.744105] hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0
[    0.745953] hpet0: 3 comparators, 64-bit 100.000000 MHz counter
[    0.752820] Switching to clocksource kvm-clock
[    1.106226] FS-Cache: Loaded
[    1.107331] CacheFiles: Loaded
[    1.108136] pnp: PnP ACPI init
[    1.108849] ACPI: bus type pnp registered
[    1.109763] pnp 00:00: [bus 00-ff]
[    1.110487] pnp 00:00: [io  0x0cf8-0x0cff]
[    1.111413] pnp 00:00: [io  0x0000-0x0cf7 window]
[    1.112198] pnp 00:00: [io  0x0d00-0xffff window]
[    1.112974] pnp 00:00: [mem 0x000a0000-0x000bffff window]
[    1.114131] pnp 00:00: [mem 0xe0000000-0xfebfffff window]
[    1.115402] pnp 00:00: Plug and Play ACPI device, IDs PNP0a03 (active)
[    1.116701] pnp 00:01: [io  0x0070-0x0071]
[    1.117646] pnp 00:01: [irq 8]
[    1.118268] pnp 00:01: [io  0x0072-0x0077]
[    1.119338] pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
[    1.120682] pnp 00:02: [io  0x0060]
[    1.121580] pnp 00:02: [io  0x0064]
[    1.122325] pnp 00:02: [irq 1]
[    1.123073] pnp 00:02: Plug and Play ACPI device, IDs PNP0303 (active)
[    1.124379] pnp 00:03: [irq 12]
[    1.125150] pnp 00:03: Plug and Play ACPI device, IDs PNP0f13 (active)
[    1.126467] pnp 00:04: [io  0x03f2-0x03f5]
[    1.127282] pnp 00:04: [io  0x03f7]
[    1.127936] pnp 00:04: [irq 6]
[    1.128567] pnp 00:04: [dma 2]
[    1.129486] pnp 00:04: Plug and Play ACPI device, IDs PNP0700 (active)
[    1.136477] pnp 00:05: [io  0x0378-0x037f]
[    1.137321] pnp 00:05: [irq 7]
[    1.138134] pnp 00:05: Plug and Play ACPI device, IDs PNP0400 (active)
[    1.139532] pnp 00:06: [io  0x03f8-0x03ff]
[    1.140389] pnp 00:06: [irq 4]
[    1.141200] pnp 00:06: Plug and Play ACPI device, IDs PNP0501 (active)
[    1.142554] pnp 00:07: [mem 0xfed00000-0xfed003ff]
[    1.143629] pnp 00:07: Plug and Play ACPI device, IDs PNP0103 (active)
[    1.145032] pnp: PnP ACPI: found 8 devices
[    1.145907] ACPI: ACPI bus type pnp unregistered
[    1.169796] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    1.170963] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    1.172583] NET: Registered protocol family 2
[    1.175054] TCP established hash table entries: 16384 (order: 6, 262144 =
bytes)
[    1.177055] TCP bind hash table entries: 16384 (order: 8, 1310720 bytes)
[    1.180195] TCP: Hash tables configured (established 16384 bind 16384)
[    1.181609] TCP: reno registered
[    1.182403] UDP hash table entries: 256 (order: 3, 49152 bytes)
[    1.183679] UDP-Lite hash table entries: 256 (order: 3, 49152 bytes)
[    1.185437] NET: Registered protocol family 1
[    1.187450] RPC: Registered named UNIX socket transport module.
[    1.188506] RPC: Registered udp transport module.
[    1.189580] RPC: Registered tcp transport module.
[    1.190509] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.191741] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    1.192830] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    1.194048] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    1.195241] pci 0000:00:02.0: Boot video device
[    1.196157] PCI: CLS 0 bytes, default 64
[    1.228928] DMA-API: preallocated 32768 debug entries
[    1.229974] DMA-API: debugging enabled by kernel config
[    1.232976] kvm: no hardware support
[    1.233838] has_svm: not amd
[    1.234469] kvm: no hardware support
[    1.235538] Machine check injector initialized
[    1.237825] microcode: CPU0 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.238937] microcode: CPU1 sig=3D0xf61, pf=3D0x1, revision=3D0x1
[    1.240491] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.f=
snet.co.uk>, Peter Oruba
[    1.242630] cryptomgr_test (29) used greatest stack depth: 6520 bytes le=
ft
[    1.247377] Initializing RT-Tester: OK
[    1.248253] audit: initializing netlink socket (disabled)
[    1.249322] type=3D2000 audit(1344591474.244:1): initialized
[    1.305642] Kprobe smoke test started
[    1.376152] Kprobe smoke test passed successfully
[    1.380099] Testing tracer function: [    1.735614] kwatchdog (41) used =
greatest stack depth: 6264 bytes left
PASSED
[    1.738202] Testing dynamic ftrace: PASSED
[    2.220568] Testing dynamic ftrace ops #1: (1 0 1 1 0) (1 1 2 1 0) (2 1 =
3 1 13) (2 2 4 1 302) PASSED
[    2.909296] Testing dynamic ftrace ops #2: (1 0 1 4 0) (1 1 2 170 0) (2 =
1 3 1 5) (2 2 4 461 465) PASSED
[    3.669550] Testing tracer irqsoff: PASSED
[    4.192335] Testing tracer wakeup: PASSED
[    5.000112] Testing tracer wakeup_rt: PASSED
[    5.840127] Testing tracer function_graph: PASSED
[    6.426773] HugeTLB registered 2 MB page size, pre-allocated 0 pages
[    6.430082] VFS: Disk quotas dquot_6.5.2
[    6.431269] Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    6.434962] DLM installed
[    6.438174] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    6.443615] FS-Cache: Netfs 'nfs' registered for caching
[    6.447482] NFS: Registering the id_resolver key type
[    6.448767] Key type id_resolver registered
[    6.449856] Key type id_legacy registered
[    6.450800] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    6.456471] Key type cifs.spnego registered
[    6.457648] NTFS driver 2.1.30 [Flags: R/W].
[    6.459200] EFS: 1.0a - http://aeschi.ch.eu.org/efs/
[    6.460407] jffs2: version 2.2. (NAND) (SUMMARY) =20
[    6.463372] ROMFS MTD (C) 2007 Red Hat, Inc.
[    6.465292] QNX4 filesystem 0.2.3 registered.
[    6.466748] fuse init (API version 7.19)
[    6.468553] JFS: nTxBlock =3D 3462, nTxLock =3D 27699
[    6.475518] SGI XFS with ACLs, security attributes, realtime, large bloc=
k/inode numbers, no debug enabled
[    6.481634] 9p: Installing v9fs 9p2000 file system support
[    6.483032] FS-Cache: Netfs '9p' registered for caching
[    6.484710] NILFS version 2 loaded
[    6.485669] BeFS version: 0.9.3
[    6.486680] OCFS2 1.5.0
[    6.488226] ocfs2: Registered cluster interface o2cb
[    6.489732] ocfs2: Registered cluster interface user
[    6.490968] OCFS2 DLMFS 1.5.0
[    6.492147] OCFS2 User DLM kernel interface loaded
[    6.493382] OCFS2 Node Manager 1.5.0
[    6.495242] OCFS2 DLM 1.5.0
[    6.497596] Btrfs loaded
[    6.501502] GFS2 installed
[    6.502905] ceph: loaded (mds proto 32)
[    6.503945] msgmni has been set to 865
[    6.517931] async_tx: api initialized (async)
[    6.519210] Block layer SCSI generic (bsg) driver version 0.4 loaded (ma=
jor 251)
[    6.521295] io scheduler noop registered
[    6.522270] io scheduler deadline registered
[    6.523581] io scheduler cfq registered (default)
[    6.524850] start plist test
[    6.527526] end plist test
[    6.529627] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    6.530914] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    6.532407] cpcihp_zt5550: ZT5550 CompactPCI Hot Plug Driver version: 0.2
[    6.534050] cpcihp_generic: Generic port I/O CompactPCI Hot Plug Driver =
version: 0.1
[    6.535736] cpcihp_generic: not configured, disabling.
[    6.537170] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
[    6.538710] acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
[    6.540559] acpiphp: Slot [1] registered
[    6.541679] acpiphp: Slot [2] registered
[    6.542826] acpiphp: Slot [3] registered
[    6.543883] acpiphp: Slot [4] registered
[    6.545194] acpiphp: Slot [5] registered
[    6.546266] acpiphp: Slot [6] registered
[    6.547327] acpiphp: Slot [7] registered
[    6.548453] acpiphp: Slot [8] registered
[    6.549546] acpiphp: Slot [9] registered
[    6.550650] acpiphp: Slot [10] registered
[    6.551709] acpiphp: Slot [11] registered
[    6.552753] acpiphp: Slot [12] registered
[    6.554020] acpiphp: Slot [13] registered
[    6.555049] acpiphp: Slot [14] registered
[    6.556098] acpiphp: Slot [15] registered
[    6.557193] acpiphp: Slot [16] registered
[    6.558413] acpiphp: Slot [17] registered
[    6.559499] acpiphp: Slot [18] registered
[    6.560885] acpiphp: Slot [19] registered
[    6.562109] acpiphp: Slot [20] registered
[    6.563213] acpiphp: Slot [21] registered
[    6.564293] acpiphp: Slot [22] registered
[    6.565399] acpiphp: Slot [23] registered
[    6.566443] acpiphp: Slot [24] registered
[    6.567514] acpiphp: Slot [25] registered
[    6.568660] acpiphp: Slot [26] registered
[    6.569815] acpiphp: Slot [27] registered
[    6.570856] acpiphp: Slot [28] registered
[    6.571961] acpiphp: Slot [29] registered
[    6.573136] acpiphp: Slot [30] registered
[    6.574255] acpiphp: Slot [31] registered
[    6.579315] acpiphp_ibm: ibm_acpiphp_init: acpi_walk_namespace failed
[    6.581533] progear_bl: ALI M7101 PMU not found.
[    6.583387] VIA Graphics Integration Chipset framebuffer 2.4 initializing
[    6.585525] vmlfb: initializing
[    6.586454] Could not find Carillo Ranch MCH device.
[    6.587806] no IO addresses supplied
[    6.589042] hgafb: HGA card not detected.
[    6.590130] hgafb: probe of hgafb.0 failed with error -22
[    6.594076] kworker/u:0 (116) used greatest stack depth: 5352 bytes left
[    6.595591] uvesafb: failed to execute /sbin/v86d
[    6.596875] uvesafb: make sure that the v86d helper is installed and exe=
cutable
[    6.598770] uvesafb: Getting VBE info block failed (eax=3D0x4f00, err=3D=
-2)
[    6.600302] uvesafb: vbe_init() failed with -22
[    6.601421] uvesafb: probe of uvesafb.0 failed with error -22
[    6.603816] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/inpu=
t/input0
[    6.605940] ACPI: Power Button [PWRF]
[    6.621956] GHES: HEST is not enabled!
[    6.622966] ioatdma: Intel(R) QuickData Technology Driver 4.00
[    6.625250] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    6.626810] virtio-pci 0000:00:04.0: setting latency timer to 64
[    6.629131] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    6.630621] virtio-pci 0000:00:05.0: setting latency timer to 64
[    6.632792] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    6.634239] virtio-pci 0000:00:06.0: setting latency timer to 64
[    6.636591] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    6.637999] virtio-pci 0000:00:07.0: setting latency timer to 64
[    6.639743] virtio-pci 0000:00:08.0: setting latency timer to 64
[    6.641579] virtio-pci 0000:00:09.0: setting latency timer to 64
[    6.643395] XENFS: not registering filesystem on non-xen platform
[    6.645551] HDLC line discipline maxframe=3D4096
[    6.646676] N_HDLC line discipline registered.
[    6.647804] r3964: Philips r3964 Driver $Revision: 1.10 $
[    6.649132] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    6.674700] serial8250: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    6.701932] 00:06: ttyS0 at I/O 0x3f8 (irq =3D 4) is a 16550A
[    6.704338] Cyclades driver 2.6
[    6.705714] MOXA Intellio family driver version 6.0k
[    6.731208] MOXA Smartio/Industio family driver version 2.0.5
[    6.741546] Initializing Nozomi driver 2.1d
[    6.742743] RocketPort device driver module, version 2.09, 12-June-2003
[    6.744276] No rocketport ports found; unloading driver
[    6.745780] SyncLink GT
[    6.746579] SyncLink GT, tty major#247
[    6.747707] SyncLink GT no devices found
[    6.748716] SyncLink MultiPort driver $Revision: 4.38 $
[    6.773945] SyncLink MultiPort driver $Revision: 4.38 $, tty major#246
[    6.775587] SyncLink serial driver $Revision: 4.38 $
[    6.804761] SyncLink serial driver $Revision: 4.38 $, tty major#245
[    6.807185] lp: driver loaded but no devices found
[    6.808156] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 =
Exp $
[    6.809682] ac.o: No PCI boards found.
[    6.810608] ac.o: For an ISA board you must supply memory and irq parame=
ters.
[    6.812660] Non-volatile memory driver v1.3
[    6.816729] ppdev: user-space parallel port driver
[    6.820335] telclk_interrupt =3D 0xf non-mcpbl0010 hw.
[    6.821664] smapi::smapi_init, ERROR invalid usSmapiID
[    6.822655] mwave: tp3780i::tp3780I_InitializeBoardData: Error: SMAPI is=
 not available on this machine
[    6.824895] mwave: mwavedd::mwave_init: Error: Failed to initialize boar=
d data
[    6.826884] mwave: mwavedd::mwave_init: Error: Failed to initialize
[    6.828314] Linux agpgart interface v0.103
[    6.832296] SyncLink PC Card driver $Revision: 4.34 $, tty major#243
[    6.834242] ipmi message handler version 39.2
[    6.835408] ipmi device interface
[    6.836452] IPMI System Interface driver.
[    6.837871] ipmi_si: Adding default-specified kcs state machine
[    6.839565] ipmi_si: Trying default-specified kcs state machine at i/o a=
ddress 0xca2, slave address 0x0, irq 0
[    6.841972] ipmi_si: Interface detection failed
[    6.843253] ipmi_si: Adding default-specified smic state machine
[    6.844798] ipmi_si: Trying default-specified smic state machine at i/o =
address 0xca9, slave address 0x0, irq 0
[    6.847186] ipmi_si: Interface detection failed
[    6.864307] ipmi_si: Adding default-specified bt state machine
[    6.866303] ipmi_si: Trying default-specified bt state machine at i/o ad=
dress 0xe4, slave address 0x0, irq 0
[    6.870281] ipmi_si: Interface detection failed
[    6.872108] ipmi_si: Unable to find any System Interface(s)
[    6.874562] IPMI Watchdog: driver initialized
[    6.875868] Copyright (C) 2004 MontaVista Software - IPMI Powerdown via =
sys_reboot.
[    6.878395] Hangcheck: starting hangcheck timer 0.9.1 (tick is 180 secon=
ds, margin is 60 seconds).
[    6.881390] Hangcheck: Using getrawmonotonic().
[    6.882960] [drm] Initialized drm 1.1.0 20060810
[    6.885071] [drm] radeon defaulting to kernel modesetting.
[    6.886515] [drm] radeon kernel modesetting enabled.
[    6.888932] parport_pc 00:05: reported by Plug and Play ACPI
[    6.890626] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    6.989589] lp0: using parport0 (interrupt-driven).
[    7.009993] brd: module loaded
[    7.012630] FDC 0 is a S82078B
[    7.020094] loop: module loaded
[    7.021009] Compaq SMART2 Driver (v 2.6.0)
[    7.022378] HP CISS Driver (v 3.6.26)
[    7.025042] MM: desc_per_page =3D 128
[    7.030470] nbd: registered device at major 43
[    7.042793] virtio-pci 0000:00:04.0: irq 40 for MSI/MSI-X
[    7.044803] virtio-pci 0000:00:04.0: irq 41 for MSI/MSI-X
[    7.062463]  vda: unknown partition table
[    7.063746] virtio-pci 0000:00:05.0: irq 42 for MSI/MSI-X
[    7.064767] virtio-pci 0000:00:05.0: irq 43 for MSI/MSI-X
[    7.080670]  vdb: unknown partition table
[    7.081774] virtio-pci 0000:00:06.0: irq 44 for MSI/MSI-X
[    7.082686] virtio-pci 0000:00:06.0: irq 45 for MSI/MSI-X
[    7.095323]  vdc: unknown partition table
[    7.096731] virtio-pci 0000:00:07.0: irq 46 for MSI/MSI-X
[    7.097909] virtio-pci 0000:00:07.0: irq 47 for MSI/MSI-X
[    7.115870]  vdd: unknown partition table
[    7.117268] virtio-pci 0000:00:08.0: irq 48 for MSI/MSI-X
[    7.118591] virtio-pci 0000:00:08.0: irq 49 for MSI/MSI-X
[    7.135151]  vde: unknown partition table
[    7.136455] virtio-pci 0000:00:09.0: irq 50 for MSI/MSI-X
[    7.137647] virtio-pci 0000:00:09.0: irq 51 for MSI/MSI-X
[    7.154261]  vdf: unknown partition table
[    7.159477] drbd: initialized. Version: 8.3.13 (api:88/proto:86-96)
[    7.160641] drbd: built-in
[    7.161278] drbd: registered as block device major 147
[    7.162400] drbd: minor_table @ 0xffff8800168ecef0
[    7.163501] ibmasm: IBM ASM Service Processor Driver version 1.0 loaded
[    7.165394] lkdtm: No crash points registered, enable through debugfs
[    7.166885] Phantom Linux Driver, version n0.9.8, init OK
[    7.168224] i2c-core: driver [isl29003] using legacy suspend method
[    7.169379] i2c-core: driver [isl29003] using legacy resume method
[    7.170720] i2c-core: driver [tsl2550] using legacy suspend method
[    7.171852] i2c-core: driver [tsl2550] using legacy resume method
[    7.173015] Silicon Labs C2 port support v. 0.51.0 - (C) 2007 Rodolfo Gi=
ometti
[    7.175111] c2port c2port0: C2 port uc added
[    7.175932] c2port c2port0: uc flash has 30 blocks x 512 bytes (15360 by=
tes total)
[    7.178073] Uniform Multi-Platform E-IDE driver
[    7.179337] piix 0000:00:01.1: IDE controller (0x8086:0x7010 rev 0x00)
[    7.180719] piix 0000:00:01.1: not 100% native mode: will probe irqs lat=
er
[    7.182054]     ide0: BM-DMA at 0xc000-0xc007
[    7.182953]     ide1: BM-DMA at 0xc008-0xc00f
[    7.183989] Probing IDE interface ide0...
[    7.752432] Probing IDE interface ide1...
[    8.488221] hdc: QEMU DVD-ROM, ATAPI CD/DVD-ROM drive
[    9.160370] hdc: host max PIO4 wanted PIO255(auto-tune) selected PIO0
[    9.162070] hdc: MWDMA2 mode selected
[    9.163238] ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
[    9.164620] ide1 at 0x170-0x177,0x376 on irq 15
[    9.167157] ide_generic: please use "probe_mask=3D0x3f" module parameter=
 for probing all legacy ISA IDE ports
[    9.169644] ide-gd driver 1.18
[    9.170475] ide-cd driver 5.00
[    9.172981] ide-cd: hdc: ATAPI 4X CD-ROM drive, 512kB Cache
[    9.175319] cdrom: Uniform CD-ROM driver Revision: 3.20
[    9.181404] Loading iSCSI transport class v2.0-870.
[    9.183876] rdac: device handler registered
[    9.186133] hp_sw: device handler registered
[    9.187566] emc: device handler registered
[    9.188969] alua: device handler registered
[    9.191586] fnic: Cisco FCoE HBA Driver, ver 1.5.0.2
[    9.194783] iscsi: registered transport (tcp)
[    9.196377] Loading Adaptec I2O RAID: Version 2.4 Build 5go
[    9.198026] Detecting Adaptec I2O RAID controllers...
[    9.200044] Adaptec aacraid driver 1.2-0[29800]-ms
[    9.202441] aic94xx: Adaptec aic94xx SAS/SATA driver version 1.0.3 loaded
[    9.206133] scsi: <fdomain> Detection failed (no card)
[    9.207951] qla2xxx [0000:00:00.0]-0005: : QLogic Fibre Channel HBA Driv=
er: 8.04.00.03-k.
[    9.211023] iscsi: registered transport (qla4xxx)
[    9.212736] QLogic iSCSI HBA Driver
[    9.214604] Brocade BFA FC/FCOE SCSI driver - version: 3.0.23.0
[    9.216980] DC390: clustering now enabled by default. If you get problem=
s load
[    9.219374]        with "disable_clustering=3D1" and report to maintaine=
rs
[    9.221801] megaraid cmm: 2.20.2.7 (Release Date: Sun Jul 16 00:01:03 ES=
T 2006)
[    9.225435] megaraid: 2.20.5.1 (Release Date: Thu Nov 16 15:32:35 EST 20=
06)
[    9.227703] megasas: 00.00.06.15-rc1 Mon. Mar. 19 17:00:00 PDT 2012
[    9.229818] mpt2sas version 13.100.00.00 loaded
[    9.231775] GDT-HA: Storage RAID Controller Driver. Version: 3.05
[    9.234670] 3ware Storage Controller device driver for Linux v1.26.02.00=
3.
[    9.236469] 3ware 9000 Storage Controller device driver for Linux v2.26.=
02.014.
[    9.238698] LSI 3ware SAS/SATA-RAID Controller device driver for Linux v=
3.26.02.000.
[    9.240965] ppa: Version 2.07 (for Linux 2.4.x)
[    9.244907] imm: Version 2.05 (for Linux 2.4.0)
[    9.246926] ipr: IBM Power RAID SCSI Device Driver version: 2.5.3 (March=
 10, 2012)
[    9.249188] RocketRAID 3xxx/4xxx Controller driver v1.6 (091225)
[    9.251003] stex: Promise SuperTrak EX Driver version: 4.6.0000.4
[    9.252938] libcxgbi:libcxgbi_init_module: tag itt 0x1fff, 13 bits, age =
0xf, 4 bits.
[    9.255111] libcxgbi:ddp_setup_host_page_size: system PAGE 4096, ddp idx=
 0.
[    9.256957] Chelsio T3 iSCSI Driver cxgb3i v2.0.0 (Jun. 2010)
[    9.258707] iscsi: registered transport (cxgb3i)
[    9.260077] Broadcom NetXtreme II iSCSI Driver bnx2i v2.7.2.2 (Apr 25, 2=
012)
[    9.262084] iscsi: registered transport (bnx2i)
[    9.264591] iscsi: registered transport (be2iscsi)
[    9.266217] VMware PVSCSI driver - version 1.0.2.0-k
[    9.267545] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    9.268987] osst :I: Tape driver with OnStream support version 0.99.4
[    9.268987] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    9.272266] SCSI Media Changer driver v0.25=20
[    9.273277] osd: LOADED open-osd 0.2.1
[    9.285555] scsi_debug: host protection
[    9.286366] scsi0 : scsi_debug, version 1.82 [20100324], dev_size_mb=3D8=
, opts=3D0x0
[    9.289120] scsi 0:0:0:0: Direct-Access     Linux    scsi_debug       00=
04 PQ: 0 ANSI: 5
[    9.292106] sd 0:0:0:0: [sda] 16384 512-byte logical blocks: (8.38 MB/8.=
00 MiB)
[    9.294451] sd 0:0:0:0: Attached scsi generic sg0 type 0
[    9.296099] sd 0:0:0:0: [sda] Write Protect is off
[    9.297222] sd 0:0:0:0: [sda] Mode Sense: 73 00 10 08
[    9.302544] SSFDC read-only Flash Translation layer
[    9.303485] mtdoops: mtd device (mtddev=3Dname/number) must be supplied
[    9.304592] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled,=
 supports DPO and FUA
[    9.306665] SBC-GXx flash: IO:0x258-0x259 MEM:0xdc000-0xdffff
[    9.307772] NetSc520 flash device: 0x100000 at 0x200000
[    9.308901] Failed to ioremap_nocache
[    9.316108] Failed to ioremap_nocache
[    9.317508] Generic platform RAM MTD, (c) 2004 Simtec Electronics
[    9.346968] No recognised DiskOnChip devices found
[    9.348226] slram: not enough parameters.
[    9.349290] Ramix PMC551 PCI Mezzanine Ram Driver. (C) 1999,2000 Nortel =
Networks.
[    9.351401] pmc551: not detected
[    9.355482] kworker/u:2 (136) used greatest stack depth: 5000 bytes left
[    9.359744] ftl_cs: FTL header not found.
[    9.380112]  sda: unknown partition table
[    9.394504] No valid DiskOnChip devices found
[    9.395720] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.399070] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.402191] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.402288] sd 0:0:0:0: [sda] Attached SCSI disk
[    9.406998] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.409878] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.412427] [nandsim] warning: read_byte: unexpected data output cycle, =
state is STATE_READY return 0x0
[    9.415247] NAND device: Manufacturer ID: 0x98, Chip ID: 0x39 (Toshiba N=
AND 128MiB 1,8V 8-bit), page size: 512, OOB size: 16
[    9.418411] flash size: 128 MiB
[    9.419417] page size: 512 bytes
[    9.420274] OOB area size: 16 bytes
[    9.421030] sector size: 16 KiB
[    9.422379] pages number: 262144
[    9.423262] pages per sector: 32
[    9.423908] bus width: 8
[    9.424562] bits in sector size: 14
[    9.425671] bits in page size: 9
[    9.426693] bits in OOB size: 4
[    9.427566] flash size with OOB: 135168 KiB
[    9.428755] page address bytes: 4
[    9.429690] sector address bytes: 3
[    9.430827] options: 0x42
[    9.435013] Scanning device for bad blocks
[    9.501117] Creating 1 MTD partitions on "NAND 128MiB 1,8V 8-bit":
[    9.502798] 0x000000000000-0x000008000000 : "NAND simulator partition 0"
[    9.505573] ftl_cs: FTL header not found.
[    9.508378] usbcore: registered new interface driver alauda
[    9.552063] onenand_wait: timeout! ctrl=3D0x0000 intr=3D0x0000
[    9.553093] OneNAND Manufacturer: Samsung (0xec)
[    9.554602] OneNAND 16MB 1.8V 16-bit (0x04)
[    9.555435] OneNAND version =3D 0x001e
[    9.556091] Lock scheme is Continuous Lock
[    9.556984] Scanning device for bad blocks
[    9.561738] kworker/u:0 (146) used greatest stack depth: 4840 bytes left
[    9.563251] Creating 1 MTD partitions on "OneNAND simulator":
[    9.564335] 0x000000000000-0x000001000000 : "OneNAND simulator partition"
[    9.566286] ftl_cs: FTL header not found.
[    9.684750] parport_pc 00:05: master is unqueued, this is deprecated
[    9.696341] parport0: AVR Butterfly
[    9.697420] parport0: cannot grant exclusive access for device spi-lm70l=
lp
[    9.699154] spi-lm70llp: spi_lm70llp probe fail, status -12
[    9.700671] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27, =
2011)
[    9.712865] eql: Equalizer2002: Simon Janes (simon@ncm.com) and David S.=
 Miller (davem@redhat.com)
[    9.718545] tun: Universal TUN/TAP device driver, 1.6
[    9.719503] tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
[    9.720836] arcnet loaded.
[    9.721407] arcnet: RFC1201 "standard" (`a') encapsulation support loade=
d.
[    9.722596] arcnet: RFC1051 "simple standard" (`s') encapsulation suppor=
t loaded.
[    9.723990] arcnet: raw mode (`r') encapsulation support loaded.
[    9.725033] arcnet: cap mode (`c') encapsulation support loaded.
[    9.726228] arcnet: COM90xx chipset support
[   10.027096] S3: No ARCnet cards found.
[   10.027981] arcnet: COM90xx IO-mapped mode support (by David Woodhouse e=
t el.)
[   10.029574] E-mail me if you actually test this driver, please!
[   10.030654]  arc%d: No autoprobe for IO mapped cards; you must specify t=
he base address!
[   10.032127] arcnet: RIM I (entirely mem-mapped) support
[   10.033064] E-mail me if you actually test the RIM I driver, please!
[   10.034393] Given: node 00h, shmem 0h, irq 0
[   10.035222] No autoprobe for RIM I; you must specify the shmem and irq!
[   10.036332] arcnet: COM20020 PCI support
[   10.037316] ipddp.c:v0.01 8/28/97 Bradford W. Johnson <johns393@maroon.t=
c.umn.edu>
[   10.039725] ipddp0: Appletalk-IP Encap. mode by Bradford W. Johnson <joh=
ns393@maroon.tc.umn.edu>
[   10.041323] vcan: Virtual CAN interface driver
[   10.042228] CAN device driver interface
[   10.043032] usbcore: registered new interface driver ems_usb
[   10.044132] sja1000 CAN netdevice driver
[   10.045557] cnic: Broadcom NetXtreme II CNIC Driver cnic v2.5.12 (June 2=
9, 2012)
[   10.047128] bnx2x: Broadcom NetXtreme II 5771x/578xx 10/20-Gigabit Ether=
net Driver bnx2x 1.72.51-0 (2012/06/18)
[   10.049824] enic: Cisco VIC Ethernet NIC Driver, ver 2.1.1.39
[   10.051262] vxge: Copyright(c) 2002-2010 Exar Corp.
[   10.052161] vxge: Driver version: 2.5.3.22640-k
[   10.053036] e1000: Intel(R) PRO/1000 Network Driver - version 7.3.21-k8-=
NAPI
[   10.054440] e1000: Copyright (c) 1999-2006 Intel Corporation.
[   10.055686] e1000 0000:00:03.0: setting latency timer to 64
[   10.418120] e1000 0000:00:03.0: eth0: (PCI:33MHz:32-bit) 52:54:00:12:34:=
56
[   10.419837] e1000 0000:00:03.0: eth0: Intel(R) PRO/1000 Network Connecti=
on
[   10.421578] e1000e: Intel(R) PRO/1000 Network Driver - 2.0.0-k
[   10.422976] e1000e: Copyright(c) 1999 - 2012 Intel Corporation.
[   10.424510] igb: Intel(R) Gigabit Ethernet Network Driver - version 4.0.=
1-k
[   10.426188] igb: Copyright (c) 2007-2012 Intel Corporation.
[   10.427591] igbvf: Intel(R) Gigabit Virtual Function Network Driver - ve=
rsion 2.0.1-k
[   10.429428] igbvf: Copyright (c) 2009 - 2012 Intel Corporation.
[   10.430980] ixgbe: Intel(R) 10 Gigabit PCI Express Network Driver - vers=
ion 3.9.15-k
[   10.432922] ixgbe: Copyright (c) 1999-2012 Intel Corporation.
[   10.434490] ixgbevf: Intel(R) 10 Gigabit PCI Express Virtual Function Ne=
twork Driver - version 2.6.0-k
[   10.436719] ixgbevf: Copyright (c) 2009 - 2012 Intel Corporation.
[   10.438311] ixgb: Intel(R) PRO/10GbE Network Driver - version 1.0.135-k2=
-NAPI
[   10.439895] ixgb: Copyright (c) 1999-2008 Intel Corporation.
[   10.441471] jme: JMicron JMC2XX ethernet driver version 1.0.8
[   10.443069] sky2: driver version 1.30
[   10.444629] myri10ge: Version 1.5.3-1.534
[   10.445783] ns83820.c: National Semiconductor DP83820 10/100/1000 driver.
[   10.447665] QLogic 1/10 GbE Converged/Intelligent Ethernet Driver v5.0.29
[   10.449972] QLogic/NetXen Network Driver v4.0.80
[   10.451418] Solarflare NET driver v3.1
[   10.453082] tehuti: Tehuti Networks(R) Network Driver, 7.29.3
[   10.454542] tehuti: Options: hw_csum=20
[   10.456039] mkiss: AX.25 Multikiss, Hans Albas PE1AYX
[   10.457265] AX.25: 6pack driver, Revision: 0.3.0
[   10.458491] YAM driver version 0.8 by F1OAT/F6FBB
[   10.461641] AX.25: bpqether driver version 004
[   10.463232] baycom_ser_fdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   10.463232] baycom_ser_fdx: version 0.10
[   10.469519] hdlcdrv: (C) 1996-2000 Thomas Sailer HB9JNX/AE4WA
[   10.471106] hdlcdrv: version 0.8
[   10.471951] baycom_ser_hdx: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   10.471951] baycom_ser_hdx: version 0.10
[   10.476932] baycom_par: (C) 1996-2000 Thomas Sailer, HB9JNX/AE4WA
[   10.476932] baycom_par: version 0.9
[   10.482228] usbcore: registered new interface driver irda-usb
[   10.483792] usbcore: registered new interface driver stir4200
[   10.486778] usbcore: registered new interface driver mcs7780
[   10.488535] usbcore: registered new interface driver kingsun-sir
[   10.490109] usbcore: registered new interface driver ksdazzle-sir
[   10.491834] usbcore: registered new interface driver ks959-sir
[   10.494089] NET3 PLIP version 2.4-parport gniibe@mri.co.jp
[   10.495397] plip0: Parallel port at 0x378, using IRQ 7.
[   10.496650] PPP generic driver version 2.4.2
[   10.498200] PPP BSD Compression module registered
[   10.499411] PPP Deflate Compression module registered
[   10.500909] PPP MPPE Compression module registered
[   10.502173] NET: Registered protocol family 24
[   10.503423] SLIP: version 0.8.4-NET3.019-NEWTTY (dynamic channels, max=
=3D256) (6 bit encapsulation enabled).
[   10.505805] CSLIP: code copyright 1989 Regents of the University of Cali=
fornia.
[   10.507703] SLIP linefill/keepalive option.
[   10.508898] hdlc: HDLC support module revision 1.22
[   10.510820] DLCI driver v0.35, 4 Jan 1997, mike.mclagan@linux.org.
[   10.512254] cycx_drv: Cyclom 2X Support Module v0.6 (c) 1998-2003 Arnald=
o Carvalho de Melo <acme@conectiva.com.br>
[   10.514858] cyclomx: CYCLOM 2X(tm) Sync Card Driver v0.11 (c) 1998-2003 =
Arnaldo Carvalho de Melo <acme@conectiva.com.br>
[   10.517604] ipw2200: Intel(R) PRO/Wireless 2200/2915 Network Driver, 1.2=
=2E2kmprq
[   10.519460] ipw2200: Copyright(c) 2003-2006 Intel Corporation
[   10.521279] libipw: 802.11 data/management/control stack, git-1.1.13
[   10.522827] libipw: Copyright (C) 2004-2005 Intel Corporation <jketreno@=
linux.intel.com>
[   10.524881] orinoco 0.15 (David Gibson <hermes@gibson.dropbear.id.au>, P=
avel Roskin <proski@gnu.org>, et al)
[   10.527276] orinoco_plx 0.15 (Pavel Roskin <proski@gnu.org>, David Gibso=
n <hermes@gibson.dropbear.id.au>, Daniel Barlow <dan@telent.net>)
[   10.530227] orinoco_tmd 0.15 (Joerg Dorchain <joerg@dorchain.net>)
[   10.532431] orinoco_nortel 0.15 (Tobias Hoffmann & Christoph Jungegger <=
disdos@traum404.de>)
[   10.534887] usbcore: registered new interface driver orinoco_usb
[   10.536300] airo(): Probing for PCI adapters
[   10.537134] airo(): Finished probing for PCI adapters
[   10.538225] Atmel at76x USB Wireless LAN Driver 0.17 loading
[   10.539343] usbcore: registered new interface driver at76c50x-usb
[   10.547853] Broadcom 43xx driver loaded [ Features: PMLS ]
[   10.548892] Broadcom 43xx-legacy driver loaded [ Features: PLID ]
[   10.550850] usbcore: registered new interface driver zd1211rw
[   10.553109] usbcore: registered new interface driver rtl8187
[   10.554980] usbcore: registered new interface driver rndis_wlan
[   10.556270] usbcore: registered new interface driver zd1201
[   10.557298] usbcore: registered new interface driver usb8xxx
[   10.558507] libertas_sdio: Libertas SDIO driver
[   10.559718] libertas_sdio: Copyright Pierre Ossman
[   10.560926] libertas_spi: Libertas SPI driver
[   10.562399] usbcore: registered new interface driver lbtf_usb
[   10.563503] Intel(R) Wireless WiFi driver for Linux, in-tree:
[   10.564827] Copyright(c) 2003-2012 Intel Corporation
[   10.566325] iwldvm: Intel(R) Wireless WiFi Link AGN driver for Linux, in=
-tree:
[   10.568254] iwldvm: Copyright(c) 2003-2012 Intel Corporation
[   10.569935] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection=
 driver for Linux, in-tree:s
[   10.572238] iwl3945: Copyright(c) 2003-2011 Intel Corporation
[   10.574400] usbcore: registered new interface driver rt2500usb
[   10.575546] usbcore: registered new interface driver rt73usb
[   10.576513] usbcore: registered new interface driver rt2800usb
[   10.577589] usbcore: registered new interface driver p54usb
[   10.578931] usbcore: registered new interface driver ath9k_htc
[   10.579964] mac80211_hwsim: Initializing radio 0
[   10.581730] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
[   10.583499] ieee80211 phy0: hwaddr 020000000000 registered
[   10.584782] mac80211_hwsim: Initializing radio 1
[   10.587055] ieee80211 phy1: Selected rate control algorithm 'minstrel_ht'
[   10.588712] ieee80211 phy1: hwaddr 020000000100 registered
[   10.590161] mac80211_hwsim: initializing netlink
[   10.591204] usbcore: registered new interface driver i2400m_usb
[   10.592232] VMware vmxnet3 virtual NIC driver - version 1.1.29.0-k-NAPI
[   10.593429] usbcore: registered new interface driver catc
[   10.594665] usbcore: registered new interface driver kaweth
[   10.595557] pegasus: v0.6.14 (2006/09/27), Pegasus/Pegasus II USB Ethern=
et driver
[   10.596861] usbcore: registered new interface driver pegasus
[   10.597938] usbcore: registered new interface driver rtl8150
[   10.599233] hso: /c/kernel-tests/src/stable/drivers/net/usb/hso.c: Optio=
n Wireless
[   10.601199] usbcore: registered new interface driver hso
[   10.602586] usbcore: registered new interface driver asix
[   10.603582] usbcore: registered new interface driver cdc_ether
[   10.604778] usbcore: registered new interface driver cdc_eem
[   10.605897] usbcore: registered new interface driver dm9601
[   10.606847] usbcore: registered new interface driver smsc75xx
[   10.607801] usbcore: registered new interface driver smsc95xx
[   10.608811] usbcore: registered new interface driver gl620a
[   10.609905] usbcore: registered new interface driver net1080
[   10.611018] usbcore: registered new interface driver plusb
[   10.612176] usbcore: registered new interface driver rndis_host
[   10.613770] usbcore: registered new interface driver cdc_subset
[   10.615177] usbcore: registered new interface driver zaurus
[   10.616340] usbcore: registered new interface driver MOSCHIP usb-etherne=
t driver
[   10.618374] usbcore: registered new interface driver int51x1
[   10.619864] usbcore: registered new interface driver cdc_phonet
[   10.621316] usbcore: registered new interface driver ipheth
[   10.622788] usbcore: registered new interface driver sierra_net
[   10.624259] usbcore: registered new interface driver cdc_ncm
[   10.625783] Madge ATM Ambassador driver version 1.2.4
[   10.627137] Madge ATM Horizon [Ultra] driver version 1.2.1
[   10.628694] fore200e: FORE Systems 200E-series ATM driver - version 0.3e
[   10.630619] idt77252_init: at ffffffff83b38696
[   10.631877] Solos PCI Driver Version 0.07
[   10.633071] adummy: version 1.0
[   10.634804] I2O subsystem v1.325
[   10.635742] i2o: max drivers =3D 8
[   10.637186] I2O Configuration OSM v1.323
[   10.638751] I2O Bus Adapter OSM v1.317
[   10.639842] I2O Block Device OSM v1.325
[   10.642013] I2O SCSI Peripheral OSM v1.316
[   10.643142] I2O ProcFS OSM v1.316
[   10.644166] Fusion MPT base driver 3.04.20
[   10.645251] Copyright (c) 1999-2008 LSI Corporation
[   10.646607] Fusion MPT SPI Host driver 3.04.20
[   10.647902] Fusion MPT FC Host driver 3.04.20
[   10.648813] Fusion MPT SAS Host driver 3.04.20
[   10.650239] Fusion MPT misc device (ioctl) driver 3.04.20
[   10.651907] mptctl: Registered with Fusion MPT base driver
[   10.653313] mptctl: /dev/mptctl @ (major,minor=3D10,220)
[   10.654682] Fusion MPT LAN driver 3.04.20
[   10.656968] Generic UIO driver for PCI 2.3 devices version: 0.01.0
[   10.660800] aoe: AoE v47 initialised.
[   10.663405] usbcore: registered new interface driver hwa-rc
[   10.664862] usbcore: registered new interface driver i1480-dfu-usb
[   10.667065] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[   10.668839] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[   10.670603] uhci_hcd: USB Universal Host Controller Interface driver
[   10.672194] driver u132_hcd
[   10.673043] usbcore: registered new interface driver hwa-hc
[   10.674501] usbcore: registered new interface driver wusb-cbaf
[   10.675503] usbcore: registered new interface driver cdc_acm
[   10.676485] cdc_acm: USB Abstract Control Model driver for USB modems an=
d ISDN adapters
[   10.677996] usbcore: registered new interface driver usblp
[   10.678940] usbcore: registered new interface driver cdc_wdm
[   10.679913] usbcore: registered new interface driver usbtmc
[   10.680970] Initializing USB Mass Storage driver...
[   10.682019] usbcore: registered new interface driver usb-storage
[   10.682976] USB Mass Storage support registered.
[   10.683934] usbcore: registered new interface driver ums-alauda
[   10.685005] usbcore: registered new interface driver ums-cypress
[   10.686143] usbcore: registered new interface driver ums-datafab
[   10.687166] usbcore: registered new interface driver ums-freecom
[   10.688163] usbcore: registered new interface driver ums-isd200
[   10.689247] usbcore: registered new interface driver ums-jumpshot
[   10.690702] usbcore: registered new interface driver ums-karma
[   10.692149] usbcore: registered new interface driver ums-onetouch
[   10.693130] usbcore: registered new interface driver ums-sddr09
[   10.694460] usbcore: registered new interface driver ums-sddr55
[   10.695483] usbcore: registered new interface driver ums-usbat
[   10.696481] usbcore: registered new interface driver mdc800
[   10.697368] mdc800: v0.7.5 (30/10/2000):USB Driver for Mustek MDC800 Dig=
ital Camera
[   10.698721] usbcore: registered new interface driver microtekX6
[   10.699810] usbcore: registered new interface driver usbserial
[   10.700883] usbcore: registered new interface driver usbserial_generic
[   10.702290] USB Serial support registered for generic
[   10.703541] usbserial: USB Serial Driver core
[   10.704588] usbcore: registered new interface driver aircable
[   10.705657] USB Serial support registered for aircable
[   10.706664] usbcore: registered new interface driver ark3116
[   10.707654] USB Serial support registered for ark3116
[   10.708675] usbcore: registered new interface driver belkin_sa
[   10.709790] USB Serial support registered for Belkin / Peracom / GoHubs =
USB Serial Adapter
[   10.711329] usbcore: registered new interface driver ch341
[   10.712458] USB Serial support registered for ch341-uart
[   10.713415] usbcore: registered new interface driver cp210x
[   10.714768] USB Serial support registered for cp210x
[   10.716124] usbcore: registered new interface driver cyberjack
[   10.717433] USB Serial support registered for Reiner SCT Cyberjack USB c=
ard reader
[   10.718890] usbcore: registered new interface driver cypress_m8
[   10.719923] USB Serial support registered for DeLorme Earthmate USB
[   10.721086] USB Serial support registered for HID->COM RS232 Adapter
[   10.722289] USB Serial support registered for Nokia CA-42 V2 Adapter
[   10.723358] usbcore: registered new interface driver usb_debug
[   10.724582] USB Serial support registered for debug
[   10.725453] usbcore: registered new interface driver digi_acceleport
[   10.726626] USB Serial support registered for Digi 2 port USB adapter
[   10.727687] USB Serial support registered for Digi 4 port USB adapter
[   10.729029] usbcore: registered new interface driver io_edgeport
[   10.730715] USB Serial support registered for Edgeport 2 port adapter
[   10.731966] USB Serial support registered for Edgeport 4 port adapter
[   10.733053] USB Serial support registered for Edgeport 8 port adapter
[   10.734440] USB Serial support registered for EPiC device
[   10.735437] usbcore: registered new interface driver io_ti
[   10.736395] USB Serial support registered for Edgeport TI 1 port adapter
[   10.737499] USB Serial support registered for Edgeport TI 2 port adapter
[   10.738641] usbcore: registered new interface driver empeg
[   10.739603] USB Serial support registered for empeg
[   10.740480] usbcore: registered new interface driver ftdi_sio
[   10.741963] USB Serial support registered for FTDI USB Serial Device
[   10.743521] ftdi_sio: v1.6.0:USB FTDI Serial Converters Driver
[   10.744964] usbcore: registered new interface driver funsoft
[   10.746126] USB Serial support registered for funsoft
[   10.747081] usbcore: registered new interface driver garmin_gps
[   10.748220] USB Serial support registered for Garmin GPS usb/tty
[   10.749511] usbcore: registered new interface driver hp4x
[   10.750548] USB Serial support registered for hp4X
[   10.751570] usbcore: registered new interface driver ipaq
[   10.752580] USB Serial support registered for PocketPC PDA
[   10.754380] usbcore: registered new interface driver ipw
[   10.755538] USB Serial support registered for IPWireless converter
[   10.757135] usbcore: registered new interface driver ir_usb
[   10.758512] USB Serial support registered for IR Dongle
[   10.759467] ir_usb: v0.5:USB IR Dongle driver
[   10.760305] usbcore: registered new interface driver iuu_phoenix
[   10.761580] USB Serial support registered for iuu_phoenix
[   10.762599] usbcore: registered new interface driver keyspan
[   10.763619] USB Serial support registered for Keyspan - (without firmwar=
e)
[   10.765026] USB Serial support registered for Keyspan 1 port adapter
[   10.766171] USB Serial support registered for Keyspan 2 port adapter
[   10.767369] USB Serial support registered for Keyspan 4 port adapter
[   10.768499] usbcore: registered new interface driver keyspan_pda
[   10.769652] USB Serial support registered for Keyspan PDA
[   10.770669] USB Serial support registered for Keyspan PDA - (prerenumera=
tion)
[   10.779927] USB Serial support registered for Xircom / Entregra PGS - (p=
rerenumeration)
[   10.781757] usbcore: registered new interface driver kl5kusb105
[   10.782925] USB Serial support registered for KL5KUSB105D / PalmConnect
[   10.784604] usbcore: registered new interface driver kobil_sct
[   10.786097] USB Serial support registered for KOBIL USB smart card termi=
nal
[   10.787850] usbcore: registered new interface driver mct_u232
[   10.789230] USB Serial support registered for MCT U232
[   10.790618] usbcore: registered new interface driver mos7720
[   10.791971] USB Serial support registered for Moschip 2 port adapter
[   10.793560] usbcore: registered new interface driver mos7840
[   10.795070] USB Serial support registered for Moschip 7840/7820 USB Seri=
al Driver
[   10.797006] usbcore: registered new interface driver moto_modem
[   10.798557] USB Serial support registered for moto-modem
[   10.799943] usbcore: registered new interface driver navman
[   10.801301] USB Serial support registered for navman
[   10.802639] usbcore: registered new interface driver omninet
[   10.804060] USB Serial support registered for ZyXEL - omni.net lcd plus =
usb
[   10.805941] usbcore: registered new interface driver opticon
[   10.807316] USB Serial support registered for opticon
[   10.808643] usbcore: registered new interface driver option
[   10.810146] USB Serial support registered for GSM modem (1-port)
[   10.811673] usbcore: registered new interface driver oti6858
[   10.813132] USB Serial support registered for oti6858
[   10.814585] usbcore: registered new interface driver pl2303
[   10.816101] USB Serial support registered for pl2303
[   10.817411] usbcore: registered new interface driver qcaux
[   10.818734] USB Serial support registered for qcaux
[   10.819989] usbcore: registered new interface driver qcserial
[   10.821424] USB Serial support registered for Qualcomm USB modem
[   10.822817] safe_serial: v0.1:USB Safe Encapsulated Serial
[   10.824224] usbcore: registered new interface driver safe_serial
[   10.825931] USB Serial support registered for safe_serial
[   10.827324] usbcore: registered new interface driver siemens_mpi
[   10.828826] USB Serial support registered for siemens_mpi
[   10.830256] usbcore: registered new interface driver sierra
[   10.831642] USB Serial support registered for Sierra USB modem
[   10.833089] usbcore: registered new interface driver spcp8x5
[   10.834732] USB Serial support registered for SPCP8x5
[   10.836074] usbcore: registered new interface driver symbolserial
[   10.837674] USB Serial support registered for symbol
[   10.839009] usbcore: registered new interface driver ti_usb_3410_5052
[   10.840568] USB Serial support registered for TI USB 3410 1 port adapter
[   10.842200] USB Serial support registered for TI USB 5052 2 port adapter
[   10.843824] ti_usb_3410_5052: v0.10:TI USB 3410/5052 Serial Driver
[   10.845485] usbcore: registered new interface driver visor
[   10.846866] USB Serial support registered for Handspring Visor / Palm OS
[   10.848458] USB Serial support registered for Sony Clie 5.0
[   10.849927] USB Serial support registered for Sony Clie 3.5
[   10.851335] usbcore: registered new interface driver whiteheat
[   10.852769] USB Serial support registered for Connect Tech - WhiteHEAT -=
 (prerenumeration)
[   10.855077] USB Serial support registered for Connect Tech - WhiteHEAT
[   10.856702] usbcore: registered new interface driver vivopay_serial
[   10.858276] USB Serial support registered for vivopay-serial
[   10.859720] usbcore: registered new interface driver zio
[   10.861060] USB Serial support registered for zio
[   10.862411] usbcore: registered new interface driver adutux
[   10.864108] usbcore: registered new interface driver appledisplay
[   10.865780] usbcore: registered new interface driver cypress_cy7c63
[   10.867285] usbcore: registered new interface driver cytherm
[   10.868729] usbcore: registered new interface driver emi26 - firmware lo=
ader
[   10.870463] usbcore: registered new interface driver emi62 - firmware lo=
ader
[   10.871984] driver ftdi-elan
[   10.873654] usbcore: registered new interface driver ftdi-elan
[   10.875226] usbcore: registered new interface driver idmouse
[   10.876706] usbcore: registered new interface driver iowarrior
[   10.878229] usbcore: registered new interface driver isight_firmware
[   10.879761] usbcore: registered new interface driver usblcd
[   10.881187] usbcore: registered new interface driver ldusb
[   10.882605] usbcore: registered new interface driver usbled
[   10.883999] usbcore: registered new interface driver legousbtower
[   10.885724] usbcore: registered new interface driver rio500
[   10.887137] usbcore: registered new interface driver usbtest
[   10.888548] usbcore: registered new interface driver trancevibrator
[   10.890129] usbcore: registered new interface driver uss720
[   10.891448] uss720: v0.6:USB Parport Cable driver for Cables using the L=
ucent Technologies USS720 Chip
[   10.893778] uss720: NOTE: this is a special purpose driver to allow nons=
tandard
[   10.895740] uss720: protocols (eg. bitbang) over USS720 usb to parallel =
cables
[   10.897639] uss720: If you just want to connect to a printer, use usblp =
instead
[   10.899577] usbcore: registered new interface driver usbsevseg
[   10.901004] usbcore: registered new interface driver sisusb
[   10.902506] usbcore: registered new interface driver cxacru
[   10.903957] usbcore: registered new interface driver speedtch
[   10.905637] usbcore: registered new interface driver ueagle-atm
[   10.906984] xusbatm: malformed module parameters
[   10.908387] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x6=
0,0x64 irq 1,12
[   10.911822] serio: i8042 KBD port at 0x60,0x64 irq 1
[   10.913128] serio: i8042 AUX port at 0x60,0x64 irq 12
[   10.915150] parport0: cannot grant exclusive access for device parkbd
[   10.996600] mousedev: PS/2 mouse device common for all mice
[   11.003790] usbcore: registered new interface driver appletouch
[   11.005774] input: AT Translated Set 2 keyboard as /devices/platform/i80=
42/serio0/input/input1
[   11.007982] usbcore: registered new interface driver bcm5974
[   11.023314] usbcore: registered new interface driver iforce
[   11.025636] usbcore: registered new interface driver xpad
[   11.027072] parport0: cannot grant exclusive access for device walkera07=
01
[   11.028675] usbcore: registered new interface driver usb_acecad
[   11.030260] usbcore: registered new interface driver aiptek
[   11.031641] usbcore: registered new interface driver gtco
[   11.033166] usbcore: registered new interface driver kbtab
[   11.034739] usbcore: registered new interface driver wacom
[   11.036793] mk712: device not present
[   11.037952] usbcore: registered new interface driver usbtouchscreen
[   11.039950] apanel: Fujitsu BIOS signature 'FJKEYINF' not found...
[   11.041708] usbcore: registered new interface driver ati_remote2
[   11.043298] cm109: Keymap for Komunikate KIP1000 phone loaded
[   11.044747] usbcore: registered new interface driver cm109
[   11.046222] cm109: CM109 phone driver: 20080805 (C) Alfred E. Heggestad
[   11.049473] usbcore: registered new interface driver keyspan_remote
[   11.051159] input: PC Speaker as /devices/platform/pcspkr/input/input2
[   11.060179] usbcore: registered new interface driver powermate
[   11.061973] usbcore: registered new interface driver yealink
[   11.064926] rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
[   11.066744] rtc0: alarms up to one day, 114 bytes nvram, hpet irqs
[   11.073141] rtc-test rtc-test.0: rtc core: registered test as rtc1
[   11.075573] rtc-test rtc-test.1: rtc core: registered test as rtc2
[   11.078106] i2c /dev entries driver
[   11.081057] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, r=
evision 0
[   11.197006] i2c-parport: adapter type unspecified
[   11.198293] i2c-parport-light: adapter type unspecified
[   11.199719] usbcore: registered new interface driver i2c-tiny-usb
[   11.201119] pps_ldisc: PPS line discipline registered
[   11.202497] Driver for 1-wire Dallas network protocol.
[   11.204116] usbcore: registered new interface driver DS9490R
[   11.205684] 1-Wire driver for the DS2760 battery monitor  chip  - (c) 20=
04-2005, Szabolcs Gyurko
[   11.208149] i2c-core: driver [max17040] using legacy suspend method
[   11.209611] i2c-core: driver [max17040] using legacy resume method
[   11.519226] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/=
i8042/serio1/input/input3
[   12.432091] i2c i2c-0: detect fail: address match, 0x2c
[   12.448105] i2c i2c-0: detect fail: address match, 0x2d
[   12.464106] i2c i2c-0: detect fail: address match, 0x2e
[   12.480079] i2c i2c-0: detect fail: address match, 0x2f
[   12.744109] applesmc: supported laptop not found!
[   12.745273] applesmc: driver init failed (ret=3D-19)!
[   20.600262] pc87360: PC8736x not detected, module not inserted
[   21.104515] usbcore: registered new interface driver pcwd_usb
[   21.105867] acquirewdt: WDT driver for Acquire single board computer ini=
tialising
[   21.107927] acquirewdt: I/O address 0x0043 already in use
[   21.109091] acquirewdt: probe of acquirewdt failed with error -5
[   21.110555] advantechwdt: WDT driver for Advantech single board computer=
 initialising
[   21.112639] advantechwdt: initialized. timeout=3D60 sec (nowayout=3D0)
[   21.114123] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[   21.115421] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[   21.116633] sc520_wdt: cannot register miscdev on minor=3D130 (err=3D-16)
[   21.118043] ib700wdt: WDT driver for IB700 single board computer initial=
ising
[   21.119763] ib700wdt: START method I/O 443 is not available
[   21.120879] ib700wdt: probe of ib700wdt failed with error -5
[   21.122074] wafer5823wdt: WDT driver for Wafer 5823 single board compute=
r initialising
[   21.123789] wafer5823wdt: I/O address 0x0443 already in use
[   21.125008] i6300esb: Intel 6300ESB WatchDog Timer Driver v0.05
[   21.126479] i6300esb: cannot register miscdev on minor=3D130 (err=3D-16)
[   21.127799] i6300ESB timer: probe of 0000:00:0a.0 failed with error -16
[   21.129193] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[   21.130535] iTCO_vendor_support: vendor-support=3D0
[   21.131583] it87_wdt: no device
[   21.132385] sc1200wdt: build 20020303
[   21.133132] sc1200wdt: io parameter must be specified
[   21.134343] pc87413_wdt: Version 1.1 at io 0x2E
[   21.135309] pc87413_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   21.136499] sbc60xxwdt: I/O address 0x0443 already in use
[   21.137656] sbc8360: failed to register misc device
[   21.138649] cpu5wdt: misc_register failed
[   21.139653] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 in=
itialising...
[   21.142441] smsc37b787_wdt: Unable to register miscdev on minor 130
[   21.143690] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG=
/DHG Super I/O chip initialising
[   21.152191] w83627hf_wdt: Watchdog already running. Resetting timeout to=
 60 sec
[   21.153813] w83627hf_wdt: cannot register miscdev on minor=3D130 (err=3D=
-16)
[   21.155199] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[   21.156327] w83697hf_wdt: watchdog not found at address 0x2e
[   21.157388] w83697hf_wdt: No W83697HF/HG could be found
[   21.158484] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Sup=
er I/O chip initialising
[   21.160448] w83697ug_wdt: No W83697UG/UF could be found
[   21.161450] w83877f_wdt: I/O address 0x0443 already in use
[   21.162617] w83977f_wdt: driver v1.00
[   21.163465] w83977f_wdt: cannot register miscdev on minor=3D130 (err=3D-=
16)
[   21.164785] machzwd: MachZ ZF-Logic Watchdog driver initializing
[   21.165939] machzwd: no ZF-Logic found
[   21.166798] sbc_epx_c3: cannot register miscdev on minor=3D130 (err=3D-1=
6)
[   21.168160] watchdog: Software Watchdog: cannot register miscdev on mino=
r=3D130 (err=3D-16).
[   21.169921] watchdog: Software Watchdog: a legacy watchdog module is pro=
bably present.
[   21.171873] softdog: Software Watchdog Timer: 0.08 initialized. soft_nob=
oot=3D0 soft_margin=3D60 sec soft_panic=3D0 (nowayout=3D0)
[   21.174758] md: linear personality registered for level -1
[   21.175790] md: raid0 personality registered for level 0
[   21.176827] md: raid1 personality registered for level 1
[   21.178156] md: raid10 personality registered for level 10
[   21.179421] md: raid6 personality registered for level 6
[   21.180284] md: raid5 personality registered for level 5
[   21.181116] md: raid4 personality registered for level 4
[   21.182235] md: multipath personality registered for level -4
[   21.183429] md: faulty personality registered for level -5
[   21.184847] device-mapper: uevent: version 1.0.3
[   21.186325] device-mapper: ioctl: 4.23.0-ioctl (2012-07-25) initialised:=
 dm-devel@redhat.com
[   21.189159] device-mapper: multipath: version 1.5.0 loaded
[   21.190435] device-mapper: multipath round-robin: version 1.0.0 loaded
[   21.191627] device-mapper: multipath queue-length: version 0.1.0 loaded
[   21.192749] device-mapper: multipath service-time: version 0.2.0 loaded
[   21.194836] device-mapper: dm-log-userspace: version 1.1.0 loaded
[   21.195980] Bluetooth: Virtual HCI driver ver 1.3
[   21.197028] Bluetooth: HCI UART driver ver 2.2
[   21.198138] Bluetooth: HCI H4 protocol initialized
[   21.199296] Bluetooth: HCI BCSP protocol initialized
[   21.200341] Bluetooth: HCILL protocol initialized
[   21.201289] usbcore: registered new interface driver bcm203x
[   21.202828] usbcore: registered new interface driver bpa10x
[   21.204447] usbcore: registered new interface driver bfusb
[   21.206248] usbcore: registered new interface driver btusb
[   21.207702] Bluetooth: Generic Bluetooth SDIO driver ver 0.1
[   21.209324] usbcore: registered new interface driver ath3k
[   21.211605] CAPI 2.0 started up with major 68 (middleware)
[   21.213073] Modular ISDN core version 1.1.29
[   21.214701] NET: Registered protocol family 34
[   21.215920] DSP module 2.0
[   21.216839] mISDN_dsp: DSP clocks every 64 samples. This equals 2 jiffie=
s.
[   21.221160] mISDN: Layer-1-over-IP driver Rev. 2.00
[   21.222871] 0 virtual devices registered
[   21.224259] b1pci: revision 1.1.2.2
[   21.225297] b1: revision 1.1.2.2
[   21.226318] b1dma: revision 1.1.2.3
[   21.227389] b1pci: revision 1.1.2.2
[   21.228724] t1pci: revision 1.1.2.2
[   21.229942] c4: revision 1.1.2.2
[   21.231069] mISDN: HFC-multi driver 2.03
[   21.232479] usbcore: registered new interface driver HFC-S_USB
[   21.234066] AVM Fritz PCI driver Rev. 2.3
[   21.235319] Sedlbauer Speedfax+ Driver Rev. 2.0
[   21.236751] Infineon ISDN Driver Rev. 1.0
[   21.238088] Winbond W6692 PCI driver Rev. 2.0
[   21.239397] mISDNipac module version 2.0
[   21.240549] mISDN: ISAR driver Rev. 2.1
[   21.241691] gigaset: Driver for Gigaset 307x
[   21.242924] gigaset: Kernel CAPI interface
[   21.244375] usbcore: registered new interface driver usb_gigaset
[   21.245983] usb_gigaset: USB Driver for Gigaset 307x using M105
[   21.247650] usbcore: registered new interface driver bas_gigaset
[   21.249220] bas_gigaset: USB Driver for Gigaset 307x
[   21.250776] EDAC MC: Ver: 3.0.0
[   21.254159] AMD64 EDAC driver v3.4.0
[   21.255501] cpuidle: using governor ladder
[   21.256724] cpuidle: using governor menu
[   21.258052] sdhci: Secure Digital Host Controller Interface driver
[   21.259637] sdhci: Copyright(c) Pierre Ossman
[   21.261012] wbsd: Winbond W83L51xD SD/MMC card interface driver
[   21.262641] wbsd: Copyright(c) Pierre Ossman
[   21.264107] via_sdmmc: VIA SD/MMC Card Reader driver (C) 2008 VIA Techno=
logies, Inc.
[   21.266448] sdhci-pltfm: SDHCI platform and OF driver helper
[   21.268901] leds_ss4200: no LED devices found
[   21.273046] user_mad: couldn't register device number
[   21.274827] user_verbs: couldn't register device number
[   21.275911] ucm: couldn't register device number
[   21.284596] ib_qib: Unable to register ipathfs
[   21.289279] iscsi: registered transport (iser)
[   21.290231] EFI Variables Facility v0.08 2004-May-17
[   21.291522] dcdbas dcdbas: Dell Systems Management Base Driver (version =
5.6.0-3.2)
[   21.292965] No iBFT detected.
[   21.296195] usbcore: registered new interface driver usbhid
[   21.297162] usbhid: USB HID core driver
[   21.298145] Linux telephony interface: v1.00
[   21.298980] ixj driver initialized.
[   21.300595] msi_laptop: driver 0.5 successfully loaded
[   21.301842] compal_laptop: Motherboard not recognized (You could try the=
 module's force-parameter)
[   21.303474] dell_wmi: No known WMI GUID found
[   21.304523] acer_wmi: Acer Laptop ACPI-WMI Extras
[   21.305431] acer_wmi: No or unsupported WMI interface, unable to load
[   21.306649] acerhdf: Acer Aspire One Fan driver, v.0.5.26
[   21.307623] acerhdf: unknown (unsupported) BIOS version Bochs/Bochs/Boch=
s, please report, aborting!
[   21.309252] hdaps: supported laptop not found!
[   21.310115] hdaps: driver init failed (ret=3D-19)!
[   21.311481] fujitsu_laptop: driver 0.6.0 successfully loaded
[   21.312528] msi_wmi: This machine doesn't have MSI-hotkeys through WMI
[   21.313978] topstar_laptop: ACPI extras driver loaded
[   21.315963] ieee802154hardmac ieee802154hardmac: Added ieee802154 HardMA=
C hardware
[   21.327131] no UART detected at 0x1
[   21.328246] MTVAP port 0x378 is busy
[   21.328994] snd_mtpav: probe of snd_mtpav failed with error -16
[   21.330325] snd_mts64: probe of snd_mts64.0 failed with error -5
[   21.331730] snd_portman2x4: probe of snd_portman2x4.0 failed with error =
-5
[   21.333091] Error: Driver 'pcspkr' is already registered, aborting...
[   21.336777] ASIHPI driver 4.10.01
[   21.341122] usbcore: registered new interface driver snd-usb-audio
[   21.342341] usbcore: registered new interface driver snd-ua101
[   21.343537] usbcore: registered new interface driver snd-usb-usx2y
[   21.344834] usbcore: registered new interface driver snd-usb-us122l
[   21.346042] usbcore: registered new interface driver snd-usb-caiaq
[   21.347273] oprofile: using NMI interrupt.
[   21.348240] pktgen: Packet Generator for packet performance testing. Ver=
sion: 2.74
[   21.350304] drop_monitor: Initializing network drop monitor service
[   21.351848] NET: Registered protocol family 26
[   21.352932] GACT probability on
[   21.353769] Mirror/redirect action on
[   21.354704] Simple TC action Loaded
[   21.355917] netem: version 1.3
[   21.356634] u32 classifier
[   21.357246]     Performance counters on
[   21.358045]     input device check on
[   21.358853]     Actions configured
[   21.359669] Netfilter messages via NETLINK v0.30.
[   21.360827] nf_conntrack version 0.5.0 (3462 buckets, 13848 max)
[   21.362676] ctnetlink v0.93: registering with nfnetlink.
[   21.364120] NF_TPROXY: Transparent proxy support initialized, version 4.=
1.0
[   21.365440] NF_TPROXY: Copyright (c) 2006-2007 BalaBit IT Ltd.
[   21.366830] xt_time: kernel timezone is -0000
[   21.367664] IPVS: Registered protocols (TCP, UDP, SCTP, AH, ESP)
[   21.368793] IPVS: Connection hash table configured (size=3D4096, memory=
=3D64Kbytes)
[   21.370534] IPVS: Creating netns size=3D3080 id=3D0
[   21.371610] IPVS: ipvs loaded.
[   21.372264] IPVS: [rr] scheduler registered.
[   21.373017] IPVS: [wrr] scheduler registered.
[   21.374202] IPVS: [lc] scheduler registered.
[   21.375063] IPVS: [wlc] scheduler registered.
[   21.375859] IPVS: [lblc] scheduler registered.
[   21.376704] IPVS: [lblcr] scheduler registered.
[   21.377601] IPVS: [dh] scheduler registered.
[   21.378410] IPVS: [sh] scheduler registered.
[   21.379184] IPVS: [sed] scheduler registered.
[   21.379983] IPVS: [nq] scheduler registered.
[   21.381022] IPVS: ftp: loaded support on port[0] =3D 21
[   21.382156] IPv4 over IPv4 tunneling driver
[   21.384204] ip_tables: (C) 2000-2006 Netfilter Core Team
[   21.385509] ipt_CLUSTERIP: ClusterIP Version 0.8 loaded successfully
[   21.386748] arp_tables: (C) 2002 David S. Miller
[   21.387671] TCP: bic registered
[   21.388325] TCP: cubic registered
[   21.388935] TCP: westwood registered
[   21.389735] TCP: highspeed registered
[   21.390488] TCP: hybla registered
[   21.391323] TCP: htcp registered
[   21.391933] TCP: vegas registered
[   21.392612] TCP: veno registered
[   21.393242] TCP: scalable registered
[   21.394180] TCP: lp registered
[   21.394899] TCP: yeah registered
[   21.400926] TCP: illinois registered
[   21.401659] Initializing XFRM netlink socket
[   21.403006] NET: Registered protocol family 10
[   21.407453] mip6: Mobile IPv6
[   21.408140] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   21.409233] sit: IPv6 over IPv4 tunneling driver
[   21.411369] NET: Registered protocol family 17
[   21.412308] NET: Registered protocol family 15
[   21.413259] Bridge firewalling registered
[   21.414248] Ebtables v2.0 registered
[   21.415399] NET: Registered protocol family 4
[   21.416311] NET: Registered protocol family 5
[   21.418838] NET: Registered protocol family 6
[   21.424053] NET: Registered protocol family 11
[   21.425145] NET: Registered protocol family 3
[   21.426083] can: controller area network core (rev 20120528 abi 9)
[   21.427395] NET: Registered protocol family 29
[   21.428173] can: raw protocol (rev 20120528)
[   21.428960] can: broadcast manager protocol (rev 20120528 t)
[   21.431063] IrCOMM protocol (Dag Brattli)
[   21.436529] RPC: Registered rdma transport module.
[   21.437803] NET: Registered protocol family 33
[   21.438632] Key type rxrpc registered
[   21.439313] Key type rxrpc_s registered
[   21.441483] RxRPC: Registered security type 2 'rxkad'
[   21.442621] lec:lane_module_init: lec.c: initialized
[   21.443629] mpoa:atm_mpoa_init: mpc.c: initialized
[   21.444553] l2tp_core: L2TP core driver, V2.0
[   21.445421] l2tp_ppp: PPPoL2TP kernel driver, V2.0
[   21.446415] l2tp_ip: L2TP IP encapsulation support (L2TPv3)
[   21.447624] l2tp_netlink: L2TP netlink interface
[   21.448567] l2tp_eth: L2TP ethernet pseudowire support (L2TPv3)
[   21.449741] l2tp_debugfs: L2TP debugfs support
[   21.450629] l2tp_ip6: L2TP IP encapsulation support for IPv6 (L2TPv3)
[   21.452065] NET4: DECnet for Linux: V.2.5.68s (C) 1995-2003 Linux DECnet=
 Project Team
[   21.454280] DECnet: Routing cache hash table of 256 buckets, 20Kbytes
[   21.455605] NET: Registered protocol family 12
[   21.456638] NET: Registered protocol family 35
[   21.457838] 8021q: 802.1Q VLAN Support v1.8
[   21.460442] DCCP: Activated CCID 2 (TCP-like)
[   21.461617] DCCP: Activated CCID 3 (TCP-Friendly Rate Control)
[   21.474576] DCCP watch registered (port=3D0)
[   21.476176] sctp: Hash tables configured (established 1638 bind 1638)
[   21.489715] sctp_probe: probe registered (port=3D0)
[   21.491644] NET: Registered protocol family 21
[   21.492907] Registered RDS/iwarp transport
[   21.494345] Registered RDS/infiniband transport
[   21.495619] Registered RDS/tcp transport
[   21.496761] lib80211: common routines for IEEE802.11 drivers
[   21.498144] lib80211_crypt: registered algorithm 'NULL'
[   21.499340] lib80211_crypt: registered algorithm 'WEP'
[   21.500416] lib80211_crypt: registered algorithm 'CCMP'
[   21.501842] lib80211_crypt: registered algorithm 'TKIP'
[   21.503026] tipc: Activated (version 2.0.0)
[   21.505033] NET: Registered protocol family 30
[   21.506100] tipc: Started in single node mode
[   21.507270] 9pnet: Installing 9P2000 support
[   21.508535] NET: Registered protocol family 36
[   21.509443] Key type dns_resolver registered
[   21.510719] Key type ceph registered
[   21.511581] libceph: loaded (mon/osd proto 15/24, osdmap 5/6 5/6)
[   21.515300]=20
[   21.515300] printing PIC contents
[   21.516505] ... PIC  IMR: ffff
[   21.517203] ... PIC  IRR: 9153
[   21.518149] ... PIC  ISR: 0000
[   21.518958] ... PIC ELCR: 0c00
[   21.519638] printing local APIC contents on CPU#0/0:
[   21.520927] ... APIC ID:      00000000 (0)
[   21.522174] ... APIC VERSION: 00050014
[   21.523230] ... APIC TASKPRI: 00000000 (00)
[   21.523631] ... APIC PROCPRI: 00000000
[   21.523631] ... APIC LDR: 01000000
[   21.523631] ... APIC DFR: ffffffff
[   21.523631] ... APIC SPIV: 000001ff
[   21.523631] ... APIC ISR field:
[   21.523631] 000000000000000000000000000000000000000000000000000000000000=
0000
[   21.523631] ... APIC TMR field:
[   21.523631] 000000000000000000000000000000000000000000000000000000000000=
0000
[   21.523631] ... APIC IRR field:
[   21.523631] 000000000000000000000000000000000000000000000000000000000000=
8000
[   21.523631] ... APIC ESR: 00000000
[   21.523631] ... APIC ICR: 000008fd
[   21.523631] ... APIC ICR2: 02000000
[   21.523631] ... APIC LVTT: 000000ef
[   21.523631] ... APIC LVTPC: 00010000
[   21.523631] ... APIC LVT0: 00010700
[   21.523631] ... APIC LVT1: 00000400
[   21.523631] ... APIC LVTERR: 000000fe
[   21.523631] ... APIC TMICT: 000771a7
[   21.523631] ... APIC TMCCT: 00000000
[   21.523631] ... APIC TDCR: 00000003
[   21.523631]=20
[   21.559501] number of MP IRQ sources: 15.
[   21.560809] number of IO-APIC #2 registers: 24.
[   21.562227] testing the IO APIC.......................
[   21.563838] IO APIC #2......
[   21.564535] .... register #00: 00000000
[   21.565271] .......    : physical APIC id: 00
[   21.566267] .......    : Delivery Type: 0
[   21.567506] .......    : LTS          : 0
[   21.568587] .... register #01: 00170011
[   21.569704] .......     : max redirection entries: 17
[   21.571544] .......     : PRQ implemented: 0
[   21.572659] .......     : IO APIC version: 11
[   21.574081] .... register #02: 00000000
[   21.575064] .......     : arbitration: 00
[   21.576113] .... IRQ redirection table:
[   21.577189]  NR Dst Mask Trig IRR Pol Stat Dmod Deli Vect:
[   21.578697]  00 00  1    0    0   0   0    0    0    00
[   21.580135]  01 03  0    0    0   0   0    1    1    41
[   21.581590]  02 03  0    0    0   0   0    1    1    51
[   21.582998]  03 01  0    0    0   0   0    1    1    61
[   21.585151]  04 01  1    0    0   0   0    1    1    71
[   21.586606]  05 01  1    1    0   0   0    1    1    81
[   21.587900]  06 01  0    0    0   0   0    1    1    91
[   21.589310]  07 01  0    0    0   0   0    1    1    A1
[   21.590793]  08 01  0    0    0   0   0    1    1    B1
[   21.592251]  09 01  0    1    0   0   0    1    1    C1
[   21.594490]  0a 01  1    1    0   0   0    1    1    D1
[   21.595815]  0b 01  1    1    0   0   0    1    1    E1
[   21.597239]  0c 03  0    0    0   0   0    1    1    22
[   21.598735]  0d 01  0    0    0   0   0    1    1    42
[   21.600121]  0e 01  0    0    0   0   0    1    1    52
[   21.601606]  0f 01  0    0    0   0   0    1    1    62
[   21.602985]  10 00  1    0    0   0   0    0    0    00
[   21.605263]  11 00  1    0    0   0   0    0    0    00
[   21.606754]  12 00  1    0    0   0   0    0    0    00
[   21.608237]  13 00  1    0    0   0   0    0    0    00
[   21.609784]  14 00  1    0    0   0   0    0    0    00
[   21.611170]  15 00  1    0    0   0   0    0    0    00
[   21.612634]  16 00  1    0    0   0   0    0    0    00
[   21.614771]  17 00  1    0    0   0   0    0    0    00
[   21.616171] IRQ to pin mappings:
[   21.617064] IRQ0 -> 0:2
[   21.618079] IRQ1 -> 0:1
[   21.619051] IRQ3 -> 0:3
[   21.620084] IRQ4 -> 0:4
[   21.621038] IRQ5 -> 0:5
[   21.622129] IRQ6 -> 0:6
[   21.623100] IRQ7 -> 0:7
[   21.624114] IRQ8 -> 0:8
[   21.625104] IRQ9 -> 0:9
[   21.626168] IRQ10 -> 0:10
[   21.627181] IRQ11 -> 0:11
[   21.628230] IRQ12 -> 0:12
[   21.629250] IRQ13 -> 0:13
[   21.630316] IRQ14 -> 0:14
[   21.631381] IRQ15 -> 0:15
[   21.632404] .................................... done.
[   21.634772] PM: Hibernation image not present or could not be loaded.
[   21.636447] registered taskstats version 1
[   21.637537] Running tests on trace events:
[   21.638567] Testing event 9p_client_req: OK
[   21.656951] Testing event 9p_client_res: OK
[   21.672880] Testing event 9p_protocol_dump: OK
[   21.689782] Testing event drv_return_void: OK
[   21.709109] Testing event drv_return_int: OK
[   21.725136] Testing event drv_return_bool: OK
[   21.741252] Testing event drv_return_u64: OK
[   21.757212] Testing event drv_start: OK
[   21.772986] Testing event drv_get_et_strings: OK
[   21.788758] Testing event drv_get_et_sset_count: OK
[   21.804740] Testing event drv_get_et_stats: OK
[   21.820941] Testing event drv_suspend: OK
[   21.837276] Testing event drv_resume: OK
[   21.852690] Testing event drv_set_wakeup: OK
[   21.869009] Testing event drv_stop: OK
[   21.885076] Testing event drv_add_interface: OK
[   21.900917] Testing event drv_change_interface: OK
[   21.916858] Testing event drv_remove_interface: OK
[   21.932975] Testing event drv_config: OK
[   21.948863] Testing event drv_bss_info_changed: OK
[   21.968337] Testing event drv_prepare_multicast: OK
[   21.984920] Testing event drv_configure_filter: OK
[   22.001142] Testing event drv_set_tim: OK
[   22.017023] Testing event drv_set_key: OK
[   22.032839] Testing event drv_update_tkip_key: OK
[   22.048983] Testing event drv_hw_scan: OK
[   22.074858] Testing event drv_cancel_hw_scan: OK
[   22.104829] Testing event drv_sched_scan_start: OK
[   22.122285] Testing event drv_sched_scan_stop: OK
[   22.138311] Testing event drv_sw_scan_start: OK
[   22.152907] Testing event drv_sw_scan_complete: OK
[   22.168944] Testing event drv_get_stats: OK
[   22.184938] Testing event drv_get_tkip_seq: OK
[   22.200882] Testing event drv_set_frag_threshold: OK
[   22.216902] Testing event drv_set_rts_threshold: OK
[   22.232916] Testing event drv_set_coverage_class: OK
[   22.248949] Testing event drv_sta_notify: OK
[   22.265168] Testing event drv_sta_state: OK
[   22.281032] Testing event drv_sta_rc_update: OK
[   22.297083] Testing event drv_sta_add: OK
[   22.312989] Testing event drv_sta_remove: OK
[   22.328959] Testing event drv_conf_tx: OK
[   22.345050] Testing event drv_get_tsf: OK
[   22.360928] Testing event drv_set_tsf: OK
[   22.377345] Testing event drv_reset_tsf: OK
[   22.398171] Testing event drv_tx_last_beacon: OK
[   22.413342] Testing event drv_ampdu_action: OK
[   22.437013] Testing event drv_get_survey: OK
[   22.459656] Testing event drv_flush: OK
[   22.477037] Testing event drv_channel_switch: OK
[   22.493585] Testing event drv_set_antenna: OK
[   22.508915] Testing event drv_get_antenna: OK
[   22.528143] Testing event drv_remain_on_channel: OK
[   22.548760] Testing event drv_cancel_remain_on_channel: OK
[   22.564765] Testing event drv_offchannel_tx: OK
[   22.580898] Testing event drv_set_ringparam: OK
[   22.596945] Testing event drv_get_ringparam: OK
[   22.612808] Testing event drv_tx_frames_pending: OK
[   22.628897] Testing event drv_offchannel_tx_cancel_wait: OK
[   22.644956] Testing event drv_set_bitrate_mask: OK
[   22.660955] Testing event drv_set_rekey_data: OK
[   22.676933] Testing event drv_rssi_callback: OK
[   22.692996] Testing event drv_release_buffered_frames: OK
[   22.709001] Testing event drv_allow_buffered_frames: OK
[   22.724985] Testing event drv_get_rssi: OK
[   22.740997] Testing event drv_mgd_prepare_tx: OK
[   22.756977] Testing event api_start_tx_ba_session: OK
[   22.775270] Testing event api_start_tx_ba_cb: OK
[   22.792833] Testing event api_stop_tx_ba_session: OK
[   22.809819] Testing event api_stop_tx_ba_cb: OK
[   22.825208] Testing event api_restart_hw: OK
[   22.845217] Testing event api_beacon_loss: OK
[   22.860901] Testing event api_connection_loss: OK
[   22.876987] Testing event api_cqm_rssi_notify: OK
[   22.894952] Testing event api_scan_completed: OK
[   22.912946] Testing event api_sched_scan_results: OK
[   22.932945] Testing event api_sched_scan_stopped: OK
[   22.957000] Testing event api_sta_block_awake: OK
[   22.973009] Testing event api_chswitch_done: OK
[   22.989206] Testing event api_ready_on_channel: OK
[   23.007088] Testing event api_remain_on_channel_expired: OK
[   23.024754] Testing event api_gtk_rekey_notify: OK
[   23.041142] Testing event api_enable_rssi_reports: OK
[   23.064614] Testing event api_eosp: OK
[   23.081380] Testing event wake_queue: OK
[   23.105339] Testing event stop_queue: OK
[   23.120903] Testing event rpc_call_status: OK
[   23.136897] Testing event rpc_bind_status: OK
[   23.163410] Testing event rpc_connect_status: OK
[   23.182758] Testing event rpc_task_begin: OK
[   23.202639] Testing event rpc_task_run_action: OK
[   23.220868] Testing event rpc_task_complete: OK
[   23.237646] Testing event rpc_task_sleep: OK
[   23.253885] Testing event rpc_task_wakeup: OK
[   23.272960] Testing event kfree_skb: OK
[   23.288911] Testing event consume_skb: OK
[   23.310992] Testing event skb_copy_datagram_iovec: OK
[   23.329193] Testing event net_dev_xmit: OK
[   23.349162] Testing event net_dev_queue: OK
[   23.383067] Testing event netif_receive_skb: OK
[   23.405297] Testing event netif_rx: OK
[   23.421207] Testing event napi_poll: OK
[   23.436978] Testing event sock_rcvqueue_full: OK
[   23.454441] Testing event sock_exceed_buf_limit: OK
[   23.468895] Testing event udp_fail_queue_rcv_skb: OK
[   23.484928] Testing event hda_send_cmd: OK
[   23.500912] Testing event hda_get_response: OK
[   23.516908] Testing event hda_bus_reset: OK
[   23.532883] Testing event hda_power_down: OK
[   23.548942] Testing event hda_power_up: OK
[   23.565320] Testing event hda_unsol_event: OK
[   23.580952] Testing event mc_event: OK
[   23.596946] Testing event scsi_dispatch_cmd_start: OK
[   23.620905] Testing event scsi_dispatch_cmd_error: OK
[   23.642326] Testing event scsi_dispatch_cmd_done: OK
[   23.661279] Testing event scsi_dispatch_cmd_timeout: OK
[   23.680977] Testing event scsi_eh_wakeup: OK
[   23.697179] Testing event regmap_reg_write: OK
[   23.713002] Testing event regmap_reg_read: OK
[   23.729009] Testing event regmap_reg_read_cache: OK
[   23.745327] Testing event regmap_hw_read_start: OK
[   23.765037] Testing event regmap_hw_read_done: OK
[   23.781541] Testing event regmap_hw_write_start: OK
[   23.798137] Testing event regmap_hw_write_done: OK
[   23.812909] Testing event regcache_sync: OK
[   23.829018] Testing event regmap_cache_only: OK
[   23.844960] Testing event regmap_cache_bypass: OK
[   23.862017] Testing event i915_gem_object_create: OK
[   23.877115] Testing event i915_gem_object_bind: OK
[   23.896157] Testing event i915_gem_object_unbind: OK
[   23.912950] Testing event i915_gem_object_change_domain: OK
[   23.928941] Testing event i915_gem_object_pwrite: OK
[   23.946839] Testing event i915_gem_object_pread: OK
[   23.969314] Testing event i915_gem_object_fault: OK
[   23.993295] Testing event i915_gem_object_clflush: OK
[   24.009016] Testing event i915_gem_object_destroy: OK
[   24.024954] Testing event i915_gem_evict: OK
[   24.040854] Testing event i915_gem_evict_everything: OK
[   24.057610] Testing event i915_gem_ring_dispatch: OK
[   24.073009] Testing event i915_gem_ring_flush: OK
[   24.090275] Testing event i915_gem_request_add: OK
[   24.104966] Testing event i915_gem_request_complete: OK
[   24.120891] Testing event i915_gem_request_retire: OK
[   24.136883] Testing event i915_gem_request_wait_begin: OK
[   24.154231] Testing event i915_gem_request_wait_end: OK
[   24.169345] Testing event i915_ring_wait_begin: OK
[   24.185327] Testing event i915_ring_wait_end: OK
[   24.201163] Testing event i915_flip_request: OK
[   24.216879] Testing event i915_flip_complete: OK
[   24.232943] Testing event i915_reg_rw: OK
[   24.249246] Testing event radeon_bo_create: OK
[   24.268878] Testing event radeon_fence_emit: OK
[   24.284789] Testing event radeon_fence_retire: OK
[   24.300935] Testing event radeon_fence_wait_begin: OK
[   24.316946] Testing event radeon_fence_wait_end: OK
[   24.333321] Testing event drm_vblank_event: OK
[   24.353130] Testing event drm_vblank_event_queued: OK
[   24.368947] Testing event drm_vblank_event_delivered: OK
[   24.385374] Testing event mix_pool_bytes: OK
[   24.401169] Testing event mix_pool_bytes_nolock: OK
[   24.417097] Testing event credit_entropy_bits: OK
[   24.432956] Testing event get_random_bytes: OK
[   24.449385] Testing event extract_entropy: OK
[   24.465243] Testing event extract_entropy_user: OK
[   24.481701] Testing event regulator_enable: OK
[   24.496889] Testing event regulator_enable_delay: OK
[   24.512795] Testing event regulator_enable_complete: OK
[   24.529137] Testing event regulator_disable: OK
[   24.544942] Testing event regulator_disable_complete: OK
[   24.562382] Testing event regulator_set_voltage: OK
[   24.580928] Testing event regulator_set_voltage_complete: OK
[   24.599098] Testing event gpio_direction: OK
[   24.616904] Testing event gpio_value: OK
[   24.633317] Testing event block_rq_abort: OK
[   24.648897] Testing event block_rq_requeue: OK
[   24.664993] Testing event block_rq_complete: OK
[   24.681002] Testing event block_rq_insert: OK
[   24.700956] Testing event block_rq_issue: OK
[   24.716916] Testing event block_bio_bounce: OK
[   24.732942] Testing event block_bio_complete: OK
[   24.748924] Testing event block_bio_backmerge: OK
[   24.765283] Testing event block_bio_frontmerge: OK
[   24.781286] Testing event block_bio_queue: OK
[   24.797008] Testing event block_getrq: OK
[   24.813961] Testing event block_sleeprq: OK
[   24.828907] Testing event block_plug: OK
[   24.845159] Testing event block_unplug: OK
[   24.864778] Testing event block_split: OK
[   24.885016] Testing event block_bio_remap: OK
[   24.901578] Testing event block_rq_remap: OK
[   24.921659] Testing event gfs2_glock_state_change: OK
[   24.941181] Testing event gfs2_glock_put: OK
[   24.959608] Testing event gfs2_demote_rq: OK
[   24.976934] Testing event gfs2_promote: OK
[   24.994587] Testing event gfs2_glock_queue: OK
[   25.014117] Testing event gfs2_glock_lock_time: OK
[   25.028911] Testing event gfs2_pin: OK
[   25.044922] Testing event gfs2_log_flush: OK
[   25.061018] Testing event gfs2_log_blocks: OK
[   25.076986] Testing event gfs2_ail_flush: OK
[   25.092869] Testing event gfs2_bmap: OK
[   25.109011] Testing event gfs2_block_alloc: OK
[   25.124822] Testing event gfs2_rs: OK
[   25.140754] Testing event btrfs_transaction_commit: OK
[   25.156937] Testing event btrfs_inode_new: OK
[   25.172751] Testing event btrfs_inode_request: OK
[   25.198795] Testing event btrfs_inode_evict: OK
[   25.216891] Testing event btrfs_get_extent: OK
[   25.240947] Testing event btrfs_ordered_extent_add: OK
[   25.258065] Testing event btrfs_ordered_extent_remove: OK
[   25.272739] Testing event btrfs_ordered_extent_start: OK
[   25.289141] Testing event btrfs_ordered_extent_put: OK
[   25.304855] Testing event __extent_writepage: OK
[   25.321557] Testing event btrfs_writepage_end_io_hook: OK
[   25.336901] Testing event btrfs_sync_file: OK
[   25.355853] Testing event btrfs_sync_fs: OK
[   25.373023] Testing event btrfs_delayed_tree_ref: OK
[   25.391060] Testing event btrfs_delayed_data_ref: OK
[   25.408946] Testing event btrfs_delayed_ref_head: OK
[   25.426488] Testing event btrfs_chunk_alloc: OK
[   25.445068] Testing event btrfs_chunk_free: OK
[   25.463554] Testing event btrfs_cow_block: OK
[   25.487972] Testing event btrfs_space_reservation: OK
[   25.509095] Testing event btrfs_reserved_extent_alloc: OK
[   25.525097] Testing event btrfs_reserved_extent_free: OK
[   25.545318] Testing event find_free_extent: OK
[   25.560911] Testing event btrfs_reserve_extent: OK
[   25.581301] Testing event btrfs_reserve_extent_cluster: OK
[   25.604318] Testing event btrfs_find_cluster: OK
[   25.620985] Testing event btrfs_failed_cluster_setup: OK
[   25.637382] Testing event btrfs_setup_cluster: OK
[   25.653974] Testing event alloc_extent_state: OK
[   25.672927] Testing event free_extent_state: OK
[   25.695577] Testing event ocfs2_adjust_rightmost_branch: OK
[   25.712969] Testing event ocfs2_rotate_tree_right: OK
[   25.728948] Testing event ocfs2_append_rec_to_path: OK
[   25.744780] Testing event ocfs2_insert_extent_start: OK
[   25.761893] Testing event ocfs2_add_clusters_in_btree: OK
[   25.784692] Testing event ocfs2_num_free_extents: OK
[   25.804605] Testing event ocfs2_complete_edge_insert: OK
[   25.828871] Testing event ocfs2_grow_tree: OK
[   25.848714] Testing event ocfs2_rotate_subtree: OK
[   25.865231] Testing event ocfs2_insert_extent: OK
[   25.881783] Testing event ocfs2_split_extent: OK
[   25.900878] Testing event ocfs2_remove_extent: OK
[   25.916957] Testing event ocfs2_commit_truncate: OK
[   25.932749] Testing event ocfs2_validate_extent_block: OK
[   25.948992] Testing event ocfs2_rotate_leaf: OK
[   25.974135] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   25.993307] Testing event ocfs2_mark_extent_written: OK
[   26.009085] Testing event ocfs2_truncate_log_append: OK
[   26.028911] Testing event ocfs2_replay_truncate_records: OK
[   26.046665] Testing event ocfs2_flush_truncate_log: OK
[   26.065100] Testing event ocfs2_begin_truncate_log_recovery: OK
[   26.081015] Testing event ocfs2_truncate_log_recovery_num: OK
[   26.106499] Testing event ocfs2_complete_truncate_log_recovery: OK
[   26.125115] Testing event ocfs2_free_cached_blocks: OK
[   26.144869] Testing event ocfs2_cache_cluster_dealloc: OK
[   26.160931] Testing event ocfs2_run_deallocs: OK
[   26.178299] Testing event ocfs2_cache_block_dealloc: OK
[   26.192900] Testing event ocfs2_trim_extent: OK
[   26.208902] Testing event ocfs2_trim_group: OK
[   26.225011] Testing event ocfs2_trim_fs: OK
[   26.240905] Testing event ocfs2_la_set_sizes: OK
[   26.258196] Testing event ocfs2_alloc_should_use_local: OK
[   26.272936] Testing event ocfs2_load_local_alloc: OK
[   26.292498] Testing event ocfs2_begin_local_alloc_recovery: OK
[   26.308888] Testing event ocfs2_reserve_local_alloc_bits: OK
[   26.325030] Testing event ocfs2_local_alloc_count_bits: OK
[   26.340893] Testing event ocfs2_local_alloc_find_clear_bits_search_bitma=
p: OK
[   26.357024] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   26.372949] Testing event ocfs2_sync_local_to_main: OK
[   26.389300] Testing event ocfs2_sync_local_to_main_free: OK
[   26.404848] Testing event ocfs2_local_alloc_new_window: OK
[   26.420886] Testing event ocfs2_local_alloc_new_window_result: OK
[   26.438185] Testing event ocfs2_update_last_group_and_inode: OK
[   26.452841] Testing event ocfs2_group_extend: OK
[   26.469119] Testing event ocfs2_group_add: OK
[   26.484929] Testing event ocfs2_validate_group_descriptor: OK
[   26.501144] Testing event ocfs2_block_group_alloc_contig: OK
[   26.517021] Testing event ocfs2_block_group_alloc_discontig: OK
[   26.532867] Testing event ocfs2_block_group_alloc: OK
[   26.548859] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   26.564979] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   26.581310] Testing event ocfs2_reserve_new_inode_new_group: OK
[   26.597231] Testing event ocfs2_block_group_set_bits: OK
[   26.612896] Testing event ocfs2_relink_block_group: OK
[   26.630136] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   26.648866] Testing event ocfs2_cluster_group_search_max_block: OK
[   26.664910] Testing event ocfs2_block_group_search_max_block: OK
[   26.684906] Testing event ocfs2_search_chain_begin: OK
[   26.700925] Testing event ocfs2_search_chain_succ: OK
[   26.716895] Testing event ocfs2_search_chain_end: OK
[   26.732951] Testing event ocfs2_claim_suballoc_bits: OK
[   26.748863] Testing event ocfs2_claim_new_inode_at_loc: OK
[   26.765006] Testing event ocfs2_block_group_clear_bits: OK
[   26.781063] Testing event ocfs2_free_suballoc_bits: OK
[   26.799293] Testing event ocfs2_free_clusters: OK
[   26.816936] Testing event ocfs2_get_suballoc_slot_bit: OK
[   26.833271] Testing event ocfs2_test_suballoc_bit: OK
[   26.849555] Testing event ocfs2_test_inode_bit: OK
[   26.868915] Testing event ocfs2_validate_refcount_block: OK
[   26.897976] Testing event ocfs2_purge_refcount_trees: OK
[   26.912907] Testing event ocfs2_create_refcount_tree: OK
[   26.928888] Testing event ocfs2_create_refcount_tree_blkno: OK
[   26.945186] Testing event ocfs2_change_refcount_rec: OK
[   26.961639] Testing event ocfs2_expand_inline_ref_root: OK
[   26.982922] Testing event ocfs2_divide_leaf_refcount_block: OK
[   27.001491] Testing event ocfs2_new_leaf_refcount_block: OK
[   27.017064] Testing event ocfs2_insert_refcount_rec: OK
[   27.036942] Testing event ocfs2_split_refcount_rec: OK
[   27.052898] Testing event ocfs2_split_refcount_rec_insert: OK
[   27.068971] Testing event ocfs2_increase_refcount_begin: OK
[   27.085081] Testing event ocfs2_increase_refcount_change: OK
[   27.108288] Testing event ocfs2_increase_refcount_insert: OK
[   27.125030] Testing event ocfs2_increase_refcount_split: OK
[   27.140939] Testing event ocfs2_remove_refcount_extent: OK
[   27.157178] Testing event ocfs2_restore_refcount_block: OK
[   27.179127] Testing event ocfs2_decrease_refcount_rec: OK
[   27.196922] Testing event ocfs2_decrease_refcount: OK
[   27.212904] Testing event ocfs2_mark_extent_refcounted: OK
[   27.230225] Testing event ocfs2_calc_refcount_meta_credits: OK
[   27.252938] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   27.272652] Testing event ocfs2_add_refcount_flag: OK
[   27.290289] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   27.308897] Testing event ocfs2_lock_refcount_allocators: OK
[   27.324966] Testing event ocfs2_duplicate_clusters_by_page: OK
[   27.347518] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   27.364989] Testing event ocfs2_clear_ext_refcount: OK
[   27.381336] Testing event ocfs2_replace_clusters: OK
[   27.401169] Testing event ocfs2_make_clusters_writable: OK
[   27.420929] Testing event ocfs2_refcount_cow_hunk: OK
[   27.436915] Testing event ocfs2_symlink_get_block: OK
[   27.458140] Testing event ocfs2_get_block: OK
[   27.472924] Testing event ocfs2_get_block_end: OK
[   27.496131] Testing event ocfs2_readpage: OK
[   27.517171] Testing event ocfs2_writepage: OK
[   27.536920] Testing event ocfs2_bmap: OK
[   27.558325] Testing event ocfs2_try_to_write_inline_data: OK
[   27.577580] Testing event ocfs2_write_begin_nolock: OK
[   27.592980] Testing event ocfs2_write_end_inline: OK
[   27.610150] Testing event ocfs2_fault: OK
[   27.634546] Testing event ocfs2_file_open: OK
[   27.652907] Testing event ocfs2_file_release: OK
[   27.668922] Testing event ocfs2_sync_file: OK
[   27.684926] Testing event ocfs2_file_aio_write: OK
[   27.700899] Testing event ocfs2_file_splice_write: OK
[   27.716980] Testing event ocfs2_file_splice_read: OK
[   27.732981] Testing event ocfs2_file_aio_read: OK
[   27.756399] Testing event ocfs2_truncate_file: OK
[   27.772921] Testing event ocfs2_truncate_file_error: OK
[   27.788948] Testing event ocfs2_extend_allocation: OK
[   27.805054] Testing event ocfs2_extend_allocation_end: OK
[   27.820995] Testing event ocfs2_write_zero_page: OK
[   27.840930] Testing event ocfs2_zero_extend_range: OK
[   27.858204] Testing event ocfs2_zero_extend: OK
[   27.872927] Testing event ocfs2_setattr: OK
[   27.891174] Testing event ocfs2_write_remove_suid: OK
[   27.908932] Testing event ocfs2_zero_partial_clusters: OK
[   27.926326] Testing event ocfs2_zero_partial_clusters_range1: OK
[   27.945279] Testing event ocfs2_zero_partial_clusters_range2: OK
[   27.965183] Testing event ocfs2_remove_inode_range: OK
[   27.989042] Testing event ocfs2_prepare_inode_for_write: OK
[   28.004911] Testing event generic_file_aio_read_ret: OK
[   28.020972] Testing event ocfs2_iget_begin: OK
[   28.042781] Testing event ocfs2_iget5_locked: OK
[   28.061203] Testing event ocfs2_iget_end: OK
[   28.076996] Testing event ocfs2_find_actor: OK
[   28.096280] Testing event ocfs2_populate_inode: OK
[   28.112897] Testing event ocfs2_read_locked_inode: OK
[   28.128935] Testing event ocfs2_check_orphan_recovery_state: OK
[   28.144950] Testing event ocfs2_validate_inode_block: OK
[   28.160920] Testing event ocfs2_inode_is_valid_to_delete: OK
[   28.176888] Testing event ocfs2_query_inode_wipe_begin: OK
[   28.192903] Testing event ocfs2_query_inode_wipe_succ: OK
[   28.208951] Testing event ocfs2_query_inode_wipe_end: OK
[   28.224926] Testing event ocfs2_cleanup_delete_inode: OK
[   28.240973] Testing event ocfs2_delete_inode: OK
[   28.256882] Testing event ocfs2_clear_inode: OK
[   28.276939] Testing event ocfs2_drop_inode: OK
[   28.292923] Testing event ocfs2_inode_revalidate: OK
[   28.309110] Testing event ocfs2_mark_inode_dirty: OK
[   28.324843] Testing event ocfs2_read_virt_blocks: OK
[   28.341963] Testing event ocfs2_refresh_slot_info: OK
[   28.356943] Testing event ocfs2_map_slot_buffers: OK
[   28.376906] Testing event ocfs2_map_slot_buffers_block: OK
[   28.402182] Testing event ocfs2_find_slot: OK
[   28.416902] Testing event ocfs2_do_node_down: OK
[   28.432893] Testing event ocfs2_remount: OK
[   28.448946] Testing event ocfs2_fill_super: OK
[   28.464983] Testing event ocfs2_parse_options: OK
[   28.480947] Testing event ocfs2_put_super: OK
[   28.496877] Testing event ocfs2_statfs: OK
[   28.513136] Testing event ocfs2_dismount_volume: OK
[   28.531455] Testing event ocfs2_initialize_super: OK
[   28.553114] Testing event ocfs2_validate_xattr_block: OK
[   28.569297] Testing event ocfs2_xattr_extend_allocation: OK
[   28.590542] Testing event ocfs2_init_xattr_set_ctxt: OK
[   28.611643] Testing event ocfs2_xattr_bucket_find: OK
[   28.629330] Testing event ocfs2_xattr_index_block_find: OK
[   28.648943] Testing event ocfs2_xattr_index_block_find_rec: OK
[   28.664965] Testing event ocfs2_iterate_xattr_buckets: OK
[   28.680986] Testing event ocfs2_iterate_xattr_bucket: OK
[   28.696890] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   28.712874] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   28.728932] Testing event ocfs2_xattr_create_index_block_begin: OK
[   28.752909] Testing event ocfs2_xattr_create_index_block: OK
[   28.769107] Testing event ocfs2_defrag_xattr_bucket: OK
[   28.784880] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   28.800897] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   28.816828] Testing event ocfs2_divide_xattr_bucket_move: OK
[   28.832959] Testing event ocfs2_cp_xattr_bucket: OK
[   28.848946] Testing event ocfs2_mv_xattr_buckets: OK
[   28.865933] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   28.880905] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   28.898173] Testing event ocfs2_add_new_xattr_cluster: OK
[   28.912889] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   28.928903] Testing event ocfs2_extend_xattr_bucket: OK
[   28.945147] Testing event ocfs2_add_new_xattr_bucket: OK
[   28.962153] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   28.976885] Testing event ocfs2_rm_xattr_cluster: OK
[   28.997255] Testing event ocfs2_reflink_xattr_header: OK
[   29.013009] Testing event ocfs2_create_empty_xattr_block: OK
[   29.028876] Testing event ocfs2_xattr_set_entry_bucket: OK
[   29.044991] Testing event ocfs2_xattr_set_entry_index_block: OK
[   29.061230] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   29.076966] Testing event ocfs2_reflink_xattr_buckets: OK
[   29.101684] Testing event ocfs2_reflink_xattr_rec: OK
[   29.116899] Testing event ocfs2_resv_insert: OK
[   29.136002] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   29.152853] Testing event ocfs2_resmap_find_free_bits_end: OK
[   29.168907] Testing event ocfs2_resv_find_window_begin: OK
[   29.184906] Testing event ocfs2_resv_find_window_prev: OK
[   29.206503] Testing event ocfs2_resv_find_window_next: OK
[   29.228944] Testing event ocfs2_cannibalize_resv_begin: OK
[   29.245265] Testing event ocfs2_cannibalize_resv_end: OK
[   29.264842] Testing event ocfs2_resmap_resv_bits: OK
[   29.280852] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   29.296919] Testing event ocfs2_resmap_claimed_bits_end: OK
[   29.312841] Testing event ocfs2_recover_local_quota_file: OK
[   29.328912] Testing event ocfs2_finish_quota_recovery: OK
[   29.345144] Testing event olq_set_dquot: OK
[   29.360939] Testing event ocfs2_validate_quota_block: OK
[   29.383562] Testing event ocfs2_sync_dquot: OK
[   29.401330] Testing event ocfs2_sync_dquot_helper: OK
[   29.426034] Testing event ocfs2_write_dquot: OK
[   29.441076] Testing event ocfs2_release_dquot: OK
[   29.460718] Testing event ocfs2_acquire_dquot: OK
[   29.476969] Testing event ocfs2_mark_dquot_dirty: OK
[   29.497044] Testing event ocfs2_search_dirblock: OK
[   29.518151] Testing event ocfs2_validate_dir_block: OK
[   29.532989] Testing event ocfs2_find_entry_el: OK
[   29.549313] Testing event ocfs2_dx_dir_search: OK
[   29.565790] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   29.580984] Testing event ocfs2_delete_entry_dx: OK
[   29.605236] Testing event ocfs2_readdir: OK
[   29.620821] Testing event ocfs2_find_files_on_disk: OK
[   29.637643] Testing event ocfs2_check_dir_for_entry: OK
[   29.670556] Testing event ocfs2_dx_dir_attach_index: OK
[   29.693049] Testing event ocfs2_dx_dir_format_cluster: OK
[   29.713302] Testing event ocfs2_dx_dir_index_root_block: OK
[   29.728940] Testing event ocfs2_extend_dir: OK
[   29.745181] Testing event ocfs2_dx_dir_rebalance: OK
[   29.763420] Testing event ocfs2_dx_dir_rebalance_split: OK
[   29.781518] Testing event ocfs2_prepare_dir_for_insert: OK
[   29.802466] Testing event ocfs2_lookup: OK
[   29.816873] Testing event ocfs2_mkdir: OK
[   29.833181] Testing event ocfs2_create: OK
[   29.853630] Testing event ocfs2_unlink: OK
[   29.877192] Testing event ocfs2_symlink_create: OK
[   29.905468] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   29.928477] Testing event ocfs2_lookup_ret: OK
[   29.950371] Testing event ocfs2_mknod: OK
[   29.982151] Testing event ocfs2_link: OK
[   29.996850] Testing event ocfs2_unlink_noent: OK
[   30.012895] Testing event ocfs2_double_lock: OK
[   30.028922] Testing event ocfs2_double_lock_end: OK
[   30.044883] Testing event ocfs2_rename: OK
[   30.061954] Testing event ocfs2_rename_target_exists: OK
[   30.076979] Testing event ocfs2_rename_disagree: OK
[   30.093000] Testing event ocfs2_rename_over_existing: OK
[   30.112934] Testing event ocfs2_create_symlink_data: OK
[   30.128921] Testing event ocfs2_symlink_begin: OK
[   30.145269] Testing event ocfs2_blkno_stringify: OK
[   30.161007] Testing event ocfs2_orphan_add_begin: OK
[   30.177576] Testing event ocfs2_orphan_add_end: OK
[   30.192877] Testing event ocfs2_orphan_del: OK
[   30.208888] Testing event ocfs2_dentry_revalidate: OK
[   30.233918] Testing event ocfs2_dentry_revalidate_negative: OK
[   30.249377] Testing event ocfs2_dentry_revalidate_delete: OK
[   30.264968] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   30.284987] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   30.300954] Testing event ocfs2_dentry_revalidate_ret: OK
[   30.316959] Testing event ocfs2_find_local_alias: OK
[   30.337223] Testing event ocfs2_dentry_attach_lock: OK
[   30.352904] Testing event ocfs2_dentry_attach_lock_found: OK
[   30.369219] Testing event ocfs2_get_dentry_begin: OK
[   30.384846] Testing event ocfs2_get_dentry_test_bit: OK
[   30.400915] Testing event ocfs2_get_dentry_stale: OK
[   30.416738] Testing event ocfs2_get_dentry_generation: OK
[   30.432868] Testing event ocfs2_get_dentry_end: OK
[   30.449815] Testing event ocfs2_get_parent: OK
[   30.470485] Testing event ocfs2_get_parent_end: OK
[   30.489783] Testing event ocfs2_encode_fh_begin: OK
[   30.504701] Testing event ocfs2_encode_fh_self: OK
[   30.520714] Testing event ocfs2_encode_fh_parent: OK
[   30.536794] Testing event ocfs2_encode_fh_type: OK
[   30.552716] Testing event ocfs2_commit_cache_begin: OK
[   30.568940] Testing event ocfs2_commit_cache_end: OK
[   30.584866] Testing event ocfs2_extend_trans: OK
[   30.600683] Testing event ocfs2_extend_trans_restart: OK
[   30.616771] Testing event ocfs2_journal_access: OK
[   30.633650] Testing event ocfs2_journal_dirty: OK
[   30.648979] Testing event ocfs2_journal_init: OK
[   30.664742] Testing event ocfs2_journal_init_maxlen: OK
[   30.681426] Testing event ocfs2_journal_shutdown: OK
[   30.701556] Testing event ocfs2_journal_shutdown_wait: OK
[   30.716809] Testing event ocfs2_complete_recovery: OK
[   30.732872] Testing event ocfs2_complete_recovery_end: OK
[   30.748939] Testing event ocfs2_complete_recovery_slot: OK
[   30.768766] Testing event ocfs2_recovery_thread_node: OK
[   30.784879] Testing event ocfs2_recovery_thread_end: OK
[   30.800898] Testing event ocfs2_recovery_thread: OK
[   30.816942] Testing event ocfs2_replay_journal_recovered: OK
[   30.832894] Testing event ocfs2_replay_journal_lock_err: OK
[   30.848887] Testing event ocfs2_replay_journal_skip: OK
[   30.864953] Testing event ocfs2_recover_node: OK
[   30.880987] Testing event ocfs2_recover_node_skip: OK
[   30.897278] Testing event ocfs2_mark_dead_nodes: OK
[   30.912871] Testing event ocfs2_queue_orphan_scan_begin: OK
[   30.928960] Testing event ocfs2_queue_orphan_scan_end: OK
[   30.945168] Testing event ocfs2_orphan_filldir: OK
[   30.960943] Testing event ocfs2_recover_orphans: OK
[   30.977061] Testing event ocfs2_recover_orphans_iput: OK
[   30.992821] Testing event ocfs2_wait_on_mount: OK
[   31.008927] Testing event ocfs2_read_blocks_sync: OK
[   31.025034] Testing event ocfs2_read_blocks_sync_jbd: OK
[   31.040931] Testing event ocfs2_read_blocks_from_disk: OK
[   31.056930] Testing event ocfs2_read_blocks_bh: OK
[   31.072897] Testing event ocfs2_read_blocks_end: OK
[   31.093040] Testing event ocfs2_write_block: OK
[   31.108853] Testing event ocfs2_read_blocks_begin: OK
[   31.124792] Testing event ocfs2_purge_copied_metadata_tree: OK
[   31.140940] Testing event ocfs2_metadata_cache_purge: OK
[   31.156990] Testing event ocfs2_buffer_cached_begin: OK
[   31.172871] Testing event ocfs2_buffer_cached_end: OK
[   31.188860] Testing event ocfs2_append_cache_array: OK
[   31.204939] Testing event ocfs2_insert_cache_tree: OK
[   31.220970] Testing event ocfs2_expand_cache: OK
[   31.236900] Testing event ocfs2_set_buffer_uptodate: OK
[   31.252886] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   31.269138] Testing event ocfs2_remove_metadata_array: OK
[   31.285155] Testing event ocfs2_remove_metadata_tree: OK
[   31.305302] Testing event ocfs2_remove_block_from_cache: OK
[   31.324882] Testing event xfs_attr_list_sf: OK
[   31.340867] Testing event xfs_attr_list_sf_all: OK
[   31.357065] Testing event xfs_attr_list_leaf: OK
[   31.372946] Testing event xfs_attr_list_leaf_end: OK
[   31.389193] Testing event xfs_attr_list_full: OK
[   31.404889] Testing event xfs_attr_list_add: OK
[   31.420862] Testing event xfs_attr_list_wrong_blk: OK
[   31.437284] Testing event xfs_attr_list_notfound: OK
[   31.452888] Testing event xfs_perag_get: OK
[   31.469210] Testing event xfs_perag_get_tag: OK
[   31.484703] Testing event xfs_perag_put: OK
[   31.500920] Testing event xfs_perag_set_reclaim: OK
[   31.525999] Testing event xfs_perag_clear_reclaim: OK
[   31.541059] Testing event xfs_attr_list_node_descend: OK
[   31.556790] Testing event xfs_iext_insert: OK
[   31.572731] Testing event xfs_iext_remove: OK
[   31.588780] Testing event xfs_bmap_pre_update: OK
[   31.605221] Testing event xfs_bmap_post_update: OK
[   31.621685] Testing event xfs_extlist: OK
[   31.636992] Testing event xfs_buf_init: OK
[   31.652915] Testing event xfs_buf_free: OK
[   31.668957] Testing event xfs_buf_hold: OK
[   31.685185] Testing event xfs_buf_rele: OK
[   31.700956] Testing event xfs_buf_iodone: OK
[   31.717588] Testing event xfs_buf_iorequest: OK
[   31.733883] Testing event xfs_buf_bawrite: OK
[   31.749245] Testing event xfs_buf_lock: OK
[   31.764794] Testing event xfs_buf_lock_done: OK
[   31.780800] Testing event xfs_buf_trylock: OK
[   31.796724] Testing event xfs_buf_unlock: OK
[   31.812685] Testing event xfs_buf_iowait: OK
[   31.828963] Testing event xfs_buf_iowait_done: OK
[   31.845024] Testing event xfs_buf_delwri_queue: OK
[   31.860946] Testing event xfs_buf_delwri_queued: OK
[   31.876928] Testing event xfs_buf_delwri_split: OK
[   31.893307] Testing event xfs_buf_get_uncached: OK
[   31.910171] Testing event xfs_bdstrat_shut: OK
[   31.930027] Testing event xfs_buf_item_relse: OK
[   31.945208] Testing event xfs_buf_item_iodone: OK
[   31.964958] Testing event xfs_buf_item_iodone_async: OK
[   31.981885] Testing event xfs_buf_error_relse: OK
[   32.004953] Testing event xfs_trans_read_buf_io: OK
[   32.021054] Testing event xfs_trans_read_buf_shut: OK
[   32.036918] Testing event xfs_btree_corrupt: OK
[   32.052924] Testing event xfs_da_btree_corrupt: OK
[   32.071619] Testing event xfs_reset_dqcounts: OK
[   32.089661] Testing event xfs_inode_item_push: OK
[   32.104980] Testing event xfs_buf_find: OK
[   32.121041] Testing event xfs_buf_get: OK
[   32.137042] Testing event xfs_buf_read: OK
[   32.153222] Testing event xfs_buf_ioerror: OK
[   32.169566] Testing event xfs_buf_item_size: OK
[   32.185422] Testing event xfs_buf_item_size_stale: OK
[   32.205547] Testing event xfs_buf_item_format: OK
[   32.224928] Testing event xfs_buf_item_format_stale: OK
[   32.241598] Testing event xfs_buf_item_pin: OK
[   32.262138] Testing event xfs_buf_item_unpin: OK
[   32.281133] Testing event xfs_buf_item_unpin_stale: OK
[   32.300964] Testing event xfs_buf_item_unlock: OK
[   32.316959] Testing event xfs_buf_item_unlock_stale: OK
[   32.333951] Testing event xfs_buf_item_committed: OK
[   32.352998] Testing event xfs_buf_item_push: OK
[   32.369167] Testing event xfs_trans_get_buf: OK
[   32.385118] Testing event xfs_trans_get_buf_recur: OK
[   32.404862] Testing event xfs_trans_getsb: OK
[   32.421164] Testing event xfs_trans_getsb_recur: OK
[   32.436867] Testing event xfs_trans_read_buf: OK
[   32.453342] Testing event xfs_trans_read_buf_recur: OK
[   32.472892] Testing event xfs_trans_log_buf: OK
[   32.490576] Testing event xfs_trans_brelse: OK
[   32.514048] Testing event xfs_trans_bjoin: OK
[   32.529071] Testing event xfs_trans_bhold: OK
[   32.545259] Testing event xfs_trans_bhold_release: OK
[   32.561703] Testing event xfs_trans_binval: OK
[   32.580564] Testing event xfs_ilock: OK
[   32.597152] Testing event xfs_ilock_nowait: OK
[   32.613173] Testing event xfs_ilock_demote: OK
[   32.629699] Testing event xfs_iunlock: OK
[   32.645232] Testing event xfs_iget_skip: OK
[   32.664938] Testing event xfs_iget_reclaim: OK
[   32.689109] Testing event xfs_iget_reclaim_fail: OK
[   32.705109] Testing event xfs_iget_hit: OK
[   32.721414] Testing event xfs_iget_miss: OK
[   32.742947] Testing event xfs_getattr: OK
[   32.761912] Testing event xfs_setattr: OK
[   32.776953] Testing event xfs_readlink: OK
[   32.793223] Testing event xfs_alloc_file_space: OK
[   32.813011] Testing event xfs_free_file_space: OK
[   32.830416] Testing event xfs_readdir: OK
[   32.845433] Testing event xfs_get_acl: OK
[   32.861153] Testing event xfs_vm_bmap: OK
[   32.876950] Testing event xfs_file_ioctl: OK
[   32.898544] Testing event xfs_file_compat_ioctl: OK
[   32.916963] Testing event xfs_ioctl_setattr: OK
[   32.936961] Testing event xfs_dir_fsync: OK
[   32.962034] Testing event xfs_file_fsync: OK
[   32.977066] Testing event xfs_destroy_inode: OK
[   32.993229] Testing event xfs_evict_inode: OK
[   33.008986] Testing event xfs_update_time: OK
[   33.025158] Testing event xfs_dquot_dqalloc: OK
[   33.041310] Testing event xfs_dquot_dqdetach: OK
[   33.059381] Testing event xfs_ihold: OK
[   33.086473] Testing event xfs_irele: OK
[   33.104810] Testing event xfs_inode_pin: OK
[   33.120944] Testing event xfs_inode_unpin: OK
[   33.136937] Testing event xfs_inode_unpin_nowait: OK
[   33.152931] Testing event xfs_remove: OK
[   33.168938] Testing event xfs_link: OK
[   33.185256] Testing event xfs_lookup: OK
[   33.204999] Testing event xfs_create: OK
[   33.221007] Testing event xfs_symlink: OK
[   33.237342] Testing event xfs_rename: OK
[   33.252973] Testing event xfs_dqadjust: OK
[   33.268989] Testing event xfs_dqreclaim_want: OK
[   33.285049] Testing event xfs_dqreclaim_dirty: OK
[   33.305089] Testing event xfs_dqreclaim_busy: OK
[   33.325108] Testing event xfs_dqreclaim_done: OK
[   33.340907] Testing event xfs_dqattach_found: OK
[   33.357111] Testing event xfs_dqattach_get: OK
[   33.380140] Testing event xfs_dqalloc: OK
[   33.396863] Testing event xfs_dqtobp_read: OK
[   33.413418] Testing event xfs_dqread: OK
[   33.432866] Testing event xfs_dqread_fail: OK
[   33.448886] Testing event xfs_dqget_hit: OK
[   33.464993] Testing event xfs_dqget_miss: OK
[   33.480928] Testing event xfs_dqget_freeing: OK
[   33.497650] Testing event xfs_dqget_dup: OK
[   33.513181] Testing event xfs_dqput: OK
[   33.536919] Testing event xfs_dqput_wait: OK
[   33.553550] Testing event xfs_dqput_free: OK
[   33.579518] Testing event xfs_dqrele: OK
[   33.600933] Testing event xfs_dqflush: OK
[   33.622864] Testing event xfs_dqflush_force: OK
[   33.640954] Testing event xfs_dqflush_done: OK
[   33.663980] Testing event xfs_log_done_nonperm: OK
[   33.685520] Testing event xfs_log_done_perm: OK
[   33.704896] Testing event xfs_log_umount_write: OK
[   33.734766] Testing event xfs_log_grant_sleep: OK
[   33.753053] Testing event xfs_log_grant_wake: OK
[   33.768858] Testing event xfs_log_grant_wake_up: OK
[   33.784864] Testing event xfs_log_reserve: OK
[   33.809246] Testing event xfs_log_reserve_exit: OK
[   33.825722] Testing event xfs_log_regrant: OK
[   33.844934] Testing event xfs_log_regrant_exit: OK
[   33.860937] Testing event xfs_log_regrant_reserve_enter: OK
[   33.877207] Testing event xfs_log_regrant_reserve_exit: OK
[   33.893270] Testing event xfs_log_regrant_reserve_sub: OK
[   33.910159] Testing event xfs_log_ungrant_enter: OK
[   33.932255] Testing event xfs_log_ungrant_exit: OK
[   33.953105] Testing event xfs_log_ungrant_sub: OK
[   33.969209] Testing event xfs_log_force: OK
[   33.984927] Testing event xfs_ail_push: OK
[   34.003563] Testing event xfs_ail_pinned: OK
[   34.020895] Testing event xfs_ail_locked: OK
[   34.036854] Testing event xfs_ail_flushing: OK
[   34.052937] Testing event xfs_file_read: OK
[   34.068868] Testing event xfs_file_buffered_write: OK
[   34.084916] Testing event xfs_file_direct_write: OK
[   34.100926] Testing event xfs_file_splice_read: OK
[   34.120972] Testing event xfs_file_splice_write: OK
[   34.146858] Testing event xfs_writepage: OK
[   34.169673] Testing event xfs_releasepage: OK
[   34.194725] Testing event xfs_invalidatepage: OK
[   34.216201] Testing event xfs_map_blocks_found: OK
[   34.232910] Testing event xfs_map_blocks_alloc: OK
[   34.252291] Testing event xfs_get_blocks_found: OK
[   34.269922] Testing event xfs_get_blocks_alloc: OK
[   34.286460] Testing event xfs_delalloc_enospc: OK
[   34.305204] Testing event xfs_unwritten_convert: OK
[   34.321177] Testing event xfs_get_blocks_notfound: OK
[   34.344638] Testing event xfs_setfilesize: OK
[   34.361407] Testing event xfs_itruncate_extents_start: OK
[   34.376977] Testing event xfs_itruncate_extents_end: OK
[   34.394217] Testing event xfs_pagecache_inval: OK
[   34.408916] Testing event xfs_bunmap: OK
[   34.426837] Testing event xfs_extent_busy: OK
[   34.452093] Testing event xfs_extent_busy_enomem: OK
[   34.469033] Testing event xfs_extent_busy_force: OK
[   34.485557] Testing event xfs_extent_busy_reuse: OK
[   34.501695] Testing event xfs_extent_busy_clear: OK
[   34.520993] Testing event xfs_extent_busy_trim: OK
[   34.536917] Testing event xfs_trans_commit_lsn: OK
[   34.553577] Testing event xfs_agf: OK
[   34.581389] Testing event xfs_free_extent: OK
[   34.597128] Testing event xfs_alloc_exact_done: OK
[   34.621250] Testing event xfs_alloc_exact_notfound: OK
[   34.637163] Testing event xfs_alloc_exact_error: OK
[   34.661140] Testing event xfs_alloc_near_nominleft: OK
[   34.677118] Testing event xfs_alloc_near_first: OK
[   34.698794] Testing event xfs_alloc_near_greater: OK
[   34.717066] Testing event xfs_alloc_near_lesser: OK
[   34.733150] Testing event xfs_alloc_near_error: OK
[   34.766023] Testing event xfs_alloc_near_noentry: OK
[   34.801090] Testing event xfs_alloc_near_busy: OK
[   34.817152] Testing event xfs_alloc_size_neither: OK
[   34.845121] Testing event xfs_alloc_size_noentry: OK
[   34.861149] Testing event xfs_alloc_size_nominleft: OK
[   34.885336] Testing event xfs_alloc_size_done: OK
[   34.903009] Testing event xfs_alloc_size_error: OK
[   34.925149] Testing event xfs_alloc_size_busy: OK
[   34.941114] Testing event xfs_alloc_small_freelist: OK
[   34.965147] Testing event xfs_alloc_small_notenough: OK
[   34.981152] Testing event xfs_alloc_small_done: OK
[   34.997160] Testing event xfs_alloc_small_error: OK
[   35.021192] Testing event xfs_alloc_vextent_badargs: OK
[   35.037206] Testing event xfs_alloc_vextent_nofix: OK
[   35.053157] Testing event xfs_alloc_vextent_noagbp: OK
[   35.077144] Testing event xfs_alloc_vextent_loopfailed: OK
[   35.093116] Testing event xfs_alloc_vextent_allfailed: OK
[   35.109167] Testing event xfs_dir2_sf_addname: OK
[   35.133177] Testing event xfs_dir2_sf_create: OK
[   35.149101] Testing event xfs_dir2_sf_lookup: OK
[   35.165118] Testing event xfs_dir2_sf_replace: OK
[   35.189149] Testing event xfs_dir2_sf_removename: OK
[   35.205182] Testing event xfs_dir2_sf_toino4: OK
[   35.221195] Testing event xfs_dir2_sf_toino8: OK
[   35.245197] Testing event xfs_dir2_sf_to_block: OK
[   35.261189] Testing event xfs_dir2_block_addname: OK
[   35.277145] Testing event xfs_dir2_block_lookup: OK
[   35.301128] Testing event xfs_dir2_block_replace: OK
[   35.317180] Testing event xfs_dir2_block_removename: OK
[   35.333214] Testing event xfs_dir2_block_to_sf: OK
[   35.357145] Testing event xfs_dir2_block_to_leaf: OK
[   35.373138] Testing event xfs_dir2_leaf_addname: OK
[   35.389149] Testing event xfs_dir2_leaf_lookup: OK
[   35.408925] Testing event xfs_dir2_leaf_replace: OK
[   35.424910] Testing event xfs_dir2_leaf_removename: OK
[   35.445141] Testing event xfs_dir2_leaf_to_block: OK
[   35.460926] Testing event xfs_dir2_leaf_to_node: OK
[   35.476901] Testing event xfs_dir2_node_addname: OK
[   35.492925] Testing event xfs_dir2_node_lookup: OK
[   35.508859] Testing event xfs_dir2_node_replace: OK
[   35.525111] Testing event xfs_dir2_node_removename: OK
[   35.541276] Testing event xfs_dir2_node_to_leaf: OK
[   35.562508] Testing event xfs_attr_sf_add: OK
[   35.576885] Testing event xfs_attr_sf_addname: OK
[   35.592900] Testing event xfs_attr_sf_create: OK
[   35.611204] Testing event xfs_attr_sf_lookup: OK
[   35.628922] Testing event xfs_attr_sf_remove: OK
[   35.650550] Testing event xfs_attr_sf_removename: OK
[   35.668912] Testing event xfs_attr_sf_to_leaf: OK
[   35.688875] Testing event xfs_attr_leaf_add: OK
[   35.704885] Testing event xfs_attr_leaf_add_old: OK
[   35.720922] Testing event xfs_attr_leaf_add_new: OK
[   35.736921] Testing event xfs_attr_leaf_addname: OK
[   35.762592] Testing event xfs_attr_leaf_create: OK
[   35.780953] Testing event xfs_attr_leaf_lookup: OK
[   35.796988] Testing event xfs_attr_leaf_replace: OK
[   35.812982] Testing event xfs_attr_leaf_removename: OK
[   35.838593] Testing event xfs_attr_leaf_split: OK
[   35.856930] Testing event xfs_attr_leaf_split_before: OK
[   35.876912] Testing event xfs_attr_leaf_split_after: OK
[   35.892942] Testing event xfs_attr_leaf_clearflag: OK
[   35.915447] Testing event xfs_attr_leaf_setflag: OK
[   35.932971] Testing event xfs_attr_leaf_flipflags: OK
[   35.949673] Testing event xfs_attr_leaf_to_sf: OK
[   35.972419] Testing event xfs_attr_leaf_to_node: OK
[   35.988973] Testing event xfs_attr_leaf_rebalance: OK
[   36.008890] Testing event xfs_attr_leaf_unbalance: OK
[   36.024863] Testing event xfs_attr_node_addname: OK
[   36.040873] Testing event xfs_attr_node_lookup: OK
[   36.060952] Testing event xfs_attr_node_replace: OK
[   36.077832] Testing event xfs_attr_node_removename: OK
[   36.106121] Testing event xfs_da_split: OK
[   36.120980] Testing event xfs_da_join: OK
[   36.139296] Testing event xfs_da_link_before: OK
[   36.163462] Testing event xfs_da_link_after: OK
[   36.184951] Testing event xfs_da_unlink_back: OK
[   36.201184] Testing event xfs_da_unlink_forward: OK
[   36.225305] Testing event xfs_da_root_split: OK
[   36.240929] Testing event xfs_da_root_join: OK
[   36.256928] Testing event xfs_da_node_add: OK
[   36.278512] Testing event xfs_da_node_create: OK
[   36.296934] Testing event xfs_da_node_split: OK
[   36.312925] Testing event xfs_da_node_remove: OK
[   36.338566] Testing event xfs_da_node_rebalance: OK
[   36.356970] Testing event xfs_da_node_unbalance: OK
[   36.372906] Testing event xfs_da_swap_lastblock: OK
[   36.392962] Testing event xfs_da_grow_inode: OK
[   36.418526] Testing event xfs_da_shrink_inode: OK
[   36.436939] Testing event xfs_dir2_leafn_add: OK
[   36.453093] Testing event xfs_dir2_leafn_remove: OK
[   36.468922] Testing event xfs_dir2_grow_inode: OK
[   36.488268] Testing event xfs_dir2_shrink_inode: OK
[   36.505404] Testing event xfs_dir2_leafn_moveents: OK
[   36.521560] Testing event xfs_swap_extent_before: OK
[   36.545707] Testing event xfs_swap_extent_after: OK
[   36.561596] Testing event xfs_log_recover_item_add: OK
[   36.576929] Testing event xfs_log_recover_item_add_cont: OK
[   36.602167] Testing event xfs_log_recover_item_reorder_head: OK
[   36.621142] Testing event xfs_log_recover_item_reorder_tail: OK
[   36.636946] Testing event xfs_log_recover_item_recover: OK
[   36.662044] Testing event xfs_log_recover_buf_not_cancel: OK
[   36.681130] Testing event xfs_log_recover_buf_cancel: OK
[   36.696924] Testing event xfs_log_recover_buf_cancel_add: OK
[   36.718574] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   36.736950] Testing event xfs_log_recover_buf_recover: OK
[   36.758590] Testing event xfs_log_recover_buf_inode_buf: OK
[   36.776871] Testing event xfs_log_recover_buf_reg_buf: OK
[   36.792945] Testing event xfs_log_recover_buf_dquot_buf: OK
[   36.808998] Testing event xfs_log_recover_inode_recover: OK
[   36.832040] Testing event xfs_log_recover_inode_cancel: OK
[   36.848915] Testing event xfs_log_recover_inode_skip: OK
[   36.871408] Testing event xfs_discard_extent: OK
[   36.888930] Testing event xfs_discard_toosmall: OK
[   36.904984] Testing event xfs_discard_exclude: OK
[   36.920807] Testing event xfs_discard_busy: OK
[   36.940906] Testing event jbd2_checkpoint: OK
[   36.965022] Testing event jbd2_start_commit: OK
[   36.984869] Testing event jbd2_commit_locking: OK
[   37.000904] Testing event jbd2_commit_flushing: OK
[   37.025537] Testing event jbd2_commit_logging: OK
[   37.040843] Testing event jbd2_drop_transaction: OK
[   37.056862] Testing event jbd2_end_commit: OK
[   37.078482] Testing event jbd2_submit_inode_data: OK
[   37.092855] Testing event jbd2_run_stats: OK
[   37.108862] Testing event jbd2_checkpoint_stats: OK
[   37.134980] Testing event jbd2_update_log_tail: OK
[   37.152853] Testing event jbd2_write_superblock: OK
[   37.174432] Testing event jbd_checkpoint: OK
[   37.192879] Testing event jbd_start_commit: OK
[   37.208812] Testing event jbd_commit_locking: OK
[   37.224895] Testing event jbd_commit_flushing: OK
[   37.240940] Testing event jbd_commit_logging: OK
[   37.261039] Testing event jbd_drop_transaction: OK
[   37.277275] Testing event jbd_end_commit: OK
[   37.297157] Testing event jbd_do_submit_data: OK
[   37.320045] Testing event jbd_cleanup_journal_tail: OK
[   37.337349] Testing event journal_write_superblock: OK
[   37.352914] Testing event ext4_free_inode: OK
[   37.370207] Testing event ext4_request_inode: OK
[   37.385401] Testing event ext4_allocate_inode: OK
[   37.402731] Testing event ext4_evict_inode: OK
[   37.421852] Testing event ext4_drop_inode: OK
[   37.455910] Testing event ext4_mark_inode_dirty: OK
[   37.481337] Testing event ext4_begin_ordered_truncate: OK
[   37.500929] Testing event ext4_write_begin: OK
[   37.516860] Testing event ext4_da_write_begin: OK
[   37.533217] Testing event ext4_ordered_write_end: OK
[   37.549009] Testing event ext4_writeback_write_end: OK
[   37.564971] Testing event ext4_journalled_write_end: OK
[   37.581014] Testing event ext4_da_write_end: OK
[   37.597536] Testing event ext4_da_writepages: OK
[   37.614550] Testing event ext4_da_write_pages: OK
[   37.638645] Testing event ext4_da_writepages_result: OK
[   37.661929] Testing event ext4_writepage: OK
[   37.681286] Testing event ext4_readpage: OK
[   37.697564] Testing event ext4_releasepage: OK
[   37.717132] Testing event ext4_invalidatepage: OK
[   37.732955] Testing event ext4_discard_blocks: OK
[   37.748935] Testing event ext4_mb_new_inode_pa: OK
[   37.764941] Testing event ext4_mb_new_group_pa: OK
[   37.786387] Testing event ext4_mb_release_inode_pa: OK
[   37.800921] Testing event ext4_mb_release_group_pa: OK
[   37.816926] Testing event ext4_discard_preallocations: OK
[   37.836888] Testing event ext4_mb_discard_preallocations: OK
[   37.856248] Testing event ext4_request_blocks: OK
[   37.873419] Testing event ext4_allocate_blocks: OK
[   37.888950] Testing event ext4_free_blocks: OK
[   37.907216] Testing event ext4_sync_file_enter: OK
[   37.924880] Testing event ext4_sync_file_exit: OK
[   37.940864] Testing event ext4_sync_fs: OK
[   37.956963] Testing event ext4_alloc_da_blocks: OK
[   37.972873] Testing event ext4_mballoc_alloc: OK
[   37.988891] Testing event ext4_mballoc_prealloc: OK
[   38.007186] Testing event ext4_mballoc_discard: OK
[   38.024919] Testing event ext4_mballoc_free: OK
[   38.041205] Testing event ext4_forget: OK
[   38.056938] Testing event ext4_da_update_reserve_space: OK
[   38.072890] Testing event ext4_da_reserve_space: OK
[   38.088999] Testing event ext4_da_release_space: OK
[   38.104869] Testing event ext4_mb_bitmap_load: OK
[   38.129693] Testing event ext4_mb_buddy_bitmap_load: OK
[   38.148865] Testing event ext4_read_block_bitmap_load: OK
[   38.168228] Testing event ext4_load_inode_bitmap: OK
[   38.184995] Testing event ext4_direct_IO_enter: OK
[   38.200943] Testing event ext4_direct_IO_exit: OK
[   38.216882] Testing event ext4_fallocate_enter: OK
[   38.233215] Testing event ext4_fallocate_exit: OK
[   38.252916] Testing event ext4_unlink_enter: OK
[   38.268869] Testing event ext4_unlink_exit: OK
[   38.294109] Testing event ext4_truncate_enter: OK
[   38.308814] Testing event ext4_truncate_exit: OK
[   38.324893] Testing event ext4_ext_convert_to_initialized_enter: OK
[   38.350303] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   38.368842] Testing event ext4_ext_map_blocks_enter: OK
[   38.384910] Testing event ext4_ind_map_blocks_enter: OK
[   38.404875] Testing event ext4_ext_map_blocks_exit: OK
[   38.424865] Testing event ext4_ind_map_blocks_exit: OK
[   38.440864] Testing event ext4_ext_load_extent: OK
[   38.462239] Testing event ext4_load_inode: OK
[   38.476974] Testing event ext4_journal_start: OK
[   38.493041] Testing event ext4_trim_extent: OK
[   38.511100] Testing event ext4_trim_all_free: OK
[   38.528935] Testing event ext4_ext_handle_uninitialized_extents: OK
[   38.545210] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   38.563244] Testing event ext4_ext_put_in_cache: OK
[   38.580945] Testing event ext4_ext_in_cache: OK
[   38.600926] Testing event ext4_find_delalloc_range: OK
[   38.620907] Testing event ext4_get_reserved_cluster_alloc: OK
[   38.639926] Testing event ext4_ext_show_extent: OK
[   38.660978] Testing event ext4_remove_blocks: OK
[   38.677196] Testing event ext4_ext_rm_leaf: OK
[   38.700174] Testing event ext4_ext_rm_idx: OK
[   38.717003] Testing event ext4_ext_remove_space: OK
[   38.732982] Testing event ext4_ext_remove_space_done: OK
[   38.748938] Testing event ext3_free_inode: OK
[   38.764937] Testing event ext3_request_inode: OK
[   38.782406] Testing event ext3_allocate_inode: OK
[   38.796997] Testing event ext3_evict_inode: OK
[   38.812961] Testing event ext3_drop_inode: OK
[   38.831256] Testing event ext3_mark_inode_dirty: OK
[   38.848962] Testing event ext3_write_begin: OK
[   38.871301] Testing event ext3_ordered_write_end: OK
[   38.889019] Testing event ext3_writeback_write_end: OK
[   38.904962] Testing event ext3_journalled_write_end: OK
[   38.922229] Testing event ext3_ordered_writepage: OK
[   38.936927] Testing event ext3_writeback_writepage: OK
[   38.953152] Testing event ext3_journalled_writepage: OK
[   38.968964] Testing event ext3_readpage: OK
[   38.990969] Testing event ext3_releasepage: OK
[   39.008990] Testing event ext3_invalidatepage: OK
[   39.036282] Testing event ext3_discard_blocks: OK
[   39.057444] Testing event ext3_request_blocks: OK
[   39.072974] Testing event ext3_allocate_blocks: OK
[   39.099397] Testing event ext3_free_blocks: OK
[   39.117112] Testing event ext3_sync_file_enter: OK
[   39.133167] Testing event ext3_sync_file_exit: OK
[   39.151142] Testing event ext3_sync_fs: OK
[   39.168886] Testing event ext3_rsv_window_add: OK
[   39.184920] Testing event ext3_discard_reservation: OK
[   39.210464] Testing event ext3_alloc_new_reservation: OK
[   39.229098] Testing event ext3_reserved: OK
[   39.244945] Testing event ext3_forget: OK
[   39.264893] Testing event ext3_read_block_bitmap: OK
[   39.289612] Testing event ext3_direct_IO_enter: OK
[   39.305116] Testing event ext3_direct_IO_exit: OK
[   39.321046] Testing event ext3_unlink_enter: OK
[   39.345052] Testing event ext3_unlink_exit: OK
[   39.365790] Testing event ext3_truncate_enter: OK
[   39.385011] Testing event ext3_truncate_exit: OK
[   39.401278] Testing event ext3_get_blocks_enter: OK
[   39.416923] Testing event ext3_get_blocks_exit: OK
[   39.433014] Testing event ext3_load_inode: OK
[   39.448948] Testing event writeback_nothread: OK
[   39.467056] Testing event writeback_queue: OK
[   39.485221] Testing event writeback_exec: OK
[   39.501163] Testing event writeback_start: OK
[   39.528174] Testing event writeback_written: OK
[   39.545420] Testing event writeback_wait: OK
[   39.562193] Testing event writeback_pages_written: OK
[   39.585591] Testing event writeback_nowork: OK
[   39.601654] Testing event writeback_wake_background: OK
[   39.621174] Testing event writeback_wake_thread: OK
[   39.640968] Testing event writeback_wake_forker_thread: OK
[   39.660968] Testing event writeback_bdi_register: OK
[   39.677231] Testing event writeback_bdi_unregister: OK
[   39.696499] Testing event writeback_thread_start: OK
[   39.713001] Testing event writeback_thread_stop: OK
[   39.730002] Testing event wbc_writepage: OK
[   39.745085] Testing event writeback_queue_io: OK
[   39.762204] Testing event global_dirty_state: OK
[   39.777697] Testing event bdi_dirty_ratelimit: OK
[   39.797640] Testing event balance_dirty_pages: OK
[   39.818203] Testing event writeback_sb_inodes_requeue: OK
[   39.832915] Testing event writeback_congestion_wait: OK
[   39.849000] Testing event writeback_wait_iff_congested: OK
[   39.865225] Testing event writeback_single_inode: OK
[   39.881220] Testing event mm_compaction_isolate_migratepages: OK
[   39.897020] Testing event mm_compaction_isolate_freepages: OK
[   39.912887] Testing event mm_compaction_migratepages: OK
[   39.928961] Testing event kmalloc: OK
[   39.944905] Testing event kmem_cache_alloc: OK
[   39.960876] Testing event kmalloc_node: OK
[   39.976901] Testing event kmem_cache_alloc_node: OK
[   39.992926] Testing event kfree: OK
[   40.009157] Testing event kmem_cache_free: OK
[   40.024927] Testing event mm_page_free: OK
[   40.040967] Testing event mm_page_free_batched: OK
[   40.057037] Testing event mm_page_alloc: OK
[   40.072936] Testing event mm_page_alloc_zone_locked: OK
[   40.088951] Testing event mm_page_pcpu_drain: OK
[   40.104948] Testing event mm_page_alloc_extfrag: OK
[   40.120953] Testing event mm_vmscan_kswapd_sleep: OK
[   40.136946] Testing event mm_vmscan_kswapd_wake: OK
[   40.152942] Testing event mm_vmscan_wakeup_kswapd: OK
[   40.168929] Testing event mm_vmscan_direct_reclaim_begin: OK
[   40.184952] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   40.201691] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   40.224948] Testing event mm_vmscan_direct_reclaim_end: OK
[   40.241095] Testing event mm_vmscan_memcg_reclaim_end: OK
[   40.263698] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   40.281028] Testing event mm_shrink_slab_start: OK
[   40.297171] Testing event mm_shrink_slab_end: OK
[   40.317176] Testing event mm_vmscan_lru_isolate: OK
[   40.332971] Testing event mm_vmscan_memcg_isolate: OK
[   40.353000] Testing event mm_vmscan_writepage: OK
[   40.372970] Testing event mm_vmscan_lru_shrink_inactive: OK
[   40.394544] Testing event oom_score_adj_update: OK
[   40.413069] Testing event rpm_suspend: OK
[   40.433003] Testing event rpm_resume: OK
[   40.448960] Testing event rpm_idle: OK
[   40.474554] Testing event rpm_return_int: OK
[   40.492907] Testing event cpu_idle: OK
[   40.508905] Testing event cpu_frequency: OK
[   40.525282] Testing event machine_suspend: OK
[   40.549242] Testing event wakeup_source_activate: OK
[   40.565398] Testing event wakeup_source_deactivate: OK
[   40.581960] Testing event power_start: OK
[   40.601710] Testing event power_frequency: OK
[   40.621567] Testing event power_end: OK
[   40.636956] Testing event clock_enable: OK
[   40.652939] Testing event clock_disable: OK
[   40.677140] Testing event clock_set_rate: OK
[   40.692950] Testing event power_domain_target: OK
[   40.709250] Testing event ftrace_test_filter: OK
[   40.731754] Testing event module_load: OK
[   40.749240] Testing event module_free: OK
[   40.764981] Testing event module_get: OK
[   40.784315] Testing event module_put: OK
[   40.804903] Testing event module_request: OK
[   40.821574] Testing event lock_acquire: OK
[   40.841723] Testing event lock_release: OK
[   40.864796] Testing event lock_contended: OK
[   40.881548] Testing event lock_acquired: OK
[   40.896987] Testing event sched_kthread_stop: OK
[   40.916845] Testing event sched_kthread_stop_ret: OK
[   40.944907] Testing event sched_wakeup: OK
[   40.960885] Testing event sched_wakeup_new: OK
[   40.976881] Testing event sched_switch: OK
[   40.992910] Testing event sched_migrate_task: OK
[   41.011281] Testing event sched_process_free: OK
[   41.028940] Testing event sched_process_exit: OK
[   41.050920] Testing event sched_wait_task: OK
[   41.068923] Testing event sched_process_wait: OK
[   41.086110] Testing event sched_process_fork: OK
[   41.100881] Testing event sched_process_exec: OK
[   41.117169] Testing event sched_stat_wait: OK
[   41.134501] Testing event sched_stat_sleep: OK
[   41.148924] Testing event sched_stat_iowait: OK
[   41.164910] Testing event sched_stat_blocked: OK
[   41.180895] Testing event sched_stat_runtime: OK
[   41.196910] Testing event sched_pi_setprio: OK
[   41.213039] Testing event rcu_utilization: OK
[   41.228968] Testing event rcu_grace_period: OK
[   41.244936] Testing event rcu_grace_period_init: OK
[   41.260918] Testing event rcu_preempt_task: OK
[   41.278348] Testing event rcu_unlock_preempted_task: OK
[   41.296906] Testing event rcu_quiescent_state_report: OK
[   41.312946] Testing event rcu_fqs: OK
[   41.328937] Testing event rcu_dyntick: OK
[   41.351349] Testing event rcu_prep_idle: OK
[   41.383171] Testing event rcu_callback: OK
[   41.413785] Testing event rcu_kfree_callback: OK
[   41.428983] Testing event rcu_batch_start: OK
[   41.445343] Testing event rcu_invoke_callback: OK
[   41.461009] Testing event rcu_invoke_kfree_callback: OK
[   41.484577] Testing event rcu_batch_end: OK
[   41.500989] Testing event rcu_torture_read: OK
[   41.521688] Testing event rcu_barrier: OK
[   41.541039] Testing event workqueue_queue_work: OK
[   41.562507] Testing event workqueue_activate_work: OK
[   41.581054] Testing event workqueue_execute_start: OK
[   41.602486] Testing event workqueue_execute_end: OK
[   41.621074] Testing event signal_generate: OK
[   41.637129] Testing event signal_deliver: OK
[   41.660900] Testing event timer_init: OK
[   41.677118] Testing event timer_start: OK
[   41.692999] Testing event timer_expire_entry: OK
[   41.708885] Testing event timer_expire_exit: OK
[   41.724920] Testing event timer_cancel: OK
[   41.740957] Testing event hrtimer_init: OK
[   41.756937] Testing event hrtimer_start: OK
[   41.772919] Testing event hrtimer_expire_entry: OK
[   41.789297] Testing event hrtimer_expire_exit: OK
[   41.804918] Testing event hrtimer_cancel: OK
[   41.820896] Testing event itimer_state: OK
[   41.836869] Testing event itimer_expire: OK
[   41.852889] Testing event irq_handler_entry: OK
[   41.874778] Testing event irq_handler_exit: OK
[   41.892955] Testing event softirq_entry: OK
[   41.908884] Testing event softirq_exit: OK
[   41.924920] Testing event softirq_raise: OK
[   41.940881] Testing event console: OK
[   41.956864] Testing event task_newtask: OK
[   41.972886] Testing event task_rename: OK
[   41.989093] Testing event mce_record: OK
[   42.005018] Testing event sys_enter: OK
[   42.022481] Testing event sys_exit: OK
[   42.036899] Testing event emulate_vsyscall: OK
[   42.052923] Testing event xen_mc_batch: OK
[   42.068913] Testing event xen_mc_issue: OK
[   42.085091] Testing event xen_mc_entry: OK
[   42.100931] Testing event xen_mc_entry_alloc: OK
[   42.116926] Testing event xen_mc_callback: OK
[   42.132902] Testing event xen_mc_flush_reason: OK
[   42.149210] Testing event xen_mc_flush: OK
[   42.164923] Testing event xen_mc_extend_args: OK
[   42.180920] Testing event xen_mmu_set_pte: OK
[   42.196986] Testing event xen_mmu_set_pte_atomic: OK
[   42.212920] Testing event xen_mmu_set_domain_pte: OK
[   42.229523] Testing event xen_mmu_set_pte_at: OK
[   42.244928] Testing event xen_mmu_pte_clear: OK
[   42.260930] Testing event xen_mmu_set_pmd: OK
[   42.276932] Testing event xen_mmu_pmd_clear: OK
[   42.293013] Testing event xen_mmu_set_pud: OK
[   42.308874] Testing event xen_mmu_set_pgd: OK
[   42.324927] Testing event xen_mmu_pud_clear: OK
[   42.341022] Testing event xen_mmu_pgd_clear: OK
[   42.357390] Testing event xen_mmu_ptep_modify_prot_start: OK
[   42.381157] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   42.400071] Testing event xen_mmu_alloc_ptpage: OK
[   42.417130] Testing event xen_mmu_release_ptpage: OK
[   42.433218] Testing event xen_mmu_pgd_pin: OK
[   42.449101] Testing event xen_mmu_pgd_unpin: OK
[   42.465187] Testing event xen_mmu_flush_tlb: OK
[   42.481126] Testing event xen_mmu_flush_tlb_single: OK
[   42.497203] Testing event xen_mmu_flush_tlb_others: OK
[   42.513209] Testing event xen_mmu_write_cr3: OK
[   42.529127] Testing event xen_cpu_write_ldt_entry: OK
[   42.545135] Testing event xen_cpu_write_idt_entry: OK
[   42.561218] Testing event xen_cpu_load_idt: OK
[   42.577338] Testing event xen_cpu_write_gdt_entry: OK
[   42.593558] Testing event xen_cpu_set_ldt: OK
[   42.609203] Testing event kvm_mmu_pagetable_walk: OK
[   42.625574] Testing event kvm_mmu_paging_element: OK
[   42.641156] Testing event kvm_mmu_set_accessed_bit: OK
[   42.657298] Testing event kvm_mmu_set_dirty_bit: OK
[   42.673581] Testing event kvm_mmu_walker_error: OK
[   42.689282] Testing event kvm_mmu_get_page: OK
[   42.705554] Testing event kvm_mmu_sync_page: OK
[   42.721219] Testing event kvm_mmu_unsync_page: OK
[   42.737339] Testing event kvm_mmu_prepare_zap_page: OK
[   42.754440] Testing event kvm_mmu_delay_free_pages: OK
[   42.773624] Testing event mark_mmio_spte: OK
[   42.789706] Testing event handle_mmio_page_fault: OK
[   42.805643] Testing event fast_page_fault: OK
[   42.820842] Testing event kvm_entry: OK
[   42.836869] Testing event kvm_hypercall: OK
[   42.861203] Testing event kvm_hv_hypercall: OK
[   42.878268] Testing event kvm_pio: OK
[   42.892923] Testing event kvm_cpuid: OK
[   42.908944] Testing event kvm_apic: OK
[   42.924935] Testing event kvm_exit: OK
[   42.941024] Testing event kvm_inj_virq: OK
[   42.957062] Testing event kvm_inj_exception: OK
[   42.972930] Testing event kvm_page_fault: OK
[   42.988991] Testing event kvm_msr: OK
[   43.005017] Testing event kvm_cr: OK
[   43.021399] Testing event kvm_pic_set_irq: OK
[   43.043841] Testing event kvm_apic_ipi: OK
[   43.061083] Testing event kvm_apic_accept_irq: OK
[   43.077163] Testing event kvm_eoi: OK
[   43.100913] Testing event kvm_pv_eoi: OK
[   43.117698] Testing event kvm_nested_vmrun: OK
[   43.133216] Testing event kvm_nested_intercepts: OK
[   43.157709] Testing event kvm_nested_vmexit: OK
[   43.173647] Testing event kvm_nested_vmexit_inject: OK
[   43.189018] Testing event kvm_nested_intr_vmexit: OK
[   43.206201] Testing event kvm_invlpga: OK
[   43.221145] Testing event kvm_skinit: OK
[   43.245439] Testing event kvm_emulate_insn: OK
[   43.261076] Testing event vcpu_match_mmio: OK
[   43.277235] Testing event kvm_userspace_exit: OK
[   43.295174] Testing event kvm_set_irq: OK
[   43.312898] Testing event kvm_ioapic_set_irq: OK
[   43.328877] Testing event kvm_msi_set_irq: OK
[   43.348888] Testing event kvm_ack_irq: OK
[   43.371158] Testing event kvm_mmio: OK
[   43.389205] Testing event kvm_fpu: OK
[   43.410426] Testing event kvm_age_page: OK
[   43.428973] Testing event kvm_try_async_get_page: OK
[   43.444811] Testing event kvm_async_pf_doublefault: OK
[   43.460934] Testing event kvm_async_pf_not_present: OK
[   43.476847] Testing event kvm_async_pf_ready: OK
[   43.493278] Testing event kvm_async_pf_completed: OK
[   43.508901] Running tests on trace event systems:
[   43.510131] Testing event system 9p: OK
[   43.525043] Testing event system mac80211: OK
[   43.556810] Testing event system sunrpc: OK
[   43.573934] Testing event system skb: OK
[   43.593134] Testing event system net: OK
[   43.609283] Testing event system napi: OK
[   43.625052] Testing event system sock: OK
[   43.641087] Testing event system udp: OK
[   43.663332] Testing event system hda: OK
[   43.682001] Testing event system ras: OK
[   43.705067] Testing event system scsi: OK
[   43.721425] Testing event system regmap: OK
[   43.751105] Testing event system i915: OK
[   43.775731] Testing event system radeon: OK
[   43.799810] Testing event system drm: OK
[   43.822095] Testing event system random: OK
[   43.848299] Testing event system regulator: OK
[   43.865882] Testing event system gpio: OK
[   43.881078] Testing event system block: OK
[   43.902859] Testing event system gfs2: OK
[   43.922230] Testing event system btrfs: OK
[   43.944528] Testing event system ocfs2: OK
[   44.068711] Testing event system xfs: OK
[   44.174816] Testing event system jbd2: OK
[   44.193679] Testing event system jbd: OK
[   44.210666] Testing event system ext4: OK
[   44.245783] Testing event system ext3: OK
[   44.268461] Testing event system writeback: OK
[   44.287376] Testing event system compaction: OK
[   44.306882] Testing event system kmem: OK
[   44.325877] Testing event system vmscan: OK
[   44.346622] Testing event system oom: OK
[   44.365103] Testing event system rpm: OK
[   44.382210] Testing event system power: OK
[   44.406070] Testing event system test: OK
[   44.420956] Testing event system module: OK
[   44.441802] Testing event system lock: OK
[   44.461074] Testing event system sched: OK
[   44.482627] Testing event system rcu: OK
[   44.502615] Testing event system workqueue: OK
[   44.521396] Testing event system signal: OK
[   44.537141] Testing event system timer: OK
[   44.553904] Testing event system irq: OK
[   44.573544] Testing event system printk: OK
[   44.589126] Testing event system task: OK
[   44.605336] Testing event system mce: OK
[   44.627303] Testing event system raw_syscalls: OK
[   44.645159] Testing event system vsyscall: OK
[   44.661170] Testing event system syscalls: OK
[   44.686557] Testing event system xen: OK
[   44.708502] Testing event system kvmmmu: OK
[   44.726537] Testing event system kvm: OK
[   44.750306] Running tests on all trace events:
[   44.751568] Testing all events: OK
[   45.686776] Running tests again, along with the function tracer
[   45.697760] Running tests on trace events:
[   45.698994] Testing event 9p_client_req: OK
[   45.726431] Testing event 9p_client_res: OK
[   45.746399] Testing event 9p_protocol_dump: OK
[   45.769907] Testing event drv_return_void: OK
[   45.790992] Testing event drv_return_int: OK
[   45.812865] Testing event drv_return_bool: OK
[   45.834850] Testing event drv_return_u64: OK
[   45.854695] Testing event drv_start: OK
[   45.875168] Testing event drv_get_et_strings: OK
[   45.898408] Testing event drv_get_et_sset_count: OK
[   45.918604] Testing event drv_get_et_stats: OK
[   45.947985] Testing event drv_suspend: OK
[   45.967611] Testing event drv_resume: OK
[   45.987303] Testing event drv_set_wakeup: OK
[   46.006538] Testing event drv_stop: OK
[   46.027016] Testing event drv_add_interface: OK
[   46.055493] Testing event drv_change_interface: OK
[   46.077993] Testing event drv_remove_interface: OK
[   46.108488] Testing event drv_config: OK
[   46.131672] Testing event drv_bss_info_changed: OK
[   46.159746] Testing event drv_prepare_multicast: OK
[   46.182968] Testing event drv_configure_filter: OK
[   46.210881] Testing event drv_set_tim: OK
[   46.231683] Testing event drv_set_key: OK
[   46.255101] Testing event drv_update_tkip_key: OK
[   46.275297] Testing event drv_hw_scan: OK
[   46.304673] Testing event drv_cancel_hw_scan: OK
[   46.332761] Testing event drv_sched_scan_start: OK
[   46.355386] Testing event drv_sched_scan_stop: OK
[   46.374887] Testing event drv_sw_scan_start: OK
[   46.400779] Testing event drv_sw_scan_complete: OK
[   46.426462] Testing event drv_get_stats: OK
[   46.447546] Testing event drv_get_tkip_seq: OK
[   46.480207] Testing event drv_set_frag_threshold: OK
[   46.510458] Testing event drv_set_rts_threshold: OK
[   46.530864] Testing event drv_set_coverage_class: OK
[   46.576656] Testing event drv_sta_notify: OK
[   46.596204] Testing event drv_sta_state: OK
[   46.624727] Testing event drv_sta_rc_update: OK
[   46.649860] Testing event drv_sta_add: OK
[   46.670318] Testing event drv_sta_remove: OK
[   46.690551] Testing event drv_conf_tx: OK
[   46.710941] Testing event drv_get_tsf: OK
[   46.730412] Testing event drv_set_tsf: OK
[   46.750317] Testing event drv_reset_tsf: OK
[   46.770813] Testing event drv_tx_last_beacon: OK
[   46.790475] Testing event drv_ampdu_action: OK
[   46.814166] Testing event drv_get_survey: OK
[   46.834322] Testing event drv_flush: OK
[   46.854618] Testing event drv_channel_switch: OK
[   46.874913] Testing event drv_set_antenna: OK
[   46.897049] Testing event drv_get_antenna: OK
[   46.919225] Testing event drv_remain_on_channel: OK
[   46.939148] Testing event drv_cancel_remain_on_channel: OK
[   46.958433] Testing event drv_offchannel_tx: OK
[   46.978502] Testing event drv_set_ringparam: OK
[   46.998818] Testing event drv_get_ringparam: OK
[   47.018832] Testing event drv_tx_frames_pending: OK
[   47.038619] Testing event drv_offchannel_tx_cancel_wait: OK
[   47.058926] Testing event drv_set_bitrate_mask: OK
[   47.078946] Testing event drv_set_rekey_data: OK
[   47.099734] Testing event drv_rssi_callback: OK
[   47.122993] Testing event drv_release_buffered_frames: OK
[   47.142571] Testing event drv_allow_buffered_frames: OK
[   47.162504] Testing event drv_get_rssi: OK
[   47.182410] Testing event drv_mgd_prepare_tx: OK
[   47.206439] Testing event api_start_tx_ba_session: OK
[   47.227594] Testing event api_start_tx_ba_cb: OK
[   47.247306] Testing event api_stop_tx_ba_session: OK
[   47.276843] Testing event api_stop_tx_ba_cb: OK
[   47.299305] Testing event api_restart_hw: OK
[   47.327092] Testing event api_beacon_loss: OK
[   47.352555] Testing event api_connection_loss: OK
[   47.381625] Testing event api_cqm_rssi_notify: OK
[   47.402583] Testing event api_scan_completed: OK
[   47.422567] Testing event api_sched_scan_results: OK
[   47.442511] Testing event api_sched_scan_stopped: OK
[   47.462542] Testing event api_sta_block_awake: OK
[   47.482494] Testing event api_chswitch_done: OK
[   47.503134] Testing event api_ready_on_channel: OK
[   47.532778] Testing event api_remain_on_channel_expired: OK
[   47.560729] Testing event api_gtk_rekey_notify: OK
[   47.588521] Testing event api_enable_rssi_reports: OK
[   47.615492] Testing event api_eosp: OK
[   47.644965] Testing event wake_queue: OK
[   47.666592] Testing event stop_queue: OK
[   47.696089] Testing event rpc_call_status: OK
[   47.715819] Testing event rpc_bind_status: OK
[   47.746393] Testing event rpc_connect_status: OK
[   47.767137] Testing event rpc_task_begin: OK
[   47.795631] Testing event rpc_task_run_action: OK
[   47.815070] Testing event rpc_task_complete: OK
[   47.845314] Testing event rpc_task_sleep: OK
[   47.872601] Testing event rpc_task_wakeup: OK
[   47.895278] Testing event kfree_skb: OK
[   47.915721] Testing event consume_skb: OK
[   47.934317] Testing event skb_copy_datagram_iovec: OK
[   47.954418] Testing event net_dev_xmit: OK
[   47.974338] Testing event net_dev_queue: OK
[   47.994842] Testing event netif_receive_skb: OK
[   48.014416] Testing event netif_rx: OK
[   48.034631] Testing event napi_poll: OK
[   48.055564] Testing event sock_rcvqueue_full: OK
[   48.079658] Testing event sock_exceed_buf_limit: OK
[   48.098954] Testing event udp_fail_queue_rcv_skb: OK
[   48.119680] Testing event hda_send_cmd: OK
[   48.139036] Testing event hda_get_response: OK
[   48.159578] Testing event hda_bus_reset: OK
[   48.179010] Testing event hda_power_down: OK
[   48.200550] Testing event hda_power_up: OK
[   48.246533] Testing event hda_unsol_event: OK
[   48.275580] Testing event mc_event: OK
[   48.294948] Testing event scsi_dispatch_cmd_start: OK
[   48.323943] Testing event scsi_dispatch_cmd_error: OK
[   48.348667] Testing event scsi_dispatch_cmd_done: OK
[   48.370479] Testing event scsi_dispatch_cmd_timeout: OK
[   48.398860] Testing event scsi_eh_wakeup: OK
[   48.424312] Testing event regmap_reg_write: OK
[   48.443074] Testing event regmap_reg_read: OK
[   48.471646] Testing event regmap_reg_read_cache: OK
[   48.495625] Testing event regmap_hw_read_start: OK
[   48.514402] Testing event regmap_hw_read_done: OK
[   48.534912] Testing event regmap_hw_write_start: OK
[   48.554850] Testing event regmap_hw_write_done: OK
[   48.575186] Testing event regcache_sync: OK
[   48.599892] Testing event regmap_cache_only: OK
[   48.618922] Testing event regmap_cache_bypass: OK
[   48.647196] Testing event i915_gem_object_create: OK
[   48.676083] Testing event i915_gem_object_bind: OK
[   48.704335] Testing event i915_gem_object_unbind: OK
[   48.727115] Testing event i915_gem_object_change_domain: OK
[   48.759200] Testing event i915_gem_object_pwrite: OK
[   48.778433] Testing event i915_gem_object_pread: OK
[   48.798403] Testing event i915_gem_object_fault: OK
[   48.818910] Testing event i915_gem_object_clflush: OK
[   48.846563] Testing event i915_gem_object_destroy: OK
[   48.867712] Testing event i915_gem_evict: OK
[   48.889606] Testing event i915_gem_evict_everything: OK
[   48.926389] Testing event i915_gem_ring_dispatch: OK
[   48.947415] Testing event i915_gem_ring_flush: OK
[   48.966981] Testing event i915_gem_request_add: OK
[   48.986524] Testing event i915_gem_request_complete: OK
[   49.006384] Testing event i915_gem_request_retire: OK
[   49.026475] Testing event i915_gem_request_wait_begin: OK
[   49.046535] Testing event i915_gem_request_wait_end: OK
[   49.066491] Testing event i915_ring_wait_begin: OK
[   49.086847] Testing event i915_ring_wait_end: OK
[   49.112106] Testing event i915_flip_request: OK
[   49.135476] Testing event i915_flip_complete: OK
[   49.154942] Testing event i915_reg_rw: OK
[   49.182725] Testing event radeon_bo_create: OK
[   49.202685] Testing event radeon_fence_emit: OK
[   49.223012] Testing event radeon_fence_retire: OK
[   49.247034] Testing event radeon_fence_wait_begin: OK
[   49.267507] Testing event radeon_fence_wait_end: OK
[   49.286840] Testing event drm_vblank_event: OK
[   49.306550] Testing event drm_vblank_event_queued: OK
[   49.326425] Testing event drm_vblank_event_delivered: OK
[   49.347084] Testing event mix_pool_bytes: OK
[   49.366334] Testing event mix_pool_bytes_nolock: OK
[   49.386546] Testing event credit_entropy_bits: OK
[   49.406454] Testing event get_random_bytes: OK
[   49.430340] Testing event extract_entropy: OK
[   49.450291] Testing event extract_entropy_user: OK
[   49.474755] Testing event regulator_enable: OK
[   49.494148] Testing event regulator_enable_delay: OK
[   49.514014] Testing event regulator_enable_complete: OK
[   49.535821] Testing event regulator_disable: OK
[   49.554341] Testing event regulator_disable_complete: OK
[   49.574969] Testing event regulator_set_voltage: OK
[   49.597703] Testing event regulator_set_voltage_complete: OK
[   49.618392] Testing event gpio_direction: OK
[   49.638350] Testing event gpio_value: OK
[   49.658442] Testing event block_rq_abort: OK
[   49.678285] Testing event block_rq_requeue: OK
[   49.698393] Testing event block_rq_complete: OK
[   49.719293] Testing event block_rq_insert: OK
[   49.738478] Testing event block_rq_issue: OK
[   49.758258] Testing event block_bio_bounce: OK
[   49.787624] Testing event block_bio_complete: OK
[   49.806468] Testing event block_bio_backmerge: OK
[   49.826400] Testing event block_bio_frontmerge: OK
[   49.846896] Testing event block_bio_queue: OK
[   49.866313] Testing event block_getrq: OK
[   49.886506] Testing event block_sleeprq: OK
[   49.906435] Testing event block_plug: OK
[   49.926528] Testing event block_unplug: OK
[   49.945930] Testing event block_split: OK
[   49.965830] Testing event block_bio_remap: OK
[   49.986223] Testing event block_rq_remap: OK
[   50.005937] Testing event gfs2_glock_state_change: OK
[   50.025904] Testing event gfs2_glock_put: OK
[   50.046999] Testing event gfs2_demote_rq: OK
[   50.067123] Testing event gfs2_promote: OK
[   50.086925] Testing event gfs2_glock_queue: OK
[   50.114332] Testing event gfs2_glock_lock_time: OK
[   50.134284] Testing event gfs2_pin: OK
[   50.154255] Testing event gfs2_log_flush: OK
[   50.173635] Testing event gfs2_log_blocks: OK
[   50.190637] Testing event gfs2_ail_flush: OK
[   50.217602] Testing event gfs2_bmap: OK
[   50.238442] Testing event gfs2_block_alloc: OK
[   50.259304] Testing event gfs2_rs: OK
[   50.277642] Testing event btrfs_transaction_commit: OK
[   50.298329] Testing event btrfs_inode_new: OK
[   50.318336] Testing event btrfs_inode_request: OK
[   50.338407] Testing event btrfs_inode_evict: OK
[   50.358340] Testing event btrfs_get_extent: OK
[   50.378307] Testing event btrfs_ordered_extent_add: OK
[   50.398262] Testing event btrfs_ordered_extent_remove: OK
[   50.418217] Testing event btrfs_ordered_extent_start: OK
[   50.438228] Testing event btrfs_ordered_extent_put: OK
[   50.458442] Testing event __extent_writepage: OK
[   50.478561] Testing event btrfs_writepage_end_io_hook: OK
[   50.498652] Testing event btrfs_sync_file: OK
[   50.518479] Testing event btrfs_sync_fs: OK
[   50.538386] Testing event btrfs_delayed_tree_ref: OK
[   50.558433] Testing event btrfs_delayed_data_ref: OK
[   50.578440] Testing event btrfs_delayed_ref_head: OK
[   50.598434] Testing event btrfs_chunk_alloc: OK
[   50.618477] Testing event btrfs_chunk_free: OK
[   50.638567] Testing event btrfs_cow_block: OK
[   50.658524] Testing event btrfs_space_reservation: OK
[   50.679231] Testing event btrfs_reserved_extent_alloc: OK
[   50.698320] Testing event btrfs_reserved_extent_free: OK
[   50.718311] Testing event find_free_extent: OK
[   50.738259] Testing event btrfs_reserve_extent: OK
[   50.758376] Testing event btrfs_reserve_extent_cluster: OK
[   50.778810] Testing event btrfs_find_cluster: OK
[   50.799551] Testing event btrfs_failed_cluster_setup: OK
[   50.818322] Testing event btrfs_setup_cluster: OK
[   50.838400] Testing event alloc_extent_state: OK
[   50.858554] Testing event free_extent_state: OK
[   50.877829] Testing event ocfs2_adjust_rightmost_branch: OK
[   50.898933] Testing event ocfs2_rotate_tree_right: OK
[   50.920523] Testing event ocfs2_append_rec_to_path: OK
[   50.938284] Testing event ocfs2_insert_extent_start: OK
[   50.958316] Testing event ocfs2_add_clusters_in_btree: OK
[   50.978545] Testing event ocfs2_num_free_extents: OK
[   50.998254] Testing event ocfs2_complete_edge_insert: OK
[   51.018455] Testing event ocfs2_grow_tree: OK
[   51.038386] Testing event ocfs2_rotate_subtree: OK
[   51.057956] Testing event ocfs2_insert_extent: OK
[   51.078433] Testing event ocfs2_split_extent: OK
[   51.098871] Testing event ocfs2_remove_extent: OK
[   51.118508] Testing event ocfs2_commit_truncate: OK
[   51.137715] Testing event ocfs2_validate_extent_block: OK
[   51.162883] Testing event ocfs2_rotate_leaf: OK
[   51.194503] Testing event ocfs2_add_clusters_in_btree_ret: OK
[   51.226227] Testing event ocfs2_mark_extent_written: OK
[   51.245930] Testing event ocfs2_truncate_log_append: OK
[   51.269618] Testing event ocfs2_replay_truncate_records: OK
[   51.307077] Testing event ocfs2_flush_truncate_log: OK
[   51.327675] Testing event ocfs2_begin_truncate_log_recovery: OK
[   51.346124] Testing event ocfs2_truncate_log_recovery_num: OK
[   51.366471] Testing event ocfs2_complete_truncate_log_recovery: OK
[   51.386896] Testing event ocfs2_free_cached_blocks: OK
[   51.417017] Testing event ocfs2_cache_cluster_dealloc: OK
[   51.439275] Testing event ocfs2_run_deallocs: OK
[   51.463140] Testing event ocfs2_cache_block_dealloc: OK
[   51.484746] Testing event ocfs2_trim_extent: OK
[   51.506835] Testing event ocfs2_trim_group: OK
[   51.526868] Testing event ocfs2_trim_fs: OK
[   51.546823] Testing event ocfs2_la_set_sizes: OK
[   51.566979] Testing event ocfs2_alloc_should_use_local: OK
[   51.589824] Testing event ocfs2_load_local_alloc: OK
[   51.610473] Testing event ocfs2_begin_local_alloc_recovery: OK
[   51.630643] Testing event ocfs2_reserve_local_alloc_bits: OK
[   51.651564] Testing event ocfs2_local_alloc_count_bits: OK
[   51.670762] Testing event ocfs2_local_alloc_find_clear_bits_search_bitma=
p: OK
[   51.690645] Testing event ocfs2_local_alloc_find_clear_bits: OK
[   51.711102] Testing event ocfs2_sync_local_to_main: OK
[   51.735003] Testing event ocfs2_sync_local_to_main_free: OK
[   51.755664] Testing event ocfs2_local_alloc_new_window: OK
[   51.775383] Testing event ocfs2_local_alloc_new_window_result: OK
[   51.794512] Testing event ocfs2_update_last_group_and_inode: OK
[   51.814518] Testing event ocfs2_group_extend: OK
[   51.834461] Testing event ocfs2_group_add: OK
[   51.854876] Testing event ocfs2_validate_group_descriptor: OK
[   51.882439] Testing event ocfs2_block_group_alloc_contig: OK
[   51.902486] Testing event ocfs2_block_group_alloc_discontig: OK
[   51.922469] Testing event ocfs2_block_group_alloc: OK
[   51.942452] Testing event ocfs2_reserve_suballoc_bits_nospc: OK
[   51.971532] Testing event ocfs2_reserve_suballoc_bits_no_new_group: OK
[   51.994622] Testing event ocfs2_reserve_new_inode_new_group: OK
[   52.020634] Testing event ocfs2_block_group_set_bits: OK
[   52.045903] Testing event ocfs2_relink_block_group: OK
[   52.067513] Testing event ocfs2_cluster_group_search_wrong_max_bits: OK
[   52.095159] Testing event ocfs2_cluster_group_search_max_block: OK
[   52.122484] Testing event ocfs2_block_group_search_max_block: OK
[   52.143065] Testing event ocfs2_search_chain_begin: OK
[   52.175391] Testing event ocfs2_search_chain_succ: OK
[   52.203429] Testing event ocfs2_search_chain_end: OK
[   52.222477] Testing event ocfs2_claim_suballoc_bits: OK
[   52.243003] Testing event ocfs2_claim_new_inode_at_loc: OK
[   52.271600] Testing event ocfs2_block_group_clear_bits: OK
[   52.296527] Testing event ocfs2_free_suballoc_bits: OK
[   52.332585] Testing event ocfs2_free_clusters: OK
[   52.354712] Testing event ocfs2_get_suballoc_slot_bit: OK
[   52.374510] Testing event ocfs2_test_suballoc_bit: OK
[   52.394342] Testing event ocfs2_test_inode_bit: OK
[   52.413824] Testing event ocfs2_validate_refcount_block: OK
[   52.435397] Testing event ocfs2_purge_refcount_trees: OK
[   52.454418] Testing event ocfs2_create_refcount_tree: OK
[   52.473864] Testing event ocfs2_create_refcount_tree_blkno: OK
[   52.494681] Testing event ocfs2_change_refcount_rec: OK
[   52.514925] Testing event ocfs2_expand_inline_ref_root: OK
[   52.538853] Testing event ocfs2_divide_leaf_refcount_block: OK
[   52.558343] Testing event ocfs2_new_leaf_refcount_block: OK
[   52.578310] Testing event ocfs2_insert_refcount_rec: OK
[   52.598630] Testing event ocfs2_split_refcount_rec: OK
[   52.618744] Testing event ocfs2_split_refcount_rec_insert: OK
[   52.642349] Testing event ocfs2_increase_refcount_begin: OK
[   52.663576] Testing event ocfs2_increase_refcount_change: OK
[   52.682406] Testing event ocfs2_increase_refcount_insert: OK
[   52.702451] Testing event ocfs2_increase_refcount_split: OK
[   52.722331] Testing event ocfs2_remove_refcount_extent: OK
[   52.742863] Testing event ocfs2_restore_refcount_block: OK
[   52.762717] Testing event ocfs2_decrease_refcount_rec: OK
[   52.781696] Testing event ocfs2_decrease_refcount: OK
[   52.797679] Testing event ocfs2_mark_extent_refcounted: OK
[   52.821034] Testing event ocfs2_calc_refcount_meta_credits: OK
[   52.842320] Testing event ocfs2_calc_refcount_meta_credits_iterate: OK
[   52.871030] Testing event ocfs2_add_refcount_flag: OK
[   52.894331] Testing event ocfs2_prepare_refcount_change_for_del: OK
[   52.914475] Testing event ocfs2_lock_refcount_allocators: OK
[   52.934708] Testing event ocfs2_duplicate_clusters_by_page: OK
[   52.954567] Testing event ocfs2_duplicate_clusters_by_jbd: OK
[   52.974450] Testing event ocfs2_clear_ext_refcount: OK
[   52.994520] Testing event ocfs2_replace_clusters: OK
[   53.016625] Testing event ocfs2_make_clusters_writable: OK
[   53.042791] Testing event ocfs2_refcount_cow_hunk: OK
[   53.062447] Testing event ocfs2_symlink_get_block: OK
[   53.083917] Testing event ocfs2_get_block: OK
[   53.102321] Testing event ocfs2_get_block_end: OK
[   53.122208] Testing event ocfs2_readpage: OK
[   53.142423] Testing event ocfs2_writepage: OK
[   53.162571] Testing event ocfs2_bmap: OK
[   53.183017] Testing event ocfs2_try_to_write_inline_data: OK
[   53.205387] Testing event ocfs2_write_begin_nolock: OK
[   53.226494] Testing event ocfs2_write_end_inline: OK
[   53.246810] Testing event ocfs2_fault: OK
[   53.278037] Testing event ocfs2_file_open: OK
[   53.297724] Testing event ocfs2_file_release: OK
[   53.318722] Testing event ocfs2_sync_file: OK
[   53.338481] Testing event ocfs2_file_aio_write: OK
[   53.359177] Testing event ocfs2_file_splice_write: OK
[   53.387542] Testing event ocfs2_file_splice_read: OK
[   53.408405] Testing event ocfs2_file_aio_read: OK
[   53.433065] Testing event ocfs2_truncate_file: OK
[   53.464531] Testing event ocfs2_truncate_file_error: OK
[   53.486467] Testing event ocfs2_extend_allocation: OK
[   53.507434] Testing event ocfs2_extend_allocation_end: OK
[   53.527656] Testing event ocfs2_write_zero_page: OK
[   53.559770] Testing event ocfs2_zero_extend_range: OK
[   53.586595] Testing event ocfs2_zero_extend: OK
[   53.606339] Testing event ocfs2_setattr: OK
[   53.631012] Testing event ocfs2_write_remove_suid: OK
[   53.654531] Testing event ocfs2_zero_partial_clusters: OK
[   53.685014] Testing event ocfs2_zero_partial_clusters_range1: OK
[   53.707474] Testing event ocfs2_zero_partial_clusters_range2: OK
[   53.730311] Testing event ocfs2_remove_inode_range: OK
[   53.750305] Testing event ocfs2_prepare_inode_for_write: OK
[   53.782750] Testing event generic_file_aio_read_ret: OK
[   53.806303] Testing event ocfs2_iget_begin: OK
[   53.831688] Testing event ocfs2_iget5_locked: OK
[   53.850401] Testing event ocfs2_iget_end: OK
[   53.870313] Testing event ocfs2_find_actor: OK
[   53.899661] Testing event ocfs2_populate_inode: OK
[   53.918912] Testing event ocfs2_read_locked_inode: OK
[   53.938387] Testing event ocfs2_check_orphan_recovery_state: OK
[   53.959596] Testing event ocfs2_validate_inode_block: OK
[   53.989084] Testing event ocfs2_inode_is_valid_to_delete: OK
[   54.011237] Testing event ocfs2_query_inode_wipe_begin: OK
[   54.030705] Testing event ocfs2_query_inode_wipe_succ: OK
[   54.050436] Testing event ocfs2_query_inode_wipe_end: OK
[   54.070564] Testing event ocfs2_cleanup_delete_inode: OK
[   54.090411] Testing event ocfs2_delete_inode: OK
[   54.110418] Testing event ocfs2_clear_inode: OK
[   54.130467] Testing event ocfs2_drop_inode: OK
[   54.150391] Testing event ocfs2_inode_revalidate: OK
[   54.171209] Testing event ocfs2_mark_inode_dirty: OK
[   54.190753] Testing event ocfs2_read_virt_blocks: OK
[   54.212255] Testing event ocfs2_refresh_slot_info: OK
[   54.235144] Testing event ocfs2_map_slot_buffers: OK
[   54.254979] Testing event ocfs2_map_slot_buffers_block: OK
[   54.278065] Testing event ocfs2_find_slot: OK
[   54.299006] Testing event ocfs2_do_node_down: OK
[   54.324833] Testing event ocfs2_remount: OK
[   54.351922] Testing event ocfs2_fill_super: OK
[   54.370920] Testing event ocfs2_parse_options: OK
[   54.390576] Testing event ocfs2_put_super: OK
[   54.410535] Testing event ocfs2_statfs: OK
[   54.437976] Testing event ocfs2_dismount_volume: OK
[   54.458351] Testing event ocfs2_initialize_super: OK
[   54.482261] Testing event ocfs2_validate_xattr_block: OK
[   54.503194] Testing event ocfs2_xattr_extend_allocation: OK
[   54.534804] Testing event ocfs2_init_xattr_set_ctxt: OK
[   54.554921] Testing event ocfs2_xattr_bucket_find: OK
[   54.590775] Testing event ocfs2_xattr_index_block_find: OK
[   54.613393] Testing event ocfs2_xattr_index_block_find_rec: OK
[   54.636802] Testing event ocfs2_iterate_xattr_buckets: OK
[   54.662815] Testing event ocfs2_iterate_xattr_bucket: OK
[   54.687614] Testing event ocfs2_cp_xattr_block_to_bucket_begin: OK
[   54.708653] Testing event ocfs2_cp_xattr_block_to_bucket_end: OK
[   54.730657] Testing event ocfs2_xattr_create_index_block_begin: OK
[   54.750653] Testing event ocfs2_xattr_create_index_block: OK
[   54.776271] Testing event ocfs2_defrag_xattr_bucket: OK
[   54.795262] Testing event ocfs2_mv_xattr_bucket_cross_cluster: OK
[   54.815864] Testing event ocfs2_divide_xattr_bucket_begin: OK
[   54.843194] Testing event ocfs2_divide_xattr_bucket_move: OK
[   54.863808] Testing event ocfs2_cp_xattr_bucket: OK
[   54.890205] Testing event ocfs2_mv_xattr_buckets: OK
[   54.910977] Testing event ocfs2_adjust_xattr_cross_cluster: OK
[   54.930645] Testing event ocfs2_add_new_xattr_cluster_begin: OK
[   54.953912] Testing event ocfs2_add_new_xattr_cluster: OK
[   54.974766] Testing event ocfs2_add_new_xattr_cluster_insert: OK
[   54.995105] Testing event ocfs2_extend_xattr_bucket: OK
[   55.015238] Testing event ocfs2_add_new_xattr_bucket: OK
[   55.035693] Testing event ocfs2_xattr_bucket_value_truncate: OK
[   55.060424] Testing event ocfs2_rm_xattr_cluster: OK
[   55.082411] Testing event ocfs2_reflink_xattr_header: OK
[   55.102812] Testing event ocfs2_create_empty_xattr_block: OK
[   55.123339] Testing event ocfs2_xattr_set_entry_bucket: OK
[   55.143826] Testing event ocfs2_xattr_set_entry_index_block: OK
[   55.166482] Testing event ocfs2_xattr_bucket_value_refcount: OK
[   55.188752] Testing event ocfs2_reflink_xattr_buckets: OK
[   55.210336] Testing event ocfs2_reflink_xattr_rec: OK
[   55.230530] Testing event ocfs2_resv_insert: OK
[   55.250443] Testing event ocfs2_resmap_find_free_bits_begin: OK
[   55.270975] Testing event ocfs2_resmap_find_free_bits_end: OK
[   55.295720] Testing event ocfs2_resv_find_window_begin: OK
[   55.328547] Testing event ocfs2_resv_find_window_prev: OK
[   55.351421] Testing event ocfs2_resv_find_window_next: OK
[   55.371779] Testing event ocfs2_cannibalize_resv_begin: OK
[   55.395558] Testing event ocfs2_cannibalize_resv_end: OK
[   55.419819] Testing event ocfs2_resmap_resv_bits: OK
[   55.442953] Testing event ocfs2_resmap_claimed_bits_begin: OK
[   55.463081] Testing event ocfs2_resmap_claimed_bits_end: OK
[   55.483012] Testing event ocfs2_recover_local_quota_file: OK
[   55.502593] Testing event ocfs2_finish_quota_recovery: OK
[   55.522769] Testing event olq_set_dquot: OK
[   55.542452] Testing event ocfs2_validate_quota_block: OK
[   55.566290] Testing event ocfs2_sync_dquot: OK
[   55.586488] Testing event ocfs2_sync_dquot_helper: OK
[   55.607014] Testing event ocfs2_write_dquot: OK
[   55.631067] Testing event ocfs2_release_dquot: OK
[   55.660637] Testing event ocfs2_acquire_dquot: OK
[   55.682472] Testing event ocfs2_mark_dquot_dirty: OK
[   55.710086] Testing event ocfs2_search_dirblock: OK
[   55.729707] Testing event ocfs2_validate_dir_block: OK
[   55.746625] Testing event ocfs2_find_entry_el: OK
[   55.765955] Testing event ocfs2_dx_dir_search: OK
[   55.786731] Testing event ocfs2_dx_dir_search_leaf_info: OK
[   55.806789] Testing event ocfs2_delete_entry_dx: OK
[   55.826807] Testing event ocfs2_readdir: OK
[   55.846471] Testing event ocfs2_find_files_on_disk: OK
[   55.866539] Testing event ocfs2_check_dir_for_entry: OK
[   55.891705] Testing event ocfs2_dx_dir_attach_index: OK
[   55.921203] Testing event ocfs2_dx_dir_format_cluster: OK
[   55.947096] Testing event ocfs2_dx_dir_index_root_block: OK
[   55.971462] Testing event ocfs2_extend_dir: OK
[   55.991201] Testing event ocfs2_dx_dir_rebalance: OK
[   56.020474] Testing event ocfs2_dx_dir_rebalance_split: OK
[   56.044354] Testing event ocfs2_prepare_dir_for_insert: OK
[   56.066709] Testing event ocfs2_lookup: OK
[   56.091088] Testing event ocfs2_mkdir: OK
[   56.110860] Testing event ocfs2_create: OK
[   56.130603] Testing event ocfs2_unlink: OK
[   56.150520] Testing event ocfs2_symlink_create: OK
[   56.170280] Testing event ocfs2_mv_orphaned_inode_to_new: OK
[   56.211477] Testing event ocfs2_lookup_ret: OK
[   56.242837] Testing event ocfs2_mknod: OK
[   56.269841] Testing event ocfs2_link: OK
[   56.295671] Testing event ocfs2_unlink_noent: OK
[   56.316478] Testing event ocfs2_double_lock: OK
[   56.347508] Testing event ocfs2_double_lock_end: OK
[   56.371406] Testing event ocfs2_rename: OK
[   56.398864] Testing event ocfs2_rename_target_exists: OK
[   56.419327] Testing event ocfs2_rename_disagree: OK
[   56.439439] Testing event ocfs2_rename_over_existing: OK
[   56.463338] Testing event ocfs2_create_symlink_data: OK
[   56.483888] Testing event ocfs2_symlink_begin: OK
[   56.502235] Testing event ocfs2_blkno_stringify: OK
[   56.522566] Testing event ocfs2_orphan_add_begin: OK
[   56.549157] Testing event ocfs2_orphan_add_end: OK
[   56.572665] Testing event ocfs2_orphan_del: OK
[   56.590350] Testing event ocfs2_dentry_revalidate: OK
[   56.610287] Testing event ocfs2_dentry_revalidate_negative: OK
[   56.631119] Testing event ocfs2_dentry_revalidate_delete: OK
[   56.650928] Testing event ocfs2_dentry_revalidate_orphaned: OK
[   56.670958] Testing event ocfs2_dentry_revalidate_nofsdata: OK
[   56.690877] Testing event ocfs2_dentry_revalidate_ret: OK
[   56.710961] Testing event ocfs2_find_local_alias: OK
[   56.731271] Testing event ocfs2_dentry_attach_lock: OK
[   56.763989] Testing event ocfs2_dentry_attach_lock_found: OK
[   56.786849] Testing event ocfs2_get_dentry_begin: OK
[   56.806210] Testing event ocfs2_get_dentry_test_bit: OK
[   56.826211] Testing event ocfs2_get_dentry_stale: OK
[   56.846526] Testing event ocfs2_get_dentry_generation: OK
[   56.866992] Testing event ocfs2_get_dentry_end: OK
[   56.886939] Testing event ocfs2_get_parent: OK
[   56.906838] Testing event ocfs2_get_parent_end: OK
[   56.927051] Testing event ocfs2_encode_fh_begin: OK
[   56.954697] Testing event ocfs2_encode_fh_self: OK
[   56.974132] Testing event ocfs2_encode_fh_parent: OK
[   56.995172] Testing event ocfs2_encode_fh_type: OK
[   57.014465] Testing event ocfs2_commit_cache_begin: OK
[   57.034561] Testing event ocfs2_commit_cache_end: OK
[   57.056652] Testing event ocfs2_extend_trans: OK
[   57.080665] Testing event ocfs2_extend_trans_restart: OK
[   57.102305] Testing event ocfs2_journal_access: OK
[   57.127705] Testing event ocfs2_journal_dirty: OK
[   57.150399] Testing event ocfs2_journal_init: OK
[   57.172764] Testing event ocfs2_journal_init_maxlen: OK
[   57.198448] Testing event ocfs2_journal_shutdown: OK
[   57.218470] Testing event ocfs2_journal_shutdown_wait: OK
[   57.238398] Testing event ocfs2_complete_recovery: OK
[   57.258474] Testing event ocfs2_complete_recovery_end: OK
[   57.278329] Testing event ocfs2_complete_recovery_slot: OK
[   57.298348] Testing event ocfs2_recovery_thread_node: OK
[   57.318450] Testing event ocfs2_recovery_thread_end: OK
[   57.338425] Testing event ocfs2_recovery_thread: OK
[   57.358337] Testing event ocfs2_replay_journal_recovered: OK
[   57.377926] Testing event ocfs2_replay_journal_lock_err: OK
[   57.398773] Testing event ocfs2_replay_journal_skip: OK
[   57.447985] Testing event ocfs2_recover_node: OK
[   57.470685] Testing event ocfs2_recover_node_skip: OK
[   57.490454] Testing event ocfs2_mark_dead_nodes: OK
[   57.510402] Testing event ocfs2_queue_orphan_scan_begin: OK
[   57.538881] Testing event ocfs2_queue_orphan_scan_end: OK
[   57.558382] Testing event ocfs2_orphan_filldir: OK
[   57.585828] Testing event ocfs2_recover_orphans: OK
[   57.610533] Testing event ocfs2_recover_orphans_iput: OK
[   57.634486] Testing event ocfs2_wait_on_mount: OK
[   57.655102] Testing event ocfs2_read_blocks_sync: OK
[   57.685212] Testing event ocfs2_read_blocks_sync_jbd: OK
[   57.706478] Testing event ocfs2_read_blocks_from_disk: OK
[   57.727210] Testing event ocfs2_read_blocks_bh: OK
[   57.756954] Testing event ocfs2_read_blocks_end: OK
[   57.781839] Testing event ocfs2_write_block: OK
[   57.807891] Testing event ocfs2_read_blocks_begin: OK
[   57.831573] Testing event ocfs2_purge_copied_metadata_tree: OK
[   57.850524] Testing event ocfs2_metadata_cache_purge: OK
[   57.870506] Testing event ocfs2_buffer_cached_begin: OK
[   57.895667] Testing event ocfs2_buffer_cached_end: OK
[   57.923922] Testing event ocfs2_append_cache_array: OK
[   57.943760] Testing event ocfs2_insert_cache_tree: OK
[   57.962780] Testing event ocfs2_expand_cache: OK
[   57.982476] Testing event ocfs2_set_buffer_uptodate: OK
[   58.002569] Testing event ocfs2_set_buffer_uptodate_begin: OK
[   58.023709] Testing event ocfs2_remove_metadata_array: OK
[   58.042532] Testing event ocfs2_remove_metadata_tree: OK
[   58.065810] Testing event ocfs2_remove_block_from_cache: OK
[   58.086578] Testing event xfs_attr_list_sf: OK
[   58.106683] Testing event xfs_attr_list_sf_all: OK
[   58.126886] Testing event xfs_attr_list_leaf: OK
[   58.146571] Testing event xfs_attr_list_leaf_end: OK
[   58.166411] Testing event xfs_attr_list_full: OK
[   58.186491] Testing event xfs_attr_list_add: OK
[   58.206516] Testing event xfs_attr_list_wrong_blk: OK
[   58.226431] Testing event xfs_attr_list_notfound: OK
[   58.246444] Testing event xfs_perag_get: OK
[   58.266870] Testing event xfs_perag_get_tag: OK
[   58.286592] Testing event xfs_perag_put: OK
[   58.307280] Testing event xfs_perag_set_reclaim: OK
[   58.326267] Testing event xfs_perag_clear_reclaim: OK
[   58.347048] Testing event xfs_attr_list_node_descend: OK
[   58.366422] Testing event xfs_iext_insert: OK
[   58.386449] Testing event xfs_iext_remove: OK
[   58.406696] Testing event xfs_bmap_pre_update: OK
[   58.426474] Testing event xfs_bmap_post_update: OK
[   58.447045] Testing event xfs_extlist: OK
[   58.466400] Testing event xfs_buf_init: OK
[   58.486061] Testing event xfs_buf_free: OK
[   58.506794] Testing event xfs_buf_hold: OK
[   58.535427] Testing event xfs_buf_rele: OK
[   58.555728] Testing event xfs_buf_iodone: OK
[   58.575896] Testing event xfs_buf_iorequest: OK
[   58.598692] Testing event xfs_buf_bawrite: OK
[   58.618684] Testing event xfs_buf_lock: OK
[   58.638694] Testing event xfs_buf_lock_done: OK
[   58.660000] Testing event xfs_buf_trylock: OK
[   58.678642] Testing event xfs_buf_unlock: OK
[   58.698780] Testing event xfs_buf_iowait: OK
[   58.718662] Testing event xfs_buf_iowait_done: OK
[   58.738775] Testing event xfs_buf_delwri_queue: OK
[   58.758721] Testing event xfs_buf_delwri_queued: OK
[   58.779142] Testing event xfs_buf_delwri_split: OK
[   58.798444] Testing event xfs_buf_get_uncached: OK
[   58.818462] Testing event xfs_bdstrat_shut: OK
[   58.843142] Testing event xfs_buf_item_relse: OK
[   58.863274] Testing event xfs_buf_item_iodone: OK
[   58.882740] Testing event xfs_buf_item_iodone_async: OK
[   58.902509] Testing event xfs_buf_error_relse: OK
[   58.922519] Testing event xfs_trans_read_buf_io: OK
[   58.945601] Testing event xfs_trans_read_buf_shut: OK
[   58.966837] Testing event xfs_btree_corrupt: OK
[   58.987004] Testing event xfs_da_btree_corrupt: OK
[   59.006619] Testing event xfs_reset_dqcounts: OK
[   59.026811] Testing event xfs_inode_item_push: OK
[   59.046909] Testing event xfs_buf_find: OK
[   59.066630] Testing event xfs_buf_get: OK
[   59.087520] Testing event xfs_buf_read: OK
[   59.113331] Testing event xfs_buf_ioerror: OK
[   59.134424] Testing event xfs_buf_item_size: OK
[   59.154381] Testing event xfs_buf_item_size_stale: OK
[   59.176146] Testing event xfs_buf_item_format: OK
[   59.194465] Testing event xfs_buf_item_format_stale: OK
[   59.213676] Testing event xfs_buf_item_pin: OK
[   59.230443] Testing event xfs_buf_item_unpin: OK
[   59.250347] Testing event xfs_buf_item_unpin_stale: OK
[   59.270321] Testing event xfs_buf_item_unlock: OK
[   59.290297] Testing event xfs_buf_item_unlock_stale: OK
[   59.310181] Testing event xfs_buf_item_committed: OK
[   59.330304] Testing event xfs_buf_item_push: OK
[   59.350503] Testing event xfs_trans_get_buf: OK
[   59.370445] Testing event xfs_trans_get_buf_recur: OK
[   59.391704] Testing event xfs_trans_getsb: OK
[   59.410798] Testing event xfs_trans_getsb_recur: OK
[   59.430228] Testing event xfs_trans_read_buf: OK
[   59.450586] Testing event xfs_trans_read_buf_recur: OK
[   59.470518] Testing event xfs_trans_log_buf: OK
[   59.490608] Testing event xfs_trans_brelse: OK
[   59.510426] Testing event xfs_trans_bjoin: OK
[   59.534956] Testing event xfs_trans_bhold: OK
[   59.554422] Testing event xfs_trans_bhold_release: OK
[   59.578341] Testing event xfs_trans_binval: OK
[   59.598821] Testing event xfs_ilock: OK
[   59.622222] Testing event xfs_ilock_nowait: OK
[   59.642500] Testing event xfs_ilock_demote: OK
[   59.662443] Testing event xfs_iunlock: OK
[   59.682451] Testing event xfs_iget_skip: OK
[   59.702385] Testing event xfs_iget_reclaim: OK
[   59.722460] Testing event xfs_iget_reclaim_fail: OK
[   59.742466] Testing event xfs_iget_hit: OK
[   59.762603] Testing event xfs_iget_miss: OK
[   59.782685] Testing event xfs_getattr: OK
[   59.803819] Testing event xfs_setattr: OK
[   59.823077] Testing event xfs_readlink: OK
[   59.847090] Testing event xfs_alloc_file_space: OK
[   59.870834] Testing event xfs_free_file_space: OK
[   59.894621] Testing event xfs_readdir: OK
[   59.914615] Testing event xfs_get_acl: OK
[   59.934320] Testing event xfs_vm_bmap: OK
[   59.954684] Testing event xfs_file_ioctl: OK
[   59.974552] Testing event xfs_file_compat_ioctl: OK
[   59.994539] Testing event xfs_ioctl_setattr: OK
[   60.015044] Testing event xfs_dir_fsync: OK
[   60.035305] Testing event xfs_file_fsync: OK
[   60.063683] Testing event xfs_destroy_inode: OK
[   60.082339] Testing event xfs_evict_inode: OK
[   60.102526] Testing event xfs_update_time: OK
[   60.126823] Testing event xfs_dquot_dqalloc: OK
[   60.146860] Testing event xfs_dquot_dqdetach: OK
[   60.176673] Testing event xfs_ihold: OK
[   60.199764] Testing event xfs_irele: OK
[   60.222960] Testing event xfs_inode_pin: OK
[   60.250071] Testing event xfs_inode_unpin: OK
[   60.270430] Testing event xfs_inode_unpin_nowait: OK
[   60.290475] Testing event xfs_remove: OK
[   60.311326] Testing event xfs_link: OK
[   60.330487] Testing event xfs_lookup: OK
[   60.350422] Testing event xfs_create: OK
[   60.370470] Testing event xfs_symlink: OK
[   60.390427] Testing event xfs_rename: OK
[   60.410319] Testing event xfs_dqadjust: OK
[   60.430351] Testing event xfs_dqreclaim_want: OK
[   60.450434] Testing event xfs_dqreclaim_dirty: OK
[   60.470313] Testing event xfs_dqreclaim_busy: OK
[   60.489953] Testing event xfs_dqreclaim_done: OK
[   60.510349] Testing event xfs_dqattach_found: OK
[   60.529968] Testing event xfs_dqattach_get: OK
[   60.549681] Testing event xfs_dqalloc: OK
[   60.570963] Testing event xfs_dqtobp_read: OK
[   60.594616] Testing event xfs_dqread: OK
[   60.614754] Testing event xfs_dqread_fail: OK
[   60.635008] Testing event xfs_dqget_hit: OK
[   60.654395] Testing event xfs_dqget_miss: OK
[   60.682178] Testing event xfs_dqget_freeing: OK
[   60.701509] Testing event xfs_dqget_dup: OK
[   60.718466] Testing event xfs_dqput: OK
[   60.738836] Testing event xfs_dqput_wait: OK
[   60.758317] Testing event xfs_dqput_free: OK
[   60.778933] Testing event xfs_dqrele: OK
[   60.800869] Testing event xfs_dqflush: OK
[   60.822498] Testing event xfs_dqflush_force: OK
[   60.846493] Testing event xfs_dqflush_done: OK
[   60.867610] Testing event xfs_log_done_nonperm: OK
[   60.886314] Testing event xfs_log_done_perm: OK
[   60.906973] Testing event xfs_log_umount_write: OK
[   60.926733] Testing event xfs_log_grant_sleep: OK
[   60.947862] Testing event xfs_log_grant_wake: OK
[   60.970689] Testing event xfs_log_grant_wake_up: OK
[   60.990696] Testing event xfs_log_reserve: OK
[   61.011400] Testing event xfs_log_reserve_exit: OK
[   61.030399] Testing event xfs_log_regrant: OK
[   61.050288] Testing event xfs_log_regrant_exit: OK
[   61.070590] Testing event xfs_log_regrant_reserve_enter: OK
[   61.090570] Testing event xfs_log_regrant_reserve_exit: OK
[   61.110462] Testing event xfs_log_regrant_reserve_sub: OK
[   61.130194] Testing event xfs_log_ungrant_enter: OK
[   61.150820] Testing event xfs_log_ungrant_exit: OK
[   61.170688] Testing event xfs_log_ungrant_sub: OK
[   61.190039] Testing event xfs_log_force: OK
[   61.209958] Testing event xfs_ail_push: OK
[   61.231328] Testing event xfs_ail_pinned: OK
[   61.251233] Testing event xfs_ail_locked: OK
[   61.274258] Testing event xfs_ail_flushing: OK
[   61.294820] Testing event xfs_file_read: OK
[   61.316595] Testing event xfs_file_buffered_write: OK
[   61.338293] Testing event xfs_file_direct_write: OK
[   61.358808] Testing event xfs_file_splice_read: OK
[   61.379008] Testing event xfs_file_splice_write: OK
[   61.398691] Testing event xfs_writepage: OK
[   61.418936] Testing event xfs_releasepage: OK
[   61.442109] Testing event xfs_invalidatepage: OK
[   61.462755] Testing event xfs_map_blocks_found: OK
[   61.483311] Testing event xfs_map_blocks_alloc: OK
[   61.516870] Testing event xfs_get_blocks_found: OK
[   61.546288] Testing event xfs_get_blocks_alloc: OK
[   61.566600] Testing event xfs_delalloc_enospc: OK
[   61.586906] Testing event xfs_unwritten_convert: OK
[   61.606252] Testing event xfs_get_blocks_notfound: OK
[   61.626312] Testing event xfs_setfilesize: OK
[   61.651863] Testing event xfs_itruncate_extents_start: OK
[   61.682242] Testing event xfs_itruncate_extents_end: OK
[   61.702310] Testing event xfs_pagecache_inval: OK
[   61.722267] Testing event xfs_bunmap: OK
[   61.742399] Testing event xfs_extent_busy: OK
[   61.761864] Testing event xfs_extent_busy_enomem: OK
[   61.783390] Testing event xfs_extent_busy_force: OK
[   61.802790] Testing event xfs_extent_busy_reuse: OK
[   61.821781] Testing event xfs_extent_busy_clear: OK
[   61.842130] Testing event xfs_extent_busy_trim: OK
[   61.863300] Testing event xfs_trans_commit_lsn: OK
[   61.882592] Testing event xfs_agf: OK
[   61.903222] Testing event xfs_free_extent: OK
[   61.925300] Testing event xfs_alloc_exact_done: OK
[   61.946448] Testing event xfs_alloc_exact_notfound: OK
[   61.966386] Testing event xfs_alloc_exact_error: OK
[   61.986351] Testing event xfs_alloc_near_nominleft: OK
[   62.006684] Testing event xfs_alloc_near_first: OK
[   62.027441] Testing event xfs_alloc_near_greater: OK
[   62.046547] Testing event xfs_alloc_near_lesser: OK
[   62.071059] Testing event xfs_alloc_near_error: OK
[   62.094801] Testing event xfs_alloc_near_noentry: OK
[   62.114601] Testing event xfs_alloc_near_busy: OK
[   62.134645] Testing event xfs_alloc_size_neither: OK
[   62.154730] Testing event xfs_alloc_size_noentry: OK
[   62.174406] Testing event xfs_alloc_size_nominleft: OK
[   62.194963] Testing event xfs_alloc_size_done: OK
[   62.214789] Testing event xfs_alloc_size_error: OK
[   62.234334] Testing event xfs_alloc_size_busy: OK
[   62.258471] Testing event xfs_alloc_small_freelist: OK
[   62.277861] Testing event xfs_alloc_small_notenough: OK
[   62.298554] Testing event xfs_alloc_small_done: OK
[   62.318550] Testing event xfs_alloc_small_error: OK
[   62.338697] Testing event xfs_alloc_vextent_badargs: OK
[   62.358570] Testing event xfs_alloc_vextent_nofix: OK
[   62.378823] Testing event xfs_alloc_vextent_noagbp: OK
[   62.398880] Testing event xfs_alloc_vextent_loopfailed: OK
[   62.419351] Testing event xfs_alloc_vextent_allfailed: OK
[   62.437860] Testing event xfs_dir2_sf_addname: OK
[   62.458632] Testing event xfs_dir2_sf_create: OK
[   62.478415] Testing event xfs_dir2_sf_lookup: OK
[   62.497945] Testing event xfs_dir2_sf_replace: OK
[   62.517921] Testing event xfs_dir2_sf_removename: OK
[   62.538410] Testing event xfs_dir2_sf_toino4: OK
[   62.558268] Testing event xfs_dir2_sf_toino8: OK
[   62.578491] Testing event xfs_dir2_sf_to_block: OK
[   62.598223] Testing event xfs_dir2_block_addname: OK
[   62.618840] Testing event xfs_dir2_block_lookup: OK
[   62.637852] Testing event xfs_dir2_block_replace: OK
[   62.658618] Testing event xfs_dir2_block_removename: OK
[   62.678420] Testing event xfs_dir2_block_to_sf: OK
[   62.698968] Testing event xfs_dir2_block_to_leaf: OK
[   62.722891] Testing event xfs_dir2_leaf_addname: OK
[   62.743643] Testing event xfs_dir2_leaf_lookup: OK
[   62.763500] Testing event xfs_dir2_leaf_replace: OK
[   62.786467] Testing event xfs_dir2_leaf_removename: OK
[   62.806980] Testing event xfs_dir2_leaf_to_block: OK
[   62.826496] Testing event xfs_dir2_leaf_to_node: OK
[   62.846753] Testing event xfs_dir2_node_addname: OK
[   62.865963] Testing event xfs_dir2_node_lookup: OK
[   62.887445] Testing event xfs_dir2_node_replace: OK
[   62.913113] Testing event xfs_dir2_node_removename: OK
[   62.937683] Testing event xfs_dir2_node_to_leaf: OK
[   62.959818] Testing event xfs_attr_sf_add: OK
[   62.998461] Testing event xfs_attr_sf_addname: OK
[   63.019018] Testing event xfs_attr_sf_create: OK
[   63.039693] Testing event xfs_attr_sf_lookup: OK
[   63.062819] Testing event xfs_attr_sf_remove: OK
[   63.088164] Testing event xfs_attr_sf_removename: OK
[   63.115559] Testing event xfs_attr_sf_to_leaf: OK
[   63.134205] Testing event xfs_attr_leaf_add: OK
[   63.158416] Testing event xfs_attr_leaf_add_old: OK
[   63.186936] Testing event xfs_attr_leaf_add_new: OK
[   63.211204] Testing event xfs_attr_leaf_addname: OK
[   63.240242] Testing event xfs_attr_leaf_create: OK
[   63.272521] Testing event xfs_attr_leaf_lookup: OK
[   63.294545] Testing event xfs_attr_leaf_replace: OK
[   63.331782] Testing event xfs_attr_leaf_removename: OK
[   63.361921] Testing event xfs_attr_leaf_split: OK
[   63.382475] Testing event xfs_attr_leaf_split_before: OK
[   63.406344] Testing event xfs_attr_leaf_split_after: OK
[   63.426733] Testing event xfs_attr_leaf_clearflag: OK
[   63.446977] Testing event xfs_attr_leaf_setflag: OK
[   63.468551] Testing event xfs_attr_leaf_flipflags: OK
[   63.490686] Testing event xfs_attr_leaf_to_sf: OK
[   63.510504] Testing event xfs_attr_leaf_to_node: OK
[   63.530599] Testing event xfs_attr_leaf_rebalance: OK
[   63.550669] Testing event xfs_attr_leaf_unbalance: OK
[   63.569696] Testing event xfs_attr_node_addname: OK
[   63.587505] Testing event xfs_attr_node_lookup: OK
[   63.605889] Testing event xfs_attr_node_replace: OK
[   63.627068] Testing event xfs_attr_node_removename: OK
[   63.647669] Testing event xfs_da_split: OK
[   63.669715] Testing event xfs_da_join: OK
[   63.690486] Testing event xfs_da_link_before: OK
[   63.711534] Testing event xfs_da_link_after: OK
[   63.730683] Testing event xfs_da_unlink_back: OK
[   63.750440] Testing event xfs_da_unlink_forward: OK
[   63.770267] Testing event xfs_da_root_split: OK
[   63.790809] Testing event xfs_da_root_join: OK
[   63.811621] Testing event xfs_da_node_add: OK
[   63.830874] Testing event xfs_da_node_create: OK
[   63.854445] Testing event xfs_da_node_split: OK
[   63.874591] Testing event xfs_da_node_remove: OK
[   63.894417] Testing event xfs_da_node_rebalance: OK
[   63.914412] Testing event xfs_da_node_unbalance: OK
[   63.934536] Testing event xfs_da_swap_lastblock: OK
[   63.954671] Testing event xfs_da_grow_inode: OK
[   63.978459] Testing event xfs_da_shrink_inode: OK
[   63.999161] Testing event xfs_dir2_leafn_add: OK
[   64.018580] Testing event xfs_dir2_leafn_remove: OK
[   64.038587] Testing event xfs_dir2_grow_inode: OK
[   64.058652] Testing event xfs_dir2_shrink_inode: OK
[   64.078787] Testing event xfs_dir2_leafn_moveents: OK
[   64.098438] Testing event xfs_swap_extent_before: OK
[   64.118532] Testing event xfs_swap_extent_after: OK
[   64.138032] Testing event xfs_log_recover_item_add: OK
[   64.157869] Testing event xfs_log_recover_item_add_cont: OK
[   64.177940] Testing event xfs_log_recover_item_reorder_head: OK
[   64.197951] Testing event xfs_log_recover_item_reorder_tail: OK
[   64.218334] Testing event xfs_log_recover_item_recover: OK
[   64.239543] Testing event xfs_log_recover_buf_not_cancel: OK
[   64.259203] Testing event xfs_log_recover_buf_cancel: OK
[   64.291213] Testing event xfs_log_recover_buf_cancel_add: OK
[   64.319191] Testing event xfs_log_recover_buf_cancel_ref_inc: OK
[   64.347195] Testing event xfs_log_recover_buf_recover: OK
[   64.375497] Testing event xfs_log_recover_buf_inode_buf: OK
[   64.403122] Testing event xfs_log_recover_buf_reg_buf: OK
[   64.431480] Testing event xfs_log_recover_buf_dquot_buf: OK
[   64.450743] Testing event xfs_log_recover_inode_recover: OK
[   64.469632] Testing event xfs_log_recover_inode_cancel: OK
[   64.485974] Testing event xfs_log_recover_inode_skip: OK
[   64.506785] Testing event xfs_discard_extent: OK
[   64.526435] Testing event xfs_discard_toosmall: OK
[   64.546425] Testing event xfs_discard_exclude: OK
[   64.566681] Testing event xfs_discard_busy: OK
[   64.587214] Testing event jbd2_checkpoint: OK
[   64.610698] Testing event jbd2_start_commit: OK
[   64.631174] Testing event jbd2_commit_locking: OK
[   64.656144] Testing event jbd2_commit_flushing: OK
[   64.675654] Testing event jbd2_commit_logging: OK
[   64.696289] Testing event jbd2_drop_transaction: OK
[   64.718539] Testing event jbd2_end_commit: OK
[   64.739043] Testing event jbd2_submit_inode_data: OK
[   64.758426] Testing event jbd2_run_stats: OK
[   64.778450] Testing event jbd2_checkpoint_stats: OK
[   64.798412] Testing event jbd2_update_log_tail: OK
[   64.817857] Testing event jbd2_write_superblock: OK
[   64.838959] Testing event jbd_checkpoint: OK
[   64.859262] Testing event jbd_start_commit: OK
[   64.878916] Testing event jbd_commit_locking: OK
[   64.897782] Testing event jbd_commit_flushing: OK
[   64.918318] Testing event jbd_commit_logging: OK
[   64.938547] Testing event jbd_drop_transaction: OK
[   64.958484] Testing event jbd_end_commit: OK
[   64.978408] Testing event jbd_do_submit_data: OK
[   64.999049] Testing event jbd_cleanup_journal_tail: OK
[   65.018263] Testing event journal_write_superblock: OK
[   65.040066] Testing event ext4_free_inode: OK
[   65.059598] Testing event ext4_request_inode: OK
[   65.079995] Testing event ext4_allocate_inode: OK
[   65.098599] Testing event ext4_evict_inode: OK
[   65.119701] Testing event ext4_drop_inode: OK
[   65.138213] Testing event ext4_mark_inode_dirty: OK
[   65.159127] Testing event ext4_begin_ordered_truncate: OK
[   65.180648] Testing event ext4_write_begin: OK
[   65.198646] Testing event ext4_da_write_begin: OK
[   65.218243] Testing event ext4_ordered_write_end: OK
[   65.238916] Testing event ext4_writeback_write_end: OK
[   65.259749] Testing event ext4_journalled_write_end: OK
[   65.278508] Testing event ext4_da_write_end: OK
[   65.299438] Testing event ext4_da_writepages: OK
[   65.318539] Testing event ext4_da_write_pages: OK
[   65.338303] Testing event ext4_da_writepages_result: OK
[   65.367862] Testing event ext4_writepage: OK
[   65.386495] Testing event ext4_readpage: OK
[   65.406706] Testing event ext4_releasepage: OK
[   65.426389] Testing event ext4_invalidatepage: OK
[   65.446891] Testing event ext4_discard_blocks: OK
[   65.466407] Testing event ext4_mb_new_inode_pa: OK
[   65.487274] Testing event ext4_mb_new_group_pa: OK
[   65.506649] Testing event ext4_mb_release_inode_pa: OK
[   65.529110] Testing event ext4_mb_release_group_pa: OK
[   65.550648] Testing event ext4_discard_preallocations: OK
[   65.570742] Testing event ext4_mb_discard_preallocations: OK
[   65.590761] Testing event ext4_request_blocks: OK
[   65.610669] Testing event ext4_allocate_blocks: OK
[   65.630412] Testing event ext4_free_blocks: OK
[   65.650866] Testing event ext4_sync_file_enter: OK
[   65.670585] Testing event ext4_sync_file_exit: OK
[   65.690459] Testing event ext4_sync_fs: OK
[   65.712677] Testing event ext4_alloc_da_blocks: OK
[   65.729726] Testing event ext4_mballoc_alloc: OK
[   65.750387] Testing event ext4_mballoc_prealloc: OK
[   65.770771] Testing event ext4_mballoc_discard: OK
[   65.790951] Testing event ext4_mballoc_free: OK
[   65.811540] Testing event ext4_forget: OK
[   65.830320] Testing event ext4_da_update_reserve_space: OK
[   65.850915] Testing event ext4_da_reserve_space: OK
[   65.874440] Testing event ext4_da_release_space: OK
[   65.894801] Testing event ext4_mb_bitmap_load: OK
[   65.918879] Testing event ext4_mb_buddy_bitmap_load: OK
[   65.937639] Testing event ext4_read_block_bitmap_load: OK
[   65.954353] Testing event ext4_load_inode_bitmap: OK
[   65.974444] Testing event ext4_direct_IO_enter: OK
[   65.994677] Testing event ext4_direct_IO_exit: OK
[   66.014276] Testing event ext4_fallocate_enter: OK
[   66.035081] Testing event ext4_fallocate_exit: OK
[   66.054644] Testing event ext4_unlink_enter: OK
[   66.075552] Testing event ext4_unlink_exit: OK
[   66.095572] Testing event ext4_truncate_enter: OK
[   66.114770] Testing event ext4_truncate_exit: OK
[   66.134841] Testing event ext4_ext_convert_to_initialized_enter: OK
[   66.154947] Testing event ext4_ext_convert_to_initialized_fastpath: OK
[   66.178334] Testing event ext4_ext_map_blocks_enter: OK
[   66.198242] Testing event ext4_ind_map_blocks_enter: OK
[   66.218994] Testing event ext4_ext_map_blocks_exit: OK
[   66.239030] Testing event ext4_ind_map_blocks_exit: OK
[   66.265824] Testing event ext4_ext_load_extent: OK
[   66.286781] Testing event ext4_load_inode: OK
[   66.305683] Testing event ext4_journal_start: OK
[   66.323004] Testing event ext4_trim_extent: OK
[   66.342995] Testing event ext4_trim_all_free: OK
[   66.362815] Testing event ext4_ext_handle_uninitialized_extents: OK
[   66.383769] Testing event ext4_get_implied_cluster_alloc_exit: OK
[   66.402339] Testing event ext4_ext_put_in_cache: OK
[   66.422548] Testing event ext4_ext_in_cache: OK
[   66.451026] Testing event ext4_find_delalloc_range: OK
[   66.474430] Testing event ext4_get_reserved_cluster_alloc: OK
[   66.495109] Testing event ext4_ext_show_extent: OK
[   66.515149] Testing event ext4_remove_blocks: OK
[   66.534945] Testing event ext4_ext_rm_leaf: OK
[   66.554844] Testing event ext4_ext_rm_idx: OK
[   66.575516] Testing event ext4_ext_remove_space: OK
[   66.594278] Testing event ext4_ext_remove_space_done: OK
[   66.614394] Testing event ext3_free_inode: OK
[   66.636409] Testing event ext3_request_inode: OK
[   66.659534] Testing event ext3_allocate_inode: OK
[   66.680999] Testing event ext3_evict_inode: OK
[   66.702415] Testing event ext3_drop_inode: OK
[   66.722584] Testing event ext3_mark_inode_dirty: OK
[   66.742528] Testing event ext3_write_begin: OK
[   66.762824] Testing event ext3_ordered_write_end: OK
[   66.782641] Testing event ext3_writeback_write_end: OK
[   66.802652] Testing event ext3_journalled_write_end: OK
[   66.822787] Testing event ext3_ordered_writepage: OK
[   66.841638] Testing event ext3_writeback_writepage: OK
[   66.858946] Testing event ext3_journalled_writepage: OK
[   66.879467] Testing event ext3_readpage: OK
[   66.898677] Testing event ext3_releasepage: OK
[   66.918497] Testing event ext3_invalidatepage: OK
[   66.939526] Testing event ext3_discard_blocks: OK
[   66.958962] Testing event ext3_request_blocks: OK
[   66.991284] Testing event ext3_allocate_blocks: OK
[   67.010592] Testing event ext3_free_blocks: OK
[   67.032522] Testing event ext3_sync_file_enter: OK
[   67.055246] Testing event ext3_sync_file_exit: OK
[   67.075477] Testing event ext3_sync_fs: OK
[   67.094434] Testing event ext3_rsv_window_add: OK
[   67.116272] Testing event ext3_discard_reservation: OK
[   67.138429] Testing event ext3_alloc_new_reservation: OK
[   67.159659] Testing event ext3_reserved: OK
[   67.183527] Testing event ext3_forget: OK
[   67.204838] Testing event ext3_read_block_bitmap: OK
[   67.231703] Testing event ext3_direct_IO_enter: OK
[   67.259351] Testing event ext3_direct_IO_exit: OK
[   67.278460] Testing event ext3_unlink_enter: OK
[   67.298519] Testing event ext3_unlink_exit: OK
[   67.320137] Testing event ext3_truncate_enter: OK
[   67.338476] Testing event ext3_truncate_exit: OK
[   67.357845] Testing event ext3_get_blocks_enter: OK
[   67.379690] Testing event ext3_get_blocks_exit: OK
[   67.408086] Testing event ext3_load_inode: OK
[   67.426346] Testing event writeback_nothread: OK
[   67.446807] Testing event writeback_queue: OK
[   67.467598] Testing event writeback_exec: OK
[   67.490655] Testing event writeback_start: OK
[   67.510550] Testing event writeback_written: OK
[   67.531621] Testing event writeback_wait: OK
[   67.551407] Testing event writeback_pages_written: OK
[   67.571346] Testing event writeback_nowork: OK
[   67.590927] Testing event writeback_wake_background: OK
[   67.610905] Testing event writeback_wake_thread: OK
[   67.629600] Testing event writeback_wake_forker_thread: OK
[   67.645754] Testing event writeback_bdi_register: OK
[   67.665689] Testing event writeback_bdi_unregister: OK
[   67.685621] Testing event writeback_thread_start: OK
[   67.702192] Testing event writeback_thread_stop: OK
[   67.722414] Testing event wbc_writepage: OK
[   67.742421] Testing event writeback_queue_io: OK
[   67.763208] Testing event global_dirty_state: OK
[   67.782804] Testing event bdi_dirty_ratelimit: OK
[   67.802423] Testing event balance_dirty_pages: OK
[   67.831754] Testing event writeback_sb_inodes_requeue: OK
[   67.853641] Testing event writeback_congestion_wait: OK
[   67.875225] Testing event writeback_wait_iff_congested: OK
[   67.894483] Testing event writeback_single_inode: OK
[   67.914741] Testing event mm_compaction_isolate_migratepages: OK
[   67.934739] Testing event mm_compaction_isolate_freepages: OK
[   67.955340] Testing event mm_compaction_migratepages: OK
[   67.979839] Testing event kmalloc: OK
[   68.002533] Testing event kmem_cache_alloc: OK
[   68.022496] Testing event kmalloc_node: OK
[   68.042294] Testing event kmem_cache_alloc_node: OK
[   68.064545] Testing event kfree: OK
[   68.086680] Testing event kmem_cache_free: OK
[   68.107423] Testing event mm_page_free: OK
[   68.136135] Testing event mm_page_free_batched: OK
[   68.168162] Testing event mm_page_alloc: OK
[   68.193663] Testing event mm_page_alloc_zone_locked: OK
[   68.214693] Testing event mm_page_pcpu_drain: OK
[   68.234642] Testing event mm_page_alloc_extfrag: OK
[   68.254619] Testing event mm_vmscan_kswapd_sleep: OK
[   68.274677] Testing event mm_vmscan_kswapd_wake: OK
[   68.294637] Testing event mm_vmscan_wakeup_kswapd: OK
[   68.314530] Testing event mm_vmscan_direct_reclaim_begin: OK
[   68.334623] Testing event mm_vmscan_memcg_reclaim_begin: OK
[   68.354394] Testing event mm_vmscan_memcg_softlimit_reclaim_begin: OK
[   68.374458] Testing event mm_vmscan_direct_reclaim_end: OK
[   68.394416] Testing event mm_vmscan_memcg_reclaim_end: OK
[   68.414431] Testing event mm_vmscan_memcg_softlimit_reclaim_end: OK
[   68.434411] Testing event mm_shrink_slab_start: OK
[   68.454496] Testing event mm_shrink_slab_end: OK
[   68.474409] Testing event mm_vmscan_lru_isolate: OK
[   68.494647] Testing event mm_vmscan_memcg_isolate: OK
[   68.514541] Testing event mm_vmscan_writepage: OK
[   68.534490] Testing event mm_vmscan_lru_shrink_inactive: OK
[   68.558677] Testing event oom_score_adj_update: OK
[   68.579144] Testing event rpm_suspend: OK
[   68.604833] Testing event rpm_resume: OK
[   68.622571] Testing event rpm_idle: OK
[   68.643534] Testing event rpm_return_int: OK
[   68.663582] Testing event cpu_idle: OK
[   68.693567] Testing event cpu_frequency: OK
[   68.715022] Testing event machine_suspend: OK
[   68.735231] Testing event wakeup_source_activate: OK
[   68.754446] Testing event wakeup_source_deactivate: OK
[   68.775043] Testing event power_start: OK
[   68.801820] Testing event power_frequency: OK
[   68.822598] Testing event power_end: OK
[   68.842562] Testing event clock_enable: OK
[   68.863169] Testing event clock_disable: OK
[   68.886912] Testing event clock_set_rate: OK
[   68.906651] Testing event power_domain_target: OK
[   68.927568] Testing event ftrace_test_filter: OK
[   68.946698] Testing event module_load: OK
[   68.967417] Testing event module_free: OK
[   68.986291] Testing event module_get: OK
[   69.006396] Testing event module_put: OK
[   69.026515] Testing event module_request: OK
[   69.068729] Testing event lock_acquire: OK
[   69.091898] Testing event lock_release: OK
[   69.110206] Testing event lock_contended: OK
[   69.131885] Testing event lock_acquired: OK
[   69.164243] Testing event sched_kthread_stop: OK
[   69.182965] Testing event sched_kthread_stop_ret: OK
[   69.202454] Testing event sched_wakeup: OK
[   69.222386] Testing event sched_wakeup_new: OK
[   69.242398] Testing event sched_switch: OK
[   69.262762] Testing event sched_migrate_task: OK
[   69.283118] Testing event sched_process_free: OK
[   69.302449] Testing event sched_process_exit: OK
[   69.322603] Testing event sched_wait_task: OK
[   69.342602] Testing event sched_process_wait: OK
[   69.362624] Testing event sched_process_fork: OK
[   69.382933] Testing event sched_process_exec: OK
[   69.403419] Testing event sched_stat_wait: OK
[   69.423351] Testing event sched_stat_sleep: OK
[   69.447246] Testing event sched_stat_iowait: OK
[   69.478996] Testing event sched_stat_blocked: OK
[   69.499417] Testing event sched_stat_runtime: OK
[   69.524547] Testing event sched_pi_setprio: OK
[   69.551480] Testing event rcu_utilization: OK
[   69.578688] Testing event rcu_grace_period: OK
[   69.607354] Testing event rcu_grace_period_init: OK
[   69.628594] Testing event rcu_preempt_task: OK
[   69.651200] Testing event rcu_unlock_preempted_task: OK
[   69.685180] Testing event rcu_quiescent_state_report: OK
[   69.707583] Testing event rcu_fqs: OK
[   69.737258] Testing event rcu_dyntick: OK
[   69.759308] Testing event rcu_prep_idle: OK
[   69.778406] Testing event rcu_callback: OK
[   69.798264] Testing event rcu_kfree_callback: OK
[   69.817775] Testing event rcu_batch_start: OK
[   69.834023] Testing event rcu_invoke_callback: OK
[   69.855598] Testing event rcu_invoke_kfree_callback: OK
[   69.875145] Testing event rcu_batch_end: OK
[   69.894543] Testing event rcu_torture_read: OK
[   69.915983] Testing event rcu_barrier: OK
[   69.935660] Testing event workqueue_queue_work: OK
[   69.954576] Testing event workqueue_activate_work: OK
[   69.974528] Testing event workqueue_execute_start: OK
[   69.995102] Testing event workqueue_execute_end: OK
[   70.014550] Testing event signal_generate: OK
[   70.034433] Testing event signal_deliver: OK
[   70.054607] Testing event timer_init: OK
[   70.074889] Testing event timer_start: OK
[   70.094553] Testing event timer_expire_entry: OK
[   70.114570] Testing event timer_expire_exit: OK
[   70.134526] Testing event timer_cancel: OK
[   70.155114] Testing event hrtimer_init: OK
[   70.174500] Testing event hrtimer_start: OK
[   70.196713] Testing event hrtimer_expire_entry: OK
[   70.218601] Testing event hrtimer_expire_exit: OK
[   70.238650] Testing event hrtimer_cancel: OK
[   70.258665] Testing event itimer_state: OK
[   70.279121] Testing event itimer_expire: OK
[   70.299035] Testing event irq_handler_entry: OK
[   70.319459] Testing event irq_handler_exit: OK
[   70.338547] Testing event softirq_entry: OK
[   70.358958] Testing event softirq_exit: OK
[   70.379127] Testing event softirq_raise: OK
[   70.403137] Testing event console: OK
[   70.422792] Testing event task_newtask: OK
[   70.442761] Testing event task_rename: OK
[   70.462738] Testing event mce_record: OK
[   70.483270] Testing event sys_enter: OK
[   70.503447] Testing event sys_exit: OK
[   70.527030] Testing event emulate_vsyscall: OK
[   70.553510] Testing event xen_mc_batch: OK
[   70.581990] Testing event xen_mc_issue: OK
[   70.606830] Testing event xen_mc_entry: OK
[   70.626766] Testing event xen_mc_entry_alloc: OK
[   70.647453] Testing event xen_mc_callback: OK
[   70.672453] Testing event xen_mc_flush_reason: OK
[   70.694540] Testing event xen_mc_flush: OK
[   70.714682] Testing event xen_mc_extend_args: OK
[   70.734427] Testing event xen_mmu_set_pte: OK
[   70.754463] Testing event xen_mmu_set_pte_atomic: OK
[   70.774348] Testing event xen_mmu_set_domain_pte: OK
[   70.794554] Testing event xen_mmu_set_pte_at: OK
[   70.815111] Testing event xen_mmu_pte_clear: OK
[   70.834468] Testing event xen_mmu_set_pmd: OK
[   70.854431] Testing event xen_mmu_pmd_clear: OK
[   70.874422] Testing event xen_mmu_set_pud: OK
[   70.906611] Testing event xen_mmu_set_pgd: OK
[   70.926728] Testing event xen_mmu_pud_clear: OK
[   70.947011] Testing event xen_mmu_pgd_clear: OK
[   70.966676] Testing event xen_mmu_ptep_modify_prot_start: OK
[   70.986804] Testing event xen_mmu_ptep_modify_prot_commit: OK
[   71.006250] Testing event xen_mmu_alloc_ptpage: OK
[   71.026286] Testing event xen_mmu_release_ptpage: OK
[   71.046656] Testing event xen_mmu_pgd_pin: OK
[   71.066450] Testing event xen_mmu_pgd_unpin: OK
[   71.086537] Testing event xen_mmu_flush_tlb: OK
[   71.106602] Testing event xen_mmu_flush_tlb_single: OK
[   71.126723] Testing event xen_mmu_flush_tlb_others: OK
[   71.146600] Testing event xen_mmu_write_cr3: OK
[   71.166545] Testing event xen_cpu_write_ldt_entry: OK
[   71.186434] Testing event xen_cpu_write_idt_entry: OK
[   71.206599] Testing event xen_cpu_load_idt: OK
[   71.226434] Testing event xen_cpu_write_gdt_entry: OK
[   71.245680] Testing event xen_cpu_set_ldt: OK
[   71.262494] Testing event kvm_mmu_pagetable_walk: OK
[   71.282547] Testing event kvm_mmu_paging_element: OK
[   71.302253] Testing event kvm_mmu_set_accessed_bit: OK
[   71.323484] Testing event kvm_mmu_set_dirty_bit: OK
[   71.342439] Testing event kvm_mmu_walker_error: OK
[   71.362530] Testing event kvm_mmu_get_page: OK
[   71.382415] Testing event kvm_mmu_sync_page: OK
[   71.401898] Testing event kvm_mmu_unsync_page: OK
[   71.422232] Testing event kvm_mmu_prepare_zap_page: OK
[   71.442552] Testing event kvm_mmu_delay_free_pages: OK
[   71.462140] Testing event mark_mmio_spte: OK
[   71.482435] Testing event handle_mmio_page_fault: OK
[   71.502958] Testing event fast_page_fault: OK
[   71.531803] Testing event kvm_entry: OK
[   71.560351] Testing event kvm_hypercall: OK
[   71.592595] Testing event kvm_hv_hypercall: OK
[   71.619159] Testing event kvm_pio: OK
[   71.647392] Testing event kvm_cpuid: OK
[   71.671552] Testing event kvm_apic: OK
[   71.692459] Testing event kvm_exit: OK
[   71.711491] Testing event kvm_inj_virq: OK
[   71.734198] Testing event kvm_inj_exception: OK
[   71.755513] Testing event kvm_page_fault: OK
[   71.785582] Testing event kvm_msr: OK
[   71.807601] Testing event kvm_cr: OK
[   71.839664] Testing event kvm_pic_set_irq: OK
[   71.866292] Testing event kvm_apic_ipi: OK
[   71.886432] Testing event kvm_apic_accept_irq: OK
[   71.906986] Testing event kvm_eoi: OK
[   71.927109] Testing event kvm_pv_eoi: OK
[   71.956486] Testing event kvm_nested_vmrun: OK
[   71.982577] Testing event kvm_nested_intercepts: OK
[   72.003233] Testing event kvm_nested_vmexit: OK
[   72.032311] Testing event kvm_nested_vmexit_inject: OK
[   72.054727] Testing event kvm_nested_intr_vmexit: OK
[   72.075681] Testing event kvm_invlpga: OK
[   72.094596] Testing event kvm_skinit: OK
[   72.114604] Testing event kvm_emulate_insn: OK
[   72.134697] Testing event vcpu_match_mmio: OK
[   72.155258] Testing event kvm_userspace_exit: OK
[   72.183862] Testing event kvm_set_irq: OK
[   72.206636] Testing event kvm_ioapic_set_irq: OK
[   72.226669] Testing event kvm_msi_set_irq: OK
[   72.246355] Testing event kvm_ack_irq: OK
[   72.266336] Testing event kvm_mmio: OK
[   72.286466] Testing event kvm_fpu: OK
[   72.306337] Testing event kvm_age_page: OK
[   72.326430] Testing event kvm_try_async_get_page: OK
[   72.346523] Testing event kvm_async_pf_doublefault: OK
[   72.366577] Testing event kvm_async_pf_not_present: OK
[   72.386517] Testing event kvm_async_pf_ready: OK
[   72.406606] Testing event kvm_async_pf_completed: OK
[   72.426504] Running tests on trace event systems:
[   72.428328] Testing event system 9p: OK
[   72.452636] Testing event system mac80211: OK
[   72.550097] Testing event system sunrpc: OK
[   72.587543] Testing event system skb: OK
[   72.617687] Testing event system net: OK
[   72.639594] Testing event system napi: OK
[   72.658634] Testing event system sock: OK
[   72.678958] Testing event system udp: OK
[   72.698677] Testing event system hda: OK
[   72.720930] Testing event system ras: OK
[   72.742501] Testing event system scsi: OK
[   72.764221] Testing event system regmap: OK
[   72.790414] Testing event system i915: OK
[   72.827554] Testing event system radeon: OK
[   72.852226] Testing event system drm: OK
[   72.875420] Testing event system random: OK
[   72.901413] Testing event system regulator: OK
[   72.925856] Testing event system gpio: OK
[   72.946862] Testing event system block: OK
[   72.985302] Testing event system gfs2: OK
[   73.022581] Testing event system btrfs: OK
[   73.067188] Testing event system ocfs2: OK
[   73.365938] Testing event system xfs: OK
[   73.653343] Testing event system jbd2: OK
[   73.683100] Testing event system jbd: OK
[   73.710825] Testing event system ext4: OK
[   73.793282] Testing event system ext3: OK
[   73.841331] Testing event system writeback: OK
[   73.882905] Testing event system compaction: OK
[   73.903846] Testing event system kmem: OK
[   73.935127] Testing event system vmscan: OK
[   73.968340] Testing event system oom: OK
[   73.986716] Testing event system rpm: OK
[   74.012133] Testing event system power: OK
[   74.042758] Testing event system test: OK
[   74.062587] Testing event system module: OK
[   74.100104] Testing event system lock: OK
[   74.134752] Testing event system sched: OK
[   74.180864] Testing event system rcu: OK
[   74.225989] Testing event system workqueue: OK
[   74.248732] Testing event system signal: OK
[   74.271794] Testing event system timer: OK
[   74.300151] Testing event system irq: OK
[   74.324237] Testing event system printk: OK
[   74.342503] Testing event system task: OK
[   74.362926] Testing event system mce: OK
[   74.382338] Testing event system raw_syscalls: OK
[   74.402801] Testing event system vsyscall: OK
[   74.422669] Testing event system syscalls: OK
[   74.449696] Testing event system xen: OK
[   74.497229] Testing event system kvmmmu: OK
[   74.528716] Testing event system kvm: OK
[   74.579444] Running tests on all trace events:
[   74.580788] Testing all events: OK
[   76.268956] Testing ftrace filter: OK
[   76.272715] Testing kprobe tracing: OK
[   76.278978] kAFS: Red Hat AFS client v0.1 registering.
[   76.280408] FS-Cache: Netfs 'afs' registered for caching
[   76.284190] console [netcon0] enabled
[   76.285160] netconsole: network logging started
[   76.286627] rtc_cmos 00:01: setting system clock to 2012-08-10 09:39:08 =
UTC (1344591548)
[   76.288888] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   76.290429] EDD information not available.
[   76.293809] IPv6: ADDRCONF(NETDEV_UP): bond0: link is not ready
[   76.295205] 8021q: adding VLAN 0 to HW filter on device bond0
[   76.298897] IP-Config: Failed to open ipddp0
[   76.309097] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Contr=
ol: RX
[   76.312443] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   76.314507] 8021q: adding VLAN 0 to HW filter on device eth0
[   76.315865] IP-Config: Failed to open plip0
[   76.316970] ieee80211 phy0: mac80211_hwsim_start
[   76.318184] ieee80211 phy0: mac80211_hwsim_add_interface (type=3D2 mac_a=
ddr=3D02:00:00:00:00:00)
[   76.320288] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=3D0x=
e)
[   76.321869] ieee80211 phy0:   ERP_CTS_PROT: 0
[   76.322944] ieee80211 phy0:   ERP_PREAMBLE: 0
[   76.324042] ieee80211 phy0:   ERP_SLOT: 0
[   76.325063] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3D0 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.327197] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3D1 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.329350] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3D2 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.331537] ieee80211 phy0: mac80211_hwsim_conf_tx (queue=3D3 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.333667] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=3D0x=
2000)
[   76.335320] ieee80211 phy0: mac80211_hwsim_bss_info_changed(changed=3D0x=
4000)
[   76.336949] ieee80211 phy0: mac80211_hwsim_config (freq=3D2412/noht idle=
=3D1 ps=3D0 smps=3Dstatic)
[   76.352561] ieee80211 phy0: mac80211_hwsim_configure_filter
[   76.353588] IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   76.353715] ieee80211 phy1: mac80211_hwsim_start
[   76.353724] ieee80211 phy1: mac80211_hwsim_add_interface (type=3D2 mac_a=
ddr=3D02:00:00:00:01:00)
[   76.353727] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=3D0x=
e)
[   76.353728] ieee80211 phy1:   ERP_CTS_PROT: 0
[   76.353730] ieee80211 phy1:   ERP_PREAMBLE: 0
[   76.353731] ieee80211 phy1:   ERP_SLOT: 0
[   76.353737] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3D0 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.353739] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3D1 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.353747] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3D2 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.353749] ieee80211 phy1: mac80211_hwsim_conf_tx (queue=3D3 txop=3D0 c=
w_min=3D31 cw_max=3D1023 aifs=3D2)
[   76.353751] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=3D0x=
2000)
[   76.353755] ieee80211 phy1: mac80211_hwsim_bss_info_changed(changed=3D0x=
4000)
[   76.353759] ieee80211 phy1: mac80211_hwsim_config (freq=3D2412/noht idle=
=3D1 ps=3D0 smps=3Dstatic)
[   76.354835] IPv6: ADDRCONF(NETDEV_UP): wlan1: link is not ready
[   76.355252] DHCP/BOOTP: Ignoring device hardwpan0, MTU 127 too small
[   76.355252] IP-Config: Failed to open irlan0
[   76.355292] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   76.383867] ieee80211 phy1: mac80211_hwsim_configure_filter
[   76.386484] ieee80211 phy0: mac80211_hwsim_configure_filter
[   76.368063] Sending DHCP requests ., OK
[   77.876635] IP-Config: Got DHCP answer from 10.0.2.2, my address is 10.0=
=2E2.15
[   77.880651] ieee80211 phy0: mac80211_hwsim_configure_filter
[   77.882352] ieee80211 phy0: mac80211_hwsim_configure_filter
[   77.884469] ieee80211 phy0: mac80211_hwsim_remove_interface (type=3D2 ma=
c_addr=3D02:00:00:00:00:00)
[   77.886861] ieee80211 phy0: mac80211_hwsim_stop
[   77.888591] ieee80211 phy1: mac80211_hwsim_configure_filter
[   77.890219] ieee80211 phy1: mac80211_hwsim_configure_filter
[   77.892195] ieee80211 phy1: mac80211_hwsim_remove_interface (type=3D2 ma=
c_addr=3D02:00:00:00:01:00)
[   77.894607] ieee80211 phy1: mac80211_hwsim_stop
[   77.897400] IP-Config: Complete:
[   77.898468]      device=3Deth0, addr=3D10.0.2.15, mask=3D255.255.255.0, =
gw=3D10.0.2.2
[   77.900189]      host=3Dkvm, domain=3D, nis-domain=3D(none)
[   77.901595]      bootserver=3D10.0.2.2, rootserver=3D10.239.97.14, rootp=
ath=3D
[   77.903523] ALSA device list:
[   77.904476]   #0: Dummy 1
[   77.905276]   #1: Virtual MIDI Card 1
[   77.907317] md: Waiting for all devices to be available before autodetect
[   77.909159] md: If you don't use raid, use raid=3Dnoautodetect
[   77.912419] md: Autodetecting RAID arrays.
[   77.913601] md: Scanned 0 and added 0 devices.
[   77.914805] md: autorun ...
[   77.915703] md: ... autorun DONE.
[   77.926545] BUG: unable to handle kernel NULL pointer dereference at 000=
0000000000030
[   77.928884] IP: [<ffffffff8250e980>] ip_send_skb+0xf/0x3d
[   77.929523] PGD 0=20
[   77.929523] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
[   77.929523] Modules linked in:
[   77.929523] CPU 0=20
[   77.929523] Pid: 171, comm: kworker/0:2 Not tainted 3.6.0-rc1+ #1720 Boc=
hs Bochs
[   77.929523] RIP: 0010:[<ffffffff8250e980>]  [<ffffffff8250e980>] ip_send=
_skb+0xf/0x3d
[   77.929523] RSP: 0018:ffff88001f203938  EFLAGS: 00010286
[   77.929523] RAX: 0000000000000000 RBX: ffff88001f3d2580 RCX: ffff880012e=
75eb8
[   77.929523] RDX: ffff88001f2039b8 RSI: ffff880012e9dd28 RDI: ffff8800129=
03f00
[   77.929523] RBP: ffff88001f203948 R08: 0000000000000000 R09: 00000000000=
00000
[   77.929523] R10: ffff88001f3d2810 R11: ffff880012e75e00 R12: ffff880012e=
5cf00
[   77.929523] R13: ffff880012903f00 R14: ffff88001f203a88 R15: ffff88001f3=
d2820
[   77.929523] FS:  0000000000000000(0000) GS:ffff88001f200000(0000) knlGS:=
0000000000000000
[   77.929523] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   77.929523] CR2: 0000000000000030 CR3: 0000000003614000 CR4: 00000000000=
006f0
[   77.929523] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   77.929523] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[   77.929523] Process kworker/0:2 (pid: 171, threadinfo ffff880013d9a000, =
task ffff880013d9c180)
[   77.929523] Stack:
[   77.929523]  ffff880012e9dd28 ffff88001f3d2580 ffff88001f203958 ffffffff=
8250e9d7
[   77.929523]  ffff88001f203a58 ffffffff8250edcd ffff88001f2039a0 ffff8800=
1f203998
[   77.929523]  ffff880000000040 ffffffff810d312d 000000000f02000a 00000014=
24c86afd
[   77.929523] Call Trace:
[   77.929523]  <IRQ>=20
[   77.929523]  [<ffffffff8250e9d7>] ip_push_pending_frames+0x29/0x2f
[   77.929523]  [<ffffffff8250edcd>] ip_send_unicast_reply+0x297/0x2ce
[   77.929523]  [<ffffffff810d312d>] ? trace_hardirqs_off_caller+0x1f/0x9e
[   77.929523]  [<ffffffff810b9f00>] ? local_clock+0x25/0x52
[   77.929523]  [<ffffffff810d36ca>] ? lock_is_held+0x82/0x94
[   77.929523]  [<ffffffff82526999>] tcp_v4_send_ack+0x1f9/0x218
[   77.929523]  [<ffffffff810b9f16>] ? local_clock+0x3b/0x52
[   77.929523]  [<ffffffff82527ff2>] tcp_v4_rcv+0x6a7/0x754
[   77.929523]  [<ffffffff82509846>] ? __xfrm_policy_check2.constprop.8+0x5=
b/0x5b
[   77.929523]  [<ffffffff825099c1>] ip_local_deliver_finish+0x17b/0x20f
[   77.929523]  [<ffffffff8250988d>] ? ip_local_deliver_finish+0x47/0x20f
[   77.929523]  [<ffffffff82509ba1>] ip_local_deliver+0x53/0x84
[   77.929523]  [<ffffffff825094bf>] ? skb_dst.isra.5+0x37/0x5b
[   77.929523]  [<ffffffff810b9ef4>] ? local_clock+0x19/0x52
[   77.929523]  [<ffffffff825097b3>] ip_rcv_finish+0x2d0/0x308
[   77.929523]  [<ffffffff82509de2>] ip_rcv+0x210/0x26a
[   77.929523]  [<ffffffff8248253a>] ? rcu_lock_acquire+0x27/0x29
[   77.929523]  [<ffffffff82482513>] ? dev_seq_stop+0x10/0x10
[   77.929523]  [<ffffffff824868b9>] __netif_receive_skb+0x469/0x572
[   77.929523]  [<ffffffff82486b8a>] netif_receive_skb+0x65/0x9c
[   77.929523]  [<ffffffff824870e3>] ? __napi_gro_receive+0xf2/0xfe
[   77.929523]  [<ffffffff82486c4f>] napi_skb_finish+0x27/0x59
[   77.929523]  [<ffffffff824871e2>] napi_gro_receive+0x2f/0x34
[   77.929523]  [<ffffffff81caf06e>] e1000_receive_skb+0x57/0x60
[   77.929523]  [<ffffffff81cb1ebb>] e1000_clean_rx_irq+0x2f2/0x387
[   77.929523]  [<ffffffff81cafdb4>] e1000_clean+0x541/0x695
[   77.929523]  [<ffffffff810d6d1c>] ? mark_held_locks+0x71/0x99
[   77.929523]  [<ffffffff82487432>] ? net_rx_action+0x1ae/0x1ee
[   77.929523]  [<ffffffff82487337>] net_rx_action+0xb3/0x1ee
[   77.929523]  [<ffffffff81090178>] ? __do_softirq+0x83/0x1f5
[   77.929523]  [<ffffffff810901be>] __do_softirq+0xc9/0x1f5
[   77.929523]  [<ffffffff8286b3bc>] call_softirq+0x1c/0x30
[   77.929523]  <EOI>=20
[   77.929523]  [<ffffffff8104ac90>] do_softirq+0x4a/0xa2
[   77.929523]  [<ffffffff825184cc>] ? tcp_close+0x2e7/0x303
[   77.929523]  [<ffffffff8108fcfa>] _local_bh_enable_ip+0xa7/0xd8
[   77.929523]  [<ffffffff8108fd4d>] local_bh_enable+0x12/0x14
[   77.929523]  [<ffffffff825184cc>] tcp_close+0x2e7/0x303
[   77.929523]  [<ffffffff82535559>] inet_release+0x7e/0x85
[   77.929523]  [<ffffffff824739f4>] sock_release+0x1f/0x77
[   77.929523]  [<ffffffff82618a94>] xs_reset_transport+0xb8/0xc1
[   77.929523]  [<ffffffff82618ab0>] xs_close+0x13/0x42
[   77.929523]  [<ffffffff82618b04>] xs_destroy+0x25/0x59
[   77.929523]  [<ffffffff82616b17>] xprt_destroy+0x73/0x77
[   77.929523]  [<ffffffff82618196>] xprt_put+0x18/0x1a
[   77.929523]  [<ffffffff82615e6a>] rpc_free_client+0x8e/0xa0
[   77.929523]  [<ffffffff82615dab>] rpc_release_client+0x4f/0x80
[   77.929523]  [<ffffffff82616179>] rpc_task_release_client+0x4b/0x54
[   77.929523]  [<ffffffff8261b9cb>] rpc_release_resources_task+0x39/0x3e
[   77.929523]  [<ffffffff8261ce33>] __rpc_execute+0x12e/0x22b
[   77.929523]  [<ffffffff810d6e67>] ? trace_hardirqs_on_caller+0x123/0x17f
[   77.929523]  [<ffffffff8261cf58>] rpc_async_schedule+0x28/0x34
[   77.929523]  [<ffffffff810a1ecf>] process_one_work+0x1ef/0x3cc
[   77.929523]  [<ffffffff810a1e62>] ? process_one_work+0x182/0x3cc
[   77.929523]  [<ffffffff810d4d4c>] ? lock_acquired+0x1fa/0x22b
[   77.929523]  [<ffffffff8261cf30>] ? __rpc_execute+0x22b/0x22b
[   77.929523]  [<ffffffff810a2412>] worker_thread+0x1ac/0x250
[   77.929523]  [<ffffffff810a2266>] ? rescuer_thread+0x18b/0x18b
[   77.929523]  [<ffffffff810a8ec4>] kthread+0x8a/0x92
[   77.929523]  [<ffffffff8167be8e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   77.929523]  [<ffffffff8286b2c4>] kernel_thread_helper+0x4/0x10
[   77.929523]  [<ffffffff82863930>] ? retint_restore_args+0x13/0x13
[   77.929523]  [<ffffffff810a8e3a>] ? __init_kthread_worker+0x5a/0x5a
[   77.929523]  [<ffffffff8286b2c0>] ? gs_change+0x13/0x13
[   77.929523] Code: 87 84 fe ff ff e9 7a fe ff ff 48 83 c4 38 4c 89 e8 5b =
41 5c 41 5d 41 5e 41 5f 5d c3 55 48 89 e5 53 56 0f 1f 44 00 00 48 8b 47 18 =
<48> 8b 58 30 e8 d1 f1 ff ff 83 f8 00 74 1c 7e 0e 83 f8 02 75 04=20
[   77.929523] RIP  [<ffffffff8250e980>] ip_send_skb+0xf/0x3d
[   77.929523]  RSP <ffff88001f203938>
[   77.929523] CR2: 0000000000000030
[   78.098032] ---[ end trace 0aa2f229c4dc73c1 ]---
[   78.099404] Kernel panic - not syncing: Fatal exception in interrupt
[   78.101210] Rebooting in 10 seconds..
--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="config-3.6.0-rc1+"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.6.0-rc1 Kernel Configuration
#
CONFIG_64BIT=y
# CONFIG_X86_32 is not set
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
# CONFIG_RWSEM_GENERIC_SPINLOCK is not set
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
CONFIG_X86_64_SMP=y
CONFIG_X86_HT=y
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_CPU_PROBE_RELEASE=y
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_HAVE_IRQ_WORK=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
CONFIG_EXPERIMENTAL=y
CONFIG_INIT_ENV_ARG_LIMIT=32
CONFIG_CROSS_COMPILE=""
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
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
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
# CONFIG_FHANDLE is not set
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
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
CONFIG_IRQ_DOMAIN=y
# CONFIG_IRQ_DOMAIN_DEBUG is not set
CONFIG_IRQ_FORCED_THREADING=y
CONFIG_SPARSE_IRQ=y
CONFIG_CLOCKSOURCE_WATCHDOG=y
CONFIG_ARCH_CLOCKSOURCE_DATA=y
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
# RCU Subsystem
#
CONFIG_TREE_RCU=y
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_FANOUT=64
CONFIG_RCU_FANOUT_LEAF=16
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_RCU_FAST_NO_HZ=y
CONFIG_TREE_RCU_TRACE=y
# CONFIG_IKCONFIG is not set
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CPUSETS=y
CONFIG_PROC_PID_CPUSET=y
CONFIG_CGROUP_CPUACCT=y
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
CONFIG_CC_OPTIMIZE_FOR_SIZE=y
CONFIG_SYSCTL=y
CONFIG_ANON_INODES=y
# CONFIG_EXPERT is not set
CONFIG_UID16=y
# CONFIG_SYSCTL_SYSCALL is not set
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
CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS=y
CONFIG_KRETPROBES=y
CONFIG_USER_RETURN_NOTIFIER=y
CONFIG_HAVE_IOREMAP_PROT=y
CONFIG_HAVE_KPROBES=y
CONFIG_HAVE_KRETPROBES=y
CONFIG_HAVE_OPTPROBES=y
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
CONFIG_HAVE_ARCH_JUMP_LABEL=y
CONFIG_ARCH_HAVE_NMI_SAFE_CMPXCHG=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_ARCH_WANT_COMPAT_IPC_PARSE_VERSION=y
CONFIG_ARCH_WANT_OLD_COMPAT_IPC=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_SECCOMP_FILTER=y

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
# CONFIG_INLINE_SPIN_TRYLOCK is not set
# CONFIG_INLINE_SPIN_TRYLOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK is not set
# CONFIG_INLINE_SPIN_LOCK_BH is not set
# CONFIG_INLINE_SPIN_LOCK_IRQ is not set
# CONFIG_INLINE_SPIN_LOCK_IRQSAVE is not set
CONFIG_UNINLINE_SPIN_UNLOCK=y
# CONFIG_INLINE_SPIN_UNLOCK_BH is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQ is not set
# CONFIG_INLINE_SPIN_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_READ_TRYLOCK is not set
# CONFIG_INLINE_READ_LOCK is not set
# CONFIG_INLINE_READ_LOCK_BH is not set
# CONFIG_INLINE_READ_LOCK_IRQ is not set
# CONFIG_INLINE_READ_LOCK_IRQSAVE is not set
# CONFIG_INLINE_READ_UNLOCK is not set
# CONFIG_INLINE_READ_UNLOCK_BH is not set
# CONFIG_INLINE_READ_UNLOCK_IRQ is not set
# CONFIG_INLINE_READ_UNLOCK_IRQRESTORE is not set
# CONFIG_INLINE_WRITE_TRYLOCK is not set
# CONFIG_INLINE_WRITE_LOCK is not set
# CONFIG_INLINE_WRITE_LOCK_BH is not set
# CONFIG_INLINE_WRITE_LOCK_IRQ is not set
# CONFIG_INLINE_WRITE_LOCK_IRQSAVE is not set
# CONFIG_INLINE_WRITE_UNLOCK is not set
# CONFIG_INLINE_WRITE_UNLOCK_BH is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQ is not set
# CONFIG_INLINE_WRITE_UNLOCK_IRQRESTORE is not set
# CONFIG_MUTEX_SPIN_ON_OWNER is not set
CONFIG_FREEZER=y

#
# Processor type and features
#
CONFIG_ZONE_DMA=y
CONFIG_SMP=y
CONFIG_X86_MPPARSE=y
# CONFIG_X86_EXTENDED_PLATFORM is not set
CONFIG_X86_SUPPORTS_MEMORY_FAILURE=y
CONFIG_SCHED_OMIT_FRAME_POINTER=y
CONFIG_PARAVIRT_GUEST=y
# CONFIG_PARAVIRT_TIME_ACCOUNTING is not set
CONFIG_XEN=y
CONFIG_XEN_DOM0=y
CONFIG_XEN_PRIVILEGED_GUEST=y
CONFIG_XEN_PVHVM=y
CONFIG_XEN_MAX_DOMAIN_MEMORY=500
CONFIG_XEN_SAVE_RESTORE=y
# CONFIG_XEN_DEBUG_FS is not set
CONFIG_KVM_CLOCK=y
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
CONFIG_X86_CMPXCHG=y
CONFIG_X86_L1_CACHE_SHIFT=6
CONFIG_X86_XADD=y
CONFIG_X86_WP_WORKS_OK=y
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
# CONFIG_IRQ_TIME_ACCOUNTING is not set
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
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
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
CONFIG_MEMORY_HOTREMOVE=y
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=1
CONFIG_BOUNCE=y
CONFIG_VIRT_TO_BUS=y
CONFIG_MMU_NOTIFIER=y
CONFIG_KSM=y
CONFIG_DEFAULT_MMAP_MIN_ADDR=65536
CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
CONFIG_MEMORY_FAILURE=y
CONFIG_HWPOISON_INJECT=y
# CONFIG_TRANSPARENT_HUGEPAGE is not set
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
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_IPMI is not set
CONFIG_ACPI_HOTPLUG_CPU=y
CONFIG_ACPI_PROCESSOR_AGGREGATOR=y
CONFIG_ACPI_THERMAL=y
CONFIG_ACPI_NUMA=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
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
# CONFIG_ACPI_APEI_PCIEAER is not set
# CONFIG_ACPI_APEI_MEMORY_FAILURE is not set
# CONFIG_ACPI_APEI_EINJ is not set
# CONFIG_ACPI_APEI_ERST_DEBUG is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
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
CONFIG_X86_PCC_CPUFREQ=y
CONFIG_X86_ACPI_CPUFREQ=y
CONFIG_X86_POWERNOW_K8=y
CONFIG_X86_SPEEDSTEP_CENTRINO=y
CONFIG_X86_P4_CLOCKMOD=y

#
# shared options
#
CONFIG_X86_SPEEDSTEP_LIB=y
CONFIG_CPU_IDLE=y
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
# CONFIG_PCI_CNB20LE_QUIRK is not set
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
CONFIG_PCI_ATS=y
CONFIG_PCI_IOV=y
CONFIG_PCI_PRI=y
CONFIG_PCI_PASID=y
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
CONFIG_HOTPLUG_PCI_FAKE=y
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
# CONFIG_IP_FIB_TRIE_STATS is not set
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_MULTIPATH=y
CONFIG_IP_ROUTE_VERBOSE=y
CONFIG_IP_ROUTE_CLASSID=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_IP_PNP_RARP=y
CONFIG_NET_IPIP=y
# CONFIG_NET_IPGRE_DEMUX is not set
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
# CONFIG_NF_CONNTRACK_TIMESTAMP is not set
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
# CONFIG_NF_CONNTRACK_SNMP is not set
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

#
# Xtables targets
#
# CONFIG_NETFILTER_XT_TARGET_AUDIT is not set
# CONFIG_NETFILTER_XT_TARGET_CHECKSUM is not set
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_CONNSECMARK=y
CONFIG_NETFILTER_XT_TARGET_CT=y
CONFIG_NETFILTER_XT_TARGET_DSCP=y
CONFIG_NETFILTER_XT_TARGET_HL=y
# CONFIG_NETFILTER_XT_TARGET_HMARK is not set
# CONFIG_NETFILTER_XT_TARGET_IDLETIMER is not set
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
# CONFIG_NETFILTER_XT_MATCH_ADDRTYPE is not set
CONFIG_NETFILTER_XT_MATCH_CLUSTER=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNLIMIT=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
# CONFIG_NETFILTER_XT_MATCH_CPU is not set
CONFIG_NETFILTER_XT_MATCH_DCCP=y
# CONFIG_NETFILTER_XT_MATCH_DEVGROUP is not set
CONFIG_NETFILTER_XT_MATCH_DSCP=y
CONFIG_NETFILTER_XT_MATCH_ECN=y
CONFIG_NETFILTER_XT_MATCH_ESP=y
CONFIG_NETFILTER_XT_MATCH_HASHLIMIT=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_HL=y
CONFIG_NETFILTER_XT_MATCH_IPRANGE=y
# CONFIG_NETFILTER_XT_MATCH_IPVS is not set
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
# CONFIG_IP_SET is not set
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
CONFIG_IP_VS_FTP=y
CONFIG_IP_VS_NFCT=y
# CONFIG_IP_VS_PE_SIP is not set

#
# IP: Netfilter Configuration
#
CONFIG_NF_DEFRAG_IPV4=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_NF_CONNTRACK_PROC_COMPAT=y
CONFIG_IP_NF_QUEUE=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_AH=y
CONFIG_IP_NF_MATCH_ECN=y
# CONFIG_IP_NF_MATCH_RPFILTER is not set
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_ULOG=y
CONFIG_NF_NAT=y
CONFIG_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_NF_NAT_PROTO_DCCP=y
CONFIG_NF_NAT_PROTO_GRE=y
CONFIG_NF_NAT_PROTO_UDPLITE=y
CONFIG_NF_NAT_PROTO_SCTP=y
CONFIG_NF_NAT_FTP=y
CONFIG_NF_NAT_IRC=y
CONFIG_NF_NAT_TFTP=y
CONFIG_NF_NAT_AMANDA=y
CONFIG_NF_NAT_PPTP=y
CONFIG_NF_NAT_H323=y
CONFIG_NF_NAT_SIP=y
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
# DCCP CCIDs Configuration (EXPERIMENTAL)
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
# CONFIG_SCTP_HMAC_NONE is not set
# CONFIG_SCTP_HMAC_SHA1 is not set
CONFIG_SCTP_HMAC_MD5=y
CONFIG_RDS=y
CONFIG_RDS_RDMA=y
CONFIG_RDS_TCP=y
# CONFIG_RDS_DEBUG is not set
CONFIG_TIPC=y
CONFIG_TIPC_ADVANCED=y
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
# CONFIG_NET_DSA is not set
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
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
CONFIG_IPDDP_DECAP=y
# CONFIG_X25 is not set
CONFIG_LAPB=y
CONFIG_WAN_ROUTER=y
CONFIG_PHONET=y
CONFIG_IEEE802154=y
# CONFIG_IEEE802154_6LOWPAN is not set
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
# CONFIG_NET_SCH_SFB is not set
CONFIG_NET_SCH_SFQ=y
CONFIG_NET_SCH_TEQL=y
CONFIG_NET_SCH_TBF=y
CONFIG_NET_SCH_GRED=y
CONFIG_NET_SCH_DSMARK=y
CONFIG_NET_SCH_NETEM=y
CONFIG_NET_SCH_DRR=y
# CONFIG_NET_SCH_MQPRIO is not set
# CONFIG_NET_SCH_CHOKE is not set
# CONFIG_NET_SCH_QFQ is not set
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
# CONFIG_NET_ACT_CSUM is not set
CONFIG_NET_CLS_IND=y
CONFIG_NET_SCH_FIFO=y
CONFIG_DCB=y
CONFIG_DNS_RESOLVER=y
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
CONFIG_RPS=y
CONFIG_RFS_ACCEL=y
CONFIG_XPS=y
# CONFIG_NETPRIO_CGROUP is not set
CONFIG_BQL=y
# CONFIG_BPF_JIT is not set

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
# CONFIG_CAN_GW is not set

#
# CAN Device Drivers
#
CONFIG_CAN_VCAN=y
# CONFIG_CAN_SLCAN is not set
CONFIG_CAN_DEV=y
CONFIG_CAN_CALC_BITTIMING=y
CONFIG_CAN_MCP251X=y
# CONFIG_PCH_CAN is not set
CONFIG_CAN_SJA1000=y
# CONFIG_CAN_SJA1000_ISA is not set
# CONFIG_CAN_SJA1000_PLATFORM is not set
# CONFIG_CAN_EMS_PCMCIA is not set
CONFIG_CAN_EMS_PCI=y
# CONFIG_CAN_PEAK_PCMCIA is not set
# CONFIG_CAN_PEAK_PCI is not set
CONFIG_CAN_KVASER_PCI=y
CONFIG_CAN_PLX_PCI=y
# CONFIG_CAN_C_CAN is not set
# CONFIG_CAN_CC770 is not set

#
# CAN USB interfaces
#
CONFIG_CAN_EMS_USB=y
# CONFIG_CAN_ESD_USB2 is not set
# CONFIG_CAN_PEAK_USB is not set
# CONFIG_CAN_SOFTING is not set
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
# CONFIG_BT_RFCOMM is not set
# CONFIG_BT_BNEP is not set
# CONFIG_BT_CMTP is not set
# CONFIG_BT_HIDP is not set

#
# Bluetooth device drivers
#
CONFIG_BT_HCIBTUSB=y
CONFIG_BT_HCIBTSDIO=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_H4=y
CONFIG_BT_HCIUART_BCSP=y
# CONFIG_BT_HCIUART_ATH3K is not set
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
# CONFIG_NFC is not set
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
# CONFIG_DEBUG_DRIVER is not set
# CONFIG_DEBUG_DEVRES is not set
CONFIG_SYS_HYPERVISOR=y
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_DMA_SHARED_BUFFER=y
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
# CONFIG_MTD_SWAP is not set

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
# CONFIG_MTD_SC520CDP is not set
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
# CONFIG_MTD_NAND_VERIFY_WRITE is not set
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
CONFIG_MTD_UBI_BEB_RESERVE=2
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
# CONFIG_BLK_DEV_UB is not set
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=65536
# CONFIG_BLK_DEV_XIP is not set
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
# CONFIG_CDROM_PKTCDVD_WCACHE is not set
CONFIG_ATA_OVER_ETH=y
CONFIG_XEN_BLKDEV_FRONTEND=y
# CONFIG_XEN_BLKDEV_BACKEND is not set
CONFIG_VIRTIO_BLK=y
# CONFIG_BLK_DEV_HD is not set
# CONFIG_BLK_DEV_RBD is not set

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
CONFIG_ENCLOSURE_SERVICES=y
CONFIG_HP_ILO=y
# CONFIG_APDS9802ALS is not set
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
CONFIG_SENSORS_TSL2550=y
# CONFIG_SENSORS_BH1780 is not set
# CONFIG_SENSORS_BH1770 is not set
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_TI_DAC7512=y
CONFIG_VMWARE_BALLOON=y
# CONFIG_BMP085_I2C is not set
# CONFIG_BMP085_SPI is not set
# CONFIG_PCH_PHUB is not set
# CONFIG_USB_SWITCH_FSA9480 is not set
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
# CONFIG_SCSI_CXGB4_ISCSI is not set
CONFIG_SCSI_BNX2_ISCSI=y
# CONFIG_SCSI_BNX2X_FCOE is not set
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
# CONFIG_SCSI_MVUMI is not set
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
# CONFIG_SCSI_UFSHCD is not set
CONFIG_SCSI_HPTIOP=y
CONFIG_SCSI_BUSLOGIC=y
CONFIG_VMWARE_PVSCSI=y
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
# CONFIG_SCSI_ISCI is not set
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
CONFIG_SCSI_QLA_ISCSI=y
# CONFIG_SCSI_LPFC is not set
CONFIG_SCSI_DC395x=y
CONFIG_SCSI_DC390T=y
CONFIG_SCSI_DEBUG=y
CONFIG_SCSI_PMCRAID=y
CONFIG_SCSI_PM8001=y
CONFIG_SCSI_SRP=y
CONFIG_SCSI_BFA_FC=y
# CONFIG_SCSI_VIRTIO is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
# CONFIG_PCMCIA_AHA152X is not set
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
CONFIG_SATA_PMP=y

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
# CONFIG_SATA_AHCI_PLATFORM is not set
CONFIG_SATA_INIC162X=y
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
CONFIG_ATA_SFF=y

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
# CONFIG_PATA_ARASAN_CF is not set
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
# CONFIG_MULTICORE_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BLK_DEV_DM=y
# CONFIG_DM_DEBUG is not set
CONFIG_DM_CRYPT=y
CONFIG_DM_SNAPSHOT=y
# CONFIG_DM_THIN_PROVISIONING is not set
CONFIG_DM_MIRROR=y
# CONFIG_DM_RAID is not set
CONFIG_DM_LOG_USERSPACE=y
CONFIG_DM_ZERO=y
CONFIG_DM_MULTIPATH=y
CONFIG_DM_MULTIPATH_QL=y
CONFIG_DM_MULTIPATH_ST=y
CONFIG_DM_DELAY=y
CONFIG_DM_UEVENT=y
# CONFIG_DM_FLAKEY is not set
# CONFIG_DM_VERITY is not set
# CONFIG_TARGET_CORE is not set
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
# CONFIG_FIREWIRE_NOSY is not set
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
CONFIG_IEEE802154_DRIVERS=y
CONFIG_IEEE802154_FAKEHARD=y
CONFIG_IFB=y
# CONFIG_NET_TEAM is not set
CONFIG_MACVLAN=y
CONFIG_MACVTAP=y
CONFIG_NETCONSOLE=y
CONFIG_NETCONSOLE_DYNAMIC=y
CONFIG_NETPOLL=y
# CONFIG_NETPOLL_TRAP is not set
CONFIG_NET_POLL_CONTROLLER=y
CONFIG_TUN=y
CONFIG_VETH=y
CONFIG_VIRTIO_NET=y
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
# CONFIG_ARCNET_COM20020_CS is not set
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
# CONFIG_ATM_NICSTAR is not set
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
CONFIG_ETHERNET=y
CONFIG_MDIO=y
CONFIG_NET_VENDOR_3COM=y
# CONFIG_PCMCIA_3C574 is not set
# CONFIG_PCMCIA_3C589 is not set
# CONFIG_VORTEX is not set
# CONFIG_TYPHOON is not set
CONFIG_NET_VENDOR_ADAPTEC=y
# CONFIG_ADAPTEC_STARFIRE is not set
CONFIG_NET_VENDOR_ALTEON=y
CONFIG_ACENIC=y
# CONFIG_ACENIC_OMIT_TIGON_I is not set
CONFIG_NET_VENDOR_AMD=y
# CONFIG_AMD8111_ETH is not set
# CONFIG_PCNET32 is not set
# CONFIG_PCMCIA_NMCLAN is not set
CONFIG_NET_VENDOR_ATHEROS=y
# CONFIG_ATL2 is not set
CONFIG_ATL1=y
CONFIG_ATL1E=y
CONFIG_ATL1C=y
CONFIG_NET_VENDOR_BROADCOM=y
# CONFIG_B44 is not set
CONFIG_BNX2=y
CONFIG_CNIC=y
CONFIG_TIGON3=y
CONFIG_BNX2X=y
CONFIG_NET_VENDOR_BROCADE=y
# CONFIG_BNA is not set
# CONFIG_NET_CALXEDA_XGMAC is not set
CONFIG_NET_VENDOR_CHELSIO=y
CONFIG_CHELSIO_T1=y
CONFIG_CHELSIO_T1_1G=y
CONFIG_CHELSIO_T3=y
CONFIG_CHELSIO_T4=y
# CONFIG_CHELSIO_T4VF is not set
CONFIG_NET_VENDOR_CISCO=y
CONFIG_ENIC=y
# CONFIG_DNET is not set
CONFIG_NET_VENDOR_DEC=y
# CONFIG_NET_TULIP is not set
CONFIG_NET_VENDOR_DLINK=y
# CONFIG_DE600 is not set
# CONFIG_DE620 is not set
CONFIG_DL2K=y
# CONFIG_SUNDANCE is not set
CONFIG_NET_VENDOR_EMULEX=y
CONFIG_BE2NET=y
CONFIG_NET_VENDOR_EXAR=y
CONFIG_S2IO=y
CONFIG_VXGE=y
# CONFIG_VXGE_DEBUG_TRACE_ALL is not set
CONFIG_NET_VENDOR_FUJITSU=y
# CONFIG_PCMCIA_FMVJ18X is not set
CONFIG_NET_VENDOR_HP=y
# CONFIG_HP100 is not set
CONFIG_NET_VENDOR_INTEL=y
# CONFIG_E100 is not set
CONFIG_E1000=y
CONFIG_E1000E=y
CONFIG_IGB=y
CONFIG_IGB_DCA=y
# CONFIG_IGB_PTP is not set
CONFIG_IGBVF=y
CONFIG_IXGB=y
CONFIG_IXGBE=y
CONFIG_IXGBE_HWMON=y
CONFIG_IXGBE_DCA=y
CONFIG_IXGBE_DCB=y
# CONFIG_IXGBE_PTP is not set
CONFIG_IXGBEVF=y
CONFIG_NET_VENDOR_I825XX=y
# CONFIG_ZNET is not set
CONFIG_IP1000=y
CONFIG_JME=y
CONFIG_NET_VENDOR_MARVELL=y
CONFIG_SKGE=y
CONFIG_SKGE_DEBUG=y
# CONFIG_SKGE_GENESIS is not set
CONFIG_SKY2=y
CONFIG_SKY2_DEBUG=y
CONFIG_NET_VENDOR_MELLANOX=y
CONFIG_MLX4_EN=y
CONFIG_MLX4_EN_DCB=y
CONFIG_MLX4_CORE=y
CONFIG_MLX4_DEBUG=y
CONFIG_NET_VENDOR_MICREL=y
# CONFIG_KS8842 is not set
# CONFIG_KS8851 is not set
# CONFIG_KS8851_MLL is not set
# CONFIG_KSZ884X_PCI is not set
CONFIG_NET_VENDOR_MICROCHIP=y
# CONFIG_ENC28J60 is not set
CONFIG_NET_VENDOR_MYRI=y
CONFIG_MYRI10GE=y
CONFIG_MYRI10GE_DCA=y
# CONFIG_FEALNX is not set
CONFIG_NET_VENDOR_NATSEMI=y
# CONFIG_NATSEMI is not set
CONFIG_NS83820=y
CONFIG_NET_VENDOR_8390=y
# CONFIG_PCMCIA_AXNET is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_PCMCIA_PCNET is not set
CONFIG_NET_VENDOR_NVIDIA=y
# CONFIG_FORCEDETH is not set
CONFIG_NET_VENDOR_OKI=y
# CONFIG_PCH_GBE is not set
# CONFIG_ETHOC is not set
CONFIG_NET_PACKET_ENGINE=y
CONFIG_HAMACHI=y
CONFIG_YELLOWFIN=y
CONFIG_NET_VENDOR_QLOGIC=y
CONFIG_QLA3XXX=y
CONFIG_QLCNIC=y
CONFIG_QLGE=y
CONFIG_NETXEN_NIC=y
CONFIG_NET_VENDOR_REALTEK=y
# CONFIG_ATP is not set
# CONFIG_8139CP is not set
# CONFIG_8139TOO is not set
CONFIG_R8169=y
CONFIG_NET_VENDOR_RDC=y
# CONFIG_R6040 is not set
CONFIG_NET_VENDOR_SEEQ=y
# CONFIG_SEEQ8005 is not set
CONFIG_NET_VENDOR_SILAN=y
# CONFIG_SC92031 is not set
CONFIG_NET_VENDOR_SIS=y
# CONFIG_SIS900 is not set
CONFIG_SIS190=y
CONFIG_SFC=y
CONFIG_SFC_MTD=y
CONFIG_SFC_MCDI_MON=y
CONFIG_SFC_SRIOV=y
CONFIG_NET_VENDOR_SMSC=y
# CONFIG_PCMCIA_SMC91C92 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SMSC9420 is not set
CONFIG_NET_VENDOR_STMICRO=y
# CONFIG_STMMAC_ETH is not set
CONFIG_NET_VENDOR_SUN=y
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
CONFIG_NIU=y
CONFIG_NET_VENDOR_TEHUTI=y
CONFIG_TEHUTI=y
CONFIG_NET_VENDOR_TI=y
# CONFIG_TLAN is not set
CONFIG_NET_VENDOR_VIA=y
# CONFIG_VIA_RHINE is not set
CONFIG_VIA_VELOCITY=y
CONFIG_NET_VENDOR_WIZNET=y
# CONFIG_WIZNET_W5100 is not set
# CONFIG_WIZNET_W5300 is not set
CONFIG_NET_VENDOR_XIRCOM=y
# CONFIG_PCMCIA_XIRC2PS is not set
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
CONFIG_USB_NET_CDCETHER=y
CONFIG_USB_NET_CDC_EEM=y
CONFIG_USB_NET_CDC_NCM=y
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
# CONFIG_USB_NET_CX82310_ETH is not set
# CONFIG_USB_NET_KALMIA is not set
# CONFIG_USB_NET_QMI_WWAN is not set
CONFIG_USB_HSO=y
CONFIG_USB_NET_INT51X1=y
CONFIG_USB_CDC_PHONET=y
CONFIG_USB_IPHETH=y
CONFIG_USB_SIERRA_NET=y
# CONFIG_USB_VL600 is not set
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
CONFIG_ATH_COMMON=y
# CONFIG_ATH_DEBUG is not set
CONFIG_ATH5K=y
# CONFIG_ATH5K_DEBUG is not set
# CONFIG_ATH5K_TRACER is not set
CONFIG_ATH5K_PCI=y
CONFIG_ATH9K_HW=y
CONFIG_ATH9K_COMMON=y
CONFIG_ATH9K_BTCOEX_SUPPORT=y
CONFIG_ATH9K=y
CONFIG_ATH9K_PCI=y
# CONFIG_ATH9K_AHB is not set
# CONFIG_ATH9K_DEBUGFS is not set
CONFIG_ATH9K_RATE_CONTROL=y
CONFIG_ATH9K_HTC=y
# CONFIG_ATH9K_HTC_DEBUGFS is not set
# CONFIG_CARL9170 is not set
# CONFIG_ATH6KL is not set
CONFIG_B43=y
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
CONFIG_B43_PCMCIA=y
CONFIG_B43_SDIO=y
CONFIG_B43_PIO=y
# CONFIG_B43_PHY_N is not set
CONFIG_B43_PHY_LP=y
# CONFIG_B43_PHY_HT is not set
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
# CONFIG_BRCMFMAC is not set
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

#
# Debugging Options
#
# CONFIG_IWLWIFI_DEBUG is not set
# CONFIG_IWLWIFI_DEVICE_TRACING is not set
CONFIG_IWLWIFI_P2P=y
# CONFIG_IWLWIFI_EXPERIMENTAL_MFP is not set
CONFIG_IWLEGACY=y
# CONFIG_IWL4965 is not set
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
# CONFIG_RT2800USB_RT53XX is not set
# CONFIG_RT2800USB_UNKNOWN is not set
CONFIG_RT2800_LIB=y
CONFIG_RT2X00_LIB_PCI=y
CONFIG_RT2X00_LIB_USB=y
CONFIG_RT2X00_LIB=y
CONFIG_RT2X00_LIB_FIRMWARE=y
CONFIG_RT2X00_LIB_CRYPTO=y
CONFIG_RT2X00_LIB_LEDS=y
# CONFIG_RT2X00_DEBUG is not set
# CONFIG_RTL8192CE is not set
# CONFIG_RTL8192SE is not set
# CONFIG_RTL8192DE is not set
# CONFIG_RTL8192CU is not set
# CONFIG_WL_TI is not set
CONFIG_ZD1211RW=y
# CONFIG_ZD1211RW_DEBUG is not set
# CONFIG_MWIFIEX is not set

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
CONFIG_WAN_ROUTER_DRIVERS=y
CONFIG_CYCLADES_SYNC=y
# CONFIG_CYCLOMX_X25 is not set
CONFIG_SBNI=y
# CONFIG_SBNI_MULTILINE is not set
CONFIG_XEN_NETDEV_FRONTEND=y
# CONFIG_XEN_NETDEV_BACKEND is not set
CONFIG_VMXNET3=y
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
# CONFIG_KEYBOARD_OMAP4 is not set
CONFIG_KEYBOARD_XTKBD=y
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
CONFIG_MOUSE_PS2_ELANTECH=y
CONFIG_MOUSE_PS2_SENTELIC=y
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
CONFIG_MOUSE_SERIAL=y
CONFIG_MOUSE_APPLETOUCH=y
CONFIG_MOUSE_BCM5974=y
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
# CONFIG_TABLET_USB_HANWANG is not set
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
# CONFIG_TOUCHSCREEN_EGALAX is not set
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
CONFIG_GAMEPORT=y
CONFIG_GAMEPORT_NS558=y
CONFIG_GAMEPORT_L4=y
CONFIG_GAMEPORT_EMU10K1=y
CONFIG_GAMEPORT_FM801=y

#
# Character devices
#
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
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_FIX_EARLYCON_MEM=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_SERIAL_8250_PNP=y
CONFIG_SERIAL_8250_CS=y
CONFIG_SERIAL_8250_NR_UARTS=32
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_MANY_PORTS=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
# CONFIG_SERIAL_8250_DETECT_IRQ is not set
CONFIG_SERIAL_8250_RSA=y

#
# Non-8250 serial port support
#
CONFIG_SERIAL_MAX3100=y
# CONFIG_SERIAL_MAX3107 is not set
# CONFIG_SERIAL_MFD_HSU is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
CONFIG_SERIAL_JSM=y
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_IFX6X60 is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_XILINX_PS_UART is not set
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
CONFIG_TCG_NSC=y
CONFIG_TCG_ATMEL=y
CONFIG_TCG_INFINEON=y
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
# CONFIG_I2C_DESIGNWARE_PCI is not set
# CONFIG_I2C_EG20T is not set
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
# CONFIG_I2C_DIOLAN_U2C is not set
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
# CONFIG_SPI_PXA2XX_PCI is not set
# CONFIG_SPI_TOPCLIFF_PCH is not set
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
# CONFIG_PPS_CLIENT_PARPORT is not set
# CONFIG_PPS_CLIENT_GPIO is not set

#
# PPS generators support
#

#
# PTP clock support
#
# CONFIG_PTP_1588_CLOCK is not set
CONFIG_ARCH_WANT_OPTIONAL_GPIOLIB=y
CONFIG_GPIOLIB=y
# CONFIG_DEBUG_GPIO is not set
# CONFIG_GPIO_SYSFS is not set

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
# CONFIG_GPIO_IT8761E is not set
# CONFIG_GPIO_SCH is not set
# CONFIG_GPIO_ICH is not set
# CONFIG_GPIO_VX855 is not set

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
# CONFIG_GPIO_PCH is not set
# CONFIG_GPIO_ML_IOH is not set
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
# CONFIG_CHARGER_SMB347 is not set
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
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
CONFIG_SENSORS_ADT7475=y
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
CONFIG_SENSORS_K10TEMP=y
# CONFIG_SENSORS_FAM15H_POWER is not set
CONFIG_SENSORS_ASB100=y
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
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
# CONFIG_SENSORS_LINEAGE is not set
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
# CONFIG_SENSORS_LTC4151 is not set
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
# CONFIG_SENSORS_LTC4261 is not set
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX1111=y
# CONFIG_SENSORS_MAX16065 is not set
CONFIG_SENSORS_MAX1619=y
# CONFIG_SENSORS_MAX1668 is not set
# CONFIG_SENSORS_MAX6639 is not set
# CONFIG_SENSORS_MAX6642 is not set
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MCP3021 is not set
# CONFIG_SENSORS_NTC_THERMISTOR is not set
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
# CONFIG_SENSORS_SHT15 is not set
# CONFIG_SENSORS_SHT21 is not set
CONFIG_SENSORS_SIS5595=y
# CONFIG_SENSORS_SMM665 is not set
CONFIG_SENSORS_DME1737=y
CONFIG_SENSORS_EMC1403=y
# CONFIG_SENSORS_EMC2103 is not set
# CONFIG_SENSORS_EMC6W201 is not set
CONFIG_SENSORS_SMSC47M1=y
CONFIG_SENSORS_SMSC47M192=y
CONFIG_SENSORS_SMSC47B397=y
# CONFIG_SENSORS_SCH56XX_COMMON is not set
# CONFIG_SENSORS_SCH5627 is not set
# CONFIG_SENSORS_SCH5636 is not set
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
CONFIG_SENSORS_ADS7871=y
CONFIG_SENSORS_AMC6821=y
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
# CONFIG_SENSORS_W83795 is not set
CONFIG_SENSORS_W83L785TS=y
CONFIG_SENSORS_W83L786NG=y
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
CONFIG_SENSORS_APPLESMC=y

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
CONFIG_SENSORS_ATK0110=y
CONFIG_THERMAL=y
CONFIG_THERMAL_HWMON=y
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
# CONFIG_F71808E_WDT is not set
# CONFIG_SP5100_TCO is not set
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
# CONFIG_NV_TCO is not set
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
# CONFIG_XEN_WDT is not set

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
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
# CONFIG_BCMA is not set

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
# CONFIG_MFD_88PM860X is not set
# CONFIG_MFD_88PM800 is not set
# CONFIG_MFD_88PM805 is not set
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
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
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
# CONFIG_PMIC_DA903X is not set
# CONFIG_MFD_DA9052_SPI is not set
# CONFIG_MFD_DA9052_I2C is not set
# CONFIG_PMIC_ADP5520 is not set
# CONFIG_MFD_MAX77686 is not set
# CONFIG_MFD_MAX77693 is not set
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
# CONFIG_MFD_WL1273_CORE is not set
# CONFIG_MFD_TPS65090 is not set
# CONFIG_MFD_AAT2870_CORE is not set
# CONFIG_MFD_RC5T583 is not set
# CONFIG_MFD_PALMAS is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
# CONFIG_REGULATOR_VIRTUAL_CONSUMER is not set
CONFIG_REGULATOR_USERSPACE_CONSUMER=y
# CONFIG_REGULATOR_GPIO is not set
# CONFIG_REGULATOR_AD5398 is not set
# CONFIG_REGULATOR_ISL6271A is not set
CONFIG_REGULATOR_MAX1586=y
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
# CONFIG_REGULATOR_MAX8952 is not set
CONFIG_REGULATOR_LP3971=y
# CONFIG_REGULATOR_LP3972 is not set
# CONFIG_REGULATOR_LP872X is not set
CONFIG_REGULATOR_PCF50633=y
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

#
# Media drivers
#

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
CONFIG_DRM_TTM=y
CONFIG_DRM_TDFX=y
CONFIG_DRM_R128=y
CONFIG_DRM_RADEON=y
CONFIG_DRM_RADEON_KMS=y
# CONFIG_DRM_NOUVEAU is not set

#
# I2C encoder or helper chips
#
# CONFIG_DRM_I2C_CH7006 is not set
# CONFIG_DRM_I2C_SIL164 is not set
# CONFIG_DRM_I810 is not set
CONFIG_DRM_I915=y
CONFIG_DRM_I915_KMS=y
CONFIG_DRM_MGA=y
CONFIG_DRM_SIS=y
CONFIG_DRM_VIA=y
CONFIG_DRM_SAVAGE=y
# CONFIG_DRM_VMWGFX is not set
# CONFIG_DRM_GMA500 is not set
# CONFIG_DRM_UDL is not set
# CONFIG_DRM_AST is not set
# CONFIG_DRM_MGAG200 is not set
# CONFIG_DRM_CIRRUS_QEMU is not set
# CONFIG_STUB_POULSBO is not set
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
# CONFIG_FB_VIA_X_COMPATIBILITY is not set
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
# CONFIG_FB_UDL is not set
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
CONFIG_BACKLIGHT_PROGEAR=y
# CONFIG_BACKLIGHT_APPLE is not set
# CONFIG_BACKLIGHT_SAHARA is not set
# CONFIG_BACKLIGHT_ADP8860 is not set
# CONFIG_BACKLIGHT_ADP8870 is not set
# CONFIG_BACKLIGHT_PCF50633 is not set
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
# CONFIG_SND_ALOOP is not set
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
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE=y
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
# CONFIG_SND_LOLA is not set
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
# CONFIG_SND_USB_6FIRE is not set
CONFIG_SND_FIREWIRE=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
# CONFIG_SND_ISIGHT is not set
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
# CONFIG_HID_BATTERY_STRENGTH is not set
CONFIG_HIDRAW=y
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
CONFIG_HID_A4TECH=y
# CONFIG_HID_ACRUX is not set
CONFIG_HID_APPLE=y
# CONFIG_HID_AUREAL is not set
CONFIG_HID_BELKIN=y
CONFIG_HID_CHERRY=y
CONFIG_HID_CHICONY=y
CONFIG_HID_PRODIKEYS=y
CONFIG_HID_CYPRESS=y
CONFIG_HID_DRAGONRISE=y
CONFIG_DRAGONRISE_FF=y
# CONFIG_HID_EMS_FF is not set
CONFIG_HID_EZKEY=y
# CONFIG_HID_HOLTEK is not set
# CONFIG_HID_KEYTOUCH is not set
CONFIG_HID_KYE=y
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
CONFIG_HID_GYRATION=y
CONFIG_HID_TWINHAN=y
CONFIG_HID_KENSINGTON=y
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LENOVO_TPKBD is not set
CONFIG_HID_LOGITECH=y
CONFIG_HID_LOGITECH_DJ=m
CONFIG_LOGITECH_FF=y
CONFIG_LOGIRUMBLEPAD2_FF=y
CONFIG_LOGIG940_FF=y
CONFIG_LOGIWHEELS_FF=y
CONFIG_HID_MICROSOFT=y
CONFIG_HID_MONTEREY=y
# CONFIG_HID_MULTITOUCH is not set
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
CONFIG_HID_ROCCAT=y
# CONFIG_HID_SAITEK is not set
CONFIG_HID_SAMSUNG=y
CONFIG_HID_SONY=y
# CONFIG_HID_SPEEDLINK is not set
CONFIG_HID_SUNPLUS=y
CONFIG_HID_GREENASIA=y
CONFIG_GREENASIA_FF=y
CONFIG_HID_SMARTJOYPLUS=y
CONFIG_SMARTJOYPLUS_FF=y
# CONFIG_HID_TIVO is not set
CONFIG_HID_TOPSEED=y
CONFIG_HID_THRUSTMASTER=y
CONFIG_THRUSTMASTER_FF=y
CONFIG_HID_ZEROPLUS=y
CONFIG_ZEROPLUS_FF=y
CONFIG_HID_ZYDACRON=y

#
# USB HID support
#
CONFIG_USB_HID=y
CONFIG_HID_PID=y
CONFIG_USB_HIDDEV=y
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
# CONFIG_USB_STORAGE_REALTEK is not set
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
# CONFIG_USB_STORAGE_ENE_UB6250 is not set
# CONFIG_USB_UAS is not set
# CONFIG_USB_LIBUSUAL is not set

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
CONFIG_USB_EZUSB=y
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
CONFIG_USB_SERIAL_ZIO=y
# CONFIG_USB_SERIAL_SSU100 is not set
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
# CONFIG_USB_YUREX is not set

#
# USB Physical Layer drivers
#
# CONFIG_USB_ISP1301 is not set
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
CONFIG_USB_R8A66597=y
# CONFIG_USB_MV_UDC is not set
# CONFIG_USB_M66592 is not set
# CONFIG_USB_AMD5536UDC is not set
# CONFIG_USB_NET2272 is not set
# CONFIG_USB_NET2280 is not set
# CONFIG_USB_GOKU is not set
# CONFIG_USB_EG20T is not set
# CONFIG_USB_DUMMY_HCD is not set
CONFIG_USB_GADGET_DUALSPEED=y
# CONFIG_USB_ZERO is not set
# CONFIG_USB_AUDIO is not set
# CONFIG_USB_ETH is not set
# CONFIG_USB_G_NCM is not set
# CONFIG_USB_GADGETFS is not set
# CONFIG_USB_FUNCTIONFS is not set
# CONFIG_USB_FILE_STORAGE is not set
# CONFIG_USB_MASS_STORAGE is not set
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
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
CONFIG_MMC_SPI=y
CONFIG_MMC_SDRICOH_CS=y
CONFIG_MMC_CB710=y
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_VUB300 is not set
# CONFIG_MMC_USHC is not set
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
# CONFIG_MEMSTICK_R592 is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
# CONFIG_LEDS_LM3530 is not set
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
# CONFIG_LEDS_LM3556 is not set
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
CONFIG_INFINIBAND_ISER=y
CONFIG_EDAC=y

#
# Reporting subsystems
#
CONFIG_EDAC_LEGACY_SYSFS=y
# CONFIG_EDAC_DEBUG is not set
CONFIG_EDAC_DECODE_MCE=y
# CONFIG_EDAC_MCE_INJ is not set
CONFIG_EDAC_MM_EDAC=y
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
# CONFIG_EDAC_I7300 is not set
# CONFIG_EDAC_SBRIDGE is not set
CONFIG_RTC_LIB=y
CONFIG_RTC_CLASS=y
CONFIG_RTC_HCTOSYS=y
CONFIG_RTC_HCTOSYS_DEVICE="rtc0"
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
CONFIG_RTC_DRV_PCF50633=y

#
# on-CPU RTC drivers
#
CONFIG_DMADEVICES=y
# CONFIG_DMADEVICES_DEBUG is not set

#
# DMA Devices
#
# CONFIG_INTEL_MID_DMAC is not set
CONFIG_INTEL_IOATDMA=y
# CONFIG_TIMB_DMA is not set
# CONFIG_PCH_DMA is not set
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
CONFIG_UIO_AEC=y
CONFIG_UIO_SERCOS3=y
CONFIG_UIO_PCI_GENERIC=y
CONFIG_UIO_NETX=y
# CONFIG_VFIO is not set
CONFIG_VIRTIO=y
CONFIG_VIRTIO_RING=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
CONFIG_VIRTIO_BALLOON=y
# CONFIG_VIRTIO_MMIO is not set

#
# Microsoft Hyper-V guest support
#
# CONFIG_HYPERV is not set

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
CONFIG_XEN_GNTDEV=m
CONFIG_XEN_GRANT_DEV_ALLOC=m
CONFIG_SWIOTLB_XEN=y
CONFIG_XEN_PCIDEV_BACKEND=m
CONFIG_XEN_PRIVCMD=y
CONFIG_XEN_ACPI_PROCESSOR=m
# CONFIG_XEN_MCE_LOG is not set
CONFIG_STAGING=y
# CONFIG_ET131X is not set
# CONFIG_SLICOSS is not set
# CONFIG_USBIP_CORE is not set
# CONFIG_W35UND is not set
# CONFIG_PRISM2_USB is not set
# CONFIG_ECHO is not set
# CONFIG_COMEDI is not set
# CONFIG_ASUS_OLED is not set
# CONFIG_PANEL is not set
# CONFIG_R8187SE is not set
# CONFIG_RTL8192U is not set
# CONFIG_RTLLIB is not set
# CONFIG_R8712U is not set
# CONFIG_RTS_PSTOR is not set
# CONFIG_RTS5139 is not set
# CONFIG_TRANZPORT is not set
# CONFIG_IDE_PHISON is not set
# CONFIG_LINE6_USB is not set
# CONFIG_USB_SERIAL_QUATECH2 is not set
# CONFIG_VT6655 is not set
# CONFIG_VT6656 is not set
# CONFIG_DX_SEP is not set
# CONFIG_ZSMALLOC is not set
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
# CONFIG_SPEAKUP is not set
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
# CONFIG_ANDROID is not set
CONFIG_PHONE=y
CONFIG_PHONE_IXJ=y
CONFIG_PHONE_IXJ_PCMCIA=y
# CONFIG_USB_WPAN_HCD is not set
# CONFIG_USB_G_CCG is not set
# CONFIG_IPACK_BUS is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_CSR_WIFI is not set
CONFIG_X86_PLATFORM_DEVICES=y
CONFIG_ACER_WMI=y
CONFIG_ACERHDF=y
CONFIG_ASUS_LAPTOP=y
CONFIG_DELL_LAPTOP=y
CONFIG_DELL_WMI=y
# CONFIG_DELL_WMI_AIO is not set
CONFIG_FUJITSU_LAPTOP=y
# CONFIG_FUJITSU_LAPTOP_DEBUG is not set
# CONFIG_FUJITSU_TABLET is not set
# CONFIG_AMILO_RFKILL is not set
# CONFIG_HP_ACCEL is not set
CONFIG_HP_WMI=y
CONFIG_MSI_LAPTOP=y
CONFIG_PANASONIC_LAPTOP=y
CONFIG_COMPAL_LAPTOP=y
CONFIG_SONY_LAPTOP=y
CONFIG_SONYPI_COMPAT=y
# CONFIG_IDEAPAD_LAPTOP is not set
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
# CONFIG_ASUS_WMI is not set
CONFIG_ACPI_WMI=y
CONFIG_MSI_WMI=y
CONFIG_TOPSTAR_LAPTOP=y
CONFIG_ACPI_TOSHIBA=y
CONFIG_TOSHIBA_BT_RFKILL=y
CONFIG_ACPI_CMPC=y
# CONFIG_INTEL_IPS is not set
# CONFIG_IBM_RTL is not set
# CONFIG_XO15_EBOOK is not set
# CONFIG_SAMSUNG_LAPTOP is not set
# CONFIG_MXM_WMI is not set
# CONFIG_INTEL_OAKTRAIL is not set
# CONFIG_SAMSUNG_Q10 is not set
# CONFIG_APPLE_GMUX is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_I8253_LOCK=y
CONFIG_CLKBLD_I8253=y
CONFIG_IOMMU_API=y
CONFIG_IOMMU_SUPPORT=y
CONFIG_AMD_IOMMU=y
# CONFIG_AMD_IOMMU_STATS is not set
# CONFIG_AMD_IOMMU_V2 is not set
# CONFIG_INTEL_IOMMU is not set
# CONFIG_IRQ_REMAP is not set

#
# Remoteproc drivers (EXPERIMENTAL)
#

#
# Rpmsg drivers (EXPERIMENTAL)
#
# CONFIG_VIRT_DRIVERS is not set
# CONFIG_PM_DEVFREQ is not set
# CONFIG_EXTCON is not set
# CONFIG_MEMORY is not set
# CONFIG_IIO is not set
# CONFIG_VME_BUS is not set
# CONFIG_PWM is not set

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
CONFIG_EXT4_FS_XATTR=y
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
# CONFIG_FANOTIFY is not set
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
# CONFIG_SQUASHFS_XATTR is not set
CONFIG_SQUASHFS_ZLIB=y
# CONFIG_SQUASHFS_LZO is not set
# CONFIG_SQUASHFS_XZ is not set
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
# CONFIG_CIFS_DEBUG2 is not set
CONFIG_CIFS_DFS_UPCALL=y
# CONFIG_CIFS_FSCACHE is not set
# CONFIG_CIFS_ACL is not set
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
# CONFIG_9P_FS_POSIX_ACL is not set
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
# CONFIG_DEBUG_SECTION_MISMATCH is not set
CONFIG_DEBUG_KERNEL=y
CONFIG_DEBUG_SHIRQ=y
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_HARDLOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
CONFIG_DETECT_HUNG_TASK=y
CONFIG_DEFAULT_HUNG_TASK_TIMEOUT=120
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
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
CONFIG_DEBUG_LOCK_ALLOC=y
CONFIG_PROVE_LOCKING=y
# CONFIG_PROVE_RCU is not set
# CONFIG_SPARSE_RCU_POINTER is not set
CONFIG_LOCKDEP=y
CONFIG_LOCK_STAT=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_TRACE_IRQFLAGS=y
# CONFIG_DEBUG_ATOMIC_SLEEP is not set
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_STACKTRACE=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
# CONFIG_DEBUG_INFO is not set
CONFIG_DEBUG_VM=y
CONFIG_DEBUG_VIRTUAL=y
CONFIG_DEBUG_WRITECOUNT=y
CONFIG_DEBUG_MEMORY_INIT=y
CONFIG_DEBUG_LIST=y
# CONFIG_TEST_LIST_SORT is not set
CONFIG_DEBUG_SG=y
CONFIG_DEBUG_NOTIFIERS=y
CONFIG_DEBUG_CREDENTIALS=y
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
CONFIG_BOOT_PRINTK_DELAY=y
# CONFIG_RCU_TORTURE_TEST is not set
CONFIG_RCU_CPU_STALL_TIMEOUT=60
# CONFIG_RCU_CPU_STALL_INFO is not set
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
CONFIG_HAVE_FTRACE_MCOUNT_RECORD=y
CONFIG_HAVE_SYSCALL_TRACEPOINTS=y
CONFIG_HAVE_C_RECORDMCOUNT=y
CONFIG_TRACER_MAX_TRACE=y
CONFIG_RING_BUFFER=y
CONFIG_EVENT_TRACING=y
CONFIG_EVENT_POWER_TRACING_DEPRECATED=y
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
CONFIG_BRANCH_PROFILE_NONE=y
# CONFIG_PROFILE_ANNOTATED_BRANCHES is not set
# CONFIG_PROFILE_ALL_BRANCHES is not set
# CONFIG_STACK_TRACER is not set
CONFIG_BLK_DEV_IO_TRACE=y
CONFIG_KPROBE_EVENT=y
# CONFIG_UPROBE_EVENT is not set
CONFIG_PROBE_EVENTS=y
CONFIG_DYNAMIC_FTRACE=y
# CONFIG_FUNCTION_PROFILER is not set
CONFIG_FTRACE_MCOUNT_RECORD=y
CONFIG_FTRACE_SELFTEST=y
CONFIG_FTRACE_STARTUP_TEST=y
# CONFIG_EVENT_TRACE_TEST_SYSCALLS is not set
CONFIG_MMIOTRACE=y
# CONFIG_MMIOTRACE_TEST is not set
# CONFIG_RING_BUFFER_BENCHMARK is not set
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
# CONFIG_DEBUG_SET_MODULE_RONX is not set
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
# CONFIG_DEBUG_NMI_SELFTEST is not set

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
CONFIG_LSM_MMAP_MIN_ADDR=65536
CONFIG_SECURITY_SELINUX=y
# CONFIG_SECURITY_SELINUX_BOOTPARAM is not set
# CONFIG_SECURITY_SELINUX_DISABLE is not set
CONFIG_SECURITY_SELINUX_DEVELOP=y
CONFIG_SECURITY_SELINUX_AVC_STATS=y
CONFIG_SECURITY_SELINUX_CHECKREQPROT_VALUE=1
# CONFIG_SECURITY_SELINUX_POLICYDB_VERSION_MAX is not set
CONFIG_SECURITY_TOMOYO=y
CONFIG_SECURITY_TOMOYO_MAX_ACCEPT_ENTRY=2048
CONFIG_SECURITY_TOMOYO_MAX_AUDIT_LOG=1024
# CONFIG_SECURITY_TOMOYO_OMIT_USERSPACE_LOADER is not set
CONFIG_SECURITY_TOMOYO_POLICY_LOADER="/sbin/tomoyo-init"
CONFIG_SECURITY_TOMOYO_ACTIVATION_TRIGGER="/sbin/init"
# CONFIG_SECURITY_APPARMOR is not set
# CONFIG_SECURITY_YAMA is not set
# CONFIG_IMA is not set
# CONFIG_EVM is not set
# CONFIG_DEFAULT_SECURITY_SELINUX is not set
# CONFIG_DEFAULT_SECURITY_TOMOYO is not set
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
CONFIG_CRYPTO_MANAGER_DISABLE_TESTS=y
CONFIG_CRYPTO_GF128MUL=y
CONFIG_CRYPTO_NULL=y
CONFIG_CRYPTO_PCRYPT=y
CONFIG_CRYPTO_WORKQUEUE=y
CONFIG_CRYPTO_CRYPTD=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_TEST=m
CONFIG_CRYPTO_ABLK_HELPER_X86=y

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
CONFIG_CRYPTO_CRC32C_INTEL=y
CONFIG_CRYPTO_GHASH=y
CONFIG_CRYPTO_MD4=y
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_MICHAEL_MIC=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_SHA1_SSSE3 is not set
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
# CONFIG_CRYPTO_BLOWFISH_X86_64 is not set
CONFIG_CRYPTO_CAMELLIA=y
# CONFIG_CRYPTO_CAMELLIA_X86_64 is not set
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST6=y
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
# CONFIG_CRYPTO_TWOFISH_X86_64_3WAY is not set
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
# CONFIG_CRYPTO_USER_API_HASH is not set
# CONFIG_CRYPTO_USER_API_SKCIPHER is not set
CONFIG_CRYPTO_HW=y
CONFIG_CRYPTO_DEV_PADLOCK=y
CONFIG_CRYPTO_DEV_PADLOCK_AES=y
CONFIG_CRYPTO_DEV_PADLOCK_SHA=y
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_HAVE_KVM_MSI=y
CONFIG_VIRTUALIZATION=y
CONFIG_KVM=y
CONFIG_KVM_INTEL=y
CONFIG_KVM_AMD=y
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VHOST_NET=y
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
# CONFIG_CRC8 is not set
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
# CONFIG_CORDIC is not set
# CONFIG_DDR is not set

--C7zPtVaVf+AK4Oqc--
