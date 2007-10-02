From: akpm@linux-foundation.org
Subject: [patch 03/13] drivers/net/cxgb3/xgmac.c: remove dead code
Date: Tue, 02 Oct 2007 14:11:36 -0700
Message-ID: <200710022111.l92LBaI5022482@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42572 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754568AbXJBVMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:12:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch removes dead code ("tx_xcnt" can never be != 0 at this place)
spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/xgmac.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff -puN drivers/net/cxgb3/xgmac.c~drivers-net-cxgb3-xgmacc-remove-dead-code drivers/net/cxgb3/xgmac.c
--- a/drivers/net/cxgb3/xgmac.c~drivers-net-cxgb3-xgmacc-remove-dead-code
+++ a/drivers/net/cxgb3/xgmac.c
@@ -522,10 +522,7 @@ int t3b2_mac_watchdog_task(struct cmac *
 		goto rxcheck;
 	}
 
-	if (((tx_tcnt != mac->tx_tcnt) &&
-	     (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
-	    ((mac->tx_mcnt == tx_mcnt) &&
-	     (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
+	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
 		if (mac->toggle_cnt > 4) {
 			status = 2;
 			goto out;
_
