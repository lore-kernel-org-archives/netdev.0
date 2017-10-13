From: Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
Subject: [PATCH net-next v2 0/2] add UniPhier AVE ethernet support
Date: Fri, 13 Oct 2017 09:35:26 +0900
Message-ID: <1507854928-4357-1-git-send-email-hayashi.kunihiko@socionext.com>
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        devicetree@vger.kernel.org,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        Masami Hiramatsu <masami.hiramatsu@linaro.org>,
        Jassi Brar <jaswinder.singh@linaro.org>,
        Kunihiko Hayashi <hayashi.kunihiko@socionext.com>
To: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series adds support for Socionext AVE ethernet controller implemented
on UniPhier SoCs. This driver supports RGMII/RMII modes.

v1: http://www.spinics.net/lists/netdev/msg454292.html

The PHY patch included in v1 has already separated in:
http://www.spinics.net/lists/netdev/msg454595.html

Changes since v1:
- add/remove devicetree properties and sub-node
  - remove "internal-phy-interrupt" and "desc-bits" property
  - add SoC data structures based on compatible strings
  - add node operation to apply "mdio" sub-node
- add support for features
  - add support for {get,set}_pauseparam and pause frame operations
  - add support for ndo_get_stats64 instead of ndo_get_stats
- replace with desiable functions
  - replace check for valid phy_mode with phy_interface{_mode}_is_rgmii()
  - replace phy attach message with phy_attached_info()
  - replace 32bit operation with {upper,lower}_32_bits() on ave_wdesc_addr()
  - replace nway_reset and get_link with generic functions
- move operations to proper functions
  - move phy_start_aneg() to ndo_open,
    and remove unnecessary PHY interrupt operations
    See http://www.spinics.net/lists/netdev/msg454590.html
  - move irq initialization and descriptor memory allocation to ndo_open
  - move initialization of reset and clock and mdiobus to ndo_init
- fix skbuffer operations
  - fix skb alignment operations and add Rx buffer adjustment for descriptor
    See http://www.spinics.net/lists/netdev/msg456014.html
  - add error returns when dma_map_single() failed 
- clean up code structures
  - clean up wait-loop and wake-queue conditions
  - add ave_wdesc_addr() and offset definitions
  - add ave_macaddr_init() to clean up mac-address operation
  - fix checking whether Tx entry is not enough
  - fix supported features of phydev
  - add necessary free/disable operations
  - add phydev check on ave_{get,set}_wol()
  - remove netif_carrier functions, phydev initializer, and Tx budget check
- change obsolate codes
  - replace ndev->{base_addr,irq} with the members of ave_private
- rename goto labels and mask definitions, and remove unused codes

Kunihiko Hayashi (2):
  dt-bindings: net: add DT bindings for Socionext UniPhier AVE
  net: ethernet: socionext: add AVE ethernet driver

 .../bindings/net/socionext,uniphier-ave4.txt       |   53 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/socionext/Kconfig             |   22 +
 drivers/net/ethernet/socionext/Makefile            |    4 +
 drivers/net/ethernet/socionext/sni_ave.c           | 1773 ++++++++++++++++++++
 6 files changed, 1854 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
 create mode 100644 drivers/net/ethernet/socionext/Kconfig
 create mode 100644 drivers/net/ethernet/socionext/Makefile
 create mode 100644 drivers/net/ethernet/socionext/sni_ave.c

-- 
2.7.4
