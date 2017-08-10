From: Max Uvarov <muvarov@gmail.com>
Subject: [PATCH 1/2] drivers: net: davinci_mdio: remove busy loop on wait user access
Date: Thu, 10 Aug 2017 10:41:59 +0300
Message-ID: <1502350920-22750-1-git-send-email-muvarov@gmail.com>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        Max Uvarov <muvarov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:33000 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750868AbdHJHmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 03:42:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Polling 14 mdio devices on single mdio bus eats 30% of 1Ghz cpu time
due to busy loop in waiti(). Aadd small delay to relax cpu.

Signed-off-by: Max Uvarov <muvarov@gmail.com>
---
 drivers/net/ethernet/ti/davinci_mdio.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
index 33df340..611e7cc 100644
--- a/drivers/net/ethernet/ti/davinci_mdio.c
+++ b/drivers/net/ethernet/ti/davinci_mdio.c
@@ -198,8 +198,10 @@ static inline int wait_for_user_access(struct davinci_mdio_data *data)
 			return 0;
 
 		reg = __raw_readl(&regs->control);
-		if ((reg & CONTROL_IDLE) == 0)
+		if ((reg & CONTROL_IDLE) == 0) {
+			usleep_range(100, 200);
 			continue;
+		}
 
 		/*
 		 * An emac soft_reset may have clobbered the mdio controller's
-- 
2.5.0
