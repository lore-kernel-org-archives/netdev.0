From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 05/13] batman-adv: randomize initial seqno to avoid collision
Date: Wed, 18 Apr 2012 12:00:02 +0200
Message-ID: <1334743210-12338-6-git-send-email-ordex@autistici.org>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:24575 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524Ab2DRJ71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 05:59:27 -0400
In-Reply-To: <1334743210-12338-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <lindner_marek@yahoo.de>

Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bat_iv_ogm.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/batman-adv/bat_iv_ogm.c b/net/batman-adv/bat_iv_ogm.c
index 117b831..95bfc59 100644
--- a/net/batman-adv/bat_iv_ogm.c
+++ b/net/batman-adv/bat_iv_ogm.c
@@ -33,6 +33,11 @@
 static void bat_iv_ogm_iface_enable(struct hard_iface *hard_iface)
 {
 	struct batman_ogm_packet *batman_ogm_packet;
+	uint32_t random_seqno;
+
+	/* randomize initial seqno to avoid collision */
+	get_random_bytes(&random_seqno, sizeof(random_seqno));
+	atomic_set(&hard_iface->seqno, random_seqno);
 
 	hard_iface->packet_len = BATMAN_OGM_LEN;
 	hard_iface->packet_buff = kmalloc(hard_iface->packet_len, GFP_ATOMIC);
-- 
1.7.9.4
