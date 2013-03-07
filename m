From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next.git 9/9] stmmac: update the Doc and Version (PTP+SGMII)
Date: Thu,  7 Mar 2013 11:50:19 +0100
Message-ID: <1362653419-1047-10-git-send-email-peppe.cavallaro@st.com>
References: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Cc: bh74.an@samsung.com, ayagond@vayavyalabs.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:58860 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752847Ab3CGKxq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 05:53:46 -0500
In-Reply-To: <1362653419-1047-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the stmmac.txt file adding
information related to the PTP and SGMII/RGMII
supports.

Also the patch updates the driver version to:
March_2013.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt          |   39 ++++++++++++++++++++++++-
 drivers/net/ethernet/stmicro/stmmac/stmmac.h |    2 +-
 2 files changed, 38 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index f9fa6db..f7d8c3d 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -326,6 +326,41 @@ To enter in Tx LPI mode the driver needs to have a software timer
 that enable and disable the LPI mode when there is nothing to be
 transmitted.
 
-7) TODO:
+7) Extended descriptors
+The CONFIG_STMMAC_EXTENDED_DESC option can be enabled to use the
+the extended status in the descriptors. For RDESC, that gives some
+information about the receive Ethernet payload when it is carrying PTP
+packets or TCP/UDP/ICMP over IP.
+This option cannot be used on GMAC Synopsys older than the 3.50
+so the driver's probe will fail in this scenario.
+This option also is mandatory for PTPv2 because the extra descriptors
+are used for saving the hardware timestamps.
+
+8) Precision Time Protocol (PTP)
+The driver supports the IEEE 1588-2002, Precision Time Protocol (PTP),
+which enables precise synchronization of clocks in measurement and
+control systems implemented with technologies such as network
+communication.
+This is the Kernel option to enable it: CONFIG_STMMAC_USE_HWSTAMP
+
+In addition to the basic timestamp features mentioned in IEEE 1588-2002
+Timestamps, new GMAC cores support the advanced timestamp features.
+IEEE 1588-2008 that can be enabled when configure the Kernel. This is
+its option: CONFIG_STMMAC_USE_HW_A_STAMP
+To use this support the HW has to have the extended descriptors.
+At run time this will be verified by looking at the HW capability
+register.
+
+9) SGMII/RGMII supports
+New GMAC devices provide own way to manage RGMII/SGMII.
+This information is available at run-time by looking at the
+HW capability register. This means that the stmmac can manage
+auto-negotiation and link status w/o using the PHYLIB stuff
+In fact, the HW provides a subset of extended registers to
+restart the ANE, verify Full/Half duplex mode and Speed.
+Also thanks to these registers it is possible to look at the
+Auto-negotiated Link Parter Ability.
+
+10) TODO:
  o XGMAC is not supported.
- o Add the PTP - precision time protocol
+ o Complete the TBI & RTBI support.
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 200011d..78bc4d1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -24,7 +24,7 @@
 #define __STMMAC_H__
 
 #define STMMAC_RESOURCE_NAME   "stmmaceth"
-#define DRV_MODULE_VERSION	"Nov_2012"
+#define DRV_MODULE_VERSION	"March_2013"
 
 #include <linux/clk.h>
 #include <linux/stmmac.h>
-- 
1.7.4.4
