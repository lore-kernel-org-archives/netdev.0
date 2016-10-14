From: Timur Tabi <timur@codeaurora.org>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 07:39:48 -0500
Message-ID: <5800D214.70808@codeaurora.org>
References: <5800159B.3080708@codeaurora.org> <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org> <20161014120624.GG5822@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35522 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752900AbcJNMju (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 08:39:50 -0400
In-Reply-To: <20161014120624.GG5822@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn wrote:
> Please can you tell us what PHY which is, and how it is put to sleep
> and woken up.

It's the at803x driver.

http://lxr.free-electrons.com/source/drivers/net/phy/at803x.c

It goes to sleep in its at803x_suspend() function, which is called by 
phy_suspend().

There is a corresponding at803x_resume().  The problem is that this is 
not called by mdiobus_register().  I'm guessing that mdiobus_register() 
assumes that the phy is awake.

It seems like a catch-22.  mdiobus_register() assumes that the phy is 
awake, but you can't wake up the phy until after you call 
mdiobus_register().

> If the PHY cannot be woken up using MDIO, then maybe you need to look
> at the mdio bus reset call?

I looked at that, but it won't work because there is no phydev when the 
reset function is called:

http://lxr.free-electrons.com/source/drivers/net/phy/mdio_bus.c#L328

It's the same catch-22.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
