From: Nathaniel Case <ncase@xes-inc.com>
Subject: Re: [PATCH 1/3] mv643xx fixes - Disable interrupts on all ports
	during initialization
Date: Tue, 27 Jun 2006 11:09:04 -0500
Message-ID: <1151424544.31020.12.camel@localhost.localdomain>
References: <200606270951.59024.bcook@bpointsys.com>
	 <44A14BCC.5060708@lucent.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Brent Cook <bcook@bpointsys.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:18338 "EHLO xes-mad.com")
	by vger.kernel.org with ESMTP id S1161139AbWF0QJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2006 12:09:10 -0400
To: John Haller <jhaller@lucent.com>
In-Reply-To: <44A14BCC.5060708@lucent.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 10:16 -0500, John Haller wrote:
> Brent Cook wrote:
> > This patch disable interrupts on all ports during initialization. The current 
> > assumes that the firmware has already disabled all interrupts on all ports. 
> > We have encountered some boards that do not always disable interrupts (XES 
> > XPedite 6200 for instance) on a soft reset. This patch prevents a kernel 
> > panic if a packet is received before the DMA ring buffers are setup for a 
> > port on which interrupts are left enabled by the firmware.
> You probably have bigger problems than the interrupt being left
> enabled.  If the interrupt is left enabled, the DMA engine
> is probably left enabled, and if a packet happens
> to come in before the driver can properly configure them,
> some random part of memory will get overwritten.
> The firmware needs to disable this device before transferring
> control to the kernel, both the interrupts and the DMA,
> there is no way to fix this in the kernel.

I agree that the patch isn't the best fix for this problem.

Brent, for this particular case, I believe there's chip errata for the
Discovery bridge preventing it from resetting itself when the board
resets itself in non-monarch mode.  That's why interrupts are left
enabled.  This issue should never crop up if the board is monarch on the
PCI bus.

So the proper workaround would be for our firmware to account for this
case and disable interrupts, ethernet, etc. on a soft non-monarch reset.
We could also do this in the boot wrapper code as a safety measure.

Also, note that the firmware _will_ already explicitly disable ethernet
before transferring control over to the OS _if_ you're booting over
ethernet instead of flash.

- Nate Case <ncase@xes-inc.com>

