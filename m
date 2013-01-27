From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 2/3] batman-adv: check for more types of invalid IP addresses in DAT
Date: Sun, 27 Jan 2013 20:43:58 +0100
Message-ID: <1359315839-24136-3-git-send-email-ordex@autistici.org>
References: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:37100 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755435Ab3A0To5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2013 14:44:57 -0500
In-Reply-To: <1359315839-24136-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

There are more types of IP addresses that may appear in ARP packets that we
don't want to process. While some of these should never appear in sane ARP
packets, a 0.0.0.0 source is used for duplicate address detection and thus seen
quite often.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index 9f4cff3..be3be28 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -777,7 +777,9 @@ static uint16_t batadv_arp_get_type(struct batadv_priv *bat_priv,
 	ip_src = batadv_arp_ip_src(skb, hdr_size);
 	ip_dst = batadv_arp_ip_dst(skb, hdr_size);
 	if (ipv4_is_loopback(ip_src) || ipv4_is_multicast(ip_src) ||
-	    ipv4_is_loopback(ip_dst) || ipv4_is_multicast(ip_dst))
+	    ipv4_is_loopback(ip_dst) || ipv4_is_multicast(ip_dst) ||
+	    ipv4_is_zeronet(ip_src) || ipv4_is_lbcast(ip_src) ||
+	    ipv4_is_zeronet(ip_dst) || ipv4_is_lbcast(ip_dst))
 		goto out;
 
 	type = ntohs(arphdr->ar_op);
-- 
1.8.1.1
