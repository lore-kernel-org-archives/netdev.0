From: Matthias Kaehlcke <mka@chromium.org>
Subject: [PATCH] net: jme: Remove unused functions
Date: Tue, 23 May 2017 17:27:51 -0700
Message-ID: <20170524002751.172595-1-mka@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Douglas Anderson <dianders@chromium.org>,
        Matthias Kaehlcke <mka@chromium.org>
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35753 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965002AbdEXA2N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 20:28:13 -0400
Received: by mail-pf0-f180.google.com with SMTP id n23so129621391pfb.2
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 17:28:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions jme_restart_tx_engine(), jme_pause_rx() and
jme_resume_rx() are not used. Removing them fixes the following warnings
when building with clang:

drivers/net/ethernet/jme.c:694:1: error: unused function
    'jme_restart_tx_engine' [-Werror,-Wunused-function]

drivers/net/ethernet/jme.c:2393:20: error: unused function
    'jme_pause_rx' [-Werror,-Wunused-function]

drivers/net/ethernet/jme.c:2406:20: error: unused function
    'jme_resume_rx' [-Werror,-Wunused-function]

Signed-off-by: Matthias Kaehlcke <mka@chromium.org>
---
 drivers/net/ethernet/jme.c | 42 ------------------------------------------
 1 file changed, 42 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index f580b49e6b67..0e5083a48937 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -691,17 +691,6 @@ jme_enable_tx_engine(struct jme_adapter *jme)
 }
 
 static inline void
-jme_restart_tx_engine(struct jme_adapter *jme)
-{
-	/*
-	 * Restart TX Engine
-	 */
-	jwrite32(jme, JME_TXCS, jme->reg_txcs |
-				TXCS_SELECT_QUEUE0 |
-				TXCS_ENABLE);
-}
-
-static inline void
 jme_disable_tx_engine(struct jme_adapter *jme)
 {
 	int i;
@@ -2382,37 +2371,6 @@ jme_tx_timeout(struct net_device *netdev)
 	jme_reset_link(jme);
 }
 
-static inline void jme_pause_rx(struct jme_adapter *jme)
-{
-	atomic_dec(&jme->link_changing);
-
-	jme_set_rx_pcc(jme, PCC_OFF);
-	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
-		JME_NAPI_DISABLE(jme);
-	} else {
-		tasklet_disable(&jme->rxclean_task);
-		tasklet_disable(&jme->rxempty_task);
-	}
-}
-
-static inline void jme_resume_rx(struct jme_adapter *jme)
-{
-	struct dynpcc_info *dpi = &(jme->dpi);
-
-	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
-		JME_NAPI_ENABLE(jme);
-	} else {
-		tasklet_enable(&jme->rxclean_task);
-		tasklet_enable(&jme->rxempty_task);
-	}
-	dpi->cur		= PCC_P1;
-	dpi->attempt		= PCC_P1;
-	dpi->cnt		= 0;
-	jme_set_rx_pcc(jme, PCC_P1);
-
-	atomic_inc(&jme->link_changing);
-}
-
 static void
 jme_get_drvinfo(struct net_device *netdev,
 		     struct ethtool_drvinfo *info)
-- 
2.13.0.219.gdb65acc882-goog
