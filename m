From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 1/3] batman-adv: fix skb leak in batadv_dat_snoop_incoming_arp_reply()
Date: Sun, 27 Jan 2013 20:43:57 +0100
Message-ID: <1359315839-24136-2-git-send-email-ordex@autistici.org>
References: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:37025 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755395Ab3A0Toz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 14:44:55 -0500
In-Reply-To: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

The callers of batadv_dat_snoop_incoming_arp_reply() assume the skb has been
freed when it returns true; fix this by calling kfree_skb before returning as
it is done in batadv_dat_snoop_incoming_arp_request().

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 7485a78..9f4cff3 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -1012,6 +1012,8 @@ bool batadv_dat_snoop_incoming_arp_reply(struct batadv_priv *bat_priv,
 	 */
 	ret = !batadv_is_my_client(bat_priv, hw_dst);
 out:
+	if (ret)
+		kfree_skb(skb);
 	/* if ret == false -> packet has to be delivered to the interface */
 	return ret;
 }
-- 
1.8.1.1
