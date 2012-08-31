From: rebelyouth hacklab <rebelyouth.hacklab@gmail.com>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast
 Ethernet (rev b0) 1.0.0.7 md5 corrupted using NFS
Date: Fri, 31 Aug 2012 01:58:12 -0400
Message-ID: <CAPxKiaw9yHisO8imXwKkTEqCm-BE+Tiq_t3s28EE7xMgqNnggA@mail.gmail.com>
References: <201208061302.32582.marco.castiglione@yahoo.ca>
	<157393863283F442885425D2C454285623E19289@NASANEXD02A.na.qualcomm.com>
	<201208101526.03990.rebelyouth.hacklab@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:45888 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120Ab2HaF6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2012 01:58:13 -0400
Received: by vbbff1 with SMTP id ff1so2816116vbb.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 22:58:13 -0700 (PDT)
In-Reply-To: <201208101526.03990.rebelyouth.hacklab@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Xiong,

Sorry for the long delay but I did some experiment :

I tried with different pc and devices and OS and the problem is only in Linux.

 I don't get kernel oops (actually was the ATI catalyst the problem,
now with the Open source driver is all ok  ) and ifconfig showing is
all ok  on the pc side (Atheros)


eth0      Link encap:Ethernet  HWaddr
          inet addr:192.168.2.2  Bcast:192.168.2.15  Mask:255.255.255.240
          inet6 addr: fe80::226:18ff:fe62:72f5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:9933884 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3235805 errors:0 dropped:0 overruns:0 carrier:1
          collisions:0 txqueuelen:1000
          RX bytes:14432030555 (413.4 GiB)  TX bytes:275014758 (262.2 GiB)
          Interrupt:46

On the server side I received :

eth0      Link encap:Ethernet  HWaddr
          inet addr:192.168.2.5  Bcast:192.168.2.15  Mask:255.255.255.240
          inet6 addr: fe80::201:2eff:fe2b:67b6/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13922264 errors:20736 dropped:0 overruns:20736 frame:0
          TX packets:8782465 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4995676199 (414.6 GiB)  TX bytes:31479570606 (229.3 GiB)
          Interrupt:22


The server receive a lot of errors in RX

RX packets:13922264 errors:20736 dropped:0 overruns:20736 frame:0

I tried big DVD isos and separate files zip an rar and there are
perfect in WIndows, Freebsd and Mac OS X (samba,ftp,nfs) the ipconfig
on the server showing  is all ok

I also tried to optimize the NFS server and client but the only
setting for get the same of the other OS is  need to set proto=udp on
/ etc/fstab (now is more stable from before)

I can also see there isn't any problem on the client computer using
the usb adapter with ax8112 Chipset without set proto=udp

So  tried to disable the TSO with : ethtool -K eth0 tso off  and IS  working !!!


I really think the problem is this one and unfortunately I can't send
any oops, but if you need any information or to run any software
please let me know!!!



On Fri, Aug 10, 2012 at 3:26 PM, Rebelyouth
<rebelyouth.hacklab@gmail.com> wrote:
>
>
> Hi Xiong,
>
> Thank you for your replay,
>
> I am in a middle of reinstall all my machines f, so for now I can send you my
> lspci and try to recreate the MD5 /SHA1 problem
>
> I will send you another email when I get the result
> Thanks in advance
>
>
>
> 00:00.0 Host bridge: Advanced Micro Devices [AMD] RS780 Host Bridge
>         Subsystem: Advanced Micro Devices [AMD] RS780 Host Bridge
>         Flags: bus master, 66MHz, medium devsel, latency 0
>         Capabilities: <access denied>
>
> 00:02.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI bridge (ext
> gfx port 0) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
>         I/O behind bridge: 0000c000-0000cfff
>         Memory behind bridge: fbd00000-fbdfffff
>         Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
>         Capabilities: <access denied>
>         Kernel driver in use: pcieport
>
> 00:06.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI bridge (PCIE
> port 2) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
>         I/O behind bridge: 0000d000-0000dfff
>         Memory behind bridge: fbe00000-fbefffff
>         Capabilities: <access denied>
>         Kernel driver in use: pcieport
>
> 00:07.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI bridge (PCIE
> port 3) (prog-if 00 [Normal decode])
>         Flags: bus master, fast devsel, latency 0
>         Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
>         I/O behind bridge: 0000e000-0000efff
>         Memory behind bridge: fbf00000-fbffffff
>         Capabilities: <access denied>
>         Kernel driver in use: pcieport
>
> 00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
> SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (prog-if 01 [AHCI 1.0])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 SATA
> Controller [AHCI mode]
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 43
>         I/O ports at b000 [size=8]
>         I/O ports at a000 [size=4]
>         I/O ports at 9000 [size=8]
>         I/O ports at 8000 [size=4]
>         I/O ports at 7000 [size=16]
>         Memory at fbcffc00 (32-bit, non-prefetchable) [size=1K]
>         Capabilities: <access denied>
>         Kernel driver in use: ahci
>
> 00:12.0 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> USB OHCI0 Controller (prog-if 10 [OHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB
> OHCI0 Controller
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
>         Memory at fbcfd000 (32-bit, non-prefetchable) [size=4K]
>         Kernel driver in use: ohci_hcd
>
> 00:12.1 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0 USB OHCI1
> Controller (prog-if 10 [OHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0 USB OHCI1
> Controller
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
>         Memory at fbcfe000 (32-bit, non-prefetchable) [size=4K]
>         Kernel driver in use: ohci_hcd
>
> 00:12.2 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> USB EHCI Controller (prog-if 20 [EHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4397
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 17
>         Memory at fbcff800 (32-bit, non-prefetchable) [size=256]
>         Capabilities: <access denied>
>         Kernel driver in use: ehci_hcd
>
> 00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> USB OHCI0 Controller (prog-if 10 [OHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4398
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 18
>         Memory at fbcfb000 (32-bit, non-prefetchable) [size=4K]
>         Kernel driver in use: ohci_hcd
>
> 00:13.1 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0 USB OHCI1
> Controller (prog-if 10 [OHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4399
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 18
>         Memory at fbcfc000 (32-bit, non-prefetchable) [size=4K]
>         Kernel driver in use: ohci_hcd
>
> 00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> USB EHCI Controller (prog-if 20 [EHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 USB
> EHCI Controller
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 19
>         Memory at fbcff400 (32-bit, non-prefetchable) [size=256]
>         Capabilities: <access denied>
>         Kernel driver in use: ehci_hcd
>
> 00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller
> (rev 3c)
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller
>         Flags: 66MHz, medium devsel
>         Capabilities: <access denied>
>
> 00:14.1 IDE interface: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> IDE Controller (prog-if 8a [Master SecP PriP])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 IDE
> Controller
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 16
>         I/O ports at 01f0 [size=8]
>         I/O ports at 03f4 [size=1]
>         I/O ports at 0170 [size=8]
>         I/O ports at 0374 [size=1]
>         I/O ports at ff00 [size=16]
>         Capabilities: <access denied>
>         Kernel driver in use: pata_atiixp
>
> 00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00 Azalia (Intel
> HDA)
>         Subsystem: ASUSTeK Computer Inc. Device 8357
>         Flags: bus master, slow devsel, latency 64, IRQ 16
>         Memory at fbcf4000 (64-bit, non-prefetchable) [size=16K]
>         Capabilities: <access denied>
>         Kernel driver in use: snd_hda_intel
>
> 00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0 LPC
> host controller
>         Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4383
>         Flags: bus master, 66MHz, medium devsel, latency 0
>
> 00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to PCI
> Bridge (prog-if 01 [Subtractive decode])
>         Flags: bus master, 66MHz, medium devsel, latency 64
>         Bus: primary=00, secondary=04, subordinate=04, sec-latency=64
>
> 00:14.5 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0/SB8x0/SB9x0
> USB OHCI2 Controller (prog-if 10 [OHCI])
>         Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4396
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 18
>         Memory at fbcfa000 (32-bit, non-prefetchable) [size=4K]
>         Kernel driver in use: ohci_hcd
>
> 00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
> HyperTransport Configuration
>         Flags: fast devsel
>         Capabilities: <access denied>
>
> 00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor Address
> Map
>         Flags: fast devsel
>
> 00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor DRAM
> Controller
>         Flags: fast devsel
>
> 00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
> Miscellaneous Control
>         Flags: fast devsel
>         Capabilities: <access denied>
>         Kernel driver in use: k10temp
>
> 00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor Link
> Control
>         Flags: fast devsel
>
> 01:00.0 VGA compatible controller: Advanced Micro Devices [AMD] nee ATI
> Juniper [Radeon HD 5700 Series] (prog-if 00 [VGA controller])
>         Subsystem: Micro-Star International Co., Ltd. Device 2140
>         Flags: bus master, fast devsel, latency 0, IRQ 44
>         Memory at d0000000 (64-bit, prefetchable) [size=256M]
>         Memory at fbdc0000 (64-bit, non-prefetchable) [size=128K]
>         I/O ports at c000 [size=256]
>         Expansion ROM at fbda0000 [disabled] [size=128K]
>         Capabilities: <access denied>
>         Kernel driver in use: radeon
>
> 01:00.1 Audio device: Advanced Micro Devices [AMD] nee ATI Juniper HDMI Audio
> [Radeon HD 5700 Series]
>         Subsystem: Micro-Star International Co., Ltd. Device aa58
>         Flags: bus master, fast devsel, latency 0, IRQ 45
>         Memory at fbdfc000 (64-bit, non-prefetchable) [size=16K]
>         Capabilities: <access denied>
>         Kernel driver in use: snd_hda_intel
>
> 02:00.0 Ethernet controller: Atheros Communications Inc. AR8121/AR8113/AR8114
> Gigabit or Fast Ethernet (rev b0)
>         Subsystem: ASUSTeK Computer Inc. Device 831c
>         Flags: bus master, fast devsel, latency 0, IRQ 46
>         Memory at fbec0000 (64-bit, non-prefetchable) [size=256K]
>         I/O ports at dc00 [size=128]
>         Capabilities: <access denied>
>         Kernel driver in use: ATL1E
>
> 03:00.0 FireWire (IEEE 1394): VIA Technologies, Inc. VT6315 Series Firewire
> Controller (prog-if 10 [OHCI])
>         Subsystem: ASUSTeK Computer Inc. P8P67 Deluxe Motherboard
>         Flags: bus master, fast devsel, latency 0, IRQ 19
>         Memory at fbfff800 (64-bit, non-prefetchable) [size=2K]
>         I/O ports at e800 [size=256]
>         Capabilities: <access denied>
>         Kernel driver in use: firewire_ohci
>
> > Marco
> >     Could you run lspci, and list the kernel oops ?
> >     we could duplicate it using the same NIC.
> >
> >
> > PS.     The driver of 1.0.1.14 is not for your NIC.
> >
> > Thanks
> > Xiong
> >
> > > -----Original Message-----
> > > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > > On Behalf Of Marco Castiglione
> > > Sent: Tuesday, August 07, 2012 1:03
> > > To: netdev@vger.kernel.org
> > > Subject: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or
> > > Fast Ethernet (rev b0) 1.0.0.7 md5 corrupted using NFS
> > >
> > > Hi,
> > >
> > > I have a problem with :
> > >
> > > Ethernet controller: Atheros Communications Inc. AR8121/AR8113/AR8114
> > > Gigabit or Fast Ethernet (rev b0)
> > >
> > >         Subsystem: ASUSTeK Computer Inc. Device 831c
> > >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> > >
> > > ParErr-
> > > Stepping- SERR+ FastB2B- DisINTx+
> > >
> > >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> > >
> > > <TAbort- <MAbort- >SERR- <PERR- INTx-
> > >
> > >         Latency: 0, Cache Line Size: 64 bytes
> > >         Interrupt: pin A routed to IRQ 46
> > >         Region 0: Memory at fbec0000 (64-bit, non-prefetchable)
> > >         [size=256K] Region 2: I/O ports at dc00 [size=128]
> > >         Capabilities: <access denied>
> > >         Kernel driver in use: ATL1E
> > >
> > > The driver working fine except for nfs3 and nfs4
> > >
> > > If I try to copy a file bigger of 400 mb the file get corrupted, If I try
> > > with multiple files I have a kernel oops
> > >
> > > I tried different system and service (Ftp,samba) and they working fine.
> > >
> > > I also tried to set nfs to use udp, it kinda fix the problem but only in
> > > part (I get 1 on 3 big file with md5 mismatch).
> > >
> > > I notice in almost every kernel from 2.6 to now 3.2.15 the driver is the
> > > same version
> > >
> > > Filename:       /lib/modules/3.2.0-2-amd64/
> > > kernel/drivers/net/ethernet/atheros/atl1e/atl1e.ko
> > > version:        1.0.0.7-NAPI
> > > license:        GPL
> > > description:    Atheros 1000M Ethernet Network Driver
> > > author:         Atheros Corporation, <xiong.huang@atheros.com>, Jie Yang
> > > < jie.yang@atheros.com>
> > > srcversion:     6E5949327D7FDF32D5F4A5B
> > > alias:          pci:v00001969d00001066sv*sd*bc*sc*i*
> > > alias:          pci:v00001969d00001026sv*sd*bc*sc*i*
> > > depends:
> > > intree:         Y
> > > vermagic:       3.2.0-2-amd64 SMP mod_unload modversions
> > > parm:           tx_desc_cnt:Transmit description count (array of int)
> > > parm:           rx_mem_size:memory size of rx buffer(KB) (array of int)
> > > parm:           media_type:MediaType Select (array of int)
> > > parm:           int_mod_timer:Interrupt Moderator Timer (array of int)
> > >
> > > I found on ubuntu website the last version of the driver is 1.0.1.14 with
> > > this change log :
> > >
> > > 1.0.1.14
> > >
> > >     1. don't define napi_struct in kcompat.h when GRO isn't supported.
> > >
> > > 1.0.1.13
> > >
> > >     1. fix AR8151-A hang when plug in LAN cable by cleaning bit1 of
> > >
> > > REG(0x1114).
> > >
> > > 1.0.1.12
> > >
> > >     1. fix tpd, rfd, rrs, configure error for powerpc
> > >
> > > 1.0.1.11
> > >
> > >     1. only save power when WOL enable.
> > >
> > > 1.0.1.10
> > >
> > >     1. add l1d 2.0 support.
> > >     2. fix atl1c_phy_power_saving bug.
> > >
> > > 1.0.1.9
> > >
> > >     1. fix AR8131 reset error TX pending.
> > >     2. add AR8152 description.
> > >
> > > 1.0.1.8
> > >
> > >     1. add L2CB V2.0 support.
> > >
> > > 1.0.1.7
> > >
> > >     1. fix L0s/L1 bug.
> > >     2. update suspend procedure.
> > >
> > > 1.0.1.6
> > >
> > >     1. fix valn error.
> > >     2. use common task instead of reset task and link change task.
> > >     3. reset phy when link down.
> > >
> > > 1.0.1.5
> > >
> > >     1. change rx mod.
> > >
> > > 1.0.1.4
> > >
> > >     1. add l1d support.
> > >
> > > 1.0.1.3
> > >
> > >     1. fix TSO error.
> > >
> > > 1.0.1.2
> > >
> > >     1. fix compile error for kernel >= 2.6.30.
> > >
> > > 1.0.1.1
> > >
> > >     1. add L2cB support.
> > >
> > > 1.0.0.10
> > >
> > >     1. fix memory leak when power suspend.
> > >
> > > 1.0.0.9
> > >
> > >     1. do power saving when bootup with link lost.
> > >     2. remove ATL1C_INTR_CLEAR_ON_READ for power saving
> > >
> > > 1.0.0.8
> > >
> > >     1. remove dump_stack(), which was used for debugging.
> > >
> > > So I found out the TSO is corrupt in the current version  and that
> > > explain with the udp setting do the trick.
> > >
> > > Now I tried to compile the new version from AR81Family-linux-
> > > v1.0.1.14.tar.gz but was made for the 2.6 so I can't
> > > compile.( <http://goog_56610235>
> > > http://media.cdn.ubuntu-de.org/forum/attachments/2666793/AR81Family-
> > > linux-
> > > v1.0.1.14_10.10.tar.gz
> > > )
> > >
> > > The Atheros support and web page is gone after Qualcomm acquisition and
> > > the patch I found on Ubuntu forum don't work either (
> > > http://ubuntuforums.org/attachment.php?attachmentid=182141&d=1296221
> > > 015)
> > >
> > > I found out lots of people have the same issue and they using samba at
> > > the moment.
> > >
> > > My temp solution is use a usb/eth adapter with ax8112 chipset but it run
> > > at 100mbps.
> > >
> > > SO my request is this : Is possible for somebody of the kernel team look
> > > the code inside AR81Family-linux-v1.0.1.14.tar.gz  and update the one in
> > > the kernel 3.x?
> > >
> > > Thank you for you time and consideration
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in the
> > > body of a message to majordomo@vger.kernel.org More majordomo info at
> > > http://vger.kernel.org/majordomo-info.html
>
>
> Hi
