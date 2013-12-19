From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 3/5] sctp: fix checkpatch errors with indent
Date: Thu, 19 Dec 2013 14:52:00 +0800
Message-ID: <1387435922-24152-4-git-send-email-wangweidong1@huawei.com>
References: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: <davem@davemloft.net>, <vyasevich@gmail.com>,
	<nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22013 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab3LSGwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 01:52:37 -0500
In-Reply-To: <1387435922-24152-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix checkpatch errors below:
ERROR: switch and case should be at the same inden
ERROR: code indent should use tabs where possible

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/auth.c          | 12 ++++-----
 net/sctp/input.c         | 48 +++++++++++++++++------------------
 net/sctp/output.c        | 11 ++++----
 net/sctp/sm_make_chunk.c | 65 ++++++++++++++++++++++++------------------------
 net/sctp/sm_statefuns.c  |  5 ++--
 net/sctp/sm_statetable.c |  2 +-
 6 files changed, 70 insertions(+), 73 deletions(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 889400b..a594b3c 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -647,15 +647,15 @@ static int __sctp_auth_cid(sctp_cid_t chunk, struct sctp_chunks_param *param)
 	 */
 	for (i = 0; !found && i < len; i++) {
 		switch (param->chunks[i]) {
-		    case SCTP_CID_INIT:
-		    case SCTP_CID_INIT_ACK:
-		    case SCTP_CID_SHUTDOWN_COMPLETE:
-		    case SCTP_CID_AUTH:
+		case SCTP_CID_INIT:
+		case SCTP_CID_INIT_ACK:
+		case SCTP_CID_SHUTDOWN_COMPLETE:
+		case SCTP_CID_AUTH:
 			break;
 
-		    default:
+		default:
 			if (param->chunks[i] == chunk)
-			    found = 1;
+				found = 1;
 			break;
 		}
 	}
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 726a474..49aef00 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -1059,30 +1059,30 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 			break;
 
 		switch (ch->type) {
-		    case SCTP_CID_AUTH:
-			    have_auth = chunk_num;
-			    break;
-
-		    case SCTP_CID_COOKIE_ECHO:
-			    /* If a packet arrives containing an AUTH chunk as
-			     * a first chunk, a COOKIE-ECHO chunk as the second
-			     * chunk, and possibly more chunks after them, and
-			     * the receiver does not have an STCB for that
-			     * packet, then authentication is based on
-			     * the contents of the COOKIE- ECHO chunk.
-			     */
-			    if (have_auth == 1 && chunk_num == 2)
-				    return NULL;
-			    break;
-
-		    case SCTP_CID_ASCONF:
-			    if (have_auth || net->sctp.addip_noauth)
-				    asoc = __sctp_rcv_asconf_lookup(
-							net, ch, laddr,
-							sctp_hdr(skb)->source,
-							transportp);
-		    default:
-			    break;
+		case SCTP_CID_AUTH:
+			have_auth = chunk_num;
+			break;
+
+		case SCTP_CID_COOKIE_ECHO:
+			/* If a packet arrives containing an AUTH chunk as
+			 * a first chunk, a COOKIE-ECHO chunk as the second
+			 * chunk, and possibly more chunks after them, and
+			 * the receiver does not have an STCB for that
+			 * packet, then authentication is based on
+			 * the contents of the COOKIE- ECHO chunk.
+			 */
+			if (have_auth == 1 && chunk_num == 2)
+				return NULL;
+			break;
+
+		case SCTP_CID_ASCONF:
+			if (have_auth || net->sctp.addip_noauth)
+				asoc = __sctp_rcv_asconf_lookup(
+						net, ch, laddr,
+						sctp_hdr(skb)->source,
+						transportp);
+		default:
+			break;
 		}
 
 		if (asoc)
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 3f55823..49da402 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -280,7 +280,7 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 
 	/* We believe that this chunk is OK to add to the packet */
 	switch (chunk->chunk_hdr->type) {
-	    case SCTP_CID_DATA:
+	case SCTP_CID_DATA:
 		/* Account for the data being in the packet */
 		sctp_packet_append_data(packet, chunk);
 		/* Disallow SACK bundling after DATA. */
@@ -292,17 +292,17 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 		/* timestamp the chunk for rtx purposes */
 		chunk->sent_at = jiffies;
 		break;
-	    case SCTP_CID_COOKIE_ECHO:
+	case SCTP_CID_COOKIE_ECHO:
 		packet->has_cookie_echo = 1;
 		break;
 
-	    case SCTP_CID_SACK:
+	case SCTP_CID_SACK:
 		packet->has_sack = 1;
 		if (chunk->asoc)
 			chunk->asoc->stats.osacks++;
 		break;
 
-	    case SCTP_CID_AUTH:
+	case SCTP_CID_AUTH:
 		packet->has_auth = 1;
 		packet->auth = chunk;
 		break;
@@ -540,8 +540,7 @@ int sctp_packet_transmit(struct sctp_packet *packet)
 		} else {
 			/* no need to seed pseudo checksum for SCTP */
 			nskb->ip_summed = CHECKSUM_PARTIAL;
-			nskb->csum_start = (skb_transport_header(nskb) -
-			                    nskb->head);
+			nskb->csum_start = skb_transport_header(nskb) - nskb->head;
 			nskb->csum_offset = offsetof(struct sctphdr, checksum);
 		}
 	}
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index d53af47..e5f7cdb 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1967,13 +1967,13 @@ static int sctp_verify_ext_param(struct net *net, union sctp_params param)
 
 	for (i = 0; i < num_ext; i++) {
 		switch (param.ext->chunks[i]) {
-		    case SCTP_CID_AUTH:
-			    have_auth = 1;
-			    break;
-		    case SCTP_CID_ASCONF:
-		    case SCTP_CID_ASCONF_ACK:
-			    have_asconf = 1;
-			    break;
+		case SCTP_CID_AUTH:
+			have_auth = 1;
+			break;
+		case SCTP_CID_ASCONF:
+		case SCTP_CID_ASCONF_ACK:
+			have_asconf = 1;
+			break;
 		}
 	}
 
@@ -2000,25 +2000,24 @@ static void sctp_process_ext_param(struct sctp_association *asoc,
 
 	for (i = 0; i < num_ext; i++) {
 		switch (param.ext->chunks[i]) {
-		    case SCTP_CID_FWD_TSN:
-			    if (net->sctp.prsctp_enable &&
-				!asoc->peer.prsctp_capable)
+		case SCTP_CID_FWD_TSN:
+			if (net->sctp.prsctp_enable && !asoc->peer.prsctp_capable)
 				    asoc->peer.prsctp_capable = 1;
-			    break;
-		    case SCTP_CID_AUTH:
-			    /* if the peer reports AUTH, assume that he
-			     * supports AUTH.
-			     */
-			    if (net->sctp.auth_enable)
-				    asoc->peer.auth_capable = 1;
-			    break;
-		    case SCTP_CID_ASCONF:
-		    case SCTP_CID_ASCONF_ACK:
-			    if (net->sctp.addip_enable)
-				    asoc->peer.asconf_capable = 1;
-			    break;
-		    default:
-			    break;
+			break;
+		case SCTP_CID_AUTH:
+			/* if the peer reports AUTH, assume that he
+			 * supports AUTH.
+			 */
+			if (net->sctp.auth_enable)
+				asoc->peer.auth_capable = 1;
+			break;
+		case SCTP_CID_ASCONF:
+		case SCTP_CID_ASCONF_ACK:
+			if (net->sctp.addip_enable)
+				asoc->peer.asconf_capable = 1;
+			break;
+		default:
+			break;
 		}
 	}
 }
@@ -2266,14 +2265,14 @@ int sctp_verify_init(struct net *net, const struct sctp_association *asoc,
 
 		result = sctp_verify_param(net, asoc, param, cid, chunk, errp);
 		switch (result) {
-		    case SCTP_IERROR_ABORT:
-		    case SCTP_IERROR_NOMEM:
-				return 0;
-		    case SCTP_IERROR_ERROR:
-				return 1;
-		    case SCTP_IERROR_NO_ERROR:
-		    default:
-				break;
+		case SCTP_IERROR_ABORT:
+		case SCTP_IERROR_NOMEM:
+			return 0;
+		case SCTP_IERROR_ERROR:
+			return 1;
+		case SCTP_IERROR_NO_ERROR:
+		default:
+			break;
 		}
 
 	} /* for (loop through all parameters) */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 624e4ef..483dcd7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3681,8 +3681,7 @@ sctp_disposition_t sctp_sf_do_asconf(struct net *net,
 	asconf_ack->dest = chunk->source;
 	sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(asconf_ack));
 	if (asoc->new_transport) {
-	        sctp_sf_heartbeat(ep, asoc, type, asoc->new_transport,
-                    commands);
+		sctp_sf_heartbeat(ep, asoc, type, asoc->new_transport, commands);
 		((struct sctp_association *)asoc)->new_transport = NULL;
 	}
 
@@ -6207,7 +6206,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 */
 	if (*sk->sk_prot_creator->memory_pressure) {
 		if (sctp_tsnmap_has_gap(map) &&
-	           (sctp_tsnmap_get_ctsn(map) + 1) == tsn) {
+		    (sctp_tsnmap_get_ctsn(map) + 1) == tsn) {
 			pr_debug("%s: under pressure, reneging for tsn:%u\n",
 				 __func__, tsn);
 			deliver = SCTP_CMD_RENEGE;
diff --git a/net/sctp/sm_statetable.c b/net/sctp/sm_statetable.c
index a4f1743..a987d54 100644
--- a/net/sctp/sm_statetable.c
+++ b/net/sctp/sm_statetable.c
@@ -69,7 +69,7 @@ static const sctp_sm_table_entry_t bug = {
 	if ((event_subtype._type > (_max))) {				\
 		pr_warn("table %p possible attack: event %d exceeds max %d\n", \
 			_table, event_subtype._type, _max);		\
-	        rtn = &bug;						\
+		rtn = &bug;						\
 	} else								\
 		rtn = &_table[event_subtype._type][(int)state];		\
 									\
-- 
1.7.12
