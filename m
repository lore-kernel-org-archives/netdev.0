From: Maxime Bizon <mbizon@freebox.fr>
Subject: [PATCH][RFC] bridge: mark packets sent to any local mac address as
 PACKET_HOST
Date: Tue, 22 Apr 2014 19:50:18 +0200
Message-ID: <1398189018.19788.2.camel@sakura.staff.proxad.net>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.iliad.fr ([212.27.33.1]:41381 "EHLO ns.iliad.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933214AbaDVR7E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 13:59:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The bridge code only set PACKET_HOST on packets sent to the bridge mac
address, packets sent to other local mac addresses are sent to upper
layer, but ignored because they are marked as PACKET_OTHERHOST.
---
 net/bridge/br_input.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 7985dea..b942561 100644
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


-- 
Maxime
