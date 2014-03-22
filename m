From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [PATCH 14/16] batman-adv: improve the TT flags documentation
Date: Sat, 22 Mar 2014 09:56:14 +0100
Message-ID: <1395478576-10999-15-git-send-email-antonio@meshcoding.com>
References: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:37382 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921AbaCVJOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2014 05:14:04 -0400
In-Reply-To: <1395478576-10999-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Convert the current documentation for the TT flags in proper
kerneldoc and improve it by adding an explanation for each
of the flags.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/packet.h | 28 ++++++++++++++++++++++++----
 1 file changed, 24 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index c7f6eef..34e096d 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -119,10 +119,30 @@ enum batadv_tt_data_flags {
 	BATADV_TT_FULL_TABLE = BIT(4),
 };
 
-/* BATADV_TT_CLIENT flags.
- * Flags from BIT(0) to BIT(7) are sent on the wire, while flags from BIT(8) to
- * BIT(15) are used for local computation only.
- * Flags from BIT(4) to BIT(7) are kept in sync with the rest of the network.
+/**
+ * enum batadv_tt_client_flags - TT client specific flags
+ * @BATADV_TT_CLIENT_DEL: the client has to be deleted from the table
+ * @BATADV_TT_CLIENT_ROAM: the client roamed to/from another node and the new
+ *  update telling its new real location has not been received/sent yet
+ * @BATADV_TT_CLIENT_WIFI: this client is connected through a wifi interface.
+ *  This information is used by the "AP Isolation" feature
+ * @BATADV_TT_CLIENT_ISOLA: this client is considered "isolated". This
+ *  information is used by the Extended Isolation feature
+ * @BATADV_TT_CLIENT_NOPURGE: this client should never be removed from the table
+ * @BATADV_TT_CLIENT_NEW: this client has been added to the local table but has
+ *  not been announced yet
+ * @BATADV_TT_CLIENT_PENDING: this client is marked for removal but it is kept
+ *  in the table for one more originator interval for consistency purposes
+ * @BATADV_TT_CLIENT_TEMP: this global client has been detected to be part of
+ *  the network but no nnode has already announced it
+ *
+ * Bits from 0 to 7 are called _remote flags_ because they are sent on the wire.
+ * Bits from 8 to 15 are called _local flags_ because they are used for local
+ * computations only.
+ *
+ * Bits from 4 to 7 - a subset of remote flags - are ensured to be in sync with
+ * the other nodes in the network. To achieve this goal these flags are included
+ * in the TT CRC computation.
  */
 enum batadv_tt_client_flags {
 	BATADV_TT_CLIENT_DEL     = BIT(0),
-- 
1.8.3.2
