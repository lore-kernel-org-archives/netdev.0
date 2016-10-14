From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Need help with mdiobus_register and phy
Date: Fri, 14 Oct 2016 15:18:52 +0200
Message-ID: <20161014131852.GM5822@lunn.ch>
References: <5800159B.3080708@codeaurora.org>
 <20161014040641.GE5822@lunn.ch>
 <5800C3C7.60705@codeaurora.org>
 <20161014120624.GG5822@lunn.ch>
 <5800D214.70808@codeaurora.org>
 <20161014124928.GJ5822@lunn.ch>
 <5800D474.1030303@codeaurora.org>
 <20161014125736.GK5822@lunn.ch>
 <5800D796.1030602@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45432 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932454AbcJNNSy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 14 Oct 2016 09:18:54 -0400
Content-Disposition: inline
In-Reply-To: <5800D796.1030602@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 14, 2016 at 08:03:18AM -0500, Timur Tabi wrote:
> Andrew Lunn wrote:
> >Have you tried using the ethernet-phy-id device tree property? It
> >looks like that will allow you to skip get_phy_device and just create
> >the phy device. You can then bring the phy out of sleep in the probe
> >function?
> 
> The problem I'm experiencing is with ACPI, so I can't use any of the
> fancy of_ apis like of_get_phy_id().  But I'll look into it.
> 
> Is it possible that at803x_suspend() is too aggressive?  That's it's
> effectively disabling the phy?  While the phy is suspended, should
> it still respond to MII_PHYSID1 and MII_PHYSID2 requests?

That is a basic assumption of the code. If you cannot read the IDs how
are you supposed to know what device it is, and what quirks you need
to work around its broken features...

Does the datasheet say anything about this?

I would say for this device, suspend() is too aggressive.

  Andrew
