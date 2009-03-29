From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2]: tg3: Add GRO support.
Date: Sun, 29 Mar 2009 03:17:24 -0700 (PDT)
Message-ID: <20090329.031724.171895685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34505
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753906AbZC2KRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:17:36 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id DB901C8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:17:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f7efcec..1205c2a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4392,7 +4392,7 @@ static void tg3_recycle_rx(struct tg3 *tp, u32 opaque_key,
 #if TG3_VLAN_TAG_USED
 static int tg3_vlan_rx(struct tg3 *tp, struct sk_buff *skb, u16 vlan_tag)
 {
-	return vlan_hwaccel_receive_skb(skb, tp->vlgrp, vlan_tag);
+	return vlan_gro_receive(&tp->napi, tp->vlgrp, vlan_tag, skb);
 }
 #endif
 
@@ -4539,7 +4539,7 @@ static int tg3_rx(struct tg3 *tp, int budget)
 				    desc->err_vlan & RXD_VLAN_MASK);
 		} else
 #endif
-			netif_receive_skb(skb);
+			napi_gro_receive(&tp->napi, skb);
 
 		received++;
 		budget--;
-- 
1.6.2.1.222.g570cc

