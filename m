From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] fs_enet: Add support for MPC512x to
 fs_enet driver
Date: Tue, 09 Feb 2010 12:13:56 -0800 (PST)
Message-ID: <20100209.121356.216640014.davem@davemloft.net>
References: <4B5871F2.9090005@grandegger.com>
	<20100121.180311.228791894.davem@davemloft.net>
	<20100209152317.5303b1b3@wker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, netdev@vger.kernel.org, dzu@denx.de, wd@denx.de,
	jcrigby@gmail.com, kosmo@semihalf.com, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca
To: agust@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab0BIUNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 15:13:42 -0500
In-Reply-To: <20100209152317.5303b1b3@wker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anatolij Gustschin <agust@denx.de>
Date: Tue, 9 Feb 2010 15:23:17 +0100

> In my understanding, in the ESP scsi driver the set of defines for
> the register offsets is common for all chip drivers. The chip driver
> methods for register access translate the offsets because the
> registers on some chips are at different intervals (4-byte, 1-byte,
> 16-byte for mac_esp.c). But the register order is the same for
> different chips.
> 
> In our case non only the register order is not the same for 8xx
> FEC and 5121 FEC, but there are also other differences, different
> reserved areas between several registers, some registers are
> available only on 8xx and some only on 5121.

That only means you would need to use a table based register address
translation scheme, rather than a simple calculation.  Something
like:

static unsigned int chip_xxx_table[] =
{
	[GENERIC_REG_FOO]	 = CHIP_XXX_FOO,
	...
};

static u32 chip_xxx_read_reg(struct chip *p, unsigned int reg)
{
	unsigned int reg_off = chip_xxx_table[reg];

	return readl(p->regs + reg_off);
}

And this table can have special tokens in entries for
registers which do not exist on a chip, so you can trap
attempted access to them in these read/write handlers.

Please stop looking for excuses to fork this driver, a
unified driver I think can be done cleanly.
