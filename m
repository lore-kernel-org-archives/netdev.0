From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 06:06:41 +0200
Message-ID: <20161014040641.GE5822@lunn.ch>
References: <5800159B.3080708@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45159 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754120AbcJNEGo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 00:06:44 -0400
Content-Disposition: inline
In-Reply-To: <5800159B.3080708@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 13, 2016 at 06:15:39PM -0500, Timur Tabi wrote:
> I need help with a program I've discovered with my driver
> (ethernet/qualcomm/emac/) that occurs in the following process:
> 
> 1. Load the driver
> 1a. Driver calls mdiobus_register (see emac_phy_config), which calls
> mdiobus_scan(), which calls get_phy_device()
> 1b. get_phy_device() performs MDIO bus operations, which means the
> bus and the external phy need to be active.
> 2. Bring up the interface
> 3. Bring down the interface.  This calls phy_disconnect() which
> calls phy_detach() which calls phy_suspend().  This puts the
> external phy to sleep.
> 4. Unload the driver
> 5. Re-load the driver.
> 5a. Driver calls mdiobus_register again, but this time the call to
> get_phy_device() fails because the external phy is asleep and does
> not respond to MDIO transactions.

Hi Timur

Normally, a sleeping PHY does respond to MDIO. Otherwise, how do you
wake it?

So i assume this phy has some other means to wake it. What is this
means?

      Andrew
