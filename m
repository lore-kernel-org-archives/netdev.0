From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix circular dependency in of_mdio code
Date: Wed, 02 Jul 2014 00:31:28 -0700 (PDT)
Message-ID: <20140702.003128.935333350824361837.davem@davemloft.net>
References: <1403911415-18690-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: zonque@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaGBHba (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 03:31:30 -0400
In-Reply-To: <1403911415-18690-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <zonque@gmail.com>
Date: Sat, 28 Jun 2014 01:23:35 +0200

> Commit 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev()) introduced a
> circular dependency between libphy and of_mdio.
> 
> depmod: ERROR: <modroot>/kernel/drivers/net/phy/libphy.ko in
> dependency cycle!
> depmod: ERROR: <modroot>/kernel/drivers/of/of_mdio.ko in dependency cycle!
> 
> The problem is that of_mdio.c references &mdio_bus_type and libphy now
> references of_mdiobus_link_phydev.
> 
> Fix this by not exporting of_mdiobus_link_phydev() from of_mdio.ko.
> Make it a static function in mdio_bus.c instead.
> 
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Reported-by: Jeff Mahoney <jeffm@suse.com>
> Fixes: 86f6cf4127 (net: of_mdio: add of_mdiobus_link_phydev())
> ---
> v2: Provide a stub for of_mdiobus_link_phydev() for !CONFIG_OF_MDIO.

Applied, thanks.
