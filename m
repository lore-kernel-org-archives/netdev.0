From: Sorin Dumitru <sdumitru@ixiacom.com>
Subject: [PATCH] llc: free the right skb
Date: Mon, 6 Aug 2012 15:35:58 +0300
Message-ID: <1344256558-22649-1-git-send-email-sdumitru@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <acme@ghostprotocols.net>, <davem@davemloft.net>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:8741
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754491Ab2HFMgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 08:36:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are freeing skb instead of nskb, resulting in a double
free on skb and a leak from nskb.

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
---
 net/llc/llc_station.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/llc/llc_station.c b/net/llc/llc_station.c
index 39a8d89..6828e39 100644
--- a/net/llc/llc_station.c
+++ b/net/llc/llc_station.c
@@ -268,7 +268,7 @@ static int llc_station_ac_send_null_dsap_xid_c(struct sk_buff *skb)
 out:
 	return rc;
 free:
-	kfree_skb(skb);
+	kfree_skb(nskb);
 	goto out;
 }
 
@@ -293,7 +293,7 @@ static int llc_station_ac_send_xid_r(struct sk_buff *skb)
 out:
 	return rc;
 free:
-	kfree_skb(skb);
+	kfree_skb(nskb);
 	goto out;
 }
 
@@ -322,7 +322,7 @@ static int llc_station_ac_send_test_r(struct sk_buff *skb)
 out:
 	return rc;
 free:
-	kfree_skb(skb);
+	kfree_skb(nskb);
 	goto out;
 }
 
-- 
1.7.11.4
