From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/4] net/cpsw: optimize the for_each_slave_macro()
Date: Wed, 24 Apr 2013 20:48:24 +0200
Message-ID: <1366829305-9752-4-git-send-email-bigeasy@linutronix.de>
References: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Cc: tglx@linutronix.de, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:41172 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203Ab3DXSsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 14:48:37 -0400
In-Reply-To: <1366829305-9752-1-git-send-email-bigeasy@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 text    data     bss     dec     hex filename
15530      92       4   15626    3d0a cpsw.o.before
15478      92       4   15574    3cd6 cpsw.o.after

52 bytes smaller, 13 for each invocation.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/ti/cpsw.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 1983f23..8b643d9 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -355,12 +355,15 @@ struct cpsw_priv {
 #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
 #define for_each_slave(priv, func, arg...)				\
 	do {								\
-		int idx;						\
+		struct cpsw_slave *slave;				\
+		int n;							\
 		if (priv->data.dual_emac)				\
 			(func)((priv)->slaves + priv->emac_port, ##arg);\
 		else							\
-			for (idx = 0; idx < (priv)->data.slaves; idx++)	\
-				(func)((priv)->slaves + idx, ##arg);	\
+			for (n = (priv)->data.slaves,			\
+					slave = (priv)->slaves;		\
+					n; n--)				\
+				(func)(slave++, ##arg);			\
 	} while (0)
 #define cpsw_get_slave_ndev(priv, __slave_no__)				\
 	(priv->slaves[__slave_no__].ndev)
-- 
1.7.10.4
