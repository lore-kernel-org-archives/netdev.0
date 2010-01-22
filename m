From: Michael Breuer <mbreuer@majjas.com>
Subject: Hang: 2.6.32.4 sky2/DMAR (was [PATCH] sky2: Fix WARNING: at
 lib/dma-debug.c:902 check_sync)
Date: Fri, 22 Jan 2010 13:01:15 -0500
Message-ID: <4B59E7EB.3050605@majjas.com>
References: <20100120094103.GA6225@ff.dom.local> <4B58B217.8030001@majjas.com>
 <20100121204133.GB3085@del.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_4/mclBUfdWhwQaAkg94QoQ)"
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, flyboy@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Michael Chan <mchan@broadcom.com>,
	Don Fry <pcnet32@verizon.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Matt Carlson <mcarlson@broadcom.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756088Ab0AVSBt@vger.kernel.org>
In-reply-to: <20100121204133.GB3085@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_4/mclBUfdWhwQaAkg94QoQ)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

Kernel 2.6.32.4 (git) with the following patches applied:

af_packet.c (tpacket_snd version 3)
sky2.c pskb_may_pull
sky2 fix WARNING at lib/dma-debug.c check_sync

Running with CONFIG_DMAR=n, system is stable.
Running with the exact same source but CONFIG_DMAR=y I get the WARNING 
(see below) after about 36 hours of uptime (has varied from about 24 to 
about 48):
Smolt profile: 
http://smolt.fedoraproject.org/show?uuid=pub_bb05c701-1e47-4b3c-9fab-54f520f39d79+
I'm also attaching dmesg.old (dmesg from the crash).

Subsequent to this the system watchdog reboots the system (it's hung).

Of interest: each and every time this has happened the system was under 
heavy RX load (win7 backup to a cifs share hosted on this server). Also, 
there is always a dhcp exchange of some sort preceding the event.

It is possible that the event is re creatable without DMAR enabled, but 
I have been unsuccessful in doing so.


Jan 22 05:38:36 mail dhcpd: DHCPREQUEST for 10.0.0.54 from 
00:1b:78:c8:2b:8e (HPC82B8D) via eth0
Jan 22 05:38:36 mail dhcpd: DHCPACK on 10.0.0.54 to 00:1b:78:c8:2b:8e 
(HPC82B8D) via eth0
Jan 22 05:38:41 mail kernel: DRHD: handling fault status reg 2
Jan 22 05:38:41 mail kernel: DMAR:[DMA Read] Request device [06:00.0] 
fault addr ffdfdd9fe000
Jan 22 05:38:41 mail kernel: DMAR:[fault reason 06] PTE Read access is 
not set
Jan 22 05:38:41 mail kernel: sky2 0000:06:00.0: error interrupt 
status=0xc0000000
Jan 22 05:38:41 mail kernel: sky2 0000:06:00.0: PCI hardware error (0x2010)
Jan 22 05:39:18 mail kernel: ------------[ cut here ]------------
Jan 22 05:39:18 mail kernel: WARNING: at net/sched/sch_generic.c:261 
dev_watchdog+0xf3/0x164()
Jan 22 05:39:18 mail kernel: Hardware name: System Product Name
Jan 22 05:39:18 mail kernel: NETDEV WATCHDOG: eth0 (sky2): transmit 
queue 0 timed out
Jan 22 05:39:18 mail kernel: Modules linked in: cpufreq_stats 
ip6table_mangle ip6table_filter ip6_tables ipt_MASQUERADE iptable_nat 
nf_nat iptable_mangle iptable_raw appletalk psnap llc nfsd lockd nfs_acl 
auth_rpcgss exportfs hwmon_vid coretemp sunrpc acpi_cpufreq sit tunnel4 
ipt_LOG nf_conntrack_netbios_ns nf_conntrack_ftp nf_conntrack_ipv6 
xt_multiport xt_DSCP xt_dscp xt_MARK ipv6 dm_multipath kvm_intel kvm 
snd_hda_codec_analog snd_ens1371 gameport snd_rawmidi snd_hda_intel 
snd_ac97_codec snd_hda_codec snd_hwdep ac97_bus snd_seq snd_seq_device 
firewire_ohci snd_pcm firewire_core crc_itu_t snd_timer snd 
gspca_spca505 gspca_main i2c_i801 videodev v4l1_compat sky2 soundcore 
v4l2_compat_ioctl32 wmi snd_page_alloc asus_atk0110 hwmon pcspkr 
iTCO_wdt iTCO_vendor_support fbcon tileblit font bitblit softcursor 
raid456 async_raid6_recov async_pq raid6_pq async_xor xor async_memcpy 
async_tx raid1 ata_generic pata_acpi pata_marvell nouveau ttm 
drm_kms_helper drm agpgart fb i2c_algo_bit cfbcopyarea i2c_core 
cfbimgblt cfb
Jan 22 05:39:18 mail kernel: fillrect [last unloaded: microcode]
Jan 22 05:39:18 mail kernel: Pid: 0, comm: swapper Tainted: G        W  
2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #6
Jan 22 05:39:18 mail kernel: Call Trace:
Jan 22 05:39:18 mail kernel: <IRQ>  [<ffffffff810536ee>] 
warn_slowpath_common+0x7c/0x94
Jan 22 05:39:18 mail kernel: [<ffffffff8105375d>] 
warn_slowpath_fmt+0x41/0x43
Jan 22 05:39:18 mail kernel: [<ffffffff813e3b6b>] ? netif_tx_lock+0x44/0x6c
Jan 22 05:39:18 mail kernel: [<ffffffff813e3cd3>] dev_watchdog+0xf3/0x164
Jan 22 05:39:18 mail kernel: [<ffffffff8105f3f4>] ? cascade+0x6a/0x84
Jan 22 05:39:18 mail kernel: [<ffffffff8106323f>] 
run_timer_softirq+0x1c8/0x270
Jan 22 05:39:18 mail kernel: [<ffffffff8105af0f>] __do_softirq+0xf8/0x1cd
Jan 22 05:39:18 mail kernel: [<ffffffff8107f0ab>] ? 
tick_program_event+0x2a/0x2c
Jan 22 05:39:18 mail kernel: [<ffffffff81012e1c>] call_softirq+0x1c/0x30
Jan 22 05:39:18 mail kernel: [<ffffffff810143a3>] do_softirq+0x4b/0xa6
Jan 22 05:39:18 mail kernel: [<ffffffff8105aaef>] irq_exit+0x4a/0x8c
Jan 22 05:39:18 mail kernel: [<ffffffff81470612>] 
smp_apic_timer_interrupt+0x86/0x94
Jan 22 05:39:18 mail kernel: [<ffffffff810127e3>] 
apic_timer_interrupt+0x13/0x20
Jan 22 05:39:18 mail kernel: <EOI>  [<ffffffff812c729a>] ? 
acpi_idle_enter_bm+0x256/0x28a
Jan 22 05:39:18 mail kernel: [<ffffffff812c7293>] ? 
acpi_idle_enter_bm+0x24f/0x28a
Jan 22 05:39:18 mail kernel: [<ffffffff813a6c3c>] ? 
cpuidle_idle_call+0x9e/0xfa
Jan 22 05:39:18 mail kernel: [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
Jan 22 05:39:18 mail kernel: [<ffffffff81465ba5>] ? 
start_secondary+0x201/0x242
Jan 22 05:39:18 mail kernel: ---[ end trace 57f7151f6a5def07 ]---
Jan 22 05:39:18 mail kernel: sky2 eth0: tx timeout
Jan 22 05:39:18 mail kernel: sky2 eth0: transmit ring 76 .. 35 report=76 
done=76
Jan 22 05:39:18 mail kernel: sky2 eth0: disabling interface
Jan 22 05:39:18 mail kernel: sky2 eth0: enabling interface
Jan 22 05:39:21 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
Jan 22 05:40:06 mail kernel: sky2 eth0: tx timeout
Jan 22 05:40:06 mail kernel: sky2 eth0: transmit ring 3 .. 90 report=3 
done=3
Jan 22 05:40:06 mail kernel: sky2 eth0: disabling interface
Jan 22 05:40:06 mail kernel: sky2 eth0: enabling interface
Jan 22 05:40:09 mail kernel: sky2 eth0: Link is up at 1000 Mbps, full 
duplex, flow control both
Jan 22 05:40:30 mail abrt: Kerneloops: Reported 1 kernel oopses to Abrt
Jan 22 05:40:30 mail abrtd: Directory 'kerneloops-1264156830-1' creation 
detected
Jan 22 05:40:30 mail abrtd: Can't open file 
'/var/cache/abrt/kerneloops-1264156830-1/cmdline'
Jan 22 05:40:30 mail abrtd: Corrupted or bad crash, deleting
Jan 22 05:40:33 mail dhcpd: DHCPINFORM from 10.0.0.11 via eth0
Jan 22 05:40:33 mail dhcpd: DHCPACK to 10.0.0.11 (00:1a:92:8d:30:81) via 
eth0
Jan 22 05:40:36 mail dhcpd: DHCPINFORM from 10.0.0.11 via eth0
Jan 22 05:40:36 mail dhcpd: DHCPACK to 10.0.0.11 (00:1a:92:8d:30:81) via 
eth0
Jan 22 05:40:50 mail named[11245]: error (connection refused) resolving 
'173-212-207-86.hostnoc.net/A/IN': 2607:f878:0:3::12#53
Jan 22 05:40:50 mail named[11245]: error (connection refused) resolving 
'NS1.HOSTNOC.NET/AAAA/IN': 2607:f878:0:3::10#53
<watchdog reboot>


--Boundary_(ID_4/mclBUfdWhwQaAkg94QoQ)
Content-type: text/plain; name=dmesg.old
Content-transfer-encoding: 7BIT
Content-disposition: attachment; filename=dmesg.old

Initializing cgroup subsys cpuset
Initializing cgroup subsys cpu
Linux version 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty (mbreuer@mail.majjas.com) (gcc version 4.4.2 20091222 (Red Hat 4.4.2-20) (GCC) ) #6 SMP Thu Jan 21 00:09:11 EST 2010
Command line: ro root=/dev/mapper/vg_00-LogVol02_root usbcore.autosuspend=1 crashkernel=128M SYSFONT=latarcyrheb-sun16 LANG=en_US.UTF-8 KEYTABLE=us pcie_aspm=force intel_iommu=igfx_off debug
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009cc00 (usable)
 BIOS-e820: 000000000009cc00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4c00 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000bf780000 (usable)
 BIOS-e820: 00000000bf780000 - 00000000bf798000 (ACPI data)
 BIOS-e820: 00000000bf798000 - 00000000bf7dc000 (ACPI NVS)
 BIOS-e820: 00000000bf7dc000 - 00000000c0000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffe00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000340000000 (usable)
DMI 2.5 present.
AMI BIOS detected: BIOS may corrupt low RAM, working around it.
e820 update range: 0000000000000000 - 0000000000010000 (usable) ==> (reserved)
last_pfn = 0x340000 max_arch_pfn = 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-E3FFF write-protect
  E4000-EBFFF write-through
  EC000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000 mask E00000000 write-back
  1 base 200000000 mask F00000000 write-back
  2 base 300000000 mask FC0000000 write-back
  3 base 0C0000000 mask FC0000000 uncachable
  4 base 0BF800000 mask FFF800000 uncachable
  5 disabled
  6 disabled
  7 disabled
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
original variable MTRRs
reg 0, base: 0GB, range: 8GB, type WB
reg 1, base: 8GB, range: 4GB, type WB
reg 2, base: 12GB, range: 1GB, type WB
reg 3, base: 3GB, range: 1GB, type UC
reg 4, base: 3064MB, range: 8MB, type UC
total RAM covered: 12280M
Found optimal setting for mtrr clean up
 gran_size: 64K 	chunk_size: 16M 	num_reg: 6  	lose cover RAM: 0G
New variable MTRRs
reg 0, base: 0GB, range: 2GB, type WB
reg 1, base: 2GB, range: 1GB, type WB
reg 2, base: 3064MB, range: 8MB, type UC
reg 3, base: 4GB, range: 4GB, type WB
reg 4, base: 8GB, range: 4GB, type WB
reg 5, base: 12GB, range: 1GB, type WB
e820 update range: 00000000bf800000 - 0000000100000000 (usable) ==> (reserved)
last_pfn = 0xbf780 max_arch_pfn = 0x400000000
Scanning 0 areas for low memory corruption
modified physical RAM map:
 modified: 0000000000000000 - 0000000000010000 (reserved)
 modified: 0000000000010000 - 000000000009cc00 (usable)
 modified: 000000000009cc00 - 00000000000a0000 (reserved)
 modified: 00000000000e4c00 - 0000000000100000 (reserved)
 modified: 0000000000100000 - 00000000bf780000 (usable)
 modified: 00000000bf780000 - 00000000bf798000 (ACPI data)
 modified: 00000000bf798000 - 00000000bf7dc000 (ACPI NVS)
 modified: 00000000bf7dc000 - 00000000c0000000 (reserved)
 modified: 00000000fee00000 - 00000000fee01000 (reserved)
 modified: 00000000ffe00000 - 0000000100000000 (reserved)
 modified: 0000000100000000 - 0000000340000000 (usable)
initial memory mapped : 0 - 20000000
init_memory_mapping: 0000000000000000-00000000bf780000
 0000000000 - 00bf600000 page 2M
 00bf600000 - 00bf780000 page 4k
kernel direct mapping tables up to bf780000 @ 10000-15000
init_memory_mapping: 0000000100000000-0000000340000000
 0100000000 - 0340000000 page 2M
kernel direct mapping tables up to 340000000 @ 13000-21000
RAMDISK: 3770e000 - 37fef2d9
ACPI: RSDP 00000000000fb1a0 00024 (v02 ACPIAM)
ACPI: XSDT 00000000bf780100 00064 (v01 111209 XSDT1642 20091112 MSFT 00000097)
ACPI: FACP 00000000bf780290 000F4 (v03 111209 FACP1642 20091112 MSFT 00000097)
ACPI: DSDT 00000000bf7804b0 0B66D (v01  A1265 A1265001 00000001 INTL 20060113)
ACPI: FACS 00000000bf798000 00040
ACPI: APIC 00000000bf780390 000D8 (v01 111209 APIC1642 20091112 MSFT 00000097)
ACPI: MCFG 00000000bf780470 0003C (v01 111209 OEMMCFG  20091112 MSFT 00000097)
ACPI: OEMB 00000000bf798040 00072 (v01 111209 OEMB1642 20091112 MSFT 00000097)
ACPI: HPET 00000000bf78f4b0 00038 (v01 111209 OEMHPET  20091112 MSFT 00000097)
ACPI: DMAR 00000000bf7980c0 00138 (v01    AMI  OEMDMAR 00000001 MSFT 00000097)
ACPI: OSFR 00000000bf78f4f0 000B0 (v01 111209 OEMOSFR  20091112 MSFT 00000097)
ACPI: SSDT 00000000bf79a470 00363 (v01 DpgPmm    CpuPm 00000012 INTL 20060113)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at 0000000000000000-0000000340000000
Bootmem setup node 0 0000000000000000-0000000340000000
  NODE_DATA [000000000001c000 - 000000000002ffff]
  bootmap [0000000000030000 -  0000000000097fff] pages 68
(8 early reservations) ==> bootmem [0000000000 - 0340000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 - 0000008000]
  #2 [0001000000 - 0001a478b0]    TEXT DATA BSS ==> [0001000000 - 0001a478b0]
  #3 [003770e000 - 0037fef2d9]          RAMDISK ==> [003770e000 - 0037fef2d9]
  #4 [000009cc00 - 0000100000]    BIOS reserved ==> [000009cc00 - 0000100000]
  #5 [0001a48000 - 0001a48294]              BRK ==> [0001a48000 - 0001a48294]
  #6 [0000010000 - 0000013000]          PGTABLE ==> [0000010000 - 0000013000]
  #7 [0000013000 - 000001c000]          PGTABLE ==> [0000013000 - 000001c000]
found SMP MP-table at [ffff8800000ff780] ff780
Reserving 128MB of memory at 32MB for crashkernel (System RAM: 13312MB)
 [ffffea0000000000-ffffea000b5fffff] PMD -> [ffff880028600000-ffff880032dfffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00340000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009c
    0: 0x00000100 -> 0x000bf780
    0: 0x00100000 -> 0x00340000
On node 0 totalpages: 3143436
  DMA zone: 56 pages used for memmap
  DMA zone: 114 pages reserved
  DMA zone: 3810 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 765880 pages, LIFO batch:31
  Normal zone: 32256 pages used for memmap
  Normal zone: 2327040 pages, LIFO batch:31
ACPI: PM-Timer IO Port: 0x808
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] enabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x04] enabled)
ACPI: LAPIC (acpi_id[0x04] lapic_id[0x06] enabled)
ACPI: LAPIC (acpi_id[0x05] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x06] lapic_id[0x03] enabled)
ACPI: LAPIC (acpi_id[0x07] lapic_id[0x05] enabled)
ACPI: LAPIC (acpi_id[0x08] lapic_id[0x07] enabled)
ACPI: LAPIC (acpi_id[0x09] lapic_id[0x88] disabled)
ACPI: LAPIC (acpi_id[0x0a] lapic_id[0x89] disabled)
ACPI: LAPIC (acpi_id[0x0b] lapic_id[0x8a] disabled)
ACPI: LAPIC (acpi_id[0x0c] lapic_id[0x8b] disabled)
ACPI: LAPIC (acpi_id[0x0d] lapic_id[0x8c] disabled)
ACPI: LAPIC (acpi_id[0x0e] lapic_id[0x8d] disabled)
ACPI: LAPIC (acpi_id[0x0f] lapic_id[0x8e] disabled)
ACPI: LAPIC (acpi_id[0x10] lapic_id[0x8f] disabled)
ACPI: IOAPIC (id[0x08] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 8, version 32, address 0xfec00000, GSI 0-23
ACPI: IOAPIC (id[0x09] address[0xfec8a000] gsi_base[24])
IOAPIC[1]: apic_id 9, version 32, address 0xfec8a000, GSI 24-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a301 base: 0xfed00000
SMP: Allowing 16 CPUs, 8 hotplug CPUs
nr_irqs_gsi: 48
Allocating PCI resources starting at c0000000 (gap: c0000000:3ee00000)
Booting paravirtualized kernel on bare hardware
NR_CPUS:16 nr_cpumask_bits:16 nr_cpu_ids:16 nr_node_ids:1
PERCPU: Embedded 30 pages/cpu @ffff880028200000 s90264 r8192 d24424 u131072
pcpu-alloc: s90264 r8192 d24424 u131072 alloc=1*2097152
pcpu-alloc: [0] 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 3096730
Policy zone: Normal
Kernel command line: ro root=/dev/mapper/vg_00-LogVol02_root usbcore.autosuspend=1 crashkernel=128M SYSFONT=latarcyrheb-sun16 LANG=en_US.UTF-8 KEYTABLE=us pcie_aspm=force intel_iommu=igfx_off debug
PCIe ASPM is forcedly enabled
Intel-IOMMU: disable GFX device mapping
PID hash table entries: 4096 (order: 3, 32768 bytes)
Initializing CPU#0
Checking aperture...
No AGP bridge found
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 12248680k/13631488k available (4554k kernel code, 1057744k absent, 325064k reserved, 3163k data, 1524k init)
SLUB: Genslabs=14, HWalign=64, Order=0-3, MinObjects=0, CPUs=16, Nodes=1
Hierarchical RCU implementation.
RCU-based detection of stalled CPUs is enabled.
NR_IRQS:4352 nr_irqs:944
Extended CMOS year: 2000
Console: colour VGA+ 80x25
console [tty0] enabled
allocated 125829120 bytes of page_cgroup
please try 'cgroup_disable=memory' option if you don't want memory cgroups
hpet clockevent registered
HPET: 4 timers in total, 0 timers will be used for per-cpu timer
Fast TSC calibration using PIT
Detected 2672.911 MHz processor.
Calibrating delay loop (skipped), value calculated using timer frequency.. 5345.82 BogoMIPS (lpj=2672911)
Security Framework initialized
SELinux:  Initializing.
SELinux:  Starting in permissive mode
Dentry cache hash table entries: 2097152 (order: 12, 16777216 bytes)
Inode-cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Mount-cache hash table entries: 256
Initializing cgroup subsys ns
Initializing cgroup subsys cpuacct
Initializing cgroup subsys memory
Initializing cgroup subsys devices
Initializing cgroup subsys freezer
Initializing cgroup subsys net_cls
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 0/0x0 -> Node 0
mce: CPU supports 9 MCE banks
CPU0: Thermal monitoring enabled (TM1)
CPU 0 MCA banks CMCI:2 CMCI:3 CMCI:5 CMCI:6 SHD:8
using mwait in idle threads.
Performance Events: Nehalem/Corei7 events, Intel PMU driver.
... version:                3
... bit width:              48
... generic registers:      4
... value mask:             0000ffffffffffff
... max period:             000000007fffffff
... fixed-purpose events:   3
... event mask:             000000070000000f
ACPI: Core revision 20090903
ftrace: converting mcount calls to 0f 1f 44 00 00
ftrace: allocating 23777 entries in 94 pages
DMAR: Host address width 39
DMAR: DRHD base: 0x000000fbfff000 flags: 0x0
IOMMU fbfff000: ver 1:0 cap c9008010e60262 ecap f0207a
DMAR: DRHD base: 0x000000fbffe000 flags: 0x1
IOMMU fbffe000: ver 1:0 cap c90780106f0462 ecap f020fe
DMAR: RMRR base: 0x000000000ec000 end: 0x000000000effff
DMAR: RMRR base: 0x000000bf7dc000 end: 0x000000bf7dbfff
DMAR: ATSR flags: 0x0
IOAPIC id 8 under DRHD base 0xfbffe000
IOAPIC id 9 under DRHD base 0xfbffe000
DRHD: handling fault status reg 2
Enabled Interrupt-remapping
Setting APIC routing to flat
  alloc irq_desc for 48 on node 0
  alloc kstat_irqs on node 0
  alloc irq_desc for 49 on node 0
  alloc kstat_irqs on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
alloc irq_2_iommu on node 0
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
APIC calibration not consistent with PM-Timer: 121ms instead of 100ms
APIC delta adjusted to PM-Timer: 835227 (1018966)
Booting processor 1 APIC 0x2 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5344.68 BogoMIPS (lpj=2672340)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 1/0x2 -> Node 0
CPU1: Thermal monitoring enabled (TM1)
CPU 1 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU1: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Skipping synchronization checks as TSC is reliable.
Booting processor 2 APIC 0x4 ip 0x6000
Initializing CPU#2
Calibrating delay using timer specific routine.. 5344.68 BogoMIPS (lpj=2672340)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 2/0x4 -> Node 0
CPU2: Thermal monitoring enabled (TM1)
CPU 2 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU2: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Booting processor 3 APIC 0x6 ip 0x6000
Initializing CPU#3
Calibrating delay using timer specific routine.. 5558.47 BogoMIPS (lpj=2779235)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 3/0x6 -> Node 0
CPU3: Thermal monitoring enabled (TM1)
CPU 3 MCA banks CMCI:2 CMCI:3 CMCI:5 SHD:6 SHD:8
CPU3: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Booting processor 4 APIC 0x1 ip 0x6000
Initializing CPU#4
Calibrating delay using timer specific routine.. 5344.67 BogoMIPS (lpj=2672339)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 4/0x1 -> Node 0
CPU4: Thermal monitoring enabled (TM1)
CPU 4 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU4: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Booting processor 5 APIC 0x3 ip 0x6000
Initializing CPU#5
Calibrating delay using timer specific routine.. 5344.67 BogoMIPS (lpj=2672339)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 5/0x3 -> Node 0
CPU5: Thermal monitoring enabled (TM1)
CPU 5 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU5: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Booting processor 6 APIC 0x5 ip 0x6000
Initializing CPU#6
Calibrating delay using timer specific routine.. 5558.46 BogoMIPS (lpj=2779231)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 6/0x5 -> Node 0
CPU6: Thermal monitoring enabled (TM1)
CPU 6 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU6: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Booting processor 7 APIC 0x7 ip 0x6000
Initializing CPU#7
Calibrating delay using timer specific routine.. 5344.67 BogoMIPS (lpj=2672338)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 256K
CPU: L3 cache: 8192K
CPU 7/0x7 -> Node 0
CPU7: Thermal monitoring enabled (TM1)
CPU 7 MCA banks SHD:2 SHD:3 SHD:5 SHD:6 SHD:8
CPU7: Intel(R) Core(TM) i7 CPU         920  @ 2.67GHz stepping 05
Brought up 8 CPUs
Total of 8 processors activated (43186.14 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0,4 level SIBLING
  groups: 0 (cpu_power = 589) 4 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178)
CPU1 attaching sched-domain:
 domain 0: span 1,5 level SIBLING
  groups: 1 (cpu_power = 589) 5 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178)
CPU2 attaching sched-domain:
 domain 0: span 2,6 level SIBLING
  groups: 2 (cpu_power = 589) 6 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178)
CPU3 attaching sched-domain:
 domain 0: span 3,7 level SIBLING
  groups: 3 (cpu_power = 589) 7 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178)
CPU4 attaching sched-domain:
 domain 0: span 0,4 level SIBLING
  groups: 4 (cpu_power = 589) 0 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178)
CPU5 attaching sched-domain:
 domain 0: span 1,5 level SIBLING
  groups: 5 (cpu_power = 589) 1 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178)
CPU6 attaching sched-domain:
 domain 0: span 2,6 level SIBLING
  groups: 6 (cpu_power = 589) 2 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 2,6 (cpu_power = 1178) 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178)
CPU7 attaching sched-domain:
 domain 0: span 3,7 level SIBLING
  groups: 7 (cpu_power = 589) 3 (cpu_power = 589)
  domain 1: span 0-7 level MC
   groups: 3,7 (cpu_power = 1178) 0,4 (cpu_power = 1178) 1,5 (cpu_power = 1178) 2,6 (cpu_power = 1178)
regulator: core version 0.5
Time:  5:43:57  Date: 01/21/10
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: Not using MMCONFIG.
PCI: Using configuration type 1 for base access
bio: create slab <bio-0> at 0
ACPI: EC: Look up EC in DSDT
ACPI: Executed 1 blocks of module-level executable AML code
ACPI: Interpreter enabled
ACPI: (supports S0 S1 S3 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in ACPI motherboard resources
PCI: Using MMCONFIG at e0000000 - efffffff
ACPI: No dock devices found.
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:00.0: PME# supported from D0 D3hot D3cold
pci 0000:00:00.0: PME# disabled
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:03.0: PME# supported from D0 D3hot D3cold
pci 0000:00:03.0: PME# disabled
pci 0000:00:07.0: PME# supported from D0 D3hot D3cold
pci 0000:00:07.0: PME# disabled
pci 0000:00:1a.0: reg 20 io port: [0x9800-0x981f]
pci 0000:00:1a.1: reg 20 io port: [0x9880-0x989f]
pci 0000:00:1a.2: reg 20 io port: [0x9c00-0x9c1f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xf7fff000-0xf7fff3ff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1b.0: reg 10 64bit mmio: [0xf7ff8000-0xf7ffbfff]
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.2: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0x9080-0x909f]
pci 0000:00:1d.1: reg 20 io port: [0x9400-0x941f]
pci 0000:00:1d.2: reg 20 io port: [0x9480-0x949f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xf7ffe000-0xf7ffe3ff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 0800-087f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0500-053f claimed by ICH6 GPIO
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 1 PIO at 0294 (mask 0003)
pci 0000:00:1f.0: ICH7 LPC Generic IO decode 3 PIO at 4700 (mask 001f)
pci 0000:00:1f.2: reg 10 io port: [0x8c00-0x8c07]
pci 0000:00:1f.2: reg 14 io port: [0x8880-0x8883]
pci 0000:00:1f.2: reg 18 io port: [0x8800-0x8807]
pci 0000:00:1f.2: reg 1c io port: [0x8480-0x8483]
pci 0000:00:1f.2: reg 20 io port: [0x8400-0x841f]
pci 0000:00:1f.2: reg 24 32bit mmio: [0xf7ffc000-0xf7ffc7ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: reg 10 64bit mmio: [0xf7ffd000-0xf7ffd0ff]
pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
pci 0000:02:00.0: reg 10 32bit mmio: [0xfa000000-0xfaffffff]
pci 0000:02:00.0: reg 14 64bit mmio pref: [0xd0000000-0xdfffffff]
pci 0000:02:00.0: reg 1c 64bit mmio: [0xf8000000-0xf9ffffff]
pci 0000:02:00.0: reg 24 io port: [0xac00-0xac7f]
pci 0000:02:00.0: reg 30 32bit mmio pref: [0xfbae0000-0xfbafffff]
pci 0000:00:03.0: bridge io port: [0xa000-0xafff]
pci 0000:00:03.0: bridge 32bit mmio: [0xf8000000-0xfbafffff]
pci 0000:00:03.0: bridge 64bit mmio pref: [0xd0000000-0xdfffffff]
pci 0000:00:1c.0: bridge 64bit mmio pref: [0xf6f00000-0xf6ffffff]
pci 0000:06:00.0: reg 10 64bit mmio: [0xfbdfc000-0xfbdfffff]
pci 0000:06:00.0: reg 18 io port: [0xd800-0xd8ff]
pci 0000:06:00.0: reg 30 32bit mmio pref: [0xfbdc0000-0xfbddffff]
pci 0000:06:00.0: supports D1 D2
pci 0000:06:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:06:00.0: PME# disabled
pci 0000:00:1c.2: bridge io port: [0xd000-0xdfff]
pci 0000:00:1c.2: bridge 32bit mmio: [0xfbd00000-0xfbdfffff]
pci 0000:05:00.0: reg 10 io port: [0xcc00-0xcc07]
pci 0000:05:00.0: reg 14 io port: [0xc880-0xc883]
pci 0000:05:00.0: reg 18 io port: [0xc800-0xc807]
pci 0000:05:00.0: reg 1c io port: [0xc480-0xc483]
pci 0000:05:00.0: reg 20 io port: [0xc400-0xc40f]
pci 0000:05:00.0: reg 24 32bit mmio: [0xfbcffc00-0xfbcfffff]
pci 0000:05:00.0: supports D1
pci 0000:05:00.0: PME# supported from D0 D1 D3hot
pci 0000:05:00.0: PME# disabled
pci 0000:00:1c.4: bridge io port: [0xc000-0xcfff]
pci 0000:00:1c.4: bridge 32bit mmio: [0xfbc00000-0xfbcfffff]
pci 0000:04:00.0: reg 10 64bit mmio: [0xfbbfc000-0xfbbfffff]
pci 0000:04:00.0: reg 18 io port: [0xb800-0xb8ff]
pci 0000:04:00.0: reg 30 32bit mmio pref: [0xfbbc0000-0xfbbdffff]
pci 0000:04:00.0: supports D1 D2
pci 0000:04:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:04:00.0: PME# disabled
pci 0000:00:1c.5: bridge io port: [0xb000-0xbfff]
pci 0000:00:1c.5: bridge 32bit mmio: [0xfbb00000-0xfbbfffff]
pci 0000:08:01.0: reg 10 io port: [0xec00-0xec3f]
pci 0000:08:01.0: supports D2
pci 0000:08:02.0: reg 10 32bit mmio: [0xfbeff000-0xfbeff7ff]
pci 0000:08:02.0: reg 14 io port: [0xe880-0xe8ff]
pci 0000:08:02.0: supports D2
pci 0000:08:02.0: PME# supported from D2 D3hot D3cold
pci 0000:08:02.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1e.0: bridge io port: [0xe000-0xefff]
pci 0000:00:1e.0: bridge 32bit mmio: [0xfbe00000-0xfbefffff]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P4._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P6._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P8._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.P0P9._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE1._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE3._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.NPE7._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 6 7 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs *5)
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 6 7 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 6 7 10 11 12 *14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 6 7 10 11 12 14 *15)
ACPI: PCI Interrupt Link [LNKF] (IRQs *3 4 6 7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 6 *7 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 *4 6 7 10 11 12 14 15)
vgaarb: device added: PCI:0000:02:00.0,decodes=io+mem,owns=io+mem,locks=none
vgaarb: loaded
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
NetLabel: Initializing
NetLabel:  domain hash size = 128
NetLabel:  protocols = UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0
hpet0: 4 comparators, 64-bit 14.318180 MHz counter
Switching to clocksource tsc
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 15 devices
ACPI: ACPI bus type pnp unregistered
system 00:01: iomem range 0xfbf00000-0xfbffffff has been reserved
system 00:01: iomem range 0xfc000000-0xfcffffff has been reserved
system 00:01: iomem range 0xfd000000-0xfdffffff has been reserved
system 00:01: iomem range 0xfe000000-0xfebfffff has been reserved
system 00:01: iomem range 0xfec8a000-0xfec8afff could not be reserved
system 00:01: iomem range 0xfed10000-0xfed10fff has been reserved
system 00:06: ioport range 0x290-0x29f has been reserved
system 00:07: ioport range 0x4d0-0x4d1 has been reserved
system 00:07: ioport range 0x800-0x87f has been reserved
system 00:07: ioport range 0x500-0x57f could not be reserved
system 00:07: iomem range 0xfed1c000-0xfed1ffff has been reserved
system 00:07: iomem range 0xfed20000-0xfed3ffff has been reserved
system 00:07: iomem range 0xfed40000-0xfed8ffff has been reserved
system 00:0a: iomem range 0xffc00000-0xffdfffff has been reserved
system 00:0b: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0b: iomem range 0xfee00000-0xfee00fff has been reserved
system 00:0d: iomem range 0xe0000000-0xefffffff has been reserved
system 00:0e: iomem range 0x0-0x9ffff could not be reserved
system 00:0e: iomem range 0xc0000-0xcffff has been reserved
system 00:0e: iomem range 0xe0000-0xfffff could not be reserved
system 00:0e: iomem range 0x100000-0xbfffffff could not be reserved
system 00:0e: iomem range 0xfed90000-0xffffffff could not be reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: disabled
pci 0000:00:01.0:   MEM window: disabled
pci 0000:00:01.0:   PREFETCH window: disabled
pci 0000:00:03.0: PCI bridge, secondary bus 0000:02
pci 0000:00:03.0:   IO window: 0xa000-0xafff
pci 0000:00:03.0:   MEM window: 0xf8000000-0xfbafffff
pci 0000:00:03.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff
pci 0000:00:07.0: PCI bridge, secondary bus 0000:03
pci 0000:00:07.0:   IO window: disabled
pci 0000:00:07.0:   MEM window: disabled
pci 0000:00:07.0:   PREFETCH window: disabled
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:07
pci 0000:00:1c.0:   IO window: 0x1000-0x1fff
pci 0000:00:1c.0:   MEM window: 0xc0000000-0xc03fffff
pci 0000:00:1c.0:   PREFETCH window: 0x000000f6f00000-0x000000f6ffffff
pci 0000:00:1c.2: PCI bridge, secondary bus 0000:06
pci 0000:00:1c.2:   IO window: 0xd000-0xdfff
pci 0000:00:1c.2:   MEM window: 0xfbd00000-0xfbdfffff
pci 0000:00:1c.2:   PREFETCH window: 0x000000c0400000-0x000000c05fffff
pci 0000:00:1c.4: PCI bridge, secondary bus 0000:05
pci 0000:00:1c.4:   IO window: 0xc000-0xcfff
pci 0000:00:1c.4:   MEM window: 0xfbc00000-0xfbcfffff
pci 0000:00:1c.4:   PREFETCH window: 0x000000c0600000-0x000000c07fffff
pci 0000:00:1c.5: PCI bridge, secondary bus 0000:04
pci 0000:00:1c.5:   IO window: 0xb000-0xbfff
pci 0000:00:1c.5:   MEM window: 0xfbb00000-0xfbbfffff
pci 0000:00:1c.5:   PREFETCH window: 0x000000c0800000-0x000000c09fffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:08
pci 0000:00:1e.0:   IO window: 0xe000-0xefff
pci 0000:00:1e.0:   MEM window: 0xfbe00000-0xfbefffff
pci 0000:00:1e.0:   PREFETCH window: disabled
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:03.0: setting latency timer to 64
pci 0000:00:07.0: setting latency timer to 64
pci 0000:00:1c.0: enabling device (0106 -> 0107)
  alloc irq_desc for 17 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pci 0000:00:1c.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.0: setting latency timer to 64
  alloc irq_desc for 18 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pci 0000:00:1c.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
pci 0000:00:1c.2: setting latency timer to 64
pci 0000:00:1c.4: PCI INT A -> GSI 17 (level, low) -> IRQ 17
pci 0000:00:1c.4: setting latency timer to 64
  alloc irq_desc for 16 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pci 0000:00:1c.5: PCI INT B -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.5: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
pci_bus 0000:00: resource 0 io:  [0x00-0xffff]
pci_bus 0000:00: resource 1 mem: [0x000000-0xffffffffffffffff]
pci_bus 0000:02: resource 0 io:  [0xa000-0xafff]
pci_bus 0000:02: resource 1 mem: [0xf8000000-0xfbafffff]
pci_bus 0000:02: resource 2 pref mem [0xd0000000-0xdfffffff]
pci_bus 0000:07: resource 0 io:  [0x1000-0x1fff]
pci_bus 0000:07: resource 1 mem: [0xc0000000-0xc03fffff]
pci_bus 0000:07: resource 2 pref mem [0xf6f00000-0xf6ffffff]
pci_bus 0000:06: resource 0 io:  [0xd000-0xdfff]
pci_bus 0000:06: resource 1 mem: [0xfbd00000-0xfbdfffff]
pci_bus 0000:06: resource 2 pref mem [0xc0400000-0xc05fffff]
pci_bus 0000:05: resource 0 io:  [0xc000-0xcfff]
pci_bus 0000:05: resource 1 mem: [0xfbc00000-0xfbcfffff]
pci_bus 0000:05: resource 2 pref mem [0xc0600000-0xc07fffff]
pci_bus 0000:04: resource 0 io:  [0xb000-0xbfff]
pci_bus 0000:04: resource 1 mem: [0xfbb00000-0xfbbfffff]
pci_bus 0000:04: resource 2 pref mem [0xc0800000-0xc09fffff]
pci_bus 0000:08: resource 0 io:  [0xe000-0xefff]
pci_bus 0000:08: resource 1 mem: [0xfbe00000-0xfbefffff]
pci_bus 0000:08: resource 3 io:  [0x00-0xffff]
pci_bus 0000:08: resource 4 mem: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 524288 (order: 10, 4194304 bytes)
TCP established hash table entries: 524288 (order: 11, 8388608 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
NET: Registered protocol family 1
pci 0000:02:00.0: Boot video device
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 9092k freed
DMA-API: preallocated 32768 debug entries
DMA-API: debugging enabled by kernel config
IOMMU 0xfbfff000: using Queued invalidation
IOMMU 0xfbffe000: using Queued invalidation
------------[ cut here ]------------
WARNING: at drivers/pci/intel-iommu.c:3790 init_dmars+0x32a/0x6ea()
Hardware name: System Product Name
Your BIOS is broken; DMA routed to ISOCH DMAR unit but no TLB space.
BIOS vendor: American Megatrends Inc.; Ver: 0704   ; Product Version: System Version
Modules linked in:
Pid: 1, comm: swapper Not tainted 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #6
Call Trace:
 [<ffffffff810536ee>] warn_slowpath_common+0x7c/0x94
 [<ffffffff8105375d>] warn_slowpath_fmt+0x41/0x43
 [<ffffffff817c9f73>] init_dmars+0x32a/0x6ea
 [<ffffffff817ca59e>] intel_iommu_init+0x26b/0x340
 [<ffffffff817a98f7>] ? pci_iommu_init+0x0/0x32
 [<ffffffff817a991b>] pci_iommu_init+0x24/0x32
 [<ffffffff8100a07d>] do_one_initcall+0x72/0x18a
 [<ffffffff817a26d8>] kernel_init+0x181/0x1db
 [<ffffffff81012d1a>] child_rip+0xa/0x20
 [<ffffffff8101267d>] ? restore_args+0x0/0x30
 [<ffffffff817a2557>] ? kernel_init+0x0/0x1db
 [<ffffffff81012d10>] ? child_rip+0x0/0x20
---[ end trace 57f7151f6a5def05 ]---
IOMMU: hardware identity mapping for device 0000:00:1b.0
IOMMU: Setting RMRR:
IOMMU: Setting identity map for device 0000:00:1d.0 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1d.1 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1d.2 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1d.7 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1a.0 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1a.1 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1a.2 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1a.7 [0xbf7dc000 - 0xbf7dc000]
IOMMU: Setting identity map for device 0000:00:1d.0 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1d.1 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1d.2 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1d.7 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1a.0 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1a.1 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1a.2 [0xec000 - 0xf0000]
IOMMU: Setting identity map for device 0000:00:1a.7 [0xec000 - 0xf0000]
IOMMU: Prepare 0-16MiB unity mapping for LPC
IOMMU: Setting identity map for device 0000:00:1f.0 [0x0 - 0x1000000]
PCI-DMA: Intel(R) Virtualization Technology for Directed I/O
Scanning for low memory corruption every 60 seconds
audit: initializing netlink socket (disabled)
type=2000 audit(1264052636.959:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Btrfs loaded
msgmni has been set to 23940
SELinux:  Registering netfilter hooks
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 253)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
  alloc irq_desc for 50 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:01.0: irq 50 for MSI/MSI-X
pcieport 0000:00:01.0: setting latency timer to 64
  alloc irq_desc for 51 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:03.0: irq 51 for MSI/MSI-X
pcieport 0000:00:03.0: setting latency timer to 64
  alloc irq_desc for 52 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:07.0: irq 52 for MSI/MSI-X
pcieport 0000:00:07.0: setting latency timer to 64
  alloc irq_desc for 53 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:1c.0: irq 53 for MSI/MSI-X
pcieport 0000:00:1c.0: setting latency timer to 64
  alloc irq_desc for 54 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:1c.2: irq 54 for MSI/MSI-X
pcieport 0000:00:1c.2: setting latency timer to 64
  alloc irq_desc for 55 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:1c.4: irq 55 for MSI/MSI-X
pcieport 0000:00:1c.4: setting latency timer to 64
  alloc irq_desc for 56 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
pcieport 0000:00:1c.5: irq 56 for MSI/MSI-X
pcieport 0000:00:1c.5: setting latency timer to 64
aer 0000:00:01.0:pcie02: AER service couldn't init device: no _OSC support
aer 0000:00:03.0:pcie02: AER service couldn't init device: no _OSC support
aer 0000:00:07.0:pcie02: AER service couldn't init device: no _OSC support
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
pci-stub: invalid id string ""
input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/input0
ACPI: Power Button [PWRB]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input1
ACPI: Power Button [PWRF]
ACPI: SSDT 00000000bf798200 01C0C (v01 DpgPmm  P001Ist 00000011 INTL 20060113)
ACPI: SSDT 00000000bf799e10 00659 (v01  PmRef  P001Cst 00003001 INTL 20060113)
Monitor-Mwait will be used to enter C-1 state
Monitor-Mwait will be used to enter C-2 state
Monitor-Mwait will be used to enter C-3 state
processor LNXCPU:00: registered as cooling_device0
processor LNXCPU:01: registered as cooling_device1
processor LNXCPU:02: registered as cooling_device2
processor LNXCPU:03: registered as cooling_device3
processor LNXCPU:04: registered as cooling_device4
processor LNXCPU:05: registered as cooling_device5
processor LNXCPU:06: registered as cooling_device6
processor LNXCPU:07: registered as cooling_device7
Non-volatile memory driver v1.3
Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
brd: module loaded
loop: module loaded
ahci 0000:00:1f.2: version 3.0
  alloc irq_desc for 20 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
ahci 0000:00:1f.2: PCI INT B -> GSI 20 (level, low) -> IRQ 20
  alloc irq_desc for 57 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
ahci 0000:00:1f.2: irq 57 for MSI/MSI-X
ahci: SSS flag set, parallel bus scan disabled
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part ccc ems sxs 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc100 irq 57
ata2: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc180 irq 57
ata3: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc200 irq 57
ata4: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc280 irq 57
ata5: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc300 irq 57
ata6: SATA max UDMA/133 abar m2048@0xf7ffc000 port 0xf7ffc380 irq 57
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: debug port 1
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xf7fff000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=1d6b, idProduct=0002
usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.7
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 6 ports detected
  alloc irq_desc for 23 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: debug port 1
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xf7ffe000
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=1d6b, idProduct=0002
usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.7
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
uhci_hcd: USB Universal Host Controller Interface driver
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x00009800
usb usb3: New USB device found, idVendor=1d6b, idProduct=0001
usb usb3: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb3: Product: UHCI Host Controller
usb usb3: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb3: SerialNumber: 0000:00:1a.0
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
  alloc irq_desc for 21 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x00009880
usb usb4: New USB device found, idVendor=1d6b, idProduct=0001
usb usb4: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb4: Product: UHCI Host Controller
usb usb4: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb4: SerialNumber: 0000:00:1a.1
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
  alloc irq_desc for 19 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
uhci_hcd 0000:00:1a.2: PCI INT D -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1a.2: setting latency timer to 64
uhci_hcd 0000:00:1a.2: UHCI Host Controller
uhci_hcd 0000:00:1a.2: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1a.2: irq 19, io base 0x00009c00
usb usb5: New USB device found, idVendor=1d6b, idProduct=0001
usb usb5: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb5: Product: UHCI Host Controller
usb usb5: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb5: SerialNumber: 0000:00:1a.2
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.0: irq 23, io base 0x00009080
usb usb6: New USB device found, idVendor=1d6b, idProduct=0001
usb usb6: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb6: Product: UHCI Host Controller
usb usb6: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb6: SerialNumber: 0000:00:1d.0
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.1: irq 19, io base 0x00009400
usb usb7: New USB device found, idVendor=1d6b, idProduct=0001
usb usb7: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb7: Product: UHCI Host Controller
usb usb7: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb7: SerialNumber: 0000:00:1d.1
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 8
uhci_hcd 0000:00:1d.2: irq 18, io base 0x00009480
usb usb8: New USB device found, idVendor=1d6b, idProduct=0001
usb usb8: New USB device strings: Mfr=3, Product=2, SerialNumber=1
usb usb8: Product: UHCI Host Controller
usb usb8: Manufacturer: Linux 2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty uhci_hcd
usb usb8: SerialNumber: 0000:00:1d.2
usb usb8: configuration #1 chosen from 1 choice
hub 8-0:1.0: USB hub found
hub 8-0:1.0: 2 ports detected
PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect please boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
rtc_cmos 00:03: RTC can wake from S4
rtc_cmos 00:03: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one month, y3k, 114 bytes nvram, hpet irqs
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
cpuidle: using governor ladder
cpuidle: using governor menu
usbcore: registered new interface driver hiddev
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
CONFIG_NF_CT_ACCT is deprecated and will be removed soon. Please use
nf_conntrack.acct=1 kernel parameter, acct=1 nf_conntrack module option or
sysctl net.netfilter.nf_conntrack_acct=1 to enable it.
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
Initializing XFRM netlink socket
NET: Registered protocol family 17
registered taskstats version 1
No TPM chip found, activating TPM-bypass!
  Magic number: 10:757:719
rtc_cmos 00:03: setting system clock to 2010-01-21 05:43:57 UTC (1264052637)
Initalizing network drop monitor service
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/input/input2
usb 1-5: new high speed USB device using ehci_hcd and address 2
usb 1-5: New USB device found, idVendor=0409, idProduct=005a
usb 1-5: New USB device strings: Mfr=0, Product=0, SerialNumber=0
usb 1-5: configuration #1 chosen from 1 choice
hub 1-5:1.0: USB hub found
hub 1-5:1.0: 4 ports detected
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-8: WDC WD10EADS-00L5B1, 01.01A01, max UDMA/133
ata1.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      WDC WD10EADS-00L 01.0 PQ: 0 ANSI: 5
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:0:0: [sda] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sda: sda1 sda2
sd 0:0:0:0: [sda] Attached SCSI disk
usb 7-1: new full speed USB device using uhci_hcd and address 2
usb 7-1: New USB device found, idVendor=0733, idProduct=0430
usb 7-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
usb 7-1: configuration #1 chosen from 1 choice
usb 7-2: new low speed USB device using uhci_hcd and address 3
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: WDC WD10EADS-00L5B1, 01.01A01, max UDMA/133
ata2.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata2.00: configured for UDMA/133
scsi 1:0:0:0: Direct-Access     ATA      WDC WD10EADS-00L 01.0 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 1:0:0:0: Attached scsi generic sg1 type 0
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdb: sdb1 sdb2
sd 1:0:0:0: [sdb] Attached SCSI disk
usb 7-2: New USB device found, idVendor=051d, idProduct=0002
usb 7-2: New USB device strings: Mfr=3, Product=1, SerialNumber=2
usb 7-2: Product: Back-UPS ES 550 FW:843.K1d.D USB FW:K1d
usb 7-2: Manufacturer: APC
usb 7-2: SerialNumber: 3B1806X13792  
usb 7-2: configuration #1 chosen from 1 choice
generic-usb 0003:051D:0002.0001: hiddev96,hidraw0: USB HID v1.10 Device [APC Back-UPS ES 550 FW:843.K1d.D USB FW:K1d] on usb-0000:00:1d.1-2/input0
ata3: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata3.00: ATA-8: WDC WD10EADS-00L5B1, 01.01A01, max UDMA/133
ata3.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata3.00: configured for UDMA/133
scsi 2:0:0:0: Direct-Access     ATA      WDC WD10EADS-00L 01.0 PQ: 0 ANSI: 5
sd 2:0:0:0: Attached scsi generic sg2 type 0
sd 2:0:0:0: [sdc] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 2:0:0:0: [sdc] Write Protect is off
sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdc: sdc1
sd 2:0:0:0: [sdc] Attached SCSI disk
ata4: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata4.00: ATA-8: WDC WD10EADS-00L5B1, 01.01A01, max UDMA/133
ata4.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata4.00: configured for UDMA/133
scsi 3:0:0:0: Direct-Access     ATA      WDC WD10EADS-00L 01.0 PQ: 0 ANSI: 5
sd 3:0:0:0: [sdd] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 3:0:0:0: Attached scsi generic sg3 type 0
sd 3:0:0:0: [sdd] Write Protect is off
sd 3:0:0:0: [sdd] Mode Sense: 00 3a 00 00
sd 3:0:0:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdd: sdd1
sd 3:0:0:0: [sdd] Attached SCSI disk
ata5: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata5.00: ATA-8: WDC WD10EADS-65L5B1, 01.01A01, max UDMA/133
ata5.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata5.00: configured for UDMA/133
scsi 4:0:0:0: Direct-Access     ATA      WDC WD10EADS-65L 01.0 PQ: 0 ANSI: 5
sd 4:0:0:0: [sde] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 4:0:0:0: Attached scsi generic sg4 type 0
sd 4:0:0:0: [sde] Write Protect is off
sd 4:0:0:0: [sde] Mode Sense: 00 3a 00 00
sd 4:0:0:0: [sde] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sde: sde1
sd 4:0:0:0: [sde] Attached SCSI disk
ata6: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata6.00: ATA-8: WDC WD10EADS-65L5B1, 01.01A01, max UDMA/133
ata6.00: 1953525168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata6.00: configured for UDMA/133
scsi 5:0:0:0: Direct-Access     ATA      WDC WD10EADS-65L 01.0 PQ: 0 ANSI: 5
sd 5:0:0:0: [sdf] 1953525168 512-byte logical blocks: (1.00 TB/931 GiB)
sd 5:0:0:0: Attached scsi generic sg5 type 0
sd 5:0:0:0: [sdf] Write Protect is off
sd 5:0:0:0: [sdf] Mode Sense: 00 3a 00 00
sd 5:0:0:0: [sdf] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
 sdf: sdf1
sd 5:0:0:0: [sdf] Attached SCSI disk
Freeing unused kernel memory: 1524k freed
Write protecting the kernel read-only data: 6788k
dracut: dracut-002-13.4.git8f397a9b.fc12
udev: starting version 147
Linux agpgart interface v0.103
[drm] Initialized drm 1.1.0 20060810
  alloc irq_desc for 24 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
nouveau 0000:02:00.0: PCI INT A -> GSI 24 (level, low) -> IRQ 24
nouveau 0000:02:00.0: setting latency timer to 64
[drm] nouveau 0000:02:00.0: Detected an NV50 generation card (0x450300a2)
[drm] nouveau 0000:02:00.0: Attempting to load BIOS image from PRAMIN
[drm] nouveau 0000:02:00.0: ... appears to be valid
[drm] nouveau 0000:02:00.0: BIT BIOS found
[drm] nouveau 0000:02:00.0: Bios version 60.80.18.00
[drm] nouveau 0000:02:00.0: TMDS table revision 2.0 not currently supported
[drm] nouveau 0000:02:00.0: BIT table 'd' not found
[drm] nouveau 0000:02:00.0: Found Display Configuration Block version 4.0
[drm] nouveau 0000:02:00.0: DCB connector table: VHER 0x40 5 14 2
[drm] nouveau 0000:02:00.0:   0: 0x00001030: type 0x30 idx 0 tag 0x07
[drm] nouveau 0000:02:00.0:   1: 0x00002130: type 0x30 idx 1 tag 0x08
[drm] nouveau 0000:02:00.0:   2: 0x00000210: type 0x10 idx 2 tag 0xff
[drm] nouveau 0000:02:00.0:   3: 0x00000211: type 0x11 idx 2 tag 0xff
[drm] nouveau 0000:02:00.0:   4: 0x00000213: type 0x13 idx 2 tag 0xff
[drm] nouveau 0000:02:00.0: Raw DCB entry 0: 04000320 00000028
[drm] nouveau 0000:02:00.0: Raw DCB entry 1: 01000322 00000030
[drm] nouveau 0000:02:00.0: Raw DCB entry 2: 02011310 00000028
[drm] nouveau 0000:02:00.0: Raw DCB entry 3: 02011312 00000030
[drm] nouveau 0000:02:00.0: Raw DCB entry 4: 010223f1 00c1c020
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table 0 at offset 0xBFB4
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table 1 at offset 0xC1BF
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table 2 at offset 0xD37B
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table 3 at offset 0xD46A
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table 4 at offset 0xD621
[drm] nouveau 0000:02:00.0: Parsing VBIOS init table at offset 0xD686
[drm] nouveau 0000:02:00.0: 0xD686: Condition still not met after 20ms, skipping following opcodes
[drm] nouveau 0000:02:00.0: 0xB284: parsing output script 0
[drm] nouveau 0000:02:00.0: 0xB284: parsing output script 0
[drm] nouveau 0000:02:00.0: 0xA8FA: parsing output script 0
[TTM] Zone  kernel: Available graphics memory: 6129650 kiB.
[TTM] Zone   dma32: Available graphics memory: 2097152 kiB.
[drm] nouveau 0000:02:00.0: 320 MiB VRAM
[drm] nouveau 0000:02:00.0: 512 MiB GART (aperture)
nouveau 0000:02:00.0: firmware: requesting nouveau/nv50.ctxprog
dracut: 
dracut: udevadm settle - timeout of 30 seconds reached, the event queue contains:
dracut: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0 (936)
dracut: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/drm/controlD64 (1024)
dracut: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/drm/card0 (1025)
dracut: /sys/devices/pci0000:00/0000:00:03.0/0000:02:00.0/i2c-0 (1026)
dracut: Starting plymouth daemon
pata_marvell 0000:05:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pata_marvell 0000:05:00.0: setting latency timer to 64
scsi6 : pata_marvell
scsi7 : pata_marvell
ata7: PATA max UDMA/100 cmd 0xcc00 ctl 0xc880 bmdma 0xc400 irq 16
ata8: PATA max UDMA/133 cmd 0xc800 ctl 0xc480 bmdma 0xc408 irq 16
ata7.01: NODEV after polling detection
irq 16: nobody cared (try booting with the "irqpoll" option)
Pid: 0, comm: swapper Tainted: G        W  2.6.32.4MMAPDMARAF3SKY2PSKBMAYPULL-00912-g914160d-dirty #6
Call Trace:
 <IRQ>  [<ffffffff810a43ff>] __report_bad_irq+0x3d/0x8c
 [<ffffffff810a4566>] note_interrupt+0x118/0x17e
 [<ffffffff810a4c69>] handle_fasteoi_irq+0x9c/0xc1
 [<ffffffff81014422>] handle_irq+0x24/0x2c
 [<ffffffff8147052c>] do_IRQ+0x5c/0xbc
 [<ffffffff81012613>] ret_from_intr+0x0/0x16
 <EOI>  [<ffffffff812c729a>] ? acpi_idle_enter_bm+0x256/0x28a
 [<ffffffff812c7293>] ? acpi_idle_enter_bm+0x24f/0x28a
 [<ffffffff813a6c3c>] ? cpuidle_idle_call+0x9e/0xfa
 [<ffffffff81010c90>] ? cpu_idle+0xb4/0xf6
 [<ffffffff81465ba5>] ? start_secondary+0x201/0x242
handlers:
[<ffffffff8134d15a>] (usb_hcd_irq+0x0/0xa7)
[<ffffffff813395ce>] (ata_sff_interrupt+0x0/0x96)
Disabling IRQ #16
ata7.00: ATAPI: HP  DVD Writer 400, KH27, max UDMA/33
ata7.00: configured for UDMA/33
scsi 6:0:0:0: CD-ROM            HP       DVD Writer 400c  KH27 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 40x/40x writer cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 6:0:0:0: Attached scsi CD-ROM sr0
sr 6:0:0:0: Attached scsi generic sg6 type 5
[drm] nouveau 0000:02:00.0: No ctxprog for NV50
[drm] nouveau 0000:02:00.0: Detected a DAC output
[drm] nouveau 0000:02:00.0: Detected a TMDS output
[drm] nouveau 0000:02:00.0: Detected a DAC output
[drm] nouveau 0000:02:00.0: Detected a TMDS output
[drm] nouveau 0000:02:00.0: DCB encoder 1 unknown
[drm] nouveau 0000:02:00.0: Detected a DVI-I connector
[drm] nouveau 0000:02:00.0: Detected a DVI-I connector
[drm] nouveau 0000:02:00.0: allocated 1680x1050 fb: 0x401c0000, bo ffff88032dba3400
fb0: nouveaufb frame buffer device
registered panic notifier
[drm] Initialized nouveau 0.0.15 20090420 for 0000:02:00.0 on minor 0
dracut: Autoassembling MD Raid
md: md0 stopped.
md: bind<sdb1>
md: bind<sda1>
md: raid1 personality registered for level 1
raid1: raid set md0 active with 2 out of 2 mirrors
md0: detected capacity change from 0 to 209649664
dracut: mdadm: /dev/md0 has been started with 2 drives.
 md0: unknown partition table
md: md1 stopped.
md: bind<sdb2>
md: bind<sdc1>
md: bind<sdd1>
md: bind<sdf1>
md: bind<sde1>
md: bind<sda2>
async_tx: api initialized (async)
xor: automatically using best checksumming function: generic_sse
   generic_sse:  8908.000 MB/sec
xor: using function: generic_sse (8908.000 MB/sec)
raid6: int64x1   2371 MB/s
raid6: int64x2   2476 MB/s
raid6: int64x4   2039 MB/s
raid6: int64x8   1558 MB/s
raid6: sse2x1    5906 MB/s
raid6: sse2x2    6945 MB/s
raid6: sse2x4    8015 MB/s
raid6: using algorithm sse2x4 (8015 MB/s)
md: raid6 personality registered for level 6
md: raid5 personality registered for level 5
md: raid4 personality registered for level 4
raid5: device sda2 operational as raid disk 0
raid5: device sde1 operational as raid disk 5
raid5: device sdf1 operational as raid disk 4
raid5: device sdd1 operational as raid disk 3
raid5: device sdc1 operational as raid disk 2
raid5: device sdb2 operational as raid disk 1
raid5: allocated 6386kB for md1
0: w=1 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
5: w=2 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
4: w=3 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
3: w=4 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
2: w=5 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
1: w=6 pa=0 pr=6 m=2 a=2 r=6 op1=0 op2=0
raid5: raid level 6 set md1 active with 6 out of 6 devices, algorithm 2
RAID5 conf printout:
 --- rd:6 wd:6
 disk 0, o:1, dev:sda2
 disk 1, o:1, dev:sdb2
 disk 2, o:1, dev:sdc1
 disk 3, o:1, dev:sdd1
 disk 4, o:1, dev:sdf1
 disk 5, o:1, dev:sde1
md1: detected capacity change from 0 to 3999969837056
dracut: mdadm: /dev/md1 has been started with 6 drives.
 md1: unknown partition table
dracut: Scanning devices md1  for LVM volume groups 
dracut: Reading all physical volumes. This may take a while...
dracut: Found volume group "vg_00" using metadata type lvm2
dracut: 13 logical volume(s) in volume group "vg_00" now active
dracut: Autoassembling MD Raid
EXT4-fs (dm-3): mounted filesystem with ordered data mode
dracut: Mounted root filesystem /dev/mapper/vg_00-LogVol02_root
dracut: Loading SELinux policy
type=1404 audit(1264052705.420:2): enforcing=1 old_enforcing=0 auid=4294967295 ses=4294967295
SELinux: 8192 avtab hash slots, 131435 rules.
SELinux: 8192 avtab hash slots, 131435 rules.
SELinux:  8 users, 12 roles, 2787 types, 129 bools, 1 sens, 1024 cats
SELinux:  74 classes, 131435 rules
SELinux:  class tun_socket not defined in policy
SELinux:  permission module_request in class system not defined in policy
SELinux: the above unknown classes and permissions will be allowed
SELinux:  Completing initialization.
SELinux:  Setting up existing superblocks.
SELinux: initialized (dev dm-3, type ext4), uses xattr
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev securityfs, type securityfs), uses genfs_contexts
SELinux: initialized (dev usbfs, type usbfs), uses genfs_contexts
SELinux: initialized (dev selinuxfs, type selinuxfs), uses genfs_contexts
SELinux: initialized (dev mqueue, type mqueue), uses transition SIDs
SELinux: initialized (dev hugetlbfs, type hugetlbfs), uses genfs_contexts
SELinux: initialized (dev devpts, type devpts), uses transition SIDs
SELinux: initialized (dev inotifyfs, type inotifyfs), uses genfs_contexts
SELinux: initialized (dev anon_inodefs, type anon_inodefs), uses genfs_contexts
SELinux: initialized (dev pipefs, type pipefs), uses task SIDs
SELinux: initialized (dev debugfs, type debugfs), uses genfs_contexts
SELinux: initialized (dev sockfs, type sockfs), uses task SIDs
SELinux: initialized (dev tmpfs, type tmpfs), uses transition SIDs
SELinux: initialized (dev proc, type proc), uses genfs_contexts
SELinux: initialized (dev bdev, type bdev), uses genfs_contexts
SELinux: initialized (dev rootfs, type rootfs), uses genfs_contexts
SELinux: initialized (dev sysfs, type sysfs), uses genfs_contexts
type=1403 audit(1264052705.655:3): policy loaded auid=4294967295 ses=4294967295
dracut: Switching root
[drm] DAC-7: set mode 1680x1050 25
Console: switching to colour frame buffer device 210x65
[drm] nouveau 0000:02:00.0: 0x0FA9: parsing clock script 0
udev: starting version 147
iTCO_vendor_support: vendor-support=0
iTCO_wdt: Intel TCO WatchDog Timer Driver v1.05
iTCO_wdt: Found a ICH10R TCO device (Version=2, TCOBASE=0x0860)
iTCO_wdt: initialized. heartbeat=30 sec (nowayout=0)
input: PC Speaker as /devices/platform/pcspkr/input/input3
ACPI: WMI: Mapper loaded
sky2 driver version 1.25
sky2 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
sky2 0000:06:00.0: setting latency timer to 64
sky2 0000:06:00.0: Yukon-2 EC Ultra chip revision 3
  alloc irq_desc for 58 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
sky2 0000:06:00.0: irq 58 for MSI/MSI-X
sky2 eth0: addr 00:26:18:00:1c:3b
sky2 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
sky2 0000:04:00.0: setting latency timer to 64
sky2 0000:04:00.0: Yukon-2 EC Ultra chip revision 3
  alloc irq_desc for 59 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
sky2 0000:04:00.0: irq 59 for MSI/MSI-X
sky2 eth1: addr 00:26:18:00:1c:3a
Linux video capture interface: v2.00
i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ACPI: I/O resource 0000:00:1f.3 [0x400-0x41f] conflicts with ACPI region SMRG [0x400-0x40f]
ACPI: If an ACPI driver is available for this device, you should use it instead of the native driver
gspca: main v2.7.0 registered
gspca: probing 0733:0430
gspca: probe ok
usbcore: registered new interface driver spca505
spca505: registered
firewire_ohci 0000:08:02.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
firewire_ohci: Added fw-ohci device 0000:08:02.0, OHCI version 1.10
  alloc irq_desc for 22 on node -1
  alloc kstat_irqs on node -1
alloc irq_2_iommu on node -1
HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
HDA Intel 0000:00:1b.0: setting latency timer to 64
ENS1371 0000:08:01.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
firewire_core: created device fw0: GUID 001e8c0001e5e584, S400
hda_codec: AD1989B: BIOS auto-probing.
ALSA sound/pci/hda/hda_codec.c:3881: autoconfig: line_outs=4 (0x12/0x16/0x24/0x25/0x0)
ALSA sound/pci/hda/hda_codec.c:3885:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
ALSA sound/pci/hda/hda_codec.c:3889:    hp_outs=1 (0x11/0x0/0x0/0x0/0x0)
ALSA sound/pci/hda/hda_codec.c:3890:    mono: mono_out=0x0
ALSA sound/pci/hda/hda_codec.c:3893:    dig-out=0x1b/0x1d
ALSA sound/pci/hda/hda_codec.c:3901:    inputs: mic=0x17, fmic=0x14, line=0x15, fline=0x0, cd=0x18, aux=0x0
input: HDA Digital PCBeep as /devices/pci0000:00/0000:00:1b.0/input/input4
ALSA sound/pci/hda/hda_intel.c:698: azx_get_response timeout, switching to polling mode: last cmd=0x002f0d00
gameport: ES137x is pci0000:08:01.0/gameport0, io 0x200, speed 663kHz
name_count maxed, losing inode data: dev=00:06, inode=11914
name_count maxed, losing inode data: dev=00:06, inode=11914
name_count maxed, losing inode data: dev=00:06, inode=11914
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11919
name_count maxed, losing inode data: dev=00:06, inode=11919
name_count maxed, losing inode data: dev=00:06, inode=11919
name_count maxed, losing inode data: dev=00:06, inode=11919
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11924
name_count maxed, losing inode data: dev=00:06, inode=11924
name_count maxed, losing inode data: dev=00:06, inode=11924
name_count maxed, losing inode data: dev=00:06, inode=11924
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11929
name_count maxed, losing inode data: dev=00:06, inode=11929
name_count maxed, losing inode data: dev=00:06, inode=11929
name_count maxed, losing inode data: dev=00:06, inode=11929
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11934
name_count maxed, losing inode data: dev=00:06, inode=11934
name_count maxed, losing inode data: dev=00:06, inode=11934
name_count maxed, losing inode data: dev=00:06, inode=11934
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11939
name_count maxed, losing inode data: dev=00:06, inode=11939
name_count maxed, losing inode data: dev=00:06, inode=11939
name_count maxed, losing inode data: dev=00:06, inode=11939
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11944
name_count maxed, losing inode data: dev=00:06, inode=11944
name_count maxed, losing inode data: dev=00:06, inode=11944
name_count maxed, losing inode data: dev=00:06, inode=11944
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11949
name_count maxed, losing inode data: dev=00:06, inode=11949
name_count maxed, losing inode data: dev=00:06, inode=11949
name_count maxed, losing inode data: dev=00:06, inode=11949
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11954
name_count maxed, losing inode data: dev=00:06, inode=11954
name_count maxed, losing inode data: dev=00:06, inode=11954
name_count maxed, losing inode data: dev=00:06, inode=11954
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11959
name_count maxed, losing inode data: dev=00:06, inode=11959
name_count maxed, losing inode data: dev=00:06, inode=11959
name_count maxed, losing inode data: dev=00:06, inode=11959
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11965
name_count maxed, losing inode data: dev=00:06, inode=11965
name_count maxed, losing inode data: dev=00:06, inode=11965
name_count maxed, losing inode data: dev=00:06, inode=11965
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11970
name_count maxed, losing inode data: dev=00:06, inode=11970
name_count maxed, losing inode data: dev=00:06, inode=11970
name_count maxed, losing inode data: dev=00:06, inode=11970
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11975
name_count maxed, losing inode data: dev=00:06, inode=11975
name_count maxed, losing inode data: dev=00:06, inode=11975
name_count maxed, losing inode data: dev=00:06, inode=11975
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11980
name_count maxed, losing inode data: dev=00:06, inode=11980
name_count maxed, losing inode data: dev=00:06, inode=11980
name_count maxed, losing inode data: dev=00:06, inode=11980
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11985
name_count maxed, losing inode data: dev=00:06, inode=11985
name_count maxed, losing inode data: dev=00:06, inode=11985
name_count maxed, losing inode data: dev=00:06, inode=11985
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11990
name_count maxed, losing inode data: dev=00:06, inode=11990
name_count maxed, losing inode data: dev=00:06, inode=11990
name_count maxed, losing inode data: dev=00:06, inode=11990
name_count maxed, losing inode data: dev=00:06, inode=11906
name_count maxed, losing inode data: dev=00:06, inode=11995
name_count maxed, losing inode data: dev=00:06, inode=11995
name_count maxed, losing inode data: dev=00:06, inode=11995
name_count maxed, losing inode data: dev=00:06, inode=11995
name_count maxed, losing inode data: dev=00:06, inode=201
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12003
name_count maxed, losing inode data: dev=00:06, inode=12003
name_count maxed, losing inode data: dev=00:06, inode=12003
name_count maxed, losing inode data: dev=00:06, inode=12003
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12008
name_count maxed, losing inode data: dev=00:06, inode=12008
name_count maxed, losing inode data: dev=00:06, inode=12008
name_count maxed, losing inode data: dev=00:06, inode=12008
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12013
name_count maxed, losing inode data: dev=00:06, inode=12013
name_count maxed, losing inode data: dev=00:06, inode=12013
name_count maxed, losing inode data: dev=00:06, inode=12013
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12018
name_count maxed, losing inode data: dev=00:06, inode=12018
name_count maxed, losing inode data: dev=00:06, inode=12018
name_count maxed, losing inode data: dev=00:06, inode=12018
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12023
name_count maxed, losing inode data: dev=00:06, inode=12023
name_count maxed, losing inode data: dev=00:06, inode=12023
name_count maxed, losing inode data: dev=00:06, inode=12023
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12028
name_count maxed, losing inode data: dev=00:06, inode=12028
name_count maxed, losing inode data: dev=00:06, inode=12028
name_count maxed, losing inode data: dev=00:06, inode=12028
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12033
name_count maxed, losing inode data: dev=00:06, inode=12033
name_count maxed, losing inode data: dev=00:06, inode=12033
name_count maxed, losing inode data: dev=00:06, inode=12033
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12038
name_count maxed, losing inode data: dev=00:06, inode=12038
name_count maxed, losing inode data: dev=00:06, inode=12038
name_count maxed, losing inode data: dev=00:06, inode=12038
name_count maxed, losing inode data: dev=00:06, inode=12000
name_count maxed, losing inode data: dev=00:06, inode=12043
name_count maxed, losing inode data: dev=00:06, inode=12043
name_count maxed, losing inode data: dev=00:06, inode=12043
name_count maxed, losing inode data: dev=00:06, inode=12043
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
name_count maxed, losing inode data: dev=00:06, inode=12050
device-mapper: multipath: version 1.1.0 loaded
EXT4-fs (dm-6): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-6, type ext4), uses xattr
EXT4-fs (dm-1): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-1, type ext4), uses xattr
EXT4-fs (dm-5): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-5, type ext4), uses xattr
kjournald starting.  Commit interval 5 seconds
EXT3 FS on md0, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
SELinux: initialized (dev md0, type ext3), uses xattr
EXT4-fs (dm-7): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-7, type ext4), uses xattr
EXT4-fs (dm-8): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-8, type ext4), uses xattr
EXT4-fs (dm-4): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-4, type ext4), uses xattr
EXT4-fs (dm-2): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-2, type ext4), uses xattr
device fsid 834fc529ea4ea2c5-f9308b94bfd9cac devid 1 transid 24026 /dev/mapper/vg_00-kvm_guest_btrfs_test
SELinux: initialized (dev dm-9, type btrfs), uses xattr
EXT4-fs (dm-10): mounted filesystem with ordered data mode
SELinux: initialized (dev dm-10, type ext4), uses xattr
Adding 17432568k swap on /dev/mapper/vg_00-LogVol00_swap.  Priority:-1 extents:1 across:17432568k 
SELinux: initialized (dev binfmt_misc, type binfmt_misc), uses genfs_contexts

--Boundary_(ID_4/mclBUfdWhwQaAkg94QoQ)--
