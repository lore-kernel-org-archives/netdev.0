From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: phy: Fix PHY module checks and NULL deref in
 phy_attach_direct()
Date: Thu, 09 Feb 2017 16:22:35 -0500 (EST)
Message-ID: <20170209.162235.1544284000098138678.davem@davemloft.net>
References: <20170209030526.6029-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maowenan@huawei.com, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        nikita.yoush@cogentembedded.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932469AbdBIVp5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 16:45:57 -0500
In-Reply-To: <20170209030526.6029-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed,  8 Feb 2017 19:05:26 -0800

> The Generic PHY drivers gets assigned after we checked that the current
> PHY driver is NULL, so we need to check a few things before we can
> safely dereference d->driver. This would be causing a NULL deference to
> occur when a system binds to the Generic PHY driver. Update
> phy_attach_direct() to do the following:
> 
> - grab the driver module reference after we have assigned the Generic
>   PHY drivers accordingly, and remember we came from the generic PHY
>   path
> 
> - update the error path to clean up the module reference in case the
>   Generic PHY probe function fails
> 
> - split the error path involving phy_detacht() to avoid double free/put
>   since phy_detach() does all the clean up
> 
> - finally, have phy_detach() drop the module reference count before we
>   call device_release_driver() for the Generic PHY driver case
> 
> Fixes: cafe8df8b9bc ("net: phy: Fix lack of reference count on PHY driver")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied to 'net', thanks Florian.
