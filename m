From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: dsa: Broadcom BCM53xx switches support
Date: Thu,  9 Jun 2016 18:23:52 -0700
Message-ID: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:34124 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbcFJBYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:03 -0400
Received: by mail-pa0-f65.google.com with SMTP id ug1so3866726pab.1
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series adds support for the Broadcom BCM53xx series aka RoboSwitches.

This driver is largely based on Jonas Gorski's b53 driver for OpenWrt which can
be found here:

https://dev.openwrt.org/browser/trunk/target/linux/generic/files/drivers/net/phy/b53

a few bug fixes and DSA-ifycation later, here is what we got.

This has been successfully tested in the following configurations:

- Broadcom BCM53011 using the SRAB bus layer with 4 ports LAN, 1 port WAN

- A Broadcom BCM7445 device with an internal Starfighter 2 switch (bcm_sf2.c)
  and a Broadcom BCM53125 hanging off one of its ports connected via MDIO, creating
  two trees hanging off each other, and this works!

- A Broadcom BCM53125 MDIO connected to a Lamobo/Bananapi R1 board using the STMMAC
  MDIO driver

For now, we do not enable Broadcom tags, because there are different
generations of switches being supported which have different tag formats, but
the plan is to enable them later on.

Support for different HW features will be added later: EEE, Compact Field
Processor (TCAM) once this initial cut gets accepted.

Testing and bug reports welcome!

Florian Fainelli (5):
  net: dsa: b53: Add support for Broadcom RoboSwitch
  net: dsa: b53: Add BCM7445 quirk
  net: dsa: b53: Implement ARL add/del/dump operations
  net: dsa: b53: Add bridge support
  net: dsa: b53: Plug in VLAN support

 Documentation/devicetree/bindings/net/dsa/b53.txt |   90 ++
 MAINTAINERS                                       |    8 +
 drivers/net/dsa/Kconfig                           |    2 +
 drivers/net/dsa/Makefile                          |    2 +
 drivers/net/dsa/b53/Kconfig                       |   33 +
 drivers/net/dsa/b53/Makefile                      |    6 +
 drivers/net/dsa/b53/b53_common.c                  | 1787 +++++++++++++++++++++
 drivers/net/dsa/b53/b53_mdio.c                    |  392 +++++
 drivers/net/dsa/b53/b53_mmap.c                    |  260 +++
 drivers/net/dsa/b53/b53_priv.h                    |  387 +++++
 drivers/net/dsa/b53/b53_regs.h                    |  434 +++++
 drivers/net/dsa/b53/b53_spi.c                     |  331 ++++
 drivers/net/dsa/b53/b53_srab.c                    |  415 +++++
 include/linux/platform_data/b53.h                 |   33 +
 14 files changed, 4180 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/b53.txt
 create mode 100644 drivers/net/dsa/b53/Kconfig
 create mode 100644 drivers/net/dsa/b53/Makefile
 create mode 100644 drivers/net/dsa/b53/b53_common.c
 create mode 100644 drivers/net/dsa/b53/b53_mdio.c
 create mode 100644 drivers/net/dsa/b53/b53_mmap.c
 create mode 100644 drivers/net/dsa/b53/b53_priv.h
 create mode 100644 drivers/net/dsa/b53/b53_regs.h
 create mode 100644 drivers/net/dsa/b53/b53_spi.c
 create mode 100644 drivers/net/dsa/b53/b53_srab.c
 create mode 100644 include/linux/platform_data/b53.h

-- 
2.7.4
