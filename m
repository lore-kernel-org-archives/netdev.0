From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 4/7] batman-adv: fix size of batadv_bla_claim_dst
Date: Sat, 28 Dec 2013 17:05:57 +0100
Message-ID: <1388246760-3335-5-git-send-email-antonio@meshcoding.com>
References: <1388246760-3335-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <antonio@meshcoding.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:35481 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319Ab3L1QJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Dec 2013 11:09:11 -0500
In-Reply-To: <1388246760-3335-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <sw@simonwunderlich.de>

Since this is a mac address and always 48 bit, and we can assume that
it is always aligned to 2-byte boundaries, add a pack(2) pragma.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/packet.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 2a857ed..04cf27c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -155,6 +155,7 @@ enum batadv_tvlv_type {
 	BATADV_TVLV_ROAM	= 0x05,
 };
 
+#pragma pack(2)
 /* the destination hardware field in the ARP frame is used to
  * transport the claim type and the group id
  */
@@ -163,6 +164,7 @@ struct batadv_bla_claim_dst {
 	uint8_t type;		/* bla_claimframe */
 	__be16 group;		/* group id */
 };
+#pragma pack()
 
 /**
  * struct batadv_ogm_packet - ogm (routing protocol) packet
-- 
1.8.5.2
