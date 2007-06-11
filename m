From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] MII bitbang driver should generate MII bus phy_mask dynamically
Date: Mon, 11 Jun 2007 13:57:20 -0500
Message-ID: <9A3A59AA-FADC-4A98-9129-0E00F122188E@freescale.com>
References: <1181548417.5217.13.camel@mark>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Mark Zhan <rongkai.zhan@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:54271 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbXFKS5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:57:19 -0400
In-Reply-To: <1181548417.5217.13.camel@mark>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jun 11, 2007, at 02:53, Mark Zhan wrote:

> Current MII bitbang bus driver hard-codes the phy mask of mii_bus to
> ~0x09, which is actually specific to the FSL boards. This patch will
> make the bitbang driver to generate MII bus phy_mask dynamically,  
> by the
> PHY irq info provided by the platform.
>
> Signed-off-by: Mark Zhan <rongkai.zhan@windriver.com>

[...]

>
> +	new_bus->phy_mask = 0xFFFFFFFF;
> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		if (pdata->irq[i] != -1)
> +			new_bus->phy_mask &= ~(1 << i);
> +


This doesn't work.  There are a couple of things wrong:

1) Don't use -1, use PHY_POLL

2) As you can tell from #1, the absence of a set interrupt for a  
particular PHY does not indicate it doesn't exist.  Rather, it  
indicates it doesn't have an interrupt.

I think you need to add a phy_mask to the platform data, and then set  
it appropriately.  We also need to look into adding that for the mdio  
nodes in the device tree, so it will get passed in properly.

Andy

