From: roy.qing.li@gmail.com
Subject: [PATCH 3/3] netfilter: ip6_route_output() never returns NULL.
Date: Wed, 22 Feb 2012 16:10:51 +0800
Message-ID: <1329898251-5357-3-git-send-email-roy.qing.li@gmail.com>
References: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41798 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2BVIMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 03:12:15 -0500
Received: by mail-ee0-f46.google.com with SMTP id c14so3061517eek.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 00:12:14 -0800 (PST)
In-Reply-To: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com>

ip6_route_output() never returns NULL, so it is wrong to
check if the return value is NULL.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/netfilter/xt_TEE.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 3aae66f..4d50579 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -152,9 +152,10 @@ tee_tg_route6(struct sk_buff *skb, const struct xt_tee_tginfo *info)
 	fl6.flowlabel = ((iph->flow_lbl[0] & 0xF) << 16) |
 			   (iph->flow_lbl[1] << 8) | iph->flow_lbl[2];
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL)
+	if (dst->error) {
+		dst_release(dst);
 		return false;
-
+	}
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
 	skb->dev      = dst->dev;
-- 
1.7.1
