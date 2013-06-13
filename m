From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [netlink_lookup] BUG: unable to handle kernel NULL pointer
 dereference at (null)
Date: Thu, 13 Jun 2013 09:22:16 +0800
Message-ID: <20130613012216.GA6788@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Greetings,

I got the below dmesg and the first bad commit is

commit da12c90e099789a63073fc82a19542ce54d4efb9
Author: Gao feng <gaofeng@cn.fujitsu.com>
Date:   Thu Jun 6 14:49:11 2013 +0800

    netlink: Add compare function for netlink_table
    
    As we know, netlink sockets are private resource of
    net namespace, they can communicate with each other
    only when they in the same net namespace. this works
    well until we try to add namespace support for other
    subsystems which use netlink.
    
    Don't like ipv4 and route table.., it is not suited to
    make these subsytems belong to net namespace, Such as
    audit and crypto subsystems,they are more suitable to
    user namespace.
    
    So we must have the ability to make the netlink sockets
    in same user namespace can communicate with each other.
    
    This patch adds a new function pointer "compare" for
    netlink_table, we can decide if the netlink sockets can
    communicate with each other through this netlink_table
    self-defined compare function.
    
    The behavior isn't changed if we don't provide the compare
    function for netlink_table.
    
    Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
    Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
[   75.052517] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   75.053342] IP: [<          (null)>]           (null)
[   75.053342] PGD f015067 PUD f000067 PMD 0 
[   75.053342] Oops: 0010 [#1] 
[   75.053342] CPU: 0 PID: 206 Comm: trinity-child0 Not tainted 3.10.0-rc4-00590-g130d3d6 #32
[   75.053342] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   75.053342] task: ffff88000f0a1840 ti: ffff88000f04c000 task.ti: ffff88000f04c000
[   75.053342] RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
[   75.053342] RSP: 0018:ffff88000f04dc50  EFLAGS: 00010282
[   75.053342] RAX: ffff88000f1d9438 RBX: ffff88000f1d9400 RCX: 0000000022b5ec40
[   75.053342] RDX: 0000000000000000 RSI: ffff88000f1d9400 RDI: ffffffff81dab900
[   75.053342] RBP: ffff88000f04dc78 R08: 0000000000000000 R09: 0000000000000000
[   75.053342] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800000210d0
[   75.053342] R13: ffffffff81dab900 R14: 0000000000000000 R15: 0000000000000000
[   75.053342] FS:  00007fc54dccf700(0000) GS:ffffffff81c9b000(0000) knlGS:0000000000000000
[   75.053342] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   75.053342] CR2: 0000000000000000 CR3: 0000000006eb0000 CR4: 00000000000006b0
[   75.053342] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   75.053342] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   75.053342] Stack:
[   75.053342]  ffffffff818d304f 0000000000000000 ffff88000f1d9400 ffff88000f007600
[   75.053342]  ffff88000f007600 ffff88000f04dcc8 ffffffff818d48ba 0000000000001000
[   75.053342]  0000000000f54220 ffff88000f04dfd8 7fffffffffffffff ffff88000f04dd70
[   75.053342] Call Trace:
[   75.053342]  [<ffffffff818d304f>] ? netlink_lookup+0xaf/0xf0
[   75.053342]  [<ffffffff818d48ba>] netlink_unicast+0xba/0x1d0
[   75.053342]  [<ffffffff818d512a>] netlink_sendmsg+0x32a/0x3e0
[   75.053342]  [<ffffffff818a678b>] sock_aio_write+0xfb/0x130
[   75.053342]  [<ffffffff81100e72>] ? kmem_cache_free+0x32/0x180
[   75.053342]  [<ffffffff811069ea>] do_sync_write+0x7a/0xb0
[   75.053342]  [<ffffffff81106cbd>] vfs_write+0x16d/0x1d0
[   75.053342]  [<ffffffff81106e0d>] SyS_write+0x4d/0xa0
[   75.053342]  [<ffffffff818eefd0>] system_call_fastpath+0x16/0x1b
[   75.053342] Code:  Bad RIP value.
[   75.053342] RIP  [<          (null)>]           (null)
[   75.053342]  RSP <ffff88000f04dc50>
[   75.053342] CR2: 0000000000000000
[   75.099392] ---[ end trace fe29140019c40c80 ]---

git bisect start 130d3d68b52097c7ae081109f700b02776adcb9c dbbffe6898fd0d7bac66ded5d3c58835b13ddefc --
git bisect good 3acfeac351c6ab2fe1139ee13d780729af0c8145  # 19:11     50+  Merge branch 'fec_regulator_suspend_resume'
git bisect good 8764d86100fe58e69877753faa44fc1d9276c624  # 19:24     50+  Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mszeredi/fuse
git bisect good 1612e111e4e565422242727efb59499cce8738e4  # 19:44     50+  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net
git bisect good bd118b6e9509a19bfb82925152d9ae8fa398d567  # 20:02     50+  ibm-ethernet: delete stale MCA and duplicate PSERIES dependency
git bisect good 143554ace8919d5ef3cc8424c0b06dbd3d671b4e  # 22:50     50+  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next
git bisect good 589ebdef7e3107401bf96a9c660753d397329ee9  # 22:59     50+  sh_eth: get R8A777x support out of #ifdef
git bisect good af12fa6e46aa651e7b86a4c4117b562518fef184  # 23:08     50+  net: add napi_id and hash
git bisect good 30f3a40f9a2a2869a560a9cb9ef488d10c803e14  # 23:14     50+  net: remove last caller of skb_tail_offset() and itself
git bisect good 8249152c472e10c18936b774737fd58c60335154  # 23:24     50+  xen-netfront: use skb_partial_csum_set() to simplify the codes
git bisect  bad b41abb42bf62a85a32c41dab873220598a6ee266  # 23:29     10-  net: pass correct parameter to skb_headers_offset_update()
git bisect  bad da12c90e099789a63073fc82a19542ce54d4efb9  # 23:33      2-  netlink: Add compare function for netlink_table
git bisect good 8249152c472e10c18936b774737fd58c60335154  # 23:55    195+  xen-netfront: use skb_partial_csum_set() to simplify the codes
git bisect  bad 130d3d68b52097c7ae081109f700b02776adcb9c  # 23:55      0-  net_sched: psched_ratecfg_precompute() improvements
git bisect good 27016b825ef907d8d8446fc500bb8d23b57546a6  # 00:12    195+  Revert "netlink: Add compare function for netlink_table"
git bisect good 77293e215edef7871a39de4b326f777bc39278ca  # 03:03    195+  Merge branch 'fixes-3.10' of git://git.infradead.org/users/willy/linux-nvme
git bisect good c04efed734409f5a44715b54a6ca1b54b0ccf215  # 06:02    195+  Add linux-next specific files for 20130607

Thanks,
Fengguang

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dmesg-kvm-bens-7896-20130612140322-3.10.0-rc4-00590-g130d3d6-32"

[    0.000000] Initializing cgroup subsys cpu
[    0.000000] Linux version 3.10.0-rc4-00590-g130d3d6 (kbuild@cairo) (gcc version 4.7.2 (Debian 4.7.2-4) ) #32 Wed Jun 12 14:01:46 CST 2013
[    0.000000] Command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-c21-0611/net-next:master/.vmlinuz-130d3d68b52097c7ae081109f700b02776adcb9c-20130612140227-8-bens branch=net-next/master  BOOT_IMAGE=/kernel/x86_64-randconfig-c21-0611/130d3d68b52097c7ae081109f700b02776adcb9c/vmlinuz-3.10.0-rc4-00590-g130d3d6
[    0.000000] e820: BIOS-provided physical RAM map:
[    0.000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000093bff] usable
[    0.000000] BIOS-e820: [mem 0x0000000000093c00-0x000000000009ffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000000f0000-0x00000000000fffff] reserved
[    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000000fffdfff] usable
[    0.000000] BIOS-e820: [mem 0x000000000fffe000-0x000000000fffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000feffc000-0x00000000feffffff] reserved
[    0.000000] BIOS-e820: [mem 0x00000000fffc0000-0x00000000ffffffff] reserved
[    0.000000] debug: ignoring loglevel setting.
[    0.000000] NX (Execute Disable) protection: active
[    0.000000] SMBIOS 2.4 present.
[    0.000000] DMI: Bochs Bochs, BIOS Bochs 01/01/2007
[    0.000000] e820: update [mem 0x00000000-0x00000fff] usable ==> reserved
[    0.000000] e820: remove [mem 0x000a0000-0x000fffff] usable
[    0.000000] No AGP bridge found
[    0.000000] e820: last_pfn = 0xfffe max_arch_pfn = 0x400000000
[    0.000000] Base memory trampoline at [ffff88000008d000] 8d000 size 24576
[    0.000000] init_memory_mapping: [mem 0x00000000-0x000fffff]
[    0.000000]  [mem 0x00000000-0x000fffff] page 4k
[    0.000000] BRK [0x01fea000, 0x01feafff] PGTABLE
[    0.000000] BRK [0x01feb000, 0x01febfff] PGTABLE
[    0.000000] BRK [0x01fec000, 0x01fecfff] PGTABLE
[    0.000000] init_memory_mapping: [mem 0x0e600000-0x0e7fffff]
[    0.000000]  [mem 0x0e600000-0x0e7fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0c000000-0x0e5fffff]
[    0.000000]  [mem 0x0c000000-0x0e5fffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x00100000-0x0bffffff]
[    0.000000]  [mem 0x00100000-0x001fffff] page 4k
[    0.000000]  [mem 0x00200000-0x0bffffff] page 2M
[    0.000000] init_memory_mapping: [mem 0x0e800000-0x0fffdfff]
[    0.000000]  [mem 0x0e800000-0x0fdfffff] page 2M
[    0.000000]  [mem 0x0fe00000-0x0fffdfff] page 4k
[    0.000000] BRK [0x01fed000, 0x01fedfff] PGTABLE
[    0.000000] log_buf_len: 8388608
[    0.000000] early log buf free: 128284(97%)
[    0.000000] RAMDISK: [mem 0x0e8d6000-0x0ffeffff]
[    0.000000] ACPI: RSDP 00000000000fd920 00014 (v00 BOCHS )
[    0.000000] ACPI: RSDT 000000000fffe550 00038 (v01 BOCHS  BXPCRSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: FACP 000000000fffff80 00074 (v01 BOCHS  BXPCFACP 00000001 BXPC 00000001)
[    0.000000] ACPI: DSDT 000000000fffe590 01121 (v01   BXPC   BXDSDT 00000001 INTL 20100528)
[    0.000000] ACPI: FACS 000000000fffff40 00040
[    0.000000] ACPI: SSDT 000000000ffffe40 000FF (v01 BOCHS  BXPCSSDT 00000001 BXPC 00000001)
[    0.000000] ACPI: APIC 000000000ffffd50 00080 (v01 BOCHS  BXPCAPIC 00000001 BXPC 00000001)
[    0.000000] ACPI: HPET 000000000ffffd10 00038 (v01 BOCHS  BXPCHPET 00000001 BXPC 00000001)
[    0.000000] ACPI: SSDT 000000000ffff6c0 00644 (v01   BXPC BXSSDTPC 00000001 INTL 20100528)
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] Zone ranges:
[    0.000000]   DMA32    [mem 0x00001000-0xffffffff]
[    0.000000]   Normal   empty
[    0.000000] Movable zone start for each node
[    0.000000] Early memory node ranges
[    0.000000]   node   0: [mem 0x00001000-0x00092fff]
[    0.000000]   node   0: [mem 0x00100000-0x0fffdfff]
[    0.000000] On node 0 totalpages: 65424
[    0.000000]   DMA32 zone: 1024 pages used for memmap
[    0.000000]   DMA32 zone: 21 pages reserved
[    0.000000]   DMA32 zone: 65424 pages, LIFO batch:15
[    0.000000] ACPI: PM-Timer IO Port: 0xb008
[    0.000000] ACPI: Local APIC address 0xfee00000
[    0.000000] mapped APIC to ffffffffff5fa000 (        fee00000)
[    0.000000] ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
[    0.000000] ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
[    0.000000] ACPI: NR_CPUS/possible_cpus limit of 1 reached.  Processor 1/0x1 ignored.
[    0.000000] ACPI: LAPIC_NMI (acpi_id[0xff] dfl dfl lint[0x1])
[    0.000000] ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
[    0.000000] IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-23
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 00, APIC ID 2, APIC INT 02
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 5 global_irq 5 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 05, APIC ID 2, APIC INT 05
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 09, APIC ID 2, APIC INT 09
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 10 global_irq 10 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0a, APIC ID 2, APIC INT 0a
[    0.000000] ACPI: INT_SRC_OVR (bus 0 bus_irq 11 global_irq 11 high level)
[    0.000000] Int: type 0, pol 1, trig 3, bus 00, IRQ 0b, APIC ID 2, APIC INT 0b
[    0.000000] ACPI: IRQ0 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 01, APIC ID 2, APIC INT 01
[    0.000000] ACPI: IRQ2 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 03, APIC ID 2, APIC INT 03
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 04, APIC ID 2, APIC INT 04
[    0.000000] ACPI: IRQ5 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 06, APIC ID 2, APIC INT 06
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 07, APIC ID 2, APIC INT 07
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 08, APIC ID 2, APIC INT 08
[    0.000000] ACPI: IRQ9 used by override.
[    0.000000] ACPI: IRQ10 used by override.
[    0.000000] ACPI: IRQ11 used by override.
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0c, APIC ID 2, APIC INT 0c
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0d, APIC ID 2, APIC INT 0d
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0e, APIC ID 2, APIC INT 0e
[    0.000000] Int: type 0, pol 0, trig 0, bus 00, IRQ 0f, APIC ID 2, APIC INT 0f
[    0.000000] Using ACPI (MADT) for SMP configuration information
[    0.000000] ACPI: HPET id: 0x8086a201 base: 0xfed00000
[    0.000000] mapped IOAPIC to ffffffffff5f9000 (fec00000)
[    0.000000] nr_irqs_gsi: 40
[    0.000000] e820: [mem 0x10000000-0xfeffbfff] available for PCI devices
[    0.000000] pcpu-alloc: s0 r0 d32768 u32768 alloc=1*32768
[    0.000000] pcpu-alloc: [0] 0 
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 64379
[    0.000000] Kernel command line: hung_task_panic=1 rcutree.rcu_cpu_stall_timeout=100 log_buf_len=8M ignore_loglevel debug sched_debug apic=debug dynamic_printk sysrq_always_enabled panic=10  prompt_ramdisk=0 console=ttyS0,115200 console=tty0 vga=normal  root=/dev/ram0 rw link=/kernel-tests/run-queue/kvm/x86_64-randconfig-c21-0611/net-next:master/.vmlinuz-130d3d68b52097c7ae081109f700b02776adcb9c-20130612140227-8-bens branch=net-next/master  BOOT_IMAGE=/kernel/x86_64-randconfig-c21-0611/130d3d68b52097c7ae081109f700b02776adcb9c/vmlinuz-3.10.0-rc4-00590-g130d3d6
[    0.000000] sysrq: sysrq always enabled.
[    0.000000] PID hash table entries: 1024 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 32768 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 16384 (order: 5, 131072 bytes)
[    0.000000] Checking aperture...
[    0.000000] No AGP bridge found
[    0.000000] Memory: 208752k/262136k available (9154k kernel code, 440k absent, 52944k reserved, 4978k data, 776k init)
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=1, Nodes=1
[    0.000000] NR_IRQS:4352 nr_irqs:256 16
[    0.000000] console [ttyS0] enabled
[    0.000000] ------------------------
[    0.000000] | Locking API testsuite:
[    0.000000] ----------------------------------------------------------------------------
[    0.000000]                                  | spin |wlock |rlock |mutex | wsem | rsem |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]                      A-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]                  A-B-B-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]              A-B-B-C-C-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]              A-B-C-A-B-C deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-B-C-C-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-C-D-B-D-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]          A-B-C-D-B-C-D-A deadlock:failed|failed|  ok  |failed|failed|failed|
[    0.000000]                     double unlock:  ok  |  ok  |failed|  ok  |failed|failed|
[    0.000000]                   initialize held:failed|failed|failed|failed|failed|failed|
[    0.000000]                  bad unlock order:  ok  |  ok  |  ok  |  ok  |  ok  |  ok  |
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]               recursive read-lock:             |  ok  |             |failed|
[    0.000000]            recursive read-lock #2:             |  ok  |             |failed|
[    0.000000]             mixed read-write-lock:             |failed|             |failed|
[    0.000000]             mixed write-read-lock:             |failed|             |failed|
[    0.000000]   --------------------------------------------------------------------------
[    0.000000]      hard-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/12:failed|failed|  ok  |
[    0.000000]      hard-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]      soft-irqs-on + irq-safe-A/21:failed|failed|  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/12:failed|failed|  ok  |
[    0.000000]        sirq-safe-A => hirqs-on/21:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/12:failed|failed|  ok  |
[    0.000000]          hard-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]          soft-safe-A + irqs-on/21:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #1/321:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/123:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/132:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/213:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/231:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/312:failed|failed|  ok  |
[    0.000000]     hard-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]     soft-safe-A + unsafe-B #2/321:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/123:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/132:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/213:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/231:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/312:failed|failed|  ok  |
[    0.000000]       hard-irq lock-inversion/321:failed|failed|  ok  |
[    0.000000]       soft-irq lock-inversion/321:failed|failed|  ok  |
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
[    0.000000] --------------------------------------------------------
[    0.000000] 142 out of 218 testcases failed, as expected. |
[    0.000000] ----------------------------------------------------
[    0.000000] ODEBUG: 8 of 8 active objects replaced
[    0.000000] hpet clockevent registered
[    0.000000] tsc: Fast TSC calibration failed
[    0.000000] tsc: PIT calibration matches HPET. 1 loops
[    0.000000] tsc: Detected 2666.615 MHz processor
[    0.010001] Calibrating delay loop (skipped), value calculated using timer frequency.. 5335.44 BogoMIPS (lpj=8888716)
[    0.013840] pid_max: default: 32768 minimum: 301
[    0.014714] Mount-cache hash table entries: 256
[    0.015732] Initializing cgroup subsys devices
[    0.016680] Initializing cgroup subsys perf_event
[    0.017621] Last level iTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017621] Last level dTLB entries: 4KB 0, 2MB 0, 4MB 0
[    0.017621] tlb_flushall_shift: 6
[    0.020003] CPU: Intel Common KVM processor (fam: 0f, model: 06, stepping: 01)
[    0.021414] ACPI: Core revision 20130328
[    0.022857] ACPI: All ACPI Tables successfully acquired
[    0.024174] Performance Events: unsupported Netburst CPU model 6 no PMU driver, software events only.
[    0.027660] Getting VERSION: 50014
[    0.028281] Getting VERSION: 50014
[    0.028902] Getting ID: 0
[    0.029383] Getting ID: ff000000
[    0.029970] Getting LVT0: 8700
[    0.030007] Getting LVT1: 8400
[    0.030729] enabled ExtINT on CPU#0
[    0.032396] ENABLING IO-APIC IRQs
[    0.033340] init IO_APIC IRQs
[    0.033875]  apic 2 pin 0 not connected
[    0.034571] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.035975] IOAPIC[0]: Set routing entry (2-2 -> 0x30 -> IRQ 0 Mode:0 Active:0 Dest:1)
[    0.036686] IOAPIC[0]: Set routing entry (2-3 -> 0x33 -> IRQ 3 Mode:0 Active:0 Dest:1)
[    0.038080] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.040018] IOAPIC[0]: Set routing entry (2-5 -> 0x35 -> IRQ 5 Mode:1 Active:0 Dest:1)
[    0.041416] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.042805] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.043351] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.044738] IOAPIC[0]: Set routing entry (2-9 -> 0x39 -> IRQ 9 Mode:1 Active:0 Dest:1)
[    0.046684] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    0.048100] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    0.050018] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.051442] IOAPIC[0]: Set routing entry (2-13 -> 0x3d -> IRQ 13 Mode:0 Active:0 Dest:1)
[    0.052861] IOAPIC[0]: Set routing entry (2-14 -> 0x3e -> IRQ 14 Mode:0 Active:0 Dest:1)
[    0.053351] IOAPIC[0]: Set routing entry (2-15 -> 0x3f -> IRQ 15 Mode:0 Active:0 Dest:1)
[    0.054769]  apic 2 pin 16 not connected
[    0.056668]  apic 2 pin 17 not connected
[    0.057366]  apic 2 pin 18 not connected
[    0.058055]  apic 2 pin 19 not connected
[    0.058750]  apic 2 pin 20 not connected
[    0.059445]  apic 2 pin 21 not connected
[    0.060002]  apic 2 pin 22 not connected
[    0.060695]  apic 2 pin 23 not connected
[    0.061535] ..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
[    0.094953] Using local APIC timer interrupts.
[    0.094953] calibrating APIC timer ...
[    0.099999] ... lapic delta = 6249773
[    0.099999] ... PM-Timer delta = 357926
[    0.099999] ... PM-Timer result ok
[    0.099999] ..... delta 6249773
[    0.099999] ..... mult: 268425733
[    0.099999] ..... calibration result: 3333212
[    0.099999] ..... CPU clock speed is 2666.2380 MHz.
[    0.099999] ..... host bus clock speed is 1000.0212 MHz.
[    0.100268] devtmpfs: initialized
[    0.102305] xor: measuring software checksum speed
[    0.133338]    prefetch64-sse: 10120.800 MB/sec
[    0.166669]    generic_sse:  8144.400 MB/sec
[    0.167787] xor: using function: prefetch64-sse (10120.800 MB/sec)
[    0.169419] atomic64 test passed for x86-64 platform with CX8 and with SSE
[    0.170161] regulator-dummy: no parameters
[    0.171325] NET: Registered protocol family 16
[    0.173998] ACPI: bus type PCI registered
[    0.175157] PCI: Using configuration type 1 for base access
[    0.181153] bio: create slab <bio-0> at 0
[    0.236688] raid6: sse2x1    3141 MB/s
[    0.293342] raid6: sse2x2    6660 MB/s
[    0.350010] raid6: sse2x4    7409 MB/s
[    0.350870] raid6: using algorithm sse2x4 (7409 MB/s)
[    0.352023] raid6: using intx1 recovery algorithm
[    0.353205] ACPI: Added _OSI(Module Device)
[    0.353338] ACPI: Added _OSI(Processor Device)
[    0.354355] ACPI: Added _OSI(3.0 _SCP Extensions)
[    0.355446] ACPI: Added _OSI(Processor Aggregator Device)
[    0.357382] ACPI: EC: Look up EC in DSDT
[    0.360528] ACPI: Interpreter enabled
[    0.361386] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S1_] (20130328/hwxface-568)
[    0.363336] ACPI Exception: AE_NOT_FOUND, While evaluating Sleep State [\_S2_] (20130328/hwxface-568)
[    0.365475] ACPI: (supports S0 S3 S5)
[    0.366315] ACPI: Using IOAPIC for interrupt routing
[    0.366682] PCI: Ignoring host bridge windows from ACPI; if necessary, use "pci=use_crs" and report a bug
[    0.372780] ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-ff])
[    0.373352] acpi PNP0A03:00: host bridge window [io  0x0000-0x0cf7] (ignored)
[    0.374954] acpi PNP0A03:00: host bridge window [io  0x0d00-0xffff] (ignored)
[    0.376670] acpi PNP0A03:00: host bridge window [mem 0x000a0000-0x000bffff] (ignored)
[    0.378435] acpi PNP0A03:00: host bridge window [mem 0xe0000000-0xfebfffff] (ignored)
[    0.380003] PCI: root bus 00: using default resources
[    0.381175] PCI host bridge to bus 0000:00
[    0.382116] pci_bus 0000:00: root bus resource [bus 00-ff]
[    0.383336] pci_bus 0000:00: root bus resource [io  0x0000-0xffff]
[    0.384746] pci_bus 0000:00: root bus resource [mem 0x00000000-0xffffffffff]
[    0.386734] pci 0000:00:00.0: [8086:1237] type 00 class 0x060000
[    0.388616] pci 0000:00:01.0: [8086:7000] type 00 class 0x060100
[    0.390719] pci 0000:00:01.1: [8086:7010] type 00 class 0x010180
[    0.394679] pci 0000:00:01.1: reg 20: [io  0xc1e0-0xc1ef]
[    0.396891] pci 0000:00:01.3: [8086:7113] type 00 class 0x068000
[    0.398837] pci 0000:00:01.3: quirk: [io  0xb000-0xb03f] claimed by PIIX4 ACPI
[    0.400016] pci 0000:00:01.3: quirk: [io  0xb100-0xb10f] claimed by PIIX4 SMB
[    0.401876] pci 0000:00:02.0: [1013:00b8] type 00 class 0x030000
[    0.407191] pci 0000:00:02.0: reg 10: [mem 0xfc000000-0xfdffffff pref]
[    0.410071] pci 0000:00:02.0: reg 14: [mem 0xfebe0000-0xfebe0fff]
[    0.416034] pci 0000:00:02.0: reg 30: [mem 0xfebc0000-0xfebcffff pref]
[    0.417181] pci 0000:00:03.0: [1af4:1000] type 00 class 0x020000
[    0.420358] pci 0000:00:03.0: reg 10: [io  0xc1c0-0xc1df]
[    0.422258] pci 0000:00:03.0: reg 14: [mem 0xfebe1000-0xfebe1fff]
[    0.427027] pci 0000:00:03.0: reg 30: [mem 0xfebd0000-0xfebdffff pref]
[    0.428822] pci 0000:00:04.0: [8086:100e] type 00 class 0x020000
[    0.430722] pci 0000:00:04.0: reg 10: [mem 0xfeb80000-0xfeb9ffff]
[    0.432767] pci 0000:00:04.0: reg 14: [io  0xc000-0xc03f]
[    0.437698] pci 0000:00:04.0: reg 30: [mem 0xfeba0000-0xfebbffff pref]
[    0.439365] pci 0000:00:05.0: [1af4:1001] type 00 class 0x010000
[    0.440769] pci 0000:00:05.0: reg 10: [io  0xc040-0xc07f]
[    0.443336] pci 0000:00:05.0: reg 14: [mem 0xfebe2000-0xfebe2fff]
[    0.448389] pci 0000:00:06.0: [1af4:1001] type 00 class 0x010000
[    0.450718] pci 0000:00:06.0: reg 10: [io  0xc080-0xc0bf]
[    0.452620] pci 0000:00:06.0: reg 14: [mem 0xfebe3000-0xfebe3fff]
[    0.457688] pci 0000:00:07.0: [1af4:1001] type 00 class 0x010000
[    0.459804] pci 0000:00:07.0: reg 10: [io  0xc0c0-0xc0ff]
[    0.460685] pci 0000:00:07.0: reg 14: [mem 0xfebe4000-0xfebe4fff]
[    0.466980] pci 0000:00:08.0: [1af4:1001] type 00 class 0x010000
[    0.469104] pci 0000:00:08.0: reg 10: [io  0xc100-0xc13f]
[    0.470691] pci 0000:00:08.0: reg 14: [mem 0xfebe5000-0xfebe5fff]
[    0.476082] pci 0000:00:09.0: [1af4:1001] type 00 class 0x010000
[    0.477430] pci 0000:00:09.0: reg 10: [io  0xc140-0xc17f]
[    0.480003] pci 0000:00:09.0: reg 14: [mem 0xfebe6000-0xfebe6fff]
[    0.485047] pci 0000:00:0a.0: [1af4:1001] type 00 class 0x010000
[    0.487430] pci 0000:00:0a.0: reg 10: [io  0xc180-0xc1bf]
[    0.489329] pci 0000:00:0a.0: reg 14: [mem 0xfebe7000-0xfebe7fff]
[    0.494321] pci 0000:00:0b.0: [8086:25ab] type 00 class 0x088000
[    0.496070] pci 0000:00:0b.0: reg 10: [mem 0xfebe8000-0xfebe800f]
[    0.500245] pci_bus 0000:00: on NUMA node 0
[    0.501222] acpi PNP0A03:00: ACPI _OSC support notification failed, disabling PCIe ASPM
[    0.502997] acpi PNP0A03:00: Unable to request _OSC control (_OSC support mask: 0x08)
[    0.503798] ACPI: PCI Interrupt Link [LNKA] (IRQs 5 *10 11)
[    0.506806] ACPI: PCI Interrupt Link [LNKB] (IRQs 5 *10 11)
[    0.508358] ACPI: PCI Interrupt Link [LNKC] (IRQs 5 10 *11)
[    0.509907] ACPI: PCI Interrupt Link [LNKD] (IRQs 5 10 *11)
[    0.510519] ACPI: PCI Interrupt Link [LNKS] (IRQs 9) *0
[    0.512378] ACPI: Enabled 16 GPEs in block 00 to 0F
[    0.513342] acpi root: \_SB_.PCI0 notify handler is installed
[    0.514655] Found 1 acpi root devices
[    0.517207] vgaarb: device added: PCI:0000:00:02.0,decodes=io+mem,owns=io+mem,locks=none
[    0.519025] vgaarb: loaded
[    0.519648] vgaarb: bridge control possible 0000:00:02.0
[    0.520411] SCSI subsystem initialized
[    0.521281] ACPI: bus type ATA registered
[    0.522259] libata version 3.00 loaded.
[    0.523394] Linux video capture interface: v2.00
[    0.524466] pps_core: LinuxPPS API ver. 1 registered
[    0.525590] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.526677] PTP clock support registered
[    0.527805] Advanced Linux Sound Architecture Driver Initialized.
[    0.530022] PCI: Using ACPI for IRQ routing
[    0.530979] PCI: pci_cache_line_size set to 64 bytes
[    0.533384] e820: reserve RAM buffer [mem 0x00093c00-0x0009ffff]
[    0.534740] e820: reserve RAM buffer [mem 0x0fffe000-0x0fffffff]
[    0.536840] Switching to clocksource hpet
[    0.537843] FS-Cache: Loaded
[    0.538532] CacheFiles: Loaded
[    0.539273] pnp: PnP ACPI init
[    0.539979] ACPI: bus type PNP registered
[    0.539979] IOAPIC[0]: Set routing entry (2-8 -> 0x38 -> IRQ 8 Mode:0 Active:0 Dest:1)
[    0.541827] pnp 00:00: Plug and Play ACPI device, IDs PNP0b00 (active)
[    0.543398] IOAPIC[0]: Set routing entry (2-1 -> 0x31 -> IRQ 1 Mode:0 Active:0 Dest:1)
[    0.545207] pnp 00:01: Plug and Play ACPI device, IDs PNP0303 (active)
[    0.546752] IOAPIC[0]: Set routing entry (2-12 -> 0x3c -> IRQ 12 Mode:0 Active:0 Dest:1)
[    0.548588] pnp 00:02: Plug and Play ACPI device, IDs PNP0f13 (active)
[    0.550135] IOAPIC[0]: Set routing entry (2-6 -> 0x36 -> IRQ 6 Mode:0 Active:0 Dest:1)
[    0.551922] pnp 00:03: [dma 2]
[    0.552640] pnp 00:03: Plug and Play ACPI device, IDs PNP0700 (active)
[    0.554218] IOAPIC[0]: Set routing entry (2-7 -> 0x37 -> IRQ 7 Mode:0 Active:0 Dest:1)
[    0.556046] pnp 00:04: Plug and Play ACPI device, IDs PNP0400 (active)
[    0.557619] IOAPIC[0]: Set routing entry (2-4 -> 0x34 -> IRQ 4 Mode:0 Active:0 Dest:1)
[    0.559439] pnp 00:05: Plug and Play ACPI device, IDs PNP0501 (active)
[    0.561110] pnp 00:06: Plug and Play ACPI device, IDs PNP0103 (active)
[    0.562738] pnp: PnP ACPI: found 7 devices
[    0.563731] ACPI: bus type PNP unregistered
[    0.564686] INFO_MDMA: LNW DMA Driver Version 1.1.0
[    0.570776] pci_bus 0000:00: resource 4 [io  0x0000-0xffff]
[    0.572044] pci_bus 0000:00: resource 5 [mem 0x00000000-0xffffffffff]
[    0.573554] NET: Registered protocol family 1
[    0.574582] pci 0000:00:00.0: Limiting direct PCI/PCI transfers
[    0.575929] pci 0000:00:01.0: PIIX3: Enabling Passive Release
[    0.577311] pci 0000:00:01.0: Activating ISA DMA hang workarounds
[    0.578736] pci 0000:00:02.0: Boot video device
[    0.579896] PCI: CLS 0 bytes, default 64
[    0.580923] Trying to unpack rootfs image as initramfs...
[    1.240161] Freeing initrd memory: 23656k freed
[    1.265863] DMA-API: preallocated 65536 debug entries
[    1.267360] DMA-API: debugging enabled by kernel config
[    1.269278] microcode: CPU0 sig=0xf61, pf=0x1, revision=0x1
[    1.270817] microcode: Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[    1.273129] camellia-x86_64: performance on this CPU would be suboptimal: disabling camellia-x86_64.
[    1.275528] blowfish-x86_64: performance on this CPU would be suboptimal: disabling blowfish-x86_64.
[    1.277997] twofish-x86_64-3way: performance on this CPU would be suboptimal: disabling twofish-x86_64-3way.
[    1.280602] cryptomgr_test (19) used greatest stack depth: 7024 bytes left
[    1.282655] sha1_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.284308] sha256_ssse3: Neither AVX nor SSSE3 is available/usable.
[    1.285943] AVX or AES-NI instructions are not detected.
[    1.287377] AVX instructions are not detected.
[    1.288532] AVX instructions are not detected.
[    1.289685] AVX instructions are not detected.
[    1.290892] AVX instructions are not detected.
[    1.292049] AVX2 instructions are not detected.
[    1.293223] AVX2 or AES-NI instructions are not detected.
[    1.294671] AVX2 instructions are not detected.
[    1.295845] AVX2 instructions are not detected.
[    1.297506] Initializing RT-Tester: OK
[    1.300902] NTFS driver 2.1.30 [Flags: R/O DEBUG].
[    1.302249] fuse init (API version 7.22)
[    1.303549] JFS: nTxBlock = 1815, nTxLock = 14525
[    1.306123] NILFS version 2 loaded
[    1.307369] bio: create slab <bio-1> at 1
[    1.308628] Running btrfs free space cache tests
[    1.309836] Running extent only tests
[    1.310884] Running bitmap only tests
[    1.311849] Running bitmap and extent tests
[    1.312960] Free space cache tests finished
[    1.314112] Btrfs loaded
[    1.315389] GFS2 installed
[    1.316128] msgmni has been set to 453
[    1.318287] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
[    1.320258] io scheduler noop registered
[    1.321290] io scheduler cfq registered (default)
[    1.324477] list_sort_test: start testing list_sort()
[    1.325989] test_string_helpers: Running tests...
[    1.327423] xz_dec_test: module loaded
[    1.328413] xz_dec_test: Create a device node with 'mknod xz_dec_test c 249 0' and write .xz files to it.
[    1.331209] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
[    1.332674] pciehp: PCI Express Hot Plug Controller Driver version: 0.4
[    1.334602] input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input0
[    1.336501] ACPI: Power Button [PWRF]
[    1.338379] ACPI: PCI Interrupt Link [LNKC] enabled at IRQ 11
[    1.339870] IOAPIC[0]: Set routing entry (2-11 -> 0x3b -> IRQ 11 Mode:1 Active:0 Dest:1)
[    1.342107] virtio-pci 0000:00:03.0: setting latency timer to 64
[    1.344213] ACPI: PCI Interrupt Link [LNKA] enabled at IRQ 10
[    1.345708] IOAPIC[0]: Set routing entry (2-10 -> 0x3a -> IRQ 10 Mode:1 Active:0 Dest:1)
[    1.347903] virtio-pci 0000:00:05.0: setting latency timer to 64
[    1.350290] ACPI: PCI Interrupt Link [LNKB] enabled at IRQ 10
[    1.351818] virtio-pci 0000:00:06.0: setting latency timer to 64
[    1.353970] virtio-pci 0000:00:07.0: setting latency timer to 64
[    1.356164] ACPI: PCI Interrupt Link [LNKD] enabled at IRQ 11
[    1.357748] virtio-pci 0000:00:08.0: setting latency timer to 64
[    1.359831] virtio-pci 0000:00:09.0: setting latency timer to 64
[    1.361974] virtio-pci 0000:00:0a.0: setting latency timer to 64
[    1.371114] Serial: 8250/16550 driver, 4 ports, IRQ sharing disabled
[    1.430076] 00:05: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
[    1.432027] Applicom driver: $Id: ac.c,v 1.30 2000/03/22 16:03:57 dwmw2 Exp $
[    1.433924] ac.o: No PCI boards found.
[    1.434907] ac.o: For an ISA board you must supply memory and irq parameters.
[    1.436844] ppdev: user-space parallel port driver
[    1.438113] telclk_interrupt = 0xf non-mcpbl0010 hw.
[    1.439446] parport_pc 00:04: reported by Plug and Play ACPI
[    1.450450] parport0: PC-style at 0x378, irq 7 [PCSPP,TRISTATE]
[    1.534031] Floppy drive(s): fd0 is 1.44M
[    1.535975] brd: module loaded
[    1.537183] loop: module loaded
[    1.537876] Compaq SMART2 Driver (v 2.6.0)
[    1.538909] MM: desc_per_page = 128
[    1.539668] mtip32xx Version 1.2.6os3
[    1.540650] dummy-irq: no IRQ given.  Use irq=N
[    1.541636] lkdtm: No crash points registered, enable through debugfs
[    1.543027] Phantom Linux Driver, version n0.9.8, init OK
[    1.544399] Driver for timberdale has been successfully registered.
[    1.545839] rdac: device handler registered
[    1.546880] emc: device handler registered
[    1.547808] alua: device handler registered
[    1.548698] st: Version 20101219, fixed bufsize 32768, s/g segs 256
[    1.552071] FDC 0 is a S82078B
[    1.553721] osst :I: Tape driver with OnStream support version 0.99.4
[    1.553721] osst :I: $Id: osst.c,v 1.73 2005/01/01 21:13:34 wriede Exp $
[    1.556545] SCSI Media Changer driver v0.25 
[    1.557665] ata_piix 0000:00:01.1: version 2.13
[    1.558797] ata_piix 0000:00:01.1: setting latency timer to 64
[    1.560440] scsi0 : ata_piix
[    1.561173] scsi1 : ata_piix
[    1.561826] ata1: PATA max MWDMA2 cmd 0x1f0 ctl 0x3f6 bmdma 0xc1e0 irq 14
[    1.563296] ata2: PATA max MWDMA2 cmd 0x170 ctl 0x376 bmdma 0xc1e8 irq 15
[    1.565813] HSI/SSI char device loaded
[    1.566959] i8042: PNP: PS/2 Controller [PNP0303:KBD,PNP0f13:MOU] at 0x60,0x64 irq 1,12
[    1.569627] serio: i8042 KBD port at 0x60,0x64 irq 1
[    1.570808] serio: i8042 AUX port at 0x60,0x64 irq 12
[    1.571942] serio: PARKBD AT adapter on parport0
[    1.573033] mousedev: PS/2 mouse device common for all mice
[    1.574775] input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input1
[    1.576930] I2O subsystem v1.325
[    1.577682] i2o: max drivers = 8
[    1.578472] I2O Configuration OSM v1.323
[    1.579320] I2O Bus Adapter OSM v1.317
[    1.580196] I2O SCSI Peripheral OSM v1.316
[    1.581240] piix4_smbus 0000:00:01.3: SMBus Host Controller at 0xb100, revision 0
[    1.593569] i2c-parport-light: adapter type unspecified
[    1.594778] saa7146: register extension 'hexium HV-PCI6 Orion'
[    1.596060] Zoran MJPEG board driver version 0.10.1
[    1.597192] Linux video codec intermediate layer: v0.2
[    1.598307] cx25821: driver version 0.0.106 loaded
[    1.599408] pps pps0: new PPS source ktimer
[    1.600431] pps pps0: ktimer PPS source registered
[    1.673450] w83793: Detection failed at check vendor id
[    1.693439] w83793: Detection failed at check vendor id
[    1.713439] w83793: Detection failed at check vendor id
[    1.717585] ata2.01: NODEV after polling detection
[    1.719019] ata2.00: ATAPI: QEMU DVD-ROM, 1.1.2, max UDMA/100
[    1.721069] ata2.00: configured for MWDMA2
[    1.722646] scsi 1:0:0:0: CD-ROM            QEMU     QEMU DVD-ROM     1.1. PQ: 0 ANSI: 5
[    1.725495] sr0: scsi3-mmc drive: 4x/4x cd/rw xa/form2 tray
[    1.726746] cdrom: Uniform CD-ROM driver Revision: 3.20
[    1.728145] sr 1:0:0:0: Attached scsi CD-ROM sr0
[    1.729349] sr 1:0:0:0: Attached scsi generic sg0 type 5
[    1.733444] w83793: Detection failed at check vendor id
[    1.746775] i2c i2c-0: w83795: Detection failed at addr 0x2c, check bank
[    1.760107] i2c i2c-0: w83795: Detection failed at addr 0x2d, check bank
[    1.773440] i2c i2c-0: w83795: Detection failed at addr 0x2e, check bank
[    1.786774] i2c i2c-0: w83795: Detection failed at addr 0x2f, check bank
[    1.800107] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.813439] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.826773] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.840108] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.853440] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.866774] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.880106] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.893441] i2c i2c-0: Detection of w83781d chip failed at step 3
[    1.966779] i2c i2c-0: Detecting device at 0,0x2c with COMPANY: 0xff and VERSTEP: 0xff
[    1.968503] i2c i2c-0: Autodetecting device at 0,0x2c...
[    1.969623] i2c i2c-0: Autodetection failed
[    1.990108] i2c i2c-0: Detecting device at 0,0x2d with COMPANY: 0xff and VERSTEP: 0xff
[    1.991823] i2c i2c-0: Autodetecting device at 0,0x2d...
[    1.992950] i2c i2c-0: Autodetection failed
[    2.013441] i2c i2c-0: Detecting device at 0,0x2e with COMPANY: 0xff and VERSTEP: 0xff
[    2.015186] i2c i2c-0: Autodetecting device at 0,0x2e...
[    2.016315] i2c i2c-0: Autodetection failed
[    2.270081] tsc: Refined TSC clocksource calibration: 2666.660 MHz
[    2.271489] Switching to clocksource tsc
[    2.366740] i2c i2c-0: detect fail: address match, 0x2c
[    2.380069] i2c i2c-0: detect fail: address match, 0x2d
[    2.393402] i2c i2c-0: detect fail: address match, 0x2e
[    2.406734] i2c i2c-0: detect fail: address match, 0x2f
[    2.420071]  (null): Wrong manufacturer ID. Got 255, expected 65
[    2.433403]  (null): Wrong manufacturer ID. Got 255, expected 65
[    2.446735]  (null): Wrong manufacturer ID. Got 255, expected 65
[    2.578348] input: ImExPS/2 Generic Explorer Mouse as /devices/platform/i8042/serio1/input/input2
[    2.866908] f71882fg: Not a Fintek device
[    2.867842] f71882fg: Not a Fintek device
[    2.973404]  (null): Unknown chip type, skipping
[    2.986734]  (null): Unknown chip type, skipping
[    3.300080] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[    3.346749] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[    3.393412] i2c i2c-0: Unsupported chip (man_id=0xFF, chip_id=0xFF)
[    8.156769] i2c i2c-0: Unsupported chip at 0x18 (man_id=0xFF, chip_id=0xFF)
[    8.190102] i2c i2c-0: Unsupported chip at 0x19 (man_id=0xFF, chip_id=0xFF)
[    8.223420] i2c i2c-0: Unsupported chip at 0x1a (man_id=0xFF, chip_id=0xFF)
[    8.256734] i2c i2c-0: Unsupported chip at 0x29 (man_id=0xFF, chip_id=0xFF)
[    8.290067] i2c i2c-0: Unsupported chip at 0x2a (man_id=0xFF, chip_id=0xFF)
[    8.323400] i2c i2c-0: Unsupported chip at 0x2b (man_id=0xFF, chip_id=0xFF)
[    8.356732] i2c i2c-0: Unsupported chip at 0x48 (man_id=0xFF, chip_id=0xFF)
[    8.390067] i2c i2c-0: Unsupported chip at 0x49 (man_id=0xFF, chip_id=0xFF)
[    8.423411] i2c i2c-0: Unsupported chip at 0x4a (man_id=0xFF, chip_id=0xFF)
[    8.456732] i2c i2c-0: Unsupported chip at 0x4b (man_id=0xFF, chip_id=0xFF)
[    8.490066] i2c i2c-0: Unsupported chip at 0x4c (man_id=0xFF, chip_id=0xFF)
[    8.523400] i2c i2c-0: Unsupported chip at 0x4d (man_id=0xFF, chip_id=0xFF)
[    8.556733] i2c i2c-0: Unsupported chip at 0x4e (man_id=0xFF, chip_id=0xFF)
[    8.590066] i2c i2c-0: Unsupported chip at 0x4f (man_id=0xFF, chip_id=0xFF)
[    8.603399] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[    8.616732] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[    8.630066] i2c i2c-0: detect failed, bad manufacturer id 0xff!
[    8.736737] i2c i2c-0: MAX1619 detection failed at 0x18
[    8.763399] i2c i2c-0: MAX1619 detection failed at 0x19
[    8.790065] i2c i2c-0: MAX1619 detection failed at 0x1a
[    8.816733] i2c i2c-0: MAX1619 detection failed at 0x29
[    8.843398] i2c i2c-0: MAX1619 detection failed at 0x2a
[    8.870066] i2c i2c-0: MAX1619 detection failed at 0x2b
[    8.896732] i2c i2c-0: MAX1619 detection failed at 0x4c
[    8.923405] i2c i2c-0: MAX1619 detection failed at 0x4d
[    8.950067] i2c i2c-0: MAX1619 detection failed at 0x4e
[    9.236879] pc87360: PC8736x not detected, module not inserted
[    9.238478] sch56xx_common: Unsupported device id: 0xff
[    9.239855] sch56xx_common: Unsupported device id: 0xff
[    9.246732] thmc50: Probing for THMC50 at 0x2C on bus 0
[    9.273390] thmc50: Probing for THMC50 at 0x2D on bus 0
[    9.300056] thmc50: Probing for THMC50 at 0x2E on bus 0
[    9.360276] advantechwdt: WDT driver for Advantech single board computer initialising
[    9.362407] advantechwdt: initialized. timeout=60 sec (nowayout=1)
[    9.364025] alim7101_wdt: Steve Hill <steve@navaho.co.uk>
[    9.365418] alim7101_wdt: ALi M7101 PMU not present - WDT not set
[    9.367085] iTCO_wdt: Intel TCO WatchDog Timer Driver v1.10
[    9.368587] it87_wdt: no device
[    9.369424] sc1200wdt: build 20020303
[    9.370410] sc1200wdt: io parameter must be specified
[    9.371722] pc87413_wdt: Version 1.1 at io 0x2E
[    9.372901] pc87413_wdt: cannot register miscdev on minor=130 (err=-16)
[    9.374628] sbc60xxwdt: I/O address 0x0443 already in use
[    9.376029] sbc8360: failed to register misc device
[    9.377324] cpu5wdt: misc_register failed
[    9.378453] smsc37b787_wdt: SMsC 37B787 watchdog component driver 1.1 initialising...
[    9.381558] smsc37b787_wdt: Unable to register miscdev on minor 130
[    9.383171] w83627hf_wdt: WDT driver for the Winbond(TM) W83627HF/THF/HG/DHG Super I/O chip initialising
[    9.385703] w83627hf_wdt: Watchdog already running. Resetting timeout to 60 sec
[    9.387682] w83627hf_wdt: cannot register miscdev on minor=130 (err=-16)
[    9.389400] w83697hf_wdt: WDT driver for W83697HF/HG initializing
[    9.391036] w83697hf_wdt: watchdog not found at address 0x2e
[    9.392494] w83697hf_wdt: No W83697HF/HG could be found
[    9.393860] w83697ug_wdt: WDT driver for the Winbond(TM) W83697UG/UF Super I/O chip initialising
[    9.396148] w83697ug_wdt: No W83697UG/UF could be found
[    9.397647] w83877f_wdt: I/O address 0x0443 already in use
[    9.399079] w83977f_wdt: driver v1.00
[    9.400055] w83977f_wdt: cannot register miscdev on minor=130 (err=-16)
[    9.401776] machzwd: MachZ ZF-Logic Watchdog driver initializing
[    9.403348] machzwd: no ZF-Logic found
[    9.404327] sbc_epx_c3: cannot register miscdev on minor=130 (err=-16)
[    9.406048] watchdog: Software Watchdog: cannot register miscdev on minor=130 (err=-16).
[    9.408148] watchdog: Software Watchdog: a legacy watchdog module is probably present.
[    9.410231] softdog: Software Watchdog Timer: 0.08 initialized. soft_noboot=0 soft_margin=60 sec soft_panic=0 (nowayout=1)
[    9.413062] md: linear personality registered for level -1
[    9.414496] md: raid0 personality registered for level 0
[    9.415861] md: raid1 personality registered for level 1
[    9.417252] md: raid10 personality registered for level 10
[    9.418679] md: multipath personality registered for level -4
[    9.420187] md: faulty personality registered for level -5
[    9.421777] cpuidle: using governor ladder
[    9.422863] cpuidle: using governor menu
[    9.423931] sdhci: Secure Digital Host Controller Interface driver
[    9.425523] sdhci: Copyright(c) Pierre Ossman
[    9.426656] wbsd: Winbond W83L51xD SD/MMC card interface driver
[    9.428200] wbsd: Copyright(c) Pierre Ossman
[    9.429345] sdhci-pltfm: SDHCI platform and OF driver helper
[   12.800096]  (null): enodev DEV ADDR = 0xFF
[   12.801190] dcdbas dcdbas: Dell Systems Management Base Driver (version 5.6.0-3.2)
[   12.802797] cs5535-clockevt: Could not allocate MFGPT timer
[   12.804066] parport0: no more devices allowed
[   12.805004] panel: panel_attach: port->number=0 parport=0, parport_register_device() failed
[   12.806778] panel: driver version 0.9.5 not yet registered
[   12.807977] vme_pio2: No cards, skipping registration
[   12.809385] Audio Excel DSP 16 init driver Copyright (C) Riccardo Facchetti 1995-98
[   12.811020] aedsp16: I/O, IRQ and DMA are mandatory
[   12.812057] pss: mss_io, mss_dma, mss_irq and pss_io must be set.
[   12.813334] ad1848/cs4248 codec driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.814942] ad1848: No ISAPnP cards found, trying standard ones...
[   12.816246] MediaTrix audio driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.817791] I/O, IRQ, DMA and type are mandatory
[   12.818777] Pro Audio Spectrum driver Copyright (C) by Hannu Savolainen 1993-1996
[   12.820362] I/O, IRQ, DMA and type are mandatory
[   12.821336] sb: Init: Starting Probe...
[   12.822189] sb: Init: Done
[   12.822797] YM3812 and OPL-3 driver Copyright (C) by Hannu Savolainen, Rob Hooft 1993-1996
[   12.824576] MIDI Loopback device driver
[   12.825615] can't register device seq
[   12.827642] no UART detected at 0x1
[   12.828513] MTVAP port 0x378 is busy
[   12.829291] snd_mtpav: probe of snd_mtpav failed with error -16
[   12.830606] parport0: no more devices allowed
[   12.831542] snd_mts64: probe of snd_mts64.0 failed with error -5
[   12.833060] ASIHPI driver 4.10.01
[   12.834565] 
[   12.834565] printing PIC contents
[   12.835603] ... PIC  IMR: ffff
[   12.836267] ... PIC  IRR: 9053
[   12.836954] ... PIC  ISR: 0000
[   12.837610] ... PIC ELCR: 0c00
[   12.838273] printing local APIC contents on CPU#0/0:
[   12.839319] ... APIC ID:      00000000 (0)
[   12.840192] ... APIC VERSION: 00050014
[   12.840275] ... APIC TASKPRI: 00000000 (00)
[   12.840275] ... APIC PROCPRI: 00000000
[   12.840275] ... APIC LDR: 01000000
[   12.840275] ... APIC DFR: ffffffff
[   12.840275] ... APIC SPIV: 000001ff
[   12.840275] ... APIC ISR field:
[   12.840275] 0000000000000000000000000000000000000000000000000000000000000000
[   12.840275] ... APIC TMR field:
[   12.840275] 0000000000000000000000000000000000000000000000000000000000000000
[   12.840275] ... APIC IRR field:
[   12.840275] 0000000000000000000000000000000000000000000000000000000000008000
[   12.840275] ... APIC ESR: 00000000
[   12.840275] ... APIC ICR: 00000831
[   12.840275] ... APIC ICR2: 01000000
[   12.840275] ... APIC LVTT: 000000ef
[   12.840275] ... APIC LVTPC: 00010000
[   12.840275] ... APIC LVT0: 00010700
[   12.840275] ... APIC LVT1: 00000400
[   12.840275] ... APIC LVTERR: 000000fe
[   12.840275] ... APIC TMICT: 0002e99f
[   12.840275] ... APIC TMCCT: 00000000
[   12.840275] ... APIC TDCR: 00000003
[   12.840275] 
[   12.863840] number of MP IRQ sources: 15.
[   12.864760] number of IO-APIC #2 registers: 24.
[   12.865724] testing the IO APIC.......................
[   12.866853] IO APIC #2......
[   12.867477] .... register #00: 00000000
[   12.868295] .......    : physical APIC id: 00
[   12.869224] .......    : Delivery Type: 0
[   12.870109] .......    : LTS          : 0
[   12.870965] .... register #01: 00170011
[   12.871769] .......     : max redirection entries: 17
[   12.872874] .......     : PRQ implemented: 0
[   12.873844] .......     : IO APIC version: 11
[   12.874832] .... register #02: 00000000
[   12.875707] .......     : arbitration: 00
[   12.876624] .... IRQ redirection table:
[   12.877553] 1    0    0   0   0    0    0    00
[   12.878540] 0    0    0   0   0    1    1    31
[   12.879514] 0    0    0   0   0    1    1    30
[   12.880532] 0    0    0   0   0    1    1    33
[   12.881580] 1    0    0   0   0    1    1    34
[   12.882644] 1    1    0   0   0    1    1    35
[   12.883756] 0    0    0   0   0    1    1    36
[   12.884910] 0    0    0   0   0    1    1    37
[   12.886124] 0    0    0   0   0    1    1    38
[   12.887151] 0    1    0   0   0    1    1    39
[   12.888119] 1    1    0   0   0    1    1    3A
[   12.889088] 1    1    0   0   0    1    1    3B
[   12.890077] 0    0    0   0   0    1    1    3C
[   12.891043] 0    0    0   0   0    1    1    3D
[   12.892005] 0    0    0   0   0    1    1    3E
[   12.892964] 0    0    0   0   0    1    1    3F
[   12.893943] 1    0    0   0   0    0    0    00
[   12.894909] 1    0    0   0   0    0    0    00
[   12.895931] 1    0    0   0   0    0    0    00
[   12.896915] 1    0    0   0   0    0    0    00
[   12.897890] 1    0    0   0   0    0    0    00
[   12.898849] 1    0    0   0   0    0    0    00
[   12.899813] 1    0    0   0   0    0    0    00
[   12.900789] 1    0    0   0   0    0    0    00
[   12.901741] IRQ to pin mappings:
[   12.902434] IRQ0 -> 0:2
[   12.903029] IRQ1 -> 0:1
[   12.903632] IRQ3 -> 0:3
[   12.904222] IRQ4 -> 0:4
[   12.904808] IRQ5 -> 0:5
[   12.905399] IRQ6 -> 0:6
[   12.905994] IRQ7 -> 0:7
[   12.906580] IRQ8 -> 0:8
[   12.907192] IRQ9 -> 0:9
[   12.907781] IRQ10 -> 0:10
[   12.908408] IRQ11 -> 0:11
[   12.909038] IRQ12 -> 0:12
[   12.909659] IRQ13 -> 0:13
[   12.910304] IRQ14 -> 0:14
[   12.910926] IRQ15 -> 0:15
[   12.911552] .................................... done.
[   12.913494] dmaengine: __dma_request_channel: fail ((null))
[   12.914759] hd: no drives specified - use hd=cyl,head,sectors on kernel command line
[   12.916479] BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
[   12.917755] EDD information not available.
[   12.918617] ALSA device list:
[   12.919250]   #0: Dummy 1
[   12.919807]   #1: Loopback 1
[   12.920440]   #2: Virtual MIDI Card 1
[   12.922524] Freeing unused kernel memory: 776k freed
[   12.942549] hostname (104) used greatest stack depth: 5792 bytes left
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
/bin/sh: /proc/self/fd/9: No such file or directory
[   20.859432] warning: process `trinity-child0' used the deprecated sysctl system call with 
[   23.885633] trinity-child0 (125) used greatest stack depth: 5488 bytes left
[   31.276698] CPA self-test:
[   31.277284]  4k 1534 large 125 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.286544]  4k 63998 large 3 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.299047]  4k 63998 large 3 gb 0 x 1[ffff88000008e000-ffff88000008e000] miss 0
[   31.314928] ok.
plymouth-upstart-bridge: ply-event-loop.c:497: ply_event_loop_new: Assertion `loop->epoll_fd >= 0' failed.
/etc/lsb-base-logging.sh: line 5:   164 Aborted                 plymouth --ping > /dev/null 2>&1
 * Asking all remaining processes to terminate...       
killall5[167]: mount returned non-zero exit status
killall5[167]: /proc not mounted, failed to mount.
/etc/lsb-base-logging.sh: line 5:   169 Aborted                 plymouth --ping > /dev/null 2>&1

mount: proc has wrong device number or fs type proc not supported
killall5[175]: mount returned non-zero exit status
killall5[175]: /proc not mounted, failed to mount.
/etc/lsb-base-logging.sh: line 5:   185 Aborted                 plymouth --ping > /dev/null 2>&1
 * All processes ended within 1 seconds....       

/etc/rc6.d/S40umountfs: line 20: /proc/mounts: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
[   75.052517] BUG: unable to handle kernel NULL pointer dereference at           (null)
[   75.053342] IP: [<          (null)>]           (null)
[   75.053342] PGD f015067 PUD f000067 PMD 0 
[   75.053342] Oops: 0010 [#1] 
[   75.053342] CPU: 0 PID: 206 Comm: trinity-child0 Not tainted 3.10.0-rc4-00590-g130d3d6 #32
[   75.053342] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   75.053342] task: ffff88000f0a1840 ti: ffff88000f04c000 task.ti: ffff88000f04c000
[   75.053342] RIP: 0010:[<0000000000000000>]  [<          (null)>]           (null)
[   75.053342] RSP: 0018:ffff88000f04dc50  EFLAGS: 00010282
[   75.053342] RAX: ffff88000f1d9438 RBX: ffff88000f1d9400 RCX: 0000000022b5ec40
[   75.053342] RDX: 0000000000000000 RSI: ffff88000f1d9400 RDI: ffffffff81dab900
[   75.053342] RBP: ffff88000f04dc78 R08: 0000000000000000 R09: 0000000000000000
[   75.053342] R10: 0000000000000000 R11: 0000000000000000 R12: ffff8800000210d0
[   75.053342] R13: ffffffff81dab900 R14: 0000000000000000 R15: 0000000000000000
[   75.053342] FS:  00007fc54dccf700(0000) GS:ffffffff81c9b000(0000) knlGS:0000000000000000
[   75.053342] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   75.053342] CR2: 0000000000000000 CR3: 0000000006eb0000 CR4: 00000000000006b0
[   75.053342] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   75.053342] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   75.053342] Stack:
[   75.053342]  ffffffff818d304f 0000000000000000 ffff88000f1d9400 ffff88000f007600
[   75.053342]  ffff88000f007600 ffff88000f04dcc8 ffffffff818d48ba 0000000000001000
[   75.053342]  0000000000f54220 ffff88000f04dfd8 7fffffffffffffff ffff88000f04dd70
[   75.053342] Call Trace:
[   75.053342]  [<ffffffff818d304f>] ? netlink_lookup+0xaf/0xf0
[   75.053342]  [<ffffffff818d48ba>] netlink_unicast+0xba/0x1d0
[   75.053342]  [<ffffffff818d512a>] netlink_sendmsg+0x32a/0x3e0
[   75.053342]  [<ffffffff818a678b>] sock_aio_write+0xfb/0x130
[   75.053342]  [<ffffffff81100e72>] ? kmem_cache_free+0x32/0x180
[   75.053342]  [<ffffffff811069ea>] do_sync_write+0x7a/0xb0
[   75.053342]  [<ffffffff81106cbd>] vfs_write+0x16d/0x1d0
[   75.053342]  [<ffffffff81106e0d>] SyS_write+0x4d/0xa0
[   75.053342]  [<ffffffff818eefd0>] system_call_fastpath+0x16/0x1b
[   75.053342] Code:  Bad RIP value.
[   75.053342] RIP  [<          (null)>]           (null)
[   75.053342]  RSP <ffff88000f04dc50>
[   75.053342] CR2: 0000000000000000
[   75.099392] ---[ end trace fe29140019c40c80 ]---
[   75.100379] BUG: sleeping function called from invalid context at /c/kernel-tests/src/tip/kernel/rwsem.c:20
[   75.102398] in_atomic(): 1, irqs_disabled(): 0, pid: 206, name: trinity-child0
[   75.103920] CPU: 0 PID: 206 Comm: trinity-child0 Tainted: G      D      3.10.0-rc4-00590-g130d3d6 #32
[   75.105833] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
[   75.107053]  0000000000000009 ffff88000f04d888 ffffffff818e8da7 ffff88000f04d898
[   75.108718]  ffffffff810a7c0c ffff88000f04d8b8 ffffffff818eca4f 0000000000000092
[   75.110410]  ffff88000f0a1840 ffff88000f04d8e8 ffffffff8109046f ffff88000f04d948
[   75.112076] Call Trace:
[   75.112606]  [<ffffffff818e8da7>] dump_stack+0x19/0x1b
[   75.113708]  [<ffffffff810a7c0c>] __might_sleep+0xcc/0xf0
[   75.114853]  [<ffffffff818eca4f>] down_read+0x1f/0x40
[   75.115914]  [<ffffffff8109046f>] exit_signals+0x1f/0x120
[   75.117048]  [<ffffffff81085e84>] do_exit+0xa4/0x990
[   75.118096]  [<ffffffff818e45ef>] ? printk+0x48/0x4a
[   75.119138]  [<ffffffff81005377>] oops_end+0x97/0xe0
[   75.120198]  [<ffffffff818e3f84>] no_context+0x25c/0x288
[   75.121308]  [<ffffffff818e433d>] __bad_area_nosemaphore+0x1c2/0x1e1
[   75.122630]  [<ffffffff818e436a>] bad_area_nosemaphore+0xe/0x10
[   75.123888]  [<ffffffff81021b22>] __do_page_fault+0x2b2/0x4d0
[   75.125090]  [<ffffffff810de26e>] ? __alloc_pages_nodemask+0x13e/0x8b0
[   75.126445]  [<ffffffff810dc8c8>] ? __rmqueue+0x78/0x340
[   75.127571]  [<ffffffff810b5bd1>] ? mutex_remove_waiter+0x51/0x140
[   75.128856]  [<ffffffff818ec54a>] ? __mutex_lock_slowpath+0x1ba/0x2b0
[   75.130226]  [<ffffffff810b5bd1>] ? mutex_remove_waiter+0x51/0x140
[   75.131518]  [<ffffffff81021d69>] do_page_fault+0x9/0x10
[   75.132627]  [<ffffffff818eeaaf>] page_fault+0x1f/0x30
[   75.133719]  [<ffffffff818d304f>] ? netlink_lookup+0xaf/0xf0
[   75.134905]  [<ffffffff818d48ba>] netlink_unicast+0xba/0x1d0
[   75.136080]  [<ffffffff818d512a>] netlink_sendmsg+0x32a/0x3e0
[   75.137274]  [<ffffffff818a678b>] sock_aio_write+0xfb/0x130
[   75.138440]  [<ffffffff81100e72>] ? kmem_cache_free+0x32/0x180
[   75.139655]  [<ffffffff811069ea>] do_sync_write+0x7a/0xb0
[   75.140798]  [<ffffffff81106cbd>] vfs_write+0x16d/0x1d0
[   75.141889]  [<ffffffff81106e0d>] SyS_write+0x4d/0xa0
[   75.142948]  [<ffffffff818eefd0>] system_call_fastpath+0x16/0x1b
[   75.144223] note: trinity-child0[206] exited with preempt_count 1
[   75.146128] trinity-child0 (206) used greatest stack depth: 4352 bytes left
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
cat: /proc/1/maps: No such file or directory
umount: /var/run: not mounted
umount: /var/lock: not mounted
umount: /dev/shm: not mounted
mount: / is busy
 * Will now restart
[   78.457366] Restarting system.
[   78.458190] reboot: machine restart
Elapsed time: 100

--k1lZvvs/B4yU6o8G
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="bisect-130d3d68b52097c7ae081109f700b02776adcb9c-x86_64-randconfig-c21-0611-BUG:-unable-to-handle-kernel-NULL-pointer-dereference-at-85760.log"
Content-Transfer-Encoding: base64

Z2l0IGNoZWNrb3V0IGRiYmZmZTY4OThmZDBkN2JhYzY2ZGVkNWQzYzU4ODM1YjEzZGRlZmMK
UHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgMTMwZDNkNi4uLiBuZXRfc2NoZWQ6IHBzY2hl
ZF9yYXRlY2ZnX3ByZWNvbXB1dGUoKSBpbXByb3ZlbWVudHMKSEVBRCBpcyBub3cgYXQgZGJi
ZmZlNi4uLiBNZXJnZSBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5l
bC9naXQvZGF2ZW0vbmV0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZf
NjQtcmFuZGNvbmZpZy1jMjEtMDYxMS9uZXQtbmV4dDptYXN0ZXI6ZGJiZmZlNjg5OGZkMGQ3
YmFjNjZkZWQ1ZDNjNTg4MzViMTNkZGVmYzpiaXNlY3QtbmV0CgoyMDEzLTA2LTEyLTE4OjQy
OjQzIGRiYmZmZTY4OThmZDBkN2JhYzY2ZGVkNWQzYzU4ODM1YjEzZGRlZmMgcmV1c2UgL2tl
cm5lbC94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS9kYmJmZmU2ODk4ZmQwZDdiYWM2NmRl
ZDVkM2M1ODgzNWIxM2RkZWZjL3ZtbGludXotMy4xMC4wLXJjMS0wMDA3OS1nZGJiZmZlNgoK
MjAxMy0wNi0xMi0xODo0Mjo0MyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAuLi4JMi4uCTQJNQk5
LgkxMAkxMQkxNQkyMQkyNAkzMAkzMwkzNgkzNwkzOC4JMzkJNDAJNDUuLgk0Ngk0OAk1MCBT
VUNDRVNTCgpiaXNlY3Q6IGdvb2QgY29tbWl0IGRiYmZmZTY4OThmZDBkN2JhYzY2ZGVkNWQz
YzU4ODM1YjEzZGRlZmMKZ2l0IGJpc2VjdCBzdGFydCAxMzBkM2Q2OGI1MjA5N2M3YWUwODEx
MDlmNzAwYjAyNzc2YWRjYjljIGRiYmZmZTY4OThmZDBkN2JhYzY2ZGVkNWQzYzU4ODM1YjEz
ZGRlZmMgLS0KUHJldmlvdXMgSEVBRCBwb3NpdGlvbiB3YXMgZGJiZmZlNi4uLiBNZXJnZSBn
aXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvZGF2ZW0vbmV0
ClN3aXRjaGVkIHRvIGJyYW5jaCAnbWFzdGVyJwpZb3VyIGJyYW5jaCBpcyBiZWhpbmQgJ29y
aWdpbi9tYXN0ZXInIGJ5IDMwNDggY29tbWl0cywgYW5kIGNhbiBiZSBmYXN0LWZvcndhcmRl
ZC4KQmlzZWN0aW5nOiA3OTggcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChy
b3VnaGx5IDEwIHN0ZXBzKQpbM2FjZmVhYzM1MWM2YWIyZmUxMTM5ZWUxM2Q3ODA3MjlhZjBj
ODE0NV0gTWVyZ2UgYnJhbmNoICdmZWNfcmVndWxhdG9yX3N1c3BlbmRfcmVzdW1lJwpnaXQg
YmlzZWN0IHJ1biAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNo
IC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNl
Y3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1h
IC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYx
MS9uZXQtbmV4dDptYXN0ZXI6M2FjZmVhYzM1MWM2YWIyZmUxMTM5ZWUxM2Q3ODA3MjlhZjBj
ODE0NTpiaXNlY3QtbmV0CgoyMDEzLTA2LTEyLTE4OjU3OjM5IDNhY2ZlYWMzNTFjNmFiMmZl
MTEzOWVlMTNkNzgwNzI5YWYwYzgxNDUgY29tcGlsaW5nCjkxIHJlYWwgIDk4MSB1c2VyICA4
MyBzeXMgIDExNjUuNzclIGNwdSAJeDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEKCjIwMTMt
MDYtMTItMTg6NTk6MzcgZGV0ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJjMi0xNDk3OC1n
M2FjZmVhYy4uLi4uCTQJOQkxMAkxMS4JMTYJMjAJMjMuCTI0CTMxCTMzCTM0CTQwCTQ0CTQ4
Lgk0OQk1MCBTVUNDRVNTCgpCaXNlY3Rpbmc6IDM5OCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0
IGFmdGVyIHRoaXMgKHJvdWdobHkgOSBzdGVwcykKWzg3NjRkODYxMDBmZTU4ZTY5ODc3NzUz
ZmFhNDRmYzFkOTI3NmM2MjRdIE1lcmdlIGJyYW5jaCAnZm9yLWxpbnVzJyBvZiBnaXQ6Ly9n
aXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvbXN6ZXJlZGkvZnVzZQpy
dW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1cmUuc2ggL2hv
bWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2
bS94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS9uZXQtbmV4dDptYXN0ZXI6ODc2NGQ4NjEw
MGZlNThlNjk4Nzc3NTNmYWE0NGZjMWQ5Mjc2YzYyNDpiaXNlY3QtbmV0CgoyMDEzLTA2LTEy
LTE5OjExOjQ1IDg3NjRkODYxMDBmZTU4ZTY5ODc3NzUzZmFhNDRmYzFkOTI3NmM2MjQgY29t
cGlsaW5nCjEyNiByZWFsICA5OTQgdXNlciAgODMgc3lzICA4NTQuMjMlIGNwdSAJeDg2XzY0
LXJhbmRjb25maWctYzIxLTA2MTEKCjIwMTMtMDYtMTItMTk6MTQ6MDcgZGV0ZWN0aW5nIGJv
b3Qgc3RhdGUgMy4xMC4wLXJjNC0xNTIzMS1nODc2NGQ4Ni4uLgkzCTYJNwk5CTE1CTE3CTIz
CTI0CTI1CTMyCTQyCTQzLgk0NC4JNDkJNTAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAyMjggcmV2
aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5IDggc3RlcHMpClsxNjEy
ZTExMWU0ZTU2NTQyMjI0MjcyN2VmYjU5NDk5Y2NlODczOGU0XSBNZXJnZSBnaXQ6Ly9naXQu
a2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvZGF2ZW0vbmV0CnJ1bm5pbmcg
L2Mva2VybmVsLXRlc3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93Zmcv
bmV0L29iai1iaXNlY3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82
NC1yYW5kY29uZmlnLWMyMS0wNjExL25ldC1uZXh0Om1hc3RlcjoxNjEyZTExMWU0ZTU2NTQy
MjI0MjcyN2VmYjU5NDk5Y2NlODczOGU0OmJpc2VjdC1uZXQKCjIwMTMtMDYtMTItMTk6MjQ6
MTYgMTYxMmUxMTFlNGU1NjU0MjIyNDI3MjdlZmI1OTQ5OWNjZTg3MzhlNCBjb21waWxpbmcK
MTE4IHJlYWwgIDk5MSB1c2VyICA4NyBzeXMgIDkwNy45NyUgY3B1IAl4ODZfNjQtcmFuZGNv
bmZpZy1jMjEtMDYxMQoKMjAxMy0wNi0xMi0xOToyNjozNyBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAzLjEwLjAtcmM0LTE1NDAxLWcxNjEyZTExLi4uCTUJNgk3CTEwCTE0LgkxOAkyMgkyNAky
NS4JMjYuCTI4CTI5CTM0CTM1CTM2Li4JMzcJMzgJMzkuCTQyCTQzCTQ0Lgk0NQk0OS4JNTAg
U1VDQ0VTUwoKQmlzZWN0aW5nOiAxMTQgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDcgc3RlcHMpCltiZDExOGI2ZTk1MDlhMTliZmI4MjkyNTE1MmQ5YWU4
ZmEzOThkNTY3XSBpYm0tZXRoZXJuZXQ6IGRlbGV0ZSBzdGFsZSBNQ0EgYW5kIGR1cGxpY2F0
ZSBQU0VSSUVTIGRlcGVuZGVuY3kKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRl
c3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAva2Vy
bmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEvbmV0
LW5leHQ6bWFzdGVyOmJkMTE4YjZlOTUwOWExOWJmYjgyOTI1MTUyZDlhZThmYTM5OGQ1Njc6
YmlzZWN0LW5ldAoKMjAxMy0wNi0xMi0xOTo0NDoxMiBiZDExOGI2ZTk1MDlhMTliZmI4Mjky
NTE1MmQ5YWU4ZmEzOThkNTY3IGNvbXBpbGluZwo0NTYgcmVhbCAgMTAwMCB1c2VyICA4MiBz
eXMgIDIzNy4xNSUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMQoKMjAxMy0wNi0x
Mi0xOTo1MjowOSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmMyLTE1MDkyLWdiZDEx
OGI2Li4uCTUJMTAJMTUJMTYJMTkJMjYJMjgJMzAJMzMJMzkJNDEuCTQyCTQ1CTQ3CTQ4CTUw
IFNVQ0NFU1MKCkJpc2VjdGluZzogNTYgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0
aGlzIChyb3VnaGx5IDYgc3RlcHMpClsxNDM1NTRhY2U4OTE5ZDVlZjNjYzg0MjRjMGIwNmRi
ZDNkNjcxYjRlXSBNZXJnZSBicmFuY2ggJ21hc3Rlcicgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5v
cmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3BhYmxvL25mLW5leHQKcnVubmluZyAvYy9r
ZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQv
b2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJh
bmRjb25maWctYzIxLTA2MTEvbmV0LW5leHQ6bWFzdGVyOjE0MzU1NGFjZTg5MTlkNWVmM2Nj
ODQyNGMwYjA2ZGJkM2Q2NzFiNGU6YmlzZWN0LW5ldAoKMjAxMy0wNi0xMi0yMDowMjoxNCAx
NDM1NTRhY2U4OTE5ZDVlZjNjYzg0MjRjMGIwNmRiZDNkNjcxYjRlIGNvbXBpbGluZwoyMTcg
cmVhbCAgMTAwNCB1c2VyICA4NSBzeXMgIDUwMi4wMyUgY3B1IAl4ODZfNjQtcmFuZGNvbmZp
Zy1jMjEtMDYxMQoKMjAxMy0wNi0xMi0yMDowNjowOSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAz
LjEwLjAtcmM0LTE1NjU2LWcxNDM1NTRhLi4uCTIJMy4JNC4JOQkxMwkxNgkxNy4JMjYJMjcJ
MjguLgkzMgkzOAk0MAk0Mwk0Nwk0OS4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4b
WzE7MzVtYWRkX3RvX3J1bl9xdWV1ZSAxG1swbQouLi4JNTAgU1VDQ0VTUwoKQmlzZWN0aW5n
OiAyOCByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgNSBzdGVw
cykKWzU4OWViZGVmN2UzMTA3NDAxYmY5NmE5YzY2MDc1M2QzOTczMjllZTldIHNoX2V0aDog
Z2V0IFI4QTc3N3ggc3VwcG9ydCBvdXQgb2YgI2lmZGVmCnJ1bm5pbmcgL2Mva2VybmVsLXRl
c3RzL2Jpc2VjdC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNl
Y3QKbHMgLWEgL2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmln
LWMyMS0wNjExL25ldC1uZXh0Om1hc3Rlcjo1ODllYmRlZjdlMzEwNzQwMWJmOTZhOWM2NjA3
NTNkMzk3MzI5ZWU5OmJpc2VjdC1uZXQKCjIwMTMtMDYtMTItMjI6NTE6MDIgNTg5ZWJkZWY3
ZTMxMDc0MDFiZjk2YTljNjYwNzUzZDM5NzMyOWVlOSBjb21waWxpbmcKMTI2IHJlYWwgIDk5
MCB1c2VyICA4OCBzeXMgIDg1NS40MCUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYx
MQoKMjAxMy0wNi0xMi0yMjo1MzozMSBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0
LTE1NzQ4LWc1ODllYmRlLi4uCTEJMgk1CTE0CTE5CTI5CTM1CTQ3CTUwIFNVQ0NFU1MKCkJp
c2VjdGluZzogMTQgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5
IDQgc3RlcHMpClthZjEyZmE2ZTQ2YWE2NTFlN2I4NmE0YzQxMTdiNTYyNTE4ZmVmMTg0XSBu
ZXQ6IGFkZCBuYXBpX2lkIGFuZCBoYXNoCnJ1bm5pbmcgL2Mva2VybmVsLXRlc3RzL2Jpc2Vj
dC10ZXN0LWJvb3QtZmFpbHVyZS5zaCAvaG9tZS93ZmcvbmV0L29iai1iaXNlY3QKbHMgLWEg
L2tlcm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMyMS0wNjEx
L25ldC1uZXh0Om1hc3RlcjphZjEyZmE2ZTQ2YWE2NTFlN2I4NmE0YzQxMTdiNTYyNTE4ZmVm
MTg0OmJpc2VjdC1uZXQKCjIwMTMtMDYtMTItMjI6NTk6MzcgYWYxMmZhNmU0NmFhNjUxZTdi
ODZhNGM0MTE3YjU2MjUxOGZlZjE4NCBjb21waWxpbmcKMTI5IHJlYWwgIDk4NSB1c2VyICA4
NiBzeXMgIDgyNS4zMyUgY3B1IAl4ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMQoKMjAxMy0w
Ni0xMi0yMzowMjozMiBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAtcmM0LTE1NzYyLWdh
ZjEyZmE2Li4uLgkzCTEyCTIxCTI4CTMxCTQwCTQxCTUwIFNVQ0NFU1MKCkJpc2VjdGluZzog
NyByZXZpc2lvbnMgbGVmdCB0byB0ZXN0IGFmdGVyIHRoaXMgKHJvdWdobHkgMyBzdGVwcykK
WzMwZjNhNDBmOWEyYTI4NjlhNTYwYTljYjllZjQ4OGQxMGM4MDNlMTRdIG5ldDogcmVtb3Zl
IGxhc3QgY2FsbGVyIG9mIHNrYl90YWlsX29mZnNldCgpIGFuZCBpdHNlbGYKcnVubmluZyAv
Yy9rZXJuZWwtdGVzdHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9u
ZXQvb2JqLWJpc2VjdApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0
LXJhbmRjb25maWctYzIxLTA2MTEvbmV0LW5leHQ6bWFzdGVyOjMwZjNhNDBmOWEyYTI4Njlh
NTYwYTljYjllZjQ4OGQxMGM4MDNlMTQ6YmlzZWN0LW5ldAoKMjAxMy0wNi0xMi0yMzowODoz
NiAzMGYzYTQwZjlhMmEyODY5YTU2MGE5Y2I5ZWY0ODhkMTBjODAzZTE0IGNvbXBpbGluZwox
MjAgcmVhbCAgOTkzIHVzZXIgIDkwIHN5cyAgODk3LjQ3JSBjcHUgCXg4Nl82NC1yYW5kY29u
ZmlnLWMyMS0wNjExCgoyMDEzLTA2LTEyLTIzOjEwOjUzIGRldGVjdGluZyBib290IHN0YXRl
IDMuMTAuMC1yYzQtMTU3NjktZzMwZjNhNDAuLi4JNQkxNwkzOAk0Mgk1MCBTVUNDRVNTCgpC
aXNlY3Rpbmc6IDMgcmV2aXNpb25zIGxlZnQgdG8gdGVzdCBhZnRlciB0aGlzIChyb3VnaGx5
IDIgc3RlcHMpCls4MjQ5MTUyYzQ3MmUxMGMxODkzNmI3NzQ3MzdmZDU4YzYwMzM1MTU0XSB4
ZW4tbmV0ZnJvbnQ6IHVzZSBza2JfcGFydGlhbF9jc3VtX3NldCgpIHRvIHNpbXBsaWZ5IHRo
ZSBjb2RlcwpydW5uaW5nIC9jL2tlcm5lbC10ZXN0cy9iaXNlY3QtdGVzdC1ib290LWZhaWx1
cmUuc2ggL2hvbWUvd2ZnL25ldC9vYmotYmlzZWN0CmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS9uZXQtbmV4dDptYXN0ZXI6
ODI0OTE1MmM0NzJlMTBjMTg5MzZiNzc0NzM3ZmQ1OGM2MDMzNTE1NDpiaXNlY3QtbmV0Cgoy
MDEzLTA2LTEyLTIzOjE1OjAwIDgyNDkxNTJjNDcyZTEwYzE4OTM2Yjc3NDczN2ZkNThjNjAz
MzUxNTQgY29tcGlsaW5nCjE0MiByZWFsICA5OTYgdXNlciAgODcgc3lzICA3NjIuMTAlIGNw
dSAJeDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEKCjIwMTMtMDYtMTItMjM6MTk6MTAgZGV0
ZWN0aW5nIGJvb3Qgc3RhdGUgMy4xMC4wLXJjNC0xNTc3My1nODI0OTE1Mi4uLi4JMTIJMTYJ
MjMJNDIJNDgJNTAgU1VDQ0VTUwoKQmlzZWN0aW5nOiAxIHJldmlzaW9uIGxlZnQgdG8gdGVz
dCBhZnRlciB0aGlzIChyb3VnaGx5IDEgc3RlcCkKW2I0MWFiYjQyYmY2MmE4NWEzMmM0MWRh
Yjg3MzIyMDU5OGE2ZWUyNjZdIG5ldDogcGFzcyBjb3JyZWN0IHBhcmFtZXRlciB0byBza2Jf
aGVhZGVyc19vZmZzZXRfdXBkYXRlKCkKcnVubmluZyAvYy9rZXJuZWwtdGVzdHMvYmlzZWN0
LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2VjdApscyAtYSAv
a2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEv
bmV0LW5leHQ6bWFzdGVyOmI0MWFiYjQyYmY2MmE4NWEzMmM0MWRhYjg3MzIyMDU5OGE2ZWUy
NjY6YmlzZWN0LW5ldAoKMjAxMy0wNi0xMi0yMzoyNDoxNSBiNDFhYmI0MmJmNjJhODVhMzJj
NDFkYWI4NzMyMjA1OThhNmVlMjY2IGNvbXBpbGluZwoxMjAgcmVhbCAgOTg0IHVzZXIgIDg2
IHN5cyAgODg3LjQ1JSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWMyMS0wNjExCgoyMDEzLTA2
LTEyLTIzOjI2OjMzIGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQtMTU3NzUtZ2I0
MWFiYjQuLi4JNAkxMCBURVNUIEZBSUxVUkUKG1sxOzM1bUluY3JlYXNpbmcgcmVwZWF0IGNv
dW50IGZyb20gNTAgdG8gNjUbWzBtCmRtZXNnLWt2bS1sa3AtbmV4MDQtMjI1ODUtMjAxMzA2
MTIyMjIwNTUtMy4xMC4wLXJjNC0xNTc3NS1nYjQxYWJiNC0xMAoKQmlzZWN0aW5nOiAwIHJl
dmlzaW9ucyBsZWZ0IHRvIHRlc3QgYWZ0ZXIgdGhpcyAocm91Z2hseSAwIHN0ZXBzKQpbZGEx
MmM5MGUwOTk3ODlhNjMwNzNmYzgyYTE5NTQyY2U1NGQ0ZWZiOV0gbmV0bGluazogQWRkIGNv
bXBhcmUgZnVuY3Rpb24gZm9yIG5ldGxpbmtfdGFibGUKcnVubmluZyAvYy9rZXJuZWwtdGVz
dHMvYmlzZWN0LXRlc3QtYm9vdC1mYWlsdXJlLnNoIC9ob21lL3dmZy9uZXQvb2JqLWJpc2Vj
dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0veDg2XzY0LXJhbmRjb25maWct
YzIxLTA2MTEvbmV0LW5leHQ6bWFzdGVyOmRhMTJjOTBlMDk5Nzg5YTYzMDczZmM4MmExOTU0
MmNlNTRkNGVmYjk6YmlzZWN0LW5ldAoKMjAxMy0wNi0xMi0yMzoyOTowNyBkYTEyYzkwZTA5
OTc4OWE2MzA3M2ZjODJhMTk1NDJjZTU0ZDRlZmI5IGNvbXBpbGluZwoxMjUgcmVhbCAgOTky
IHVzZXIgIDg4IHN5cyAgODYzLjIwJSBjcHUgCXg4Nl82NC1yYW5kY29uZmlnLWMyMS0wNjEx
CgoyMDEzLTA2LTEyLTIzOjMxOjI4IGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQt
MTU3NzQtZ2RhMTJjOTAuLi4JMiBURVNUIEZBSUxVUkUKZG1lc2cta3ZtLWJheS0yODI5NS0y
MDEzMDYxMjIzMzU0MC0zLjEwLjAtcmM0LTE1Nzc0LWdkYTEyYzkwLTExCgpkYTEyYzkwZTA5
OTc4OWE2MzA3M2ZjODJhMTk1NDJjZTU0ZDRlZmI5IGlzIHRoZSBmaXJzdCBiYWQgY29tbWl0
CmNvbW1pdCBkYTEyYzkwZTA5OTc4OWE2MzA3M2ZjODJhMTk1NDJjZTU0ZDRlZmI5CkF1dGhv
cjogR2FvIGZlbmcgPGdhb2ZlbmdAY24uZnVqaXRzdS5jb20+CkRhdGU6ICAgVGh1IEp1biA2
IDE0OjQ5OjExIDIwMTMgKzA4MDAKCiAgICBuZXRsaW5rOiBBZGQgY29tcGFyZSBmdW5jdGlv
biBmb3IgbmV0bGlua190YWJsZQogICAgCiAgICBBcyB3ZSBrbm93LCBuZXRsaW5rIHNvY2tl
dHMgYXJlIHByaXZhdGUgcmVzb3VyY2Ugb2YKICAgIG5ldCBuYW1lc3BhY2UsIHRoZXkgY2Fu
IGNvbW11bmljYXRlIHdpdGggZWFjaCBvdGhlcgogICAgb25seSB3aGVuIHRoZXkgaW4gdGhl
IHNhbWUgbmV0IG5hbWVzcGFjZS4gdGhpcyB3b3JrcwogICAgd2VsbCB1bnRpbCB3ZSB0cnkg
dG8gYWRkIG5hbWVzcGFjZSBzdXBwb3J0IGZvciBvdGhlcgogICAgc3Vic3lzdGVtcyB3aGlj
aCB1c2UgbmV0bGluay4KICAgIAogICAgRG9uJ3QgbGlrZSBpcHY0IGFuZCByb3V0ZSB0YWJs
ZS4uLCBpdCBpcyBub3Qgc3VpdGVkIHRvCiAgICBtYWtlIHRoZXNlIHN1YnN5dGVtcyBiZWxv
bmcgdG8gbmV0IG5hbWVzcGFjZSwgU3VjaCBhcwogICAgYXVkaXQgYW5kIGNyeXB0byBzdWJz
eXN0ZW1zLHRoZXkgYXJlIG1vcmUgc3VpdGFibGUgdG8KICAgIHVzZXIgbmFtZXNwYWNlLgog
ICAgCiAgICBTbyB3ZSBtdXN0IGhhdmUgdGhlIGFiaWxpdHkgdG8gbWFrZSB0aGUgbmV0bGlu
ayBzb2NrZXRzCiAgICBpbiBzYW1lIHVzZXIgbmFtZXNwYWNlIGNhbiBjb21tdW5pY2F0ZSB3
aXRoIGVhY2ggb3RoZXIuCiAgICAKICAgIFRoaXMgcGF0Y2ggYWRkcyBhIG5ldyBmdW5jdGlv
biBwb2ludGVyICJjb21wYXJlIiBmb3IKICAgIG5ldGxpbmtfdGFibGUsIHdlIGNhbiBkZWNp
ZGUgaWYgdGhlIG5ldGxpbmsgc29ja2V0cyBjYW4KICAgIGNvbW11bmljYXRlIHdpdGggZWFj
aCBvdGhlciB0aHJvdWdoIHRoaXMgbmV0bGlua190YWJsZQogICAgc2VsZi1kZWZpbmVkIGNv
bXBhcmUgZnVuY3Rpb24uCiAgICAKICAgIFRoZSBiZWhhdmlvciBpc24ndCBjaGFuZ2VkIGlm
IHdlIGRvbid0IHByb3ZpZGUgdGhlIGNvbXBhcmUKICAgIGZ1bmN0aW9uIGZvciBuZXRsaW5r
X3RhYmxlLgogICAgCiAgICBTaWduZWQtb2ZmLWJ5OiBHYW8gZmVuZyA8Z2FvZmVuZ0Bjbi5m
dWppdHN1LmNvbT4KICAgIEFja2VkLWJ5OiBTZXJnZSBFLiBIYWxseW4gPHNlcmdlLmhhbGx5
bkB1YnVudHUuY29tPgogICAgU2lnbmVkLW9mZi1ieTogRGF2aWQgUy4gTWlsbGVyIDxkYXZl
bUBkYXZlbWxvZnQubmV0PgoKOjA0MDAwMCAwNDAwMDAgZDYxMTUyYmQ5ZTJlMTU1ZWE0ZjNk
ODlkYjM1YjMyOWNjZGJjOTk3MSBjNDhiMjU0NDgxMzEzOTZkNzM1ZThmNmVmNzQzMzE5ZDBl
NjQzYWMzIE0JaW5jbHVkZQo6MDQwMDAwIDA0MDAwMCBiZDRiNTJhZmI4ZDRhYmM2NGYzZmEw
YzkxMDYyZWU3NmIxODg2NjYyIGY3MjhiODc0MGM1OTIyYWIxZjM4NzU2YzY0OTM5N2FmYzk3
YWMyZWEgTQluZXQKYmlzZWN0IHJ1biBzdWNjZXNzCmxzIC1hIC9rZXJuZWwtdGVzdHMvcnVu
LXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS9uZXQtbmV4dDptYXN0ZXI6
ODI0OTE1MmM0NzJlMTBjMTg5MzZiNzc0NzM3ZmQ1OGM2MDMzNTE1NDpiaXNlY3QtbmV0Cgoy
MDEzLTA2LTEyLTIzOjMzOjM3IDgyNDkxNTJjNDcyZTEwYzE4OTM2Yjc3NDczN2ZkNThjNjAz
MzUxNTQgcmV1c2UgL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS84MjQ5MTUy
YzQ3MmUxMGMxODkzNmI3NzQ3MzdmZDU4YzYwMzM1MTU0L3ZtbGludXotMy4xMC4wLXJjNC0x
NTc3My1nODI0OTE1MgoKMjAxMy0wNi0xMi0yMzozMzozOCBkZXRlY3RpbmcgYm9vdCBzdGF0
ZSAuLi4uLgk1NAk1OAk2Ngk3MAk3My4JNzUJNzgJNzkJODAJODYJODkJOTIJOTYJMTAwCTEw
MQkxMDMJMTA5CTExMgkxMTMJMTI0CTEyOQkxMzAJMTMyCTE0MgkxNDQJMTQ1CTE0OAkxNTEJ
MTUyCTE1NwkxNjUJMTY3CTE3NAkxNzYJMTg2CTE5MwkxOTUgU1VDQ0VTUwoKbHMgLWEgL2tl
cm5lbC10ZXN0cy9ydW4tcXVldWUva3ZtL3g4Nl82NC1yYW5kY29uZmlnLWMyMS0wNjExL25l
dC1uZXh0Om1hc3RlcjoxMzBkM2Q2OGI1MjA5N2M3YWUwODExMDlmNzAwYjAyNzc2YWRjYjlj
OmJpc2VjdC1uZXQKIFRFU1QgRkFJTFVSRQova2VybmVsL3g4Nl82NC1yYW5kY29uZmlnLWMy
MS0wNjExLzEzMGQzZDY4YjUyMDk3YzdhZTA4MTEwOWY3MDBiMDI3NzZhZGNiOWMvZG1lc2ct
a3ZtLWJlbnMtNzg5Ni0yMDEzMDYxMjE0MDMyMi0zLjEwLjAtcmM0LTAwNTkwLWcxMzBkM2Q2
LTMyCi9rZXJuZWwveDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEvMTMwZDNkNjhiNTIwOTdj
N2FlMDgxMTA5ZjcwMGIwMjc3NmFkY2I5Yy9kbWVzZy1rdm0tdnAtMjc0MTItMjAxMzA2MTIx
NDA1NDQtMy4xMC4wLXJjNC0wMDU5MC1nMTMwZDNkNi0zMgova2VybmVsL3g4Nl82NC1yYW5k
Y29uZmlnLWMyMS0wNjExLzEzMGQzZDY4YjUyMDk3YzdhZTA4MTEwOWY3MDBiMDI3NzZhZGNi
OWMvZG1lc2cta3ZtLXZwLTMwMDA0LTIwMTMwNjEyMTg0MzE2LTMuMTAuMC1yYzQtMDA1OTAt
ZzEzMGQzZDYtMzIKL2tlcm5lbC94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYxMS8xMzBkM2Q2
OGI1MjA5N2M3YWUwODExMDlmNzAwYjAyNzc2YWRjYjljL2RtZXNnLWt2bS12cC0zMDkwNy0y
MDEzMDYxMjE0MDU1Ny0zLjEwLjAtcmM0LTAwNTkwLWcxMzBkM2Q2LTMyCi9rZXJuZWwveDg2
XzY0LXJhbmRjb25maWctYzIxLTA2MTEvMTMwZDNkNjhiNTIwOTdjN2FlMDgxMTA5ZjcwMGIw
Mjc3NmFkY2I5Yy9kbWVzZy1rdm0td2FpbWVhLTI4MzI4LTIwMTMwNjEyMTQwODIzLTMuMTAu
MC1yYzQtMDA1OTAtZzEzMGQzZDYtMzIKCltkZXRhY2hlZCBIRUFEIDI3MDE2YjhdIFJldmVy
dCAibmV0bGluazogQWRkIGNvbXBhcmUgZnVuY3Rpb24gZm9yIG5ldGxpbmtfdGFibGUiCiAz
IGZpbGVzIGNoYW5nZWQsIDggaW5zZXJ0aW9ucygrKSwgMjcgZGVsZXRpb25zKC0pCmxzIC1h
IC9rZXJuZWwtdGVzdHMvcnVuLXF1ZXVlL2t2bS94ODZfNjQtcmFuZGNvbmZpZy1jMjEtMDYx
MS9uZXQtbmV4dDptYXN0ZXI6MjcwMTZiODI1ZWY5MDdkOGQ4NDQ2ZmM1MDBiYjhkMjNiNTc1
NDZhNjpiaXNlY3QtbmV0CgoyMDEzLTA2LTEyLTIzOjU1OjI1IDI3MDE2YjgyNWVmOTA3ZDhk
ODQ0NmZjNTAwYmI4ZDIzYjU3NTQ2YTYgY29tcGlsaW5nCgoyMDEzLTA2LTEyLTIzOjU3OjU5
IGRldGVjdGluZyBib290IHN0YXRlIDMuMTAuMC1yYzQtMTU3NzgtZzI3MDE2YjguLi4JOQkx
MQkxMgkyNQk0Ngk0Nwk1NAk3NAk4OAk5NQkxMDQJMTI1CTE0MAkxNDIJMTUwCTE3MgkxODEJ
MTg2CTE5MQkxOTMuLgkxOTQuCTE5NSBTVUNDRVNTCgoKPT09PT09PT09IHVwc3RyZWFtID09
PT09PT09PQpGZXRjaGluZyBsaW51cwpscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9r
dm0veDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEvbmV0LW5leHQ6bWFzdGVyOjc3MjkzZTIx
NWVkZWY3ODcxYTM5ZGU0YjMyNmY3NzdiYzM5Mjc4Y2E6YmlzZWN0LW5ldAoKMjAxMy0wNi0x
My0wMDoxMjozMSA3NzI5M2UyMTVlZGVmNzg3MWEzOWRlNGIzMjZmNzc3YmMzOTI3OGNhIGNv
bXBpbGluZwoKMjAxMy0wNi0xMy0wMDoxNTowMCBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEw
LjAtcmM1LTAwMDYxLWc3NzI5M2UyLi4uCTQJOQk0MQk1MAk1MQk1Nwk2NQk4MAk4Mwk4NQk5
NQkxMTIJMTE0CTExOQkxMzEJMTQ3CTE0OAkxNTEJMTYwCTE3MAkxODAJMTg1CTE4NwkxOTQu
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uG1sxOzM1bWFkZF90b19ydW5fcXVldWUg
MRtbMG0KLi4uLi4uLi4JMTk1IFNVQ0NFU1MKCgo9PT09PT09PT0gbGludXgtbmV4dCA9PT09
PT09PT0KRmV0Y2hpbmcgbmV4dApscyAtYSAva2VybmVsLXRlc3RzL3J1bi1xdWV1ZS9rdm0v
eDg2XzY0LXJhbmRjb25maWctYzIxLTA2MTEvbmV0LW5leHQ6bWFzdGVyOmMwNGVmZWQ3MzQ0
MDlmNWE0NDcxNWI1NGE2Y2ExYjU0YjBjY2YyMTU6YmlzZWN0LW5ldAoKMjAxMy0wNi0xMy0w
MzoxMDoxNSBjMDRlZmVkNzM0NDA5ZjVhNDQ3MTViNTRhNmNhMWI1NGIwY2NmMjE1IGNvbXBp
bGluZwoKMjAxMy0wNi0xMy0wMzoxMzowNyBkZXRlY3RpbmcgYm9vdCBzdGF0ZSAzLjEwLjAt
cmM0LW5leHQtMjAxMzA2MDctMDUwMDEtZ2MwNGVmZWQuLi4JMwk0Li4uCTUuCTcJOQkxNAk0
MQk1MQk1Nwk2NC4JNjUuCTY2CTc0CTc3CTEwMAkxMTEJMTE3CTEzNwkxNjQJMTcyCTE3OAkx
OTAJMTk0Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4u
Li4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLi4uLhtbMTszNW1hZGRfdG9fcnVu
X3F1ZXVlIDEbWzBtCi4uLi4JMTk1IFNVQ0NFU1MKCg==

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=".config-bisect"

#
# Automatically generated file; DO NOT EDIT.
# Linux/x86_64 3.10.0-rc4 Kernel Configuration
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
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_ARCH_HAS_CPU_RELAX=y
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
CONFIG_ARCH_HWEIGHT_CFLAGS="-fcall-saved-rdi -fcall-saved-rsi -fcall-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r10 -fcall-saved-r11"
CONFIG_ARCH_SUPPORTS_UPROBES=y
CONFIG_DEFCONFIG_LIST="/lib/modules/$UNAME_RELEASE/.config"
CONFIG_CONSTRUCTORS=y
CONFIG_IRQ_WORK=y
CONFIG_BUILDTIME_EXTABLE_SORT=y

#
# General setup
#
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
CONFIG_KERNEL_GZIP=y
# CONFIG_KERNEL_BZIP2 is not set
# CONFIG_KERNEL_LZMA is not set
# CONFIG_KERNEL_XZ is not set
# CONFIG_KERNEL_LZO is not set
CONFIG_DEFAULT_HOSTNAME="(none)"
# CONFIG_SWAP is not set
CONFIG_SYSVIPC=y
# CONFIG_POSIX_MQUEUE is not set
# CONFIG_FHANDLE is not set
# CONFIG_AUDIT is not set
CONFIG_HAVE_GENERIC_HARDIRQS=y

#
# IRQ subsystem
#
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_GENERIC_IRQ_SHOW=y
CONFIG_GENERIC_IRQ_CHIP=y
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
CONFIG_HZ_PERIODIC=y
# CONFIG_NO_HZ_IDLE is not set
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
# CONFIG_TASKSTATS is not set

#
# RCU Subsystem
#
CONFIG_TINY_RCU=y
# CONFIG_PREEMPT_RCU is not set
# CONFIG_RCU_STALL_COMMON is not set
# CONFIG_TREE_RCU_TRACE is not set
CONFIG_IKCONFIG=y
CONFIG_LOG_BUF_SHIFT=17
CONFIG_HAVE_UNSTABLE_SCHED_CLOCK=y
CONFIG_ARCH_SUPPORTS_NUMA_BALANCING=y
CONFIG_ARCH_WANTS_PROT_NUMA_PROT_NONE=y
CONFIG_CGROUPS=y
# CONFIG_CGROUP_DEBUG is not set
# CONFIG_CGROUP_FREEZER is not set
CONFIG_CGROUP_DEVICE=y
# CONFIG_CPUSETS is not set
# CONFIG_CGROUP_CPUACCT is not set
# CONFIG_RESOURCE_COUNTERS is not set
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_SCHED=y
CONFIG_FAIR_GROUP_SCHED=y
# CONFIG_CFS_BANDWIDTH is not set
CONFIG_RT_GROUP_SCHED=y
# CONFIG_BLK_CGROUP is not set
# CONFIG_CHECKPOINT_RESTORE is not set
CONFIG_NAMESPACES=y
# CONFIG_UTS_NS is not set
CONFIG_IPC_NS=y
# CONFIG_USER_NS is not set
CONFIG_PID_NS=y
CONFIG_NET_NS=y
CONFIG_UIDGID_CONVERTED=y
CONFIG_UIDGID_STRICT_TYPE_CHECKS=y
CONFIG_SCHED_AUTOGROUP=y
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
CONFIG_SYSCTL_EXCEPTION_TRACE=y
CONFIG_HOTPLUG=y
CONFIG_HAVE_PCSPKR_PLATFORM=y
CONFIG_EXPERT=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_PRINTK=y
CONFIG_BUG=y
# CONFIG_ELF_CORE is not set
# CONFIG_PCSPKR_PLATFORM is not set
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
# CONFIG_EPOLL is not set
CONFIG_SIGNALFD=y
# CONFIG_TIMERFD is not set
CONFIG_EVENTFD=y
# CONFIG_SHMEM is not set
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
CONFIG_VM_EVENT_COUNTERS=y
CONFIG_SLUB_DEBUG=y
CONFIG_COMPAT_BRK=y
# CONFIG_SLAB is not set
CONFIG_SLUB=y
# CONFIG_SLOB is not set
# CONFIG_PROFILING is not set
CONFIG_HAVE_OPROFILE=y
CONFIG_OPROFILE_NMI_TIMER=y
# CONFIG_JUMP_LABEL is not set
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
CONFIG_HAVE_ALIGNED_STRUCT_PAGE=y
CONFIG_HAVE_CMPXCHG_LOCAL=y
CONFIG_HAVE_CMPXCHG_DOUBLE=y
CONFIG_HAVE_ARCH_SECCOMP_FILTER=y
CONFIG_HAVE_CONTEXT_TRACKING=y
CONFIG_HAVE_IRQ_TIME_ACCOUNTING=y
CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE=y
CONFIG_MODULES_USE_ELF_RELA=y

#
# GCOV-based kernel profiling
#
CONFIG_GCOV_KERNEL=y
# CONFIG_GCOV_PROFILE_ALL is not set
# CONFIG_HAVE_GENERIC_DMA_COHERENT is not set
CONFIG_RT_MUTEXES=y
CONFIG_BASE_SMALL=0
# CONFIG_MODULES is not set
CONFIG_BLOCK=y
CONFIG_BLK_DEV_BSG=y
CONFIG_BLK_DEV_BSGLIB=y
# CONFIG_BLK_DEV_INTEGRITY is not set

#
# Partition Types
#
CONFIG_PARTITION_ADVANCED=y
# CONFIG_ACORN_PARTITION is not set
# CONFIG_OSF_PARTITION is not set
CONFIG_AMIGA_PARTITION=y
# CONFIG_ATARI_PARTITION is not set
CONFIG_MAC_PARTITION=y
CONFIG_MSDOS_PARTITION=y
CONFIG_BSD_DISKLABEL=y
CONFIG_MINIX_SUBPARTITION=y
# CONFIG_SOLARIS_X86_PARTITION is not set
# CONFIG_UNIXWARE_DISKLABEL is not set
# CONFIG_LDM_PARTITION is not set
# CONFIG_SGI_PARTITION is not set
CONFIG_ULTRIX_PARTITION=y
CONFIG_SUN_PARTITION=y
CONFIG_KARMA_PARTITION=y
# CONFIG_EFI_PARTITION is not set
# CONFIG_SYSV68_PARTITION is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_IOSCHED_CFQ=y
CONFIG_DEFAULT_CFQ=y
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="cfq"
CONFIG_UNINLINE_SPIN_UNLOCK=y
CONFIG_FREEZER=y

#
# Processor type and features
#
# CONFIG_ZONE_DMA is not set
# CONFIG_SMP is not set
# CONFIG_X86_MPPARSE is not set
# CONFIG_X86_EXTENDED_PLATFORM is not set
# CONFIG_X86_INTEL_LPSS is not set
# CONFIG_SCHED_OMIT_FRAME_POINTER is not set
# CONFIG_HYPERVISOR_GUEST is not set
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
# CONFIG_PROCESSOR_SELECT is not set
CONFIG_CPU_SUP_INTEL=y
CONFIG_CPU_SUP_AMD=y
CONFIG_CPU_SUP_CENTAUR=y
CONFIG_HPET_TIMER=y
CONFIG_DMI=y
CONFIG_GART_IOMMU=y
# CONFIG_CALGARY_IOMMU is not set
CONFIG_SWIOTLB=y
CONFIG_IOMMU_HELPER=y
CONFIG_NR_CPUS=1
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
CONFIG_X86_REROUTE_FOR_BROKEN_BOOT_IRQS=y
# CONFIG_X86_MCE is not set
# CONFIG_I8K is not set
CONFIG_MICROCODE=y
CONFIG_MICROCODE_INTEL=y
# CONFIG_MICROCODE_AMD is not set
CONFIG_MICROCODE_OLD_INTERFACE=y
CONFIG_MICROCODE_INTEL_LIB=y
CONFIG_MICROCODE_INTEL_EARLY=y
CONFIG_MICROCODE_EARLY=y
# CONFIG_X86_MSR is not set
CONFIG_X86_CPUID=y
CONFIG_ARCH_PHYS_ADDR_T_64BIT=y
CONFIG_ARCH_DMA_ADDR_T_64BIT=y
# CONFIG_DIRECT_GBPAGES is not set
CONFIG_ARCH_SPARSEMEM_ENABLE=y
CONFIG_ARCH_SPARSEMEM_DEFAULT=y
CONFIG_ARCH_SELECT_MEMORY_MODEL=y
CONFIG_ARCH_MEMORY_PROBE=y
CONFIG_ILLEGAL_POINTER_VALUE=0xdead000000000000
CONFIG_SELECT_MEMORY_MODEL=y
CONFIG_SPARSEMEM_MANUAL=y
CONFIG_SPARSEMEM=y
CONFIG_HAVE_MEMORY_PRESENT=y
CONFIG_SPARSEMEM_EXTREME=y
CONFIG_SPARSEMEM_VMEMMAP_ENABLE=y
CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER=y
# CONFIG_SPARSEMEM_VMEMMAP is not set
CONFIG_HAVE_MEMBLOCK=y
CONFIG_HAVE_MEMBLOCK_NODE_MAP=y
CONFIG_ARCH_DISCARD_MEMBLOCK=y
# CONFIG_HAVE_BOOTMEM_INFO_NODE is not set
CONFIG_MEMORY_HOTPLUG=y
CONFIG_MEMORY_HOTPLUG_SPARSE=y
# CONFIG_MEMORY_HOTREMOVE is not set
CONFIG_PAGEFLAGS_EXTENDED=y
CONFIG_SPLIT_PTLOCK_CPUS=999999
CONFIG_COMPACTION=y
CONFIG_MIGRATION=y
CONFIG_PHYS_ADDR_T_64BIT=y
CONFIG_ZONE_DMA_FLAG=0
CONFIG_VIRT_TO_BUS=y
# CONFIG_KSM is not set
CONFIG_DEFAULT_MMAP_MIN_ADDR=4096
# CONFIG_TRANSPARENT_HUGEPAGE is not set
# CONFIG_CROSS_MEMORY_ATTACH is not set
CONFIG_NEED_PER_CPU_KM=y
# CONFIG_CLEANCACHE is not set
CONFIG_X86_CHECK_BIOS_CORRUPTION=y
# CONFIG_X86_BOOTPARAM_MEMORY_CORRUPTION_CHECK is not set
CONFIG_X86_RESERVE_LOW=64
# CONFIG_MTRR is not set
CONFIG_ARCH_RANDOM=y
# CONFIG_X86_SMAP is not set
# CONFIG_EFI is not set
# CONFIG_SECCOMP is not set
CONFIG_CC_STACKPROTECTOR=y
# CONFIG_HZ_100 is not set
# CONFIG_HZ_250 is not set
CONFIG_HZ_300=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=300
CONFIG_SCHED_HRTICK=y
CONFIG_KEXEC=y
# CONFIG_CRASH_DUMP is not set
CONFIG_PHYSICAL_START=0x1000000
# CONFIG_RELOCATABLE is not set
CONFIG_PHYSICAL_ALIGN=0x1000000
# CONFIG_CMDLINE_BOOL is not set
CONFIG_ARCH_ENABLE_MEMORY_HOTPLUG=y
CONFIG_ARCH_ENABLE_MEMORY_HOTREMOVE=y

#
# Power management and ACPI options
#
CONFIG_SUSPEND=y
CONFIG_SUSPEND_FREEZER=y
CONFIG_PM_SLEEP=y
CONFIG_PM_AUTOSLEEP=y
CONFIG_PM_WAKELOCKS=y
CONFIG_PM_WAKELOCKS_LIMIT=100
CONFIG_PM_WAKELOCKS_GC=y
# CONFIG_PM_RUNTIME is not set
CONFIG_PM=y
# CONFIG_PM_DEBUG is not set
CONFIG_ACPI=y
CONFIG_ACPI_SLEEP=y
# CONFIG_ACPI_EC_DEBUGFS is not set
CONFIG_ACPI_AC=y
CONFIG_ACPI_BATTERY=y
CONFIG_ACPI_BUTTON=y
# CONFIG_ACPI_VIDEO is not set
CONFIG_ACPI_FAN=y
# CONFIG_ACPI_DOCK is not set
CONFIG_ACPI_I2C=y
CONFIG_ACPI_PROCESSOR=y
# CONFIG_ACPI_PROCESSOR_AGGREGATOR is not set
CONFIG_ACPI_THERMAL=y
# CONFIG_ACPI_CUSTOM_DSDT is not set
# CONFIG_ACPI_INITRD_TABLE_OVERRIDE is not set
CONFIG_ACPI_BLACKLIST_YEAR=0
# CONFIG_ACPI_DEBUG is not set
# CONFIG_ACPI_PCI_SLOT is not set
CONFIG_X86_PM_TIMER=y
# CONFIG_ACPI_CONTAINER is not set
# CONFIG_ACPI_HOTPLUG_MEMORY is not set
# CONFIG_ACPI_SBS is not set
# CONFIG_ACPI_HED is not set
# CONFIG_ACPI_CUSTOM_METHOD is not set
# CONFIG_ACPI_APEI is not set
CONFIG_SFI=y

#
# CPU Frequency scaling
#
CONFIG_CPU_FREQ=y
CONFIG_CPU_FREQ_TABLE=y
CONFIG_CPU_FREQ_GOV_COMMON=y
# CONFIG_CPU_FREQ_STAT is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_PERFORMANCE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_POWERSAVE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_USERSPACE is not set
# CONFIG_CPU_FREQ_DEFAULT_GOV_ONDEMAND is not set
CONFIG_CPU_FREQ_DEFAULT_GOV_CONSERVATIVE=y
CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
CONFIG_CPU_FREQ_GOV_POWERSAVE=y
CONFIG_CPU_FREQ_GOV_USERSPACE=y
CONFIG_CPU_FREQ_GOV_ONDEMAND=y
CONFIG_CPU_FREQ_GOV_CONSERVATIVE=y

#
# x86 CPU frequency scaling drivers
#
CONFIG_X86_INTEL_PSTATE=y
# CONFIG_X86_PCC_CPUFREQ is not set
# CONFIG_X86_ACPI_CPUFREQ is not set
# CONFIG_X86_SPEEDSTEP_CENTRINO is not set
# CONFIG_X86_P4_CLOCKMOD is not set

#
# shared options
#
# CONFIG_X86_SPEEDSTEP_LIB is not set
CONFIG_CPU_IDLE=y
CONFIG_CPU_IDLE_MULTIPLE_DRIVERS=y
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
# CONFIG_PCI_MMCONFIG is not set
CONFIG_PCI_DOMAINS=y
# CONFIG_PCI_CNB20LE_QUIRK is not set
CONFIG_PCIEPORTBUS=y
CONFIG_HOTPLUG_PCI_PCIE=y
CONFIG_PCIEAER=y
# CONFIG_PCIE_ECRC is not set
# CONFIG_PCIEAER_INJECT is not set
CONFIG_PCIEASPM=y
# CONFIG_PCIEASPM_DEBUG is not set
# CONFIG_PCIEASPM_DEFAULT is not set
# CONFIG_PCIEASPM_POWERSAVE is not set
CONFIG_PCIEASPM_PERFORMANCE=y
CONFIG_ARCH_SUPPORTS_MSI=y
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_DEBUG is not set
# CONFIG_PCI_REALLOC_ENABLE_AUTO is not set
# CONFIG_PCI_STUB is not set
CONFIG_HT_IRQ=y
# CONFIG_PCI_ATS is not set
# CONFIG_PCI_IOV is not set
# CONFIG_PCI_PRI is not set
# CONFIG_PCI_PASID is not set
# CONFIG_PCI_IOAPIC is not set
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
# CONFIG_YENTA is not set
CONFIG_PD6729=y
CONFIG_I82092=y
CONFIG_PCCARD_NONSTATIC=y
CONFIG_HOTPLUG_PCI=y
# CONFIG_HOTPLUG_PCI_ACPI is not set
# CONFIG_HOTPLUG_PCI_CPCI is not set
# CONFIG_HOTPLUG_PCI_SHPC is not set
CONFIG_RAPIDIO=y
# CONFIG_RAPIDIO_TSI721 is not set
CONFIG_RAPIDIO_DISC_TIMEOUT=30
CONFIG_RAPIDIO_ENABLE_RX_TX_PORTS=y
CONFIG_RAPIDIO_DMA_ENGINE=y
CONFIG_RAPIDIO_DEBUG=y
CONFIG_RAPIDIO_ENUM_BASIC=y
CONFIG_RAPIDIO_TSI57X=y
CONFIG_RAPIDIO_CPS_XX=y
# CONFIG_RAPIDIO_TSI568 is not set
# CONFIG_RAPIDIO_CPS_GEN2 is not set
CONFIG_RAPIDIO_TSI500=y

#
# Executable file formats / Emulations
#
CONFIG_BINFMT_ELF=y
CONFIG_ARCH_BINFMT_ELF_RANDOMIZE_PIE=y
CONFIG_BINFMT_SCRIPT=y
# CONFIG_HAVE_AOUT is not set
CONFIG_BINFMT_MISC=y
CONFIG_COREDUMP=y
# CONFIG_IA32_EMULATION is not set
CONFIG_HAVE_TEXT_POKE_SMP=y
CONFIG_X86_DEV_DMA_OPS=y
CONFIG_NET=y

#
# Networking options
#
# CONFIG_PACKET is not set
CONFIG_UNIX=y
# CONFIG_UNIX_DIAG is not set
# CONFIG_NET_KEY is not set
# CONFIG_INET is not set
# CONFIG_NETWORK_SECMARK is not set
# CONFIG_NETWORK_PHY_TIMESTAMPING is not set
# CONFIG_NETFILTER is not set
# CONFIG_ATM is not set
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set
# CONFIG_X25 is not set
# CONFIG_LAPB is not set
# CONFIG_PHONET is not set
# CONFIG_IEEE802154 is not set
# CONFIG_NET_SCHED is not set
# CONFIG_DCB is not set
# CONFIG_BATMAN_ADV is not set
# CONFIG_OPENVSWITCH is not set
# CONFIG_VSOCKETS is not set
# CONFIG_NETLINK_MMAP is not set
# CONFIG_NETLINK_DIAG is not set
# CONFIG_NET_MPLS_GSO is not set
# CONFIG_NETPRIO_CGROUP is not set
# CONFIG_NET_LL_RX_POLL is not set
CONFIG_BQL=y

#
# Network testing
#
# CONFIG_HAMRADIO is not set
# CONFIG_CAN is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
CONFIG_WIRELESS=y
# CONFIG_CFG80211 is not set
# CONFIG_LIB80211 is not set

#
# CFG80211 needs to be enabled for MAC80211
#
# CONFIG_WIMAX is not set
# CONFIG_RFKILL is not set
# CONFIG_RFKILL_REGULATOR is not set
# CONFIG_NET_9P is not set
# CONFIG_CAIF is not set
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
# CONFIG_FW_LOADER_USER_HELPER is not set
# CONFIG_DEBUG_DRIVER is not set
CONFIG_DEBUG_DEVRES=y
# CONFIG_SYS_HYPERVISOR is not set
# CONFIG_GENERIC_CPU_DEVICES is not set
CONFIG_REGMAP=y
CONFIG_REGMAP_I2C=y
CONFIG_REGMAP_MMIO=y
CONFIG_REGMAP_IRQ=y
# CONFIG_DMA_SHARED_BUFFER is not set

#
# Bus devices
#
# CONFIG_CONNECTOR is not set
# CONFIG_MTD is not set
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
# CONFIG_PARPORT_SERIAL is not set
# CONFIG_PARPORT_PC_FIFO is not set
# CONFIG_PARPORT_PC_SUPERIO is not set
CONFIG_PARPORT_PC_PCMCIA=y
# CONFIG_PARPORT_GSC is not set
# CONFIG_PARPORT_AX88796 is not set
CONFIG_PARPORT_1284=y
CONFIG_PNP=y
CONFIG_PNP_DEBUG_MESSAGES=y

#
# Protocols
#
CONFIG_PNPACPI=y
CONFIG_BLK_DEV=y
CONFIG_BLK_DEV_FD=y
# CONFIG_PARIDE is not set
CONFIG_BLK_DEV_PCIESSD_MTIP32XX=y
CONFIG_BLK_CPQ_DA=y
# CONFIG_BLK_CPQ_CISS_DA is not set
CONFIG_BLK_DEV_DAC960=y
CONFIG_BLK_DEV_UMEM=y
# CONFIG_BLK_DEV_COW_COMMON is not set
CONFIG_BLK_DEV_LOOP=y
CONFIG_BLK_DEV_LOOP_MIN_COUNT=8
# CONFIG_BLK_DEV_CRYPTOLOOP is not set

#
# DRBD disabled because PROC_FS or INET not selected
#
# CONFIG_BLK_DEV_NBD is not set
CONFIG_BLK_DEV_NVME=y
CONFIG_BLK_DEV_SX8=y
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=4096
CONFIG_BLK_DEV_XIP=y
CONFIG_CDROM_PKTCDVD=y
CONFIG_CDROM_PKTCDVD_BUFFERS=8
CONFIG_CDROM_PKTCDVD_WCACHE=y
# CONFIG_ATA_OVER_ETH is not set
# CONFIG_VIRTIO_BLK is not set
CONFIG_BLK_DEV_HD=y
CONFIG_BLK_DEV_RSXX=y

#
# Misc devices
#
# CONFIG_SENSORS_LIS3LV02D is not set
# CONFIG_AD525X_DPOT is not set
CONFIG_DUMMY_IRQ=y
# CONFIG_IBM_ASM is not set
CONFIG_PHANTOM=y
# CONFIG_INTEL_MID_PTI is not set
# CONFIG_SGI_IOC4 is not set
CONFIG_TIFM_CORE=y
CONFIG_TIFM_7XX1=y
CONFIG_ICS932S401=y
# CONFIG_ATMEL_SSC is not set
# CONFIG_ENCLOSURE_SERVICES is not set
CONFIG_CS5535_MFGPT=y
CONFIG_CS5535_MFGPT_DEFAULT_IRQ=7
CONFIG_CS5535_CLOCK_EVENT_SRC=y
CONFIG_HP_ILO=y
CONFIG_APDS9802ALS=y
CONFIG_ISL29003=y
# CONFIG_ISL29020 is not set
# CONFIG_SENSORS_TSL2550 is not set
# CONFIG_SENSORS_BH1780 is not set
CONFIG_SENSORS_BH1770=y
# CONFIG_SENSORS_APDS990X is not set
# CONFIG_HMC6352 is not set
CONFIG_DS1682=y
CONFIG_BMP085=y
CONFIG_BMP085_I2C=y
CONFIG_PCH_PHUB=y
CONFIG_USB_SWITCH_FSA9480=y
# CONFIG_SRAM is not set
# CONFIG_C2PORT is not set

#
# EEPROM support
#
CONFIG_EEPROM_AT24=y
# CONFIG_EEPROM_LEGACY is not set
# CONFIG_EEPROM_MAX6875 is not set
CONFIG_EEPROM_93CX6=y
CONFIG_CB710_CORE=y
CONFIG_CB710_DEBUG=y
CONFIG_CB710_DEBUG_ASSUMPTIONS=y

#
# Texas Instruments shared transport line discipline
#
# CONFIG_TI_ST is not set
# CONFIG_SENSORS_LIS3_I2C is not set

#
# Altera FPGA firmware download module
#
CONFIG_ALTERA_STAPL=y
CONFIG_INTEL_MEI=y
CONFIG_INTEL_MEI_ME=y
# CONFIG_VMWARE_VMCI is not set
CONFIG_HAVE_IDE=y
# CONFIG_IDE is not set

#
# SCSI device support
#
CONFIG_SCSI_MOD=y
# CONFIG_RAID_ATTRS is not set
CONFIG_SCSI=y
CONFIG_SCSI_DMA=y
# CONFIG_SCSI_TGT is not set
# CONFIG_SCSI_NETLINK is not set

#
# SCSI support type (disk, tape, CD-ROM)
#
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_ST=y
CONFIG_CHR_DEV_OSST=y
CONFIG_BLK_DEV_SR=y
# CONFIG_BLK_DEV_SR_VENDOR is not set
CONFIG_CHR_DEV_SG=y
CONFIG_CHR_DEV_SCH=y
CONFIG_SCSI_MULTI_LUN=y
# CONFIG_SCSI_CONSTANTS is not set
# CONFIG_SCSI_LOGGING is not set
CONFIG_SCSI_SCAN_ASYNC=y

#
# SCSI Transports
#
# CONFIG_SCSI_SPI_ATTRS is not set
# CONFIG_SCSI_FC_ATTRS is not set
# CONFIG_SCSI_ISCSI_ATTRS is not set
# CONFIG_SCSI_SAS_ATTRS is not set
# CONFIG_SCSI_SAS_LIBSAS is not set
CONFIG_SCSI_SRP_ATTRS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_SCSI_LOWLEVEL_PCMCIA=y
CONFIG_SCSI_DH=y
CONFIG_SCSI_DH_RDAC=y
# CONFIG_SCSI_DH_HP_SW is not set
CONFIG_SCSI_DH_EMC=y
CONFIG_SCSI_DH_ALUA=y
CONFIG_SCSI_OSD_INITIATOR=y
# CONFIG_SCSI_OSD_ULD is not set
CONFIG_SCSI_OSD_DPRINT_SENSE=1
# CONFIG_SCSI_OSD_DEBUG is not set
CONFIG_ATA=y
# CONFIG_ATA_NONSTANDARD is not set
# CONFIG_ATA_VERBOSE_ERROR is not set
CONFIG_ATA_ACPI=y
# CONFIG_SATA_ZPODD is not set
# CONFIG_SATA_PMP is not set

#
# Controllers with non-SFF native interface
#
CONFIG_SATA_AHCI=y
CONFIG_SATA_AHCI_PLATFORM=y
# CONFIG_SATA_INIC162X is not set
# CONFIG_SATA_ACARD_AHCI is not set
CONFIG_SATA_SIL24=y
# CONFIG_ATA_SFF is not set

#
# SFF controllers with custom DMA interface
#
CONFIG_PDC_ADMA=y
# CONFIG_SATA_QSTOR is not set
CONFIG_SATA_SX4=y
CONFIG_ATA_BMDMA=y

#
# SATA SFF controllers with BMDMA
#
CONFIG_ATA_PIIX=y
CONFIG_SATA_HIGHBANK=y
CONFIG_SATA_MV=y
# CONFIG_SATA_NV is not set
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
# CONFIG_PATA_ARTOP is not set
# CONFIG_PATA_ATIIXP is not set
CONFIG_PATA_ATP867X=y
CONFIG_PATA_CMD64X=y
CONFIG_PATA_CS5520=y
# CONFIG_PATA_CS5530 is not set
# CONFIG_PATA_CS5536 is not set
CONFIG_PATA_CYPRESS=y
CONFIG_PATA_EFAR=y
CONFIG_PATA_HPT366=y
CONFIG_PATA_HPT37X=y
CONFIG_PATA_HPT3X2N=y
CONFIG_PATA_HPT3X3=y
# CONFIG_PATA_HPT3X3_DMA is not set
CONFIG_PATA_IT8213=y
CONFIG_PATA_IT821X=y
# CONFIG_PATA_JMICRON is not set
# CONFIG_PATA_MARVELL is not set
# CONFIG_PATA_NETCELL is not set
CONFIG_PATA_NINJA32=y
# CONFIG_PATA_NS87415 is not set
# CONFIG_PATA_OLDPIIX is not set
# CONFIG_PATA_OPTIDMA is not set
CONFIG_PATA_PDC2027X=y
CONFIG_PATA_PDC_OLD=y
CONFIG_PATA_RADISYS=y
CONFIG_PATA_RDC=y
# CONFIG_PATA_SC1200 is not set
CONFIG_PATA_SCH=y
# CONFIG_PATA_SERVERWORKS is not set
CONFIG_PATA_SIL680=y
CONFIG_PATA_SIS=y
CONFIG_PATA_TOSHIBA=y
# CONFIG_PATA_TRIFLEX is not set
CONFIG_PATA_VIA=y
# CONFIG_PATA_WINBOND is not set

#
# PIO-only SFF controllers
#
CONFIG_PATA_CMD640_PCI=y
CONFIG_PATA_MPIIX=y
CONFIG_PATA_NS87410=y
# CONFIG_PATA_OPTI is not set
CONFIG_PATA_PCMCIA=y
# CONFIG_PATA_PLATFORM is not set
CONFIG_PATA_RZ1000=y

#
# Generic fallback / legacy drivers
#
# CONFIG_PATA_ACPI is not set
CONFIG_ATA_GENERIC=y
CONFIG_PATA_LEGACY=y
CONFIG_MD=y
CONFIG_BLK_DEV_MD=y
CONFIG_MD_AUTODETECT=y
CONFIG_MD_LINEAR=y
CONFIG_MD_RAID0=y
CONFIG_MD_RAID1=y
CONFIG_MD_RAID10=y
# CONFIG_MD_RAID456 is not set
CONFIG_MD_MULTIPATH=y
CONFIG_MD_FAULTY=y
CONFIG_BCACHE=y
# CONFIG_BCACHE_DEBUG is not set
CONFIG_BCACHE_EDEBUG=y
# CONFIG_BCACHE_CLOSURES_DEBUG is not set
# CONFIG_BLK_DEV_DM is not set
# CONFIG_TARGET_CORE is not set
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
CONFIG_FIREWIRE=y
CONFIG_FIREWIRE_OHCI=y
CONFIG_FIREWIRE_SBP2=y
CONFIG_FIREWIRE_NOSY=y
CONFIG_I2O=y
# CONFIG_I2O_LCT_NOTIFY_ON_CHANGES is not set
CONFIG_I2O_EXT_ADAPTEC=y
CONFIG_I2O_EXT_ADAPTEC_DMA64=y
CONFIG_I2O_CONFIG=y
# CONFIG_I2O_CONFIG_OLD_IOCTL is not set
CONFIG_I2O_BUS=y
# CONFIG_I2O_BLOCK is not set
CONFIG_I2O_SCSI=y
# CONFIG_I2O_PROC is not set
CONFIG_MACINTOSH_DRIVERS=y
# CONFIG_NETDEVICES is not set
# CONFIG_VHOST_NET is not set

#
# Input device support
#
CONFIG_INPUT=y
# CONFIG_INPUT_FF_MEMLESS is not set
# CONFIG_INPUT_POLLDEV is not set
# CONFIG_INPUT_SPARSEKMAP is not set
# CONFIG_INPUT_MATRIXKMAP is not set

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
CONFIG_INPUT_MOUSEDEV_PSAUX=y
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_EVDEV is not set
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
# CONFIG_KEYBOARD_XTKBD is not set
CONFIG_INPUT_MOUSE=y
CONFIG_MOUSE_PS2=y
CONFIG_MOUSE_PS2_ALPS=y
CONFIG_MOUSE_PS2_LOGIPS2PP=y
CONFIG_MOUSE_PS2_SYNAPTICS=y
CONFIG_MOUSE_PS2_CYPRESS=y
CONFIG_MOUSE_PS2_LIFEBOOK=y
CONFIG_MOUSE_PS2_TRACKPOINT=y
# CONFIG_MOUSE_PS2_ELANTECH is not set
# CONFIG_MOUSE_PS2_SENTELIC is not set
# CONFIG_MOUSE_PS2_TOUCHKIT is not set
# CONFIG_MOUSE_SERIAL is not set
# CONFIG_MOUSE_APPLETOUCH is not set
# CONFIG_MOUSE_BCM5974 is not set
# CONFIG_MOUSE_CYAPA is not set
# CONFIG_MOUSE_VSXXXAA is not set
# CONFIG_MOUSE_GPIO is not set
# CONFIG_MOUSE_SYNAPTICS_I2C is not set
# CONFIG_MOUSE_SYNAPTICS_USB is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TABLET is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
CONFIG_SERIO_SERPORT=y
# CONFIG_SERIO_CT82C710 is not set
CONFIG_SERIO_PARKBD=y
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
CONFIG_SERIO_RAW=y
CONFIG_SERIO_ALTERA_PS2=y
CONFIG_SERIO_PS2MULT=y
CONFIG_SERIO_ARC_PS2=y
# CONFIG_GAMEPORT is not set

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
CONFIG_DEVKMEM=y

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
# CONFIG_SERIAL_8250_CS is not set
CONFIG_SERIAL_8250_NR_UARTS=4
CONFIG_SERIAL_8250_RUNTIME_UARTS=4
# CONFIG_SERIAL_8250_EXTENDED is not set
# CONFIG_SERIAL_8250_DW is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_MFD_HSU is not set
# CONFIG_SERIAL_UARTLITE is not set
CONFIG_SERIAL_CORE=y
CONFIG_SERIAL_CORE_CONSOLE=y
# CONFIG_SERIAL_JSM is not set
# CONFIG_SERIAL_SCCNXP is not set
# CONFIG_SERIAL_TIMBERDALE is not set
# CONFIG_SERIAL_ALTERA_JTAGUART is not set
# CONFIG_SERIAL_ALTERA_UART is not set
# CONFIG_SERIAL_PCH_UART is not set
# CONFIG_SERIAL_ARC is not set
# CONFIG_SERIAL_RP2 is not set
# CONFIG_TTY_PRINTK is not set
# CONFIG_PRINTER is not set
CONFIG_PPDEV=y
# CONFIG_VIRTIO_CONSOLE is not set
# CONFIG_IPMI_HANDLER is not set
CONFIG_HW_RANDOM=y
CONFIG_HW_RANDOM_TIMERIOMEM=y
CONFIG_HW_RANDOM_INTEL=y
CONFIG_HW_RANDOM_AMD=y
# CONFIG_HW_RANDOM_VIA is not set
# CONFIG_HW_RANDOM_VIRTIO is not set
# CONFIG_HW_RANDOM_TPM is not set
# CONFIG_NVRAM is not set
# CONFIG_R3964 is not set
CONFIG_APPLICOM=y

#
# PCMCIA character devices
#
# CONFIG_SYNCLINK_CS is not set
# CONFIG_CARDMAN_4000 is not set
# CONFIG_CARDMAN_4040 is not set
# CONFIG_MWAVE is not set
CONFIG_RAW_DRIVER=y
CONFIG_MAX_RAW_DEVS=256
# CONFIG_HPET is not set
# CONFIG_HANGCHECK_TIMER is not set
CONFIG_TCG_TPM=y
# CONFIG_TCG_TIS is not set
# CONFIG_TCG_TIS_I2C_INFINEON is not set
# CONFIG_TCG_NSC is not set
CONFIG_TCG_ATMEL=y
# CONFIG_TCG_INFINEON is not set
# CONFIG_TCG_ST33_I2C is not set
CONFIG_TELCLOCK=y
CONFIG_DEVPORT=y
CONFIG_I2C=y
CONFIG_I2C_BOARDINFO=y
CONFIG_I2C_COMPAT=y
# CONFIG_I2C_CHARDEV is not set
CONFIG_I2C_MUX=y

#
# Multiplexer I2C Chip support
#
# CONFIG_I2C_MUX_GPIO is not set
# CONFIG_I2C_MUX_PCA9541 is not set
CONFIG_I2C_MUX_PCA954x=y
# CONFIG_I2C_HELPER_AUTO is not set
CONFIG_I2C_SMBUS=y

#
# I2C Algorithms
#
CONFIG_I2C_ALGOBIT=y
CONFIG_I2C_ALGOPCF=y
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
# CONFIG_I2C_AMD8111 is not set
# CONFIG_I2C_I801 is not set
# CONFIG_I2C_ISCH is not set
# CONFIG_I2C_ISMT is not set
CONFIG_I2C_PIIX4=y
# CONFIG_I2C_NFORCE2 is not set
# CONFIG_I2C_SIS5595 is not set
CONFIG_I2C_SIS630=y
CONFIG_I2C_SIS96X=y
# CONFIG_I2C_VIA is not set
CONFIG_I2C_VIAPRO=y

#
# ACPI drivers
#
# CONFIG_I2C_SCMI is not set

#
# I2C system bus drivers (mostly embedded / system-on-chip)
#
CONFIG_I2C_CBUS_GPIO=y
# CONFIG_I2C_DESIGNWARE_PCI is not set
CONFIG_I2C_EG20T=y
CONFIG_I2C_GPIO=y
CONFIG_I2C_INTEL_MID=y
CONFIG_I2C_OCORES=y
# CONFIG_I2C_PCA_PLATFORM is not set
# CONFIG_I2C_PXA_PCI is not set
CONFIG_I2C_SIMTEC=y
CONFIG_I2C_XILINX=y

#
# External I2C/SMBus adapter drivers
#
# CONFIG_I2C_PARPORT is not set
CONFIG_I2C_PARPORT_LIGHT=y
# CONFIG_I2C_TAOS_EVM is not set

#
# Other I2C/SMBus bus drivers
#
# CONFIG_I2C_DEBUG_CORE is not set
# CONFIG_I2C_DEBUG_ALGO is not set
# CONFIG_I2C_DEBUG_BUS is not set
# CONFIG_SPI is not set

#
# Qualcomm MSM SSBI bus support
#
CONFIG_SSBI=y
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
# CONFIG_PPS_CLIENT_LDISC is not set
# CONFIG_PPS_CLIENT_PARPORT is not set
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
CONFIG_GPIO_DA9052=y
CONFIG_GPIO_DA9055=y
CONFIG_GPIO_MAX730X=y

#
# Memory mapped GPIO drivers:
#
# CONFIG_GPIO_GENERIC_PLATFORM is not set
CONFIG_GPIO_IT8761E=y
# CONFIG_GPIO_TS5500 is not set
CONFIG_GPIO_SCH=y
# CONFIG_GPIO_ICH is not set
CONFIG_GPIO_VX855=y
# CONFIG_GPIO_LYNXPOINT is not set

#
# I2C GPIO expanders:
#
CONFIG_GPIO_ARIZONA=y
CONFIG_GPIO_MAX7300=y
CONFIG_GPIO_MAX732X=y
CONFIG_GPIO_MAX732X_IRQ=y
# CONFIG_GPIO_PCA953X is not set
# CONFIG_GPIO_PCF857X is not set
# CONFIG_GPIO_RC5T583 is not set
# CONFIG_GPIO_SX150X is not set
# CONFIG_GPIO_TPS65912 is not set
# CONFIG_GPIO_WM831X is not set
CONFIG_GPIO_WM8350=y
CONFIG_GPIO_ADP5588=y
# CONFIG_GPIO_ADP5588_IRQ is not set

#
# PCI GPIO expanders:
#
CONFIG_GPIO_CS5535=y
CONFIG_GPIO_BT8XX=y
CONFIG_GPIO_AMD8111=y
CONFIG_GPIO_LANGWELL=y
CONFIG_GPIO_PCH=y
CONFIG_GPIO_ML_IOH=y
CONFIG_GPIO_TIMBERDALE=y
# CONFIG_GPIO_RDC321X is not set

#
# SPI GPIO expanders:
#
# CONFIG_GPIO_MCP23S08 is not set

#
# AC97 GPIO expanders:
#

#
# MODULbus GPIO expanders:
#
CONFIG_GPIO_JANZ_TTL=y
CONFIG_GPIO_PALMAS=y
# CONFIG_GPIO_TPS6586X is not set
CONFIG_GPIO_TPS65910=y

#
# USB GPIO expanders:
#
# CONFIG_W1 is not set
CONFIG_POWER_SUPPLY=y
# CONFIG_POWER_SUPPLY_DEBUG is not set
# CONFIG_PDA_POWER is not set
# CONFIG_GENERIC_ADC_BATTERY is not set
# CONFIG_MAX8925_POWER is not set
# CONFIG_WM831X_BACKUP is not set
# CONFIG_WM831X_POWER is not set
# CONFIG_WM8350_POWER is not set
# CONFIG_TEST_POWER is not set
# CONFIG_BATTERY_88PM860X is not set
# CONFIG_BATTERY_DS2780 is not set
# CONFIG_BATTERY_DS2781 is not set
# CONFIG_BATTERY_DS2782 is not set
# CONFIG_BATTERY_SBS is not set
# CONFIG_BATTERY_BQ27x00 is not set
# CONFIG_BATTERY_DA9052 is not set
# CONFIG_BATTERY_MAX17040 is not set
# CONFIG_BATTERY_MAX17042 is not set
# CONFIG_CHARGER_PCF50633 is not set
# CONFIG_CHARGER_MAX8903 is not set
# CONFIG_CHARGER_LP8727 is not set
# CONFIG_CHARGER_LP8788 is not set
# CONFIG_CHARGER_GPIO is not set
# CONFIG_CHARGER_BQ2415X is not set
# CONFIG_CHARGER_SMB347 is not set
# CONFIG_CHARGER_TPS65090 is not set
# CONFIG_BATTERY_GOLDFISH is not set
# CONFIG_POWER_RESET is not set
CONFIG_POWER_AVS=y
CONFIG_HWMON=y
CONFIG_HWMON_VID=y
CONFIG_HWMON_DEBUG_CHIP=y

#
# Native drivers
#
CONFIG_SENSORS_ABITUGURU=y
# CONFIG_SENSORS_ABITUGURU3 is not set
CONFIG_SENSORS_AD7414=y
CONFIG_SENSORS_AD7418=y
# CONFIG_SENSORS_ADM1021 is not set
# CONFIG_SENSORS_ADM1025 is not set
CONFIG_SENSORS_ADM1026=y
CONFIG_SENSORS_ADM1029=y
CONFIG_SENSORS_ADM1031=y
CONFIG_SENSORS_ADM9240=y
CONFIG_SENSORS_ADT7X10=y
CONFIG_SENSORS_ADT7410=y
CONFIG_SENSORS_ADT7411=y
CONFIG_SENSORS_ADT7462=y
CONFIG_SENSORS_ADT7470=y
# CONFIG_SENSORS_ADT7475 is not set
CONFIG_SENSORS_ASC7621=y
CONFIG_SENSORS_K8TEMP=y
# CONFIG_SENSORS_K10TEMP is not set
CONFIG_SENSORS_FAM15H_POWER=y
# CONFIG_SENSORS_ASB100 is not set
CONFIG_SENSORS_ATXP1=y
# CONFIG_SENSORS_DS620 is not set
CONFIG_SENSORS_DS1621=y
CONFIG_SENSORS_DA9052_ADC=y
# CONFIG_SENSORS_DA9055 is not set
CONFIG_SENSORS_I5K_AMB=y
CONFIG_SENSORS_F71805F=y
CONFIG_SENSORS_F71882FG=y
CONFIG_SENSORS_F75375S=y
# CONFIG_SENSORS_FSCHMD is not set
CONFIG_SENSORS_G760A=y
CONFIG_SENSORS_GL518SM=y
CONFIG_SENSORS_GL520SM=y
CONFIG_SENSORS_GPIO_FAN=y
CONFIG_SENSORS_HIH6130=y
CONFIG_SENSORS_CORETEMP=y
CONFIG_SENSORS_IIO_HWMON=y
# CONFIG_SENSORS_IT87 is not set
CONFIG_SENSORS_JC42=y
# CONFIG_SENSORS_LINEAGE is not set
CONFIG_SENSORS_LM63=y
CONFIG_SENSORS_LM73=y
CONFIG_SENSORS_LM75=y
CONFIG_SENSORS_LM77=y
CONFIG_SENSORS_LM78=y
CONFIG_SENSORS_LM80=y
# CONFIG_SENSORS_LM83 is not set
# CONFIG_SENSORS_LM85 is not set
# CONFIG_SENSORS_LM87 is not set
CONFIG_SENSORS_LM90=y
# CONFIG_SENSORS_LM92 is not set
CONFIG_SENSORS_LM93=y
CONFIG_SENSORS_LTC4151=y
CONFIG_SENSORS_LTC4215=y
CONFIG_SENSORS_LTC4245=y
CONFIG_SENSORS_LTC4261=y
CONFIG_SENSORS_LM95234=y
CONFIG_SENSORS_LM95241=y
# CONFIG_SENSORS_LM95245 is not set
CONFIG_SENSORS_MAX16065=y
CONFIG_SENSORS_MAX1619=y
CONFIG_SENSORS_MAX1668=y
CONFIG_SENSORS_MAX197=y
CONFIG_SENSORS_MAX6639=y
CONFIG_SENSORS_MAX6642=y
CONFIG_SENSORS_MAX6650=y
# CONFIG_SENSORS_MAX6697 is not set
# CONFIG_SENSORS_MCP3021 is not set
CONFIG_SENSORS_NCT6775=y
CONFIG_SENSORS_PC87360=y
CONFIG_SENSORS_PC87427=y
CONFIG_SENSORS_PCF8591=y
# CONFIG_PMBUS is not set
CONFIG_SENSORS_SHT15=y
CONFIG_SENSORS_SHT21=y
# CONFIG_SENSORS_SIS5595 is not set
CONFIG_SENSORS_SMM665=y
CONFIG_SENSORS_DME1737=y
# CONFIG_SENSORS_EMC1403 is not set
CONFIG_SENSORS_EMC2103=y
CONFIG_SENSORS_EMC6W201=y
# CONFIG_SENSORS_SMSC47M1 is not set
# CONFIG_SENSORS_SMSC47M192 is not set
CONFIG_SENSORS_SMSC47B397=y
CONFIG_SENSORS_SCH56XX_COMMON=y
# CONFIG_SENSORS_SCH5627 is not set
CONFIG_SENSORS_SCH5636=y
# CONFIG_SENSORS_ADS1015 is not set
CONFIG_SENSORS_ADS7828=y
# CONFIG_SENSORS_AMC6821 is not set
CONFIG_SENSORS_INA209=y
# CONFIG_SENSORS_INA2XX is not set
CONFIG_SENSORS_THMC50=y
CONFIG_SENSORS_TMP102=y
CONFIG_SENSORS_TMP401=y
# CONFIG_SENSORS_TMP421 is not set
# CONFIG_SENSORS_VIA_CPUTEMP is not set
CONFIG_SENSORS_VIA686A=y
CONFIG_SENSORS_VT1211=y
CONFIG_SENSORS_VT8231=y
CONFIG_SENSORS_W83781D=y
CONFIG_SENSORS_W83791D=y
CONFIG_SENSORS_W83792D=y
CONFIG_SENSORS_W83793=y
CONFIG_SENSORS_W83795=y
CONFIG_SENSORS_W83795_FANCTRL=y
# CONFIG_SENSORS_W83L785TS is not set
# CONFIG_SENSORS_W83L786NG is not set
CONFIG_SENSORS_W83627HF=y
CONFIG_SENSORS_W83627EHF=y
# CONFIG_SENSORS_WM831X is not set
CONFIG_SENSORS_WM8350=y
# CONFIG_SENSORS_APPLESMC is not set

#
# ACPI drivers
#
# CONFIG_SENSORS_ACPI_POWER is not set
# CONFIG_SENSORS_ATK0110 is not set
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
CONFIG_WATCHDOG_NOWAYOUT=y

#
# Watchdog Device Drivers
#
CONFIG_SOFT_WATCHDOG=y
# CONFIG_DA9052_WATCHDOG is not set
CONFIG_DA9055_WATCHDOG=y
CONFIG_WM831X_WATCHDOG=y
# CONFIG_WM8350_WATCHDOG is not set
CONFIG_RETU_WATCHDOG=y
# CONFIG_ACQUIRE_WDT is not set
CONFIG_ADVANTECH_WDT=y
# CONFIG_ALIM1535_WDT is not set
CONFIG_ALIM7101_WDT=y
CONFIG_F71808E_WDT=y
# CONFIG_SP5100_TCO is not set
# CONFIG_GEODE_WDT is not set
# CONFIG_SC520_WDT is not set
# CONFIG_SBC_FITPC2_WATCHDOG is not set
# CONFIG_EUROTECH_WDT is not set
# CONFIG_IB700_WDT is not set
CONFIG_IBMASR=y
# CONFIG_WAFER_WDT is not set
# CONFIG_I6300ESB_WDT is not set
CONFIG_IE6XX_WDT=y
CONFIG_ITCO_WDT=y
# CONFIG_ITCO_VENDOR_SUPPORT is not set
# CONFIG_IT8712F_WDT is not set
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

#
# PCI-based Watchdog Cards
#
CONFIG_PCIPCWATCHDOG=y
CONFIG_WDTPCI=y
CONFIG_SSB_POSSIBLE=y

#
# Sonics Silicon Backplane
#
CONFIG_SSB=y
CONFIG_SSB_SPROM=y
CONFIG_SSB_PCIHOST_POSSIBLE=y
# CONFIG_SSB_PCIHOST is not set
CONFIG_SSB_PCMCIAHOST_POSSIBLE=y
CONFIG_SSB_PCMCIAHOST=y
CONFIG_SSB_SDIOHOST_POSSIBLE=y
CONFIG_SSB_SDIOHOST=y
CONFIG_SSB_SILENT=y
# CONFIG_SSB_DRIVER_GPIO is not set
CONFIG_BCMA_POSSIBLE=y

#
# Broadcom specific AMBA
#
CONFIG_BCMA=y
CONFIG_BCMA_HOST_PCI_POSSIBLE=y
CONFIG_BCMA_HOST_PCI=y
CONFIG_BCMA_DRIVER_GMAC_CMN=y
CONFIG_BCMA_DRIVER_GPIO=y
CONFIG_BCMA_DEBUG=y

#
# Multifunction device drivers
#
CONFIG_MFD_CORE=y
CONFIG_MFD_CS5535=y
CONFIG_MFD_AS3711=y
# CONFIG_PMIC_ADP5520 is not set
CONFIG_MFD_AAT2870_CORE=y
# CONFIG_MFD_CROS_EC is not set
# CONFIG_PMIC_DA903X is not set
CONFIG_PMIC_DA9052=y
CONFIG_MFD_DA9052_I2C=y
CONFIG_MFD_DA9055=y
# CONFIG_MFD_MC13XXX_I2C is not set
# CONFIG_HTC_PASIC3 is not set
CONFIG_HTC_I2CPLD=y
CONFIG_LPC_ICH=y
CONFIG_LPC_SCH=y
CONFIG_MFD_JANZ_CMODIO=y
# CONFIG_MFD_88PM800 is not set
CONFIG_MFD_88PM805=y
CONFIG_MFD_88PM860X=y
CONFIG_MFD_MAX77686=y
CONFIG_MFD_MAX77693=y
CONFIG_MFD_MAX8907=y
CONFIG_MFD_MAX8925=y
CONFIG_MFD_MAX8997=y
# CONFIG_MFD_MAX8998 is not set
CONFIG_MFD_RETU=y
CONFIG_MFD_PCF50633=y
# CONFIG_PCF50633_ADC is not set
CONFIG_PCF50633_GPIO=y
# CONFIG_UCB1400_CORE is not set
# CONFIG_MFD_RDC321X is not set
CONFIG_MFD_RTSX_PCI=y
CONFIG_MFD_RC5T583=y
# CONFIG_MFD_SEC_CORE is not set
CONFIG_MFD_SI476X_CORE=y
CONFIG_MFD_SM501=y
# CONFIG_MFD_SM501_GPIO is not set
CONFIG_MFD_SMSC=y
# CONFIG_ABX500_CORE is not set
# CONFIG_MFD_STMPE is not set
# CONFIG_MFD_SYSCON is not set
CONFIG_MFD_TI_AM335X_TSCADC=y
CONFIG_MFD_LP8788=y
CONFIG_MFD_PALMAS=y
CONFIG_TPS6105X=y
# CONFIG_TPS65010 is not set
CONFIG_TPS6507X=y
CONFIG_MFD_TPS65090=y
CONFIG_MFD_TPS65217=y
CONFIG_MFD_TPS6586X=y
CONFIG_MFD_TPS65910=y
CONFIG_MFD_TPS65912=y
CONFIG_MFD_TPS65912_I2C=y
# CONFIG_MFD_TPS80031 is not set
# CONFIG_TWL4030_CORE is not set
# CONFIG_TWL6040_CORE is not set
CONFIG_MFD_WL1273_CORE=y
CONFIG_MFD_LM3533=y
CONFIG_MFD_TIMBERDALE=y
# CONFIG_MFD_TC3589X is not set
# CONFIG_MFD_TMIO is not set
CONFIG_MFD_VX855=y
CONFIG_MFD_ARIZONA=y
CONFIG_MFD_ARIZONA_I2C=y
# CONFIG_MFD_WM5102 is not set
# CONFIG_MFD_WM5110 is not set
CONFIG_MFD_WM8400=y
CONFIG_MFD_WM831X=y
CONFIG_MFD_WM831X_I2C=y
CONFIG_MFD_WM8350=y
CONFIG_MFD_WM8350_I2C=y
# CONFIG_MFD_WM8994 is not set
CONFIG_REGULATOR=y
# CONFIG_REGULATOR_DEBUG is not set
# CONFIG_REGULATOR_DUMMY is not set
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_VIRTUAL_CONSUMER=y
# CONFIG_REGULATOR_USERSPACE_CONSUMER is not set
# CONFIG_REGULATOR_GPIO is not set
CONFIG_REGULATOR_AD5398=y
# CONFIG_REGULATOR_AAT2870 is not set
CONFIG_REGULATOR_ARIZONA=y
CONFIG_REGULATOR_DA9052=y
# CONFIG_REGULATOR_DA9055 is not set
CONFIG_REGULATOR_FAN53555=y
# CONFIG_REGULATOR_ISL6271A is not set
# CONFIG_REGULATOR_88PM8607 is not set
# CONFIG_REGULATOR_MAX1586 is not set
CONFIG_REGULATOR_MAX8649=y
CONFIG_REGULATOR_MAX8660=y
CONFIG_REGULATOR_MAX8907=y
CONFIG_REGULATOR_MAX8925=y
CONFIG_REGULATOR_MAX8952=y
CONFIG_REGULATOR_MAX8973=y
# CONFIG_REGULATOR_MAX8997 is not set
CONFIG_REGULATOR_MAX77686=y
CONFIG_REGULATOR_LP3971=y
CONFIG_REGULATOR_LP3972=y
CONFIG_REGULATOR_LP872X=y
# CONFIG_REGULATOR_LP8755 is not set
CONFIG_REGULATOR_LP8788=y
CONFIG_REGULATOR_PCF50633=y
CONFIG_REGULATOR_RC5T583=y
# CONFIG_REGULATOR_PALMAS is not set
# CONFIG_REGULATOR_TPS51632 is not set
CONFIG_REGULATOR_TPS6105X=y
# CONFIG_REGULATOR_TPS62360 is not set
CONFIG_REGULATOR_TPS65023=y
# CONFIG_REGULATOR_TPS6507X is not set
CONFIG_REGULATOR_TPS65090=y
# CONFIG_REGULATOR_TPS65217 is not set
CONFIG_REGULATOR_TPS6586X=y
CONFIG_REGULATOR_TPS65910=y
CONFIG_REGULATOR_TPS65912=y
CONFIG_REGULATOR_WM831X=y
# CONFIG_REGULATOR_WM8350 is not set
CONFIG_REGULATOR_WM8400=y
# CONFIG_REGULATOR_AS3711 is not set
CONFIG_MEDIA_SUPPORT=y

#
# Multimedia core support
#
# CONFIG_MEDIA_CAMERA_SUPPORT is not set
CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
# CONFIG_MEDIA_DIGITAL_TV_SUPPORT is not set
CONFIG_MEDIA_RADIO_SUPPORT=y
# CONFIG_MEDIA_RC_SUPPORT is not set
CONFIG_VIDEO_DEV=y
CONFIG_VIDEO_V4L2=y
CONFIG_VIDEO_ADV_DEBUG=y
# CONFIG_VIDEO_FIXED_MINOR_RANGES is not set
CONFIG_VIDEOBUF_GEN=y
CONFIG_VIDEOBUF_DMA_SG=y
CONFIG_VIDEO_V4L2_INT_DEVICE=y
# CONFIG_TTPCI_EEPROM is not set

#
# Media drivers
#
CONFIG_MEDIA_PCI_SUPPORT=y

#
# Media capture/analog TV support
#
CONFIG_VIDEO_ZORAN=y
CONFIG_VIDEO_ZORAN_DC30=y
CONFIG_VIDEO_ZORAN_ZR36060=y
# CONFIG_VIDEO_ZORAN_BUZ is not set
CONFIG_VIDEO_ZORAN_DC10=y
CONFIG_VIDEO_ZORAN_LML33=y
# CONFIG_VIDEO_ZORAN_LML33R10 is not set
# CONFIG_VIDEO_ZORAN_AVS6EYES is not set
# CONFIG_VIDEO_HEXIUM_GEMINI is not set
CONFIG_VIDEO_HEXIUM_ORION=y
# CONFIG_VIDEO_MXB is not set

#
# Media capture/analog/hybrid TV support
#
CONFIG_VIDEO_CX25821=y
CONFIG_VIDEO_CX25821_ALSA=y
# CONFIG_VIDEO_SAA7134 is not set

#
# Supported MMC/SDIO adapters
#
# CONFIG_RADIO_ADAPTERS is not set
CONFIG_VIDEO_BTCX=y
CONFIG_VIDEO_SAA7146=y
CONFIG_VIDEO_SAA7146_VV=y

#
# Media ancillary drivers (tuners, sensors, i2c, frontends)
#
CONFIG_MEDIA_SUBDRV_AUTOSELECT=y

#
# Audio decoders, processors and mixers
#

#
# RDS decoders
#

#
# Video decoders
#
CONFIG_VIDEO_BT819=y
CONFIG_VIDEO_BT856=y
CONFIG_VIDEO_SAA7110=y
CONFIG_VIDEO_VPX3220=y

#
# Video and audio decoders
#

#
# Video encoders
#
CONFIG_VIDEO_ADV7175=y

#
# Camera sensor devices
#

#
# Flash devices
#

#
# Video improvement chips
#

#
# Miscelaneous helper chips
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
CONFIG_MEDIA_TUNER_TEA5761=y
CONFIG_MEDIA_TUNER_TEA5767=y
CONFIG_MEDIA_TUNER_MT20XX=y
CONFIG_MEDIA_TUNER_XC2028=y
CONFIG_MEDIA_TUNER_XC5000=y
CONFIG_MEDIA_TUNER_XC4000=y
CONFIG_MEDIA_TUNER_MC44S803=y

#
# Tools to develop new frontends
#
# CONFIG_DVB_DUMMY_FE is not set

#
# Graphics support
#
# CONFIG_AGP is not set
CONFIG_VGA_ARB=y
CONFIG_VGA_ARB_MAX_GPUS=16
# CONFIG_VGA_SWITCHEROO is not set
# CONFIG_DRM is not set
# CONFIG_VGASTATE is not set
CONFIG_VIDEO_OUTPUT_CONTROL=y
# CONFIG_FB is not set
CONFIG_EXYNOS_VIDEO=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_LCD_CLASS_DEVICE=y
# CONFIG_LCD_PLATFORM is not set
CONFIG_BACKLIGHT_CLASS_DEVICE=y
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_BACKLIGHT_LM3533=y
CONFIG_BACKLIGHT_PWM=y
CONFIG_BACKLIGHT_DA9052=y
CONFIG_BACKLIGHT_MAX8925=y
# CONFIG_BACKLIGHT_APPLE is not set
CONFIG_BACKLIGHT_SAHARA=y
CONFIG_BACKLIGHT_WM831X=y
CONFIG_BACKLIGHT_ADP8860=y
CONFIG_BACKLIGHT_ADP8870=y
CONFIG_BACKLIGHT_88PM860X=y
CONFIG_BACKLIGHT_PCF50633=y
CONFIG_BACKLIGHT_AAT2870=y
CONFIG_BACKLIGHT_LM3630=y
# CONFIG_BACKLIGHT_LM3639 is not set
CONFIG_BACKLIGHT_LP855X=y
CONFIG_BACKLIGHT_LP8788=y
# CONFIG_BACKLIGHT_OT200 is not set
# CONFIG_BACKLIGHT_TPS65217 is not set
CONFIG_BACKLIGHT_AS3711=y
CONFIG_SOUND=y
CONFIG_SOUND_OSS_CORE=y
# CONFIG_SOUND_OSS_CORE_PRECLAIM is not set
CONFIG_SND=y
CONFIG_SND_TIMER=y
CONFIG_SND_PCM=y
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
CONFIG_SND_DYNAMIC_MINORS=y
# CONFIG_SND_SUPPORT_OLD_API is not set
# CONFIG_SND_VERBOSE_PRINTK is not set
CONFIG_SND_DEBUG=y
CONFIG_SND_DEBUG_VERBOSE=y
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
CONFIG_SND_DUMMY=y
CONFIG_SND_ALOOP=y
CONFIG_SND_VIRMIDI=y
CONFIG_SND_MTPAV=y
CONFIG_SND_MTS64=y
CONFIG_SND_SERIAL_U16550=y
# CONFIG_SND_MPU401 is not set
# CONFIG_SND_PORTMAN2X4 is not set
CONFIG_SND_AC97_POWER_SAVE=y
CONFIG_SND_AC97_POWER_SAVE_DEFAULT=0
CONFIG_SND_SB_COMMON=y
CONFIG_SND_SB16_DSP=y
CONFIG_SND_TEA575X=y
CONFIG_SND_PCI=y
CONFIG_SND_AD1889=y
CONFIG_SND_ALS300=y
CONFIG_SND_ALS4000=y
# CONFIG_SND_ALI5451 is not set
CONFIG_SND_ASIHPI=y
CONFIG_SND_ATIIXP=y
CONFIG_SND_ATIIXP_MODEM=y
# CONFIG_SND_AU8810 is not set
CONFIG_SND_AU8820=y
CONFIG_SND_AU8830=y
CONFIG_SND_AW2=y
CONFIG_SND_AZT3328=y
# CONFIG_SND_BT87X is not set
CONFIG_SND_CA0106=y
CONFIG_SND_CMIPCI=y
CONFIG_SND_OXYGEN_LIB=y
# CONFIG_SND_OXYGEN is not set
# CONFIG_SND_CS4281 is not set
CONFIG_SND_CS46XX=y
CONFIG_SND_CS46XX_NEW_DSP=y
CONFIG_SND_CS5530=y
# CONFIG_SND_CS5535AUDIO is not set
# CONFIG_SND_CTXFI is not set
CONFIG_SND_DARLA20=y
# CONFIG_SND_GINA20 is not set
CONFIG_SND_LAYLA20=y
CONFIG_SND_DARLA24=y
CONFIG_SND_GINA24=y
CONFIG_SND_LAYLA24=y
CONFIG_SND_MONA=y
# CONFIG_SND_MIA is not set
CONFIG_SND_ECHO3G=y
# CONFIG_SND_INDIGO is not set
CONFIG_SND_INDIGOIO=y
CONFIG_SND_INDIGODJ=y
CONFIG_SND_INDIGOIOX=y
CONFIG_SND_INDIGODJX=y
CONFIG_SND_EMU10K1=y
CONFIG_SND_EMU10K1X=y
CONFIG_SND_ENS1370=y
CONFIG_SND_ENS1371=y
# CONFIG_SND_ES1938 is not set
CONFIG_SND_ES1968=y
# CONFIG_SND_ES1968_INPUT is not set
CONFIG_SND_ES1968_RADIO=y
CONFIG_SND_FM801=y
# CONFIG_SND_FM801_TEA575X_BOOL is not set
CONFIG_SND_HDA_INTEL=y
CONFIG_SND_HDA_DSP_LOADER=y
CONFIG_SND_HDA_PREALLOC_SIZE=64
CONFIG_SND_HDA_HWDEP=y
CONFIG_SND_HDA_RECONFIG=y
# CONFIG_SND_HDA_INPUT_BEEP is not set
# CONFIG_SND_HDA_INPUT_JACK is not set
# CONFIG_SND_HDA_PATCH_LOADER is not set
# CONFIG_SND_HDA_CODEC_REALTEK is not set
# CONFIG_SND_HDA_CODEC_ANALOG is not set
CONFIG_SND_HDA_CODEC_SIGMATEL=y
CONFIG_SND_HDA_CODEC_VIA=y
# CONFIG_SND_HDA_CODEC_HDMI is not set
# CONFIG_SND_HDA_CODEC_CIRRUS is not set
# CONFIG_SND_HDA_CODEC_CONEXANT is not set
# CONFIG_SND_HDA_CODEC_CA0110 is not set
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_CODEC_CA0132_DSP=y
CONFIG_SND_HDA_CODEC_CMEDIA=y
CONFIG_SND_HDA_CODEC_SI3054=y
CONFIG_SND_HDA_GENERIC=y
CONFIG_SND_HDA_POWER_SAVE_DEFAULT=0
CONFIG_SND_HDSP=y

#
# Don't forget to add built-in firmwares for HDSP driver
#
# CONFIG_SND_HDSPM is not set
# CONFIG_SND_ICE1712 is not set
# CONFIG_SND_ICE1724 is not set
CONFIG_SND_INTEL8X0=y
CONFIG_SND_INTEL8X0M=y
# CONFIG_SND_KORG1212 is not set
CONFIG_SND_LOLA=y
CONFIG_SND_LX6464ES=y
# CONFIG_SND_MAESTRO3 is not set
CONFIG_SND_MIXART=y
CONFIG_SND_NM256=y
# CONFIG_SND_PCXHR is not set
# CONFIG_SND_RIPTIDE is not set
CONFIG_SND_RME32=y
CONFIG_SND_RME96=y
# CONFIG_SND_RME9652 is not set
CONFIG_SND_SONICVIBES=y
# CONFIG_SND_TRIDENT is not set
CONFIG_SND_VIA82XX=y
CONFIG_SND_VIA82XX_MODEM=y
CONFIG_SND_VIRTUOSO=y
CONFIG_SND_VX222=y
CONFIG_SND_YMFPCI=y
CONFIG_SND_FIREWIRE=y
CONFIG_SND_FIREWIRE_LIB=y
# CONFIG_SND_FIREWIRE_SPEAKERS is not set
CONFIG_SND_ISIGHT=y
CONFIG_SND_SCS1X=y
CONFIG_SND_PCMCIA=y
CONFIG_SND_VXPOCKET=y
CONFIG_SND_PDAUDIOCF=y
CONFIG_SND_SOC=y
CONFIG_SND_ATMEL_SOC=y
CONFIG_SND_SOC_I2C_AND_SPI=y
# CONFIG_SND_SOC_ALL_CODECS is not set
CONFIG_SND_SIMPLE_CARD=y
CONFIG_SOUND_PRIME=y
CONFIG_SOUND_OSS=y
# CONFIG_SOUND_TRACEINIT is not set
CONFIG_SOUND_DMAP=y
CONFIG_SOUND_VMIDI=y
CONFIG_SOUND_TRIX=y
CONFIG_SOUND_MSS=y
CONFIG_SOUND_MPU401=y
CONFIG_SOUND_PAS=y
# CONFIG_PAS_JOYSTICK is not set
CONFIG_SOUND_PSS=y
CONFIG_PSS_MIXER=y
# CONFIG_SOUND_SB is not set
CONFIG_SOUND_YM3812=y
# CONFIG_SOUND_UART6850 is not set
CONFIG_SOUND_AEDSP16=y
CONFIG_SC6600=y
# CONFIG_SC6600_JOY is not set
CONFIG_SC6600_CDROM=4
CONFIG_SC6600_CDROMBASE=0
CONFIG_AC97_BUS=y

#
# HID support
#
CONFIG_HID=y
# CONFIG_HID_BATTERY_STRENGTH is not set
# CONFIG_HIDRAW is not set
# CONFIG_UHID is not set
CONFIG_HID_GENERIC=y

#
# Special HID drivers
#
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_ACRUX is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_AUREAL is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_PRODIKEYS is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_DRAGONRISE is not set
# CONFIG_HID_EMS_FF is not set
# CONFIG_HID_ELECOM is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_KEYTOUCH is not set
# CONFIG_HID_KYE is not set
# CONFIG_HID_UCLOGIC is not set
# CONFIG_HID_WALTOP is not set
# CONFIG_HID_GYRATION is not set
# CONFIG_HID_ICADE is not set
# CONFIG_HID_TWINHAN is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LCPOWER is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MAGICMOUSE is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_HID_MULTITOUCH is not set
# CONFIG_HID_ORTEK is not set
# CONFIG_HID_PANTHERLORD is not set
# CONFIG_HID_PETALYNX is not set
# CONFIG_HID_PICOLCD is not set
# CONFIG_HID_PRIMAX is not set
# CONFIG_HID_PS3REMOTE is not set
# CONFIG_HID_SAITEK is not set
# CONFIG_HID_SAMSUNG is not set
# CONFIG_HID_SPEEDLINK is not set
# CONFIG_HID_STEELSERIES is not set
# CONFIG_HID_SUNPLUS is not set
# CONFIG_HID_GREENASIA is not set
# CONFIG_HID_SMARTJOYPLUS is not set
# CONFIG_HID_TIVO is not set
# CONFIG_HID_TOPSEED is not set
# CONFIG_HID_THINGM is not set
# CONFIG_HID_THRUSTMASTER is not set
# CONFIG_HID_WACOM is not set
# CONFIG_HID_WIIMOTE is not set
# CONFIG_HID_ZEROPLUS is not set
# CONFIG_HID_ZYDACRON is not set
# CONFIG_HID_SENSOR_HUB is not set

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
# CONFIG_USB is not set
CONFIG_USB_DWC3=y
CONFIG_USB_DWC3_GADGET=y
# CONFIG_USB_DWC3_DEBUG is not set
CONFIG_USB_CHIPIDEA=y
CONFIG_USB_CHIPIDEA_UDC=y
CONFIG_USB_CHIPIDEA_DEBUG=y

#
# USB port drivers
#
# CONFIG_USB_PHY is not set
CONFIG_USB_GADGET=y
# CONFIG_USB_GADGET_DEBUG is not set
CONFIG_USB_GADGET_DEBUG_FS=y
CONFIG_USB_GADGET_VBUS_DRAW=2
CONFIG_USB_GADGET_STORAGE_NUM_BUFFERS=2

#
# USB Peripheral Controller
#
CONFIG_USB_R8A66597=y
# CONFIG_USB_PXA27X is not set
# CONFIG_USB_MV_UDC is not set
CONFIG_USB_MV_U3D=y
CONFIG_USB_M66592=y
CONFIG_USB_AMD5536UDC=y
CONFIG_USB_NET2272=y
CONFIG_USB_NET2272_DMA=y
CONFIG_USB_NET2280=y
# CONFIG_USB_GOKU is not set
CONFIG_USB_EG20T=y
CONFIG_USB_LIBCOMPOSITE=y
CONFIG_USB_F_SS_LB=y
CONFIG_USB_ZERO=y
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
# CONFIG_UWB is not set
CONFIG_MMC=y
CONFIG_MMC_DEBUG=y
# CONFIG_MMC_UNSAFE_RESUME is not set
CONFIG_MMC_CLKGATE=y

#
# MMC/SD/SDIO Card Drivers
#
CONFIG_MMC_BLOCK=y
CONFIG_MMC_BLOCK_MINORS=8
CONFIG_MMC_BLOCK_BOUNCE=y
# CONFIG_SDIO_UART is not set
CONFIG_MMC_TEST=y

#
# MMC/SD/SDIO Host Controller Drivers
#
CONFIG_MMC_SDHCI=y
# CONFIG_MMC_SDHCI_PCI is not set
# CONFIG_MMC_SDHCI_ACPI is not set
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_WBSD=y
CONFIG_MMC_TIFM_SD=y
# CONFIG_MMC_SDRICOH_CS is not set
# CONFIG_MMC_CB710 is not set
CONFIG_MMC_VIA_SDMMC=y
# CONFIG_MMC_REALTEK_PCI is not set
CONFIG_MEMSTICK=y
CONFIG_MEMSTICK_DEBUG=y

#
# MemoryStick drivers
#
# CONFIG_MEMSTICK_UNSAFE_RESUME is not set
CONFIG_MSPRO_BLOCK=y

#
# MemoryStick Host Controller Drivers
#
# CONFIG_MEMSTICK_TIFM_MS is not set
# CONFIG_MEMSTICK_JMICRON_38X is not set
CONFIG_MEMSTICK_R592=y
# CONFIG_MEMSTICK_REALTEK_PCI is not set
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y

#
# LED drivers
#
CONFIG_LEDS_88PM860X=y
# CONFIG_LEDS_LM3530 is not set
# CONFIG_LEDS_LM3533 is not set
CONFIG_LEDS_LM3642=y
# CONFIG_LEDS_PCA9532 is not set
# CONFIG_LEDS_GPIO is not set
CONFIG_LEDS_LP3944=y
CONFIG_LEDS_LP55XX_COMMON=y
# CONFIG_LEDS_LP5521 is not set
# CONFIG_LEDS_LP5523 is not set
CONFIG_LEDS_LP5562=y
CONFIG_LEDS_LP8788=y
# CONFIG_LEDS_CLEVO_MAIL is not set
# CONFIG_LEDS_PCA955X is not set
CONFIG_LEDS_PCA9633=y
CONFIG_LEDS_WM831X_STATUS=y
# CONFIG_LEDS_WM8350 is not set
CONFIG_LEDS_DA9052=y
CONFIG_LEDS_PWM=y
# CONFIG_LEDS_REGULATOR is not set
CONFIG_LEDS_BD2802=y
# CONFIG_LEDS_INTEL_SS4200 is not set
# CONFIG_LEDS_LT3593 is not set
CONFIG_LEDS_TCA6507=y
# CONFIG_LEDS_MAX8997 is not set
CONFIG_LEDS_LM355x=y
CONFIG_LEDS_OT200=y
CONFIG_LEDS_BLINKM=y

#
# LED Triggers
#
# CONFIG_LEDS_TRIGGERS is not set
CONFIG_ACCESSIBILITY=y
# CONFIG_INFINIBAND is not set
# CONFIG_EDAC is not set
CONFIG_RTC_LIB=y
# CONFIG_RTC_CLASS is not set
CONFIG_DMADEVICES=y
CONFIG_DMADEVICES_DEBUG=y
# CONFIG_DMADEVICES_VDEBUG is not set

#
# DMA Devices
#
CONFIG_INTEL_MID_DMAC=y
# CONFIG_INTEL_IOATDMA is not set
CONFIG_DW_DMAC=y
# CONFIG_DW_DMAC_BIG_ENDIAN_IO is not set
# CONFIG_TIMB_DMA is not set
CONFIG_PCH_DMA=y
CONFIG_DMA_ENGINE=y
CONFIG_DMA_ACPI=y

#
# DMA Clients
#
# CONFIG_NET_DMA is not set
CONFIG_ASYNC_TX_DMA=y
CONFIG_DMATEST=y
# CONFIG_AUXDISPLAY is not set
# CONFIG_UIO is not set
CONFIG_VIRT_DRIVERS=y
CONFIG_VIRTIO=y

#
# Virtio drivers
#
CONFIG_VIRTIO_PCI=y
# CONFIG_VIRTIO_BALLOON is not set
CONFIG_VIRTIO_MMIO=y
CONFIG_VIRTIO_MMIO_CMDLINE_DEVICES=y

#
# Microsoft Hyper-V guest support
#
CONFIG_STAGING=y
# CONFIG_SLICOSS is not set
CONFIG_ECHO=y
CONFIG_PANEL=y
CONFIG_PANEL_PARPORT=0
CONFIG_PANEL_PROFILE=5
CONFIG_PANEL_CHANGE_MESSAGE=y
CONFIG_PANEL_BOOT_MESSAGE=""
CONFIG_IDE_PHISON=y
CONFIG_DX_SEP=y

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
# CONFIG_AD799X is not set

#
# Analog digital bi-direction converters
#
CONFIG_ADT7316=y
CONFIG_ADT7316_I2C=y

#
# Capacitance to digital converters
#
# CONFIG_AD7150 is not set
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
CONFIG_AD5933=y

#
# Light sensors
#
CONFIG_SENSORS_ISL29018=y
# CONFIG_SENSORS_ISL29028 is not set
# CONFIG_TSL2583 is not set
# CONFIG_TSL2x7x is not set

#
# Magnetometer sensors
#
CONFIG_SENSORS_HMC5843=y

#
# Active energy metering IC
#
CONFIG_ADE7854=y
CONFIG_ADE7854_I2C=y

#
# Resolver to digital converters
#

#
# Triggers - standalone
#
# CONFIG_IIO_GPIO_TRIGGER is not set
CONFIG_IIO_SYSFS_TRIGGER=y
# CONFIG_IIO_SIMPLE_DUMMY is not set
# CONFIG_ZSMALLOC is not set
# CONFIG_CRYSTALHD is not set
# CONFIG_ACPI_QUICKSTART is not set
CONFIG_FT1000=y
# CONFIG_FT1000_PCMCIA is not set

#
# Speakup console speech
#
# CONFIG_TOUCHSCREEN_CLEARPAD_TM1217 is not set
# CONFIG_TOUCHSCREEN_SYNAPTICS_I2C_RMI4 is not set
# CONFIG_STAGING_MEDIA is not set

#
# Android
#
CONFIG_ANDROID=y
# CONFIG_ANDROID_BINDER_IPC is not set
# CONFIG_ANDROID_LOGGER is not set
# CONFIG_ANDROID_TIMED_OUTPUT is not set
# CONFIG_ANDROID_LOW_MEMORY_KILLER is not set
# CONFIG_SYNC is not set
# CONFIG_WIMAX_GDM72XX is not set
# CONFIG_NET_VENDOR_SILICOM is not set
# CONFIG_DGRP is not set
# CONFIG_FIREWIRE_SERIAL is not set
# CONFIG_X86_PLATFORM_DEVICES is not set

#
# Hardware Spinlock drivers
#
CONFIG_CLKEVT_I8253=y
CONFIG_CLKBLD_I8253=y
# CONFIG_MAILBOX is not set
# CONFIG_IOMMU_SUPPORT is not set

#
# Remoteproc drivers
#
# CONFIG_STE_MODEM_RPROC is not set

#
# Rpmsg drivers
#
CONFIG_PM_DEVFREQ=y

#
# DEVFREQ Governors
#
CONFIG_DEVFREQ_GOV_SIMPLE_ONDEMAND=y
CONFIG_DEVFREQ_GOV_PERFORMANCE=y
CONFIG_DEVFREQ_GOV_POWERSAVE=y
CONFIG_DEVFREQ_GOV_USERSPACE=y

#
# DEVFREQ Drivers
#
# CONFIG_EXTCON is not set
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
# CONFIG_IIO_ST_ACCEL_3AXIS is not set

#
# Analog to digital converters
#
CONFIG_LP8788_ADC=y
CONFIG_MAX1363=y
CONFIG_TI_ADC081C=y
CONFIG_TI_AM335X_ADC=y

#
# Amplifiers
#

#
# Hid Sensor IIO Common
#

#
# Digital to analog converters
#
CONFIG_AD5064=y
# CONFIG_AD5380 is not set
# CONFIG_AD5446 is not set
# CONFIG_MAX517 is not set
# CONFIG_MCP4725 is not set

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
# CONFIG_IIO_ST_GYRO_3AXIS is not set
# CONFIG_ITG3200 is not set

#
# Inertial measurement units
#
CONFIG_INV_MPU6050_IIO=y

#
# Light sensors
#
# CONFIG_ADJD_S311 is not set
# CONFIG_SENSORS_LM3533 is not set
# CONFIG_SENSORS_TSL2563 is not set
# CONFIG_VCNL4000 is not set

#
# Magnetometer sensors
#
# CONFIG_AK8975 is not set
# CONFIG_IIO_ST_MAGN_3AXIS is not set
CONFIG_NTB=y
CONFIG_VME_BUS=y

#
# VME Bridge Drivers
#
CONFIG_VME_CA91CX42=y
# CONFIG_VME_TSI148 is not set

#
# VME Board Drivers
#
CONFIG_VMIVME_7805=y

#
# VME Device Drivers
#
# CONFIG_VME_USER is not set
CONFIG_VME_PIO2=y
CONFIG_PWM=y
CONFIG_IPACK_BUS=y
# CONFIG_BOARD_TPCI200 is not set
# CONFIG_SERIAL_IPOCTAL is not set
# CONFIG_RESET_CONTROLLER is not set

#
# Firmware Drivers
#
CONFIG_EDD=y
CONFIG_EDD_OFF=y
# CONFIG_FIRMWARE_MEMMAP is not set
CONFIG_DELL_RBU=y
CONFIG_DCDBAS=y
CONFIG_DMIID=y
# CONFIG_DMI_SYSFS is not set
# CONFIG_ISCSI_IBFT_FIND is not set
# CONFIG_GOOGLE_FIRMWARE is not set

#
# File systems
#
CONFIG_DCACHE_WORD_ACCESS=y
# CONFIG_EXT2_FS is not set
# CONFIG_EXT3_FS is not set
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
# CONFIG_EXT4_FS_POSIX_ACL is not set
CONFIG_EXT4_FS_SECURITY=y
CONFIG_EXT4_DEBUG=y
CONFIG_JBD2=y
# CONFIG_JBD2_DEBUG is not set
CONFIG_FS_MBCACHE=y
CONFIG_REISERFS_FS=y
# CONFIG_REISERFS_CHECK is not set
# CONFIG_REISERFS_FS_XATTR is not set
CONFIG_JFS_FS=y
# CONFIG_JFS_POSIX_ACL is not set
# CONFIG_JFS_SECURITY is not set
CONFIG_JFS_DEBUG=y
# CONFIG_JFS_STATISTICS is not set
# CONFIG_XFS_FS is not set
CONFIG_GFS2_FS=y
# CONFIG_OCFS2_FS is not set
CONFIG_BTRFS_FS=y
# CONFIG_BTRFS_FS_POSIX_ACL is not set
CONFIG_BTRFS_FS_CHECK_INTEGRITY=y
CONFIG_BTRFS_FS_RUN_SANITY_TESTS=y
CONFIG_BTRFS_DEBUG=y
CONFIG_NILFS2_FS=y
CONFIG_FS_POSIX_ACL=y
CONFIG_FILE_LOCKING=y
CONFIG_FSNOTIFY=y
CONFIG_DNOTIFY=y
CONFIG_INOTIFY_USER=y
CONFIG_FANOTIFY=y
# CONFIG_QUOTA is not set
# CONFIG_QUOTA_NETLINK_INTERFACE is not set
CONFIG_QUOTACTL=y
# CONFIG_AUTOFS4_FS is not set
CONFIG_FUSE_FS=y
CONFIG_CUSE=y

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
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=y
# CONFIG_MSDOS_FS is not set
CONFIG_VFAT_FS=y
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
CONFIG_NTFS_FS=y
CONFIG_NTFS_DEBUG=y
# CONFIG_NTFS_RW is not set

#
# Pseudo filesystems
#
# CONFIG_PROC_FS is not set
CONFIG_SYSFS=y
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NLS=y
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=y
# CONFIG_NLS_CODEPAGE_737 is not set
CONFIG_NLS_CODEPAGE_775=y
CONFIG_NLS_CODEPAGE_850=y
CONFIG_NLS_CODEPAGE_852=y
CONFIG_NLS_CODEPAGE_855=y
CONFIG_NLS_CODEPAGE_857=y
CONFIG_NLS_CODEPAGE_860=y
CONFIG_NLS_CODEPAGE_861=y
# CONFIG_NLS_CODEPAGE_862 is not set
CONFIG_NLS_CODEPAGE_863=y
CONFIG_NLS_CODEPAGE_864=y
CONFIG_NLS_CODEPAGE_865=y
CONFIG_NLS_CODEPAGE_866=y
# CONFIG_NLS_CODEPAGE_869 is not set
CONFIG_NLS_CODEPAGE_936=y
CONFIG_NLS_CODEPAGE_950=y
CONFIG_NLS_CODEPAGE_932=y
# CONFIG_NLS_CODEPAGE_949 is not set
CONFIG_NLS_CODEPAGE_874=y
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
CONFIG_NLS_CODEPAGE_1251=y
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=y
# CONFIG_NLS_ISO8859_2 is not set
CONFIG_NLS_ISO8859_3=y
CONFIG_NLS_ISO8859_4=y
# CONFIG_NLS_ISO8859_5 is not set
CONFIG_NLS_ISO8859_6=y
CONFIG_NLS_ISO8859_7=y
CONFIG_NLS_ISO8859_9=y
# CONFIG_NLS_ISO8859_13 is not set
CONFIG_NLS_ISO8859_14=y
# CONFIG_NLS_ISO8859_15 is not set
CONFIG_NLS_KOI8_R=y
# CONFIG_NLS_KOI8_U is not set
CONFIG_NLS_MAC_ROMAN=y
CONFIG_NLS_MAC_CELTIC=y
# CONFIG_NLS_MAC_CENTEURO is not set
CONFIG_NLS_MAC_CROATIAN=y
CONFIG_NLS_MAC_CYRILLIC=y
CONFIG_NLS_MAC_GAELIC=y
CONFIG_NLS_MAC_GREEK=y
CONFIG_NLS_MAC_ICELAND=y
CONFIG_NLS_MAC_INUIT=y
# CONFIG_NLS_MAC_ROMANIAN is not set
CONFIG_NLS_MAC_TURKISH=y
CONFIG_NLS_UTF8=y

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
# CONFIG_STRIP_ASM_SYMS is not set
# CONFIG_READABLE_ASM is not set
CONFIG_UNUSED_SYMBOLS=y
CONFIG_DEBUG_FS=y
CONFIG_HEADERS_CHECK=y
CONFIG_DEBUG_SECTION_MISMATCH=y
CONFIG_DEBUG_KERNEL=y
# CONFIG_DEBUG_SHIRQ is not set
# CONFIG_LOCKUP_DETECTOR is not set
# CONFIG_PANIC_ON_OOPS is not set
CONFIG_PANIC_ON_OOPS_VALUE=0
# CONFIG_DETECT_HUNG_TASK is not set
CONFIG_DEBUG_OBJECTS=y
# CONFIG_DEBUG_OBJECTS_SELFTEST is not set
# CONFIG_DEBUG_OBJECTS_FREE is not set
CONFIG_DEBUG_OBJECTS_TIMERS=y
# CONFIG_DEBUG_OBJECTS_WORK is not set
CONFIG_DEBUG_OBJECTS_RCU_HEAD=y
# CONFIG_DEBUG_OBJECTS_PERCPU_COUNTER is not set
CONFIG_DEBUG_OBJECTS_ENABLE_DEFAULT=1
# CONFIG_SLUB_DEBUG_ON is not set
CONFIG_SLUB_STATS=y
CONFIG_HAVE_DEBUG_KMEMLEAK=y
# CONFIG_DEBUG_KMEMLEAK is not set
CONFIG_DEBUG_RT_MUTEXES=y
CONFIG_DEBUG_PI_LIST=y
CONFIG_RT_MUTEX_TESTER=y
CONFIG_DEBUG_SPINLOCK=y
CONFIG_DEBUG_MUTEXES=y
# CONFIG_DEBUG_LOCK_ALLOC is not set
# CONFIG_PROVE_LOCKING is not set
# CONFIG_LOCK_STAT is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y
CONFIG_DEBUG_LOCKING_API_SELFTESTS=y
CONFIG_DEBUG_STACK_USAGE=y
# CONFIG_DEBUG_KOBJECT is not set
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_DEBUG_INFO=y
# CONFIG_DEBUG_VM is not set
CONFIG_DEBUG_VIRTUAL=y
# CONFIG_DEBUG_WRITECOUNT is not set
# CONFIG_DEBUG_MEMORY_INIT is not set
CONFIG_DEBUG_LIST=y
CONFIG_TEST_LIST_SORT=y
# CONFIG_DEBUG_SG is not set
# CONFIG_DEBUG_NOTIFIERS is not set
# CONFIG_DEBUG_CREDENTIALS is not set
CONFIG_ARCH_WANT_FRAME_POINTERS=y
CONFIG_FRAME_POINTER=y
# CONFIG_BOOT_PRINTK_DELAY is not set

#
# RCU Debugging
#
# CONFIG_SPARSE_RCU_POINTER is not set
# CONFIG_RCU_TORTURE_TEST is not set
# CONFIG_RCU_TRACE is not set
# CONFIG_BACKTRACE_SELF_TEST is not set
# CONFIG_DEBUG_BLOCK_EXT_DEVT is not set
# CONFIG_DEBUG_FORCE_WEAK_PER_CPU is not set
CONFIG_LKDTM=y
CONFIG_NOTIFIER_ERROR_INJECTION=y
CONFIG_PM_NOTIFIER_ERROR_INJECT=y
CONFIG_MEMORY_NOTIFIER_ERROR_INJECT=y
CONFIG_FAULT_INJECTION=y
# CONFIG_FAILSLAB is not set
CONFIG_FAIL_PAGE_ALLOC=y
CONFIG_FAIL_MAKE_REQUEST=y
CONFIG_FAIL_IO_TIMEOUT=y
CONFIG_FAIL_MMC_REQUEST=y
# CONFIG_FAULT_INJECTION_DEBUG_FS is not set
CONFIG_ARCH_HAS_DEBUG_STRICT_USER_COPY_CHECKS=y
# CONFIG_DEBUG_STRICT_USER_COPY_CHECKS is not set
# CONFIG_DEBUG_PAGEALLOC is not set
CONFIG_USER_STACKTRACE_SUPPORT=y
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
CONFIG_TRACING_SUPPORT=y
# CONFIG_FTRACE is not set
CONFIG_PROVIDE_OHCI1394_DMA_INIT=y
CONFIG_FIREWIRE_OHCI_REMOTE_DMA=y
# CONFIG_BUILD_DOCSRC is not set
CONFIG_DYNAMIC_DEBUG=y
CONFIG_DMA_API_DEBUG=y
CONFIG_ATOMIC64_SELFTEST=y
# CONFIG_SAMPLES is not set
CONFIG_HAVE_ARCH_KGDB=y
# CONFIG_KGDB is not set
CONFIG_HAVE_ARCH_KMEMCHECK=y
# CONFIG_KMEMCHECK is not set
CONFIG_TEST_STRING_HELPERS=y
CONFIG_TEST_KSTRTOX=y
CONFIG_STRICT_DEVMEM=y
CONFIG_X86_VERBOSE_BOOTUP=y
# CONFIG_EARLY_PRINTK is not set
CONFIG_DEBUG_STACKOVERFLOW=y
CONFIG_X86_PTDUMP=y
# CONFIG_DEBUG_RODATA is not set
# CONFIG_DEBUG_TLBFLUSH is not set
# CONFIG_IOMMU_DEBUG is not set
# CONFIG_IOMMU_STRESS is not set
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
# CONFIG_DEBUG_BOOT_PARAMS is not set
CONFIG_CPA_DEBUG=y
# CONFIG_OPTIMIZE_INLINING is not set
CONFIG_DEBUG_NMI_SELFTEST=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY_DMESG_RESTRICT is not set
# CONFIG_SECURITY is not set
CONFIG_SECURITYFS=y
CONFIG_DEFAULT_SECURITY_DAC=y
CONFIG_DEFAULT_SECURITY=""
CONFIG_XOR_BLOCKS=y
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
# CONFIG_CRYPTO_CBC is not set
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_CTS=y
# CONFIG_CRYPTO_ECB is not set
CONFIG_CRYPTO_LRW=y
# CONFIG_CRYPTO_PCBC is not set
CONFIG_CRYPTO_XTS=y

#
# Hash modes
#
CONFIG_CRYPTO_CMAC=y
# CONFIG_CRYPTO_HMAC is not set
CONFIG_CRYPTO_XCBC=y
# CONFIG_CRYPTO_VMAC is not set

#
# Digest
#
CONFIG_CRYPTO_CRC32C=y
# CONFIG_CRYPTO_CRC32C_INTEL is not set
CONFIG_CRYPTO_CRC32=y
# CONFIG_CRYPTO_CRC32_PCLMUL is not set
CONFIG_CRYPTO_GHASH=y
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA1_SSSE3=y
CONFIG_CRYPTO_SHA256_SSSE3=y
# CONFIG_CRYPTO_SHA512_SSSE3 is not set
CONFIG_CRYPTO_SHA256=y
# CONFIG_CRYPTO_SHA512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_WP512=y
# CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL is not set

#
# Ciphers
#
CONFIG_CRYPTO_AES=y
# CONFIG_CRYPTO_AES_X86_64 is not set
# CONFIG_CRYPTO_AES_NI_INTEL is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_BLOWFISH=y
CONFIG_CRYPTO_BLOWFISH_COMMON=y
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_BLOWFISH_AVX2_X86_64=y
CONFIG_CRYPTO_CAMELLIA=y
CONFIG_CRYPTO_CAMELLIA_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX_X86_64=y
CONFIG_CRYPTO_CAMELLIA_AESNI_AVX2_X86_64=y
CONFIG_CRYPTO_CAST_COMMON=y
CONFIG_CRYPTO_CAST5=y
CONFIG_CRYPTO_CAST5_AVX_X86_64=y
CONFIG_CRYPTO_CAST6=y
CONFIG_CRYPTO_CAST6_AVX_X86_64=y
# CONFIG_CRYPTO_DES is not set
CONFIG_CRYPTO_FCRYPT=y
# CONFIG_CRYPTO_KHAZAD is not set
CONFIG_CRYPTO_SALSA20=y
# CONFIG_CRYPTO_SALSA20_X86_64 is not set
# CONFIG_CRYPTO_SEED is not set
CONFIG_CRYPTO_SERPENT=y
CONFIG_CRYPTO_SERPENT_SSE2_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX_X86_64=y
CONFIG_CRYPTO_SERPENT_AVX2_X86_64=y
CONFIG_CRYPTO_TEA=y
# CONFIG_CRYPTO_TWOFISH is not set
CONFIG_CRYPTO_TWOFISH_COMMON=y
CONFIG_CRYPTO_TWOFISH_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_TWOFISH_AVX_X86_64=y
CONFIG_CRYPTO_TWOFISH_AVX2_X86_64=y

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
# CONFIG_CRYPTO_HW is not set
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
CONFIG_GENERIC_FIND_FIRST_BIT=y
CONFIG_GENERIC_PCI_IOMAP=y
CONFIG_GENERIC_IOMAP=y
CONFIG_GENERIC_IO=y
# CONFIG_CRC_CCITT is not set
CONFIG_CRC16=y
CONFIG_CRC_T10DIF=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC32=y
# CONFIG_CRC32_SELFTEST is not set
# CONFIG_CRC32_SLICEBY8 is not set
# CONFIG_CRC32_SLICEBY4 is not set
# CONFIG_CRC32_SARWATE is not set
CONFIG_CRC32_BIT=y
# CONFIG_CRC7 is not set
CONFIG_LIBCRC32C=y
CONFIG_CRC8=y
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_LZO_COMPRESS=y
CONFIG_LZO_DECOMPRESS=y
CONFIG_XZ_DEC=y
# CONFIG_XZ_DEC_X86 is not set
CONFIG_XZ_DEC_POWERPC=y
# CONFIG_XZ_DEC_IA64 is not set
CONFIG_XZ_DEC_ARM=y
CONFIG_XZ_DEC_ARMTHUMB=y
# CONFIG_XZ_DEC_SPARC is not set
CONFIG_XZ_DEC_BCJ=y
CONFIG_XZ_DEC_TEST=y
CONFIG_DECOMPRESS_GZIP=y
CONFIG_HAS_IOMEM=y
CONFIG_HAS_IOPORT=y
CONFIG_HAS_DMA=y
CONFIG_DQL=y
CONFIG_NLATTR=y
CONFIG_ARCH_HAS_ATOMIC64_DEC_IF_POSITIVE=y
# CONFIG_AVERAGE is not set
CONFIG_CORDIC=y
CONFIG_DDR=y
# CONFIG_DRM_TTM is not set
# CONFIG_ISDN_DRV_LOOP is not set

--k1lZvvs/B4yU6o8G--
