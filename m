From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv3 0/4] Add DT support for fixed PHYs
Date: Tue,  4 Mar 2014 11:58:20 +0100
Message-ID: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
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
Received: from top.free-electrons.com ([176.31.233.9]:40091 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756631AbaCDK61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 05:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Here is a third version of the patch set that adds a Device Tree
binding and the related code to support fixed PHYs.

Since the second version, the changes have been:

 * Rebased on top of v3.14-rc1, and re-tested on hardware.

 * Removed the RFC tag, since there seems to be some real interest in
   this feature, and the code has gone through several iterations
   already.

 * The error handling in fixed_phy_register() has been fixed.

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

Posts of previous versions:

  RFCv1: http://www.spinics.net/lists/netdev/msg243253.html
  RFCv2: http://lists.infradead.org/pipermail/linux-arm-kernel/2013-September/196919.html

Thanks,

Thomas

Thomas Petazzoni (4):
  net: phy: decouple PHY id and PHY address in fixed PHY driver
  net: phy: extend fixed driver with fixed_phy_register()
  of: provide a binding for fixed link PHYs
  net: mvneta: add support for fixed links

 .../devicetree/bindings/net/fixed-link.txt         | 34 +++++++++
 .../bindings/net/marvell-armada-370-neta.txt       |  4 +-
 drivers/net/ethernet/marvell/mvneta.c              | 10 +--
 drivers/net/phy/fixed.c                            | 81 +++++++++++++++++++---
 drivers/of/of_mdio.c                               | 24 +++++++
 include/linux/of_mdio.h                            | 15 ++++
 include/linux/phy_fixed.h                          | 11 +++
 7 files changed, 163 insertions(+), 16 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/fixed-link.txt

-- 
1.8.3.2
