From: <Woojung.Huh@microchip.com>
Subject: [PATCH v5 net-next 0/5] dsa: add Microchip KSZ9477 DSA driver
Date: Wed, 31 May 2017 20:19:00 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA5556@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <UNGLinuxDriver@microchip.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:46975 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdEaUTC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 16:19:02 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Woojung Huh <Woojung.Huh@microchip.com>

This series of patches is for Microchip KSZ9477 DSA driver.
KSZ9477 is 7 ports GigE switch with numerous advanced features.
5 ports are 10/100/1000 Mbps internal PHYs and 2 ports have
Interfaces to SGMII, RGMII, MII or RMII.

This patch supports VLAN, MDB, FDB and port mirroring offloads.

Welcome reviews and comments from community.

Note: Tests are performed on internal development board.

V5
- add missing MODULE_LICENSE

V4
- update per review comments
- cosmetic changes
- net/dsa/tag_ksz.c
  * skb_put() & memset() are changed to skb_put_padto()
- drivers/net/dsa/microchip/ksz_common.
   * vlan access mutex is updated
   * mib_names[] is changed to static const

V3
- update per review comments
- cosmetic changes
- drivers/net/dsa/microchip/ksz_common.c 
  * clean up ksz_switch_chips[] 
  * consolidate checking loops into functions
  * update mutex for better locking
  * replace devm_kmalloc_array() to devm_kcalloc()
- MAINTAINERS
  * add missing net/dsa/tag_ksz.c

V2
- update per review comments
- several cosmetic changes
- net/dsa/tag_ksz.c
  * constants are changed to defines
  * remove skb_linearize() in ksz_rcv()
  * ksz_xmit()checks skb tailroom before allocate new skb
- drivers/net/phy/micrel.c
  * remove PHY_HAS_MAGICANEG from ksphy_driver[]
- drivers/net/dsa/microchip/ksz_common.c
  * add timeout to avoid endless loop
  * port initialization is move to ksz_port_enable() instead of  ksz_setup_ports()
- Documentation/devicetree/bindings/net/dsa/ksz.txt
  * fix typo and indentations

Woojung Huh (5):
  dsa: add support for Microchip KSZ tail tagging
  phy: micrel: add Microchip KSZ 9477 Switch PHY support
  dsa: add DSA switch driver for Microchip KSZ9477
  net: dsa: Add Microchip KSZ switches binding
  dsa: add maintainer of Microchip KSZ switches

 Documentation/devicetree/bindings/net/dsa/ksz.txt |   72 +
 MAINTAINERS                                       |   10 +
 drivers/net/dsa/Kconfig                           |    2 +
 drivers/net/dsa/Makefile                          |    1 +
 drivers/net/dsa/microchip/Kconfig                 |   12 +
 drivers/net/dsa/microchip/Makefile                |    2 +
 drivers/net/dsa/microchip/ksz_9477_reg.h          | 1676 +++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.c            | 1279 ++++++++++++++++
 drivers/net/dsa/microchip/ksz_priv.h              |  210 +++
 drivers/net/dsa/microchip/ksz_spi.c               |  216 +++
 drivers/net/phy/micrel.c                          |   11 +
 include/linux/micrel_phy.h                        |    2 +
 include/linux/platform_data/microchip-ksz.h       |   29 +
 include/net/dsa.h                                 |    1 +
 net/dsa/Kconfig                                   |    3 +
 net/dsa/Makefile                                  |    1 +
 net/dsa/dsa.c                                     |    3 +
 net/dsa/dsa_priv.h                                |    3 +
 net/dsa/tag_ksz.c                                 |  101 ++
 19 files changed, 3634 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/ksz.txt
 create mode 100644 drivers/net/dsa/microchip/Kconfig
 create mode 100644 drivers/net/dsa/microchip/Makefile
 create mode 100644 drivers/net/dsa/microchip/ksz_9477_reg.h
 create mode 100644 drivers/net/dsa/microchip/ksz_common.c
 create mode 100644 drivers/net/dsa/microchip/ksz_priv.h
 create mode 100644 drivers/net/dsa/microchip/ksz_spi.c
 create mode 100644 include/linux/platform_data/microchip-ksz.h
 create mode 100644 net/dsa/tag_ksz.c

-- 
2.7.4
