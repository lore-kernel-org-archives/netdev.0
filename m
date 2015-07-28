From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 02/17] stmmac: dwmac-ipq806x: move ipq806x_gmac_fix_mac_speed function
Date: Wed, 29 Jul 2015 00:08:49 +0200
Message-ID: <1438121344-5304-3-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net, mathieu@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:36044 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910AbbG1WJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:23 -0400
Received: by lbbqi7 with SMTP id qi7so83899172lbb.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:22 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move ipq806x_gmac_fix_mac_speed in preparation for turning
the setup glue callback in a proper probe function.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 7e3129e7f143..5f1b3f9d8dba 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -248,6 +248,13 @@ static void *ipq806x_gmac_of_parse(struct ipq806x_gmac *gmac)
 	return NULL;
 }
 
+static void ipq806x_gmac_fix_mac_speed(void *priv, unsigned int speed)
+{
+	struct ipq806x_gmac *gmac = priv;
+
+	ipq806x_gmac_set_speed(gmac, speed);
+}
+
 static void *ipq806x_gmac_setup(struct platform_device *pdev)
 {
 	struct device *dev = &pdev->dev;
@@ -330,13 +337,6 @@ static void *ipq806x_gmac_setup(struct platform_device *pdev)
 	return gmac;
 }
 
-static void ipq806x_gmac_fix_mac_speed(void *priv, unsigned int speed)
-{
-	struct ipq806x_gmac *gmac = priv;
-
-	ipq806x_gmac_set_speed(gmac, speed);
-}
-
 static const struct stmmac_of_data ipq806x_gmac_data = {
 	.has_gmac	= 1,
 	.setup		= ipq806x_gmac_setup,
-- 
1.8.0
