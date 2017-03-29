From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v3 0/5] net-next: dsa: add Mediatek MT7530 support
Date: Wed, 29 Mar 2017 17:38:18 +0800
Message-ID: <1490780303-18598-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <sean.wang@mediatek.com>, <Landen.Chao@mediatek.com>,
        <keyhaede@gmail.com>, <objelf@gmail.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <matthias.bgg@gmail.com>,
        <robh+dt@kernel.org>, <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

MT7530 is a 7-ports Gigabit Ethernet Switch that could be found on
Mediatek router platforms such as MT7623A or MT7623N which includes 7-port
Gigabit Ethernet MAC and 5-port Gigabit Ethernet PHY. Among these ports,
The port from 0 to 4 are the user ports connecting with the remote devices
while the port 5 and 6 are the CPU ports connecting into Mediatek Ethernet
GMAC.

The patch series integrated Mediatek MT7530 into DSA support which
includes the most of the essential callbacks such as tag insertion for
port distinguishing, port control, bridge offloading, STP setup and
ethtool operations to allow DSA to model each user port into independently
standalone netdevice as the other DSA driver had done.

Changes since v1:
- rebased into 4.11-rc1
- refined binding document including below five items 
- changed the type of mediatek,mcm into bool
- used reset controller binding for MCM reset and removed "mediatek,ethsys"
  property from binding
- reused CPU port's ethernet Phandle instead of creating new one and removed
  "mediatek,ethernet" property from binding
- aligned naming for GPIO reset with dsa/marvell.txt
- added phy-mode as required property child nodes within ports container
- handled gpio reset with devm_gpiod_* API
- refined comment words
- removed condition for CDM setting since the setup looks both fine for all cases
- allowed of_find_net_device_by_node() working with pointing the device node into
  real netdev instance
- fixed Kbuild warnings

Changes since v2:
- reuse readx_poll_timeout() to poll
- add proper macro instead of hard coding
- treat inconsistent cpu port as warning
- remove the usage for regmap-debugfs
- show error message when invalid id is found
- put the logic for the setup of trgmii into adjut_link()
- refine and reuse logic between port_[disable,enable], and default port setup 
- correct typo

Sean Wang (5):
  dt-bindings: net: dsa: add Mediatek MT7530 binding
  net-next: dsa: add Mediatek tag RX/TX handler
  net-next: ethernet: mediatek: add CDM able to recognize the tag for
    DSA
  net-next: ethernet: mediatek: add device_node of GMAC pointing into
    the netdev instance
  net-next: dsa: add dsa support for Mediatek MT7530 switch

 .../devicetree/bindings/net/dsa/mt7530.txt         |   92 ++
 drivers/net/dsa/Kconfig                            |    8 +
 drivers/net/dsa/Makefile                           |    2 +-
 drivers/net/dsa/mt7530.c                           | 1126 ++++++++++++++++++++
 drivers/net/dsa/mt7530.h                           |  390 +++++++
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        |    8 +
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |    4 +
 include/net/dsa.h                                  |    1 +
 net/dsa/Kconfig                                    |    2 +
 net/dsa/Makefile                                   |    1 +
 net/dsa/dsa.c                                      |    3 +
 net/dsa/dsa_priv.h                                 |    3 +
 net/dsa/tag_mtk.c                                  |  117 ++
 13 files changed, 1756 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/mt7530.txt
 create mode 100644 drivers/net/dsa/mt7530.c
 create mode 100644 drivers/net/dsa/mt7530.h
 create mode 100644 net/dsa/tag_mtk.c

-- 
1.9.1
