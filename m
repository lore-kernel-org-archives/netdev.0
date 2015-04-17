From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH] pppoe: Lacks DST MAC address check
Date: Fri, 17 Apr 2015 20:17:08 +0200
Message-ID: <1429294628-4928-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.transmode.se ([31.15.61.139]:50357 "EHLO smtp.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbbDQSRN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2015 14:17:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pppoe session is identified by its session ID and MAC address.
Currently pppoe does not check if the received pkg has the correct
MAC address. This is a problem when the eth I/F is in promisc mode
as then any DST MAC address is accepted.

Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
---
 drivers/net/ppp/pppoe.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index ff059e1..740e39b 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -383,6 +383,9 @@ static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
+		if (skb->pkt_type == PACKET_OTHERHOST)
+			goto abort_kfree;
+
 		relay_po = get_item_by_addr(sock_net(sk),
 					    &po->pppoe_relay);
 		if (relay_po == NULL)
-- 
2.0.5
