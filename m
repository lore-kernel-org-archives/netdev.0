From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/13] via-velocity: use memmove
Date: Wed, 16 Apr 2008 16:37:32 -0700
Message-ID: <20080416233757.317373462@vyatta.com>
References: <20080416233727.732025083@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:43785 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbYDPXt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 19:49:27 -0400
Content-Disposition: inline; filename=via-velocity-memmove
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use memmove to handle overlapping copy of data.
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/via-velocity.c	2008-04-16 16:21:25.000000000 -0700
+++ b/drivers/net/via-velocity.c	2008-04-16 16:24:48.000000000 -0700
@@ -1522,12 +1522,8 @@ static int velocity_rx_copy(struct sk_bu
 static inline void velocity_iph_realign(struct velocity_info *vptr,
 					struct sk_buff *skb, int pkt_size)
 {
-	/* FIXME - memmove ? */
 	if (vptr->flags & VELOCITY_FLAGS_IP_ALIGN) {
-		int i;
-
-		for (i = pkt_size; i >= 0; i--)
-			*(skb->data + i + 2) = *(skb->data + i);
+		memmove(skb->data + 2, skb->data, pkt_size);
 		skb_reserve(skb, 2);
 	}
 }

-- 

