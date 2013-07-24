From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 1/3] ARM: shmobile: r8a7790: clocks for Ether support
Date: Wed, 24 Jul 2013 17:56:07 +0900
Message-ID: <1374656169-9241-2-git-send-email-horms+renesas@verge.net.au>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

v5
* Split out from "ARM: shmobile: r8a7790: add Ether support"
---
 arch/arm/mach-shmobile/clock-r8a7790.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/arch/arm/mach-shmobile/clock-r8a7790.c b/arch/arm/mach-shmobile/clock-r8a7790.c
index 50d96f9..fc36d3d 100644
--- a/arch/arm/mach-shmobile/clock-r8a7790.c
+++ b/arch/arm/mach-shmobile/clock-r8a7790.c
@@ -51,6 +51,7 @@
 #define SMSTPCR3 0xe615013c
 #define SMSTPCR5 0xe6150144
 #define SMSTPCR7 0xe615014c
+#define SMSTPCR8 0xe6150990
 
 #define SDCKCR		0xE6150074
 #define SD2CKCR		0xE6150078
@@ -180,6 +181,7 @@ static struct clk div6_clks[DIV6_NR] = {
 
 /* MSTP */
 enum {
+	MSTP813,
 	MSTP721, MSTP720,
 	MSTP717, MSTP716,
 	MSTP522,
@@ -190,6 +192,7 @@ enum {
 };
 
 static struct clk mstp_clks[MSTP_NR] = {
+	[MSTP813] = SH_CLK_MSTP32(&p_clk, SMSTPCR8, 13, 0), /* Ether */
 	[MSTP721] = SH_CLK_MSTP32(&p_clk, SMSTPCR7, 21, 0), /* SCIF0 */
 	[MSTP720] = SH_CLK_MSTP32(&p_clk, SMSTPCR7, 20, 0), /* SCIF1 */
 	[MSTP717] = SH_CLK_MSTP32(&zs_clk, SMSTPCR7, 17, 0), /* HSCIF0 */
@@ -258,6 +261,7 @@ static struct clk_lookup lookups[] = {
 	CLKDEV_DEV_ID("sh-sci.7", &mstp_clks[MSTP720]),
 	CLKDEV_DEV_ID("sh-sci.8", &mstp_clks[MSTP717]),
 	CLKDEV_DEV_ID("sh-sci.9", &mstp_clks[MSTP716]),
+	CLKDEV_DEV_ID("r8a7790-ether", &mstp_clks[MSTP813]),
 	CLKDEV_DEV_ID("rcar_thermal", &mstp_clks[MSTP522]),
 	CLKDEV_DEV_ID("ee200000.mmcif", &mstp_clks[MSTP315]),
 	CLKDEV_DEV_ID("sh_mmcif.0", &mstp_clks[MSTP315]),
-- 
1.8.2.1

