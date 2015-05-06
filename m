From: Jean Delvare <jdelvare@suse.de>
Subject: [PATCH] net: amd-xgbe: Add hardware dependency
Date: Wed, 6 May 2015 09:04:40 +0200
Message-ID: <20150506090440.15fb1eef@endymion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Lendacky <thomas.lendacky@amd.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58438 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038AbbEFHEn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 03:04:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The amd-xgbe driver currently only works with the Seattle SoC, which
is ARM64 architecture, so there is no point in building this driver on
other architectures except for build testing purpose. The dependency
list can be updated later if the driver ever supports other
architectures.

Signed-off-by: Jean Delvare <jdelvare@suse.de>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/amd/Kconfig |    1 +
 drivers/net/phy/Kconfig          |    1 +
 2 files changed, 2 insertions(+)

--- linux-4.1-rc2.orig/drivers/net/ethernet/amd/Kconfig	2015-05-05 22:24:13.165215411 +0200
+++ linux-4.1-rc2/drivers/net/ethernet/amd/Kconfig	2015-05-05 22:28:34.406445584 +0200
@@ -180,6 +180,7 @@ config SUNLANCE
 config AMD_XGBE
 	tristate "AMD 10GbE Ethernet driver"
 	depends on (OF_NET || ACPI) && HAS_IOMEM && HAS_DMA
+	depends on ARM64 || COMPILE_TEST
 	select PHYLIB
 	select AMD_XGBE_PHY
 	select BITREVERSE
--- linux-4.1-rc2.orig/drivers/net/phy/Kconfig	2015-04-27 02:59:10.000000000 +0200
+++ linux-4.1-rc2/drivers/net/phy/Kconfig	2015-05-05 23:08:37.194848765 +0200
@@ -27,6 +27,7 @@ config AMD_PHY
 config AMD_XGBE_PHY
 	tristate "Driver for the AMD 10GbE (amd-xgbe) PHYs"
 	depends on (OF || ACPI) && HAS_IOMEM
+	depends on ARM64 || COMPILE_TEST
 	---help---
 	  Currently supports the AMD 10GbE PHY
 


-- 
Jean Delvare
SUSE L3 Support
