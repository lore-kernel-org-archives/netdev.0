From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 4/4] cxgb4: Report correct link speed for unsupported ones
Date: Wed, 30 Sep 2015 20:33:31 +0530
Message-ID: <1443625411-12096-5-git-send-email-hariprasad@chelsio.com>
References: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18047 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752871AbbI3PC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 11:02:59 -0400
In-Reply-To: <1443625411-12096-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we get garbage from the firmware with weird Port Speeds,
etc. we should emit a warning regarding unsupported speeds rather than
use the bogus default of "10Mbps" which isn't even an option in the
firmware Port Information message

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 0b7570d..9f1f5b2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -275,7 +275,7 @@ static void link_report(struct net_device *dev)
 	else {
 		static const char *fc[] = { "no", "Rx", "Tx", "Tx/Rx" };
 
-		const char *s = "10Mbps";
+		const char *s;
 		const struct port_info *p = netdev_priv(dev);
 
 		switch (p->link_cfg.speed) {
@@ -291,6 +291,10 @@ static void link_report(struct net_device *dev)
 		case 40000:
 			s = "40Gbps";
 			break;
+		default:
+			pr_info("%s: unsupported speed: %d\n",
+				dev->name, p->link_cfg.speed);
+			return;
 		}
 
 		netdev_info(dev, "link up, %s, full-duplex, %s PAUSE\n", s,
-- 
2.3.4
