From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Fri, 20 Oct 2006 18:55:20 +0200
Message-ID: <200610201855.21183.mb@bu3sch.de>
References: <45330803.mail261110C22@lwfinger.net> <4538EF6F.3030305@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Stefano Brivio <st3@riseup.net>,
	Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:61395
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932273AbWJTQ4M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 12:56:12 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4538EF6F.3030305@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 20 October 2006 17:46, Daniel Drake wrote:
> Hi Larry,
> 
> Larry Finger wrote:
> > From: Stefano Brivio <stefano.brivio@polimi.it>
> > 
> > The current bcm43xx driver does not contain code to handle PCI-E interfaces
> > such as the BCM4311 and BCM4312. This patch, originally written by Stefano
> > Brivio adds the necessary code to enable these interfaces. 
> 
> I am testing this on a Compaq VS6120US laptop. This is my first 
> experience with using bcm43xx. I'm connecting to a WPA network.

Which kernel are you using exactly?

> bcm43xx: Chip ID 0x4311, rev 0x1
> bcm43xx: Number of cores: 4
> bcm43xx: Core 0: ID 0x800, rev 0x11, vendor 0x4243, enabled
> bcm43xx: Core 1: ID 0x812, rev 0xa, vendor 0x4243, disabled

Pretty high revision numbers.
I think we need additional code to completely support these.
ChipCommon (0x800) has some special things at rev > 10

> bcm43xx: Core 2: ID 0x817, rev 0x3, vendor 0x4243, disabled
> bcm43xx: Core 3: ID 0x820, rev 0x1, vendor 0x4243, enabled
> bcm43xx: PHY connected
> bcm43xx: Detected PHY: Version: 4, Type 2, Revision 8
> bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> 
> Most of the time, it doesn't work. wpa_supplicant scans, gets scan 
> results, tries to associate, and then things stop there. Sometimes the 
> association completes but the WPA PSK stuff times out, sometimes the WPA 
> PSK stuff completes and it gets an IP, but doesn't get any further.
> 
> After bringing down the interface, it cannot be brought up again:
> 
> bcm43xx: Radio turned off
> bcm43xx: DMA-32 0x0200 (RX) max used slots: 7/64
> bcm43xx: DMA-32 0x02A0 (TX) max used slots: 0/512
> bcm43xx: DMA-32 0x0280 (TX) max used slots: 0/512
> bcm43xx: DMA-32 0x0260 (TX) max used slots: 0/512
> bcm43xx: DMA-32 0x0240 (TX) max used slots: 0/512
> bcm43xx: DMA-32 0x0220 (TX) max used slots: 7/512
> bcm43xx: DMA-32 0x0200 (TX) max used slots: 0/512
> bcm43xx: ASSERTION FAILED (bcm43xx_status(bcm) == 
> BCM43xx_STAT_INITIALIZED) at: 
> drivers/net/wireless/bcm43xx/bcm43xx_main.c:1852:bcm43xx_interrupt_handler()

That one's strange...


I'm interrested in seeing a complete dmesg log of this.

-- 
Greetings Michael.
