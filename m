From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 V5] net: Add Aeroflex Gaisler 10/100/1G Ethernet
 MAC driver
Date: Tue, 02 Feb 2010 07:31:22 -0800 (PST)
Message-ID: <20100202.073122.120457083.davem@davemloft.net>
References: <1264664629-25128-1-git-send-email-kristoffer@gaisler.com>
	<1264664629-25128-2-git-send-email-kristoffer@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: kristoffer@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45602
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756010Ab0BBPbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2010 10:31:09 -0500
In-Reply-To: <1264664629-25128-2-git-send-email-kristoffer@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristoffer Glembo <kristoffer@gaisler.com>
Date: Thu, 28 Jan 2010 08:43:49 +0100

> +	struct amba_prom_registers *prom_regs;
> +	unsigned int addr;
 ...
> +	irqs = (int *) of_get_property(ofdev->node, "interrupts", NULL);
> +	prom_regs = (struct amba_prom_registers *) of_get_property(ofdev->node, "reg", NULL);
 ...
> +	addr = prom_regs->phys_addr;
 ...
> +struct amba_prom_registers {
> +	unsigned int phys_addr;
> +	unsigned int reg_size;
> +};

These kinds of constructs should never be necessary in an OF driver.

The device probing layer calculates OF device resources that you can
use to obtain the register (op->resource[]) and IRQ (op->irq[])
mappings portably.

And you use of_ioremap() on the resource object to map the register
I/O space properly, and of_iounmap() it on unload.

See drivers/net/niu.c:niu_of_probe() for an example.

Please fix this up, thank you.
