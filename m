From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH net-2.6] net_sched: always clone skbs
Date: Mon, 20 Dec 2010 22:35:30 +0800
Message-ID: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62392 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab0LTOgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 09:36:16 -0500
Received: by gyb11 with SMTP id 11so1213324gyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 06:36:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawel reported a panic related to handling shared skbs in ixgbe
incorrectly. So we need to revert my previous patch to work around
this bug. Instead of reverting the patch completely, I just revert
the essential lines, so we can add the previous optimization
back more easily in future.

    commit 3511c9132f8b1e1b5634e41a3331c44b0c13be70
    Author: Changli Gao <xiaosuo@gmail.com>
    Date:   Sat Oct 16 13:04:08 2010 +0000
    
        net_sched: remove the unused parameter of qdisc_create_dflt()

Reported-by: Pawel Staszewski <pstaszewski@itcare.pl>
Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 include/net/sch_generic.h |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 786cc39..0af57eb 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -611,11 +611,7 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
 {
 	struct sk_buff *n;
 
-	if ((action == TC_ACT_STOLEN || action == TC_ACT_QUEUED) &&
-	    !skb_shared(skb))
-		n = skb_get(skb);
-	else
-		n = skb_clone(skb, gfp_mask);
+	n = skb_clone(skb, gfp_mask);
 
 	if (n) {
 		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
