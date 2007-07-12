From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH] ps3: fix return value in the case of tx error
Date: Thu, 12 Jul 2007 15:59:26 +0900
Message-ID: <20070712154930.3DE4.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:56070 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142AbXGLG7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 02:59:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi
	
This patch fixes the improper return value of the hard_start_xmit()
handler of PS3 gelic network driver.

Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
---
 drivers/net/ps3_gelic_net.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -803,7 +803,7 @@ kick:
 error:
 	card->netdev_stats.tx_dropped++;
 	spin_unlock_irqrestore(&card->tx_dma_lock, flags);
-	return NETDEV_TX_LOCKED;
+	return NETDEV_TX_BUSY;
 }
 
 /**

--
Masakazu MOKUNO

