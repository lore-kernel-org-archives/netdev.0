From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Fri, 31 Jul 2009 13:20:23 +0200
Message-ID: <20090731112023.GJ2714@pengutronix.de>
References: <20090729082010.GZ2714@pengutronix.de> <4A7011BA.7040906@grandegger.com> <20090730083729.GC2714@pengutronix.de> <4A715F0E.2070605@grandegger.com> <20090730092730.GD2714@pengutronix.de> <4A719463.2060201@grandegger.com> <4A7200F3.3010608@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:44714 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbZGaLUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 07:20:24 -0400
Content-Disposition: inline
In-Reply-To: <4A7200F3.3010608@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 30, 2009 at 10:22:11PM +0200, Wolfgang Grandegger wrote:
> Wolfgang Grandegger wrote:
> > Sascha Hauer wrote:
> [...]
> >> 	errcnt = readl(&regs->errcnt);
> >> 	rxerr = (errcnt >> 8) & 0xff;
> >> 	txerr = errcnt & 0xff;
> >> 	if ((rxerr >= 96 || txerr >= 96) && state == CAN_STATE_ERROR_ACTIVE)
> >> 		state = CAN_STATE_ERROR_WARNING;
> > 
> > Yes, or do not handle the state in the "case 0" above appropriately. The
> > CAN spec only specifies the bus error states error active, error passive
> > and bus off. The warning is somehow optional but available on most CAN
> > controllers. Nevertheless, we should create a message if the ISR
> > realizes a state changes.
> 
> FYI, I will be on holiday for the next 1.5 weeks.

Lucky you ;)

I just did some tests with the CAN cable disconnected. It turns out that
I get flooded by interrupts caused by ACK errors. The system is
completely unresponsive then. Unfortunately the ACK error interrupt
can't be disabled seperately, so we have to disable error interrupts
completely once we get an ACK error. I'm thinking about setting up a
timer and poll the error status register then.

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
