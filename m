From: Michael Buesch <mb@bu3sch.de>
Subject: Re: bcm43xx: "transmit timed out" and apparent hang with "preemptible periodic work" patches
Date: Thu, 29 Jun 2006 18:47:14 +0200
Message-ID: <200606291847.15113.mb@bu3sch.de>
References: <87ac80ps5o.fsf@briny.internal.ondioline.org> <200606291731.50598.mb@bu3sch.de> <20060629164716.GA4548@tuba>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Paul Collins <paul@briny.ondioline.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:53414
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750943AbWF2Qrt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 12:47:49 -0400
To: Martin Langer <martin-langer@gmx.de>
In-Reply-To: <20060629164716.GA4548@tuba>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 June 2006 18:47, Martin Langer wrote:
> On Thu, Jun 29, 2006 at 05:31:50PM +0200, Michael Buesch wrote:
> > On Thursday 29 June 2006 17:22, Larry Finger wrote:
> > > Michael Buesch wrote:
> > > > On Thursday 29 June 2006 10:24, Paul Collins wrote:
> > > >> Michael Buesch <mb@bu3sch.de> writes:
> > > >>> On Monday 26 June 2006 14:43, Michael Buesch wrote:
> > > >>>> Try to get more logs.
> > > >>>> I suggest to do a netconsole for logging.
> > > >>> Also note that current softmac trees have a patch missing.
> > > >>> It seems it got lost somewhere after my merge request.
> > > >>> I already contacted John in private for this, but no reply, yet.
> > > >>> The patch is attached. Maybe it fixes your issue.
> > > >> On a preempt kernel I can trigger the hang easily,
> > > > 
> > > > How? I need to reproduce it to get a clue and fix it. :)
> > > > I have no idea where it might come from (I don't even know
> > > > what exactly happens).
> > > > 
> > > > And please provide a _full_ dmesg log without comments inbetween
> > > > after triggering the hang (with a full Controller Restart cycle).
> > > > 
> > > 
> > > I am having what I think is a similar problem, although my system does not hang. I cannot send dmesg 
> > > output as the buffer is quickly filled with the channel assertion messages you see below, but here 
> > > is the relevant section of /var/log/messages.
> > > 
> > > Jun 29 01:22:08 larrylap kernel: NETDEV WATCHDOG: wlan0: transmit timed out
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Controller RESET (TX timeout) ...
> > > Jun 29 01:22:08 larrylap kernel: ACPI: PCI interrupt for device 0000:02:00.0 disabled
> > > Jun 29 01:22:08 larrylap kernel: PCI: Enabling device 0000:02:00.0 (0000 -> 0002)
> > > Jun 29 01:22:08 larrylap kernel: ACPI: PCI Interrupt 0000:02:00.0[A] -> Link [LNKA] -> GSI 11 
> > > (level, low) -> IRQ 11
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Chip ID 0x4306, rev 0x2
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Number of cores: 6
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 0: ID 0x800, rev 0x2, vendor 0x4243, enabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 1: ID 0x812, rev 0x4, vendor 0x4243, enabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 2: ID 0x80d, rev 0x1, vendor 0x4243, enabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 3: ID 0x807, rev 0x1, vendor 0x4243, disabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 4: ID 0x804, rev 0x7, vendor 0x4243, enabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Core 5: ID 0x812, rev 0x4, vendor 0x4243, disabled
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Ignoring additional 802.11 core.
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: PHY connected
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Detected PHY: Version: 1, Type 2, Revision 1
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Radio turned off
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Radio turned off
> > > Jun 29 01:22:08 larrylap kernel: bcm43xx: Controller restarted
> > > Jun 29 01:23:08 larrylap kernel: bcm43xx: ASSERTION FAILED (channel >= 1 && channel <= 14) at: 
> > > drivers/net/wireless/bcm43xx/bcm43xx_radio.c:79:channel2freq_bg()
> > 
> > WTF is that???
> > How is that possible to happen?
> 
> This can also be a bug in the hardware, firmware

Ehm, how? The channel value is completely in software and never read
back from hardware.

> or maybe in the mips  
> driver code. Running the original closed source linux mips driver I got 
> this funny result during normal operation
> 
> Channel: 2147439075
> Signal: 718984492 dBm
> Noise: 2147439075 dBm

A bug which we implemented, too, because we did not see it?
Well, possible. Although I don't find it :).

-- 
Greetings Michael.
