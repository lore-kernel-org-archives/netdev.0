From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 2 Aug 2017 04:58:47 +0200
Message-ID: <20170802025847.GB8415@lunn.ch>
References: <1501623460-3575-1-git-send-email-timur@codeaurora.org>
 <1501623460-3575-2-git-send-email-timur@codeaurora.org>
 <20170801231554.GA8415@lunn.ch>
 <6a6ac2c1-eb78-d7fd-5721-49dd6a550913@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48468 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751562AbdHBC6w (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 22:58:52 -0400
Content-Disposition: inline
In-Reply-To: <6a6ac2c1-eb78-d7fd-5721-49dd6a550913@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 01, 2017 at 07:56:31PM -0500, Timur Tabi wrote:
> On 8/1/17 6:15 PM, Andrew Lunn wrote:
> >Pause frames are something you can auto-negotiate at the PHY
> >level. Should you also be clearing some bits in the phydev, so the
> >peer knows pause frames are not supported?
> 
> When pause frame autonegotiation is enabled in the driver, that only means
> that the driver looks at what the PHY has autonegotiated, and then
> configures the MAC to match that.
> 
> The driver doesn't touch the PHY at all.  It leaves all that to phylib.
> 
> Now if autonegotiation is disabled in the driver, then it just hard-codes
> those TX/RX settings in the driver.  Are you saying I should program the PHY
> at the point to disable autonegotiation on the PHY level?  If so, then I
> don't know how to do that.  I just assumed that the MAC never tells the PHY
> what to do.

Documentation/networking/phy.txt says:

Pause frames / flow control

 The PHY does not participate directly in flow control/pause frames except by
 making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
 MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
 controller supports such a thing. Since flow control/pause frames generation
 involves the Ethernet MAC driver, it is recommended that this driver takes care
 of properly indicating advertisement and support for such features by setting
 the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
 either before or after phy_connect() and/or as a result of implementing the
 ethtool::set_pauseparam feature.

So just check if the MAC driver is setting SUPPORTED_Pause and
SUPPORTED_AsymPause.

	Andrew
