From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 02/14] sctp: remove the typedef sctp_retransmit_reason_t
Date: Sat,  5 Aug 2017 19:59:52 +0800
Message-ID: <7ceee2b1bf33403b8ecb04c9c30354f71dd2198a.1501934087.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
 <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33896 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751356AbdHEMA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 08:00:29 -0400
In-Reply-To: <88e505f76dd927887d8cdcc7de2b82595237aa85.1501934087.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501934086.git.lucien.xin@gmail.com>
References: <cover.1501934086.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_retransmit_reason_t, and
replace with enum sctp_retransmit_reason in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/constants.h | 4 ++--
 include/net/sctp/structs.h   | 4 ++--
 net/sctp/outqueue.c          | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 761064e..922fba5 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -370,12 +370,12 @@ typedef enum {
 						   peer */
 
 /* Reasons to retransmit. */
-typedef enum {
+enum sctp_retransmit_reason {
 	SCTP_RTXR_T3_RTX,
 	SCTP_RTXR_FAST_RTX,
 	SCTP_RTXR_PMTUD,
 	SCTP_RTXR_T1_RTX,
-} sctp_retransmit_reason_t;
+};
 
 /* Reasons to lower cwnd. */
 enum sctp_lower_cwnd {
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 53802d8..5e872ac 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1054,8 +1054,8 @@ int sctp_outq_sack(struct sctp_outq *, struct sctp_chunk *);
 int sctp_outq_is_empty(const struct sctp_outq *);
 void sctp_outq_restart(struct sctp_outq *);
 
-void sctp_retransmit(struct sctp_outq *, struct sctp_transport *,
-		     sctp_retransmit_reason_t);
+void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
+		     enum sctp_retransmit_reason reason);
 void sctp_retransmit_mark(struct sctp_outq *, struct sctp_transport *, __u8);
 void sctp_outq_uncork(struct sctp_outq *, gfp_t gfp);
 void sctp_prsctp_prune(struct sctp_association *asoc,
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index d2a8adf..08ee0ed 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -534,7 +534,7 @@ void sctp_retransmit_mark(struct sctp_outq *q,
  * one packet out.
  */
 void sctp_retransmit(struct sctp_outq *q, struct sctp_transport *transport,
-		     sctp_retransmit_reason_t reason)
+		     enum sctp_retransmit_reason reason)
 {
 	struct net *net = sock_net(q->asoc->base.sk);
 
-- 
2.1.0
