From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH] net: Fix inner_network_header assignment in skb-copy.
Date: Fri,  1 Feb 2013 17:18:49 -0800
Message-ID: <1359767929-1875-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:47318 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757258Ab3BBBRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 20:17:11 -0500
Received: by mail-gh0-f199.google.com with SMTP id r16so6383230ghr.6
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 17:17:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use correct inner offset to set inner_network_offset.
Found by inspection.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/core/skbuff.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bddc1dd..55f7ef6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -686,7 +686,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->network_header	= old->network_header;
 	new->mac_header		= old->mac_header;
 	new->inner_transport_header = old->inner_transport_header;
-	new->inner_network_header = old->inner_transport_header;
+	new->inner_network_header = old->inner_network_header;
 	skb_dst_copy(new, old);
 	new->rxhash		= old->rxhash;
 	new->ooo_okay		= old->ooo_okay;
-- 
1.7.10
