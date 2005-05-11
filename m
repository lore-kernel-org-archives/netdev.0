From: Manuel Perez Ayala <mperaya@alcazaba.unex.es>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Wed, 11 May 2005 08:04:46 +0200
Message-ID: <20050511080446.fnstrvtzq8gk8884@158.49.151.11>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
	<1115743966.8570.26.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <1115743966.8570.26.camel@rh4>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>
> I assume you have a 5700 or 5701 as this code that controls the DMA
> boundaries only affects those devices. Please confirm with the lspci
> output or tg3's probing output.
>

This is the lspci output

0000:00:0b.0 Host bridge: Apple Computer Inc. UniNorth 1.5 AGP
0000:00:10.0 VGA compatible controller: nVidia Corporation NV11=20
[GeForce2 MX/MX
400] (rev b2)
0001:10:0b.0 Host bridge: Apple Computer Inc. UniNorth 1.5 PCI
0001:10:13.0 Ethernet controller: Broadcom Corporation NetXtreme=20
BCM5700 Gigabit
Ethernet (rev 12)
0001:10:17.0 ff00: Apple Computer Inc. KeyLargo Mac I/O (rev 03)
0001:10:18.0 USB Controller: Apple Computer Inc. KeyLargo USB
0001:10:19.0 USB Controller: Apple Computer Inc. KeyLargo USB
0002:20:0b.0 Host bridge: Apple Computer Inc. UniNorth 1.5 Internal PCI
0002:20:0e.0 ffff: Lucent Microelectronics FW323 (rev ff)
0002:20:0f.0 Ethernet controller: Apple Computer Inc. UniNorth GMAC (Sun =
GEM)
(rev 01)

> Can you print out the value of tp->dma_rwctrl in hex just before it is
> written to the register in the line:
>
> tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
>
> Please do this for the working and non-working driver versions.

Value of tp->dma_rwctrl

non-working driver:

On init of driver

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)

tg3: tg3_test_dma #1: 76FF280F

eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

I've added the output of the tp->dma_rwctrl value in hex to kern messages=
:
tg3: tg3_test_dma #1: 76FF280F

On init of network interface:

tg3: tg3_reset_hw: 76FF280F

tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is on for TX and on for RX.

I've added too the output of the tp->dma_rwctrl value in hex in the=20
tg3_reset_hw
function:
tg3: tg3_reset_hw: 76FF280F


Working driver:

On init of driver:

tg3.c:v3.10 (September 14, 2004)
PCI: Enabling device 0001:10:13.0 (0014 -> 0016)

tg3: tg3_test_dma #1: 76FF120F

eth1: Tigon3 [partno(BCM95700A6) rev 7102 PHY(5401)] (PCI:33MHz:64-bit)
10/100/1000BaseT Ethernet 00:04:76:3b:51:ae
eth1: RXcsums[1] LinkChgREG[1] MIirq[1] ASF[0] Split[0] WireSpeed[0] TSOc=
ap[0]

And on init of the network interface:

tg3: tg3_reset_hw: 76FF120F

tg3: eth1: Link is up at 1000 Mbps, full duplex.
tg3: eth1: Flow control is on for TX and on for RX.


Hope this will be useful

Thanks


----------
Manuel Perez Ayala
mperaya@alcazaba.unex.es
Facultad de Biblioteconom=EDa y Documentaci=F3n
Universidad de Extremadura
