From: "Bishop, Mark" <Mark.Bishop@cooperindustries.com>
Subject: Question with interfacing to a SMSC9215
Date: Mon, 16 Jan 2012 11:02:24 -0500
Message-ID: <5D308BD40154E4439D82454FE483A50205AF1FBA@EVS4.nam.ci.root>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooperlighting-sw.cooperlighting.com ([216.130.131.68]:21381
	"EHLO cooperlighting-sw.cooperlighting.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751338Ab2APQDC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jan 2012 11:03:02 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm working on a custom board and I have most of it working expect for
the connection to the smsc 9215.  The board is based off the bf548 ezkit
(arch/blackfin/mach-bf548/boards/ezkit.c) and in there they have the INT
to the 9215 set to IRQ_PE8.  On my board I need to have it set to PG12.
I made the change to the file, but I am getting this:

smsc911x: Driver version 2008-10-21.
setting trigger mode 8 for irq 211 failed
(_bfin_gpio_irq_type+0x0/0x1e4)

I have verified that my pull up resistor for the INT is present and that
it is set for active low.  What else am I missing?

#include <linux/smsc911x.h>

static struct resource smsc911x_resources[] = {
        {
                .name = "smsc911x-memory",
                .start = 0x24000000,
                .end = 0x24000000 + 0xFF,
                .flags = IORESOURCE_MEM,
        },
        {
                /* .start = IRQ_PE8, */
                /* .end = IRQ_PE8, */
                .start = IRQ_PG12,
                .end = IRQ_PG12,
                .flags = IORESOURCE_IRQ | IORESOURCE_IRQ_LOWLEVEL,
        },
};

static struct smsc911x_platform_config smsc911x_config = {
        .flags = SMSC911X_USE_32BIT, 
        .irq_polarity = SMSC911X_IRQ_POLARITY_ACTIVE_LOW,
        .irq_type = SMSC911X_IRQ_TYPE_OPEN_DRAIN,
        .phy_interface = PHY_INTERFACE_MODE_MII,
};

static struct platform_device smsc911x_device = {
        .name = "smsc911x",
        .id = 0,
        .num_resources = ARRAY_SIZE(smsc911x_resources),
        .resource = smsc911x_resources,
        .dev = {
                .platform_data = &smsc911x_config,
        },
};
