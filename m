From: =?ISO-8859-1?Q?R=E9gis_Odey=E9?= <regis.odeye@kontron.com>
Subject: Re: [HELP] BAD interrupts
Date: Thu, 31 Dec 2009 09:12:01 +0100
Message-ID: <4B3C5CD1.2040308@kontron.com>
References: <9F4C7D19E8361D4C94921B95BE08B81BA09038@zin33exm22.fsl.freescale.net>	<1261608230.3401.16.camel@concordia>	<4B335491.1020203@alcatel-lucent.com>
	<9F4C7D19E8361D4C94921B95BE08B81BA0905B@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: gshan <gshan@alcatel-lucent.com>, avorontsov@ru.mvista.com,
	linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA0905B@zin33exm22.fsl.freescale.net>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hi,

We experimented something similar with a 8641D board. =

This seems to come from the gianfar and:
- when we are binding the three interruptions enet_tx, enet_rx and =

enet_err of each interfaces on the same processor, the BAD interruptions =

do not increase any more.
- when we are compiling the driver without the NAPI mode, there is no =

more BAD interruptions at all.

Hope it will help even if we did not find a real fix.

Regards.
R=E9gis.

Kumar Gopalpet-B05799 wrote:
>  =

>
>   =

>> -----Original Message-----
>> From: gshan [mailto:gshan@alcatel-lucent.com] =

>> Sent: Thursday, December 24, 2009 5:16 PM
>> To: michael@ellerman.id.au
>> Cc: Kumar Gopalpet-B05799; netdev@vger.kernel.org; =

>> linuxppc-dev@lists.ozlabs.org
>> Subject: Re: [HELP] BAD interrupts
>>
>> Michael Ellerman wrote:
>>     =

>>> On Wed, 2009-12-23 at 19:41 +0530, Kumar Gopalpet-B05799 wrote:
>>>   =

>>>       =

>>>> Hi all,
>>>>  =

>>>> I am trying linux 2.6.32-rc3 in SMP mode. I am seeing a lot of BAD =

>>>> interrupts when I do a "cat  /proc/interrupts".
>>>>  =

>>>> I am running a forwarding application b/w two ethernet ports =

>>>> (ethernet uses gianfar driver).
>>>>  =

>>>> Has any one observed these BAD interrupts ? If so, can someone help =

>>>> me in understanding why these interrupts come and how to =

>>>>         =

>> resolve it ?
>>     =

>>>>     =

>>>>         =

>>> You'll need to tell us what platform you're running on.
>>>
>>> The BAD interrupts come from ppc_spurious_interrupts. It's a =

>>>       =

>> count of =

>>     =

>>> the number of times we entered do_IRQ() (ie. took an external =

>>> interrupt), but when we asked the interrupt controller which irq it =

>>> was, the interrupt controller said there was no irq.
>>>
>>> Depending on your interrupt controller that might happen =

>>>       =

>> sometimes for =

>>     =

>>> valid reasons. Or it might indicate something is setup wrong.
>>>
>>> cheers
>>>   =

>>>       =

>> I think it will help to show us your /proc/interrupts so that =

>> how you suffered from bad interrupts.
>>
>>     =

>
> I am running linux-2.6.29 in SMP mode on P2020RDB ( ruuning at
> 1200/600/667). The test scenario forwarding =

> application and is a bidirectioanl flow between eth0 & eth2.
>
> Attached is the complete log of the test scenario.
>
> I also noted another observation that when all the interrupts are mapped
> to a single core, the BAD interrupts stop coming.
>
> --
>
> Thanks
> Sandeep =

>
>   =

> ------------------------------------------------------------------------
>
> tftp 1000000 etsec2/uImage_alpha
> Speed: 1000, full duplex
> Using eTSEC1 device
> TFTP from server 10.232.134.194; our IP address is 10.232.133.188
> Filename 'etsec2/uImage_alpha'.
> Load address: 0x1000000
> Loading: *=08############################################################=
#####
> 	 #################################################################
> 	 ###################################################
> done
> Bytes transferred =3D 2654090 (287f8a hex)
> =3D> tftp 2000000 etsec2/rf=08 =08ootfs_alpha
> Speed: 1000, full duplex
> Using eTSEC1 device
> TFTP from server 10.232.134.194; our IP address is 10.232.133.188
> Filename 'etsec2/rootfs_alpha'.
> Load address: 0x2000000
> Loading: *=08############################################################=
#####
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #################################################################
> 	 #####
> done
> Bytes transferred =3D 26776875 (198952b hex)
> =3D> tftp c00000 etsec2/p2020alpha.dtb
> Speed: 1000, full duplex
> Using eTSEC1 device
> TFTP from server 10.232.134.194; our IP address is 10.232.133.188
> Filename 'etsec2/p2020alpha.dtb'.
> Load address: 0xc00000
> Loading: *=08#
> done
> Bytes transferred =3D 10579 (2953 hex)
> =3D> bootm 1000000 2000000 c00000
> WARNING: adjusting available memory to 30000000
> ## Booting kernel from Legacy Image at 01000000 ...
>    Image Name:   Linux-2.6.29
>    Created:      2009-07-03   9:42:06 UTC
>    Image Type:   PowerPC Linux Kernel Image (gzip compressed)
>    Data Size:    2654026 Bytes =3D  2.5 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
> ## Loading init Ramdisk from Legacy Image at 02000000 ...
>    Image Name:   uboot ext2 ramdisk rootfs
>    Created:      2009-07-04   8:24:27 UTC
>    Image Type:   PowerPC Linux RAMDisk Image (gzip compressed)
>    Data Size:    26776811 Bytes =3D 25.5 MB
>    Load Address: 00000000
>    Entry Point:  00000000
>    Verifying Checksum ... OK
> ## Flattened Device Tree blob at 00c00000
>    Booting using the fdt blob at 0xc00000
>    Uncompressing Kernel Image ... OK
>    Loading Ramdisk to 2e676000, end 2ffff4eb ... OK
> Using P2020 RDB machine description
> Memory CAM mapping: CAM0=3D256Mb, CAM1=3D256Mb, CAM2=3D256Mb residual: 25=
6Mb
> Linux version 2.6.29 (dipen@uTeam3.ap.freescale.net) (gcc version 4.3.2 (=
GCC) ) #1 SMP Fri Jul 3 15:11:50 IST 2009
> Found initrd at 0xee676000:0xeffff4eb
> CPU maps initialized for 1 thread per core
> console [udbg0] enabled
> setup_arch: bootmem
> mpc85xx_rdb_setup_arch()
> Found FSL PCI host bridge at 0x00000000ffe09000. Firmware bus number: 0->=
255
> PCI host bridge /pcie@ffe09000  ranges:
>  MEM 0x00000000a0000000..0x00000000bfffffff -> 0x00000000a0000000 =

>   IO 0x00000000ffc30000..0x00000000ffc3ffff -> 0x0000000000000000
> Found FSL PCI host bridge at 0x00000000ffe0a000. Firmware bus number: 0->=
255
> PCI host bridge /pcie@ffe0a000  ranges:
>  MEM 0x00000000c0000000..0x00000000dfffffff -> 0x00000000c0000000 =

>   IO 0x00000000ffc20000..0x00000000ffc2ffff -> 0x0000000000000000
> MPC85xx RDB board from Freescale Semiconductor
> arch: exit
> Zone PFN ranges:
>   DMA      0x00000000 -> 0x00030000
>   Normal   0x00030000 -> 0x00030000
>   HighMem  0x00030000 -> 0x00040000
> Movable zone start PFN for each node
> early_node_map[1] active PFN ranges
>     0: 0x00000000 -> 0x00040000
> MMU: Allocated 1088 bytes of context maps for 255 contexts
> Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 2600=
96
> Kernel command line: root=3D/dev/ram rw console=3DttyS0,115200 ramdisk_si=
ze=3D275000 cache-sram-size=3D0x10000
> mpic: Setting up MPIC " OpenPIC  " version 1.2 at ffe40000, max 2 CPUs
> mpic: ISU size: 256, shift: 8, mask: ff
> mpic: Initializing for 256 sources
> PID hash table entries: 4096 (order: 12, 16384 bytes)
> clocksource: timebase mult[3555555] shift[22] registered
> Console: colour dummy device 80x25
> Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
> Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
> Memory: 1007184k/1048576k available (5180k kernel code, 40848k reserved, =
164k data, 134k bss, 216k init)
> SLUB: Genslabs=3D12, HWalign=3D32, Order=3D0-3, MinObjects=3D0, CPUs=3D2,=
 Nodes=3D1
> Calibrating delay loop... 149.50 BogoMIPS (lpj=3D299008)
> Mount-cache hash table entries: 512
> mpic: requesting IPIs ... =

> Processor 1 found.
> Brought up 2 CPUs
> net_namespace: 732 bytes
> NET: Registered protocol family 16
>              =

> PCI: Probing PCI hardware
> pci 0000:00:00.0: ignoring class b20 (doesn't match header type 01)
> pci 0000:00:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> pci 0000:00:00.0: PME# disabled
> pci 0001:02:00.0: ignoring class b20 (doesn't match header type 01)
> pci 0001:02:00.0: PME# supported from D0 D1 D2 D3hot D3cold
> pci 0001:02:00.0: PME# disabled
> pci 0000:00:00.0: not setting up bridge for bus 0000:01
> pci 0000:00:00.0: enabling device (0106 -> 0107)
> pci 0001:02:00.0: not setting up bridge for bus 0001:03
> pci 0001:02:00.0: enabling device (0106 -> 0107)
> bio: create slab <bio-0> at 0
> SCSI subsystem initialized
> usbcore: registered new interface driver usbfs
> usbcore: registered new interface driver hub
> usbcore: registered new device driver usb
> Freescale Elo / Elo Plus DMA driver
> NET: Registered protocol family 2
> IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
> TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
> TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
> TCP: Hash tables configured (established 131072 bind 65536)
> TCP reno registered
> NET: Registered protocol family 1
> checking if image is initramfs...it isn't (no cpio magic); looks like an =
initrd
> Freeing initrd memory: 26149k freed
> fsl-elo-dma ffe0c300.dma: Probe the Freescale DMA driver for fsl,eloplus-=
dma controller at ffe0c300...
> fsl-elo-dma ffe0c300.dma: #0 (fsl,eloplus-dma-channel), irq 76
> fsl-elo-dma ffe0c300.dma: #1 (fsl,eloplus-dma-channel), irq 77
> fsl-elo-dma ffe0c300.dma: #2 (fsl,eloplus-dma-channel), irq 78
> fsl-elo-dma ffe0c300.dma: #3 (fsl,eloplus-dma-channel), irq 79
> fsl-elo-dma ffe21300.dma: Probe the Freescale DMA driver for fsl,eloplus-=
dma controller at ffe21300...
> fsl-elo-dma ffe21300.dma: #0 (fsl,eloplus-dma-channel), irq 20
> fsl-elo-dma ffe21300.dma: #1 (fsl,eloplus-dma-channel), irq 21
> fsl-elo-dma ffe21300.dma: #2 (fsl,eloplus-dma-channel), irq 22
> fsl-elo-dma ffe21300.dma: #3 (fsl,eloplus-dma-channel), irq 23
> audit: initializing netlink socket (disabled)
> type=3D2000 audit(2.388:1): initialized
> highmem bounce pool size: 64 pages
> Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
> NTFS driver 2.1.29 [Flags: R/O].
> JFFS2 version 2.2. (NAND) (SUMMARY)  =C2=A9 2001-2006 Red Hat, Inc.
> JFFS2: default compression mode: priority
> msgmni has been set to 1507
> alg: No test for stdrng (krng)
> io scheduler noop registered
> io scheduler anticipatory registered
> io scheduler deadline registered
> io scheduler cfq registered (default)
> Generic non-volatile memory driver v1.1
> Serial: 8250/16550 driver, 2 ports, IRQ sharing enabled
> serial8250.0: ttyS0 at MMIO 0xffe04500 (irq =3D 42) is a 16550A
> console handover: boot [udbg0] -> real [ttyS0]
> serial8250.0: ttyS1 at MMIO 0xffe04600 (irq =3D 42) is a 16550A
> brd: module loaded
> loop: module loaded
> nbd: registered device at major 43
> e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k6
> e1000e: Copyright (c) 1999-2008 Intel Corporation.
> Gianfar MII Bus: probed
> Gianfar MII Bus: probed
> eth0 (fsl-gianfar): not using net_device_ops yet
> eth0: Gianfar Ethernet Controller Version 1.4-skbr1.1.4, 00:04:9f:0c:05:00
> eth0: MTU =3D 1500 (frame size=3D1524, truesize=3D1800)
> eth0: Running with NAPI enabled
> eth0: 128/128 RX/TX BD ring size
> eth1 (fsl-gianfar): not using net_device_ops yet
> eth1: Gianfar Ethernet Controller Version 1.4-skbr1.1.4, 00:04:9f:0c:05:01
> eth1: MTU =3D 1500 (frame size=3D1524, truesize=3D1800)
> eth1: Running with NAPI enabled
> eth1: 128/128 RX/TX BD ring size
> eth2 (fsl-gianfar): not using net_device_ops yet
> eth2: Gianfar Ethernet Controller Version 1.4-skbr1.1.4, 00:04:9f:0c:05:02
> eth2: MTU =3D 1500 (frame size=3D1524, truesize=3D1800)
> eth2: Running with NAPI enabled
> eth2: 128/128 RX/TX BD ring size
> Fixed MDIO Bus: probed
> st: Version 20081215, fixed bufsize 32768, s/g segs 256
> Driver 'st' needs updating - please use bus_type methods
> Driver 'sd' needs updating - please use bus_type methods
> Driver 'sr' needs updating - please use bus_type methods
> ef000000.nor: Found 1 x16 devices at 0x0 in 16-bit bank
>  Amd/Fujitsu Extended Query Table at 0x0040
> ef000000.nor: CFI does not contain boot bank location. Assuming top.
> number of CFI chips: 1
> cfi_cmdset_0002: Disabling erase-suspend-program due to code brokenness.
> RedBoot partition parsing not available
> Creating 5 MTD partitions on "ef000000.nor":
> 0x000000000000-0x000000040000 : "NOR (RO) Vitesse-7385 Firmware"
> ftl_cs: FTL header not found.
> 0x000000040000-0x000000080000 : "NOR (RO) DTB Image"
> ftl_cs: FTL header not found.
> 0x000000080000-0x000000400000 : "NOR (RO) Linux Kernel Image"
> ftl_cs: FTL header not found.
> 0x000000400000-0x000000f00000 : "NOR (RW) JFFS2 Root File System"
> ftl_cs: FTL header not found.
> 0x000000f00000-0x000001000000 : "NOR (RO) U-Boot Image"
> ftl_cs: FTL header not found.
> NAND device: Manufacturer ID: 0xec, Chip ID: 0x75 (Samsung NAND 32MiB 3,3=
V 8-bit)
> RedBoot partition parsing not available
> Creating 6 MTD partitions on "ffa00000.flash":
> 0x000000000000-0x000000080000 : "NAND (RO) U-Boot Image"
> ftl_cs: FTL header not found.
> 0x000000080000-0x000000100000 : "NAND (RO) DTB Image"
> ftl_cs: FTL header not found.
> 0x000000100000-0x000000500000 : "NAND (RO) Linux Kernel Image"
> ftl_cs: FTL header not found.
> 0x000000500000-0x000000900000 : "NAND (RO) Compressed RFS Image"
> ftl_cs: FTL header not found.
> 0x000000900000-0x000001000000 : "NAND (RW) JFFS2 Root File System"
> ftl_cs: FTL header not found.
> 0x000001000000-0x000002000000 : "NAND (RW) Writable User area"
> ftl_cs: FTL header not found.
> eLBC NAND device at 0xffa00000, bank 1
> fsl_m25p80 spi28672.0: s25sl128b (0 Kbytes)
> Creating 5 MTD partitions on "SPIFLASH0":
> 0x000000000000-0x000000080000 : "SPI (RO) U-Boot Image"
> ftl_cs: FTL header not found.
> 0x000000080000-0x000000100000 : "SPI (RO) DTB Image"
> ftl_cs: FTL header not found.
> 0x000000100000-0x000000500000 : "SPI (RO) Linux Kernel Image"
> ftl_cs: FTL header not found.
> 0x000000500000-0x000000900000 : "SPI (RO) Compressed RFS Image"
> ftl_cs: FTL header not found.
> 0x000000900000-0x000001000000 : "SPI (RW) JFFS2 RFS"
> ftl_cs: FTL header not found.
> ffe07000.spi: Freescale eSPI Controller driver at 0xf210a000 (irq =3D 59)
> ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
> fsl-ehci fsl-ehci.0: Freescale On-Chip EHCI Host Controller
> fsl-ehci fsl-ehci.0: new USB bus registered, assigned bus number 1
> fsl-ehci fsl-ehci.0: irq 28, io base 0xffe22000
> fsl-ehci fsl-ehci.0: USB 2.0 started, EHCI 1.00
> usb usb1: configuration #1 chosen from 1 choice
> hub 1-0:1.0: USB hub found
> hub 1-0:1.0: 1 port detected
> Initializing USB Mass Storage driver...
> usbcore: registered new interface driver usb-storage
> USB Mass Storage support registered.
> i2c /dev entries driver
> rtc-ds1307 0-0068: rtc core: registered ds1339 as rtc0
> sdhci: Secure Digital Host Controller Interface driver
> sdhci: Copyright(c) Pierre Ossman
> esdhc: Freescale Enhanced Secure Digital Host Controller driver
> mmc0: ESDHC at 0xffe2e000 irq 72 PIO
> talitos ffe30000.crypto: hwrng
> alg: No test for authenc(hmac(sha1),cbc(aes)) (authenc-hmac-sha1-cbc-aes-=
talitos)
> talitos ffe30000.crypto: authenc-hmac-sha1-cbc-aes-talitos
> alg: No test for authenc(hmac(sha1),cbc(des3_ede)) (authenc-hmac-sha1-cbc=
-3des-talitos)
> talitos ffe30000.crypto: authenc-hmac-sha1-cbc-3des-talitos
> alg: No test for authenc(hmac(sha256),cbc(aes)) (authenc-hmac-sha256-cbc-=
aes-talitos)
> talitos ffe30000.crypto: authenc-hmac-sha256-cbc-aes-talitos
> alg: No test for authenc(hmac(sha256),cbc(des3_ede)) (authenc-hmac-sha256=
-cbc-3des-talitos)
> talitos ffe30000.crypto: authenc-hmac-sha256-cbc-3des-talitos
> alg: No test for authenc(hmac(md5),cbc(aes)) (authenc-hmac-md5-cbc-aes-ta=
litos)
> talitos ffe30000.crypto: authenc-hmac-md5-cbc-aes-talitos
> alg: No test for authenc(hmac(md5),cbc(des3_ede)) (authenc-hmac-md5-cbc-3=
des-talitos)
> talitos ffe30000.crypto: authenc-hmac-md5-cbc-3des-talitos
> IPv4 over IPv4 tunneling driver
> GRE over IPv4 tunneling driver
> TCP cubic registered
> Initializing XFRM netlink socket
> NET: Registered protocol family 10
> IPv6 over IPv4 tunneling driver
> NET: Registered protocol family 17
> NET: Registered protocol family 15
> RPC: Registered udp transport module.
> RPC: Registered tcp transport module.
> 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> All bugs added by David S. Miller <davem@redhat.com>
> rtc-ds1307 0-0068: setting system clock to 2009-07-01 10:24:20 UTC (12464=
43860)
> RAMDISK: Compressed image found at block 0
> VFS: Mounted root (ext2 filesystem) on device 1:0.
> Freeing unused kernel memory: 216k init
> Mounting /proc and /sys =

> Setting the hostname to P2020RDB
> Mounting filesystems
> mount: sysfs already mounted or /sys busy
> mount: according to mtab, /sys is already mounted on /sys
> Starting syslogd and klogd
> Running sysctl
> Setting up networking on loopback device: =

> Setting up networking on eth0: ADDRCONF(NETDEV_UP): eth0: link is not rea=
dy
>
> Adding static route for default gateway to 192.168.0.1: =

> Setting nameserver to 192.168.0.1 in /etc/resolv.conf: =

> SettingADDRCONF(NETDEV_UP): eth1: link is not ready
>  up networking on eth1: =

> Adding static route for default gateway to 192.168.1.1: =

> Setting nameserver to 192.168.1.1 in /etc/resolv.conf: =

> SettingADDRCONF(NETDEV_UP): eth2: link is not ready
>  up networking on eth2: =

> Adding static route for default gateway to 192.168.2.1: =

> Starting inetd: =

> Starting the port mapper: =

> Generating keys for the dropbear ssh server: =

> Will output 1024 bit rsa secret key to '/etc/dropbear/dropbear_rsa_host_k=
ey'
> Generating key, this may take a while...
> Public key portion is:
> ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgwC8sk4V/7x6e0hJOjBdcGmUx26QQfpVdxT1z=
9itBPZf/bdfogKI5OHEfCPU2Tc+ZYNtrPXIgYvrML5I5z/WQL7QNgOx0/Vv
> woNbxHLXj5UmirIJ6kNKlyUisPyZNU54XQjKCTpK7GjcGvUFgQMqv2HqWMfFV9XmytvXJgkhy=
g0jxox7 root@P2020RDB
> Fingerprint: md5 2d:50:46:59:d1:92:72:1f:07:cf:e4:b6:14:6c:86:f3
> Starting the dropbear ssh server: =

> Starting the boa webserver: =

> Please set the system time using
>     date <mmddhhmnyyyy>
>     /sbin/hwclock -w
> PHY: 0:01 - Link is Up - 1000/Full
> ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>
>
>         Welcome to Freescale Semiconductor Embedded Linux Environment
>
> !!!!! WARNING !!!!!!!
>
> The default password for the root account is: root
> please change this password using the 'passwd' command
> and then edit this message (/etc/issue) to remove this message
>
> P2020RDB login: PHY: mdio0@520:01 - Link is Up - 1000/Full
> ADDRCONF(NETDEV_CHANGE): eth2: link becomes ready
> root
> Password: =

> [root@P2020RDB /root]# ifco=08=08=08=08[root@P2020RDB /root]# ifconfig et=
h0 down
> [root@P2020RDB /root]# [root@P2020RDB /root]# ifconfig eth0 down=08=08=08=
=08=08=08 down 1 down down
> [root@P2020RDB /root]# [root@P2020RDB /root]# ifconfig eth1 down=08=08=08=
=08=08=08 down 2 down down
> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# ifco=08=08=08=08[root@P2020RDB /root]# ifconfig et=
h0 192.168.1.2 netmask 255.255.255.0
> [root@P2020RDB /root]# PHY: 0:01 - Link is Up - 1000/Full
>
> [root@P2020RDB /root]# ifcoe=08 =08=08=08=08=08[root@P2020RDB /root]# ifc=
onfig t=08 =08eyh=08 =08=08 =08th2 192.168.2.2 netmask 255.255.255.0
> [root@P2020RDB /root]# PHY: mdio0@520:01 - Link is Up - 1000/Full
>
> [root@P2020RDB /root]# ifco=08=08=08=08[root@P2020RDB /root]# ifconfig et=
h=08 =08=08 =08=08 =08=08 =08=08 =08=08 =08=08 =08=08 =08=08 =08=08 =08=08 =
=08=08 =08eccho 1 > /p=08=08[root@P2020RDB /root]# eccho 1 > /proc/sy[root@=
P2020RDB /root]# eccho 1 > /proc/sys/n[root@P2020RDB /root]# eccho 1 > /pro=
c/sys/net/ip[root@P2020RDB /root]# eccho 1 > /proc/sys/net/ipv4[root@P2020R=
DB /root]# eccho 1 > /proc/sys/net/ipv4/ip_f[root@P2020RDB /root]# eccho 1 =
> /proc/sys/net/ipv4/ip_forward =

> -sh: eccho: not found
> [root@P2020RDB /root]# echo 1 > /p=08=08[root@P2020RDB /root]# echo 1 > /=
proc/sy[root@P2020RDB /root]# echo 1 > /proc/sys/n[root@P2020RDB /root]# ec=
ho 1 > /proc/sys/net/ip[root@P2020RDB /root]# echo 1 > /proc/sys/net/ipv4[r=
oot@P2020RDB /root]# echo 1 > /proc/sys/net/ipv4/ip_f[root@P2020RDB /root]#=
 echo 1 > /proc/sys/net/ipv4/ip_forward =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# pn=08 =08ing 192.168.1.1
> PING 192.168.1.1 (192.168.1.1): 56 data bytes
> 64 bytes from 192.168.1.1: seq=3D0 ttl=3D255 time=3D2.590 ms
> 64 bytes from 192.168.1.1: seq=3D1 ttl=3D255 time=3D0.090 ms
>
> --- 192.168.1.1 ping statistics ---
> 2 packets transmitted, 2 packets received, 0% packet loss
> round-trip min/avg/max =3D 0.090/1.340/2.590 ms
> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# ping 192.168.2.1
> PING 192.168.2.1 (192.168.2.1): 56 data bytes
> 64 bytes from 192.168.2.1: seq=3D0 ttl=3D255 time=3D3.502 ms
>
> --- 192.168.2.1 ping statistics ---
> 1 packets transmitted, 1 packets received, 0% packet loss
> round-trip min/avg/max =3D 3.502/3.502/3.502 ms
> [root@P2020RDB /root]# arp
> gateway2 (192.168.2.1) at 00:00:08:00:00:01 [ether]  on eth2
> gateway1 (192.168.1.1) at 00:00:07:00:00:01 [ether]  on eth0
> [root@P2020RDB /root]# arp -s 192.168.2.1 00:00:08:00:00:01
> [root@P2020RDB /root]# arp -s 192.1681.=08 =08=08 =08.1.1 00:00:07:00:00:=
01
> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# =

> [root@P2020RDB /root]# arp =

> gateway2 (192.168.2.1) at 00:00:08:00:00:01 [ether] PERM on eth2
> gateway1 (192.168.1.1) at 00:00:07:00:00:01 [ether] PERM on eth0
> [root@P2020RDB /root]# ifco=08=08=08=08[root@P2020RDB /root]# ifconfig =

> eth0      Link encap:Ethernet  HWaddr 00:04:9F:0C:05:00  =

>           inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:5 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 =

>           RX bytes:426 (426.0 B)  TX bytes:1146 (1.1 KiB)
>           Base address:0x2000 =

>
> eth2      Link encap:Ethernet  HWaddr 00:04:9F:0C:05:02  =

>           inet addr:192.168.2.2  Bcast:192.168.2.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:4 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 =

>           RX bytes:318 (318.0 B)  TX bytes:1048 (1.0 KiB)
>           Base address:0xa000 =

>
> lo        Link encap:Local Loopback  =

>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 =

>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
> [root@P2020RDB /root]# cat /p=08=08[root@P2020RDB /root]# cat /proc/in[ro=
ot@P2020RDB /root]# cat /proc/interrupts =

>            CPU0       CPU1       =

>  19:        648          0   OpenPIC   Level     fsl-elbc
>  20:          0          0   OpenPIC   Level     fsldma-channel
>  21:          0          0   OpenPIC   Level     fsldma-channel
>  22:          0          0   OpenPIC   Level     fsldma-channel
>  23:          0          0   OpenPIC   Level     fsldma-channel
>  28:          0          0   OpenPIC   Level     ehci_hcd:usb1
>  29:         13          0   OpenPIC   Level     eth0_tx
>  30:          0          4   OpenPIC   Level     eth0_rx
>  31:          0         12   OpenPIC   Level     eth2_tx
>  32:          4          0   OpenPIC   Level     eth2_rx
>  33:          0          0   OpenPIC   Level     eth2_er
>  34:          0          0   OpenPIC   Level     eth0_er
>  42:       1049          0   OpenPIC   Level     serial
>  43:          0         29   OpenPIC   Level     i2c-mpc, i2c-mpc
>  45:          0          0   OpenPIC   Level     talitos
>  59:          0       2494   OpenPIC   Level     fsl_espi
>  72:         12          0   OpenPIC   Level     esdhc:slot0
>  76:          0          0   OpenPIC   Level     fsldma-channel
>  77:          0          0   OpenPIC   Level     fsldma-channel
>  78:          0          0   OpenPIC   Level     fsldma-channel
>  79:          0          0   OpenPIC   Level     fsldma-channel
> 251:          0          0   OpenPIC   Edge      ipi call function
> 252:       1253       1387   OpenPIC   Edge      ipi reschedule
> 253:        427        390   OpenPIC   Edge      ipi call function single
> BAD:          1
> [root@P2020RDB /root]# PHY: mdio0@520:01 - Link is Down
> PHY: mdio0@520:01 - Link is Up - 1000/Full
>
> [root@P2020RDB /root]# cat /p=08=08[root@P2020RDB /root]# cat /proc/in[ro=
ot@P2020RDB /root]# cat /proc/interrupts =

>            CPU0       CPU1       =

>  19:        648          0   OpenPIC   Level     fsl-elbc
>  20:          0          0   OpenPIC   Level     fsldma-channel
>  21:          0          0   OpenPIC   Level     fsldma-channel
>  22:          0          0   OpenPIC   Level     fsldma-channel
>  23:          0          0   OpenPIC   Level     fsldma-channel
>  28:          0          0   OpenPIC   Level     ehci_hcd:usb1
>  29:      56328          0   OpenPIC   Level     eth0_tx
>  30:          0    5553282   OpenPIC   Level     eth0_rx
>  31:          0      43413   OpenPIC   Level     eth2_tx
>  32:    5709572          0   OpenPIC   Level     eth2_rx
>  33:          0          0   OpenPIC   Level     eth2_er
>  34:          0          0   OpenPIC   Level     eth0_er
>  42:       1179          0   OpenPIC   Level     serial
>  43:          0         29   OpenPIC   Level     i2c-mpc, i2c-mpc
>  45:          0          0   OpenPIC   Level     talitos
>  59:          0       2494   OpenPIC   Level     fsl_espi
>  72:         12          0   OpenPIC   Level     esdhc:slot0
>  76:          0          0   OpenPIC   Level     fsldma-channel
>  77:          0          0   OpenPIC   Level     fsldma-channel
>  78:          0          0   OpenPIC   Level     fsldma-channel
>  79:          0          0   OpenPIC   Level     fsldma-channel
> 251:          0          0   OpenPIC   Edge      ipi call function
> 252:       1254       1389   OpenPIC   Edge      ipi reschedule
> 253:        427        406   OpenPIC   Edge      ipi call function single
> BAD:      36172
> [root@P2020RDB /root]# uname -a
> Linux P2020RDB 2.6.29 #1 SMP Fri Jul 3 15:11:50 IST 2009 ppc unknown
> [root@P2020RDB /root]# cat /p=08=08[root@P2020RDB /root]# cat /proc/in[ro=
ot@P2020RDB /root]# cat /proc/interrupts =

>            CPU0       CPU1       =

>  19:        648          0   OpenPIC   Level     fsl-elbc
>  20:          0          0   OpenPIC   Level     fsldma-channel
>  21:          0          0   OpenPIC   Level     fsldma-channel
>  22:          0          0   OpenPIC   Level     fsldma-channel
>  23:          0          0   OpenPIC   Level     fsldma-channel
>  28:          0          0   OpenPIC   Level     ehci_hcd:usb1
>  29:      56328          0   OpenPIC   Level     eth0_tx
>  30:          0    5553282   OpenPIC   Level     eth0_rx
>  31:          0      43413   OpenPIC   Level     eth2_tx
>  32:    5709572          0   OpenPIC   Level     eth2_rx
>  33:          0          0   OpenPIC   Level     eth2_er
>  34:          0          0   OpenPIC   Level     eth0_er
>  42:       1329          0   OpenPIC   Level     serial
>  43:          0         29   OpenPIC   Level     i2c-mpc, i2c-mpc
>  45:          0          0   OpenPIC   Level     talitos
>  59:          0       2494   OpenPIC   Level     fsl_espi
>  72:         12          0   OpenPIC   Level     esdhc:slot0
>  76:          0          0   OpenPIC   Level     fsldma-channel
>  77:          0          0   OpenPIC   Level     fsldma-channel
>  78:          0          0   OpenPIC   Level     fsldma-channel
>  79:          0          0   OpenPIC   Level     fsldma-channel
> 251:          0          0   OpenPIC   Edge      ipi call function
> 252:       1256       1391   OpenPIC   Edge      ipi reschedule
> 253:        427        439   OpenPIC   Edge      ipi call function single
> BAD:      36172
> [root@P2020RDB /root]# ifco=08=08=08=08[root@P2020RDB /root]# ifconfig =

> eth0      Link encap:Ethernet  HWaddr 00:04:9F:0C:05:00  =

>           inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:8928576 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:8928586 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 =

>           RX bytes:625000396 (596.0 MiB)  TX bytes:535715406 (510.8 MiB)
>           Base address:0x2000 =

>
> eth2      Link encap:Ethernet  HWaddr 00:04:9F:0C:05:02  =

>           inet addr:192.168.2.2  Bcast:192.168.2.255  Mask:255.255.255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:8928575 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:8928585 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 =

>           RX bytes:625000288 (596.0 MiB)  TX bytes:535715308 (510.8 MiB)
>           Base address:0xa000 =

>
> lo        Link encap:Local Loopback  =

>           inet addr:127.0.0.1  Mask:255.0.0.0
>           UP LOOPBACK RUNNING  MTU:16436  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:0 =

>           RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
>
> [root@P2020RDB /root]# =

> ------------------------------------------------------------------------
>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev


-- =

R=E9gis ODEYE

Kontron Modular Computers SA
150, rue M. Berthelot / ZI Toulon Est / BP 244 / Fr 83078 TOULON Cedex 9
Phone: (33) 4 98 16 34 86           Fax: (33) 4 98 16 34 01
E-mail: regis.odeye@kontron.com  Web : www.kontron.com
