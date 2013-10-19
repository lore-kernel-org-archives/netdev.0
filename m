From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 01/18] batman-adv: check skb preparation return value
Date: Sun, 20 Oct 2013 00:21:53 +0200
Message-ID: <1382221330-3769-2-git-send-email-antonio@meshcoding.com>
References: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:45037 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753563Ab3JSWW5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:22:57 -0400
In-Reply-To: <1382221330-3769-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix bogus merge conflict resolution by checking the return
values of the skb preparation routines.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/send.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 82588e4..d765d53 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -267,11 +267,14 @@ int batadv_send_skb_generic_unicast(struct batadv_priv *bat_priv,
 
 	switch (packet_type) {
 	case BATADV_UNICAST:
-		batadv_send_skb_prepare_unicast(skb, orig_node);
+		if (!batadv_send_skb_prepare_unicast(skb, orig_node))
+			goto out;
 		break;
 	case BATADV_UNICAST_4ADDR:
-		batadv_send_skb_prepare_unicast_4addr(bat_priv, skb, orig_node,
-						      packet_subtype);
+		if (!batadv_send_skb_prepare_unicast_4addr(bat_priv, skb,
+							   orig_node,
+							   packet_subtype))
+			goto out;
 		break;
 	default:
 		/* this function supports UNICAST and UNICAST_4ADDR only. It
-- 
1.8.4
