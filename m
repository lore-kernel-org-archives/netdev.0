From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 0/7] net: dsa: add QCA AR8xxx switch family support
Date: Thu, 28 May 2015 18:42:15 -0700
Message-ID: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, mathieu@codeaurora.org, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37377 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbbE2Bmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 21:42:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds initial support for AR8xxx switches using the DSA
subsystem. It currently supports QCA8337 switch, and can be extended to
other hardware in the same family.

This switch was already discussed in the following thread:
https://www.marc.info/?t=142601417400004&r=1&w=2

Below is a typical picture of a QCA8337 used in a standard home gateway
configuration:

	+-----------+       +-----------+
	|           | SGMII |           |
	|       eth0+-------+           +------ 1000baseT MDI ("WAN")
	|        wan|       |  7-port   +------ 1000baseT MDI ("LAN1")
	|   CPU     |       |  ethernet +------ 1000baseT MDI ("LAN2")
	|           | RGMII |  switch   +------ 1000baseT MDI ("LAN3")
	|       eth1+-------+  w/5 PHYs +------ 1000baseT MDI ("LAN4")
	|        lan|       |           |
	+-----------+       +-----------+
	          |   MDIO     |
	          \------------/

The switch is connected to the CPU using 2 xMII interfaces. As DSA only
supports one logical interface to the switch, we split the switch using
device-tree information into 2 parts:
*port 6 (one of the xMII switch port) will be dedicated to one
 particular Ethernet port. From a system perspective, it will be seen as
 a regular PHY.
*port 0 (the other xMII port) will act as the switch master interface

When 2 xMII are used, the switch will therefore be seen as 2 devices: 1
PHY + 1 DSA switch. The configuration of this split is done using driver
specific options in device-tree.

The exact properties are detailed in the Documentation patch below.

Mathieu Olivari (7):
  net: dsa: add new driver for ar8xxx family
  net: dsa: ar8xxx: add ethtool hw statistics support
  net: dsa: ar8xxx: add regmap support
  net: dsa: add QCA tag support
  net: dsa: ar8xxx: enable QCA header support on AR8xxx
  net: dsa: ar8xxx: add support for second xMII interfaces through DT
  Documentation: devicetree: add ar8xxx binding

 .../devicetree/bindings/net/dsa/qca-ar8xxx.txt     |  70 +++
 drivers/net/dsa/Kconfig                            |   9 +
 drivers/net/dsa/Makefile                           |   1 +
 drivers/net/dsa/ar8xxx.c                           | 530 +++++++++++++++++++++
 drivers/net/dsa/ar8xxx.h                           | 157 ++++++
 include/net/dsa.h                                  |   1 +
 net/dsa/Kconfig                                    |   3 +
 net/dsa/Makefile                                   |   1 +
 net/dsa/dsa.c                                      |   6 +
 net/dsa/dsa_priv.h                                 |   2 +
 net/dsa/slave.c                                    |   5 +
 net/dsa/tag_qca.c                                  | 159 +++++++
 12 files changed, 944 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/dsa/qca-ar8xxx.txt
 create mode 100644 drivers/net/dsa/ar8xxx.c
 create mode 100644 drivers/net/dsa/ar8xxx.h
 create mode 100644 net/dsa/tag_qca.c

-- 
2.1.4
