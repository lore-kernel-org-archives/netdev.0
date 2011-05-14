From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 2/2] batman-adv: reset broadcast flood protection on error
Date: Sun, 15 May 2011 00:16:34 +0200
Message-ID: <1305411394-28807-3-git-send-email-sven@narfation.org>
References: <1305411394-28807-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:45203 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755132Ab1ENWQv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 18:16:51 -0400
In-Reply-To: <1305411394-28807-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The broadcast flood protection should be reset to its original value
if the primary interface could not be retrieved.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/send.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index 76daa46..3377927 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -421,7 +421,7 @@ int add_bcast_packet_to_list(struct bat_priv *bat_priv, struct sk_buff *skb)
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
-		goto out;
+		goto out_and_inc;
 
 	forw_packet = kmalloc(sizeof(struct forw_packet), GFP_ATOMIC);
 
-- 
1.7.5.1

