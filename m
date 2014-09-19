From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH net-next v2] fec: Staticize fec_enet_select_queue()
Date: Fri, 19 Sep 2014 14:59:34 -0300
Message-ID: <1411149574-26296-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Frank.Li@freescale.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0122.outbound.protection.outlook.com ([65.55.169.122]:52864
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757276AbaISR76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 13:59:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_select_queue() is only used locally, so mark it as 'static' to fix the
following sparse warning:

drivers/net/ethernet/freescale/fec_main.c:2707:5: warning: symbol 'fec_enet_select_queue' was not declared. Should it be static?

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changes since v1:
- Make checkpatch happy

 drivers/net/ethernet/freescale/fec_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6e93336..2389dff 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2704,8 +2704,9 @@ static int fec_set_features(struct net_device *netdev,
 	return 0;
 }
 
-u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
-			  void *accel_priv, select_queue_fallback_t fallback)
+static u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
+				 void *accel_priv,
+				 select_queue_fallback_t fallback)
 {
 	return skb_tx_hash(ndev, skb);
 }
-- 
1.9.1
