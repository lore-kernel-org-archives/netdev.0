From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 5/10] Neterion: New driver: Hardware init &
 configuration
Date: Wed, 25 Mar 2009 01:12:20 -0700 (PDT)
Message-ID: <20090325.011220.227287174.davem@davemloft.net>
References: <1237968776.1655.267.camel@flash>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbZCYIMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:12:32 -0400
In-Reply-To: <1237968776.1655.267.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ramkrishna Vepa <ram.vepa@neterion.com>
Date: 25 Mar 2009 00:13:12 -0800

> This patch takes care of Initialization and configuration steps of
> Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized Server Adapter.

This driver won't build on 32-bit platforms, not even x86.

You didn't build test on i386?

You have to provide a readq/writeq implementation on 32-bit
machines so that you can choose in what order it is safe
to read/write the upper and lower 32-bit halfs of a 64-bit
register.

See the following from drivers/net/niu.c:

#ifndef readq
static u64 readq(void __iomem *reg)
{
	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
}

static void writeq(u64 val, void __iomem *reg)
{
	writel(val & 0xffffffff, reg);
	writel(val >> 32, reg + 0x4UL);
}
#endif

And DO NOT JUST COPY THIS!  Think about how your hardware behaves
if the 64-bit registers are accessed 32-bits at a time, especially
wrt. state clearing when reading interrupt status registers.
