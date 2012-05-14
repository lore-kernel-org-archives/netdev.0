From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/8] batman-adv: avoid skb_linearise() if not needed
Date: Mon, 14 May 2012 09:17:31 +0200
Message-ID: <1336979858-13928-2-git-send-email-ordex@autistici.org>
References: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:51687 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601Ab2ENHRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 03:17:08 -0400
In-Reply-To: <1336979858-13928-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Whenever we want to access headers only, we do not need to linearise the whole
packet. Instead we can use pskb_may_pull()

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/routing.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 7ed9d8f..4c6467d 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -916,8 +916,9 @@ static int check_unicast_ttvn(struct bat_priv *bat_priv,
 
 	/* Check whether I have to reroute the packet */
 	if (seq_before(unicast_packet->ttvn, curr_ttvn) || tt_poss_change) {
-		/* Linearize the skb before accessing it */
-		if (skb_linearize(skb) < 0)
+		/* check if there is enough data before accessing it */
+		if (pskb_may_pull(skb, sizeof(struct unicast_packet) +
+				  ETH_HLEN) < 0)
 			return 0;
 
 		ethhdr = (struct ethhdr *)(skb->data +
-- 
1.7.9.4
