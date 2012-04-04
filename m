From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 04/10] stmmac: Define MDC clock selection macros
Date: Wed,  4 Apr 2012 16:33:22 +0200
Message-ID: <1333550008-16500-5-git-send-email-peppe.cavallaro@st.com>
References: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, deepak.sikri@st.com, spear-devel@list.st.com,
	shiraz.hashim@st.com, viresh.kumar@st.com,
	srinivas.kandagatla@st.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:57785 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756428Ab2DDOeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 10:34:05 -0400
In-Reply-To: <1333550008-16500-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Deepak SIKRI <deepak.sikri@st.com>

The patch adds the macros to be used for MDC clock selection. The MDC clock
frequency is based on scaled system clock, and has to be confined to a range
of 1-2.5 MHz. Based on the input CSR clock, the scaling factor has to be
selected.
The platform specific code will provide the default value of this scaling
factor, based on the input CSR clock.
There is an option to set MDC clock higher than the IEEE 802.3 specified
frequency limit of 2.5 MHz. This applies for the interfacing chips that
support higher MDC clocks. The resultant higher clock of 12.5 MHz requires
additional Macros to be defined for the clock divider corresponding to the
to the following selection.
-----------------------------------------
	Selection	MDC Clock
-----------------------------------------
	1000 		clk_csr_i/4
	1001 		clk_csr_i/6
	1010 		clk_csr_i/8
	1011 		clk_csr_i/10
	1100 		clk_csr_i/12
	1101	 	clk_csr_i/14
	1110 		clk_csr_i/16
	1111 		clk_csr_i/18

This support has to be added both in the include file, as well as driver. The
driver need to program the registers based on the interfacing chips. This would
be more board specific information and needs to be passed through the platform
code to the driver. This work would be carried out in the future patch set
release.

Signed-off-by: Deepak Sikri <deepak.sikri@st.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 include/linux/stmmac.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index a9b4d6c..e529282 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -32,6 +32,34 @@
 #define STMMAC_RX_COE_TYPE1	1
 #define STMMAC_RX_COE_TYPE2	2
 
+/* Define the macros for CSR clock range parameters to be passed by
+ * platform code.
+ * This could also be configured at run time using CPU freq framework. */
+
+/* MDC Clock Selection define*/
+#define	STMMAC_CSR_60_100M	0	/* MDC = clk_scr_i/42 */
+#define	STMMAC_CSR_100_150M	1	/* MDC = clk_scr_i/62 */
+#define	STMMAC_CSR_20_35M	2	/* MDC = clk_scr_i/16 */
+#define	STMMAC_CSR_35_60M	3	/* MDC = clk_scr_i/26 */
+#define	STMMAC_CSR_150_250M	4	/* MDC = clk_scr_i/102 */
+#define	STMMAC_CSR_250_300M	5	/* MDC = clk_scr_i/122 */
+
+/* FIXME: The MDC clock could be set higher than the IEEE 802.3
+ * specified frequency limit 0f 2.5 MHz, by programming a clock divider
+ * of value different than the above defined values. The resultant MDIO
+ * clock frequency of 12.5 MHz is applicable for the interfacing chips
+ * supporting higher MDC clocks.
+ * The MDC clock selection macros need to be defined for MDC clock rate
+ * of 12.5 MHz, corresponding to the following selection.
+ * 1000 clk_csr_i/4
+ * 1001 clk_csr_i/6
+ * 1010 clk_csr_i/8
+ * 1011 clk_csr_i/10
+ * 1100 clk_csr_i/12
+ * 1101 clk_csr_i/14
+ * 1110 clk_csr_i/16
+ * 1111 clk_csr_i/18 */
+
 /* Platfrom data for platform device structure's platform_data field */
 
 struct stmmac_mdio_bus_data {
-- 
1.7.4.4
