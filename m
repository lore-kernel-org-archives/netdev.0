From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: [PATCH v2] pppoe: Lacks DST MAC address check
Date: Sat, 18 Apr 2015 11:53:14 +0200
Message-ID: <1429350794-17170-1-git-send-email-Joakim.Tjernlund@transmode.se>
Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.transmode.se ([31.15.61.139]:62818 "EHLO smtp.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbbDRJxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Apr 2015 05:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pppoe session is identified by its session ID and MAC address.
Currently pppoe does not check if the received pkg has the correct
MAC address. This is a problem when the eth I/F is in promisc mode
as then any DST MAC address is accepted.
---

v2 - The MAC address check should encompass all pppoe pkgs,
     not only the relay type.
 drivers/net/ppp/pppoe.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index ff059e1..aa1dd92 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -380,6 +380,9 @@ static int pppoe_rcv_core(struct sock *sk, struct sk_buff *skb)
 	 * can't change.
 	 */
 
+	if (skb->pkt_type == PACKET_OTHERHOST)
+		goto abort_kfree;
+
 	if (sk->sk_state & PPPOX_BOUND) {
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
-- 
2.0.5
