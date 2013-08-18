From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] net-packet: restore packet statistics tp_packets to include drops
Date: Sun, 18 Aug 2013 15:58:36 -0400
Message-ID: <1376855916-21824-1-git-send-email-willemb@google.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, dborkman@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:44410 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495Ab3HRT6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 15:58:39 -0400
Received: by mail-ve0-f201.google.com with SMTP id m1so335833ves.4
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 12:58:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

getsockopt PACKET_STATISTICS returns tp_packets + tp_drops.
Commit ee80fbf301 cleaned up the getsockopt PACKET_STATISTICS code.
This also changed semantics. Historically, tp_packets included
tp_drops on return. The commit removed the line that adds tp_drops
into tp_packets.

This patch reinstates the old semantics.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4b66c75..75c8bbf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3259,9 +3259,11 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
 		if (po->tp_version == TPACKET_V3) {
 			lv = sizeof(struct tpacket_stats_v3);
+			st.stats3.tp_packets += st.stats3.tp_drops;
 			data = &st.stats3;
 		} else {
 			lv = sizeof(struct tpacket_stats);
+			st.stats1.tp_packets += st.stats1.tp_drops;
 			data = &st.stats1;
 		}
 
-- 
1.8.3
