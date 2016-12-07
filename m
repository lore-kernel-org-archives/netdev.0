From: Niklas Cassel <niklas.cassel@axis.com>
Subject: [RESEND PATCH 2/3] net: stmmac: dwmac-generic: add missing compatible strings
Date: Wed, 7 Dec 2016 13:41:07 +0100
Message-ID: <1481114469-4788-2-git-send-email-niklass@axis.com>
References: <1481114469-4788-1-git-send-email-niklass@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Niklas Cassel <niklass@axis.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bes.se.axis.com ([195.60.68.10]:47165 "EHLO bes.se.axis.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752226AbcLGMmF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 07:42:05 -0500
In-Reply-To: <1481114469-4788-1-git-send-email-niklass@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>

devicetree binding for stmmac states:
- compatible: Should be "snps,dwmac-<ip_version>", "snps,dwmac"
	For backwards compatibility: "st,spear600-gmac" is also supported.

Since dwmac-generic.c calls stmmac_probe_config_dt explicitly,
another alternative would have been to remove all compatible strings
other than "snps,dwmac" and "st,spear600-gmac" from dwmac-generic.c.

However, that would probably do more good than harm, since when trying
to figure out what hardware a certain driver supports, you usually look
at the compatible strings in the struct of_device_id, and not in some
function defined in a completely different file.

No functional change intended.

Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>
Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index e6e6c2fcc4b7..3304095c934c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -71,9 +71,12 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 
 static const struct of_device_id dwmac_generic_match[] = {
 	{ .compatible = "st,spear600-gmac"},
+	{ .compatible = "snps,dwmac-3.50a"},
 	{ .compatible = "snps,dwmac-3.610"},
 	{ .compatible = "snps,dwmac-3.70a"},
 	{ .compatible = "snps,dwmac-3.710"},
+	{ .compatible = "snps,dwmac-4.00"},
+	{ .compatible = "snps,dwmac-4.10a"},
 	{ .compatible = "snps,dwmac"},
 	{ }
 };
-- 
2.1.4
