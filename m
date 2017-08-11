From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 10/14] sctp: remove the typedef sctp_verb_t
Date: Fri, 11 Aug 2017 10:23:54 +0800
Message-ID: <712be5d964dee4d7918781d7399ad564f2309259.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
 <e15322cc52e110730f2bcb77973222b687717369.1502417340.git.lucien.xin@gmail.com>
 <67dec3f4936413e5bf596dc0ce9be0b9aa15a444.1502417340.git.lucien.xin@gmail.com>
 <5031dc5f40135c4ede57452bc61a1b29dfc76d89.1502417340.git.lucien.xin@gmail.com>
 <58f1f86286c91cf55e9d6eb9395e59e9f1fd4519.1502417340.git.lucien.xin@gmail.com>
 <77692e0783b8134d97fd4c15e37cf0b6e4fa643e.1502417340.git.lucien.xin@gmail.com>
 <bec27150caf5435011467a5488247f853f782409.1502417340.git.lucien.xin@gmail.com>
 <d9ac131331781f85d2662c4c15692344260bb1b6.1502417340.git.lucien.xin@gmail.com>
 <d69e6a88f9cbdc68f0f3ef9c2afd89ccc64f955b.1502417340.git.lucien.xin@gmail.com>
 <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33931 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752430AbdHKCZZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 22:25:25 -0400
In-Reply-To: <8a912c943fa40c635ac0dba8726c7e744031a446.1502417340.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1502417340.git.lucien.xin@gmail.com>
References: <cover.1502417340.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_verb_t, and
replace with enum sctp_verb in the places where it's
using this typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/command.h | 10 +++++-----
 net/sctp/sm_statefuns.c    |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/command.h b/include/net/sctp/command.h
index f5fc425..b55c6a4 100644
--- a/include/net/sctp/command.h
+++ b/include/net/sctp/command.h
@@ -40,7 +40,7 @@
 #include <net/sctp/structs.h>
 
 
-typedef enum {
+enum sctp_verb {
 	SCTP_CMD_NOP = 0,	/* Do nothing. */
 	SCTP_CMD_NEW_ASOC,	/* Register a new association.  */
 	SCTP_CMD_DELETE_TCB,	/* Delete the current association. */
@@ -108,7 +108,7 @@ typedef enum {
 	SCTP_CMD_PURGE_ASCONF_QUEUE, /* Purge all asconf queues.*/
 	SCTP_CMD_SET_ASOC,	 /* Restore association context */
 	SCTP_CMD_LAST
-} sctp_verb_t;
+};
 
 /* How many commands can you put in an struct sctp_cmd_seq?
  * This is a rather arbitrary number, ideally derived from a careful
@@ -198,7 +198,7 @@ static inline union sctp_arg SCTP_NULL(void)
 
 struct sctp_cmd {
 	union sctp_arg obj;
-	sctp_verb_t verb;
+	enum sctp_verb verb;
 };
 
 struct sctp_cmd_seq {
@@ -225,8 +225,8 @@ static inline int sctp_init_cmd_seq(struct sctp_cmd_seq *seq)
  * Use the SCTP_* constructors defined by SCTP_ARG_CONSTRUCTOR() above
  * to wrap data which goes in the obj argument.
  */
-static inline void sctp_add_cmd_sf(struct sctp_cmd_seq *seq, sctp_verb_t verb,
-				   union sctp_arg obj)
+static inline void sctp_add_cmd_sf(struct sctp_cmd_seq *seq,
+				   enum sctp_verb verb, union sctp_arg obj)
 {
 	struct sctp_cmd *cmd = seq->last_used_slot - 1;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3394c4d..adc1dde 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6205,7 +6205,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	struct sctp_datahdr *data_hdr;
 	struct sctp_chunk *err;
 	size_t datalen;
-	sctp_verb_t deliver;
+	enum sctp_verb deliver;
 	int tmp;
 	__u32 tsn;
 	struct sctp_tsnmap *map = (struct sctp_tsnmap *)&asoc->peer.tsn_map;
-- 
2.1.0
