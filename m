From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] geneve: fix tx_errors statistics
Date: Tue, 21 Jun 2016 16:26:49 +0800
Message-ID: <1466497609-14468-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tx errors present summation of errors encountered while transmitting
packets.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/geneve.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index aa61708..72b2f1c 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -922,8 +922,8 @@ tx_error:
 		dev->stats.collisions++;
 	else if (err == -ENETUNREACH)
 		dev->stats.tx_carrier_errors++;
-	else
-		dev->stats.tx_errors++;
+
+	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 
@@ -1012,8 +1012,8 @@ tx_error:
 		dev->stats.collisions++;
 	else if (err == -ENETUNREACH)
 		dev->stats.tx_carrier_errors++;
-	else
-		dev->stats.tx_errors++;
+
+	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
 #endif
-- 
1.8.3.1
