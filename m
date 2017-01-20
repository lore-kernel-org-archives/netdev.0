From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH] net: stmicro: fix LS field mask in EEE configuration
Date: Fri, 20 Jan 2017 16:00:26 +0000
Message-ID: <ed690f703a3c82193737f1a9813dff8b1ff403dd.1484927665.git.jpinto@synopsys.com>
Cc: rayagond@vayavyalabs.com, netdev@vger.kernel.org,
        Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.47.9]:35749 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752439AbdATQIO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:08:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the LS mask when setting EEE timer.
LS field is 10 bits long and not 11 as currently.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
Reported-By: Rayagond Kokatanur <rayagond@vayavyalabs.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 834f40f..202216c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -184,7 +184,7 @@ static void dwmac4_set_eee_pls(struct mac_device_info *hw, int link)
 static void dwmac4_set_eee_timer(struct mac_device_info *hw, int ls, int tw)
 {
 	void __iomem *ioaddr = hw->pcsr;
-	int value = ((tw & 0xffff)) | ((ls & 0x7ff) << 16);
+	int value = ((tw & 0xffff)) | ((ls & 0x3ff) << 16);
 
 	/* Program the timers in the LPI timer control register:
 	 * LS: minimum time (ms) for which the link
-- 
2.9.3
