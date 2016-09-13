From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 11:40:43 +0200
Message-ID: <5c028659-db7e-9a98-7ec1-1e2d19d135f9@phrozen.org>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913012304.GC3585@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:58730 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757460AbcIMJks (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 05:40:48 -0400
In-Reply-To: <20160913012304.GC3585@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 13/09/2016 03:23, Andrew Lunn wrote:
> So lets see if i have this right.
> 
> Port 0 has no internal phy.
> Port 1 has an internal PHY at MDIO address 0.
> Port 2 has an internal PHY at MDIO address 1.
> ...
> Port 5 has an internal PHY ad MDIO address 4.
> Port 6 has no internal PHY.

Hi Andrew

correct. port 0 is the cpu port. I initially thought that port6 can also
be used as te cpu port but there are various places in the datasheet
stating that the cpu port is 0. in some of the reference designs, port6
is wired to a 2nd gmac of the cpu and in those cases port 6 is then
hardwired to port 5 of the switch and called wan. right now the driver
does not support this feature. i have changed the code to always assume
that port is the cpu port and will send a patch later to allow the
port5/6 wan port setup once the series got accepted.

> 
> This is why you have funky port numbers, and phy_to_port.

this is legacy code from the series Matthieu posted. i agree though that
its a bit dirty. Sergey already told me that the devicetree is also bad
because of this as the unit address of the device tree node and reg
property are not aligned.

> 
> I think it would be a lot cleaner to handle this in qca8k_phy_read()
> and qca8k_phy_write(). 

ok, i will simply substract 1 from the phy_addr inside the mdio
callbacks. this would make the code more readable and make the DT
binding compliant with the ePAPR spec.

> 
> Also, the comment it a bit misleading. You are probing the PHY ID, not
> the switch ID. At least for the Marvell switches, different switches
> can have the same embedded PHY. It would be annoying to find there is
> another incompatible switch with the same PHY ID.

there is only an 8bit field inside the MASK_CTRL register (0x000) which
is 0x13. I've sent an email to QCA asking if this a unique identifier.

> Is the embedded PHY compatible with the at803x driver?

I've sent an email to QCA asking about this

	John
