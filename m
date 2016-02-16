From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net v4]r8169: Correcting start poll() operations.
Date: Tue, 16 Feb 2016 15:19:56 +0200
Message-ID: <1455628796-1750-1-git-send-email-asd@marian1000.go.ro>
Cc: Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-226-11.residential.rdsnet.ro ([5.14.226.11]:56294 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254AbcBPNxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 08:53:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This patch enable poll operations when chip is ready.
  poll op. Will start after autoneg process, after transmission is started.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 537974c..a1fa760 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7685,7 +7685,6 @@ static int rtl_open(struct net_device *dev)
 
 	set_bit(RTL_FLAG_TASK_ENABLED, tp->wk.flags);
 
-	napi_enable(&tp->napi);
 
 	rtl8169_init_phy(dev, tp);
 
@@ -7699,7 +7698,7 @@ static int rtl_open(struct net_device *dev)
 		netif_warn(tp, hw, dev, "counter reset/update failed\n");
 
 	netif_start_queue(dev);
-
+	napi_enable(&tp->napi);
 	rtl_unlock_work(tp);
 
 	tp->saved_wolopts = 0;
-- 
2.1.4
