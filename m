From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: Re: r8169 in 2.6.18 silently corrupting data, 2.6.22-rc3 link not detected at all
Date: Mon, 28 May 2007 16:11:25 -0400
Message-ID: <76366b180705281311v6a15dc7chb5dc8c4e36e573b4@mail.gmail.com>
References: <76366b180705281110j472671a1h6ff5ed5fa711c45e@mail.gmail.com>
	 <20070528195422.GA4927@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:48221 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbXE1UL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 May 2007 16:11:29 -0400
Received: by an-out-0708.google.com with SMTP id d31so449628and
        for <netdev@vger.kernel.org>; Mon, 28 May 2007 13:11:26 -0700 (PDT)
In-Reply-To: <20070528195422.GA4927@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I will check your patch against what I already grabbed from
2.6.22-rc2-mm1. I had already booted into the new kernel and captured
all the info I could.. no luck. I see that all of your recent changes
are in the mm1 driver, but I'll see if the patch link you dumped has
anything new.

I'll get the other info you asked for. Here is the info I already
gathered from 2.6.22-rc3 including DEBUG ifdef output using the mm1
driver:

# uname -a
Linux lx900 2.6.22-rc3 #2 Mon May 28 13:51:21 EDT 2007 i586 GNU/Linux

# md5sum /usr/src/linux/drivers/net/r8169.c
3de93a6dbe45bacbfdd20d0e17a9d166  r8169.c

# dmesg | grep 8169
r8169 Gigabit Ethernet driver 2.2LK loaded
eth0: RTL8169sc/8110sc at 0xd002c000, 00:0c:76:ae:b5:16, IRQ 5
r8169 Gigabit Ethernet driver 2.2LK loaded
eth1: RTL8169sc/8110sc at 0xd002e000, 00:0c:76:ae:b5:17, IRQ 11
r8169: eth0: link down

(the c5e1 below alternates back and forth to 0000 as it prints out the
PHY timer msgs)
# mii-tool -vv
Using SIOCGMIIPHY=0x8947
eth0: no link
  registers for MII PHY 32:
    1000 7949 001c c912 0de1 c5e1 000f 2001
    4bf0 0300 0800 0000 1007 f880 0000 3000
    0060 a080 0000 e002 1060 0000 920f 2108
    2740 8c00 0040 0206 246c 0000 0123 0000
  product info: vendor 00:07:32, model 17 rev 2
  basic mode:   autonegotiation enabled
  basic status: no link
  capabilities: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD
  advertising:  100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control
  link partner: 100baseTx-FD 100baseTx-HD 10baseT-FD 10baseT-HD flow-control

# ethtool -S eth0
NIC statistics:
     tx_packets: 4841
     rx_packets: 7356
     tx_errors: 1
     rx_errors: 2163
     rx_missed: 0
     align_errors: 59058
     tx_single_collisions: 573
     tx_multi_collisions: 338
     unicast: 6991
     broadcast: 365
     multicast: 0
     tx_aborted: 0
     tx_underrun: 0

# lspci -vv -s 0d.0
00:0d.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169
Gigabit Ethernet (rev 10)
	Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr-
Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
	Interrupt: pin A routed to IRQ 5
	Region 0: I/O ports at f600 [size=256]
	Region 1: Memory at effff000 (32-bit, non-prefetchable) [size=256]
	[virtual] Expansion ROM at 10080000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

# modprobe -r r8169
ACPI: PCI interrupt for device 0000:00:0e.0 disabled
ACPI: PCI interrupt for device 0000:00:0d.0 disabled

# modprobe r8169 debug=16
ACPI: PCI Interrupt 0000:00:0d.0[A] -> Link [LNKB] -> GSI 5 (level,
low) -> IRQ 5
eth0: RTL8169sc/8110sc at 0xd002e000, 00:0c:76:ae:b5:16, IRQ 5
ACPI: PCI Interrupt 0000:00:0e.0[A] -> Link [LNKD] -> GSI 11 (level,
low) -> IRQ 11
eth1: RTL8169sc/8110sc at 0xd0122000, 00:0c:76:ae:b5:17, IRQ 11
r8169: eth0: link down
eth0: PHY reset until link up
eth0: PHY reset until link up
eth0: PHY reset until link up
eth0: PHY reset until link up
eth0: PHY reset until link up

# latest 2.6.22-rc2-mm1 r8169.c compiled with DEBUG ifdef
ACPI: PCI Interrupt 0000:00:0d.0[A] -> Link [LNKB] -> GSI 5 (level,
low) -> IRQ 5
r8169: mac_version = 0x05
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
eth0: RTL8169sc/8110sc at 0xd002e000, 00:0c:76:ae:b5:16, IRQ 5
r8169: mac_version = 0x05
r8169: phy_version == RTL_GIGA_PHY_VER_D (0000)
r8169: MAC version != 0 && PHY version == 0 or 1
r8169: Do final_reg2.cfg
r8169: Set MAC Reg C+CR Offset 0x82h = 0x01h
r8169: eth0: link down
eth0: PHY reset until link up
eth0: PHY reset until link up


On 5/28/07, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Andrew Paprocki <andrew@ishiboo.com> :
> [...]
> > This struck me as strange, so I checked and it is directly connected
> > to the MAC addr of the ethernet card: 00:0c:76:ae:b5:16
> >
> > I figured that a newer kernel might fix this issue, so I built
> > 2.6.22-rc3 and under that kernel the r8169 device doesn't work at all.
> > It never detects a valid link. I insmod'd the driver with debug=16 and
> > all I see it printing is "eth0: PHY reset until link up" on a timer.
>
> Ok.
>
> You will not pollute the console much with a single bit of debug.
>
> > I see some patches flying around for r8169.c, but I'm not sure if
> > either of these two cases are known/fixed
>
> I am not sure either. With the usual luck, I could bet that an update
> will make the alignment issue go away while introducing a link negotiation
> regression.
>
> > Also, this is a gigabit NIC on a gig-e switched network, yet mii-tool
> > only reports 10mb-hd speed... ?
>
> Auto-negotiation probably failed. Your ethernet cables are fine, aren't they ?
>
> Please:
> - send a 'lspci -vvx' of the host
> - try 2.6.22-rc3 +
>   http://www.fr.zoreil.com/people/francois/misc/20070527-2.6.22-rc3-r8169.patch
> - send a complete dmesg (2.6.18 and 2.6.22-rc3 patched)
> - send 'mii-tool -vv' and 'ethtool -S' for a patched 2.6.22-rc3
> - send .config (one never knows...)
>
> [...]
> > # ethtool -S eth0
> > NIC statistics:
> >     tx_packets: 4397
> >     rx_packets: 6701
> >     tx_errors: 1
> >     rx_errors: 999
> >     rx_missed: 0
> >     align_errors: 25770
>                     ^^^^^
> ~2/3 of misaligned packets. Wow. Same thing with both interfaces ?
>
> If the patched kernel does not detect the link, restart autonegotiation
> with mii-tool.
>
> --
> Ueimor
>
>
