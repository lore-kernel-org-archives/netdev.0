From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2 0/4]
Date: Wed, 29 Jan 2014 10:00:14 +0400
Message-ID: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris@zankel.net>, Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David, Ben, Florian, Chris and everybody,

this series improves ethoc behavior in gigabit environment:
- first patch introduces two phylib setters for 'advertising' and 'supported'
  fields of struct phy_device;
- second patch disables gigabit advertisement in the attached PHY making
  possible to use gigabit link without any additional setup;
- third patch adds support to set up MII management bus frequency, adding
  new fields to platform data and to OF bindings;
- fourth patch adds basic ethtool support to ethoc driver.

These changes allow to use KC-705 board with 50MHz xtensa core and OpenCores
10/100 Mbps MAC connected to gigabit network without any additional setup.

Changes v1->v2:
- new patch "phy: provide accessors for 'advertising' and 'supported' fields";
- disable both gigabit advertisement and support;
- drop MDIO bus frequency configurability, always configure for standard
  2.5MHz;
- allow using common clock framework to provide ethoc clock;
- new patch: "net: ethoc: implement ethtool operations";
- drop device tree bindings documentation patch until common bindings format
  for network drivers is decided.

Max Filippov (4):
  phy: provide accessors for 'advertising' and 'supported' fields
  net: ethoc: don't advertise gigabit speed on attached PHY
  net: ethoc: set up MII management bus clock
  net: ethoc: implement ethtool operations

 drivers/net/ethernet/ethoc.c | 130 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/phy.h          |  12 ++++
 include/net/ethoc.h          |   1 +
 3 files changed, 141 insertions(+), 2 deletions(-)

-- 
1.8.1.4
