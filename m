From: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: [PATCH net-next v3 0/2] add UniPhier AVE ethernet support
Date: Wed, 25 Oct 2017 10:07:57 +0900
Message-ID: <1508893679-11727-1-git-send-email-hayashi.kunihiko@socionext.com>
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This series adds support for Socionext AVE ethernet controller implemented
on UniPhier SoCs. This driver supports RGMII/RMII modes.

v1: http://www.spinics.net/lists/netdev/msg454292.html
v2: http://www.spinics.net/lists/netdev/msg460109.html

The PHY patch included in v1 has already separated in:
http://www.spinics.net/lists/netdev/msg454595.html

Changes since v2:
- replace clk_get() with devm_clk_get()
- replace reset_control_get() with devm_reset_control_get_optional_shared()
- add error return when the error occurs on the above *_get functions
- sort soc data and compatible strings
- remove clearly obvious comments
- modify dt-bindings document consistent with these modifications

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

 .../bindings/net/socionext,uniphier-ave4.txt       |   48 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/socionext/Kconfig             |   22 +
 drivers/net/ethernet/socionext/Makefile            |    4 +
 drivers/net/ethernet/socionext/sni_ave.c           | 1746 ++++++++++++++++++++
 6 files changed, 1822 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
 create mode 100644 drivers/net/ethernet/socionext/Kconfig
 create mode 100644 drivers/net/ethernet/socionext/Makefile
 create mode 100644 drivers/net/ethernet/socionext/sni_ave.c

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
