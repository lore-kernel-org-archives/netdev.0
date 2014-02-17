From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 08/10] batman-adv: free skb on TVLV parsing success
Date: Mon, 17 Feb 2014 21:48:47 +0100
Message-ID: <1392670129-2498-9-git-send-email-antonio@meshcoding.com>
References: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:47531 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbaBQUxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 15:53:16 -0500
In-Reply-To: <1392670129-2498-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

When the TVLV parsing routine succeed the skb is left
untouched thus leading to a memory leak.

Fix this by consuming the skb in case of success.

Introduced by ef26157747d42254453f6b3ac2bd8bd3c53339c3
("batman-adv: tvlv - basic infrastructure")

Reported-by: Russel Senior <russell@personaltelco.net>
Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Tested-by: Russell Senior <russell@personaltelco.net>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/routing.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index c26f073..a953d5b 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -918,6 +918,8 @@ int batadv_recv_unicast_tvlv(struct sk_buff *skb,
 
 	if (ret != NET_RX_SUCCESS)
 		ret = batadv_route_unicast_packet(skb, recv_if);
+	else
+		consume_skb(skb);
 
 	return ret;
 }
-- 
1.8.5.3
