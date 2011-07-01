From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/12] sctp: Reduce switch/case indent
Date: Fri,  1 Jul 2011 12:43:11 -0700
Message-ID: <4f9993c78618082b8ac4e1d9c55d6c1e23c7bd6b.1309549244.git.joe@perches.com>
References: <cover.1309549243.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309549243.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the case labels the same indent as the switch.

git diff -w shows useless break;s removed after returns
and a comment added to an unnecessary default: break;
because of a dubious gcc warning.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sctp/sm_statefuns.c |   51 ++++++++++++++++++++++++-----------------------
 net/sctp/socket.c       |   10 ++++----
 2 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index a297283..7d00b17 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -4008,31 +4008,32 @@ sctp_disposition_t sctp_sf_eat_auth(const struct sctp_endpoint *ep,
 	auth_hdr = (struct sctp_authhdr *)chunk->skb->data;
 	error = sctp_sf_authenticate(ep, asoc, type, chunk);
 	switch (error) {
-		case SCTP_IERROR_AUTH_BAD_HMAC:
-			/* Generate the ERROR chunk and discard the rest
-			 * of the packet
-			 */
-			err_chunk = sctp_make_op_error(asoc, chunk,
-							SCTP_ERROR_UNSUP_HMAC,
-							&auth_hdr->hmac_id,
-							sizeof(__u16), 0);
-			if (err_chunk) {
-				sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
-						SCTP_CHUNK(err_chunk));
-			}
-			/* Fall Through */
-		case SCTP_IERROR_AUTH_BAD_KEYID:
-		case SCTP_IERROR_BAD_SIG:
-			return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
-			break;
-		case SCTP_IERROR_PROTO_VIOLATION:
-			return sctp_sf_violation_chunklen(ep, asoc, type, arg,
-							  commands);
-			break;
-		case SCTP_IERROR_NOMEM:
-			return SCTP_DISPOSITION_NOMEM;
-		default:
-			break;
+	case SCTP_IERROR_AUTH_BAD_HMAC:
+		/* Generate the ERROR chunk and discard the rest
+		 * of the packet
+		 */
+		err_chunk = sctp_make_op_error(asoc, chunk,
+					       SCTP_ERROR_UNSUP_HMAC,
+					       &auth_hdr->hmac_id,
+					       sizeof(__u16), 0);
+		if (err_chunk) {
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(err_chunk));
+		}
+		/* Fall Through */
+	case SCTP_IERROR_AUTH_BAD_KEYID:
+	case SCTP_IERROR_BAD_SIG:
+		return sctp_sf_pdiscard(ep, asoc, type, arg, commands);
+
+	case SCTP_IERROR_PROTO_VIOLATION:
+		return sctp_sf_violation_chunklen(ep, asoc, type, arg,
+						  commands);
+
+	case SCTP_IERROR_NOMEM:
+		return SCTP_DISPOSITION_NOMEM;
+
+	default:			/* Prevent gcc warnings */
+		break;
 	}
 
 	if (asoc->active_key_id != ntohs(auth_hdr->shkey_id)) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fd31b36..1c6aec1 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3257,11 +3257,11 @@ static int sctp_setsockopt_auth_chunk(struct sock *sk,
 		return -EFAULT;
 
 	switch (val.sauth_chunk) {
-		case SCTP_CID_INIT:
-		case SCTP_CID_INIT_ACK:
-		case SCTP_CID_SHUTDOWN_COMPLETE:
-		case SCTP_CID_AUTH:
-			return -EINVAL;
+	case SCTP_CID_INIT:
+	case SCTP_CID_INIT_ACK:
+	case SCTP_CID_SHUTDOWN_COMPLETE:
+	case SCTP_CID_AUTH:
+		return -EINVAL;
 	}
 
 	/* add this chunk id to the endpoint */
-- 
1.7.6.rc1
