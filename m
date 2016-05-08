From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next] stmmac: dwmac-socfpga: make socfpga_dwmac_pm_ops static
Date: Sun,  8 May 2016 13:47:23 +0200
Message-ID: <1462708043-8486-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	dinguyen@opensource.altera.com,
	Joachim Eastwood <manabian@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36246 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbcEHLrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 07:47:33 -0400
Received: by mail-lf0-f66.google.com with SMTP id y84so18172108lfc.3
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 04:47:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the following sparse warning:
drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c:274:1: warning:
  symbol 'socfpga_dwmac_pm_ops' was not declared. Should it be static?

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
Hi,

Noticed this sparse warning after my last batch of patches. Not so
easy to spot these when there is a macro that creates variables.

 drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
index cd9764a..f13499f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-socfpga.c
@@ -271,7 +271,8 @@ static int socfpga_dwmac_resume(struct device *dev)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-SIMPLE_DEV_PM_OPS(socfpga_dwmac_pm_ops, stmmac_suspend, socfpga_dwmac_resume);
+static SIMPLE_DEV_PM_OPS(socfpga_dwmac_pm_ops, stmmac_suspend,
+					       socfpga_dwmac_resume);
 
 static const struct of_device_id socfpga_dwmac_match[] = {
 	{ .compatible = "altr,socfpga-stmmac" },
-- 
2.8.2
