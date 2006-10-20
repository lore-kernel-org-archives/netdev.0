From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Fri, 20 Oct 2006 14:25:50 -0400
Message-ID: <453914AE.2090604@gentoo.org>
References: <45330803.mail261110C22@lwfinger.net> <4538EF6F.3030305@gentoo.org> <200610201855.21183.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:45028 "EHLO
	smtp151.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S964800AbWJTS0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 14:26:46 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610201855.21183.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> Which kernel are you using exactly?

2.6.19-rc2

>> bcm43xx: Radio turned off
>> bcm43xx: DMA-32 0x0200 (RX) max used slots: 7/64
>> bcm43xx: DMA-32 0x02A0 (TX) max used slots: 0/512
>> bcm43xx: DMA-32 0x0280 (TX) max used slots: 0/512
>> bcm43xx: DMA-32 0x0260 (TX) max used slots: 0/512
>> bcm43xx: DMA-32 0x0240 (TX) max used slots: 0/512
>> bcm43xx: DMA-32 0x0220 (TX) max used slots: 7/512
>> bcm43xx: DMA-32 0x0200 (TX) max used slots: 0/512
>> bcm43xx: ASSERTION FAILED (bcm43xx_status(bcm) == 
>> BCM43xx_STAT_INITIALIZED) at: 
>> drivers/net/wireless/bcm43xx/bcm43xx_main.c:1852:bcm43xx_interrupt_handler()
> 
> That one's strange...
> 
> 
> I'm interrested in seeing a complete dmesg log of this.

On load:

bcm43xx driver
ACPI: PCI Interrupt Link [LK1E] enabled at IRQ 11
ACPI: PCI Interrupt 0000:03:00.0[A] -> Link [LK1E] -> GSI 11 (level, 
low) -> IRQ 11
PCI: Setting latency timer of device 0000:03:00.0 to 64
bcm43xx: Chip ID 0x4311, rev 0x1
bcm43xx: Number of cores: 4
bcm43xx: Core 0: ID 0x800, rev 0x11, vendor 0x4243, enabled
bcm43xx: Core 1: ID 0x812, rev 0xa, vendor 0x4243, disabled
bcm43xx: Core 2: ID 0x817, rev 0x3, vendor 0x4243, disabled
bcm43xx: Core 3: ID 0x820, rev 0x1, vendor 0x4243, enabled
bcm43xx: PHY connected
bcm43xx: Detected PHY: Version: 4, Type 2, Revision 8
bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
bcm43xx: Radio turned off
bcm43xx: Radio turned off

ifup:
bcm43xx: PHY connected
bcm43xx: Microcode rev 0x127, pl 0xe (2005-04-18  02:36:27)
bcm43xx: Radio turned on
bcm43xx: Chip initialized
bcm43xx: 32-bit DMA initialized
bcm43xx: Keys cleared
bcm43xx: Selected 802.11 core (phytype 2)

ifdown:
bcm43xx: Radio turned off
bcm43xx: DMA-32 0x0200 (RX) max used slots: 0/64
bcm43xx: DMA-32 0x02A0 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0280 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0260 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0240 (TX) max used slots: 0/512
bcm43xx: DMA-32 0x0220 (TX) max used slots: 42/512
bcm43xx: DMA-32 0x0200 (TX) max used slots: 0/512

ifup now fails:
# ifconfig eth1 up
SIOCSIFFLAGS: No such device

bcm43xx: IRQ_READY timeout
bcm43xx: core_up for active 802.11 core failed (-19)


