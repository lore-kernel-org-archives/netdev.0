From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH V3] CAN: Add Flexcan CAN controller driver
Date: Sun, 02 Aug 2009 21:22:47 +0200
Message-ID: <4A75E787.2050207@grandegger.com>
References: <20090729082010.GZ2714@pengutronix.de>	<4A7011BA.7040906@grandegger.com>	<20090730083729.GC2714@pengutronix.de>	<4A715F0E.2070605@grandegger.com>	<20090730092730.GD2714@pengutronix.de>	<4A719463.2060201@grandegger.com> <4A7200F3.3010608@grandegger.com> <20090731112023.GJ2714@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Socketcan-core@lists.berlios.de,
	Linux Netdev List <netdev@vger.kernel.org>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:50320 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbZHBTWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:22:51 -0400
In-Reply-To: <20090731112023.GJ2714@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sascha Hauer wrote:
> On Thu, Jul 30, 2009 at 10:22:11PM +0200, Wolfgang Grandegger wrote:
>> Wolfgang Grandegger wrote:
>>> Sascha Hauer wrote:
>> [...]
>>>> 	errcnt = readl(&regs->errcnt);
>>>> 	rxerr = (errcnt >> 8) & 0xff;
>>>> 	txerr = errcnt & 0xff;
>>>> 	if ((rxerr >= 96 || txerr >= 96) && state == CAN_STATE_ERROR_ACTIVE)
>>>> 		state = CAN_STATE_ERROR_WARNING;
>>> Yes, or do not handle the state in the "case 0" above appropriately. The
>>> CAN spec only specifies the bus error states error active, error passive
>>> and bus off. The warning is somehow optional but available on most CAN
>>> controllers. Nevertheless, we should create a message if the ISR
>>> realizes a state changes.
>> FYI, I will be on holiday for the next 1.5 weeks.
> 
> Lucky you ;)

A last answer before I go really offline...

> I just did some tests with the CAN cable disconnected. It turns out that
> I get flooded by interrupts caused by ACK errors. The system is
> completely unresponsive then. Unfortunately the ACK error interrupt
> can't be disabled seperately, so we have to disable error interrupts
> completely once we get an ACK error. I'm thinking about setting up a
> timer and poll the error status register then.

I suspect that you are using 1MB/s. That's the infamous bus error
flooding we realize with the SJA1000 on low-end systems as well. The
right solution is using the NAPI (RX polling) interface.

Wolfgang.
