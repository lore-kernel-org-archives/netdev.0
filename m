From: Mark Price <elm@jimini.org>
Subject: sk98lin 2.6 bug
Date: Sun, 14 Mar 2004 18:30:56 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4054A4E0.3050306@jimini.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I seem to have found some incorrect behavior in the sk98lin driver.
The documentation claims that the driver will support  up to 16 devices, 
and yet it is only finding one of my two cards.  The problem is not 
apparently broken network cards, because one card is found if the driver 
is built in and the other is found if the driver is modularized.
Interestingly, only one of them shows up in /proc/pci at a time, 
depending on the kernel.

Here is some diagnostic info.  If I can supply more, or test some 
patches, I would be happy to.  systool is on the system, but what to do 
with it I don't yet know.

I am running 2.6.3 from debian's kernel-image-2.6.3-1-686-smp for the 
module and  debian's kernel-source-2.6.3-2 with the driver built in.  

Here is the hardware version from dmesg:
   eth0: SK-9521 10/100/1000Base-T Adapter,
   in other words SysKonnect and NOT Yukon.
# lspci -v:
00:01.0 PCI bridge: Intel Corp. 440GX - 82443GX AGP bridge (prog-if 00 
[Normal decode])
        Flags: bus master, 66Mhz, medium devsel, latency 32
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
        I/O behind bridge: 0000f000-0000ffff
        Memory behind bridge: fb000000-fdffffff
        Prefetchable memory behind bridge: f6000000-f6ffffff
 
00:02.0 PCI bridge: Digital Equipment Corporation DECchip 21152 (rev 03) 
(prog-if 00 [Normal decode])
        Flags: bus master, medium devsel, latency 32
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: f9000000-faffffff
        Prefetchable memory behind bridge: 00000000f5000000-00000000f5f00000
        Capabilities: [dc] Power Management version 1
 
00:07.0 ISA bridge: Intel Corp. 82371AB/EB/MB PIIX4 ISA (rev 02)
        Flags: bus master, medium devsel, latency 0
 
00:07.1 IDE interface: Intel Corp. 82371AB/EB/MB PIIX4 IDE (rev 01) 
(prog-if 80 [Master])
        Flags: medium devsel
        I/O ports at 1000 [disabled] [size=16]
 
00:07.2 USB Controller: Intel Corp. 82371AB/EB/MB PIIX4 USB (rev 01) 
(prog-if 00 [UHCI])
        Flags: medium devsel
        I/O ports at 1020 [disabled] [size=32]
 
00:07.3 Bridge: Intel Corp. 82371AB/EB/MB PIIX4 ACPI (rev 02)
        Flags: medium devsel, IRQ 9
 
00:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
RTL-8139/8139C/8139C+ (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RT8139
        Flags: bus master, medium devsel, latency 32, IRQ 20
        I/O ports at dc80 [size=128]
        Memory at fe004000 (32-bit, non-prefetchable) [size=128]
 
00:0a.0 SCSI storage controller: ICP Vortex Computersysteme GmbH GDT 
6118RD/6518RD/6618RD
        Subsystem: ICP Vortex Computersysteme GmbH GDT 6118RD/6518RD/6618RD
        Flags: bus master, medium devsel, latency 32, IRQ 21
        Memory at 000c8000 (low-1M, prefetchable) [size=16K]
        Expansion ROM at f8000000 [disabled] [size=32K]
 
00:0e.0 Ethernet controller: Linksys: Unknown device 1032 (rev 12)
        Subsystem: Linksys: Unknown device 0015
        Flags: bus master, 66Mhz, medium devsel, latency 32, IRQ 17
        Memory at fe000000 (32-bit, non-prefetchable) [size=16K]
        I/O ports at d800 [size=256]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
 
01:00.0 VGA compatible controller: ATI Technologies Inc 3D Rage Pro AGP 
1X (rev 5c) (prog-if 00 [VGA])
        Subsystem: Dell Computer Corporation: Unknown device 0081
        Flags: bus master, VGA palette snoop, stepping, medium devsel, 
latency 32
        Memory at fc000000 (32-bit, non-prefetchable) [size=16M]
        I/O ports at fc00 [size=256]
        Memory at fbfff000 (32-bit, non-prefetchable) [size=4K]
        Expansion ROM at <unassigned> [disabled] [size=128K]
        Capabilities: [50] AGP version 1.0
 
02:06.0 SCSI storage controller: Adaptec AIC-7860 (rev 03)
        Subsystem: Adaptec: Unknown device 7860
        Flags: bus master, medium devsel, latency 32, IRQ 16
        I/O ports at ec00 [size=256]
        Memory at f9fff000 (32-bit, non-prefetchable) [size=4K]
        Capabilities: [dc] Power Management version 1


# dmesg
Linux version 2.6.3mild (root@pantera) (gcc version 3.3.3 (Debian)) #3 
SMP Sat Mar 13 16:56:35 GMT 2004
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000003fffe000 (usable)
 BIOS-e820: 000000003fffe000 - 0000000040000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec10000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee10000 (reserved)
 BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
127MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000fe710
hm, page 000fe000 reserved twice.
hm, page 000ff000 reserved twice.
hm, page 000f0000 reserved twice.
On node 0 totalpages: 262142
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 225280 pages, LIFO batch:16
  HighMem zone: 32766 pages, LIFO batch:7
DMI 2.2 present.
ACPI disabled because your bios is from 1999 and too old
You can enable it with acpi=force
Intel MultiProcessor Specification v1.4
    Virtual Wire compatibility mode.
OEM ID: DELL     Product ID: PowerEdge 81 APIC at: 0xFEE00000
Processor #1 6:7 APIC version 17
Processor #0 6:7 APIC version 17
I/O APIC #2 Version 17 at 0xFEC00000.
Enabling APIC mode:  Flat.  Using 1 I/O APICs
Processors: 2
Built 1 zonelists
Kernel command line: BOOT_IMAGE=2.6mild root=805
Initializing CPU#0
PID hash table entries: 4096 (order 12: 32768 bytes)
Detected 498.814 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Memory: 1030176k/1048568k available (1729k kernel code, 17492k reserved, 
703k data, 168k init, 131064k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 983.04 BogoMIPS
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
checking if image is initramfs...it isn't (ungzip failed); looks like an 
initrd
Freeing initrd memory: 3952k freed
CPU:     After generic identify, caps: 0383fbff 00000000 00000000 00000000
CPU:     After vendor identify, caps: 0383fbff 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 512K
CPU:     After all inits, caps: 0383fbff 00000000 00000000 00000040
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
CPU0: Intel Pentium III (Katmai) stepping 03
per-CPU timeslice cutoff: 1464.87 usecs.
task migration cache decay timeout: 2 msecs.
enabled ExtINT on CPU#0
ESR value before enabling vector: 00000040
ESR value after enabling vector: 00000000
Booting processor 1/0 eip 3000
Initializing CPU#1
masked ExtINT on CPU#1
ESR value before enabling vector: 00000000
ESR value after enabling vector: 00000000
Calibrating delay loop... 995.32 BogoMIPS
CPU:     After generic identify, caps: 0383fbff 00000000 00000000 00000000
CPU:     After vendor identify, caps: 0383fbff 00000000 00000000 00000000
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 512K
CPU:     After all inits, caps: 0383fbff 00000000 00000000 00000040
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel Pentium III (Katmai) stepping 03
Total of 2 processors activated (1978.36 BogoMIPS).
ENABLING IO-APIC IRQs
Setting 2 in the phys_id_present_map
...changing IO-APIC physical APIC ID to 2 ... ok.
init IO_APIC IRQs
 IO-APIC (apicid-pin) 2-0, 2-5, 2-10, 2-11, 2-13, 2-14, 2-23 not connected.
..TIMER: vector=0x31 pin1=2 pin2=0
number of MP IRQ sources: 37.
number of IO-APIC #2 registers: 24.
testing the IO APIC.......................
IO APIC #2......
.... register #00: 02000000
.......    : physical APIC id: 02
.......    : Delivery Type: 0
.......    : LTS          : 0
.... register #01: 00170011
.......     : max redirection entries: 0017
.......     : PRQ implemented: 0
.......     : IO APIC version: 0011
.... register #02: 00000000
.......     : arbitration: 00
.... IRQ redirection table:
 NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:
 00 000 00  1    0    0   0   0    0    0    00
 01 001 01  0    0    0   0   0    1    1    39
 02 001 01  0    0    0   0   0    1    1    31
 03 001 01  0    0    0   0   0    1    1    41
 04 001 01  0    0    0   0   0    1    1    49
 05 000 00  1    0    0   0   0    0    0    00
 06 001 01  0    0    0   0   0    1    1    51
 07 001 01  0    0    0   0   0    1    1    59
 08 001 01  0    0    0   0   0    1    1    61
 09 001 01  0    0    0   0   0    1    1    69
 0a 000 00  1    0    0   0   0    0    0    00
 0b 000 00  1    0    0   0   0    0    0    00
 0c 001 01  0    0    0   0   0    1    1    71
 0d 000 00  1    0    0   0   0    0    0    00
 0e 000 00  1    0    0   0   0    0    0    00
 0f 001 01  0    0    0   0   0    1    1    79
 10 001 01  1    1    0   1   0    1    1    81
 11 001 01  1    1    0   1   0    1    1    89
 12 001 01  1    1    0   1   0    1    1    91
 13 001 01  1    1    0   1   0    1    1    99
 14 001 01  1    1    0   1   0    1    1    A1
 15 001 01  1    1    0   1   0    1    1    A9
 16 001 01  1    1    0   1   0    1    1    B1
 17 000 00  1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:2
IRQ1 -> 0:1
IRQ3 -> 0:3
IRQ4 -> 0:4
IRQ6 -> 0:6
IRQ7 -> 0:7
IRQ8 -> 0:8
IRQ9 -> 0:9
IRQ12 -> 0:12
IRQ15 -> 0:15
IRQ16 -> 0:16
IRQ17 -> 0:17
IRQ18 -> 0:18
IRQ19 -> 0:19
IRQ20 -> 0:20
IRQ21 -> 0:21
IRQ22 -> 0:22
.................................... done.
Using local APIC timer interrupts.
calibrating APIC timer ...
..... CPU clock speed is 498.0669 MHz.
..... host bus clock speed is 99.0733 MHz.
checking TSC synchronization across 2 CPUs: passed.
Starting migration thread for cpu 0
Starting migration thread for cpu 1
Brought up 1 CPUs
NET: Registered protocol family 16
PCI: PCI BIOS revision 2.10 entry at 0xfcc0e, last bus=2
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040116
ACPI: Interpreter disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
PnPBIOS: Scanning system for PnP BIOS support...
PnPBIOS: Found PnP BIOS installation structure at 0xc00fe2d0
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0xe2f4, dseg 0x40
pnp: 00:00: ioport range 0x800-0x83f has been reserved
pnp: 00:00: ioport range 0x850-0x85f has been reserved
pnp: 00:00: ioport range 0xaa00-0xaa7f has been reserved
PnPBIOS: 16 nodes reported by PnP BIOS; 16 recorded by driver
ACPI: ACPI tables contain no PCI IRQ routing entries
PCI: Invalid ACPI-PCI IRQ routing table
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Address space collision on region 7 of bridge 0000:00:07.3 [800:83f]
PCI: Address space collision on region 8 of bridge 0000:00:07.3 [840:85f]
PCI: Using IRQ router PIIX/ICH [8086/7110] at 0000:00:07.0
PCI->APIC IRQ transform: (B0,I8,P0) -> 20
PCI->APIC IRQ transform: (B0,I10,P0) -> 21
PCI->APIC IRQ transform: (B0,I14,P0) -> 17
PCI->APIC IRQ transform: (B2,I6,P0) -> 16
PCI: Cannot allocate resource region 4 of device 0000:00:07.1
Machine check exception polling timer started.
Starting balanced_irq
ikconfig 0.7 with /proc/config*
highmem bounce pool size: 64 pages
VFS: Disk quotas dquot_6.5.1
devfs: v1.22 (20021013) Richard Gooch (rgooch@atnf.csiro.au)
devfs: boot_options: 0x0
Initializing Cryptographic API
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
pty: 256 Unix98 ptys configured
Serial: 8250/16550 driver $Revision: 1.90 $ 48 ports, IRQ sharing enabled
ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
ttyS1 at I/O 0x2f8 (irq = 3) is a 16550A
ttyS3 at I/O 0x2e8 (irq = 3) is a 16550A
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
sk98lin: Network Device Driver v6.22
(C)Copyright 1999-2004 Marvell(R).
divert: allocating divert_blk for eth0
eth0: SK-9521 10/100/1000Base-T Adapter
      PrefPort:A  RlmtMode:Check Link State
divert: not allocating divert_blk for non-ethernet device lo
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
input: AT Translated Set 2 keyboard on isa0060/serio0
NET: Registered protocol family 2
IP: routing cache hash table of 8192 buckets, 64Kbytes
TCP: Hash tables configured (established 262144 bind 65536)
NET: Registered protocol family 8
NET: Registered protocol family 20
PM: Reading pmdisk image.
PM: Resume from disk failed.
RAMDISK: cramfs filesystem found at block 0
RAMDISK: Loading 3952 blocks [1 disk] into ram disk... done.
VFS: Mounted root (cramfs filesystem).
Freeing unused kernel memory: 168k freed
SCSI subsystem initialized
GDT: Storage RAID Controller Driver. Version: 2.08
GDT: Found 1 PCI Storage RAID Controllers
GDT CTR0: Configuring GDT-PCI HA at 0/10 IRQ 21
scsi0 : GDT6518RD
Using anticipatory io scheduler
  Vendor: ICP       Model: Host Drive  #00   Rev:
  Type:   Direct-Access                      ANSI SCSI revision: 02
  Vendor: DELL      Model: 1x6 U2W SCSI BP   Rev: 5.33
  Type:   Processor                          ANSI SCSI revision: 02
SCSI device sda: 35551845 512-byte hdwr sectors (18203 MB)
SCSI device sda: drive cache: write through
 /dev/scsi/host0/bus0/target0/lun0: p1 p2 < p5 p6 p7 p8 >
Attached scsi disk sda at scsi0, channel 0, id 0, lun 0
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
NET: Registered protocol family 1
EXT3 FS on sda5, internal journal
Real Time Clock Driver v1.12
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda7, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda6, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
parport0: irq 7 detected
parport0: cpp_daisy: aa5500ff(08)
parport0: assign_addrs: aa5500ff(08)
parport0: cpp_daisy: aa5500ff(08)
parport0: assign_addrs: aa5500ff(08)
lp0: using parport0 (polling).
Linux agpgart interface v0.100 (c) Dave Jones
8139too Fast Ethernet driver 0.9.27
divert: allocating divert_blk for eth1
eth1: RealTek RTL8139 at 0xf886e000, 00:c0:ca:11:42:f6, IRQ 20
eth1:  Identified 8139 chip type 'RTL-8139 rev K'
NET: Registered protocol family 10
Disabled Privacy Extensions on device c0331620(lo)
IPv6 over IPv4 tunneling driver
divert: not allocating divert_blk for non-ethernet device sit0
NET: Registered protocol family 17
Linux Kernel Card Services
  options:  [pci] [cardbus] [pm]
Intel ISA PCIC probe: not found.
eth0: no IPv6 routers present
input: PS/2 Generic Mouse on isa0060/serio1
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
atkbd.c: Unknown key released (translated set 2, code 0x7a on 
isa0060/serio0).
atkbd.c: This is an XFree86 bug. It shouldn't access hardware directly.
eth0: network connection up using port A
    speed:           100
    autonegotiation: yes
    duplex mode:     full
    flowctrl:        symmetric
    irq moderation:  disabled
    scatter-gather:  enabled
