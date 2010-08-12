From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 driver fails to handle "rx length error: status 0x5d60100
 length 2982" gracefully
Date: Thu, 12 Aug 2010 12:00:44 -0400
Message-ID: <20100812120044.5b1880ad@s6510>
References: <AANLkTinMK7n51v4uBPYChYV7KOye8WEvdCFDanfd2mVL@mail.gmail.com>
	<20100811215932.26414efe@s6510>
	<AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux NetDev <netdev@vger.kernel.org>
To: Maciej =?UTF-8?B?xbtlbmN6eWtvd3NraQ==?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46355 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0HLQAt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Aug 2010 12:00:49 -0400
In-Reply-To: <AANLkTikDOerA4g+-=v+wM8cmysnemCTqEx0ncCCERLY6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Aug 2010 22:36:57 -0700
Maciej =C5=BBenczykowski <zenczykowski@gmail.com> wrote:

> Here's lspci (it's an otherwise stock MacBook Pro 4,1 with a
> non-standard wireless atheros mini-pci nic, replacing the std
> broadcom.)
>=20
> $ lspci
> 00:00.0 Host bridge: Intel Corporation Mobile PM965/GM965/GL960 Memor=
y
> Controller Hub (rev 03)
> 00:01.0 PCI bridge: Intel Corporation Mobile PM965/GM965/GL960 PCI
> Express Root Port (rev 03)
> 00:1a.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB
> UHCI Controller #4 (rev 03)
> 00:1a.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB
> UHCI Controller #5 (rev 03)
> 00:1a.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2
> EHCI Controller #2 (rev 03)
> 00:1b.0 Audio device: Intel Corporation 82801H (ICH8 Family) HD Audio
> Controller (rev 03)
> 00:1c.0 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Expres=
s
> Port 1 (rev 03)
> 00:1c.2 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Expres=
s
> Port 3 (rev 03)
> 00:1c.4 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Expres=
s
> Port 5 (rev 03)
> 00:1c.5 PCI bridge: Intel Corporation 82801H (ICH8 Family) PCI Expres=
s
> Port 6 (rev 03)
> 00:1d.0 USB Controller: Intel Corporation 82801H (ICH8 Family) USB
> UHCI Controller #1 (rev 03)
> 00:1d.1 USB Controller: Intel Corporation 82801H (ICH8 Family) USB
> UHCI Controller #2 (rev 03)
> 00:1d.2 USB Controller: Intel Corporation 82801H (ICH8 Family) USB
> UHCI Controller #3 (rev 03)
> 00:1d.7 USB Controller: Intel Corporation 82801H (ICH8 Family) USB2
> EHCI Controller #1 (rev 03)
> 00:1e.0 PCI bridge: Intel Corporation 82801 Mobile PCI Bridge (rev f3=
)
> 00:1f.0 ISA bridge: Intel Corporation 82801HEM (ICH8M) LPC Interface
> Controller (rev 03)
> 00:1f.1 IDE interface: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E)
> IDE Controller (rev 03)
> 00:1f.2 IDE interface: Intel Corporation 82801HBM/HEM (ICH8M/ICH8M-E)
> SATA IDE Controller (rev 03)
> 00:1f.3 SMBus: Intel Corporation 82801H (ICH8 Family) SMBus Controlle=
r (rev 03)
> 01:00.0 VGA compatible controller: nVidia Corporation G84 [GeForce
> 8600M GT] (rev a1)
> 0b:00.0 Network controller: Atheros Communications Inc. AR928X
> Wireless Network Adapter (PCI-Express) (rev 01)
> 0c:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8058
> PCI-E Gigabit Ethernet Controller (rev 13)
> 0d:03.0 FireWire (IEEE 1394): Texas Instruments TSB82AA2 IEEE-1394b
> Link Layer Controller (rev 02)
>=20
> (more verbose lspci included in bugzilla entry)
>=20
> At least one other person has seen this on a desktop non-mac machine
> (see bugzilla) entry.
> What would you like from dmesg?
> Is the following enough?
>=20
> Aug  9 12:09:11 nike kernel: sky2: driver version 1.27
> Aug  9 12:09:11 nike kernel: sky2 0000:0c:00.0: PCI INT A -> GSI 17
> (level, low) -> IRQ 17
> Aug  9 12:09:11 nike kernel: sky2 0000:0c:00.0: Yukon-2 EC Ultra chip=
 revision 3
> Aug  9 12:09:11 nike kernel: sky2 0000:0c:00.0: eth0: addr 00:1f:5b:x=
x:xx:xx
> ...
> Aug  9 12:09:22 nike kernel: sky2 0000:0c:00.0: eth0: enabling interf=
ace
> Aug  9 12:09:22 nike kernel: ADDRCONF(NETDEV_UP): eth0: link is not r=
eady
> ...
> Aug  9 12:09:25 nike kernel: sky2 0000:0c:00.0: eth0: Link is up at
> 1000 Mbps, full duplex, flow control rx
> Aug  9 12:09:25 nike kernel: ADDRCONF(NETDEV_CHANGE): eth0: link beco=
mes ready
> ...
> Aug 11 16:21:19 nike kernel: sky2 0000:0c:00.0: eth0: rx length error=
:
> status 0x5d60100 length 2982
> Aug 11 16:21:27 nike kernel: eth0: hw csum failure.
> ...
>=20
> I'd just like to point out that this has happened something like 5
> times in the past 30 days on a machine which is on 24/7 with wired
> ethernet plugged in nearly 100% of the time.

Probably he only thing the driver can do in these cases is automaticall=
y
turn off checksumming if it suspects the chip is having problems.

Is there a known good older kernel version?

