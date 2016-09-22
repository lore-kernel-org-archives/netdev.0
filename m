From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 0/3] add support for RGMII on GMAC0 through TRGMII hardware module
Date: Thu, 22 Sep 2016 10:33:53 +0800
Message-ID: <1474511636-11644-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <andrew@lunn.ch>,
        <f.fainelli@gmail.com>, <keyhaede@gmail.com>, <objelf@gmail.com>,
        Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sean Wang <sean.wang@mediatek.com>

By default, GMAC0 is connected to built-in switch called
MT7530 through the proprietary interface called Turbo RGMII
(TRGMII). TRGMII also supports well for RGMII as generic external
PHY uses but requires some slight changes to the setup of TRGMII 
and doesn't have well support on current driver.

So this patchset
1) provides the slight changes of the setup for RGMII can work
   through TRGMII
2) adds additional setting "trgmii" as PHY_INTERFACE_MODE_TRGMII 
   about phy-mode on device tree to make GMAC0 distinguish which
   mode it runs
3) changes dynamically source clock, TX/RX delay and interface
   mode on TRGMII for adapting various link

Changes since v1:
- fixed the style of comment which doesn't have a space at 
   the beginning and end of comment lines
- add support for phy-mode "trgmii" as PHY_INTERFACE_MODE_TRGMII 
   into linux/phy.h
- enhance the Documentation about device tree binding for trgmii
  which is applicable only for GMAC0 which uses fixed-link

Sean Wang (3):
  net: ethernet: mediatek: add extension of phy-mode for TRGMII
  net: ethernet: mediatek: add support for GMAC0 connecting with
    external PHY through TRGMII
  net: ethernet: mediatek: add the dts property to set if TRGMII
    supported on GMAC0

 .../devicetree/bindings/net/mediatek-net.txt       |  5 +++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        | 34 +++++++++++++++++++++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        | 34 +++++++++++++++++++++-
 include/linux/phy.h                                |  3 ++
 4 files changed, 73 insertions(+), 3 deletions(-)

-- 
1.9.1
