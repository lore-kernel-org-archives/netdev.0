From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v3 2/3] ARM: shmobile: r7s72100: Add clock for r7s72100-ether
Date: Tue,  7 Jan 2014 11:27:14 +0900
Message-ID: <1389061635-4083-3-git-send-email-horms+renesas@verge.net.au>
References: <1389061635-4083-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:40437 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756152AbaAGC1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 21:27:39 -0500
In-Reply-To: <1389061635-4083-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---
v2
* As suggested by Sergei Shtylyov
  - Add MSTP74 to beginning of enum on a line by itself
* As suggested by Magnus Damm
  - r7s72100 ethernet is not gigabit so do not refer to it as such
---
 arch/arm/mach-shmobile/clock-r7s72100.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/mach-shmobile/clock-r7s72100.c b/arch/arm/mach-shmobile/clock-r7s72100.c
index e6ab0cd..c4ba651 100644
--- a/arch/arm/mach-shmobile/clock-r7s72100.c
+++ b/arch/arm/mach-shmobile/clock-r7s72100.c
@@ -27,6 +27,7 @@
 #define FRQCR2		0xfcfe0014
 #define STBCR3		0xfcfe0420
 #define STBCR4		0xfcfe0424
+#define STBCR7		0xfcfe0430
 #define STBCR9		0xfcfe0438
 
 #define PLL_RATE 30
@@ -146,6 +147,7 @@ struct clk div4_clks[DIV4_NR] = {
 };
 
 enum {	MSTP97, MSTP96, MSTP95, MSTP94,
+	MSTP74,
 	MSTP47, MSTP46, MSTP45, MSTP44, MSTP43, MSTP42, MSTP41, MSTP40,
 	MSTP33,	MSTP_NR };
 
@@ -154,6 +156,7 @@ static struct clk mstp_clks[MSTP_NR] = {
 	[MSTP96] = SH_CLK_MSTP8(&peripheral0_clk, STBCR9, 6, 0), /* RIIC1 */
 	[MSTP95] = SH_CLK_MSTP8(&peripheral0_clk, STBCR9, 5, 0), /* RIIC2 */
 	[MSTP94] = SH_CLK_MSTP8(&peripheral0_clk, STBCR9, 4, 0), /* RIIC3 */
+	[MSTP74] = SH_CLK_MSTP8(&peripheral1_clk, STBCR7, 4, 0), /* Ether */
 	[MSTP47] = SH_CLK_MSTP8(&peripheral1_clk, STBCR4, 7, 0), /* SCIF0 */
 	[MSTP46] = SH_CLK_MSTP8(&peripheral1_clk, STBCR4, 6, 0), /* SCIF1 */
 	[MSTP45] = SH_CLK_MSTP8(&peripheral1_clk, STBCR4, 5, 0), /* SCIF2 */
@@ -176,6 +179,7 @@ static struct clk_lookup lookups[] = {
 	CLKDEV_CON_ID("cpu_clk", &div4_clks[DIV4_I]),
 
 	/* MSTP clocks */
+	CLKDEV_DEV_ID("r7s72100-ether", &mstp_clks[MSTP74]),
 	CLKDEV_CON_ID("mtu2_fck", &mstp_clks[MSTP33]),
 
 	/* ICK */
-- 
1.8.4
