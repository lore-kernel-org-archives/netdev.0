From: Antonio Quartulli <antonio@open-mesh.com>
Subject: [PATCH 2/3] sk_buff: add bridge_restricted flag
Date: Mon, 8 Apr 2013 19:41:02 +0200
Message-ID: <1365442863-32394-3-git-send-email-antonio@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bridge@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
	Antonio Quartulli <antonio@open-mesh.com>
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:60036 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934566Ab3DHRs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 13:48:27 -0400
In-Reply-To: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This new flag tells whether the skb has been originated by
an interface marked with the IFF_BRIDGE_RESTRICTED flag.

This information can be used to prevent a packet from being
forwarded to another restricted interface.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
---
 include/linux/skbuff.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e27d1c7..2054073 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -492,7 +492,8 @@ struct sk_buff {
 	 * headers if needed
 	 */
 	__u8			encapsulation:1;
-	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
+	__u8			bridge_restricted:1;
+	/* 9/11 bit hole (depending on ndisc_nodetype presence) */
 	kmemcheck_bitfield_end(flags2);
 
 #ifdef CONFIG_NET_DMA
-- 
1.8.1.5
