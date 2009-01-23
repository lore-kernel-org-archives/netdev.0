From: "Doug Bazarnic" <kernel@bazarnic.net>
Subject: RE: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Date: Fri, 23 Jan 2009 03:12:39 -0700
Message-ID: <006b01c97d43$204fc7b0$60ef5710$@net>
References: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan> <20090114213618.a610d647.akpm@linux-foundation.org> <alpine.DEB.1.10.0901150407130.6755@p34.internal.lan> <20090115202104.GA32495@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, "'Alan Piszcz'" <ap@solarrain.com>,
	<netdev@vger.kernel.org>
To: "'Francois Romieu'" <romieu@fr.zoreil.com>,
	"'Justin Piszcz'" <jpiszcz@lucidpixels.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762305AbZAWKM5@vger.kernel.org>
In-Reply-To: <20090115202104.GA32495@electric-eye.fr.zoreil.com>
Content-Language: en-us
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've just setup a lab in the office to test out IPVS, and I'm using an Asus
p5q-ws MB with dual r8169 nics on board.  This machine is acting as a load
balancer, and it's just directing packets to the web servers.  Lots of
requests...

After about 20 minutes of hammering it with two servers running apache
bench, I too get the r8169 time out.   It causes a temporary hiccup.

Running 2.6.28.1 on centos 5.2 x86_64.  It just dropped the connection
again, as you can see in /var/log/messages, but there was no kernel panic
with this one.

Jan 23 02:32:32 director1 kernel: ------------[ cut here ]------------
Jan 23 02:32:32 director1 kernel: WARNING: at net/sched/sch_generic.c:226
dev_watchdog+0x206/0x220()
Jan 23 02:32:32 director1 kernel: NETDEV WATCHDOG: eth0 (r8169): transmit
timed out
Jan 23 02:32:32 director1 kernel: Modules linked in: dm_mirror
dm_region_hash dm_log dm_multipath dm_mod serio_raw pcspkr
Jan 23 02:32:32 director1 kernel: Pid: 0, comm: swapper Not tainted 2.6.28.1
#6
Jan 23 02:32:32 director1 kernel: Call Trace:
Jan 23 02:32:32 director1 kernel:  <IRQ>  [<ffffffff8023633c>]
warn_slowpath+0x10c/0x150
Jan 23 02:32:32 director1 kernel:  [<ffffffff8026e659>] cpupri_set+0xa9/0xe0
Jan 23 02:32:32 director1 kernel:  [<ffffffff8024ab39>]
autoremove_wake_function+0x9/0x30
Jan 23 02:32:32 director1 kernel:  [<ffffffff8022c367>]
source_load+0x37/0x70
Jan 23 02:32:32 director1 kernel:  [<ffffffff803cfb5a>] __next_cpu+0x1a/0x30
Jan 23 02:32:32 director1 kernel:  [<ffffffff8022daec>]
find_busiest_group+0x18c/0x820
Jan 23 02:32:32 director1 kernel:  [<ffffffff803d52fe>] strlcpy+0x4e/0x80
Jan 23 02:32:32 director1 kernel:  [<ffffffff804b78b6>]
dev_watchdog+0x206/0x220
Jan 23 02:32:32 director1 kernel:  [<ffffffff802122d9>] read_tsc+0x9/0x20
Jan 23 02:32:32 director1 kernel:  [<ffffffff80250368>]
getnstimeofday+0x48/0xe0
Jan 23 02:32:32 director1 kernel:  [<ffffffff8024d5e8>]
run_hrtimer_pending+0x18/0x120
Jan 23 02:32:32 director1 kernel:  [<ffffffff804b76b0>]
dev_watchdog+0x0/0x220
Jan 23 02:32:32 director1 kernel:  [<ffffffff8023fbff>]
run_timer_softirq+0x15f/0x1c0
Jan 23 02:32:32 director1 kernel:  [<ffffffff8023b52c>]
__do_softirq+0x9c/0x170
Jan 23 02:32:32 director1 kernel:  [<ffffffff8020c87c>]
call_softirq+0x1c/0x30
Jan 23 02:32:32 director1 kernel:  [<ffffffff8020e135>] do_softirq+0x35/0x70
Jan 23 02:32:32 director1 kernel:  [<ffffffff8021c205>]
smp_apic_timer_interrupt+0x85/0xd0
Jan 23 02:32:32 director1 kernel:  [<ffffffff8020c2cb>]
apic_timer_interrupt+0x6b/0x70
Jan 23 02:32:32 director1 kernel:  <EOI>  [<ffffffff802130c1>]
mwait_idle+0x41/0x50
Jan 23 02:32:32 director1 kernel:  [<ffffffff8020a2da>] cpu_idle+0x3a/0x70
Jan 23 02:32:32 director1 kernel: ---[ end trace 9b1a7551bf7a6a56 ]---
Jan 23 02:32:32 director1 kernel: r8169: eth0: link up
Jan 23 02:32:38 director1 ldirectord[2881]: Restored real server:
192.168.1.151:80 (192.168.1.150:80) (Weight set to 5) 
Jan 23 02:32:38 director1 ldirectord[2881]: Restored real server:
192.168.1.152:80 (192.168.1.150:80) (Weight set to 5) 
Jan 23 02:37:31 director1 ldirectord[2881]: Quiescent real server:
192.168.1.151:80 (192.168.1.150:80) (Weight set to 0) 
Jan 23 02:37:41 director1 ldirectord[2881]: Quiescent real server:
192.168.1.152:80 (192.168.1.150:80) (Weight set to 0) 
Jan 23 02:38:38 director1 kernel: r8169: eth0: link up
Jan 23 02:38:42 director1 ldirectord[2881]: Restored real server:
192.168.1.151:80 (192.168.1.150:80) (Weight set to 5) 
Jan 23 02:38:42 director1 ldirectord[2881]: Restored real server:
192.168.1.152:80 (192.168.1.150:80) (Weight set to 5) 
Jan 23 02:46:23 director1 sshd[2935]: Timeout, client not responding.
Jan 23 02:59:42 director1 ldirectord[2881]: Quiescent real server:
192.168.1.151:80 (192.168.1.150:80) (Weight set to 0) 
Jan 23 02:59:52 director1 ldirectord[2881]: Quiescent real server:
192.168.1.152:80 (192.168.1.150:80) (Weight set to 0) 
Jan 23 03:00:56 director1 kernel: r8169: eth0: link up
Jan 23 03:01:00 director1 ldirectord[2881]: Restored real server:
192.168.1.151:80 (192.168.1.150:80) (Weight set to 5) 
Jan 23 03:01:00 director1 ldirectord[2881]: Restored real server:
192.168.1.152:80 (192.168.1.150:80) (Weight set to 5)


[root@director1 ~]# dmesg  
BIOS EBDA/lowmem at: 0009ec00/0009ec00
Linux version 2.6.28.1 (root@director1) (gcc version 4.1.2 20071124 (Red Hat
4.1.2-42)) #6 SMP Fri Jan 23 01:43:15 MST 2009
Command line: ro root=LABEL=/
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009ec00 (usable)
 BIOS-e820: 000000000009ec00 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e4000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000cff70000 (usable)
 BIOS-e820: 00000000cff70000 - 00000000cff7e000 (ACPI data)
 BIOS-e820: 00000000cff7e000 - 00000000cffd0000 (ACPI NVS)
 BIOS-e820: 00000000cffd0000 - 00000000d0000000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffe00000 - 0000000100000000 (reserved)
 BIOS-e820: 0000000100000000 - 0000000230000000 (usable)
DMI present.
AMI BIOS detected: BIOS may corrupt low RAM, working it around.
last_pfn = 0x230000 max_arch_pfn = 0x3ffffffff
x86 PAT enabled: cpu 0, old 0x7040600070406, new 0x7010600070106
last_pfn = 0xcff70 max_arch_pfn = 0x3ffffffff
init_memory_mapping: 0000000000000000-00000000cff70000
 0000000000 - 00cfe00000 page 2M
 00cfe00000 - 00cff70000 page 4k
kernel direct mapping tables up to cff70000 @ 10000-16000
last_map_addr: cff70000 end: cff70000
init_memory_mapping: 0000000100000000-0000000230000000
 0100000000 - 0230000000 page 2M
kernel direct mapping tables up to 230000000 @ 14000-1e000
last_map_addr: 230000000 end: 230000000
RAMDISK: 37dd3000 - 37fefa7c
(7 early reservations) ==> bootmem [0000000000 - 0230000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 -
0000001000]
  #1 [0000006000 - 0000008000]       TRAMPOLINE ==> [0000006000 -
0000008000]
  #2 [0000200000 - 0000790354]    TEXT DATA BSS ==> [0000200000 -
0000790354]
  #3 [0037dd3000 - 0037fefa7c]          RAMDISK ==> [0037dd3000 -
0037fefa7c]
  #4 [000009ec00 - 0000100000]    BIOS reserved ==> [000009ec00 -
0000100000]
  #5 [0000010000 - 0000014000]          PGTABLE ==> [0000010000 -
0000014000]
  #6 [0000014000 - 0000019000]          PGTABLE ==> [0000014000 -
0000019000]
found SMP MP-table at [ffff8800000ff780] 000ff780
 [ffffe20000000000-ffffe20007bfffff] PMD ->
[ffff880028200000-ffff88002fdfffff] on node 0
Zone PFN ranges:
  DMA      0x00000010 -> 0x00001000
  DMA32    0x00001000 -> 0x00100000
  Normal   0x00100000 -> 0x00230000
Movable zone start PFN for each node
early_node_map[3] active PFN ranges
    0: 0x00000010 -> 0x0000009e
    0: 0x00000100 -> 0x000cff70
    0: 0x00100000 -> 0x00230000
On node 0 totalpages: 2096894
  DMA zone: 56 pages used for memmap
  DMA zone: 1535 pages reserved
  DMA zone: 2391 pages, LIFO batch:0
  DMA32 zone: 14280 pages used for memmap
  DMA32 zone: 833448 pages, LIFO batch:31
  Normal zone: 17024 pages used for memmap
  Normal zone: 1228160 pages, LIFO batch:31
  Movable zone: 0 pages used for memmap
Intel MultiProcessor Specification v1.4
MPTABLE: OEM ID: 
MPTABLE: Product ID: 
MPTABLE: APIC at: 0xFEE00000
Processor #0 (Bootup-CPU)
Processor #1
Processor #2
Processor #3
I/O APIC #4 Version 32 at 0xFEC00000.
Processors: 4
SMP: Allowing 4 CPUs, 0 hotplug CPUs
Allocating PCI resources starting at d4000000 (gap: d0000000:2ee00000)
PERCPU: Allocating 45056 bytes of per cpu data
NR_CPUS: 16, nr_cpu_ids: 4, nr_node_ids 1
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2063999
Kernel command line: ro root=LABEL=/
Initializing CPU#0
PID hash table entries: 4096 (order: 12, 32768 bytes)
TSC: Using PIT calibration value
Detected 2832.882 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Checking aperture...
No AGP bridge found
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
Placing software IO TLB between 0x20000000 - 0x24000000
Memory: 8172616k/9175040k available (3226k kernel code, 787464k absent,
214072k reserved, 1291k data, 340k init)
Calibrating delay loop (skipped), value calculated using timer frequency..
5665.76 BogoMIPS (lpj=2832882)
Mount-cache hash table entries: 256
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
CPU0: Thermal monitoring enabled (TM2)
using mwait in idle threads.
Freeing SMP alternatives: 27k freed
Setting APIC routing to flat
ExtINT not setup in hardware but reported by MP table
..TIMER: vector=0x30 apic1=0 pin1=2 apic2=0 pin2=0
CPU0: Intel(R) Core(TM)2 Quad  CPU   Q9550  @ 2.83GHz stepping 07
Booting processor 1 APIC 0x1 ip 0x6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5664.98 BogoMIPS
(lpj=2832492)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
CPU1: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 1, old 0x7040600070406, new 0x7010600070106
CPU1: Intel(R) Core(TM)2 Quad  CPU   Q9550  @ 2.83GHz stepping 07
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Booting processor 2 APIC 0x2 ip 0x6000
Initializing CPU#2
Calibrating delay using timer specific routine.. 5664.98 BogoMIPS
(lpj=2832494)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 2
CPU2: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 2, old 0x7040600070406, new 0x7010600070106
CPU2: Intel(R) Core(TM)2 Quad  CPU   Q9550  @ 2.83GHz stepping 07
checking TSC synchronization [CPU#0 -> CPU#2]: passed.
Booting processor 3 APIC 0x3 ip 0x6000
Initializing CPU#3
Calibrating delay using timer specific routine.. 5664.99 BogoMIPS
(lpj=2832498)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 6144K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 3
CPU3: Thermal monitoring enabled (TM2)
x86 PAT enabled: cpu 3, old 0x7040600070406, new 0x7010600070106
CPU3: Intel(R) Core(TM)2 Quad  CPU   Q9550  @ 2.83GHz stepping 07
checking TSC synchronization [CPU#0 -> CPU#3]: passed.
Brought up 4 CPUs
Total of 4 processors activated (22660.73 BogoMIPS).
net_namespace: 832 bytes
NET: Registered protocol family 16
PCI: Using configuration type 1 for base access
SCSI subsystem initialized
libata version 3.00 loaded.
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:1a.0: reg 20 io port: [0xc800-0xc81f]
pci 0000:00:1a.1: reg 20 io port: [0xc880-0xc89f]
pci 0000:00:1a.2: reg 20 io port: [0xcc00-0xcc1f]
pci 0000:00:1a.7: reg 10 32bit mmio: [0xfbfffc00-0xfbffffff]
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1c.4: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.4: PME# disabled
pci 0000:00:1c.5: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.5: PME# disabled
pci 0000:00:1d.0: reg 20 io port: [0xc080-0xc09f]
pci 0000:00:1d.1: reg 20 io port: [0xc400-0xc41f]
pci 0000:00:1d.2: reg 20 io port: [0xc480-0xc49f]
pci 0000:00:1d.7: reg 10 32bit mmio: [0xfbfff800-0xfbfffbff]
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.2: reg 10 io port: [0xbc00-0xbc07]
pci 0000:00:1f.2: reg 14 io port: [0xb880-0xb883]
pci 0000:00:1f.2: reg 18 io port: [0xb800-0xb807]
pci 0000:00:1f.2: reg 1c io port: [0xb480-0xb483]
pci 0000:00:1f.2: reg 20 io port: [0xb400-0xb41f]
pci 0000:00:1f.2: reg 24 32bit mmio: [0xfbffe800-0xfbffefff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.3: reg 10 64bit mmio: [0xfbfff400-0xfbfff4ff]
pci 0000:00:1f.3: reg 20 io port: [0x400-0x41f]
pci 0000:01:00.0: reg 10 32bit mmio: [0xfd000000-0xfdffffff]
pci 0000:01:00.0: reg 14 64bit mmio: [0xd0000000-0xdfffffff]
pci 0000:01:00.0: reg 1c 64bit mmio: [0xfc000000-0xfcffffff]
pci 0000:01:00.0: reg 30 32bit mmio: [0xfe8e0000-0xfe8fffff]
pci 0000:00:01.0: bridge 32bit mmio: [0xfc000000-0xfe8fffff]
pci 0000:00:01.0: bridge 64bit mmio pref: [0xd0000000-0xdfffffff]
pci 0000:04:00.0: supports D1
pci 0000:04:00.0: PME# supported from D0 D1 D3hot D3cold
pci 0000:04:00.0: PME# disabled
pci 0000:04:00.1: reg 10 64bit mmio: [0xfebffc00-0xfebffc7f]
pci 0000:04:00.1: supports D1
pci 0000:04:00.1: PME# supported from D0 D1 D3hot D3cold
pci 0000:04:00.1: PME# disabled
pci 0000:00:1c.0: bridge 32bit mmio: [0xfeb00000-0xfebfffff]
pci 0000:00:1c.0: bridge 64bit mmio pref: [0xfaf00000-0xfaffffff]
pci 0000:04:00.1: bridge 64bit mmio pref: [0xfaf00000-0xfaffffff]
pci 0000:03:00.0: reg 10 io port: [0xe800-0xe8ff]
pci 0000:03:00.0: reg 18 64bit mmio: [0xfeaff000-0xfeafffff]
pci 0000:03:00.0: reg 20 64bit mmio: [0xfaef0000-0xfaefffff]
pci 0000:03:00.0: reg 30 32bit mmio: [0xfeac0000-0xfeadffff]
pci 0000:03:00.0: supports D1 D2
pci 0000:03:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:03:00.0: PME# disabled
pci 0000:00:1c.4: bridge io port: [0xe000-0xefff]
pci 0000:00:1c.4: bridge 32bit mmio: [0xfea00000-0xfeafffff]
pci 0000:00:1c.4: bridge 64bit mmio pref: [0xfae00000-0xfaefffff]
pci 0000:02:00.0: reg 10 io port: [0xd800-0xd8ff]
pci 0000:02:00.0: reg 18 64bit mmio: [0xfe9ff000-0xfe9fffff]
pci 0000:02:00.0: reg 20 64bit mmio: [0xfadf0000-0xfadfffff]
pci 0000:02:00.0: reg 30 32bit mmio: [0xfe9c0000-0xfe9dffff]
pci 0000:02:00.0: supports D1 D2
pci 0000:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:02:00.0: PME# disabled
pci 0000:00:1c.5: bridge io port: [0xd000-0xdfff]
pci 0000:00:1c.5: bridge 32bit mmio: [0xfe900000-0xfe9fffff]
pci 0000:00:1c.5: bridge 64bit mmio pref: [0xfad00000-0xfadfffff]
pci 0000:00:1e.0: transparent bridge
pci 0000:00:1f.0: PIIX/ICH IRQ router [8086:3a16]
pci 0000:00:01.0: PCI->APIC IRQ transform: INT A -> IRQ 16
pci 0000:00:1a.0: PCI->APIC IRQ transform: INT A -> IRQ 16
pci 0000:00:1a.1: PCI->APIC IRQ transform: INT B -> IRQ 21
pci 0000:00:1a.2: PCI->APIC IRQ transform: INT D -> IRQ 19
pci 0000:00:1a.7: PCI->APIC IRQ transform: INT C -> IRQ 18
pci 0000:00:1c.0: PCI->APIC IRQ transform: INT A -> IRQ 17
pci 0000:00:1c.4: PCI->APIC IRQ transform: INT A -> IRQ 17
pci 0000:00:1c.5: PCI->APIC IRQ transform: INT B -> IRQ 18
pci 0000:00:1d.0: PCI->APIC IRQ transform: INT A -> IRQ 23
pci 0000:00:1d.1: PCI->APIC IRQ transform: INT B -> IRQ 20
pci 0000:00:1d.2: PCI->APIC IRQ transform: INT C -> IRQ 18
pci 0000:00:1d.7: PCI->APIC IRQ transform: INT A -> IRQ 23
pci 0000:00:1f.2: PCI->APIC IRQ transform: INT B -> IRQ 19
pci 0000:00:1f.3: PCI->APIC IRQ transform: INT C -> IRQ 18
pci 0000:01:00.0: PCI->APIC IRQ transform: INT A -> IRQ 16
pci 0000:04:00.1: PCI->APIC IRQ transform: INT A -> IRQ 16
pci 0000:03:00.0: PCI->APIC IRQ transform: INT A -> IRQ 16
pci 0000:02:00.0: PCI->APIC IRQ transform: INT A -> IRQ 17
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: disabled
pci 0000:00:01.0:   MEM window: 0xfc000000-0xfe8fffff
pci 0000:00:01.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff
pci 0000:04:00.0: PCI bridge, secondary bus 0000:06
pci 0000:04:00.0:   IO window: disabled
pci 0000:04:00.0:   MEM window: disabled
pci 0000:04:00.0:   PREFETCH window: disabled
pci 0000:04:00.1: PCI bridge, secondary bus 0000:05
pci 0000:04:00.1:   IO window: disabled
pci 0000:04:00.1:   MEM window: disabled
pci 0000:04:00.1:   PREFETCH window: 0x000000faf00000-0x000000faffffff
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:04
pci 0000:00:1c.0:   IO window: disabled
pci 0000:00:1c.0:   MEM window: 0xfeb00000-0xfebfffff
pci 0000:00:1c.0:   PREFETCH window: 0x000000faf00000-0x000000faffffff
pci 0000:00:1c.4: PCI bridge, secondary bus 0000:03
pci 0000:00:1c.4:   IO window: 0xe000-0xefff
pci 0000:00:1c.4:   MEM window: 0xfea00000-0xfeafffff
pci 0000:00:1c.4:   PREFETCH window: 0x000000fae00000-0x000000faefffff
pci 0000:00:1c.5: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.5:   IO window: 0xd000-0xdfff
pci 0000:00:1c.5:   MEM window: 0xfe900000-0xfe9fffff
pci 0000:00:1c.5:   PREFETCH window: 0x000000fad00000-0x000000fadfffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:07
pci 0000:00:1e.0:   IO window: disabled
pci 0000:00:1e.0:   MEM window: disabled
pci 0000:00:1e.0:   PREFETCH window: disabled
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:04:00.0: setting latency timer to 64
pci 0000:04:00.1: setting latency timer to 64
pci 0000:00:1c.4: setting latency timer to 64
pci 0000:00:1c.5: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
bus: 00 index 0 io port: [0x00-0xffff]
bus: 00 index 1 mmio: [0x000000-0xffffffffffffffff]
bus: 01 index 0 mmio: [0x0-0x0]
bus: 01 index 1 mmio: [0xfc000000-0xfe8fffff]
bus: 01 index 2 mmio: [0xd0000000-0xdfffffff]
bus: 01 index 3 mmio: [0x0-0x0]
bus: 04 index 0 mmio: [0x0-0x0]
bus: 04 index 1 mmio: [0xfeb00000-0xfebfffff]
bus: 04 index 2 mmio: [0xfaf00000-0xfaffffff]
bus: 04 index 3 mmio: [0x0-0x0]
bus: 06 index 0 mmio: [0x0-0x0]
bus: 06 index 1 mmio: [0x0-0x0]
bus: 06 index 2 mmio: [0x0-0x0]
bus: 06 index 3 mmio: [0x0-0x0]
bus: 05 index 0 mmio: [0x0-0x0]
bus: 05 index 1 mmio: [0x0-0x0]
bus: 05 index 2 mmio: [0xfaf00000-0xfaffffff]
bus: 05 index 3 mmio: [0x0-0x0]
bus: 03 index 0 io port: [0xe000-0xefff]
bus: 03 index 1 mmio: [0xfea00000-0xfeafffff]
bus: 03 index 2 mmio: [0xfae00000-0xfaefffff]
bus: 03 index 3 mmio: [0x0-0x0]
bus: 02 index 0 io port: [0xd000-0xdfff]
bus: 02 index 1 mmio: [0xfe900000-0xfe9fffff]
bus: 02 index 2 mmio: [0xfad00000-0xfadfffff]
bus: 02 index 3 mmio: [0x0-0x0]
bus: 07 index 0 mmio: [0x0-0x0]
bus: 07 index 1 mmio: [0x0-0x0]
bus: 07 index 2 mmio: [0x0-0x0]
bus: 07 index 3 io port: [0x00-0xffff]
bus: 07 index 4 mmio: [0x000000-0xffffffffffffffff]
NET: Registered protocol family 2
IP route cache hash table entries: 262144 (order: 9, 2097152 bytes)
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 262144 bind 65536)
TCP reno registered
NET: Registered protocol family 1
checking if image is initramfs... it is
Freeing initrd memory: 2162k freed
platform rtc_cmos: registered platform RTC device (no PNP device found)
Microcode Update Driver: v2.00 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
audit: initializing netlink socket (disabled)
type=2000 audit(1232700257.498:1): initialized
HugeTLB registered 2 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
SGI XFS with security attributes, large block/inode numbers, no debug
enabled
msgmni has been set to 15968
alg: No test for stdrng (krng)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
pcieport-driver 0000:00:01.0: setting latency timer to 64
pcieport-driver 0000:00:01.0: found MSI capability
pcieport-driver 0000:00:01.0: irq 767 for MSI/MSI-X
pci_express 0000:00:01.0:pcie00: allocate port service
pcieport-driver 0000:00:1c.0: setting latency timer to 64
pcieport-driver 0000:00:1c.0: found MSI capability
pcieport-driver 0000:00:1c.0: irq 766 for MSI/MSI-X
pci_express 0000:00:1c.0:pcie00: allocate port service
pci_express 0000:00:1c.0:pcie02: allocate port service
pcieport-driver 0000:00:1c.4: setting latency timer to 64
pcieport-driver 0000:00:1c.4: found MSI capability
pcieport-driver 0000:00:1c.4: irq 765 for MSI/MSI-X
pci_express 0000:00:1c.4:pcie00: allocate port service
pci_express 0000:00:1c.4:pcie02: allocate port service
pcieport-driver 0000:00:1c.5: setting latency timer to 64
pcieport-driver 0000:00:1c.5: found MSI capability
pcieport-driver 0000:00:1c.5: irq 764 for MSI/MSI-X
pci_express 0000:00:1c.5:pcie00: allocate port service
pci_express 0000:00:1c.5:pcie02: allocate port service
Non-volatile memory driver v1.2
Linux agpgart interface v0.103
Serial: 8250/16550 driver4 ports, IRQ sharing enabled
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
brd: module loaded
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:00.0: setting latency timer to 64
r8169 0000:03:00.0: irq 763 for MSI/MSI-X
eth0: RTL8168c/8111c at 0xffffc20000010000, 00:22:15:fb:a0:98, XID 3c4000c0
IRQ 763
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: setting latency timer to 64
r8169 0000:02:00.0: irq 762 for MSI/MSI-X
eth1: RTL8168c/8111c at 0xffffc20000014000, 00:22:15:fb:a2:42, XID 3c4000c0
IRQ 762
Uniform Multi-Platform E-IDE driver
Driver 'sd' needs updating - please use bus_type methods
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: irq 761 for MSI/MSI-X
ahci 0000:00:1f.2: AHCI 0001.0200 32 slots 6 ports 3 Gbps 0x3f impl SATA
mode
ahci 0000:00:1f.2: flags: 64bit ncq sntf stag pm led clo pmp pio slum part
ems 
ahci 0000:00:1f.2: setting latency timer to 64
scsi0 : ahci
scsi1 : ahci
scsi2 : ahci
scsi3 : ahci
scsi4 : ahci
scsi5 : ahci
ata1: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffe900 irq 761
ata2: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffe980 irq 761
ata3: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffea00 irq 761
ata4: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffea80 irq 761
ata5: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffeb00 irq 761
ata6: SATA max UDMA/133 abar m2048@0xfbffe800 port 0xfbffeb80 irq 761
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata1.00: ATA-8: ST3500320AS, SD1A, max UDMA/133
ata1.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 31/32)
ata1.00: configured for UDMA/133
ata2: SATA link down (SStatus 0 SControl 300)
ata3: SATA link down (SStatus 0 SControl 300)
ata4: SATA link down (SStatus 0 SControl 300)
ata5: SATA link down (SStatus 0 SControl 300)
ata6: SATA link down (SStatus 0 SControl 300)
scsi 0:0:0:0: Direct-Access     ATA      ST3500320AS      SD1A PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support
DPO or FUA
sd 0:0:0:0: [sda] 976773168 512-byte hardware sectors: (500 GB/465 GiB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support
DPO or FUA
 sda: sda1 sda2 sda3
sd 0:0:0:0: [sda] Attached SCSI disk
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX port at 0x60,0x64 irq 12
mice: PS/2 mouse device common for all mice
rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
rtc0: alarms up to one day, 114 bytes nvram
IPVS: Registered protocols (TCP, UDP, AH, ESP)
IPVS: Connection hash table configured (size=131072, memory=2048Kbytes)
IPVS: Each connection entry needs 232 bytes at least
IPVS: ipvs loaded.
IPVS: [rr] scheduler registered.
IPVS: [wrr] scheduler registered.
IPVS: [lc] scheduler registered.
IPVS: [wlc] scheduler registered.
IPVS: [lblc] scheduler registered.
IPVS: [lblcr] scheduler registered.
IPVS: [dh] scheduler registered.
IPVS: [sh] scheduler registered.
IPVS: [sed] scheduler registered.
IPVS: [nq] scheduler registered.
IPVS: ftp: loaded support on port[0] = 21
IPv4 over IPv4 tunneling driver
ip_tables: (C) 2000-2006 Netfilter Core Team
TCP cubic registered
NET: Registered protocol family 17
rtc_cmos rtc_cmos: setting system clock to 2009-01-23 08:44:20 UTC
(1232700260)
Freeing unused kernel memory: 340k freed
Write protecting the kernel read-only data: 4204k
input: AT Translated Set 2 keyboard as /class/input/input0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
input: PC Speaker as /class/input/input1
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.14.0-ioctl (2008-04-23) initialised:
dm-devel@redhat.com
device-mapper: multipath: version 1.0.5 loaded
EXT3 FS on sda3, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 8385920k swap on /dev/sda2.  Priority:-1 extents:1 across:8385920k
r8169: eth0: link up
r8169: eth0: link up
r8169: eth1: link up
r8169: eth1: link up
warning: `dbus-daemon' uses 32-bit capabilities (legacy support in use)
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
device eth0 entered promiscuous mode
device eth0 left promiscuous mode
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x206/0x220()
NETDEV WATCHDOG: eth0 (r8169): transmit timed out
Modules linked in: dm_mirror dm_region_hash dm_log dm_multipath dm_mod
serio_raw pcspkr
Pid: 0, comm: swapper Not tainted 2.6.28.1 #6
Call Trace:
 <IRQ>  [<ffffffff8023633c>] warn_slowpath+0x10c/0x150
 [<ffffffff8026e659>] cpupri_set+0xa9/0xe0
 [<ffffffff8024ab39>] autoremove_wake_function+0x9/0x30
 [<ffffffff8022c367>] source_load+0x37/0x70
 [<ffffffff803cfb5a>] __next_cpu+0x1a/0x30
 [<ffffffff8022daec>] find_busiest_group+0x18c/0x820
 [<ffffffff803d52fe>] strlcpy+0x4e/0x80
 [<ffffffff804b78b6>] dev_watchdog+0x206/0x220
 [<ffffffff802122d9>] read_tsc+0x9/0x20
 [<ffffffff80250368>] getnstimeofday+0x48/0xe0
 [<ffffffff8024d5e8>] run_hrtimer_pending+0x18/0x120
 [<ffffffff804b76b0>] dev_watchdog+0x0/0x220
 [<ffffffff8023fbff>] run_timer_softirq+0x15f/0x1c0
 [<ffffffff8023b52c>] __do_softirq+0x9c/0x170
 [<ffffffff8020c87c>] call_softirq+0x1c/0x30
 [<ffffffff8020e135>] do_softirq+0x35/0x70
 [<ffffffff8021c205>] smp_apic_timer_interrupt+0x85/0xd0
 [<ffffffff8020c2cb>] apic_timer_interrupt+0x6b/0x70
 <EOI>  [<ffffffff802130c1>] mwait_idle+0x41/0x50
 [<ffffffff8020a2da>] cpu_idle+0x3a/0x70
---[ end trace 9b1a7551bf7a6a56 ]---
r8169: eth0: link up
r8169: eth0: link up
You have new mail in /var/spool/mail/root


03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B
PCI Express Gigabit Ethernet controller (rev 02)
        Subsystem: ASUSTeK Computer Inc. Unknown device 82c6
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 763
        Region 0: I/O ports at e800 [size=256]
        Region 2: Memory at feaff000 (64-bit, non-prefetchable) [size=4K]
        Region 4: Memory at faef0000 (64-bit, prefetchable) [size=64K]
        Expansion ROM at feac0000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: 64bit+ Queue=0/0
Enable+
                Address: 00000000fee0800c  Data: 41a1
        Capabilities: [70] Express Endpoint IRQ 1
                Device: Supported: MaxPayload 256 bytes, PhantFunc 0,
ExtTag-
                Device: Latency L0s <512ns, L1 <8us
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
                Link: Latency L0s <512ns, L1 <64us
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data

-----Original Message-----
From: linux-kernel-owner@vger.kernel.org
[mailto:linux-kernel-owner@vger.kernel.org] On Behalf Of Francois Romieu
Sent: Thursday, January 15, 2009 1:21 PM
To: Justin Piszcz
Cc: Andrew Morton; linux-kernel@vger.kernel.org; Alan Piszcz;
netdev@vger.kernel.org
Subject: Re: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed
out

Justin Piszcz <jpiszcz@lucidpixels.com> :
[...]
> It is the first time I have ever seen it on this system, while running  
> 2.6.28.  I have never seen the error in the past (at least not that I can 
> remember/no log entries) for 2.6.27 or below.

Does it translate into a temporary network hiccup, say a few seconds,
or does it mean a final loss of networking ?

Given the timestamp, the driver seemed to worked for some amount of time
before breaking, did it not ? It would thus be different from the usual
"no link at startup" problem.

Can you send a complete dmesg, including the r8169 XID line ?

-- 
Ueimor
