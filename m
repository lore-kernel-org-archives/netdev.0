From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] Kconfig: Fix Kconfig for Intel ixgbe and igb PTP support.
Date: Wed, 20 Jun 2012 01:44:41 -0700
Message-ID: <1340181882-16333-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38315 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753746Ab2FTIop (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 04:44:45 -0400
In-Reply-To: <1340181882-16333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Fix Kconfig file to make sure that PTP and IGB/IXGBE are both either
in-kernel or modules, not mixed.  Having the build status mixed causes
compile errors.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 79b07ec..0cafe4f 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -122,8 +122,10 @@ config IGB_DCA
 
 config IGB_PTP
 	bool "PTP Hardware Clock (PHC)"
-	default y
-	depends on IGB && PTP_1588_CLOCK
+	default n
+	depends on IGB && EXPERIMENTAL
+	select PPS
+	select PTP_1588_CLOCK
 	---help---
 	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
 	  driver.  Only the basic clock operations have been implemented.
@@ -223,7 +225,9 @@ config IXGBE_DCB
 config IXGBE_PTP
 	bool "PTP Clock Support"
 	default n
-	depends on IXGBE && PTP_1588_CLOCK
+	depends on IXGBE && EXPERIMENTAL
+	select PPS
+	select PTP_1588_CLOCK
 	---help---
 	  Say Y here if you want support for 1588 Timestamping with a
 	  PHC device, using the PTP 1588 Clock support. This is
-- 
1.7.10.2
