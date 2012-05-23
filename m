From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/4] stmmac: fix driver Kconfig when built as module
Date: Wed, 23 May 2012 08:36:03 +0200
Message-ID: <1337754964-21754-3-git-send-email-peppe.cavallaro@st.com>
References: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Rayagond Kokatanur <rayagond@vayavyalabs.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:60138 "EHLO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965103Ab2EWGgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:36:23 -0400
In-Reply-To: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches fixes the driver when built as dyn module.
In fact the platform part cannot be built and the probe fails
(thanks to Bob Liu that reported this bug).
The patch also makes the selection of Platform and PCI parts
mutually exclusive.

Reported-by: Bob Liu <lliubbo@gmail.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
cc: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/Kconfig |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/Kconfig b/drivers/net/ethernet/stmicro/stmmac/Kconfig
index 0364283..3318b32 100644
--- a/drivers/net/ethernet/stmicro/stmmac/Kconfig
+++ b/drivers/net/ethernet/stmicro/stmmac/Kconfig
@@ -12,10 +12,12 @@ config STMMAC_ETH
 
 if STMMAC_ETH
 
+choice
+        prompt "STMMAC bus support"
+
 config STMMAC_PLATFORM
-	tristate "STMMAC platform bus support"
+	bool "Platform bus support"
 	depends on STMMAC_ETH
-	default y
 	---help---
 	  This selects the platform specific bus support for
 	  the stmmac device driver. This is the driver used
@@ -26,7 +28,7 @@ config STMMAC_PLATFORM
 	  If unsure, say N.
 
 config STMMAC_PCI
-	tristate "STMMAC support on PCI bus (EXPERIMENTAL)"
+	bool "PCI bus support (EXPERIMENTAL)"
 	depends on STMMAC_ETH && PCI && EXPERIMENTAL
 	---help---
 	  This is to select the Synopsys DWMAC available on PCI devices,
@@ -36,6 +38,7 @@ config STMMAC_PCI
 	  D1215994A VIRTEX FPGA board.
 
 	  If unsure, say N.
+endchoice
 
 config STMMAC_DEBUG_FS
 	bool "Enable monitoring via sysFS "
-- 
1.7.4.4
