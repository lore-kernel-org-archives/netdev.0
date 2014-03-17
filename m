From: roy.qing.li@gmail.com
Subject: [PATCH] netpoll: fix the skb check in pkt_is_ns
Date: Mon, 17 Mar 2014 16:53:39 +0800
Message-ID: <1395046419-29114-1-git-send-email-roy.qing.li@gmail.com>
Cc: amwang@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:65023 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751421AbaCQIx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 04:53:57 -0400
Received: by mail-pa0-f47.google.com with SMTP id lj1so5408105pab.6
        for <netdev@vger.kernel.org>; Mon, 17 Mar 2014 01:53:56 -0700 (PDT)
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
index 570eb40..159f160 100644
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
