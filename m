From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy: tune get_phy_c45_ids to support more c45 phy
Date: Fri, 25 Apr 2014 15:50:57 -0400 (EDT)
Message-ID: <20140425.155057.855268491985585038.davem@davemloft.net>
References: <1398305856-9761-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com
To: Shengzhou.Liu@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbaDYTu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 15:50:59 -0400
In-Reply-To: <1398305856-9761-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shengzhou Liu <Shengzhou.Liu@freescale.com>
Date: Thu, 24 Apr 2014 10:17:36 +0800

>  		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
> -			*phy_id = 0xffffffff;
> -			return 0;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | 6;
> +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> +			if (phy_reg < 0)
> +				return -EIO;
> +			c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | 5;
> +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> +			if (phy_reg < 0)
> +				return -EIO;
> +			c45_ids->devices_in_package |= (phy_reg & 0xffff);
> +			/* If mostly Fs, there is no device there,
> +			 * let's get out of here.
> +			 */

If ->devices_in_package is zero, we will not get to this code path, so
this comment makes no sense at all to me.

You need to explain the situation more accurately, and clearly.  I have
no idea what exactly the devices report in this situation, nor how your
code is trying to cope with that situation.

Please work slowly, and carefully, to write clear and accurate
comments as well as a commit message which describes (in detail) the
situation here.

Someone in the future will end up having to read this change and
try to understand it as well, so it's not just for me.

Thanks.
