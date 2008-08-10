From: "Dushan Tcholich" <dusanc@gmail.com>
Subject: Re: ksoftirqd high cpu load on kernels 2.6.24 to 2.6.27-rc1-mm1
Date: Sun, 10 Aug 2008 21:00:23 +0200
Message-ID: <a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	 <48975BD3.6040709@shaw.ca>
	 <a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	 <20080807185802.GA16327@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.239]:49274 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbYHJTAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2008 15:00:23 -0400
Received: by rv-out-0506.google.com with SMTP id k40so1910750rvb.1
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 12:00:23 -0700 (PDT)
In-Reply-To: <20080807185802.GA16327@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
Sorry for answering this late, but I was short on time and couldn't
get reiser4 to work with 2.6.27-rc2

On Thu, Aug 7, 2008 at 8:58 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Dushan Tcholich <dusanc@gmail.com> :
> [...]
>> I googled a little and found out that oprofile is a little above my head.
>> So as I thought that some driver or HW might be responsible for this I
>> tried to disable various onboard HW and found out that if I disable
>> onboard ethernet problem dissapears, so now I've added netdev and
>> maintainer of R8169 driver to cc.
>
> Can you try 2.6.27-rc2 and send the content of /proc/interrupts, dmesg,
> ifconfig as well as a capture of the strange output from top ?
>
I've copied my root to ext3 partition and with vanilla 2.6.27-rc2 I got:
-With my .config problem is still here
-With only rtl8169 removed from config there is no problem

> It seems rather benign though.
>
Well I wouldn't agree from power managment standpoint :). This nic is
in a lot of laptops.
8% of 2.13GHz Core2Duo CPU is a lot :)

Btw. should LKML be removed from cc?
If you need any more help please ask.
I hope I'm not harrasing you too much :)
> --
> Ueimor
>
Have a nice day
Dushan

Requested data:

top output:

top - 20:50:27 up 8 min,  3 users,  load average: 0.74, 0.45, 0.20
Tasks: 114 total,   1 running, 113 sleeping,   0 stopped,   0 zombie
Cpu(s):  2.8%us,  3.0%sy,  0.0%ni, 93.7%id,  0.0%wa,  0.2%hi,  0.3%si,  0.0%st
Mem:   1033720k total,   287288k used,   746432k free,     9860k buffers
Swap:   610460k total,        0k used,   610460k free,   129228k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
    7 root      15  -5     0    0    0 S    8  0.0   0:37.75 ksoftirqd/1

Note the 8min uptime and ksoftirqd is already on 37min

cat /proc/interrupts
           CPU0       CPU1
  0:        126          0   IO-APIC-edge      timer
  1:       1042          0   IO-APIC-edge      i8042
  4:       1676          0   IO-APIC-edge      serial
  9:          0          0   IO-APIC-fasteoi   acpi
 16:      46224          0   IO-APIC-fasteoi   uhci_hcd:usb3,
radeon@pci:0000:01:00.0
 18:         21          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb7
 19:      15440          0   IO-APIC-fasteoi   ata_piix, ata_piix, uhci_hcd:usb6
 21:       1269          0   IO-APIC-fasteoi   uhci_hcd:usb4, eth0
 22:        202          0   IO-APIC-fasteoi   HDA Intel
 23:         61          0   IO-APIC-fasteoi   ehci_hcd:usb2, uhci_hcd:usb5
NMI:          0          0   Non-maskable interrupts
LOC:     177598     165568   Local timer interrupts
RES:       1224       1729   Rescheduling interrupts
CAL:       1247       1548   function call interrupts
TLB:       1577       1848   TLB shootdowns
TRM:          0          0   Thermal event interrupts
SPU:          0          0   Spurious interrupts
ERR:          0
MIS:          0

ifconfig
br0       Link encap:Ethernet  HWaddr 00:16:17:92:D7:4C
          inet addr:192.168.1.3  Bcast:192.168.1.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:663 errors:0 dropped:0 overruns:0 frame:0
          TX packets:703 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:216555 (211.4 Kb)  TX bytes:251971 (246.0 Kb)

eth0      Link encap:Ethernet  HWaddr 00:16:17:92:D7:4C
          UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
          RX packets:663 errors:0 dropped:0 overruns:0 frame:0
          TX packets:703 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:225837 (220.5 Kb)  TX bytes:253009 (247.0 Kb)
          Interrupt:21 Base address:0xc000

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:407 errors:0 dropped:0 overruns:0 frame:0
          TX packets:407 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:28589 (27.9 Kb)  TX bytes:28589 (27.9 Kb)


dmesg
Linux version 2.6.27-rc2 (root@krshina3) (gcc version 4.1.2 (Gentoo
4.1.2 p1.0.2)) #1 SMP Sun Aug 10 20:36:47 CEST 2008
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f000 (usable)
 BIOS-e820: 000000000009f000 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003fedf800 (usable)
 BIOS-e820: 000000003fedf800 - 000000003fee0000 (reserved)
 BIOS-e820: 000000003fee0000 - 000000003fee3000 (ACPI NVS)
 BIOS-e820: 000000003fee3000 - 000000003fef0000 (ACPI data)
 BIOS-e820: 000000003fef0000 - 000000003ff00000 (reserved)
 BIOS-e820: 00000000e0000000 - 00000000f0000000 (reserved)
 BIOS-e820: 00000000fec00000 - 0000000100000000 (reserved)
last_pfn = 0x3fedf max_arch_pfn = 0x100000
kernel direct mapping tables up to 38000000 @ 7000-c000
DMI 2.2 present.
ACPI: RSDP 000F91A0, 0014 (r0 IntelR)
ACPI: RSDT 3FEE3040, 0038 (r1 IntelR AWRDACPI 42302E31 AWRD        0)
ACPI: FACP 3FEE30C0, 0074 (r1 IntelR AWRDACPI 42302E31 AWRD        0)
ACPI: DSDT 3FEE3180, 4744 (r1 INTELR AWRDACPI     1000 MSFT  100000E)
ACPI: FACS 3FEE0000, 0040
ACPI: MCFG 3FEE7A40, 003C (r1 IntelR AWRDACPI 42302E31 AWRD        0)
ACPI: APIC 3FEE7940, 0084 (r1 IntelR AWRDACPI 42302E31 AWRD        0)
ACPI: SSDT 3FEE7AC0, 015C (r1  PmRef  Cpu0Ist     3000 INTL 20041203)
ACPI: SSDT 3FEE7F50, 02F1 (r1  PmRef    CpuPm     3000 INTL 20040311)
126MB HIGHMEM available.
896MB LOWMEM available.
  mapped low ram: 0 - 38000000
  low ram: 00000000 - 38000000
  bootmap 00008000 - 0000f000
(8 early reservations) ==> bootmem [0000000000 - 0038000000]
  #0 [0000000000 - 0000001000]   BIOS data page ==> [0000000000 - 0000001000]
  #1 [0000001000 - 0000002000]    EX TRAMPOLINE ==> [0000001000 - 0000002000]
  #2 [0000006000 - 0000007000]       TRAMPOLINE ==> [0000006000 - 0000007000]
  #3 [0000100000 - 0000545000]    TEXT DATA BSS ==> [0000100000 - 0000545000]
  #4 [0000545000 - 0000548000]    INIT_PG_TABLE ==> [0000545000 - 0000548000]
  #5 [000009f000 - 0000100000]    BIOS reserved ==> [000009f000 - 0000100000]
  #6 [0000007000 - 0000008000]          PGTABLE ==> [0000007000 - 0000008000]
  #7 [0000008000 - 000000f000]          BOOTMAP ==> [0000008000 - 000000f000]
Scan SMP from c0000000 for 1024 bytes.
Scan SMP from c009fc00 for 1024 bytes.
Scan SMP from c00f0000 for 65536 bytes.
found SMP MP-table at [c00f51d0] 000f51d0
Zone PFN ranges:
  DMA      0x00000000 -> 0x00001000
  Normal   0x00001000 -> 0x00038000
  HighMem  0x00038000 -> 0x0003fedf
Movable zone start PFN for each node
early_node_map[2] active PFN ranges
    0: 0x00000000 -> 0x0000009f
    0: 0x00000100 -> 0x0003fedf
On node 0 totalpages: 261758
free_area_init_node: node 0, pgdat c0474b40, node_mem_map c1000000
  DMA zone: 3967 pages, LIFO batch:0
  Normal zone: 223520 pages, LIFO batch:31
  HighMem zone: 32225 pages, LIFO batch:7
Using APIC driver default
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x02] disabled)
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x03] disabled)
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x04] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 4, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Using ACPI (MADT) for SMP configuration information
mapped APIC to ffffb000 (fee00000)
mapped IOAPIC to ffffa000 (fec00000)
Allocating PCI resources starting at 40000000 (gap: 3ff00000:a0100000)
PERCPU: Allocating 28276 bytes of per cpu data
NR_CPUS: 2, nr_cpu_ids: 2, nr_node_ids 1
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 259712
Kernel command line: root=/dev/sdb1
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Initializing CPU#0
CPU 0 irqstacks, hard=c050f000 soft=c050d000
PID hash table entries: 4096 (order: 12, 16384 bytes)
TSC calibrated against PM_TIMER
Detected 2129.703 MHz processor.
Console: colour VGA+ 80x25
console [tty0] enabled
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 1033120k/1047420k available (2594k kernel code, 13580k
reserved, 1265k data, 256k init, 129916k highmem)
virtual kernel memory layout:
    fixmap  : 0xfff9e000 - 0xfffff000   ( 388 kB)
    pkmap   : 0xff800000 - 0xffc00000   (4096 kB)
    vmalloc : 0xf8800000 - 0xff7fe000   ( 111 MB)
    lowmem  : 0xc0000000 - 0xf8000000   ( 896 MB)
      .init : 0xc04ca000 - 0xc050a000   ( 256 kB)
      .data : 0xc0388835 - 0xc04c4da0   (1265 kB)
      .text : 0xc0100000 - 0xc0388835   (2594 kB)
Checking if this processor honours the WP bit even in supervisor mode...Ok.
CPA: page pool initialized 1 of 1 pages preallocated
Calibrating delay loop (skipped), value calculated using timer
frequency.. 4259.40 BogoMIPS (lpj=2129703)
Mount-cache hash table entries: 512
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
using mwait in idle threads.
Checking 'hlt' instruction... OK.
Freeing SMP alternatives: 14k freed
ACPI: Core revision 20080609
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
CPU0: Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz stepping 06
CPU 1 irqstacks, hard=c0510000 soft=c050e000
Booting processor 1/1 ip 6000
Initializing CPU#1
Calibrating delay using timer specific routine.. 4258.63 BogoMIPS (lpj=2129315)
CPU: L1 I cache: 32K, L1 D cache: 32K
CPU: L2 cache: 2048K
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 1
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz stepping 06
checking TSC synchronization [CPU#0 -> CPU#1]: passed.
Brought up 2 CPUs
Total of 2 processors activated (8518.03 BogoMIPS).
CPU0 attaching sched-domain:
 domain 0: span 0-1 level MC
  groups: 0 1
CPU1 attaching sched-domain:
 domain 0: span 0-1 level MC
  groups: 1 0
net_namespace: 296 bytes
NET: Registered protocol family 16
No dock devices found.
ACPI: bus type pci registered
PCI: MCFG configuration 0: base e0000000 segment 0 buses 0 - 255
PCI: MCFG area at e0000000 reserved in E820
PCI: Using MMCONFIG for extended config space
PCI: Using configuration type 1 for base access
ACPI: EC: Look up EC in DSDT
ACPI: Interpreter enabled
ACPI: (supports S0 S5)
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Root Bridge [PCI0] (0000:00)
pci 0000:00:01.0: PME# supported from D0 D3hot D3cold
pci 0000:00:01.0: PME# disabled
pci 0000:00:1a.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.7: PME# disabled
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: PME# disabled
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: PME# disabled
pci 0000:00:1d.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.7: PME# disabled
pci 0000:00:1f.0: quirk: region 0400-047f claimed by ICH6 ACPI/GPIO/TCO
pci 0000:00:1f.0: quirk: region 0480-04bf claimed by ICH6 GPIO
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.2: PME# disabled
pci 0000:00:1f.5: PME# supported from D3hot
pci 0000:00:1f.5: PME# disabled
pci 0000:01:00.0: supports D1
pci 0000:01:00.0: supports D2
pci 0000:01:00.1: supports D1
pci 0000:01:00.1: supports D2
pci 0000:03:06.0: supports D1
pci 0000:03:06.0: supports D2
pci 0000:03:06.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:03:06.0: PME# disabled
pci 0000:00:1e.0: transparent bridge
bus 00 -> node 0
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.PEX0._PRT]
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0.HUB0._PRT]
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 7 9 *10 11 14 15)
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 7 *9 10 11 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs *3 4 5 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 7 9 10 *11 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 7 9 10 11 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 *5 7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 *7 9 10 11 14 15)
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 7 9 10 11 14 15) *0, disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
pnp: PnP ACPI init
ACPI: bus type pnp registered
pnp: PnP ACPI: found 13 devices
ACPI: ACPI bus type pnp unregistered
SCSI subsystem initialized
libata version 3.00 loaded.
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
system 00:01: ioport range 0x4d0-0x4d1 has been reserved
system 00:01: ioport range 0xa00-0xa7f has been reserved
system 00:01: ioport range 0x880-0x88f has been reserved
system 00:09: ioport range 0x400-0x4bf could not be reserved
system 00:0b: iomem range 0xe0000000-0xefffffff could not be reserved
system 00:0c: iomem range 0xf0000-0xf3fff could not be reserved
system 00:0c: iomem range 0xf4000-0xf7fff could not be reserved
system 00:0c: iomem range 0xf8000-0xfbfff could not be reserved
system 00:0c: iomem range 0xfc000-0xfffff could not be reserved
system 00:0c: iomem range 0x3fee0000-0x3fefffff could not be reserved
system 00:0c: iomem range 0x0-0x9ffff could not be reserved
system 00:0c: iomem range 0x100000-0x3fedffff could not be reserved
system 00:0c: iomem range 0xfec00000-0xfec00fff could not be reserved
system 00:0c: iomem range 0xfed14000-0xfed1dfff could not be reserved
system 00:0c: iomem range 0xfdffc000-0xfdffcbff has been reserved
system 00:0c: iomem range 0xfed20000-0xfed9ffff could not be reserved
system 00:0c: iomem range 0xfee00000-0xfee00fff could not be reserved
system 00:0c: iomem range 0xffb00000-0xffb7ffff could not be reserved
system 00:0c: iomem range 0xfff00000-0xffffffff could not be reserved
system 00:0c: iomem range 0xe0000-0xeffff has been reserved
pci 0000:00:01.0: PCI bridge, secondary bus 0000:01
pci 0000:00:01.0:   IO window: 0xd000-0xdfff
pci 0000:00:01.0:   MEM window: 0xfde00000-0xfdefffff
pci 0000:00:01.0:   PREFETCH window: 0x000000d0000000-0x000000dfffffff
pci 0000:00:1c.0: PCI bridge, secondary bus 0000:02
pci 0000:00:1c.0:   IO window: 0xb000-0xbfff
pci 0000:00:1c.0:   MEM window: 0xfdb00000-0xfdbfffff
pci 0000:00:1c.0:   PREFETCH window: 0x000000fda00000-0x000000fdafffff
pci 0000:00:1e.0: PCI bridge, secondary bus 0000:03
pci 0000:00:1e.0:   IO window: 0xc000-0xcfff
pci 0000:00:1e.0:   MEM window: 0xfdd00000-0xfddfffff
pci 0000:00:1e.0:   PREFETCH window: 0x000000fdc00000-0x000000fdcfffff
pci 0000:00:01.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:01.0: setting latency timer to 64
pci 0000:00:1c.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:00:1c.0: setting latency timer to 64
pci 0000:00:1e.0: setting latency timer to 64
NET: Registered protocol family 2
IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 131072 bind 65536)
TCP reno registered
NET: Registered protocol family 1
highmem bounce pool size: 64 pages
Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
NTFS driver 2.1.29 [Flags: R/W].
msgmni has been set to 1764
io scheduler noop registered
io scheduler cfq registered (default)
pci 0000:01:00.0: Boot video device
pcieport-driver 0000:00:01.0: setting latency timer to 64
pcieport-driver 0000:00:01.0: found MSI capability
pci_express 0000:00:01.0:pcie00: allocate port service
pci_express 0000:00:01.0:pcie03: allocate port service
pcieport-driver 0000:00:1c.0: setting latency timer to 64
pcieport-driver 0000:00:1c.0: found MSI capability
pci_express 0000:00:1c.0:pcie00: allocate port service
pci_express 0000:00:1c.0:pcie02: allocate port service
pci_express 0000:00:1c.0:pcie03: allocate port service
input: Power Button (FF) as /class/input/input0
ACPI: Power Button (FF) [PWRF]
input: Power Button (CM) as /class/input/input1
ACPI: Power Button (CM) [PWRB]
fan PNP0C0B:00: registered as cooling_device0
ACPI: Fan [FAN] (on)
processor ACPI0007:00: registered as cooling_device1
ACPI: SSDT 3FEE7EC0, 0087 (r1  PmRef  Cpu1Ist     3000 INTL 20041203)
processor ACPI0007:01: registered as cooling_device2
thermal LNXTHERM:01: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (46 C)
Real Time Clock Driver v1.12ac
Linux agpgart interface v0.103
Hangcheck: starting hangcheck timer 0.9.0 (tick is 180 seconds, margin
is 60 seconds).
Hangcheck: Using get_cycles().
[drm] Initialized drm 1.1.0 20060810
pci 0000:01:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
pci 0000:01:00.0: setting latency timer to 64
[drm] Initialized radeon 1.29.0 20080528 on minor 0
Serial: 8250/16550 driver4 ports, IRQ sharing disabled
serial8250: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
00:07: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
brd: module loaded
loop: module loaded
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:03:06.0: PCI INT A -> GSI 21 (level, low) -> IRQ 21
eth0: RTL8169sc/8110sc at 0xf881c000, 00:16:17:92:d7:4c, XID 18000000 IRQ 21
Driver 'sd' needs updating - please use bus_type methods
Driver 'sr' needs updating - please use bus_type methods
ata_piix 0000:00:1f.2: version 2.12
ata_piix 0000:00:1f.2: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.2: MAP [ P0 P2 P1 P3 ]
ata_piix 0000:00:1f.2: setting latency timer to 64
scsi0 : ata_piix
scsi1 : ata_piix
ata1: SATA max UDMA/133 cmd 0xfa00 ctl 0xf900 bmdma 0xf600 irq 19
ata2: SATA max UDMA/133 cmd 0xf800 ctl 0xf700 bmdma 0xf608 irq 19
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 0
ata1: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.00: ATA-7: WDC WD740ADFD-00NLR1, 20.07P20, max UDMA/133
ata1.00: 145226112 sectors, multi 16: LBA48 NCQ (not used)
ata1.00: configured for UDMA/133
ata2: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
ata2.00: ATA-8: WDC WD5000AAKS-00A7B0, 01.03B01, max UDMA/133
ata2.00: 976773168 sectors, multi 16: LBA48 NCQ (depth 0/32)
ata2.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      WDC WD740ADFD-00 20.0 PQ: 0 ANSI: 5
sd 0:0:0:0: [sda] 145226112 512-byte hardware sectors (74356 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 0:0:0:0: [sda] 145226112 512-byte hardware sectors (74356 MB)
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sda: sda1 sda2 sda3 sda4
sd 0:0:0:0: [sda] Attached SCSI disk
sd 0:0:0:0: Attached scsi generic sg0 type 0
scsi 1:0:0:0: Direct-Access     ATA      WDC WD5000AAKS-0 01.0 PQ: 0 ANSI: 5
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
sd 1:0:0:0: [sdb] 976773168 512-byte hardware sectors (500108 MB)
sd 1:0:0:0: [sdb] Write Protect is off
sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't
support DPO or FUA
 sdb: sdb1
sd 1:0:0:0: [sdb] Attached SCSI disk
sd 1:0:0:0: Attached scsi generic sg1 type 0
ata_piix 0000:00:1f.5: PCI INT B -> GSI 19 (level, low) -> IRQ 19
ata_piix 0000:00:1f.5: MAP [ P0 -- P1 -- ]
ata_piix 0000:00:1f.5: setting latency timer to 64
scsi2 : ata_piix
scsi3 : ata_piix
ata3: SATA max UDMA/133 cmd 0xf300 ctl 0xf200 bmdma 0xef00 irq 19
ata4: SATA max UDMA/133 cmd 0xf100 ctl 0xf000 bmdma 0xef08 irq 19
ata3: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata3.00: ATAPI: TSSTcorpCD/DVDW SH-W163A, TS01, max UDMA/33
ata3.00: applying bridge limits
ata3.00: configured for UDMA/33
ata4: SATA link down (SStatus 0 SControl 300)
scsi 2:0:0:0: CD-ROM            TSSTcorp CD/DVDW SH-W163A TS01 PQ: 0 ANSI: 5
sr0: scsi3-mmc drive: 24x/24x writer cd/rw xa/form2 cdda tray
Uniform CD-ROM driver Revision: 3.20
sr 2:0:0:0: Attached scsi CD-ROM sr0
sr 2:0:0:0: Attached scsi generic sg2 type 5
ehci_hcd 0000:00:1a.7: PCI INT C -> GSI 18 (level, low) -> IRQ 18
ehci_hcd 0000:00:1a.7: setting latency timer to 64
ehci_hcd 0000:00:1a.7: EHCI Host Controller
ehci_hcd 0000:00:1a.7: new USB bus registered, assigned bus number 1
ehci_hcd 0000:00:1a.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1a.7: irq 18, io mem 0xfdfff000
ehci_hcd 0000:00:1a.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb1: configuration #1 chosen from 1 choice
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 4 ports detected
ehci_hcd 0000:00:1d.7: PCI INT A -> GSI 23 (level, low) -> IRQ 23
ehci_hcd 0000:00:1d.7: setting latency timer to 64
ehci_hcd 0000:00:1d.7: EHCI Host Controller
ehci_hcd 0000:00:1d.7: new USB bus registered, assigned bus number 2
ehci_hcd 0000:00:1d.7: cache line size of 32 is not supported
ehci_hcd 0000:00:1d.7: irq 23, io mem 0xfdffe000
usb 1-2: new high speed USB device using ehci_hcd and address 2
ehci_hcd 0000:00:1d.7: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
usb usb2: configuration #1 chosen from 1 choice
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 6 ports detected
usb 1-2: configuration #1 chosen from 1 choice
ohci_hcd: 2006 August 04 USB 1.1 'Open' Host Controller (OHCI) Driver
USB Universal Host Controller Interface driver v3.0
uhci_hcd 0000:00:1a.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
uhci_hcd 0000:00:1a.0: setting latency timer to 64
uhci_hcd 0000:00:1a.0: UHCI Host Controller
uhci_hcd 0000:00:1a.0: new USB bus registered, assigned bus number 3
uhci_hcd 0000:00:1a.0: irq 16, io base 0x0000ff00
usb usb3: configuration #1 chosen from 1 choice
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 2 ports detected
uhci_hcd 0000:00:1a.1: PCI INT B -> GSI 21 (level, low) -> IRQ 21
uhci_hcd 0000:00:1a.1: setting latency timer to 64
uhci_hcd 0000:00:1a.1: UHCI Host Controller
uhci_hcd 0000:00:1a.1: new USB bus registered, assigned bus number 4
uhci_hcd 0000:00:1a.1: irq 21, io base 0x0000fe00
usb usb4: configuration #1 chosen from 1 choice
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 2 ports detected
usb 2-5: new high speed USB device using ehci_hcd and address 4
uhci_hcd 0000:00:1d.0: PCI INT A -> GSI 23 (level, low) -> IRQ 23
uhci_hcd 0000:00:1d.0: setting latency timer to 64
uhci_hcd 0000:00:1d.0: UHCI Host Controller
uhci_hcd 0000:00:1d.0: new USB bus registered, assigned bus number 5
uhci_hcd 0000:00:1d.0: irq 23, io base 0x0000fd00
usb usb5: configuration #1 chosen from 1 choice
hub 5-0:1.0: USB hub found
hub 5-0:1.0: 2 ports detected
usb 2-5: configuration #1 chosen from 1 choice
hub 2-5:1.0: USB hub found
hub 2-5:1.0: 4 ports detected
uhci_hcd 0000:00:1d.1: PCI INT B -> GSI 19 (level, low) -> IRQ 19
uhci_hcd 0000:00:1d.1: setting latency timer to 64
uhci_hcd 0000:00:1d.1: UHCI Host Controller
uhci_hcd 0000:00:1d.1: new USB bus registered, assigned bus number 6
uhci_hcd 0000:00:1d.1: irq 19, io base 0x0000fc00
usb usb6: configuration #1 chosen from 1 choice
hub 6-0:1.0: USB hub found
hub 6-0:1.0: 2 ports detected
usb 5-2: new low speed USB device using uhci_hcd and address 2
uhci_hcd 0000:00:1d.2: PCI INT C -> GSI 18 (level, low) -> IRQ 18
uhci_hcd 0000:00:1d.2: setting latency timer to 64
uhci_hcd 0000:00:1d.2: UHCI Host Controller
uhci_hcd 0000:00:1d.2: new USB bus registered, assigned bus number 7
uhci_hcd 0000:00:1d.2: irq 18, io base 0x0000fb00
usb usb7: configuration #1 chosen from 1 choice
hub 7-0:1.0: USB hub found
hub 7-0:1.0: 2 ports detected
usb 5-2: configuration #1 chosen from 1 choice
usb 6-1: new low speed USB device using uhci_hcd and address 2
Initializing USB Mass Storage driver...
usb 6-1: configuration #1 chosen from 1 choice
usbcore: registered new interface driver usb-storage
USB Mass Storage support registered.
PNP: PS/2 Controller [PNP0303:PS2K] at 0x60,0x64 irq 1
PNP: PS/2 appears to have AUX port disabled, if this is incorrect
please boot with i8042.nopnp
serio: i8042 KBD port at 0x60,0x64 irq 1
mice: PS/2 mouse device common for all mice
coretemp coretemp.0: Using relative temperature scale!
coretemp coretemp.1: Using relative temperature scale!
input: AT Translated Set 2 keyboard as /class/input/input2
input: 5-Axis,12-Button with POV  as /class/input/input3
input: USB HID v1.10 Joystick [5-Axis,12-Button with POV ] on usb-0000:00:1d.0-2
input: Logitech USB-PS/2 Optical Mouse as /class/input/input4
input: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on
usb-0000:00:1d.1-1
usbcore: registered new interface driver usbhid
usbhid: v2.6:USB HID core driver
Advanced Linux Sound Architecture Driver Version 1.0.17.
HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
HDA Intel 0000:00:1b.0: setting latency timer to 64
hda_codec: Unknown model for ALC883, trying auto-probe from BIOS...
ALSA device list:
  #0: HDA Intel at 0xfdff8000 irq 22
TCP cubic registered
NET: Registered protocol family 17
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
Starting balanced_irq
Using IPI Shortcut mode
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 256k freed
EXT3 FS on sdb1, internal journal
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda4, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 610460k swap on /dev/sda3.  Priority:-1 extents:1 across:610460k
r8169: eth0: link up
br0: Dropping NETIF_F_UFO since no NETIF_F_HW_CSUM feature.
device eth0 entered promiscuous mode
br0: topology change detected, propagating
br0: port 1(eth0) entering forwarding state
[drm] Setting GART location based on new memory map
[drm] Loading R400 Microcode
[drm] Num pipes: 4
[drm] writeback test succeeded in 1 usecs
warning: `ntpd' uses 32-bit capabilities (legacy support in use)
[drm] Num pipes: 4
[drm] Loading R400 Microcode
[drm] Num pipes: 4
ISO 9660 Extensions: Microsoft Joliet Level 3
ISO 9660 Extensions: RRIP_1991A
[drm] Num pipes: 4
[drm] Loading R400 Microcode
[drm] Num pipes: 4
