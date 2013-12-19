From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 2/6] batman-adv: fix alignment for batadv_coded_packet
Date: Thu, 19 Dec 2013 01:15:28 +0100
Message-ID: <1387412132-889-3-git-send-email-antonio@meshcoding.com>
References: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:22546 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab3LSAR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 19:17:58 -0500
In-Reply-To: <1387412132-889-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

The compiler may decide to pad the structure, and then it does not
have the expected size of 46 byte. Fix this by moving it in the
pragma pack(2) part of the code.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/packet.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 207459b..10597a6 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -315,8 +315,6 @@ struct batadv_bcast_packet {
 	 */
 };
 
-#pragma pack()
-
 /**
  * struct batadv_coded_packet - network coded packet
  * @header: common batman packet header and ttl of first included packet
@@ -349,6 +347,8 @@ struct batadv_coded_packet {
 	__be16   coded_len;
 };
 
+#pragma pack()
+
 /**
  * struct batadv_unicast_tvlv - generic unicast packet with tvlv payload
  * @header: common batman packet header
-- 
1.8.5.1
