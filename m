From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] packet: restore packet statistics tp_packets to include drops
Date: Mon, 19 Aug 2013 16:40:22 -0400
Message-ID: <1376944822-30454-1-git-send-email-willemb@google.com>
References: <5212625A.1090704@cogentembedded.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, dborkman@redhat.com, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f202.google.com ([209.85.160.202]:51381 "EHLO
	mail-gh0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab3HSUkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 16:40:31 -0400
Received: by mail-gh0-f202.google.com with SMTP id g24so468222ghb.1
        for <netdev@vger.kernel.org>; Mon, 19 Aug 2013 13:40:30 -0700 (PDT)
In-Reply-To: <5212625A.1090704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

getsockopt PACKET_STATISTICS returns tp_packets + tp_drops. Commit
ee80fbf301 ("packet: account statistics only in tpacket_stats_u")
cleaned up the getsockopt PACKET_STATISTICS code.
This also changed semantics. Historically, tp_packets included
tp_drops on return. The commit removed the line that adds tp_drops
into tp_packets.

This patch reinstates the old semantics.

Signed-off-by: Willem de Bruijn <willemb@google.com>

---

v2: incorporated commit summary by request. no code changes
---
 net/packet/af_packet.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 6c53dd9..1fdf9ab 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -3215,9 +3215,11 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 
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
