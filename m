From: Hein Tibosch <hein_tibosch@yahoo.es>
Subject: Re: net/macb: clear tx/rx completion flags in ISR
Date: Fri, 19 Apr 2013 13:13:26 +0800
Message-ID: <5170D276.6070208@yahoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Ludovic Desroches <ludovic.desroches@atmel.com>
To: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bosmailout10.eigbox.net ([66.96.186.10]:53983 "EHLO
	bosmailout10.eigbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754575Ab3DSF6C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 01:58:02 -0400
Received: from bosmailscan12.eigbox.net ([10.20.15.12])
	by bosmailout10.eigbox.net with esmtp (Exim)
	id 1UT3ho-0006WY-Uk
	for netdev@vger.kernel.org; Fri, 19 Apr 2013 01:17:52 -0400
Received: from bosmailscan24.eigbox.net ([10.20.15.24])
	by bosmailscan12.eigbox.net with esmtp (Exim)
	id 1UT3ho-0005Cp-Qy
	for netdev@vger.kernel.org; Fri, 19 Apr 2013 01:17:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Steffen,

> At least in the cadence IP core on the Xilinx Zynq SoC the TCOMP/RCOMP flags
> are not auto-cleaned. As these flags are evaluated, they need to be cleaned.

This patch does not work for at least the AVR32 platform. Both RCOMP/RCOMP
are cleared by *reading* the ISR and writing them would be fatal.

Could you tell me the version of the macb of Xilinx Zynq?

    u32 version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
            | MACB_GREGS_VERSION;

On an AP7000 it reads as 0x0000010D

I am thinking of making a patch like:

    if (bp->version >= xxx)
        macb_writel(bp, ISR, MACB_BIT(TCOMP));

    if (bp->version >= xxx)
        macb_writel(bp, ISR, MACB_BIT(RCOMP));

which would make it work on both platforms.


Hein
