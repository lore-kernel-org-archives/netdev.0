From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/4] batman-adv: correctly pass the client flag on tt_response
Date: Fri, 16 Nov 2012 09:49:16 +0100
Message-ID: <1353055758-2901-3-git-send-email-ordex@autistici.org>
References: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Sven Eckelmann <sven@narfation.org>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:34856 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab2KPIuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 03:50:22 -0500
In-Reply-To: <1353055758-2901-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a TT response with the full table is sent, the client flags
should be sent as well. This patch fix the flags assignment when
populating the tt_response to send back

This was introduced by 30cfd02b60e1cb16f5effb0a01f826c5bb7e4c59
("batman-adv: detect not yet announced clients")

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 64c0012..fec1a00 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -1502,7 +1502,7 @@ batadv_tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 
 			memcpy(tt_change->addr, tt_common_entry->addr,
 			       ETH_ALEN);
-			tt_change->flags = BATADV_NO_FLAGS;
+			tt_change->flags = tt_common_entry->flags;
 
 			tt_count++;
 			tt_change++;
-- 
1.8.0
