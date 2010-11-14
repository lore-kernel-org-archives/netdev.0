From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2 for on-board 88e8055 fails to detect mac address
Date: Sun, 14 Nov 2010 10:58:44 -0800
Message-ID: <20101114105844.5f708321@nehalam>
References: <AANLkTinR9vpuGoizvNsvnpMBM-UnWS66yMjwMQaKSk_c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Guillaume Leclanche <guillaume@leclanche.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33035 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756776Ab0KNS6s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 13:58:48 -0500
In-Reply-To: <AANLkTinR9vpuGoizvNsvnpMBM-UnWS66yMjwMQaKSk_c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Nov 2010 12:42:06 +0100
Guillaume Leclanche <guillaume@leclanche.net> wrote:

> Hello,
>=20
> I use a "Marvell Technology Group Ltd. 88E8055 PCI-E Gigabit Ethernet
> Controller".
> It seems that=A0the sky2 module doesn't manage to grab the mac addres=
s
> from the HW :
>=20
> [    0.741173] sky2: driver version 1.28
> [    0.741206] sky2 0000:02:00.0: PCI INT A -> GSI 17 (level, low) ->=
 IRQ 17
> [    0.741216] sky2 0000:02:00.0: setting latency timer to 64
> [    0.741244] sky2 0000:02:00.0: Yukon-2 EC Ultra chip revision 2
> [    0.741339] sky2 0000:02:00.0: irq 44 for MSI/MSI-X
> [    0.744781] sky2 0000:02:00.0: eth0: addr 00:00:00:00:00:00
>=20
> Of course I can set the mac address manually with "ip link set eth0
> addr ..." (and then it works fine) but I guess that's not the normal
> behavior from the driver?
>=20
> I'd be happy to troubleshoot but I'm not very used to kernel
> internals, so tell me if you need some output.
> Below a few targeted info about my system.
>=20
> Guillaume
>=20
> 2.6.35-22-generic #35-Ubuntu SMP Sat Oct 16 20:36:48 UTC 2010 i686 GN=
U/Linux
>=20
> 02:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8055
> PCI-E Gigabit Ethernet Controller
> 	Subsystem: Marvell Technology Group Ltd. 88E8055 PCI-E Gigabit
> Ethernet Controller
> 	Flags: bus master, fast devsel, latency 0, IRQ 44
> 	Memory at fe8fc000 (64-bit, non-prefetchable) [size=3D16K]
> 	I/O ports at a800 [size=3D256]
> 	Expansion ROM at fe8c0000 [disabled] [size=3D128K]
> 	Capabilities: [48] Power Management version 3
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [5c] MSI: Enable+ Count=3D1/1 Maskable- 64bit+
> 	Capabilities: [e0] Express Legacy Endpoint, MSI 00
> 	Capabilities: [100] Advanced Error Reporting
> 	Kernel driver in use: sky2
> 	Kernel modules: sky2

The driver reads the MAC address from EEPROM.
There are a couple of possibilities:
1. The driver could have problem when reading the value because of a ti=
ming issue.
   BUT I doubt that because when that happens the driver would see ff:f=
f:ff:ff:ff:ff
2. The BIOS is screwing it up on boot.
   Did you enable the device in the BIOS?
3. The vendor screwed up and didn't program the address into the hardwa=
re.

It doesn't look like a kernel/driver problem at all.



