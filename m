From: Deepak Sikri <deepak.sikri@st.com>
Subject: [PATCH 2/6] stmmac: Define MDC clock selection macros.
Date: Fri, 2 Mar 2012 18:25:24 +0530
Message-ID: <1330692928-30330-3-git-send-email-deepak.sikri@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com>
 <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <spear-devel@list.st.com>, <netdev@vger.kernel.org>,
	Deepak Sikri <deepak.sikri@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:47497 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757838Ab2CBMz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2012 07:55:57 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 40CAFD8
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:47:21 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas1.st.com [10.80.176.8])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id 0DB4F75C
	for <netdev@vger.kernel.org>; Fri,  2 Mar 2012 12:55:46 +0000 (GMT)
In-Reply-To: <1330692928-30330-2-git-send-email-deepak.sikri@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds the macros to be used for MDC clock selection. The MDC clock
frequency is based on scaled system clock, and has to be confined to a range
of 1-2.5 MHz. Based on the input CSR clock, the scaling factor has to be
selected.
The platform specific code will provide the default value of this scaling
factor, based on the input CSR clock.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
---
 include/linux/stmmac.h |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index aa0d99e..7332ed8 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -40,6 +40,29 @@
 #define STMMAC_CSUM_T1	1
 #define STMMAC_CSUM_T2	2
 
+/*
+ * Define the macros for CSR clock range parameters to be passed by
+ * platform code.
+ * This could also be configured at run time using CPU freq framework.
+ */
+
+/* CSR Frequency Access Defines*/
+#define CSR_F_20M	20000000
+#define CSR_F_35M	35000000
+#define CSR_F_60M	60000000
+#define CSR_F_100M	100000000
+#define CSR_F_150M	150000000
+#define CSR_F_250M	50000000
+#define CSR_F_300M	300000000
+
+/* MDC Clock Selection define*/
+#define	STMMAC_CLK_RANGE_60_100M	0	/* MDC = Clk/42 */
+#define	STMMAC_CLK_RANGE_100_150M	1	/* MDC = Clk/62 */
+#define	STMMAC_CLK_RANGE_20_35M		2	/* MDC = Clk/16 */
+#define	STMMAC_CLK_RANGE_35_60M		3	/* MDC = Clk/26 */
+#define	STMMAC_CLK_RANGE_150_250M	4	/* MDC = Clk/102 */
+#define	STMMAC_CLK_RANGE_250_300M	5	/* MDC = Clk/122 */
+
 /* Platfrom data for platform device structure's platform_data field */
 
 struct stmmac_mdio_bus_data {
-- 
1.6.0.2
