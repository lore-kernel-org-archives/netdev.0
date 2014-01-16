From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v6 3/4] ARM: shmobile: r7s72100: Add clock for r7s72100-ether
Date: Thu, 16 Jan 2014 11:34:15 +0900
Message-ID: <1389839656-10932-4-git-send-email-horms+renesas@verge.net.au>
References: <1389839656-10932-1-git-send-email-horms+renesas@verge.net.au>
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Joe Perches <joe@perches.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389839656-10932-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Dave, I intend to take this change through my tree.

v6
* No change

v5
* Rebase

v3 - v4
* No change

v2
* As suggested by Sergei Shtylyov
  - Add MSTP74 to beginning of enum on a line by itself
* As suggested by Magnus Damm
  - r7s72100 ethernet is not gigabit so do not refer to it as such
---
 arch/arm/mach-shmobile/clock-r7s72100.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/mach-shmobile/clock-r7s72100.c b/arch/arm/mach-shmobile/clock-r7s72100.c
index dd8ce87..0242ca5 100644
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
@@ -180,6 +183,7 @@ static struct clk_lookup lookups[] = {
 	CLKDEV_DEV_ID("fcfee400.i2c", &mstp_clks[MSTP96]),
 	CLKDEV_DEV_ID("fcfee800.i2c", &mstp_clks[MSTP95]),
 	CLKDEV_DEV_ID("fcfeec00.i2c", &mstp_clks[MSTP94]),
+	CLKDEV_DEV_ID("r7s72100-ether", &mstp_clks[MSTP74]),
 	CLKDEV_CON_ID("mtu2_fck", &mstp_clks[MSTP33]),
 
 	/* ICK */
-- 
1.8.4

