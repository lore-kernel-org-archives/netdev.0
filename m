From: Sven Joachim <svenjoac@gmx.de>
Subject: Re: [ 57/72] genirq: Unmask oneshot irqs when thread was not woken
Date: Sun, 04 Mar 2012 23:08:32 +0100
Message-ID: <87sjhoc93z.fsf@turtle.gmx.de>
References: <20120228010511.GA8453@kroah.com>
	<20120228010434.412979550@linuxfoundation.org>
	<87hay4dqjr.fsf@turtle.gmx.de> <20120304215307.GA27157@burratino>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Jonathan Nieder <jrnieder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.22]:41011 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755020Ab2CDWIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 17:08:35 -0500
In-Reply-To: <20120304215307.GA27157@burratino> (Jonathan Nieder's message of
	"Sun, 4 Mar 2012 15:53:07 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-03-04 22:53 +0100, Jonathan Nieder wrote:

> Sven Joachim wrote:
>
>> The laptop is an Acer TravelMate 2490 with a Broadcom chip:
>>
>> ,----
>> | 06:02.0 Network controller: Broadcom Corporation BCM4318 [AirForce One 54g] 802.11g Wireless LAN Controller (rev 02)
>> | 	Subsystem: AMBIT Microsystem Corp. TravelMate 2410
>> | 	Flags: bus master, fast devsel, latency 64, IRQ 10
>> | 	Memory at d0002000 (32-bit, non-prefetchable) [size=8K]
>> | 	Kernel driver in use: b43-pci-bridge
>> `----
>
> Odd.  Does it use that driver with both working and non-working
> kernels?

Yes, although lsmod just tells me that "b43" is loaded.  And
"dmesg | grep b43" shows this:

,----
| [    0.628622] b43-pci-bridge 0000:06:02.0: enabling device (0000 -> 0002)
| [    0.628780] b43-pci-bridge 0000:06:02.0: PCI INT A -> Link[LNKG] -> GSI 10 (level, low) -> IRQ 10
| [    0.628795] b43-pci-bridge 0000:06:02.0: setting latency timer to 64
| [    5.648519] b43-phy0: Broadcom 4318 WLAN found (core revision 9)
| [   36.267694] b43-phy0: Loading firmware version 410.2160 (2007-05-26 15:32:10)
`----

The kernel configuration has these b43 related parameters:

CONFIG_B43=m
CONFIG_B43_SSB=y
CONFIG_B43_PCI_AUTOSELECT=y
CONFIG_B43_PCICORE_AUTOSELECT=y
# CONFIG_B43_PCMCIA is not set
# CONFIG_B43_SDIO is not set
CONFIG_B43_PIO=y
# CONFIG_B43_PHY_N is not set
CONFIG_B43_PHY_LP=y
# CONFIG_B43_PHY_HT is not set
CONFIG_B43_HWRNG=y
# CONFIG_B43_DEBUG is not set
# CONFIG_B43LEGACY is not set
CONFIG_SSB_B43_PCI_BRIDGE=y


Cheers,
       Sven
