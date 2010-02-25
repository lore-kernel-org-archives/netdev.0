From: Martyn Welch <martyn.welch@ge.com>
Subject: Re: Gianfar driver failing on MPC8641D based board
Date: Thu, 25 Feb 2010 16:46:54 +0000
Message-ID: <4B86A97E.6050509@ge.com>
References: <4B6C2488.3060403@ge.com> <4B865176.7080806@ge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sandeep Gopalpet <Sandeep.Kumar@freescale.com>, davem@davemloft.net
To: linuxppc-dev list <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4B865176.7080806@ge.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Martyn Welch wrote:
> Martyn Welch wrote:
>   
>> I have recently attempted to boot an 8641D based board from an NFS root.
>> The boot process grinds to a halt not long after the first access of the
>> NFS root and I receive multiple "nfs: server 192.168.0.1 not responding,
>> still trying" messages. Wireshark suggests that there is no further
>> traffic from this board at this point on. The NFS server seems to
>> eventually try sending duplicate packets it's already sent, which
>> results in "nfs: server 192.168.0.1 OK" messages, but the "not
>> responding" messages resume with no further traffic from the board.
>>
>> I am able to boot to a ramdisk fine and the network seems to work -
>> though I haven't really pushed the interface from it.
>>
>> I have attempted to git bisect, though I wasn't able to get much further
>> than discovering the problem was introduced in the 2.6.33 merge window -
>> at which point the gianfar network driver fails to compile (I have tried
>> to git bisect skip many, many times to no avail).
>>
>> NFS booting fails for this board on todays linux-next, the master branch
>> of Kumar's PPC tree and the head of the main tree. I have also been able
>> to NFS boot from a random x86 based board that I have, using the head of
>> the main tree and the linux-next tree.
>>
>> Copying the gianfar drivers from 2.6.32 into the head of the main tree
>> restores the correct behaviour and I'm able to NFS boot. I have heard
>> from others that the latest drivers work on 83xx and 85xx based boards,
>> but it seems to be broken on at least the 8641D.
>>
>> I can see there has been a fair amount of work done on the gianfar
>> driver, I assume that this is a bug introduced by the multiple queue
>> support, but I'm way out of my depth on this.
>>   
>>     
> I have just compiled 2.6.33 for the Freescale MPC8641_HPCN demo board
> and am having still experiencing the problems outlined in my previous
> email, though I have noticed that I tend to be able to boot from cold,
> but my boot fails on reboot. Hitting the reset button doesn't help, I
> need to actually power the machine on and off again for it to work.
>
> As before, I'm way out of my depth in this, any one have any ideas?
> Below is a dump of the failed boot process:
>
> U-Boot 2009.01-00181-gc1b7c70 (Jan 30 2009 - 11:17:31)
>
> Freescale PowerPC
> CPU:
>     Core: E600 Core 0, Version: 0.2, (0x80040202)
>     System: Unknown, Version: 2.0, (0x80900120)
>     Clocks: CPU:1000 MHz, MPX: 400 MHz, DDR: 200 MHz, LBC:  25 MHz
>     L2: Enabled
> Board: MPC8641HPCN, System ID: 0x10, System Version: 0x10, FPGA Version:
> 0x22
> I2C:   ready
> DRAM:      DDR:  1 GB
> FLASH:  8 MB
> Invalid ID (ff ff ff ff)
>                Scanning PCI bus 01
>     PCI-EXPRESS 1 on bus 00 - 02
>     PCI-EXPRESS 2 on bus 03 - 03
> Video: No radeon video card found!
> In:    serial
> Out:   serial
> Err:   serial
> SCSI:  AHCI 0001.0000 32 slots 4 ports 3 Gbps 0xf impl IDE mode
> flags: ncq ilck pm led clo pmp pio slum part
> scanning bus for devices...
> Net:   eTSEC1, eTSEC2, eTSEC3, eTSEC4
> =>  tftp 4000000 hpcn/uImage-torvalds-linux-2.6
> Speed: 1000, full duplex
> Using eTSEC1 device
> TFTP from server 192.168.0.1; our IP address is 192.168.0.30
> Filename 'hpcn/uImage-torvalds-linux-2.6'.
> Load address: 0x4000000
> Loading: #################################################################
>          #################################################################
>          #######################################################
> done
> Bytes transferred = 2709050 (29563a hex)
> => tftp 5000000 hpcn/mpc8641_hpcn-torvalds-linux-2.6.dtb
> Speed: 1000, full duplex
> Using eTSEC1 device
> TFTP from server 192.168.0.1; our IP address is 192.168.0.30
> Filename 'hpcn/mpc8641_hpcn-torvalds-linux-2.6.dtb'.
> Load address: 0x5000000
> Loading: #
> done
> Bytes transferred = 11523 (2d03 hex)
> => setenv bootargs "root=/dev/nfs rw
> nfsroot=192.168.0.1:/tftpboot/hpcn/root/ i"
> => bootm 4000000 - 5000000
> WARNING: adjusting available memory to 10000000
> ## Booting kernel from Legacy Image at 04000000 ...
>    Image Name:   Linux-2.6.33-00001-gbaac35c
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    2708986 Bytes =  2.6 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
> ## Flattened Device Tree blob at 05000000
>    Booting using the fdt blob at 0x5000000
>    Uncompressing Kernel Image ... OK
>    Loading Device Tree to 007fa000, end 007ffd02 ... OK
> Using MPC86xx HPCN machine description
> Total memory = 1024MB; using 2048kB for hash table (at cfe00000)
> Linux version 2.6.33-00001-gbaac35c (welchma@ES-J7S4D2J) (gcc version
> 4.1.2) #20
> CPU maps initialized for 1 thread per core
> bootconsole [udbg0] enabled
> setup_arch: bootmem
> mpc86xx_hpcn_setup_arch()
> Found FSL PCI host bridge at 0x00000000ffe08000. Firmware bus number: 0->2
> PCI host bridge /pcie@ffe08000 (primary) ranges:
>  MEM 0x0000000080000000..0x000000009fffffff -> 0x0000000080000000
>   IO 0x00000000ffc00000..0x00000000ffc0ffff -> 0x0000000000000000
> /pcie@ffe08000: PCICSRBAR @ 0xfff00000
> Found FSL PCI host bridge at 0x00000000ffe09000. Firmware bus number: 0->0
> PCI host bridge /pcie@ffe09000  ranges:
>  MEM 0x00000000a0000000..0x00000000bfffffff -> 0x00000000a0000000
>   IO 0x00000000ffc10000..0x00000000ffc1ffff -> 0x0000000000000000
> /pcie@ffe09000: PCICSRBAR @ 0xfff00000
> MPC86xx HPCN board from Freescale Semiconductor
> arch: exit
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00030000
>   Normal   0x00030000 -> 0x00030000
>   HighMem  0x00030000 -> 0x00040000
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0: 0x00000000 -> 0x00040000
> PERCPU: Embedded 7 pages/cpu @c1003000 s7712 r8192 d12768 u65536
> pcpu-alloc: s7712 r8192 d12768 u65536 alloc=16*4096
> pcpu-alloc: [0] 0 [0] 1
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 260096
> Kernel command line: root=/dev/nfs rw
> nfsroot=192.168.0.1:/tftpboot/hpcn/root/ p
> PID hash table entries: 4096 (order: 2, 16384 bytes)
> Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
> Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
> Memory: 1030864k/1048576k available (5228k kernel code, 17004k reserved,
> 196k d)
> Kernel virtual memory layout:
>   * 0xfffc1000..0xfffff000  : fixmap
>   * 0xff800000..0xffc00000  : highmem PTEs
>   * 0xff7da000..0xff800000  : early ioremap
>   * 0xf1000000..0xff7da000  : vmalloc & ioremap
> SLUB: Genslabs=13, HWalign=32, Order=0-3, MinObjects=0, CPUs=2, Nodes=1
> Hierarchical RCU implementation.
> NR_IRQS:512 nr_irqs:512
> mpic: Setting up MPIC " MPIC     " version 1.2 at ffe40000, max 2 CPUs
> mpic: ISU size: 256, shift: 8, mask: ff
> mpic: Initializing for 256 sources
> i8259 legacy interrupt controller initialized
> clocksource: timebase mult[2800000] shift[22] registered
> Console: colour dummy device 80x25
> Mount-cache hash table entries: 512
> mpic: requesting IPIs ...
> Processor 1 found.
> Brought up 2 CPUs
> NET: Registered protocol family 16
>             
> PCI: Probing PCI hardware
> pci 0000:00:00.0: ignoring class b20 (doesn't match header type 01)
> pci 0000:00:00.0: PCI bridge to [bus 01-ff]
> pci 0000:02:1d.0: unsupported PM cap regs version (4)
> pci 0000:01:00.0: PCI bridge to [bus 02-ff] (subtractive decode)
> pci 0001:03:00.0: ignoring class b20 (doesn't match header type 01)
> pci 0001:03:00.0: PCI bridge to [bus 04-ff]
> pci 0000:01:00.0: PCI bridge to [bus 02-02]
> pci 0000:01:00.0:   bridge window [io  0x1000-0x1fff]
> pci 0000:01:00.0:   bridge window [mem 0x80000000-0x800fffff]
> pci 0000:01:00.0:   bridge window [mem pref disabled]
> pci 0000:00:00.0: PCI bridge to [bus 01-02]
> pci 0000:00:00.0:   bridge window [io  0x0000-0xffff]
> pci 0000:00:00.0:   bridge window [mem 0x80000000-0x9fffffff]
> pci 0000:00:00.0:   bridge window [mem pref disabled]
> pci 0000:00:00.0: enabling device (0106 -> 0107)
> pci 0001:03:00.0: PCI bridge to [bus 04-04]
> pci 0001:03:00.0:   bridge window [io  0xfffee000-0xffffdfff]
> pci 0001:03:00.0:   bridge window [mem 0xa0000000-0xbfffffff]
> pci 0001:03:00.0:   bridge window [mem pref disabled]
> pci 0001:03:00.0: enabling device (0106 -> 0107)
> bio: create slab <bio-0> at 0
> vgaarb: loaded
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Advanced Linux Sound Architecture Driver Version 1.0.21.
> Switching to clocksource timebase
> NET: Registered protocol family 2
> IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
> TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
> TCP: Hash tables configured (established 131072 bind 65536)
> TCP reno registered
> UDP hash table entries: 512 (order: 2, 16384 bytes)
> UDP-Lite hash table entries: 512 (order: 2, 16384 bytes)
> NET: Registered protocol family 1
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> RPC: Registered tcp NFSv4.1 backchannel transport module.
> audit: initializing netlink socket (disabled)
> type=2000 audit(0.144:1): initialized
> highmem bounce pool size: 64 pages
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> NTFS driver 2.1.29 [Flags: R/O].
> msgmni has been set to 1502
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Generic non-volatile memory driver v1.1
> Serial: 8250/16550 driver, 2 ports, IRQ sharing enabled
> serial8250.0: ttyS0 at MMIO 0xffe04500 (irq = 42) is a 16550A
> console [ttyS0] enabled, bootconsole disabled
> console [ttyS0] enabled, bootconsole disabled
> serial8250.0: ttyS1 at MMIO 0xffe04600 (irq = 28) is a 16550A
> brd: module loaded
> loop: module loaded
> nbd: registered device at major 43
> st: Version 20081215, fixed bufsize 32768, s/g segs 256
> ahci 0000:02:1f.1: AHCI 0001.0000 32 slots 4 ports 3 Gbps 0xf impl SATA mode
> ahci 0000:02:1f.1: flags: ncq sntf ilck pm led clo pmp pio slum part
> scsi0 : ahci
> scsi1 : ahci
> scsi2 : ahci
> scsi3 : ahci
> ata1: SATA max UDMA/133 abar m1024@0x80006000 port 0x80006100 irq 5
> ata2: SATA max UDMA/133 abar m1024@0x80006000 port 0x80006180 irq 5
> ata3: SATA max UDMA/133 abar m1024@0x80006000 port 0x80006200 irq 5
> ata4: SATA max UDMA/133 abar m1024@0x80006000 port 0x80006280 irq 5
> scsi4 : pata_ali
> scsi5 : pata_ali
> ata5: PATA max UDMA/133 cmd 0x1200 ctl 0x1208 bmdma 0x1220 irq 14
> ata6: PATA max UDMA/133 cmd 0x1210 ctl 0x1218 bmdma 0x1228 irq 14
> eth0: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:00:01
> eth0: Running with NAPI enabled
> eth0: :RX BD ring size for Q[0]: 256
> eth0:TX BD ring size for Q[0]: 256
> eth1: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:01:fd
> eth1: Running with NAPI enabled
> eth1: :RX BD ring size for Q[0]: 256
> eth1:TX BD ring size for Q[0]: 256
> eth2: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:02:fd
> eth2: Running with NAPI enabled
> eth2: :RX BD ring size for Q[0]: 256
> eth2:TX BD ring size for Q[0]: 256
> eth3: Gianfar Ethernet Controller Version 1.2, 00:e0:0c:00:03:fd
> eth3: Running with NAPI enabled
> eth3: :RX BD ring size for Q[0]: 256
> eth3:TX BD ring size for Q[0]: 256
> Freescale PowerQUICC MII Bus: probed
> Freescale PowerQUICC MII Bus: probed
> Freescale PowerQUICC MII Bus: probed
> Freescale PowerQUICC MII Bus: probed
> usbmon: debugfs is not available
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> ehci_hcd 0000:02:1c.3: EHCI Host Controller
> ehci_hcd 0000:02:1c.3: new USB bus registered, assigned bus number 1
> ehci_hcd 0000:02:1c.3: debug port 1
> ehci_hcd 0000:02:1c.3: Enabling legacy PCI PM
> ehci_hcd 0000:02:1c.3: irq 11, io mem 0x80003000
> ehci_hcd 0000:02:1c.3: USB 2.0 started, EHCI 1.00
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 8 ports detected
> ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
> ohci_hcd 0000:02:1c.0: OHCI Host Controller
> ata5.00: ATAPI: SONY    DVD RW AW-Q170A, 1.73, max UDMA/66
> ata5.00: WARNING: ATAPI DMA disabled for reliability issues.  It can be
> enabled
> ata5.00: WARNING: via pata_ali.atapi_dma modparam or corresponding sysfs
> node.
> ata5.00: configured for UDMA/66
> ohci_hcd 0000:02:1c.0: new USB bus registered, assigned bus number 2
> ohci_hcd 0000:02:1c.0: irq 12, io mem 0x80000000
> hub 2-0:1.0: USB hub found
> hub 2-0:1.0: 3 ports detected
> ohci_hcd 0000:02:1c.1: OHCI Host Controller
> ohci_hcd 0000:02:1c.1: new USB bus registered, assigned bus number 3
> ohci_hcd 0000:02:1c.1: irq 9, io mem 0x80001000
> ata3: SATA link down (SStatus 0 SControl 300)
> ata1: SATA link down (SStatus 0 SControl 300)
> ata4: SATA link down (SStatus 0 SControl 300)
> ata2: SATA link down (SStatus 0 SControl 300)
> hub 3-0:1.0: USB hub found
> hub 3-0:1.0: 3 ports detected
> ohci_hcd 0000:02:1c.2: OHCI Host Controller
> ohci_hcd 0000:02:1c.2: new USB bus registered, assigned bus number 4
> scsi 4:0:0:0: CD-ROM            SONY     DVD RW AW-Q170A  1.73 PQ: 0 ANSI: 5
> ohci_hcd 0000:02:1c.2: irq 10, io mem 0x80002000
> sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
> Uniform CD-ROM driver Revision: 3.20
> sr 4:0:0:0: Attached scsi generic sg0 type 5
> hub 4-0:1.0: USB hub found
> hub 4-0:1.0: 3 ports detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i8042.c: No controller found.
> rtc_cmos rtc_cmos: rtc core: registered rtc_cmos as rtc0
> rtc0: alarms up to one day, 114 bytes nvram
> usbcore: registered new interface driver usbhid
> usbhid: USB HID core driver
> intel8x0_measure_ac97_clock: measured 50231 usecs (2424 samples)
> intel8x0: clocking to 48000
> ALSA device list:
>   #0: ALi M5455 with ALC650F at irq 6
> IPv4 over IPv4 tunneling driver
> GRE over IPv4 tunneling driver
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 10
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> rtc_cmos rtc_cmos: setting system clock to 2002-03-11 18:46:05 UTC
> (1015872365)
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> ADDRCONF(NETDEV_UP): eth1: link is not ready
> ADDRCONF(NETDEV_UP): eth2: link is not ready
> ADDRCONF(NETDEV_UP): eth3: link is not ready
> Sending DHCP requests .
> PHY: mdio@ffe24520:00 - Link is Up - 1000/Full
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> ., OK
> IP-Config: Got DHCP answer from 192.168.0.1, my address is 192.168.0.241
> IP-Config: Complete:
>      device=eth0, addr=192.168.0.241, mask=255.255.255.0, gw=192.168.0.1,
>      host=192.168.0.241, domain=Radstone.Local, nis-domain=(none),
>      bootserver=192.168.0.1, rootserver=192.168.0.1, rootpath=
> Looking up port of RPC 100003/2 on 192.168.0.1
> Looking up port of RPC 100005/1 on 192.168.0.1
> VFS: Mounted root (nfs filesystem) on device 0:13.
> Freeing unused kernel memory: 220k init
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
> nfs: server 192.168.0.1 not responding, still trying
>   

Further testing has shown that this isn't restricted to warm reboots, it
happens from cold as well. In addition, the exact timing of the failure
seems to vary, some boots have got further before failing.

Martyn

-- 
Martyn Welch (Principal Software Engineer)   |   Registered in England and
GE Intelligent Platforms                     |   Wales (3828642) at 100
T +44(0)127322748                            |   Barbirolli Square, Manchester,
E martyn.welch@ge.com                        |   M2 3AB  VAT:GB 927559189
