From: Tony Lindgren <tony@atomide.com>
Subject: Re: smsc9220 with omap3
Date: Fri, 26 Jun 2009 08:53:24 +0300
Message-ID: <20090626055323.GW7352@atomide.com>
References: <4A40FE32.1030708@compulab.co.il> <20090623222928.GM29236@buzzloop.caiaq.de> <4A423DA0.6010306@compulab.co.il> <20090624202158.GD29236@buzzloop.caiaq.de> <4A4310B3.8060902@compulab.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Mack <daniel@caiaq.de>, steve.glendinning@smsc.com,
	netdev@vger.kernel.org,
	ARM Linux <linux-arm-kernel@lists.arm.linux.org.uk>
To: Mike Rapoport <mike@compulab.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-01-ewr.mailhop.org ([204.13.248.71]:60175 "EHLO
	mho-01-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432AbZFZFxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 01:53:41 -0400
Content-Disposition: inline
In-Reply-To: <4A4310B3.8060902@compulab.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mike Rapoport <mike@compulab.co.il> [090625 08:58]:
> Daniel Mack wrote:
> > On Wed, Jun 24, 2009 at 05:52:16PM +0300, Mike Rapoport wrote:
> >>> We're using that chip connected to a PXA300 and it works well, so I
> >>> wouldn't suspect the driver. Does it work from any other scenario like
> >>> the bootloader? And I don't know OMAP, but it might be helpful to others
> >>> if you posted your platform_data config.
> >> The platform_data I use is:
> >> static struct smsc911x_platform_config smsc911x_config = {
> >> 	.irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
> >> 	.irq_type = SMSC911X_IRQ_TYPE_PUSH_PULL,
> >> 	.flags = SMSC911X_USE_32BIT | SMSC911X_FORCE_INTERNAL_PHY,
> >> };
> >>
> >> The chip is properly detected, and if I tweak the loopback test to return 0, the
> >>  driver does not complain any more. Moreover, it seems that RX work, at least
> >> ifconfig reports non-zero values for RX packets. Still, there is no even single
> >> packet transmitted from the smsc9220 :(
> >> I suspect that there's some problem with the hardware, and probably someone
> >> encountered similar problems and may have found a solution.
> > 
> > For the electrical part, there is a reference schematic from SMSC.
> 
> Yeah, I know. We actually copied the design from the reference.
> 
> > And on PXA, you need some dumb CMOS logic or a CPLD for proper interfacing
> > of the digital bus. Don't know if the latter is also necessary for OMAP.
> 
> Do you mean that the logic is necessary to demux address and data? If yes, OMAP
> does not need it.
> Besides, we have no problem in CPU <-> lan9220 communications, there's no
> network traffic from the chip. :(

In addition to checking the pin muxing.. Do you have the GPMC configured for
the timings? See arch/arm/mach-omap2/gpmc.c.

Regards,

Tony
