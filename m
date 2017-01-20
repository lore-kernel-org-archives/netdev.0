From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v5 0/2] Add support for the ethernet switch on the
 ESPRESSObin
Date: Fri, 20 Jan 2017 23:38:23 +0100
Message-ID: <20170120223823.GA25240@lunn.ch>
References: <20170119214934.27442-1-gregory.clement@free-electrons.com>
 <20170119220607.GA25907@lunn.ch>
 <87a8al64mp.fsf@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40278 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751125AbdATWi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 17:38:29 -0500
Content-Disposition: inline
In-Reply-To: <87a8al64mp.fsf@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually I didn't find anything related to the temperature measurement
> in the datasheet I have. For the 6390 there is a dedicated datsheet for
> the PHY part for the 6352 it is part of the same datasheet.

Hi Gregory

The temperature sensor changes have landed in net-next. If you have
time, please rebase to it and do some tests. Here are the likely
outcomes:

1) Like the 6390, it does not have a valid PHY product ID. Hence the
Marvell PHY driver is not loaded. You can see the PHY ID in

/sys/bus/mdio_bus/devices/*/phy_id

If it is 0x01410000, there is no product ID. I have a workaround for
this.

2) It has a valid phy_id, but it is not known to the marvell driver.
Add an entry to the table at the bottom of drivers/net/phy/marvell.c,
and a new entry in marvell_drivers. I would copy the 1540.


3) The Marvell PHY driver does recognise it, and makes the temperature
available in /sys/class/hwmon/hwmon*/temp1_input. It always returns
-25000mC. Same problem i have with the 6390. No idea how to fix it yet.

4) The Marvell PHY driver does recognise it, and makes the temperature
available in /sys/class/hwmon/hwmon*/temp1_input. The value is O.K. It
all works :-)

Personally, i'm not betting on 4 :-)


    Andrew
