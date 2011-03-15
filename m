From: Jamie Iles <jamie@jamieiles.com>
Subject: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Tue, 15 Mar 2011 10:14:48 +0000
Message-ID: <1300184096-13937-2-git-send-email-jamie@jamieiles.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Cc: nicolas.ferre@atmel.com, plagnioj@jcrosoft.com,
	Jamie Iles <jamie@jamieiles.com>
To: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:54894 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756703Ab1COKPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 06:15:12 -0400
Received: by bwz15 with SMTP id 15so389803bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 03:15:11 -0700 (PDT)
In-Reply-To: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macb driver expects clocks with the names "pclk" and "hclk".  We
currently provide "macb_clk" but to fit in line with other
architectures (namely AVR32), provide "pclk" and a fake "hclk".

Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Signed-off-by: Jamie Iles <jamie@jamieiles.com>
---
 arch/arm/mach-at91/at572d940hf.c |    8 +++++++-
 arch/arm/mach-at91/at91cap9.c    |    8 +++++++-
 arch/arm/mach-at91/at91sam9260.c |    8 +++++++-
 arch/arm/mach-at91/at91sam9263.c |    8 +++++++-
 arch/arm/mach-at91/at91sam9g45.c |    8 +++++++-
 5 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-at91/at572d940hf.c b/arch/arm/mach-at91/at572d940hf.c
index a6b9c68..9b3a37e 100644
--- a/arch/arm/mach-at91/at572d940hf.c
+++ b/arch/arm/mach-at91/at572d940hf.c
@@ -71,10 +71,15 @@ static struct clk pioC_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT572D940HF_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk usart0_clk = {
 	.name		= "usart0_clk",
 	.pmc_mask	= 1 << AT572D940HF_ID_US0,
@@ -182,6 +187,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&pioB_clk,
 	&pioC_clk,
 	&macb_clk,
+	&macb_hclk,
 	&usart0_clk,
 	&usart1_clk,
 	&usart2_clk,
diff --git a/arch/arm/mach-at91/at91cap9.c b/arch/arm/mach-at91/at91cap9.c
index 7337617..0d38ce7 100644
--- a/arch/arm/mach-at91/at91cap9.c
+++ b/arch/arm/mach-at91/at91cap9.c
@@ -150,10 +150,15 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91CAP9_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk aestdes_clk = {
 	.name		= "aestdes_clk",
 	.pmc_mask	= 1 << AT91CAP9_ID_AESTDES,
@@ -212,6 +217,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tcb_clk,
 	&pwm_clk,
 	&macb_clk,
+	&macb_hclk,
 	&aestdes_clk,
 	&adc_clk,
 	&isi_clk,
diff --git a/arch/arm/mach-at91/at91sam9260.c b/arch/arm/mach-at91/at91sam9260.c
index 195208b..f00774c 100644
--- a/arch/arm/mach-at91/at91sam9260.c
+++ b/arch/arm/mach-at91/at91sam9260.c
@@ -162,10 +162,15 @@ static struct clk ohci_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9260_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk isi_clk = {
 	.name		= "isi_clk",
 	.pmc_mask	= 1 << AT91SAM9260_ID_ISI,
@@ -221,6 +226,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tc2_clk,
 	&ohci_clk,
 	&macb_clk,
+	&macb_hclk,
 	&isi_clk,
 	&usart3_clk,
 	&usart4_clk,
diff --git a/arch/arm/mach-at91/at91sam9263.c b/arch/arm/mach-at91/at91sam9263.c
index 249f900..25cbae1 100644
--- a/arch/arm/mach-at91/at91sam9263.c
+++ b/arch/arm/mach-at91/at91sam9263.c
@@ -136,10 +136,15 @@ static struct clk pwm_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9263_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk dma_clk = {
 	.name		= "dma_clk",
 	.pmc_mask	= 1 << AT91SAM9263_ID_DMA,
@@ -190,6 +195,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&tcb_clk,
 	&pwm_clk,
 	&macb_clk,
+	&macb_hclk,
 	&twodge_clk,
 	&udc_clk,
 	&isi_clk,
diff --git a/arch/arm/mach-at91/at91sam9g45.c b/arch/arm/mach-at91/at91sam9g45.c
index c67b47f..a4d4a2d 100644
--- a/arch/arm/mach-at91/at91sam9g45.c
+++ b/arch/arm/mach-at91/at91sam9g45.c
@@ -157,10 +157,15 @@ static struct clk ac97_clk = {
 	.type		= CLK_TYPE_PERIPHERAL,
 };
 static struct clk macb_clk = {
-	.name		= "macb_clk",
+	.name		= "pclk",
 	.pmc_mask	= 1 << AT91SAM9G45_ID_EMAC,
 	.type		= CLK_TYPE_PERIPHERAL,
 };
+static struct clk macb_hclk = {
+	.name		= "hclk",
+	.pmc_mask	= 0,
+	.type		= CLK_TYPE_PERIPHERAL,
+};
 static struct clk isi_clk = {
 	.name		= "isi_clk",
 	.pmc_mask	= 1 << AT91SAM9G45_ID_ISI,
@@ -224,6 +229,7 @@ static struct clk *periph_clocks[] __initdata = {
 	&lcdc_clk,
 	&ac97_clk,
 	&macb_clk,
+	&macb_hclk,
 	&isi_clk,
 	&udphs_clk,
 	&mmc1_clk,
-- 
1.7.4

