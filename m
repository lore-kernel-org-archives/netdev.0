From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v6 0/4] Add support for the ethernet switch on the ESPRESSObin
Date: Tue, 24 Jan 2017 21:10:22 +0100
Message-ID: <cover.b0e18efe751186768e720c341693117fdd4d3c16.1485288602.git-series.gregory.clement@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Wilson Ding <dingwei@marvell.com>,
        Kostya Porotchkin <kostap@marvell.com>,
        Joe Zhou <shjzhou@marvell.com>,
        Jon Pannell <jpannell@marvell.com>
To: Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This set of patches adds support for the Marvell Ethernet Topaz switch
family (88E6141/88E6341) which is found on the ESPRESSObin. With this
series the network is usable on this board.

I rebased the series again on the very last net-next/master which
allowed me this time to benefit to the temperature support introduced
by Andrew Lunn.

I still do not have a datasheet about the PHY embedded in the switch
but thanks to the help of Andrew I was able to retrieve the PHY
ID. Then, by using the 88E1510 operations I was able to get temperature
with credible values.

In this series I also added the support of the 88E6141 which is
actually the switch on the boards I tested. The difference with the
88E6341, is the absence of the TCAM on the 88E6141, however I don't
think this feature is used in the driver, so currently for Linux there
is no difference except the switch ID.

Thanks,

Gregory

Changelog:

v5 -> v6:
- rebased on net-next/master (d140199af510)
- Fix the redundant check on mv88e6xxx_6341_family (reported by Julia
  Lawall)
- Add support for the 88E6141
- Move support for temperature sensor in the phy part

Gregory CLEMENT (3):
  net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341
  net: dsa: mv88e6xxx: Add support for ethernet switch 88E6141
  phy: marvell: Add support for the PHY embedded in the topaz switch

Romain Perier (1):
  net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >= num_of_ports

 drivers/net/dsa/mv88e6xxx/chip.c      | 102 ++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  21 +++++-
 drivers/net/phy/marvell.c             |  21 ++++++-
 include/linux/marvell_phy.h           |   1 +-
 4 files changed, 135 insertions(+), 10 deletions(-)

base-commit: 1d0ec6626e558f9eb0043352745c02c42ff13a11
-- 
git-series 0.9.1
