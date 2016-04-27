From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/17] net: sctp: rename SCTP_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:34 -0700
Message-ID: <1461800683-25034-9-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:34200 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbcD0XpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:11 -0400
Received: by mail-pf0-f174.google.com with SMTP id y69so26274299pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:11 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename SCTP_INC_STATS_BH() to __SCTP_INC_STATS()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sctp/sctp.h |  2 +-
 net/sctp/input.c        | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 5a2c4c3307a7..5607c009f738 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -206,7 +206,7 @@ extern int sysctl_sctp_wmem[3];
 
 /* SCTP SNMP MIB stats handlers */
 #define SCTP_INC_STATS(net, field)      SNMP_INC_STATS((net)->sctp.sctp_statistics, field)
-#define SCTP_INC_STATS_BH(net, field)   SNMP_INC_STATS_BH((net)->sctp.sctp_statistics, field)
+#define __SCTP_INC_STATS(net, field)   SNMP_INC_STATS_BH((net)->sctp.sctp_statistics, field)
 #define SCTP_DEC_STATS(net, field)      SNMP_DEC_STATS((net)->sctp.sctp_statistics, field)
 
 /* sctp mib definitions */
diff --git a/net/sctp/input.c b/net/sctp/input.c
index f8eca792dbcf..12332fc3eb44 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -84,7 +84,7 @@ static inline int sctp_rcv_checksum(struct net *net, struct sk_buff *skb)
 
 	if (val != cmp) {
 		/* CRC failure, dump it. */
-		SCTP_INC_STATS_BH(net, SCTP_MIB_CHECKSUMERRORS);
+		__SCTP_INC_STATS(net, SCTP_MIB_CHECKSUMERRORS);
 		return -1;
 	}
 	return 0;
@@ -122,7 +122,7 @@ int sctp_rcv(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
 
-	SCTP_INC_STATS_BH(net, SCTP_MIB_INSCTPPACKS);
+	__SCTP_INC_STATS(net, SCTP_MIB_INSCTPPACKS);
 
 	if (skb_linearize(skb))
 		goto discard_it;
@@ -208,7 +208,7 @@ int sctp_rcv(struct sk_buff *skb)
 	 */
 	if (!asoc) {
 		if (sctp_rcv_ootb(skb)) {
-			SCTP_INC_STATS_BH(net, SCTP_MIB_OUTOFBLUES);
+			__SCTP_INC_STATS(net, SCTP_MIB_OUTOFBLUES);
 			goto discard_release;
 		}
 	}
@@ -264,9 +264,9 @@ int sctp_rcv(struct sk_buff *skb)
 			skb = NULL; /* sctp_chunk_free already freed the skb */
 			goto discard_release;
 		}
-		SCTP_INC_STATS_BH(net, SCTP_MIB_IN_PKT_BACKLOG);
+		__SCTP_INC_STATS(net, SCTP_MIB_IN_PKT_BACKLOG);
 	} else {
-		SCTP_INC_STATS_BH(net, SCTP_MIB_IN_PKT_SOFTIRQ);
+		__SCTP_INC_STATS(net, SCTP_MIB_IN_PKT_SOFTIRQ);
 		sctp_inq_push(&chunk->rcvr->inqueue, chunk);
 	}
 
@@ -281,7 +281,7 @@ int sctp_rcv(struct sk_buff *skb)
 	return 0;
 
 discard_it:
-	SCTP_INC_STATS_BH(net, SCTP_MIB_IN_PKT_DISCARDS);
+	__SCTP_INC_STATS(net, SCTP_MIB_IN_PKT_DISCARDS);
 	kfree_skb(skb);
 	return 0;
 
-- 
2.8.0.rc3.226.g39d4020
