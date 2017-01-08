From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH] net: ethernet: ti: cpsw: extend limits for cpsw_get/set_ringparam
Date: Sun,  8 Jan 2017 22:12:27 +0200
Message-ID: <1483906347-7567-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, grygorii.strashko@ti.com,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: netdev@vger.kernel.org, mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34904 "EHLO
        mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750892AbdAHUMd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 15:12:33 -0500
Received: by mail-lf0-f48.google.com with SMTP id m78so62041973lfg.2
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 12:12:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to set number of descs close to possible values. In case of
minimum limit it's equal to number of channels to be able to set
at least one desc per channel. For maximum limit leave enough descs
number for tx channels.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---

Based on net-next/master

 drivers/net/ethernet/ti/cpsw.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 458298d..09e0ed6 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2474,8 +2474,7 @@ static void cpsw_get_ringparam(struct net_device *ndev,
 	/* not supported */
 	ering->tx_max_pending = 0;
 	ering->tx_pending = cpdma_get_num_tx_descs(cpsw->dma);
-	/* Max 90% RX buffers */
-	ering->rx_max_pending = (descs_pool_size * 9) / 10;
+	ering->rx_max_pending = descs_pool_size - CPSW_MAX_QUEUES;
 	ering->rx_pending = cpdma_get_num_rx_descs(cpsw->dma);
 }
 
@@ -2490,8 +2489,8 @@ static int cpsw_set_ringparam(struct net_device *ndev,
 	/* ignore ering->tx_pending - only rx_pending adjustment is supported */
 
 	if (ering->rx_mini_pending || ering->rx_jumbo_pending ||
-	    ering->rx_pending < (descs_pool_size / 10) ||
-	    ering->rx_pending > ((descs_pool_size * 9) / 10))
+	    ering->rx_pending < CPSW_MAX_QUEUES ||
+	    ering->rx_pending > (descs_pool_size - CPSW_MAX_QUEUES))
 		return -EINVAL;
 
 	if (ering->rx_pending == cpdma_get_num_rx_descs(cpsw->dma))
-- 
2.7.4
