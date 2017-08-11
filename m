From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 07/14] sctp: remove the typedef sctp_cmd_t
Date: Fri, 11 Aug 2017 10:23:51 +0800
Message-ID: <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34285 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752358AbdHKCZB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:01 -0400
In-Reply-To: <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cmd_t, and
replace with enum sctp_cmd in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h | 14 +++++++-------
 net/sctp/sm_sideeffect.c   |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index 376cb78..4e9e589 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -196,15 +196,15 @@ static inline sctp_arg_t SCTP_NULL(void)
 	return retval;
 }
 
-typedef struct {
+struct sctp_cmd {
 	sctp_arg_t obj;
 	sctp_verb_t verb;
-} sctp_cmd_t;
+};
 
 typedef struct {
-	sctp_cmd_t cmds[SCTP_MAX_NUM_COMMANDS];
-	sctp_cmd_t *last_used_slot;
-	sctp_cmd_t *next_cmd;
+	struct sctp_cmd cmds[SCTP_MAX_NUM_COMMANDS];
+	struct sctp_cmd *last_used_slot;
+	struct sctp_cmd *next_cmd;
 } sctp_cmd_seq_t;
 
 
@@ -228,7 +228,7 @@ static inline int sctp_init_cmd_seq(sctp_cmd_seq_t *seq)
 static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
 				   sctp_arg_t obj)
 {
-	sctp_cmd_t *cmd = seq->last_used_slot - 1;
+	struct sctp_cmd *cmd = seq->last_used_slot - 1;
 
 	BUG_ON(cmd < seq->cmds);
 
@@ -240,7 +240,7 @@ static inline void sctp_add_cmd_sf(sctp_cmd_seq_t *seq, sctp_verb_t verb,
 /* Return the next command structure in an sctp_cmd_seq.
  * Return NULL at the end of the sequence.
  */
-static inline sctp_cmd_t *sctp_next_cmd(sctp_cmd_seq_t *seq)
+static inline struct sctp_cmd *sctp_next_cmd(sctp_cmd_seq_t *seq)
 {
 	if (seq->next_cmd <= seq->last_used_slot)
 		return NULL;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 5e8e418..0cb3d5a 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1277,7 +1277,7 @@ static int sctp_cmd_interpreter(enum sctp_event event_type,
 	struct sctp_sock *sp = sctp_sk(sk);
 	int error = 0;
 	int force;
-	sctp_cmd_t *cmd;
+	struct sctp_cmd *cmd;
 	struct sctp_chunk *new_obj;
 	struct sctp_chunk *chunk = NULL;
 	struct sctp_packet *packet;
-- 
2.1.0
