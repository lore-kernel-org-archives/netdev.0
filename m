From: Olaf Hering <olh@suse.de>
Subject: tg3 access hangs on system shutdown with 2.6.11-rc5, tg3_stop_block timed out
Date: Sat, 26 Feb 2005 17:18:36 +0100
Message-ID: <20050226161836.GA15277@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


my JS20 blades hang on system reboot with current Linus tree. I think it
started after rc3. Maybe this line in dmesg gives a hint:

tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2

It does not happen every time, and I dont have a simple test case.


ip            S 000000000ff4a668 12160  9595   9590                     (NOTLB)
Call Trace:
[c00000000d947230] [c00000000009778c] .__alloc_pages+0x11c/0x5fc (unreliable)
[c00000000d947400] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000d947490] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000d9475b0] [c0000000003fde80] .schedule_timeout+0x118/0x120
[c00000000d947690] [c00000000034a46c] .skb_recv_datagram+0x210/0x2f4
[c00000000d9477d0] [c00000000036f310] .netlink_recvmsg+0x7c/0x2cc
[c00000000d9478c0] [c000000000340264] .sock_recvmsg+0x174/0x1c0
[c00000000d947ad0] [c000000000342aa0] .sys_recvmsg+0x154/0x350
[c00000000d947d00] [c000000000362084] .compat_sys_recvmsg+0x1c/0x34
[c00000000d947d80] [c000000000362b9c] .compat_sys_socketcall+0xf8/0x278
[c00000000d947e30] [c00000000000d500] syscall_exit+0x0/0x18



0000:00:00.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=00, secondary=11, subordinate=20, sec-latency=0
	I/O behind bridge: 00200000-003fffff
	Memory behind bridge: c0000000-dfffffff
	Expansion ROM at 00200000 [disabled] [size=2M]
	Capabilities: [a0] 	Capabilities: [b8] #08 [8011]

0000:00:03.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8111 PCI (rev 07) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 0
	Bus: primary=00, secondary=21, subordinate=30, sec-latency=0
	I/O behind bridge: 00008000-0000ffff
	Memory behind bridge: e0000000-ebffffff
	Expansion ROM at 00008000 [disabled] [size=32K]
	Capabilities: [c0] #08 [0083]
	Capabilities: [f0] #08 [8031]

0000:00:04.1 IDE interface: Advanced Micro Devices [AMD] AMD-8111 IDE (rev 03) (prog-if 8f [Master SecP SecO PriP PriO])
	Flags: bus master, medium devsel, latency 74, IRQ 32
	I/O ports at 7400
	I/O ports at 6c00 [size=4]
	I/O ports at 7800 [size=8]
	I/O ports at 7000 [size=4]
	I/O ports at 7c00 [size=16]

0000:00:1f.0 PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12) (prog-if 00 [Normal decode])
	Flags: bus master, 66Mhz, medium devsel, latency 64
	Bus: primary=00, secondary=01, subordinate=10, sec-latency=0
	I/O behind bridge: 00100000-001fffff
	Memory behind bridge: 80000000-bfffffff
	Expansion ROM at 00100000 [disabled] [size=1M]
	Capabilities: [a0] 	Capabilities: [b8] #08 [8000]
	Capabilities: [c0] #08 [005f]

0000:11:01.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704S Gigabit Ethernet (rev 03)
	Subsystem: IBM: Unknown device 029c
	Flags: bus master, 66Mhz, medium devsel, latency 144, IRQ 44
	Memory at c0030000 (64-bit, non-prefetchable)
	Memory at c0020000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] 	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-

0000:11:01.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704S Gigabit Ethernet (rev 03)
	Subsystem: IBM: Unknown device 029c
	Flags: bus master, 66Mhz, medium devsel, latency 144, IRQ 45
	Memory at c0010000 (64-bit, non-prefetchable)
	Memory at c0000000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] 	Capabilities: [48] Power Management version 2
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-

0000:21:00.0 USB Controller: Advanced Micro Devices [AMD] AMD-8111 USB (rev 0b) (prog-if 10 [OHCI])
	Flags: bus master, medium devsel, latency 72, IRQ 35
	Memory at e0001000 (32-bit, non-prefetchable)

0000:21:00.1 USB Controller: Advanced Micro Devices [AMD] AMD-8111 USB (rev 0b) (prog-if 10 [OHCI])
	Flags: bus master, medium devsel, latency 72, IRQ 35
	Memory at e0000000 (32-bit, non-prefetchable)

  PID TTY      STAT   TIME COMMAND
    1 ?        S      0:00 init [6] 
    2 ?        S      0:07 [migration/0]
    3 ?        SN     0:16 [ksoftirqd/0]
    4 ?        S      0:06 [migration/1]
    5 ?        SN     0:03 [ksoftirqd/1]
    6 ?        S<     0:05 [events/0]
    7 ?        S<     0:00 [events/1]
    8 ?        S<     0:00 [khelper]
   13 ?        S<     0:00 [kthread]
   42 ?        S<     0:00  \_ [kblockd/0]
   43 ?        S<     0:00  \_ [kblockd/1]
  112 ?        S      2:53  \_ [pdflush]
  114 ?        S<     0:00  \_ [aio/0]
  115 ?        S<     0:00  \_ [aio/1]
  709 ?        S<     0:00  \_ [khvcd]
  941 ?        S<     0:44  \_ [reiserfs/0]
  942 ?        S<     0:32  \_ [reiserfs/1]
22416 ?        S      1:36  \_ [pdflush]
   51 ?        S      0:00 [khubd]
   75 ?        S      0:00 [rtasd]
  113 ?        S      2:08 [kswapd0]
  711 ?        S      0:00 [kseriod]
 2444 ?        S      0:00 [hwscand]
 2461 ?        Ss     0:00 /sbin/dhcpcd -R -G -N -Y -t 999999 -h linux eth1
11835 ?        Ss     0:00 sshd: root@pts/0                                
11837 pts/0    Ss     0:08  \_ -bash
10383 pts/0    S+     0:00      \_ -bash
10385 pts/0    R+     0:00          \_ ps axf
 8971 ?        Ss     0:00 /bin/bash /etc/init.d/rc 6
 9438 ?        S      0:00  \_ /bin/bash /etc/init.d/rc5.d/K17network stop
 9565 ?        S      0:00      \_ /bin/bash /sbin/ifdown eth1 -o rc onboot
 9590 ?        S      0:00          \_ /bin/bash scripts/ifdown-connection eth-bus-pci-0000:11:01.1 eth1 -o rc onboot
 9595 ?        S      0:00              \_ ip link list eth1
 8986 ?        Ss     0:01 /sbin/blogd /dev/hvc0
10162 ?        Ss     0:00 /sbin/dhcpcd -H -D -t 999999 -h linux eth0
10331 ?        Ss     0:00 /usr/lib/postfix/master
10339 ?        S      0:00  \_ pickup -l -t fifo -u
10340 ?        S      0:00  \_ qmgr -l -t fifo -u
10350 ?        S      0:00  \_ trivial-rewrite -n rewrite -t unix -u
10351 ?        S      0:00  \_ smtp -t unix -u
10352 ?        S      0:00  \_ smtp -t unix -u
10353 ?        S      0:00  \_ smtp -t unix -u
10354 ?        S      0:00  \_ smtp -t unix -u
10355 ?        S      0:00  \_ smtp -t unix -u
10359 ?        S      0:00  \_ showq -t unix -u
10360 ?        S      0:00  \_ bounce -z -n defer -t unix -u
10361 ?        S      0:00  \_ bounce -z -n defer -t unix -u
10362 ?        S      0:00  \_ smtp -t unix -u
10363 ?        S      0:00  \_ smtp -t unix -u
10364 ?        S      0:00  \_ smtp -t unix -u
10365 ?        S      0:00  \_ smtp -t unix -u
10366 ?        S      0:00  \_ smtp -t unix -u
10368 ?        S      0:00  \_ smtp -t unix -u
10369 ?        S      0:00  \_ smtp -t unix -u
10377 ?        S      0:00  \_ cleanup -z -t unix -u
Found initrd at 0xc000000002600000:0xc000000002738000
firmware_features = 0x55f
Partition configured for 2 cpus.
Starting Linux PPC64 2.6.11-rc4-bk10-200502230747-usbtest
-----------------------------------------------------
ppc64_pft_size                = 0x17
ppc64_debug_switch            = 0x0
ppc64_interrupt_controller    = 0x2
systemcfg                     = 0xc000000000005000
systemcfg->platform           = 0x101
systemcfg->processorCount     = 0x2
systemcfg->physicalMemorySize = 0x1e000000
ppc64_caches.dcache_line_size = 0x80
ppc64_caches.icache_line_size = 0x80
htab_address                  = 0x0000000000000000
htab_hash_mask                = 0xffff
-----------------------------------------------------
[boot]0100 MM Init
[boot]0100 MM Init Done
Linux version 2.6.11-rc4-bk10-200502230747-usbtest (abuild@pomegranate) (gcc version 3.3.5 20050117 (prerelease) (SUSE Linux)) #1 SMP Wed Feb 23 07:52:43 UTC 2005
[boot]0012 Setup Arch
Top of RAM: 0x1e000000, Total RAM: 0x1e000000
Memory hole size: 0MB
PPC64 nvram contains 16384 bytes
Using default idle loop
On node 0 totalpages: 122880
  DMA zone: 122880 pages, LIFO batch:16
  Normal zone: 0 pages, LIFO batch:1
  HighMem zone: 0 pages, LIFO batch:1
[boot]0015 Setup Done
Built 1 zonelists
Kernel command line: root=/dev/hda3 kdb=on quiet selinux=0 elevator=cfq 
[boot]0020 XICS Init
xics: no ISA interrupt controller
[boot]0021 XICS Done
PID hash table entries: 2048 (order: 11, 65536 bytes)
time_init: decrementer frequency = 199.839387 MHz
time_init: processor frequency   = 1600.000000 MHz
Console: colour dummy device 80x25
Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
Inode-cache hash table entries: 32768 (order: 6, 262144 bytes)
freeing bootmem node 0
Memory: 463936k/491520k available (4108k kernel code, 27244k reserved, 2052k data, 1362k bss, 252k init)
Calibrating delay loop... 398.33 BogoMIPS (lpj=199168)
Security Framework v1.0.0 initialized
SELinux:  Disabled at boot.
Capability LSM initialized
Mount-cache hash table entries: 256 (order: 0, 4096 bytes)
Processor 1 found.
Brought up 2 CPUs
CPU0 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000001
  groups: 00000000,00000000,00000000,00000001
  domain 1: span 00000000,00000000,00000000,00000003
   groups: 00000000,00000000,00000000,00000001 00000000,00000000,00000000,00000002
   domain 2: span 00000000,00000000,00000000,00000003
    groups: 00000000,00000000,00000000,00000003
CPU1 attaching sched-domain:
 domain 0: span 00000000,00000000,00000000,00000002
  groups: 00000000,00000000,00000000,00000002
  domain 1: span 00000000,00000000,00000000,00000003
   groups: 00000000,00000000,00000000,00000002 00000000,00000000,00000000,00000001
   domain 2: span 00000000,00000000,00000000,00000003
    groups: 00000000,00000000,00000000,00000003
checking if image is initramfs... it is
Freeing initrd memory: 1248k freed
NET: Registered protocol family 16
PCI: Probing PCI hardware
IDE Fixup IRQ: Can't find IO-APIC !
IOMMU table initialized, virtual merging enabled
mapping IO 100f4000000 -> e000000000000000, size: 400000
PCI: Probing PCI hardware done
usbcore: registered new driver usbfs
usbcore: registered new driver hub
TC classifier action (bugs to netdev@oss.sgi.com cc hadi@cyberus.ca)
i/pSeries Real Time Clock Driver v1.1
RTAS daemon started
RTAS: event: 1, Type: Unknown, Severity: 2
probe_bus_pseries: processing c00000001dffd228
probe_bus_pseries: processing c00000001dffd398
probe_bus_pseries: processing c00000001dffd510
audit: initializing netlink socket (disabled)
audit(1109197456.282:0): initialized
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
Initializing Cryptographic API
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
rpaphp: RPA HOT Plug PCI Controller Driver version: 0.1
rpadlpar_io_init: partition not DLPAR capable
vio_register_driver: driver hvc_console registering
HVSI: registered 0 devices
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
pmac_zilog: 0.6 (Benjamin Herrenschmidt <benh@kernel.crashing.org>)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered (default)
Floppy drive(s): fd0 is 2.88M
RAMDISK driver initialized: 16 RAM disks of 123456K size 1024 blocksize
input: Macintosh mouse button emulation
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
AMD8111: IDE controller at PCI slot 0000:00:04.1
AMD8111: chipset revision 3
AMD8111: 0000:00:04.1 (rev 03) UDMA133 controller
AMD8111: 100% native mode on irq 32
    ide0: BM-DMA at 0x7c00-0x7c07, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0x7c08-0x7c0f, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
hda: TOSHIBA MK4019GAXB, ATA DISK drive
Unhandled interrupt 20, disabled
ide0 at 0x7400-0x7407,0x6c02 on irq 32
Probing IDE interface ide1...
Probing IDE interface ide1...
hda: max request size: 128KiB
hda: 78140160 sectors (40007 MB), CHS=65535/16/63, UDMA(33)
hda: cache flushes supported
 hda: hda1 hda2 hda3
ohci_hcd: 2004 Nov 08 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd 0000:21:00.0: OHCI Host Controller
ohci_hcd 0000:21:00.0: irq 35, pci mem 0x100e0001000
ohci_hcd 0000:21:00.0: new USB bus registered, assigned bus number 1
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 3 ports detected
ohci_hcd 0000:21:00.1: OHCI Host Controller
ohci_hcd 0000:21:00.1: irq 35, pci mem 0x100e0000000
ohci_hcd 0000:21:00.1: new USB bus registered, assigned bus number 2
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 3 ports detected
usbcore: registered new driver hiddev
usbcore: registered new driver usbhid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
md: md driver 0.90.1 MAX_MD_DEVS=256, MD_SB_DISKS=27
oprofile: using ppc64/970 performance monitoring.
NET: Registered protocol family 2
IP: routing cache hash table of 2048 buckets, 32Kbytes
TCP established hash table entries: 16384 (order: 6, 262144 bytes)
TCP bind hash table entries: 16384 (order: 6, 262144 bytes)
TCP: Hash tables configured (established 16384 bind 16384)
NET: Registered protocol family 1
NET: Registered protocol family 17
NET: Registered protocol family 15
Freeing unused kernel memory: 252k freed
ReiserFS: hda3: found reiserfs format "3.6" with standard journal
ReiserFS: hda3: using ordered data mode
ReiserFS: hda3: journal params: device hda3, size 8192, journal first block 18, max trans len 1024, max batch 900, max commit age 30, max trans age 30
ReiserFS: hda3: checking transaction log (hda3)
ReiserFS: hda3: Using r5 hash to sort names
ioctl32(showconsole:970): Unknown cmd fd(0) cmd(40045432){00} arg(ffffea78) on /dev/console
Adding 919792k swap on /dev/hda2.  Priority:42 extents:1
ioctl32(showconsole:1087): Unknown cmd fd(0) cmd(40045432){00} arg(ffffe9d8) on /dev/console
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
device-mapper: 4.4.0-ioctl (2005-01-12) initialised: dm-devel@redhat.com
ioctl32(showconsole:1290): Unknown cmd fd(0) cmd(40045432){00} arg(ffffea08) on /dev/console
ioctl32(showconsole:1361): Unknown cmd fd(0) cmd(40045432){00} arg(ffffea18) on /dev/console
ioctl32(showconsole:1551): Unknown cmd fd(0) cmd(40045432){00} arg(ffffea58) on /dev/console
tg3.c:v3.23 (February 15, 2005)
PCI: Enabling device: (0000:11:01.0), cmd 142
eth0: Tigon3 [partno(none) rev 2003 PHY(serdes)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:60:1e:09:de
eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[1] TSOcap[0] 
PCI: Enabling device: (0000:11:01.1), cmd 142
eth1: Tigon3 [partno(none) rev 2003 PHY(serdes)] (PCIX:133MHz:64-bit) 10/100/1000BaseT Ethernet 00:0d:60:1e:09:df
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] TSOcap[1] 
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.
tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is off for TX and off for RX.
SCSI subsystem initialized
sg: Unknown symbol scsi_do_req
sg: Unknown symbol scsi_device_get
sg: Unknown symbol scsi_command_normalize_sense
sg: Unknown symbol scsi_ioctl_send_command
sg: Unknown symbol scsi_release_request
sg: Unknown symbol scsi_print_req_sense
sg: Unknown symbol scsi_allocate_request
sg: Unknown symbol scsi_device_put
sg: Unknown symbol scsi_logging_level
sg: Unknown symbol scsi_ioctl
sg: Unknown symbol scsi_block_when_processing_errors
sg: Unknown symbol scsi_register_interface
sg: Unknown symbol scsi_reset_provider
NET: Registered protocol family 10
Disabled Privacy Extensions on device c0000000005b89b8(lo)
IPv6 over IPv4 tunneling driver
Disabled Privacy Extensions on device c0000000070e9180(sit0)
eth1: no IPv6 routers present
nfs warning: mount version older than kernel
st: Version 20041025, fixed bufsize 32768, s/g segs 256
ioctl32(hwscan:10451): Unknown cmd fd(3) cmd(40045432){00} arg(ffffe804) on /dev/console
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
nfs warning: mount version older than kernel
ioctl32(showconsole:8975): Unknown cmd fd(0) cmd(40045432){00} arg(ffffea48) on /dev/console
tg3: tg3_stop_block timed out, ofs=4000 enable_bit=2
SysRq : Show State

                                                       sibling
  task                 PC          pid father child younger older
init          S 0000000010018fc4  6848     1      0     2               (NOTLB)
Call Trace:
[c000000002a1f6d0] [c000000002a1f6f0] 0xc000000002a1f6f0 (unreliable)
[c000000002a1f8a0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002a1f930] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002a1fa50] [c0000000003fde08] .schedule_timeout+0xa0/0x120
[c000000002a1fb30] [c0000000000e0090] .do_select+0x3a0/0x4dc
[c000000002a1fc80] [c0000000000fe3fc] .compat_sys_select+0x4e0/0x824
[c000000002a1fdb0] [c00000000001dd0c] .ppc32_select+0x1c/0x34
[c000000002a1fe30] [c00000000000d500] syscall_exit+0x0/0x18
migration/0   S 0000000000000000 13328     2      1             3       (L-TLB)
Call Trace:
[c0000000013aba40] [7265677368657265] 0x7265677368657265 (unreliable)
[c0000000013abc10] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000013abca0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000013abdc0] [c000000000059950] .migration_thread+0x344/0x3dc
[c0000000013abed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000013abf90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
ksoftirqd/0   S 0000000000000000 13664     3      1             4     2 (L-TLB)
Call Trace:
[c0000000013afaa0] [c00000001c632a08] 0xc00000001c632a08 (unreliable)
[c0000000013afc70] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000013afd00] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000013afe20] [c0000000000678b0] .ksoftirqd+0x19c/0x1a4
[c0000000013afed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000013aff90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
migration/1   S 0000000000000000 13328     4      1             5     3 (L-TLB)
Call Trace:
[c0000000013b3c10] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000013b3ca0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000013b3dc0] [c000000000059950] .migration_thread+0x344/0x3dc
[c0000000013b3ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000013b3f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
ksoftirqd/1   S 0000000000000000 13664     5      1             6     4 (L-TLB)
Call Trace:
[c0000000013b7aa0] [c0000000013b7da0] 0xc0000000013b7da0 (unreliable)
[c0000000013b7c70] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000013b7d00] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000013b7e20] [c0000000000678b0] .ksoftirqd+0x19c/0x1a4
[c0000000013b7ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000013b7f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
events/0      S 0000000000000000 11176     6      1             7     5 (L-TLB)
Call Trace:
[c0000000013bba20] [0000000001c00000] 0x1c00000 (unreliable)
[c0000000013bbbf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000013bbc80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000013bbda0] [c000000000077904] .worker_thread+0x174/0x330
[c0000000013bbed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000013bbf90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
events/1      S 0000000000000000 10688     7      1             8     6 (L-TLB)
Call Trace:
[c0000000026c3a20] [000000000000000a] 0xa (unreliable)
[c0000000026c3bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000026c3c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000026c3da0] [c000000000077904] .worker_thread+0x174/0x330
[c0000000026c3ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000026c3f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
khelper       S 0000000000000000 11232     8      1            13     7 (L-TLB)
Call Trace:
[c00000001df9ba20] [c000000000056de0] .activate_task+0x84/0x104 (unreliable)
[c00000001df9bbf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000001df9bc80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000001df9bda0] [c000000000077904] .worker_thread+0x174/0x330
[c00000001df9bed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c00000001df9bf90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
kthread       S 0000000000000000 11888    13      1    42      51     8 (L-TLB)
Call Trace:
[c000000002653a20] [c000000000056de0] .activate_task+0x84/0x104 (unreliable)
[c000000002653bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002653c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002653da0] [c000000000077904] .worker_thread+0x174/0x330
[c000000002653ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002653f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
kblockd/0     S 0000000000000000 12472    42     13            43       (L-TLB)
Call Trace:
[c0000000026a3a20] [c000000000036ae0] .xics_enable_irq+0xbc/0xd8 (unreliable)
[c0000000026a3bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c0000000026a3c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c0000000026a3da0] [c000000000077904] .worker_thread+0x174/0x330
[c0000000026a3ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c0000000026a3f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
kblockd/1     S 0000000000000000 12424    43     13           112    42 (L-TLB)
Call Trace:
[c000000002657a20] [c000000000036ae0] .xics_enable_irq+0xbc/0xd8 (unreliable)
[c000000002657bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002657c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002657da0] [c000000000077904] .worker_thread+0x174/0x330
[c000000002657ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002657f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
khubd         S 0000000000000000 13504    51      1            75    13 (L-TLB)
Call Trace:
[c000000002b13a80] [c00000000058e448] r_file_operations+0x28/0xd8 (unreliable)
[c000000002b13c50] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002b13ce0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002b13e00] [c0000000002fdd00] .hub_thread+0x204/0xc7c
[c000000002b13f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
rtasd         R  running task   13240    75      1           113    51 (L-TLB)
pdflush       S 0000000000000000  7648   112     13           114    43 (L-TLB)
Call Trace:
[c000000002b5fa70] [c00000000015de4c] .do_journal_end+0x2cc/0x1214 (unreliable)
[c000000002b5fc40] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002b5fcd0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002b5fdf0] [c0000000000996b0] .pdflush+0xfc/0x25c
[c000000002b5fed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002b5ff90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
kswapd0       S 0000000000000000 10544   113      1           711    75 (L-TLB)
Call Trace:
[c000000002b63a70] [0000000000200200] 0x200200 (unreliable)
[c000000002b63c40] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002b63cd0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002b63df0] [c0000000000a34b8] .kswapd+0x478/0x51c
[c000000002b63f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
aio/0         S 0000000000000000 14624   114     13           115   112 (L-TLB)
Call Trace:
[c000000002b67bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002b67c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002b67da0] [c000000000077904] .worker_thread+0x174/0x330
[c000000002b67ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002b67f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
aio/1         S 0000000000000000 14624   115     13           709   114 (L-TLB)
Call Trace:
[c000000002b77bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002b77c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002b77da0] [c000000000077904] .worker_thread+0x174/0x330
[c000000002b77ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002b77f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
khvcd         S 0000000000000000 12992   709     13           941   115 (L-TLB)
Call Trace:
[c000000002bcfac0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002bcfb50] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002bcfc70] [c0000000003fde08] .schedule_timeout+0xa0/0x120
[c000000002bcfd50] [c00000000006de50] .msleep_interruptible+0x60/0x88
[c000000002bcfde0] [c000000000279d54] .khvcd+0x368/0x3c4
[c000000002bcfed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000002bcff90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
kseriod       S 0000000000000000 14848   711      1          2444   113 (L-TLB)
Call Trace:
[c00000001dcafcd0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000001dcafd60] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000001dcafe80] [c00000000027cdd4] .serio_thread+0x2b0/0x2f8
[c00000001dcaff90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
reiserfs/0    S 0000000000000000  9536   941     13           942   709 (L-TLB)
Call Trace:
[c00000000fca7a20] [0000000001a1f9f0] 0x1a1f9f0 (unreliable)
[c00000000fca7bf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000fca7c80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000fca7da0] [c000000000077904] .worker_thread+0x174/0x330
[c00000000fca7ed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c00000000fca7f90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
reiserfs/1    S 0000000000000000  9376   942     13         22416   941 (L-TLB)
Call Trace:
[c00000000fc8ba20] [0000000001a1f9f0] 0x1a1f9f0 (unreliable)
[c00000000fc8bbf0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000fc8bc80] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000fc8bda0] [c000000000077904] .worker_thread+0x174/0x330
[c00000000fc8bed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c00000000fc8bf90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
hwscand       S 000000000ff7dec4  9808  2444      1          2461   711 (NOTLB)
Call Trace:
[c000000002c7f860] [c000000002c7f8b0] 0xc000000002c7f8b0 (unreliable)
[c000000002c7fa30] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000002c7fac0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000002c7fbe0] [c0000000001dcba8] .sys_msgrcv+0x3ec/0x488
[c000000002c7fcf0] [c0000000001daf54] .compat_sys_msgrcv+0xd8/0x1a8
[c000000002c7fdb0] [c00000000001ce9c] .sys32_ipc+0x16c/0x210
[c000000002c7fe30] [c00000000000d500] syscall_exit+0x0/0x18
dhcpcd        S 000000000ff4b2dc 12168  2461      1          8971  2444 (NOTLB)
Call Trace:
[c00000000168f930] [c00000000006d8ac] .del_timer+0x40/0xe4 (unreliable)
[c00000000168fb00] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000168fb90] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000168fcb0] [c0000000003fde08] .schedule_timeout+0xa0/0x120
[c00000000168fd90] [c000000000088620] .compat_sys_nanosleep+0xc8/0x1a4
[c00000000168fe30] [c00000000000d500] syscall_exit+0x0/0x18
sshd          S 000000000fb8b608  8112 11835      1 11837          9000 (NOTLB)
Call Trace:
[c0000000173576d0] [c000000017357780] 0xc000000017357780 (unreliable)
[c0000000173578a0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000017357930] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000017357a50] [c0000000003fde80] .schedule_timeout+0x118/0x120
[c000000017357b30] [c0000000000e0090] .do_select+0x3a0/0x4dc
[c000000017357c80] [c0000000000fe3fc] .compat_sys_select+0x4e0/0x824
[c000000017357db0] [c00000000001dd0c] .ppc32_select+0x1c/0x34
[c000000017357e30] [c00000000000d500] syscall_exit+0x0/0x18
bash          R  running task    8112 11837  11835                     (NOTLB)
pdflush       S 0000000000000000  6928 22416     13                 942 (L-TLB)
Call Trace:
[c000000001e2ba70] [c00000000015de4c] .do_journal_end+0x2cc/0x1214 (unreliable)
[c000000001e2bc40] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000001e2bcd0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000001e2bdf0] [c0000000000996b0] .pdflush+0xfc/0x25c
[c000000001e2bed0] [c00000000007ef60] .kthread+0x18c/0x1e0
[c000000001e2bf90] [c0000000000147e8] .kernel_thread+0x4c/0x6c
rc            S 000000000fe3bc9c  8112  8971      1  9438    8986  2461 (NOTLB)
Call Trace:
[c00000001671f8d0] [0000136eafb0b001] 0x136eafb0b001 (unreliable)
[c00000001671faa0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000001671fb30] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000001671fc50] [c000000000063e1c] .do_wait+0xe5c/0x11f4
[c00000001671fdb0] [c00000000001c4c4] .sys32_waitpid+0x20/0x38
[c00000001671fe30] [c00000000000d500] syscall_exit+0x0/0x18
blogd         S 000000000ff30654 11024  8986      1          9000  8971 (NOTLB)
Call Trace:
[c00000000cec38a0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000cec3930] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000cec3a50] [c0000000003fde08] .schedule_timeout+0xa0/0x120
[c00000000cec3b30] [c0000000000e0090] .do_select+0x3a0/0x4dc
[c00000000cec3c80] [c0000000000fe3fc] .compat_sys_select+0x4e0/0x824
[c00000000cec3db0] [c00000000001dd0c] .ppc32_select+0x1c/0x34
[c00000000cec3e30] [c00000000000d500] syscall_exit+0x0/0x18
blogd         S 000000000ffc42dc 10816  9000      1         11835  8986 (NOTLB)
Call Trace:
[c00000001a7eb790] [c00000001a7eb840] 0xc00000001a7eb840 (unreliable)
[c00000001a7eb960] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000001a7eb9f0] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000001a7ebb10] [c0000000003fde08] .schedule_timeout+0xa0/0x120
[c00000001a7ebbf0] [c000000000080c60] .do_futex+0x558/0x784
[c00000001a7ebd60] [c000000000089690] .compat_sys_futex+0xac/0x144
[c00000001a7ebe30] [c00000000000d500] syscall_exit+0x0/0x18
K17network    S 000000000fe3bc9c  8176  9438   8971  9565               (NOTLB)
Call Trace:
[c0000000074338d0] [00004be47e859001] 0x4be47e859001 (unreliable)
[c000000007433aa0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000007433b30] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000007433c50] [c000000000063e1c] .do_wait+0xe5c/0x11f4
[c000000007433db0] [c00000000001c4c4] .sys32_waitpid+0x20/0x38
[c000000007433e30] [c00000000000d500] syscall_exit+0x0/0x18
ifdown        S 000000000fe3bc9c 11800  9565   9438  9590               (NOTLB)
Call Trace:
[c000000008fb78d0] [000097098ea97001] 0x97098ea97001 (unreliable)
[c000000008fb7aa0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c000000008fb7b30] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c000000008fb7c50] [c000000000063e1c] .do_wait+0xe5c/0x11f4
[c000000008fb7db0] [c00000000001c4c4] .sys32_waitpid+0x20/0x38
[c000000008fb7e30] [c00000000000d500] syscall_exit+0x0/0x18
ifdown-connec S 000000000fe3bc9c 11800  9590   9565  9595               (NOTLB)
Call Trace:
[c00000000f1b78d0] [000028a7de9d8001] 0x28a7de9d8001 (unreliable)
[c00000000f1b7aa0] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000f1b7b30] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000f1b7c50] [c000000000063e1c] .do_wait+0xe5c/0x11f4
[c00000000f1b7db0] [c00000000001c4c4] .sys32_waitpid+0x20/0x38
[c00000000f1b7e30] [c00000000000d500] syscall_exit+0x0/0x18
ip            S 000000000ff4a668 12160  9595   9590                     (NOTLB)
Call Trace:
[c00000000d947230] [c00000000009778c] .__alloc_pages+0x11c/0x5fc (unreliable)
[c00000000d947400] [c0000000000126f4] .__switch_to+0xa4/0xf0
[c00000000d947490] [c0000000003fcd24] .schedule+0x3b8/0xc98
[c00000000d9475b0] [c0000000003fde80] .schedule_timeout+0x118/0x120
[c00000000d947690] [c00000000034a46c] .skb_recv_datagram+0x210/0x2f4
[c00000000d9477d0] [c00000000036f310] .netlink_recvmsg+0x7c/0x2cc
[c00000000d9478c0] [c000000000340264] .sock_recvmsg+0x174/0x1c0
[c00000000d947ad0] [c000000000342aa0] .sys_recvmsg+0x154/0x350
[c00000000d947d00] [c000000000362084] .compat_sys_recvmsg+0x1c/0x34
[c00000000d947d80] [c000000000362b9c] .compat_sys_socketcall+0xf8/0x278
[c00000000d947e30] [c00000000000d500] syscall_exit+0x0/0x18
tg3: eth0: Link is down.
tg3: eth0: Link is up at 1000 Mbps, full duplex.
tg3: eth0: Flow control is off for TX and off for RX.
