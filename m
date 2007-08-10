From: akpm@linux-foundation.org
Subject: [patch 11/18] drivers/net/cxgb3/xgmac.c: remove dead code
Date: Fri, 10 Aug 2007 14:05:22 -0700
Message-ID: <200708102105.l7AL5MNI008977@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, bunk@stusta.de
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42669 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754376AbXHJVQB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:16:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch removes dead code ("tx_xcnt" can never be != 0 at this place)
spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/xgmac.c |    5 +----
 1 files changed, 1 insertion(+), 4 deletions(-)

diff -puN drivers/net/cxgb3/xgmac.c~drivers-net-cxgb3-xgmacc-remove-dead-code drivers/net/cxgb3/xgmac.c
--- a/drivers/net/cxgb3/xgmac.c~drivers-net-cxgb3-xgmacc-remove-dead-code
+++ a/drivers/net/cxgb3/xgmac.c
@@ -524,10 +524,7 @@ int t3b2_mac_watchdog_task(struct cmac *
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
