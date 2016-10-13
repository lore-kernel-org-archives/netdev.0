From: Timur Tabi <timur@codeaurora.org>
Subject: Need help with mdiobus_register and phy
Date: Thu, 13 Oct 2016 18:15:39 -0500
Message-ID: <5800159B.3080708@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52538 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbcJMXPm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 19:15:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need help with a program I've discovered with my driver 
(ethernet/qualcomm/emac/) that occurs in the following process:

1. Load the driver
1a. Driver calls mdiobus_register (see emac_phy_config), which calls 
mdiobus_scan(), which calls get_phy_device()
1b. get_phy_device() performs MDIO bus operations, which means the bus 
and the external phy need to be active.
2. Bring up the interface
3. Bring down the interface.  This calls phy_disconnect() which calls 
phy_detach() which calls phy_suspend().  This puts the external phy to 
sleep.
4. Unload the driver
5. Re-load the driver.
5a. Driver calls mdiobus_register again, but this time the call to 
get_phy_device() fails because the external phy is asleep and does not 
respond to MDIO transactions.

I don't know what my driver is doing wrong.  I'm concerned that 
mdiobus_register() is causing MDIO transactions to occur before the rest 
of the EMAC has a chance to initialize.  I've examined many other 
drivers, and I think I'm initializing things in the proper order.

The call to mdiobus_register() occurs before I know what phydev is. 
Since I need the phydev in order to talk to the phy driver, I don't see 
how I can "wake up" the external phy before calling mdiobus_register().

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
