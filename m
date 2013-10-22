From: "Florian Fainelli" <f.fainelli@gmail.com>
Subject: [PATCH 0/4 net-next] net: phy: add Generic Netlink switch
 configuration API
Date: Tue, 22 Oct 2013 11:23:45 -0700
Message-ID: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, s.hauer@pengutronix.de, nbd@openwrt.org,
	blogic@openwrt.org, jogo@openwrt.org, gary@mlbassoc.com,
	"Florian Fainelli" <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2631 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753736Ab3JVSYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 14:24:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patchset aims at providing Linux with a simple and extensible Ethernet
switch configuration API. It comes with two drivers, one for Broadcom BCM53xx
aka Roboswitch and a simulation/fake one to help developpers.

These patches have been used in OpenWrt since 2008 to drive various
Ethernet switches commonly found in small home and office wireless routers.

The documentation part of the patch explains why this solution was developped
in contrast to using DSA, user-space or something else deeply in details, but
to summarize:

- DSA is Marvell centric and messes up with the actual Ethernet frames, its
  control path is scattered around bridge, ethtool and iproute...

- swconfig is focused on providing a standard control path for Ethernet
  switches out there from $vendor and is extensible without core kernel
  changes and user-space changes too thanks to its netlink interface

Florian Fainelli (3):
  net: phy: add Generic Netlink Ethernet switch configuration API
  tools: add Generic Netlink switch configuration tool
  net: phy: add fake switch driver

Jonas Gorski (1):
  net: phy: add Broadcom B53 switch driver

 Documentation/networking/swconfig.txt |  162 ++++
 MAINTAINERS                           |   11 +
 drivers/net/phy/Kconfig               |   16 +
 drivers/net/phy/Makefile              |    3 +
 drivers/net/phy/b53/Kconfig           |   25 +
 drivers/net/phy/b53/Makefile          |    8 +
 drivers/net/phy/b53/b53_common.c      | 1336 +++++++++++++++++++++++++++++++++
 drivers/net/phy/b53/b53_mdio.c        |  425 +++++++++++
 drivers/net/phy/b53/b53_phy_fixup.c   |   55 ++
 drivers/net/phy/b53/b53_priv.h        |  282 +++++++
 drivers/net/phy/b53/b53_regs.h        |  311 ++++++++
 drivers/net/phy/b53/b53_spi.c         |  329 ++++++++
 drivers/net/phy/swconfig-hwsim.c      |  230 ++++++
 drivers/net/phy/swconfig.c            | 1078 ++++++++++++++++++++++++++
 include/linux/platform_data/b53.h     |   32 +
 include/linux/swconfig.h              |  180 +++++
 include/uapi/linux/Kbuild             |    1 +
 include/uapi/linux/swconfig.h         |  103 +++
 tools/Makefile                        |   10 +-
 tools/swconfig/.gitignore             |    2 +
 tools/swconfig/Makefile               |   15 +
 tools/swconfig/cli.c                  |  328 ++++++++
 tools/swconfig/swlib.c                |  786 +++++++++++++++++++
 tools/swconfig/swlib.h                |  244 ++++++
 24 files changed, 5971 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/networking/swconfig.txt
 create mode 100644 drivers/net/phy/b53/Kconfig
 create mode 100644 drivers/net/phy/b53/Makefile
 create mode 100644 drivers/net/phy/b53/b53_common.c
 create mode 100644 drivers/net/phy/b53/b53_mdio.c
 create mode 100644 drivers/net/phy/b53/b53_phy_fixup.c
 create mode 100644 drivers/net/phy/b53/b53_priv.h
 create mode 100644 drivers/net/phy/b53/b53_regs.h
 create mode 100644 drivers/net/phy/b53/b53_spi.c
 create mode 100644 drivers/net/phy/swconfig-hwsim.c
 create mode 100644 drivers/net/phy/swconfig.c
 create mode 100644 include/linux/platform_data/b53.h
 create mode 100644 include/linux/swconfig.h
 create mode 100644 include/uapi/linux/swconfig.h
 create mode 100644 tools/swconfig/.gitignore
 create mode 100644 tools/swconfig/Makefile
 create mode 100644 tools/swconfig/cli.c
 create mode 100644 tools/swconfig/swlib.c
 create mode 100644 tools/swconfig/swlib.h

-- 
1.8.3.2
