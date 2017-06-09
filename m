From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 20:56:12 +0100
Message-ID: <20170609195611.GU4902@n2100.armlinux.org.uk>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
 <20170609132624.GC20756@lunn.ch>
 <20170609140922.GD31464@kwain>
 <20170609144936.GF20756@lunn.ch>
 <20170609145630.GE31464@kwain>
 <20170609150340.GH20756@lunn.ch>
 <20170609162216.GF31464@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:52708 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751595AbdFIT4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:56:30 -0400
Content-Disposition: inline
In-Reply-To: <20170609162216.GF31464@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 06:22:16PM +0200, Antoine Tenart wrote:
> On Fri, Jun 09, 2017 at 05:03:40PM +0200, Andrew Lunn wrote:
> > > There are two busses, one generating c22 transactions and one generating
> > > c45 transactions. Each bus has its own MDC/MDIO pins.
> > 
> > O.K. That is what i wanted to know. So we want two completely separate
> > device tree bindings, busses registered with Linux, etc.
> > 
> > Thanks for clarification.
> 
> So in the end I need one change in v3: to bind the xSMI usage to
> marvell,xmdio and the SMI one to marvell,orion-mdio. (Plus the GENMASK
> and offset comments).

Also, you need to
1. trap out on incorrect MII_ADDR_C45 in regnum for the interface.
2. mask the dev_addr with GENMASK(4, 0) (as merely shifting will leave
   the MII_ADDR_C45 bit set.)
3. moving MVMDIO_XSMI_PHYADDR_SHIFT / MVMDIO_XSMI_DEVADDR_SHIFT /
   MVMDIO_XSMI_READ_OPERATION / MVMDIO_XSMI_WRITE_OPERATION under the
   MVMDIO_XSMI_MGNT_REG reg - these definitions are nothing to do with
   MVMDIO_XSMI_ADDR_REG.
4. fixing MVMDIO_XSMI_WRITE_OPERATION to be 5 << 26, not 5 << 27.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
