From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 1/5] qede: use reset to set network header
Date: Fri,  2 Dec 2016 09:51:03 +0800
Message-ID: <1480643467-4420-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:19745 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754848AbcLBBvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:18 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index b84a2c4..31c8449 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -1220,7 +1220,7 @@ static void qede_gro_receive(struct qede_dev *edev,
 
 #ifdef CONFIG_INET
 	if (skb_shinfo(skb)->gso_size) {
-		skb_set_network_header(skb, 0);
+		skb_reset_network_header(skb);
 
 		switch (skb->protocol) {
 		case htons(ETH_P_IP):
-- 
1.8.3.1
