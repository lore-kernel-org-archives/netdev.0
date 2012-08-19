From: Tabi Timur-B04825 <B04825@freescale.com>
Subject: Re: [PATCH] net/fsl: introduce Freescale 10G MDIO driver
Date: Sun, 19 Aug 2012 21:26:49 +0000
Message-ID: <50315A18.2040105@freescale.com>
References: <1345233792-14985-1-git-send-email-timur@freescale.com>
 <20120819205724.GA27555@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Tabi Timur-B04825 <B04825@freescale.com>,
	Fleming Andy-AFLEMING <afleming@freescale.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:7980
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937Ab2HSV0y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Aug 2012 17:26:54 -0400
In-Reply-To: <20120819205724.GA27555@electric-eye.fr.zoreil.com>
Content-Language: en-US
Content-ID: <A8EB91CCC7876A4AA9F6FC0B56360E96@mgd.freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
>> >+	/* Wait till the bus is free */
>> >+	status = spin_event_timeout(
>> >+		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);
>> >+	if (!status) {
>> >+		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
>> >+		return -ETIMEDOUT;
>> >+	}
> This code - comment included - is repeated several times. You may
> consider factoring it out in some xgmac_mdio_free_bus_wait function.

But it's just one line and a test.  The function would look like this:

bool xgmac_mdio_free_bus_wait(struct tgec_mdio_controller __iomem *regs)
{
	uint32_t status;

	status = spin_event_timeout(
		!((in_be32(&regs->mdio_stat)) & MDIO_STAT_BSY), TIMEOUT, 0);

	return status != 0;
}

and then

	if (!xgmac_mdio_free_bus_wait(regs)) {
		dev_dbg(&bus->dev, "%s: timeout waiting for stat\n", __func__);
		return -ETIMEDOUT;
	}

I don't see any real savings here.

-- 
Timur Tabi
Linux kernel developer at Freescale
