From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 12:22:53 +0000
Message-ID: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta2.chinamobile.com ([221.176.66.80]:3942 "EHLO
	cmccmta2.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754014AbcB2MVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 07:21:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
Then at skb_vlan_untag(), it will free skbuff again which cause double
free.

This patch removes kfree_skb() call in function skb_reorder_vlan_header().

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/core/skbuff.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 488566b..1312d4b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4350,7 +4350,6 @@ EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
 static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
 {
 	if (skb_cow(skb, skb_headroom(skb)) < 0) {
-		kfree_skb(skb);
 		return NULL;
 	}
 
-- 
1.8.3.1
