From: Vitaly Andrianov <vitalya@ti.com>
Subject: [PATCH] sctp: Add counters for out data chunk discards
Date: Mon, 6 Jul 2015 13:37:25 -0400
Message-ID: <1436204245-21645-1-git-send-email-vitalya@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vitaly Andrianov <vitalya@ti.com>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>, <linux-sctp@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds a MIB entry for out data chunk discards.
Number of outgoing SCTP DATA chunks for a SCTP association for which no
problems were encountered to prevent their transmission but were discarded.
Data chunks are discarded due to ungraceful closing of the SCTP
association.

Signed-off-by: Vitaly Andrianov <vitalya@ti.com>
---
 include/net/sctp/sctp.h | 1 +
 net/sctp/outqueue.c     | 1 +
 net/sctp/proc.c         | 2 ++
 3 files changed, 4 insertions(+)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ce13cf2..fd806ea 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -216,6 +216,7 @@ enum {
 	SCTP_MIB_IN_PKT_BACKLOG,
 	SCTP_MIB_IN_PKT_DISCARDS,
 	SCTP_MIB_IN_DATA_CHUNK_DISCARDS,
+	SCTP_MIB_OUT_DATA_CHUNK_DISCARDS,
 	__SCTP_MIB_MAX
 };
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7e8f0a1..dc1a40f 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -315,6 +315,7 @@ int sctp_outq_tail(struct sctp_outq *q, struct sctp_chunk *chunk)
 		case SCTP_STATE_SHUTDOWN_RECEIVED:
 		case SCTP_STATE_SHUTDOWN_ACK_SENT:
 			/* Cannot send after transport endpoint shutdown */
+			SCTP_INC_STATS(net, SCTP_MIB_OUT_DATA_CHUNK_DISCARDS);
 			error = -ESHUTDOWN;
 			break;
 
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0697eda..1a10b81 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -67,6 +67,8 @@ static const struct snmp_mib sctp_snmp_list[] = {
 	SNMP_MIB_ITEM("SctpInPktBacklog", SCTP_MIB_IN_PKT_BACKLOG),
 	SNMP_MIB_ITEM("SctpInPktDiscards", SCTP_MIB_IN_PKT_DISCARDS),
 	SNMP_MIB_ITEM("SctpInDataChunkDiscards", SCTP_MIB_IN_DATA_CHUNK_DISCARDS),
+	SNMP_MIB_ITEM("SctpOutDataChunkDiscards",
+		      SCTP_MIB_OUT_DATA_CHUNK_DISCARDS),
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.9.1
