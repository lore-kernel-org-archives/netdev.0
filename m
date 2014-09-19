From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH net-next] fec: Staticize fec_enet_select_queue()
Date: Fri, 19 Sep 2014 13:40:50 -0300
Message-ID: <1411144850-19267-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Frank.Li@freescale.com>, <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0106.outbound.protection.outlook.com ([157.56.111.106]:40128
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756626AbaISRPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 13:15:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fec_enet_select_queue() is only used locally, so mark it as 'static' to fix the
following sparse warning:

drivers/net/ethernet/freescale/fec_main.c:2707:5: warning: symbol 'fec_enet_select_queue' was not declared. Should it be static?

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 6e93336..eea4f98 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2704,7 +2704,7 @@ static int fec_set_features(struct net_device *netdev,
 	return 0;
 }
 
-u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
+static u16 fec_enet_select_queue(struct net_device *ndev, struct sk_buff *skb,
 			  void *accel_priv, select_queue_fallback_t fallback)
 {
 	return skb_tx_hash(ndev, skb);
-- 
1.9.1
