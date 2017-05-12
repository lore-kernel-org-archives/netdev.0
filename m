From: <Woojung.Huh@microchip.com>
Subject: [PATCH v2 net-next 0/5] dsa: add Microchip KSZ9477 DSA driver
Date: Fri, 12 May 2017 20:07:51 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A632A0@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>
To: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <sergei.shtylyov@cogentembedded.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:5143 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932439AbdELUHy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 16:07:54 -0400
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
Thanks to Andres, Florian, Sergei for reviews.

Woojung Huh (5):
  dsa: add support for Microchip KSZ tail tagging
  phy: micrel: add Microchip KSZ 9477 Switch PHY support
  dsa: add DSA switch driver for Microchip KSZ9477
  dsa: Add spi support to Microchip KSZ switches
  dsa: add maintainer of Microchip KSZ switches

 Documentation/devicetree/bindings/net/dsa/ksz.txt |   73 +
 MAINTAINERS                                       |    9 +
 drivers/net/dsa/Kconfig                           |    2 +
 drivers/net/dsa/Makefile                          |    1 +
 drivers/net/dsa/microchip/Kconfig                 |   12 +
 drivers/net/dsa/microchip/Makefile                |    2 +
 drivers/net/dsa/microchip/ksz_9477_reg.h          | 1676 +++++++++++++++++++++
 drivers/net/dsa/microchip/ksz_common.c            | 1211 +++++++++++++++
 drivers/net/dsa/microchip/ksz_priv.h              |  209 +++
 drivers/net/dsa/microchip/ksz_spi.c               |  215 +++
 drivers/net/phy/micrel.c                          |   11 +
 include/linux/micrel_phy.h                        |    2 +
 include/linux/platform_data/microchip-ksz.h       |   29 +
 include/net/dsa.h                                 |    1 +
 net/dsa/Kconfig                                   |    3 +
 net/dsa/Makefile                                  |    1 +
 net/dsa/dsa.c                                     |    3 +
 net/dsa/dsa_priv.h                                |    3 +
 net/dsa/tag_ksz.c                                 |  103 ++
 19 files changed, 3566 insertions(+)
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
