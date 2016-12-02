From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 2/5] bnx2x: use reset to set network header
Date: Fri,  2 Dec 2016 09:51:04 +0800
Message-ID: <1480643467-4420-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19229 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752680AbcLBBvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 20:51:19 -0500
In-Reply-To: <1480643467-4420-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zero, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 3fd36b4..3e199d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -724,7 +724,7 @@ static void bnx2x_gro_ipv6_csum(struct bnx2x *bp, struct sk_buff *skb)
 static void bnx2x_gro_csum(struct bnx2x *bp, struct sk_buff *skb,
 			    void (*gro_func)(struct bnx2x*, struct sk_buff*))
 {
-	skb_set_network_header(skb, 0);
+	skb_reset_network_header(skb);
 	gro_func(bp, skb);
 	tcp_gro_complete(skb);
 }
-- 
1.8.3.1
