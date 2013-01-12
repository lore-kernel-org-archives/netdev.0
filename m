From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: phy: remove flags argument from
 phy_{attach,connect,connect_direct}
Date: Fri, 11 Jan 2013 19:47:29 -0800 (PST)
Message-ID: <20130111.194729.1404456884791637120.davem@davemloft.net>
References: <1357903907-16049-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, konszert@marvell.com, afleming@gmail.com
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50447 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656Ab3ALDra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 22:47:30 -0500
In-Reply-To: <1357903907-16049-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Fri, 11 Jan 2013 12:31:47 +0100

> The flags argument of the phy_{attach,connect,connect_direct} functions
> is used to assign a struct phy_device dev_flags with the value passed.
> All callers but the tg3 driver pass the flag 0, which results in the
> underlying PHY drivers in drivers/net/phy/ not being able to actually
> use any of the flags they would check in dev_flags. This patch gets rid of
> the flags argument, and passes phydev->dev_flags to the internal PHY
> library call phy_attach_direct() such that drivers which actually modify
> a phy device dev_flags get the value preserved for use by the underly
> phy driver.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

This change is fine, except for this part:

> diff --git a/include/linux/version.h b/include/linux/version.h
> new file mode 100644
> index 0000000..0c8c321
> --- /dev/null
> +++ b/include/linux/version.h
> @@ -0,0 +1,2 @@
> +#define LINUX_VERSION_CODE 197120
> +#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
