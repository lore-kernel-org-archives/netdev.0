From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 15/16] batman-adv: remove packed from batadv_ogm_packet
Date: Wed,  9 Oct 2013 14:40:17 +0200
Message-ID: <1381322418-1349-16-git-send-email-antonio@meshcoding.com>
References: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4158 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab3JINKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 09:10:07 -0400
In-Reply-To: <1381322418-1349-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

As we decreased the struct size from 26 to 24 byte, we can remove
__packed as the compiler will not add any more padding.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/packet.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index f02dbb1..4e5fe7d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -175,7 +175,10 @@ struct batadv_ogm_packet {
 	uint8_t  reserved;
 	uint8_t  tq;
 	__be16   tvlv_len;
-} __packed;
+	/* __packed is not needed as the struct size is divisible by 4,
+	 * and the largest data type in this struct has a size of 4.
+	 */
+};
 
 #define BATADV_OGM_HLEN sizeof(struct batadv_ogm_packet)
 
-- 
1.8.3.2
