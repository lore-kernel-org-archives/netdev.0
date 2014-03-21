From: roy.qing.li@gmail.com
Subject: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Fri, 21 Mar 2014 20:53:57 +0800
Message-ID: <1395406437-19834-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:63403 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965398AbaCUMyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 08:54:07 -0400
Received: by mail-pa0-f49.google.com with SMTP id lj1so2360277pab.22
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 05:54:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

Neighbor Solicitation is ipv6 protocol, so we should check
skb->protocol with ETH_P_IPV6

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: WANG Cong <amwang@redhat.com>
---
 net/core/netpoll.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index a664f78..df9e6b1 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -742,7 +742,7 @@ static bool pkt_is_ns(struct sk_buff *skb)
 	struct nd_msg *msg;
 	struct ipv6hdr *hdr;
 
-	if (skb->protocol != htons(ETH_P_ARP))
+	if (skb->protocol != htons(ETH_P_IPV6))
 		return false;
 	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + sizeof(struct nd_msg)))
 		return false;
-- 
1.7.10.4
