From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 16/21] batman-adv: Remove unnecessary INIT_HLIST_NODE() calls
Date: Wed, 29 May 2013 10:10:46 +0200
Message-ID: <1369815051-708-17-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:39890 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965031Ab3E2ING (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:13:06 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Linus L=C3=BCssing <linus.luessing@web.de>

There's no need to for an explicit hlist_node initialization if it is
added to a list right away, like it's the case with the
hlist_add_head()s here.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c | 2 --
 net/batman-adv/send.c       | 2 --
 2 files changed, 4 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 5b0a043..d07323b 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -464,8 +464,6 @@ static void batadv_iv_ogm_aggregate_new(const unsig=
ned char *packet_buff,
 	}
 	skb_reserve(forw_packet_aggr->skb, ETH_HLEN);
=20
-	INIT_HLIST_NODE(&forw_packet_aggr->list);
-
 	skb_buff =3D skb_put(forw_packet_aggr->skb, packet_len);
 	forw_packet_aggr->packet_len =3D packet_len;
 	memcpy(skb_buff, packet_buff, packet_len);
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index ed7072a..ce69f45 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -152,8 +152,6 @@ _batadv_add_bcast_packet_to_list(struct batadv_priv=
 *bat_priv,
 				 struct batadv_forw_packet *forw_packet,
 				 unsigned long send_time)
 {
-	INIT_HLIST_NODE(&forw_packet->list);
-
 	/* add new packet to packet list */
 	spin_lock_bh(&bat_priv->forw_bcast_list_lock);
 	hlist_add_head(&forw_packet->list, &bat_priv->forw_bcast_list);
--=20
1.8.1.5
