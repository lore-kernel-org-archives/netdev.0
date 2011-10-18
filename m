From: Marek Lindner <lindner_marek@yahoo.de>
Subject: [PATCH 2/2] batman-adv: correctly set the data field in the TT_REPONSE packet
Date: Tue, 18 Oct 2011 23:01:09 +0200
Message-ID: <1318971669-941-3-git-send-email-lindner_marek@yahoo.de>
References: <1318971669-941-1-git-send-email-lindner_marek@yahoo.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm6-vm0.bullet.mail.ukl.yahoo.com ([217.146.183.234]:46678 "HELO
	nm6-vm0.bullet.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752471Ab1JRVBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 17:01:30 -0400
In-Reply-To: <1318971669-941-1-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <ordex@autistici.org>

In the TT_RESPONSE packet, the number of carried entries is not correctly set.
This leads to a wrong interpretation of the packet payload on the receiver side
causing random entries to be added to the global translation table. Therefore
the latter gets always corrupted, triggering a table recovery all the time.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/translation-table.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index f599db9..ef1acfd 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -999,7 +999,6 @@ static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	tt_response = (struct tt_query_packet *)skb_put(skb,
 						     tt_query_size + tt_len);
 	tt_response->ttvn = ttvn;
-	tt_response->tt_data = htons(tt_tot);
 
 	tt_change = (struct tt_change *)(skb->data + tt_query_size);
 	tt_count = 0;
@@ -1025,6 +1024,10 @@ static struct sk_buff *tt_response_fill_table(uint16_t tt_len, uint8_t ttvn,
 	}
 	rcu_read_unlock();
 
+	/* store in the message the number of entries we have successfully
+	 * copied */
+	tt_response->tt_data = htons(tt_count);
+
 out:
 	return skb;
 }
-- 
1.7.5.4
