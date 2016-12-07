From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] icmp: correct return value of icmp_rcv()
Date: Wed,  7 Dec 2016 14:52:53 +0800
Message-ID: <1481093573-5123-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19230 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751092AbcLGGxL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 01:53:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, icmp_rcv() always return zero on a packet delivery upcall.

To make its behavior more compliant with the way this API should be
used, this patch changes this to let it return NET_RX_SUCCESS when the
packet is proper handled, and NET_RX_DROP otherwise.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/ipv4/icmp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 691146a..f79d7a8 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -1047,12 +1047,12 @@ int icmp_rcv(struct sk_buff *skb)
 
 	if (success)  {
 		consume_skb(skb);
-		return 0;
+		return NET_RX_SUCCESS;
 	}
 
 drop:
 	kfree_skb(skb);
-	return 0;
+	return NET_RX_DROP;
 csum_error:
 	__ICMP_INC_STATS(net, ICMP_MIB_CSUMERRORS);
 error:
-- 
1.8.3.1
