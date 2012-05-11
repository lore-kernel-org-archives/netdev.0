From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 08/15] batman-adv: ignore protocol packets if the interface did not enable this protocol
Date: Fri, 11 May 2012 14:21:25 +0200
Message-ID: <1336738892-7401-9-git-send-email-ordex@autistici.org>
References: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:58371 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758410Ab2EKMZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 08:25:11 -0400
In-Reply-To: <1336738892-7401-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Reported-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index ae0a08c..37e368d 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -1186,6 +1186,7 @@ out:
 static int bat_iv_ogm_receive(struct sk_buff *skb,
 			      struct hard_iface *if_incoming)
 {
+	struct bat_priv *bat_priv = netdev_priv(if_incoming->soft_iface);
 	struct batman_ogm_packet *batman_ogm_packet;
 	struct ethhdr *ethhdr;
 	int buff_pos = 0, packet_len;
@@ -1196,6 +1197,12 @@ static int bat_iv_ogm_receive(struct sk_buff *skb,
 	if (!ret)
 		return NET_RX_DROP;
 
+	/* did we receive a B.A.T.M.A.N. IV OGM packet on an interface
+	 * that does not have B.A.T.M.A.N. IV enabled ?
+	 */
+	if (bat_priv->bat_algo_ops->bat_ogm_emit != bat_iv_ogm_emit)
+		return NET_RX_DROP;
+
 	packet_len = skb_headlen(skb);
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 	packet_buff = skb->data;
-- 
1.7.9.4
