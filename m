From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 04/10] batman-adv: properly check pskb_may_pull return value
Date: Mon, 17 Feb 2014 21:48:43 +0100
Message-ID: <1392670129-2498-5-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@meshcoding.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:6976 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbaBQUxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:04 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pskb_may_pull() returns 1 on success and 0 in case of failure,
therefore checking for the return value being negative does
not make sense at all.

This way if the function fails we will probably read beyond the current
skb data buffer. Fix this by doing the proper check.

Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/routing.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index 1ed9f7c..c26f073 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -688,7 +688,7 @@ static int batadv_check_unicast_ttvn(struct batadv_priv *bat_priv,
 	int is_old_ttvn;
 
 	/* check if there is enough data before accessing it */
-	if (pskb_may_pull(skb, hdr_len + ETH_HLEN) < 0)
+	if (!pskb_may_pull(skb, hdr_len + ETH_HLEN))
 		return 0;
 
 	/* create a copy of the skb (in case of for re-routing) to modify it. */
-- 
1.8.5.3
