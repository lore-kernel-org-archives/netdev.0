From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH] bridge: mark packets sent to any local mac address as PACKET_HOST
Date: Mon, 23 Jun 2014 16:33:35 +0200
Message-ID: <1403534015-28496-1-git-send-email-mbizon@freebox.fr>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, Maxime Bizon <mbizon@freebox.fr>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:33235 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648AbaFWOng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 10:43:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge code only set PACKET_HOST on packets sent to the bridge mac
address, packets sent to other local mac addresses are sent to upper
layers, but ignored because they are marked as PACKET_OTHERHOST.

Signed-off-by: Maxime Bizon <mbizon@freebox.fr>
---
 net/bridge/br_input.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..b9cc8554 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -120,6 +120,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 			dst->is_local) {
 		skb2 = skb;
 		/* Do not forward the packet since it's local. */
+		skb2->pkt_type = PACKET_HOST;
 		skb = NULL;
 	}
 
-- 
1.7.9.5
