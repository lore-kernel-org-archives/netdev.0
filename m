From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 02/10] stmmac: Define CSUM offload engine Types
Date: Wed,  4 Apr 2012 16:33:20 +0200
Message-ID: <1333550008-16500-3-git-send-email-peppe.cavallaro@st.com>
References: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, deepak.sikri@st.com, spear-devel@list.st.com,
	shiraz.hashim@st.com, viresh.kumar@st.com,
	srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:46492 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756484Ab2DDOeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:34:05 -0400
In-Reply-To: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak SIKRI <deepak.sikri@st.com>

This patch explicitly defines the CSUM offload engine type which need
(not mandatory) to be passed from the platform code.
STMMAC core supports two check sum offload engine types- Type-1 & Type-2.
Also, there are STMMAC cores that do not have the check sum offload
capabilities.

The behaviour of Type-1 & Type-2 cores related to provision of checksum
increases the packet length for Type-1 cores by 2, as the checksum is appended
at the end of data packet and the same is made accountable in the DMA status.
The STMMAC cores beyond Version-3.5 provide HW interface registers which allows
the user to read the HW capabilities, while to support the previous cores the
information related to HW capabilities has to be provided from the platform
code.

The Type-1 cores which do not have the HW register interface need this
information.

This patch also updates the driver's doc.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
Hacked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt |    3 +++
 include/linux/stmmac.h              |    5 +++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index d0aeead..61f40a3 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -116,6 +116,7 @@ and detailed below as well:
 	int has_gmac;
 	int enh_desc;
 	int tx_coe;
+	int rx_coe;
 	int bugged_jumbo;
 	int pmt;
 	int force_sf_dma_mode;
@@ -140,6 +141,8 @@ Where:
  o has_gmac: uses the GMAC core.
  o enh_desc: if sets the MAC will use the enhanced descriptor structure.
  o tx_coe: core is able to perform the tx csum in HW.
+ o rx_coe: the supports three check sum offloading engine types:
+	   type_1, type_2 (full csum) and no RX coe.
  o bugged_jumbo: some HWs are not able to perform the csum in HW for
 		over-sized frames due to limited buffer sizes.
 		Setting this flag the csum will be done in SW on
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 172b5e1..a9b4d6c 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -28,6 +28,10 @@
 
 #include <linux/platform_device.h>
 
+#define STMMAC_RX_COE_NONE	0
+#define STMMAC_RX_COE_TYPE1	1
+#define STMMAC_RX_COE_TYPE2	2
+
 /* Platfrom data for platform device structure's platform_data field */
 
 struct stmmac_mdio_bus_data {
@@ -49,6 +53,7 @@ struct plat_stmmacenet_data {
 	int has_gmac;
 	int enh_desc;
 	int tx_coe;
+	int rx_coe;
 	int bugged_jumbo;
 	int pmt;
 	int force_sf_dma_mode;
-- 
1.7.4.4
