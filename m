From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/13] batman-adv: mark existing ogm variables as batman iv
Date: Wed, 18 Apr 2012 12:00:07 +0200
Message-ID: <1334743210-12338-11-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24988 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753035Ab2DRJ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:41 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

The coming protocol changes also will have a part called "OGM". That
makes it necessary to introduce a distinction in the code base.

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c     |    4 ++--
 net/batman-adv/hard-interface.c |    2 +-
 net/batman-adv/packet.h         |    4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index a2af289..98f7182 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -47,7 +47,7 @@ static int bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 		goto out;
 
 	batman_ogm_packet = (struct batman_ogm_packet *)hard_iface->packet_buff;
-	batman_ogm_packet->header.packet_type = BAT_OGM;
+	batman_ogm_packet->header.packet_type = BAT_IV_OGM;
 	batman_ogm_packet->header.version = COMPAT_VERSION;
 	batman_ogm_packet->header.ttl = 2;
 	batman_ogm_packet->flags = NO_FLAGS;
@@ -934,7 +934,7 @@ static void bat_iv_ogm_process(const struct ethhdr *ethhdr,
 	 * packet in an aggregation.  Here we expect that the padding
 	 * is always zero (or not 0x01)
 	 */
-	if (batman_ogm_packet->header.packet_type != BAT_OGM)
+	if (batman_ogm_packet->header.packet_type != BAT_IV_OGM)
 		return;
 
 	/* could be changed by schedule_own_packet() */
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index 75a555b..e8c5da3 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -604,7 +604,7 @@ static int batman_skb_recv(struct sk_buff *skb, struct net_device *dev,
 
 	switch (batman_ogm_packet->header.packet_type) {
 		/* batman originator packet */
-	case BAT_OGM:
+	case BAT_IV_OGM:
 		ret = recv_bat_ogm_packet(skb, hard_iface);
 		break;
 
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 59dec0a..f54969c 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -25,7 +25,7 @@
 #define ETH_P_BATMAN  0x4305	/* unofficial/not registered Ethertype */
 
 enum bat_packettype {
-	BAT_OGM		 = 0x01,
+	BAT_IV_OGM	 = 0x01,
 	BAT_ICMP	 = 0x02,
 	BAT_UNICAST	 = 0x03,
 	BAT_BCAST	 = 0x04,
@@ -38,7 +38,7 @@ enum bat_packettype {
 /* this file is included by batctl which needs these defines */
 #define COMPAT_VERSION 14
 
-enum batman_flags {
+enum batman_iv_flags {
 	PRIMARIES_FIRST_HOP = 1 << 4,
 	VIS_SERVER	    = 1 << 5,
 	DIRECTLINK	    = 1 << 6
-- 
1.7.9.4
