From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Fri,  6 Sep 2013 17:18:17 +0200
Message-ID: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:41883 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752568Ab3IFPSY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 11:18:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here is a second version of the patch set that adds a Device Tree
binding and the related code to support fixed PHYs. Marked as RFC,
this patch set is obviously not intended for merging in 3.12.

Since the first version, the changes have been:

 * Instead of using a 'fixed-link' property inside the Ethernet device
   DT node, with a fairly cryptic succession of integer values, we now
   use a PHY subnode under the Ethernet device DT node, with explicit
   properties to configure the duplex, speed, pause and other PHY
   properties.

 * The PHY address is automatically allocated by the kernel and no
   longer visible in the Device Tree binding.

 * The PHY device is created directly when the network driver calls
   of_phy_connect_fixed_link(), and associated to the PHY DT node,
   which allows the existing of_phy_connect() function to work,
   without the need to use the deprecated of_phy_connect_fixed_link().

The things I am not entirely happy with yet are:

 * The PHY ID is hardcoded to 0xdeadbeef. Ideally, it should be a
   properly reserved vendor/device identifier, but it isn't clear how
   to get one allocated for this purpose.

 * The fixed_phy_register() function in drivers/net/phy/fixed.c has
   some OF references. So ideally, I would have preferred to put this
   code in drivers/of/of_mdio.c, but to call get_phy_device(), we need
   a reference to the mii_bus structure that represents the fixed MDIO
   bus.

 * There is some error management missing in fixed_phy_register(), but
   it can certainly be added easily. This RFC is meant to sort out the
   general idea.

Thanks,

Thomas

Thomas Petazzoni (4):
  net: phy: decouple PHY id and PHY address in fixed PHY driver
  net: phy: extend fixed driver with fixed_phy_register()
  of: provide a binding for fixed link PHYs
  net: mvneta: add support for fixed links

 .../devicetree/bindings/net/fixed-link.txt         | 34 ++++++++++++
 .../bindings/net/marvell-armada-370-neta.txt       |  4 +-
 drivers/net/ethernet/marvell/mvneta.c              | 10 ++--
 drivers/net/phy/fixed.c                            | 63 ++++++++++++++++++----
 drivers/of/of_mdio.c                               | 24 +++++++++
 include/linux/of_mdio.h                            | 15 ++++++
 include/linux/phy_fixed.h                          | 11 ++++
 7 files changed, 145 insertions(+), 16 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt

-- 
1.8.1.2
