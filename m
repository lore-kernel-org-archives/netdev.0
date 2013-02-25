From: rebelyouth hacklab <rebelyouth.hacklab@gmail.com>
Subject: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast
 Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated)
Date: Mon, 25 Feb 2013 15:23:22 -0500
Message-ID: <CAPxKiawJC3gLqmg2Lx5qrw6WPXQjBRYRpcD0Fkd7Bt6QX8hzoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f66.google.com ([209.85.215.66]:45092 "EHLO
	mail-la0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758580Ab3BYUXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:23:24 -0500
Received: by mail-la0-f66.google.com with SMTP id gw10so1008277lab.5
        for <netdev@vger.kernel.org>; Mon, 25 Feb 2013 12:23:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm writing again for the same issue about  :

Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast
Ethernet (rev b0) 1.0.0.7 md5 /sha1 corrupted using NFS and samba

My solution in this past 7 months was one : don't use the chip (I also
deactivate the chip from the BIOS)

A friend of mine let me borrowed a pci-x with a Realtek RTL8168C/8111C.

The card worked in any condition, no problem with nfs or samba.

Unfortunately my friend need back the card for a project and I
activated back the Atheros card...and the problem is still there

I'm using at the moment a Debian sid with kernel 3.7.9 and a Chackra
2012 with kernel 3.7.6 and I see the atl1e is the same 1.0.0.7-NAPI :

modinfo atl1e

filename:
/lib/modules/3.7.9-amd64/kernel/drivers/net/ethernet/atheros/atl1e/atl1e.ko
version:        1.0.0.7-NAPI
license:        GPL
description:    Atheros 1000M Ethernet Network Driver
author:         Atheros Corporation, <xiong.huang@atheros.com>, Jie
Yang <jie.yang@atheros.com>
srcversion:     440FEE0BD620C8D71C0B74A
alias:          pci:v00001969d00001066sv*sd*bc*sc*i*
alias:          pci:v00001969d00001026sv*sd*bc*sc*i*
depends:
intree:         Y
vermagic:       3.7.9-amd64 SMP preempt mod_unload modversions
parm:           tx_desc_cnt:Transmit description count (array of int)
parm:           rx_mem_size:memory size of rx buffer(KB) (array of int)
parm:           media_type:MediaType Select (array of int)
parm:           int_mod_timer:Interrupt Moderator Timer (array of int)


I know the simple solution will be to buy a card with a different chip
(like the Realtek RTL8168C/8111C) but I would like to help the
community with this issue.

The problem : files bigger of 1Gb are corrupted (and file 400mb +  I
get a corruption in the 75% of the cases)

I don't receive any oops on the kernel or any dmesg error on the
client side but the server receive a lot of errors in RX:

RX packets:78125369 errors:58741 dropped:0 overruns:58741 frame:0

This are the test I did:

I test the connection with another cable CAT 6e, tried another router,
a switch and direct connection, also tried to connect another adapter
to the server
to see if the chipset on the server (Ethernet controller: NVIDIA
Corporation MCP79 Ethernet (rev b1) ) was the one who send corrupt
data or have a conflict with the atheros,  but this, from my test,
wasn't the case

Software test:

I'm using Nfs 4 with this setting on the server:

/media               192.168.0.0/24(rw,fsid=0,no_subtree_check,sync)
/media/disk          192.168.0.0/24(rw,nohide,insecure,no_subtree_check,sync)

(tried async but doesn't fix the issue)

on the client : 192.168.0.1:/    /nfs            nfs4
defaults,users,_netdev 0 0 (tried  rsize=32768,wsize=32768, async
without success)

I tried too copy large zero files (400mb, 1gb, 4gb,8gb ,16gb) and the
sha1/md5 are ok
if I try a iso or vdi or  a video bigger on these above that the
corruption occurs all the time,
same issue if I use samba.

I tried big DVD isos and separate files zip an rar and there
areperfect in Windows, Freebsd and Mac OS X (samba,ftp,nfs) the
ipconfig
on the server showing is all ok

Temp solution :

1) disable TSO with ethtool -K eth0 tso off working at 80% for some reason

2) set the fstab on the nfs to use proto=udp working but samba files
are still corrupted

3) with the usb adapter with Axis AX88772A I have no problem with nfs
and samba with standard setting (the same setting I used with the
Realtek RTL8168C/8111C)


I hope these information will  help to find the solution and I'm will
available for others tests.

Here my lspci -vvv:

00:00.0 Host bridge: Advanced Micro Devices [AMD] RS780 Host Bridge
        Subsystem: Advanced Micro Devices [AMD] RS780 Host Bridge
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ >SERR- <PERR- INTx-
        Latency: 0
        Capabilities: <access denied>

00:02.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (ext gfx port 0) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
        I/O behind bridge: 0000d000-0000dfff
        Memory behind bridge: fbe00000-fbefffff
        Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: <access denied>
        Kernel driver in use: pcieport

00:06.0 PCI bridge: Advanced Micro Devices [AMD] RS780 PCI to PCI
bridge (PCIE port 2) (prog-if 00 [Normal decode])
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
        I/O behind bridge: 0000e000-0000efff
        Memory behind bridge: fbf00000-fbffffff
        Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
        Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
        Capabilities: <access denied>
        Kernel driver in use: pcieport

00:11.0 SATA controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] (prog-if 01 [AHCI 1.0])
        Subsystem: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 42
        Region 0: I/O ports at c000 [size=8]
        Region 1: I/O ports at b000 [size=4]
        Region 2: I/O ports at a000 [size=8]
        Region 3: I/O ports at 9000 [size=4]
        Region 4: I/O ports at 8000 [size=16]
        Region 5: Memory at fbdffc00 (32-bit, non-prefetchable) [size=1K]
        Capabilities: <access denied>
        Kernel driver in use: ahci

00:12.0 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fbdfd000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd

00:12.1 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0 USB
OHCI1 Controller (prog-if 10 [OHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI SB7x0 USB
OHCI1 Controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fbdfe000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd

00:12.2 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4397
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 17
        Region 0: Memory at fbdff800 (32-bit, non-prefetchable) [size=256]
        Capabilities: <access denied>
        Kernel driver in use: ehci_hcd

00:13.0 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI0 Controller (prog-if 10 [OHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4398
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at fbdfb000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd

00:13.1 USB controller: Advanced Micro Devices [AMD] nee ATI SB7x0 USB
OHCI1 Controller (prog-if 10 [OHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4399
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at fbdfc000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd

00:13.2 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller (prog-if 20 [EHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB EHCI Controller
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 19
        Region 0: Memory at fbdff400 (32-bit, non-prefetchable) [size=256]
        Capabilities: <access denied>
        Kernel driver in use: ehci_hcd

00:14.0 SMBus: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus
Controller (rev 3c)
        Subsystem: Advanced Micro Devices [AMD] nee ATI SBx00 SMBus Controller
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort+ <MAbort- >SERR- <PERR- INTx-
        Capabilities: <access denied>

00:14.1 IDE interface: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 IDE Controller (prog-if 8a [Master SecP PriP])
        Subsystem: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 IDE Controller
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at 01f0 [size=8]
        Region 1: I/O ports at 03f4 [size=1]
        Region 2: I/O ports at 0170 [size=8]
        Region 3: I/O ports at 0374 [size=1]
        Region 4: I/O ports at ff00 [size=16]
        Capabilities: <access denied>
        Kernel driver in use: pata_atiixp

00:14.2 Audio device: Advanced Micro Devices [AMD] nee ATI SBx00
Azalia (Intel HDA)
        Subsystem: ASUSTeK Computer Inc. Device 8357
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=slow >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: Memory at fbdf4000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: <access denied>
        Kernel driver in use: snd_hda_intel

00:14.3 ISA bridge: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 LPC host controller
        Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4383
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0

00:14.4 PCI bridge: Advanced Micro Devices [AMD] nee ATI SBx00 PCI to
PCI Bridge (prog-if 01 [Subtractive decode])
        Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64
        Bus: primary=00, secondary=03, subordinate=03, sec-latency=64
        I/O behind bridge: 0000f000-00000fff
        Memory behind bridge: fff00000-000fffff
        Prefetchable memory behind bridge: fff00000-000fffff
        Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort+ <SERR- <PERR-
        BridgeCtl: Parity+ SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
                PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-

00:14.5 USB controller: Advanced Micro Devices [AMD] nee ATI
SB7x0/SB8x0/SB9x0 USB OHCI2 Controller (prog-if 10 [OHCI])
        Subsystem: Advanced Micro Devices [AMD] nee ATI Device 4396
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap- 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64, Cache Line Size: 64 bytes
        Interrupt: pin C routed to IRQ 18
        Region 0: Memory at fbdfa000 (32-bit, non-prefetchable) [size=4K]
        Kernel driver in use: ohci_hcd

00:18.0 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
HyperTransport Configuration
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: <access denied>

00:18.1 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Address Map
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.2 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
DRAM Controller
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

00:18.3 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Miscellaneous Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Capabilities: <access denied>
        Kernel driver in use: k10temp

00:18.4 Host bridge: Advanced Micro Devices [AMD] Family 10h Processor
Link Control
        Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-

01:00.0 VGA compatible controller: Advanced Micro Devices [AMD] nee
ATI Juniper [Radeon HD 5700 Series] (prog-if 00 [VGA controller])
        Subsystem: Micro-Star International Co., Ltd. Device 2140
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 43
        Region 0: Memory at d0000000 (64-bit, prefetchable) [size=256M]
        Region 2: Memory at fbec0000 (64-bit, non-prefetchable) [size=128K]
        Region 4: I/O ports at d000 [size=256]
        Expansion ROM at fbea0000 [disabled] [size=128K]
        Capabilities: <access denied>
        Kernel driver in use: radeon

01:00.1 Audio device: Advanced Micro Devices [AMD] nee ATI Juniper
HDMI Audio [Radeon HD 5700 Series]
        Subsystem: Micro-Star International Co., Ltd. Device aa58
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 44
        Region 0: Memory at fbefc000 (64-bit, non-prefetchable) [size=16K]
        Capabilities: <access denied>
        Kernel driver in use: snd_hda_intel

02:00.0 Ethernet controller: Atheros Communications Inc.
AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0)
        Subsystem: ASUSTeK Computer Inc. Device 831c
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 45
        Region 0: Memory at fbfc0000 (64-bit, non-prefetchable) [size=256K]
        Region 2: I/O ports at ec00 [size=128]
        Capabilities: <access denied>
        Kernel driver in use: ATL1E


And the lsusb :Bus 001 Device 004: ID 0b95:772a ASIX Electronics Corp.
AX88772A Fast Ethernet
