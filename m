From: Paul Collins <paul@briny.ondioline.org>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Fri, 30 Jun 2006 01:31:20 +1000
Message-ID: <87mzbwvv07.fsf@briny.internal.ondioline.org>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org>
	<200606261727.24266.mb@bu3sch.de>
	<871wt8xtc9.fsf@briny.internal.ondioline.org>
	<200606291707.55172.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:45834 "EHLO
	jenny.ondioline.org") by vger.kernel.org with ESMTP
	id S1750808AbWF2PgQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 11:36:16 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200606291707.55172.mb@bu3sch.de> (Michael Buesch's message of
	"Thu, 29 Jun 2006 17:07:54 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb@bu3sch.de> writes:

> On Thursday 29 June 2006 10:24, Paul Collins wrote:
>> Michael Buesch <mb@bu3sch.de> writes:
>> 
>> > On Monday 26 June 2006 14:43, Michael Buesch wrote:
>> >> Try to get more logs.
>> >> I suggest to do a netconsole for logging.
>> >
>> > Also note that current softmac trees have a patch missing.
>> > It seems it got lost somewhere after my merge request.
>> > I already contacted John in private for this, but no reply, yet.
>> > The patch is attached. Maybe it fixes your issue.
>> 
>> On a preempt kernel I can trigger the hang easily,
>
> How? I need to reproduce it to get a clue and fix it. :)

I did it by running the commands I listed in my previous message.
Here they are again, minus the pesky log messages.

  ip set link eth1 up
  ip set link eth1 down
  iwconfig eth1 essid wlan-ap enc off
  ip set link eth1 down
  ip set link eth1 up
  iwconfig eth1 essid wlan-ap enc off
  dhclient eth1

I was running a preempt kernel built from Linus's current tree (commit
0a6047eef1c465c38aacfbdab193161b3f0cd144), with your suspend-MAC and
mac_suspended patches applied.  The commit ID encoded in the kernel
version is different because I have some other stuff committed locally:
the bluetooth patch and a couple of snd-aoa fixes.

> I have no idea where it might come from (I don't even know
> what exactly happens).
>
> And please provide a _full_ dmesg log without comments inbetween
> after triggering the hang (with a full Controller Restart cycle).

Here is the entire log, from boot to hang.  There was nothing more
logged on the console beyond what is below.

Jun 29 17:32:21 briny kernel: klogd 1.4.1#18, log source = /proc/kmsg started.
Jun 29 17:32:21 briny kernel: Using PowerMac machine description
Jun 29 17:32:21 briny kernel: Total memory = 1024MB; using 2048kB for hash table (at cfe00000)
Jun 29 17:32:21 briny kernel: Linux version 2.6.17-gfe4aa073-dirty (paul@briny) (gcc version 4.1.2 20060613 (prerelease) (Debian 4.1.1-5)) #6 PREEMPT Thu Jun 29 17:09:48 EST 2006
Jun 29 17:32:21 briny kernel: Found UniNorth memory controller & host bridge @ 0xf8000000 revision: 0xd2
Jun 29 17:32:21 briny kernel: Mapped at 0xfdfc0000
Jun 29 17:32:21 briny kernel: Found a Intrepid mac-io controller, rev: 0, mapped at 0xfdf40000
Jun 29 17:32:21 briny kernel: Processor NAP mode on idle enabled.
Jun 29 17:32:21 briny kernel: PowerMac motherboard: PowerBook G4 15"
Jun 29 17:32:21 briny kernel: via-pmu: Server Mode is disabled
Jun 29 17:32:21 briny kernel: PMU driver v2 initialized for Core99, firmware: 0c
Jun 29 17:32:21 briny kernel: Found UniNorth PCI host bridge at 0xf0000000. Firmware bus number: 0->1
Jun 29 17:32:21 briny kernel: Found UniNorth PCI host bridge at 0xf2000000. Firmware bus number: 0->1
Jun 29 17:32:21 briny kernel: Found UniNorth PCI host bridge at 0xf4000000. Firmware bus number: 0->1
Jun 29 17:32:21 briny kernel: nvram: Checking bank 0...
Jun 29 17:32:21 briny kernel: nvram: gen0=168, gen1=167
Jun 29 17:32:21 briny kernel: nvram: Active bank is: 0
Jun 29 17:32:21 briny kernel: nvram: OF partition at 0x410
Jun 29 17:32:21 briny kernel: nvram: XP partition at 0x1020
Jun 29 17:32:21 briny kernel: nvram: NR partition at 0x1120
Jun 29 17:32:21 briny kernel: Top of RAM: 0x40000000, Total RAM: 0x40000000
Jun 29 17:32:21 briny kernel: Memory hole size: 0MB
Jun 29 17:32:21 briny kernel: On node 0 totalpages: 262144
Jun 29 17:32:21 briny kernel:   DMA zone: 196608 pages, LIFO batch:31
Jun 29 17:32:21 briny kernel:   HighMem zone: 65536 pages, LIFO batch:15
Jun 29 17:32:21 briny kernel: Built 1 zonelists.  Total pages: 262144
Jun 29 17:32:21 briny kernel: Kernel command line: root=/dev/hda3 ro 
Jun 29 17:32:21 briny kernel: mpic: Setting up MPIC " MPIC 1   " version 1.2 at 80040000, max 4 CPUs
Jun 29 17:32:21 briny kernel: mpic: ISU size: 64, shift: 6, mask: 3f
Jun 29 17:32:21 briny kernel: mpic: Initializing for 64 sources
Jun 29 17:32:21 briny kernel: PID hash table entries: 4096 (order: 12, 16384 bytes)
Jun 29 17:32:21 briny kernel: GMT Delta read from XPRAM: 0 minutes, DST: off
Jun 29 17:32:21 briny kernel: time_init: decrementer frequency = 18.432000 MHz
Jun 29 17:32:21 briny kernel: time_init: processor frequency   = 1499.999994 MHz
Jun 29 17:32:21 briny kernel: Console: colour dummy device 80x25
Jun 29 17:32:21 briny kernel: Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Jun 29 17:32:21 briny kernel: Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Jun 29 17:32:21 briny kernel: High memory: 262144k
Jun 29 17:32:21 briny kernel: Memory: 1032272k/1048576k available (3556k kernel code, 277880k reserved, 304k data, 392k bss, 164k init)
Jun 29 17:32:21 briny kernel: Calibrating delay loop... 36.73 BogoMIPS (lpj=73472)
Jun 29 17:32:21 briny kernel: Mount-cache hash table entries: 512
Jun 29 17:32:21 briny kernel: device-tree: Duplicate name in /cpus/PowerPC,G4@0, renamed to "l2-cache#1"
Jun 29 17:32:21 briny kernel: NET: Registered protocol family 16
Jun 29 17:32:21 briny kernel: KeyWest i2c @0xf8001003 irq 42 /uni-n@f8000000/i2c@f8001000
Jun 29 17:32:21 briny kernel:  channel 0 bus <multibus>
Jun 29 17:32:21 briny kernel:  channel 1 bus <multibus>
Jun 29 17:32:21 briny kernel: KeyWest i2c @0x80018000 irq 26 /pci@f2000000/mac-io@17/i2c@18000
Jun 29 17:32:21 briny kernel:  channel 0 bus <multibus>
Jun 29 17:32:21 briny kernel: PMU i2c /pci@f2000000/mac-io@17/via-pmu@16000/pmu-i2c
Jun 29 17:32:21 briny kernel:  channel 1 bus <multibus>
Jun 29 17:32:21 briny kernel:  channel 2 bus <multibus>
Jun 29 17:32:21 briny kernel: PCI: Probing PCI hardware
Jun 29 17:32:21 briny kernel: Can't get bus-range for /pci@f2000000/cardbus@13, assuming it starts at 0
Jun 29 17:32:21 briny kernel: PCI: Cannot allocate resource region 0 of device 0001:10:18.0
Jun 29 17:32:21 briny kernel: PCI: Cannot allocate resource region 0 of device 0001:10:19.0
Jun 29 17:32:21 briny kernel: Apple USB OHCI 0001:10:18.0 disabled by firmware
Jun 29 17:32:21 briny kernel: Apple USB OHCI 0001:10:19.0 disabled by firmware
Jun 29 17:32:21 briny kernel: SCSI subsystem initialized
Jun 29 17:32:21 briny kernel: usbcore: registered new driver usbfs
Jun 29 17:32:21 briny kernel: usbcore: registered new driver hub
Jun 29 17:32:21 briny kernel: Bluetooth: Core ver 2.10
Jun 29 17:32:21 briny kernel: NET: Registered protocol family 31
Jun 29 17:32:21 briny kernel: Bluetooth: HCI device and connection manager initialized
Jun 29 17:32:21 briny kernel: Bluetooth: HCI socket layer initialized
Jun 29 17:32:21 briny kernel: NET: Registered protocol family 2
Jun 29 17:32:21 briny kernel: IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
Jun 29 17:32:21 briny kernel: TCP established hash table entries: 131072 (order: 7, 524288 bytes)
Jun 29 17:32:21 briny kernel: TCP bind hash table entries: 65536 (order: 6, 262144 bytes)
Jun 29 17:32:21 briny kernel: TCP: Hash tables configured (established 131072 bind 65536)
Jun 29 17:32:21 briny kernel: TCP reno registered
Jun 29 17:32:21 briny kernel: Registering PowerMac CPU frequency driver
Jun 29 17:32:21 briny kernel: Low: 749 Mhz, High: 1499 Mhz, Boot: 749 Mhz
Jun 29 17:32:21 briny kernel: highmem bounce pool size: 64 pages
Jun 29 17:32:21 briny kernel: fuse init (API version 7.7)
Jun 29 17:32:21 briny kernel: Installing v9fs 9P2000 file system support
Jun 29 17:32:21 briny kernel: Initializing Cryptographic API
Jun 29 17:32:21 briny kernel: io scheduler noop registered
Jun 29 17:32:21 briny kernel: io scheduler anticipatory registered
Jun 29 17:32:21 briny kernel: io scheduler deadline registered
Jun 29 17:32:21 briny kernel: io scheduler cfq registered (default)
Jun 29 17:32:21 briny kernel: PCI: Enabling device 0000:00:10.0 (0006 -> 0007)
Jun 29 17:32:21 briny kernel: radeonfb (0000:00:10.0): Invalid ROM signature 303 should be 0xaa55
Jun 29 17:32:22 briny kernel: radeonfb: Retrieved PLL infos from Open Firmware
Jun 29 17:32:22 briny kernel: radeonfb: Reference=27.00 MHz (RefDiv=12) Memory=203.00 Mhz, System=392.00 MHz
Jun 29 17:32:22 briny kernel: radeonfb: PLL min 12000 max 35000
Jun 29 17:32:22 briny kernel: radeonfb: Monitor 1 type LCD found
Jun 29 17:32:22 briny kernel: radeonfb: EDID probed
Jun 29 17:32:22 briny kernel: radeonfb: Monitor 2 type no found
Jun 29 17:32:22 briny kernel: radeonfb: Using Firmware dividers 0x0002008e from PPLL 0
Jun 29 17:32:22 briny kernel: radeonfb: Dynamic Clock Power Management enabled
Jun 29 17:32:22 briny kernel: Console: switching to colour frame buffer device 106x35
Jun 29 17:32:22 briny kernel: radeonfb: Backlight initialized (radeonbl0)
Jun 29 17:32:22 briny kernel: radeonfb (0000:00:10.0): ATI Radeon NP 
Jun 29 17:32:22 briny kernel: Generic RTC Driver v1.07
Jun 29 17:32:22 briny kernel: Macintosh non-volatile memory driver v1.1
Jun 29 17:32:22 briny kernel: Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
Jun 29 17:32:22 briny kernel: loop: loaded (max 8 devices)
Jun 29 17:32:22 briny kernel: sungem.c:v0.98 8/24/03 David S. Miller (davem@redhat.com)
Jun 29 17:32:22 briny kernel: PHY ID: 1410cc1, addr: 0
Jun 29 17:32:22 briny kernel: eth0: Sun GEM (PCI) 10/100/1000BaseT Ethernet 00:0d:93:2f:59:34 
Jun 29 17:32:22 briny kernel: eth0: Found Marvell 88E1101 PHY
Jun 29 17:32:22 briny kernel: tun: Universal TUN/TAP device driver, 1.6
Jun 29 17:32:22 briny kernel: tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
Jun 29 17:32:22 briny kernel: MacIO PCI driver attached to Intrepid chipset
Jun 29 17:32:22 briny kernel: input: Macintosh mouse button emulation as /class/input/input0
Jun 29 17:32:22 briny kernel: apm_emu: APM Emulation 0.5 initialized.
Jun 29 17:32:22 briny kernel: adb: starting probe task...
Jun 29 17:32:22 briny kernel: adt746x: version 1 (supported)
Jun 29 17:32:22 briny kernel: adt746x: Thermostat bus: 1, address: 0x2e, limit_adjust: 0, fan_speed: -1
Jun 29 17:32:22 briny kernel: sensor 0: CPU/INTREPID BOTTOMSIDE
Jun 29 17:32:22 briny kernel: sensor 1: CPU BOTTOMSIDE
Jun 29 17:32:22 briny kernel: sensor 2: PWR SUPPLY BOTTOMSIDE
Jun 29 17:32:22 briny kernel: Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
Jun 29 17:32:22 briny kernel: ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
Jun 29 17:32:22 briny kernel: PCI: Enabling device 0002:24:0d.0 (0000 -> 0002)
Jun 29 17:32:22 briny kernel: adb devices: [2]: 2 c3 [3]: 3 1 [7]: 7 1f
Jun 29 17:32:22 briny kernel: ADB keyboard at 2, handler 1
Jun 29 17:32:22 briny kernel: Detected ADB keyboard, type ANSI.
Jun 29 17:32:22 briny kernel: input: ADB keyboard as /class/input/input1
Jun 29 17:32:22 briny kernel: input: ADB Powerbook buttons as /class/input/input2
Jun 29 17:32:22 briny kernel: ADB mouse at 3, handler set to 4 (trackpad)
Jun 29 17:32:22 briny kernel: input: ADB mouse as /class/input/input3
Jun 29 17:32:22 briny kernel: adb: finished probe task...
Jun 29 17:32:22 briny kernel: ide0: Found Apple UniNorth ATA-6 controller, bus ID 3, irq 39
Jun 29 17:32:22 briny kernel: Probing IDE interface ide0...
Jun 29 17:32:22 briny kernel: hda: HTS541080G9AT00, ATA DISK drive
Jun 29 17:32:22 briny kernel: hda: Enabling Ultra DMA 5
Jun 29 17:32:22 briny kernel: ide0 at 0xf1012000-0xf1012007,0xf1012160 on irq 39
Jun 29 17:32:22 briny kernel: ide1: Found Apple KeyLargo ATA-3 controller, bus ID 0, irq 24
Jun 29 17:32:22 briny kernel: Probing IDE interface ide1...
Jun 29 17:32:22 briny kernel: hdc: MATSHITACD-RW CW-8123, ATAPI CD/DVD-ROM drive
Jun 29 17:32:22 briny kernel: hdc: Enabling MultiWord DMA 2
Jun 29 17:32:22 briny kernel: ide1 at 0xf1006000-0xf1006007,0xf1006160 on irq 24
Jun 29 17:32:22 briny kernel: hda: max request size: 512KiB
Jun 29 17:32:22 briny kernel: hda: 156301488 sectors (80026 MB) w/7539KiB Cache, CHS=16383/255/63, UDMA(100)
Jun 29 17:32:22 briny kernel: hda: cache flushes supported
Jun 29 17:32:22 briny kernel:  hda: [mac] hda1 hda2 hda3 hda4 hda5 hda6 hda7
Jun 29 17:32:22 briny kernel: hdc: ATAPI 24X DVD-ROM CD-R/RW drive, 2048kB Cache, (U)DMA
Jun 29 17:32:22 briny kernel: Uniform CD-ROM driver Revision: 3.20
Jun 29 17:32:22 briny kernel: Initializing USB Mass Storage driver...
Jun 29 17:32:22 briny kernel: usbcore: registered new driver usb-storage
Jun 29 17:32:22 briny kernel: USB Mass Storage support registered.
Jun 29 17:32:22 briny kernel: usbcore: registered new driver hiddev
Jun 29 17:32:22 briny kernel: usbcore: registered new driver usbhid
Jun 29 17:32:22 briny kernel: drivers/usb/input/hid-core.c: v2.6:USB HID core driver
Jun 29 17:32:22 briny kernel: mice: PS/2 mouse device common for all mice
Jun 29 17:32:22 briny kernel: i2c /dev entries driver
Jun 29 17:32:22 briny kernel: PowerMac i2c bus pmu 2 registered
Jun 29 17:32:22 briny kernel: PowerMac i2c bus pmu 1 registered
Jun 29 17:32:22 briny kernel: PowerMac i2c bus mac-io 0 registered
Jun 29 17:32:22 briny kernel: adt746x: ADT7460 initializing
Jun 29 17:32:22 briny kernel: adt746x: Lowering max temperatures from 81, 80, 87 to 70, 50, 70
Jun 29 17:32:22 briny kernel: PowerMac i2c bus uni-n 1 registered
Jun 29 17:32:22 briny kernel: PowerMac i2c bus uni-n 0 registered
Jun 29 17:32:22 briny kernel: device-mapper: ioctl: 4.7.0-ioctl (2006-06-24) initialised: dm-devel@redhat.com
Jun 29 17:32:22 briny kernel: Advanced Linux Sound Architecture Driver Version 1.0.12rc1 (Thu Jun 22 13:55:50 2006 UTC).
Jun 29 17:32:22 briny kernel: ALSA device list:
Jun 29 17:32:22 briny kernel:   No soundcards found.
Jun 29 17:32:22 briny kernel: GRE over IPv4 tunneling driver
Jun 29 17:32:22 briny kernel: TCP bic registered
Jun 29 17:32:22 briny kernel: TCP cubic registered
Jun 29 17:32:22 briny kernel: TCP westwood registered
Jun 29 17:32:22 briny kernel: TCP highspeed registered
Jun 29 17:32:22 briny kernel: TCP hybla registered
Jun 29 17:32:22 briny kernel: TCP htcp registered
Jun 29 17:32:22 briny kernel: TCP vegas registered
Jun 29 17:32:22 briny kernel: TCP veno registered
Jun 29 17:32:22 briny kernel: TCP scalable registered
Jun 29 17:32:22 briny kernel: TCP compound registered
Jun 29 17:32:22 briny kernel: NET: Registered protocol family 1
Jun 29 17:32:22 briny kernel: NET: Registered protocol family 17
Jun 29 17:32:22 briny kernel: Bluetooth: L2CAP ver 2.8
Jun 29 17:32:22 briny kernel: Bluetooth: L2CAP socket layer initialized
Jun 29 17:32:22 briny kernel: Bluetooth: RFCOMM socket layer initialized
Jun 29 17:32:22 briny kernel: Bluetooth: RFCOMM TTY layer initialized
Jun 29 17:32:22 briny kernel: Bluetooth: RFCOMM ver 1.7
Jun 29 17:32:22 briny kernel: Bluetooth: HIDP (Human Interface Emulation) ver 1.1-mh1
Jun 29 17:32:22 briny kernel: input: PMU as /class/input/input4
Jun 29 17:32:22 briny kernel: kjournald starting.  Commit interval 5 seconds
Jun 29 17:32:22 briny kernel: EXT3-fs: mounted filesystem with ordered data mode.
Jun 29 17:32:22 briny kernel: VFS: Mounted root (ext3 filesystem) readonly.
Jun 29 17:32:22 briny kernel: Freeing unused kernel memory: 164k init
Jun 29 17:32:22 briny kernel: ohci_hcd: 2005 April 22 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
Jun 29 17:32:22 briny kernel: Apple USB OHCI 0001:10:18.0 disabled by firmware
Jun 29 17:32:22 briny kernel: Apple USB OHCI 0001:10:19.0 disabled by firmware
Jun 29 17:32:22 briny kernel: PCI: Enabling device 0001:10:1a.0 (0000 -> 0002)
Jun 29 17:32:22 briny kernel: ohci_hcd 0001:10:1a.0: OHCI Host Controller
Jun 29 17:32:22 briny kernel: ohci_hcd 0001:10:1a.0: new USB bus registered, assigned bus number 1
Jun 29 17:32:22 briny kernel: ohci_hcd 0001:10:1a.0: irq 29, io mem 0xa0003000
Jun 29 17:32:22 briny kernel: ieee80211_crypt: registered algorithm 'NULL'
Jun 29 17:32:22 briny kernel: ieee80211: 802.11 data/management/control stack, git-1.1.13
Jun 29 17:32:22 briny kernel: ieee80211: Copyright (C) 2004-2005 Intel Corporation <jketreno@linux.intel.com>
Jun 29 17:32:22 briny kernel: usb usb1: configuration #1 chosen from 1 choice
Jun 29 17:32:22 briny kernel: hub 1-0:1.0: USB hub found
Jun 29 17:32:22 briny kernel: hub 1-0:1.0: 2 ports detected
Jun 29 17:32:22 briny kernel: bcm43xx driver
Jun 29 17:32:22 briny kernel: Linux agpgart interface v0.101 (c) Dave Jones
Jun 29 17:32:22 briny kernel: agpgart: Detected Apple UniNorth 2 chipset
Jun 29 17:32:22 briny kernel: agpgart: configuring for size idx: 4
Jun 29 17:32:22 briny kernel: agpgart: AGP aperture is 16M @ 0x0
Jun 29 17:32:23 briny kernel: PCI: Enabling device 0001:10:1b.2 (0004 -> 0006)
Jun 29 17:32:23 briny kernel: ehci_hcd 0001:10:1b.2: EHCI Host Controller
Jun 29 17:32:23 briny kernel: ehci_hcd 0001:10:1b.2: new USB bus registered, assigned bus number 2
Jun 29 17:32:23 briny kernel: ehci_hcd 0001:10:1b.2: irq 63, io mem 0xa0000000
Jun 29 17:32:23 briny kernel: ehci_hcd 0001:10:1b.2: USB 2.0 started, EHCI 1.00, driver 10 Dec 2004
Jun 29 17:32:23 briny kernel: usb usb2: configuration #1 chosen from 1 choice
Jun 29 17:32:23 briny kernel: hub 2-0:1.0: USB hub found
Jun 29 17:32:23 briny kernel: hub 2-0:1.0: 5 ports detected
Jun 29 17:32:23 briny kernel: Yenta: CardBus bridge found at 0001:10:13.0 [0000:0000]
Jun 29 17:32:23 briny kernel: PCI: Bus 17, cardbus bridge: 0001:10:13.0
Jun 29 17:32:23 briny kernel:   IO window: 00001000-000011ff
Jun 29 17:32:24 briny kernel:   IO window: 00001400-000015ff
Jun 29 17:32:24 briny kernel:   PREFETCH window: 90000000-9fffffff
Jun 29 17:32:25 briny kernel:   MEM window: f3000000-f33fffff
Jun 29 17:32:25 briny kernel: Yenta: Enabling burst memory read transactions
Jun 29 17:32:25 briny kernel: Yenta: Using CSCINT to route CSC interrupts to PCI
Jun 29 17:32:26 briny kernel: Yenta: Routing CardBus interrupts to PCI
Jun 29 17:32:26 briny kernel: usb 1-1: new full speed USB device using ohci_hcd and address 2
Jun 29 17:32:26 briny kernel: Yenta TI: socket 0001:10:13.0, mfunc 0x00001002, devctl 0x60
Jun 29 17:32:26 briny kernel: Yenta: ISA IRQ mask 0x0000, PCI irq 53
Jun 29 17:32:27 briny kernel: Socket status: 30000087
Jun 29 17:32:27 briny kernel: pcmcia: parent PCI bridge I/O window: 0x0 - 0x7fffff
Jun 29 17:32:27 briny kernel: pcmcia: parent PCI bridge Memory window: 0xf3000000 - 0xf3ffffff
Jun 29 17:32:28 briny kernel: pcmcia: parent PCI bridge Memory window: 0x80000000 - 0xafffffff
Jun 29 17:32:28 briny kernel: PCI: Enabling device 0001:10:1b.0 (0000 -> 0002)
Jun 29 17:32:28 briny kernel: ohci_hcd 0001:10:1b.0: OHCI Host Controller
Jun 29 17:32:28 briny kernel: ohci_hcd 0001:10:1b.0: new USB bus registered, assigned bus number 3
Jun 29 17:32:28 briny kernel: ohci_hcd 0001:10:1b.0: irq 63, io mem 0xa0002000
Jun 29 17:32:28 briny kernel: usb 1-1: configuration #1 chosen from 1 choice
Jun 29 17:32:28 briny kernel: usb usb3: configuration #1 chosen from 1 choice
Jun 29 17:32:29 briny kernel: input: HID 05ac:1000 as /class/input/input5
Jun 29 17:32:29 briny kernel: input: USB HID v1.11 Keyboard [HID 05ac:1000] on usb-0001:10:1a.0-1
Jun 29 17:32:29 briny kernel: hub 3-0:1.0: USB hub found
Jun 29 17:32:29 briny kernel: hub 3-0:1.0: 3 ports detected
Jun 29 17:32:29 briny kernel: input: HID 05ac:1000 as /class/input/input6
Jun 29 17:32:29 briny kernel: input: USB HID v1.11 Mouse [HID 05ac:1000] on usb-0001:10:1a.0-1
Jun 29 17:32:29 briny kernel: PCI: Enabling device 0001:10:1b.1 (0000 -> 0002)
Jun 29 17:32:29 briny kernel: ohci_hcd 0001:10:1b.1: OHCI Host Controller
Jun 29 17:32:29 briny kernel: ohci_hcd 0001:10:1b.1: new USB bus registered, assigned bus number 4
Jun 29 17:32:29 briny kernel: ohci_hcd 0001:10:1b.1: irq 63, io mem 0xa0001000
Jun 29 17:32:29 briny kernel: usb usb4: configuration #1 chosen from 1 choice
Jun 29 17:32:30 briny kernel: hub 4-0:1.0: USB hub found
Jun 29 17:32:30 briny kernel: hub 4-0:1.0: 2 ports detected
Jun 29 17:32:30 briny kernel: PCI: Enabling device 0001:10:12.0 (0004 -> 0006)
Jun 29 17:32:30 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
Jun 29 17:32:30 briny kernel: bcm43xx: Number of cores: 5
Jun 29 17:32:30 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
Jun 29 17:32:30 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
Jun 29 17:32:30 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
Jun 29 17:32:30 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
Jun 29 17:32:30 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
Jun 29 17:32:30 briny kernel: bcm43xx: PHY connected
Jun 29 17:32:30 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
Jun 29 17:32:31 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
Jun 29 17:32:31 briny kernel: bcm43xx: Radio turned off
Jun 29 17:32:31 briny kernel: bcm43xx: Radio turned off
Jun 29 17:32:31 briny kernel: snd-aoa-fabric-layout: found bus with layout 51 (using)
Jun 29 17:32:32 briny kernel: snd-aoa-codec-tas: found 'deq' node
Jun 29 17:32:32 briny kernel: snd-aoa-fabric-layout: can use this codec
Jun 29 17:32:32 briny kernel: snd-aoa-codec-tas: created and attached tas instance
Jun 29 17:32:32 briny kernel: EXT3 FS on hda3, internal journal
Jun 29 17:32:33 briny kernel: Bluetooth: HCI USB driver ver 2.9
Jun 29 17:32:33 briny kernel: usbcore: registered new driver hci_usb
Jun 29 17:32:33 briny kernel: usbcore: registered new driver snd-usb-audio
Jun 29 17:32:33 briny kernel: [drm] Initialized drm 1.0.1 20051102
Jun 29 17:32:33 briny kernel: [drm] Initialized radeon 1.25.0 20060524 on minor 0
Jun 29 17:32:33 briny kernel: kjournald starting.  Commit interval 5 seconds
Jun 29 17:32:34 briny kernel: EXT3 FS on hda7, internal journal
Jun 29 17:32:34 briny kernel: EXT3-fs: mounted filesystem with ordered data mode.
Jun 29 17:32:34 briny kernel: kjournald starting.  Commit interval 5 seconds
Jun 29 17:32:34 briny kernel: EXT3 FS on hda4, internal journal
Jun 29 17:32:34 briny kernel: EXT3-fs: mounted filesystem with ordered data mode.
Jun 29 17:32:34 briny kernel: kjournald starting.  Commit interval 5 seconds
Jun 29 17:32:34 briny kernel: EXT3 FS on hda6, internal journal
Jun 29 17:32:35 briny kernel: EXT3-fs: mounted filesystem with ordered data mode.
Jun 29 17:32:35 briny kernel: Adding 1048568k swap on /dev/mapper/swap.  Priority:-1 extents:1 across:1048568k
Jun 29 17:32:35 briny kernel: usb 1-1: usbfs: USBDEVFS_CONTROL failed cmd hid2hci rqt 64 rq 0 len 0 ret -110
Jun 29 17:32:35 briny kernel: usb 1-1: USB disconnect, address 2
Jun 29 17:32:35 briny kernel: usb 1-1: new full speed USB device using ohci_hcd and address 3
Jun 29 17:32:35 briny kernel: usb 1-1: configuration #1 chosen from 1 choice
Jun 29 17:32:48 briny kernel: bcm43xx: PHY connected
Jun 29 17:32:49 briny kernel: bcm43xx: Radio turned on
Jun 29 17:32:49 briny kernel: bcm43xx: Chip initialized
Jun 29 17:32:49 briny kernel: bcm43xx: DMA initialized
Jun 29 17:32:49 briny kernel: bcm43xx: 80211 cores initialized
Jun 29 17:32:49 briny kernel: bcm43xx: Keys cleared
Jun 29 17:32:49 briny kernel: SoftMAC: Open Authentication completed with 00:04:ed:04:1b:96
Jun 29 17:32:55 briny kernel: bcm43xx: Radio turned off
Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0200 (RX) max used slots: 1/64
Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0260 (TX) max used slots: 0/512
Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0240 (TX) max used slots: 0/512
Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0220 (TX) max used slots: 1/512
Jun 29 17:32:55 briny kernel: bcm43xx: DMA 0x0200 (TX) max used slots: 0/512
Jun 29 17:32:56 briny kernel: bcm43xx: PHY connected
Jun 29 17:32:56 briny kernel: bcm43xx: Radio turned on
Jun 29 17:32:56 briny kernel: bcm43xx: Chip initialized
Jun 29 17:32:56 briny kernel: bcm43xx: DMA initialized
Jun 29 17:32:56 briny kernel: bcm43xx: 80211 cores initialized
Jun 29 17:32:56 briny kernel: bcm43xx: Keys cleared
Jun 29 17:33:14 briny kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
Jun 29 17:33:14 briny kernel: SoftMAC: Open Authentication completed with 00:04:ed:04:1b:96
Jun 29 17:33:22 briny kernel: bcm43xx: Radio turned off
Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0200 (RX) max used slots: 1/64
Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0260 (TX) max used slots: 0/512
Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0240 (TX) max used slots: 0/512
Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0220 (TX) max used slots: 1/512
Jun 29 17:33:22 briny kernel: bcm43xx: DMA 0x0200 (TX) max used slots: 0/512
Jun 29 17:33:27 briny kernel: bcm43xx: PHY connected
Jun 29 17:33:27 briny kernel: bcm43xx: Radio turned on
Jun 29 17:33:27 briny kernel: bcm43xx: Chip initialized
Jun 29 17:33:27 briny kernel: bcm43xx: DMA initialized
Jun 29 17:33:27 briny kernel: bcm43xx: 80211 cores initialized
Jun 29 17:33:27 briny kernel: bcm43xx: Keys cleared
Jun 29 17:33:31 briny kernel: bcm43xx: set security called, .level = 0, .enabled = 0, .encrypt = 0
Jun 29 17:33:31 briny kernel: SoftMAC: Open Authentication completed with 00:04:ed:04:1b:96
Jun 29 17:33:41 briny kernel: NETDEV WATCHDOG: eth1: transmit timed out
Jun 29 17:33:41 briny kernel: bcm43xx: Controller RESET (TX timeout) ...
Jun 29 17:33:41 briny kernel: bcm43xx: Chip ID 0x4306, rev 0x3
Jun 29 17:33:41 briny kernel: bcm43xx: Number of cores: 5
Jun 29 17:33:41 briny kernel: bcm43xx: Core 0: ID 0x800, rev 0x4, vendor 0x4243, enabled
Jun 29 17:33:41 briny kernel: bcm43xx: Core 1: ID 0x812, rev 0x5, vendor 0x4243, disabled
Jun 29 17:33:41 briny kernel: bcm43xx: Core 2: ID 0x80d, rev 0x2, vendor 0x4243, enabled
Jun 29 17:33:41 briny kernel: bcm43xx: Core 3: ID 0x807, rev 0x2, vendor 0x4243, disabled
Jun 29 17:33:41 briny kernel: bcm43xx: Core 4: ID 0x804, rev 0x9, vendor 0x4243, enabled
Jun 29 17:33:41 briny kernel: bcm43xx: PHY connected
Jun 29 17:33:41 briny kernel: bcm43xx: Detected PHY: Version: 2, Type 2, Revision 2
Jun 29 17:33:41 briny kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
Jun 29 17:33:41 briny kernel: bcm43xx: Radio turned off
Jun 29 17:33:41 briny kernel: bcm43xx: Radio turned off
Jun 29 17:33:41 briny kernel: bcm43xx: Controller restarted

-- 
Paul Collins
Melbourne, Australia

Dag vijandelijk luchtschip de huismeester is dood
