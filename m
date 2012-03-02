From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 1/6] stmmac: Define CSUM offload engine Types
Date: Fri, 2 Mar 2012 18:25:23 +0530
Message-ID: <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:42539 "EHLO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757136Ab2CBMzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:55:46 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 5EBE0BC
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:16 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 2AAC875D
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:55:41 +0000 (GMT)
In-Reply-To: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 include/linux/stmmac.h |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index 0dddc9e..aa0d99e 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -28,6 +28,18 @@
 
 #include <linux/platform_device.h>
 
+/* Checksum offload engine Types */
+/* STMMAC core supports two check sum offloading engine types
+ * Type-1 & Type-2
+ * These are configurable portion of the MAC core and hence could be
+ * also made off. 
+ * The Type-0 Macro defined below covers the core which do not support
+ * the checksum offloading.
+ */
+#define STMMAC_CSUM_T0	0
+#define STMMAC_CSUM_T1	1
+#define STMMAC_CSUM_T2	2
+
 /* Platfrom data for platform device structure's platform_data field */
 
 struct stmmac_mdio_bus_data {
@@ -57,5 +69,6 @@ struct plat_stmmacenet_data {
 	void (*exit)(struct platform_device *pdev);
 	void *custom_cfg;
 	void *bsp_priv;
+	int csum_off_engine_type;
 };
 #endif
-- 
1.6.0.2
