From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net-next v2 0/4] net: mvpp2: optional PHYs and GoP link irq
Date: Fri,  1 Sep 2017 11:04:51 +0200
Message-ID: <20170901090455.32316-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, linux-kernel@vger.kernel.org,
        mw@semihalf.com, stefanc@marvell.com,
        miquel.raynal@free-electrons.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

This series aims at making the driver work when no PHY is connected
between a port and the physical layer and not described as a fixed-phy.
This is useful for some usecases such as when a switch is connected
directly to the serdes lanes. It can also be used for SFP ports on the
7k-db and 8k-db while waiting for the phylink support to land in (which
should be part of another series).

This series makes the phy optional in the PPv2 driver, and then adds
the support for the GoP port link interrupt to handle link status
changes on such ports.

This was tested using the SFP ports on the 7k-db and 8k-db boards.

Thanks!
Antoine

Since v1:
  - Now use phy_interface_mode_is_rgmii() in the GoP link patch.
  - Added one cosmetic patch to take advantage of phy_interface_mode_is_rgmii()
    in the whole PPv2 driver.

Antoine Tenart (4):
  net: mvpp2: take advantage of the is_rgmii helper
  net: mvpp2: make the phy optional
  net: mvpp2: use the GoP interrupt for link status changes
  Documentation/bindings: net: marvell-pp2: add the link interrupt

 .../devicetree/bindings/net/marvell-pp2.txt        |   2 +-
 drivers/net/ethernet/marvell/mvpp2.c               | 211 ++++++++++++++++++---
 2 files changed, 187 insertions(+), 26 deletions(-)

-- 
2.13.5
