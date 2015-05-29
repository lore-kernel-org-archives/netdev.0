From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 06/16] batman-adv: tvlv realloc, move error handling into if block
Date: Fri, 29 May 2015 11:05:18 +0200
Message-ID: <1432890328-8247-7-git-send-email-antonio@meshcoding.com>
References: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Markus Pargmann <mpa@pengutronix.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:24239 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726AbbE2JVp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 May 2015 05:21:45 -0400
In-Reply-To: <1432890328-8247-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Pargmann <mpa@pengutronix.de>

Instead of hiding the normal function flow inside an if block, we should
just put the error handling into the if block.

Signed-off-by: Markus Pargmann <mpa@pengutronix.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/main.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index ca63d48..fd9333d 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -819,15 +819,15 @@ static bool batadv_tvlv_realloc_packet_buff(unsigned char **packet_buff,
 	new_buff = kmalloc(min_packet_len + additional_packet_len, GFP_ATOMIC);
 
 	/* keep old buffer if kmalloc should fail */
-	if (new_buff) {
-		memcpy(new_buff, *packet_buff, min_packet_len);
-		kfree(*packet_buff);
-		*packet_buff = new_buff;
-		*packet_buff_len = min_packet_len + additional_packet_len;
-		return true;
-	}
+	if (!new_buff)
+		return false;
 
-	return false;
+	memcpy(new_buff, *packet_buff, min_packet_len);
+	kfree(*packet_buff);
+	*packet_buff = new_buff;
+	*packet_buff_len = min_packet_len + additional_packet_len;
+
+	return true;
 }
 
 /**
-- 
2.4.2
