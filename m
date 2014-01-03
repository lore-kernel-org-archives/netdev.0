From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/11] ixgbe: Add Live Error Recovery configuration option
Date: Thu,  2 Jan 2014 21:18:27 -0800
Message-ID: <1388726310-2996-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30860 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750884AbaACFSi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jan 2014 00:18:38 -0500
In-Reply-To: <1388726310-2996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

CONFIG_IXGBE_LER is added to control LER, Live Error Recovery,
support. This avoids possible crashes in the driver when a device
is suddenly removed, which is possible in Thunderbolt and other
environments. Turning this off will save a little CPU utilization.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 94adb89..791897d 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -192,6 +192,17 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_LER
+	bool "Intel(R) 10GbE PCI Express LER support"
+	default y
+	depends on IXGBE
+	---help---
+	  This option makes the driver more robust in the face of sudden
+	  device removals, which can happen in Thunderbolt and other
+	  environments.  Say N to disable Live Error Recovery (LER)
+	  checks to save a little CPU utilization. If in doubt,
+	  say Y.
+
 config IXGBE_HWMON
 	bool "Intel(R) 10GbE PCI Express adapters HWMON support"
 	default y
-- 
1.8.3.1
