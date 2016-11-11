From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: davinci_cpdma: don't stop ctlr if it was stopped
Date: Fri, 11 Nov 2016 16:10:47 +0200
Message-ID: <1478873447-1309-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35317 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756217AbcKKOKy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 09:10:54 -0500
Received: by mail-lf0-f42.google.com with SMTP id b14so13202420lfg.2
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 06:10:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to stop ctlr if it was already stopped. It can cause timeout
warns. Steps:
- ifconfig eth0 down
- ethtool -l eth0 rx 8 tx 8
- ethtool -l eth0 rx 1 tx 1

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on net-next/master

 drivers/net/ethernet/ti/davinci_cpdma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 56395ce..56708a7 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -387,7 +387,7 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 	int i;
 
 	spin_lock_irqsave(&ctlr->lock, flags);
-	if (ctlr->state == CPDMA_STATE_TEARDOWN) {
+	if (ctlr->state != CPDMA_STATE_ACTIVE) {
 		spin_unlock_irqrestore(&ctlr->lock, flags);
 		return -EINVAL;
 	}
-- 
1.9.1
