From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 15:26:24 +0200
Message-ID: <20170609132624.GC20756@lunn.ch>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
 <20170609082541.GC31464@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jason@lakedaemon.net, gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43203 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751534AbdFIN0a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 09:26:30 -0400
Content-Disposition: inline
In-Reply-To: <20170609082541.GC31464@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 09, 2017 at 10:25:41AM +0200, Antoine Tenart wrote:
> On Thu, Jun 08, 2017 at 09:42:21AM -0700, Florian Fainelli wrote:
> > On 06/08/2017 02:26 AM, Antoine Tenart wrote:
> > > This patch adds the xMDIO interface support in the mvmdio driver. This
> > > interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> > > of now). The xSMI interface supported by this driver complies with the
> > > IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> > > 22). The xSMI interface is used by 10GbE devices.
> > 
> > In the previous version you were properly defining a new compatibles
> > strings for xmdio, but now you don't and instead you runtime select the
> > operations based on whether MII_ADDR_C45 is set in the register which is
> > fine from a functional perspective.
> > 
> > If I get this right, the xMDIO controller is actually a superset of the
> > MDIO controller and has an extra MVMDIO_XSMI_ADDR_REG register to
> > preform C45 accesses?
> 
> This is also a mistake. It's not a superset as the register offsets are
> different. So we can't use the same smi operations in both cases. We
> would need dedicated xmdio smi operations, but I don't think there is a
> board where a c22 PHY is connected to the xMDIO interface.

Hi Antoine

I don't have the datasheet...

Is it described as one device, which can do c22 via one set of
registers, and c45 by another set of registers?

Or are there two separate devices. In particular, does each device
have there own MDC and MDIO pins? Do we have an C22 only device/bus,
and a C45 only device/bus?

    Andrew
