From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: fix an array overflow when all ext chunks are set
Date: Fri, 14 Jul 2017 22:07:33 +0800
Message-ID: <3e78f6040b834ee9221cd2ebf539324499a8bb4f.1500041253.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34692 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754191AbdGNOHn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 10:07:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcelo noticed an array overflow caused by commit c28445c3cb07
("sctp: add reconf_enable in asoc ep and netns"), in which sctp
would add SCTP_CID_RECONF into extensions when reconf_enable is
set in sctp_make_init and sctp_make_init_ack.

Then now when all ext chunks are set, 4 ext chunk ids can be put
into extensions array while extensions array size is 3. It would
cause a kernel panic because of this overflow.

This patch is to fix it by defining extensions array size is 4 in
both sctp_make_init and sctp_make_init_ack.

Fixes: c28445c3cb07 ("sctp: add reconf_enable in asoc ep and netns")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_make_chunk.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 4e16b02..6110447 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -228,7 +228,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	sctp_adaptation_ind_param_t aiparam;
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
-	__u8 extensions[3];
+	__u8 extensions[4];
 	struct sctp_paramhdr *auth_chunks = NULL,
 			*auth_hmacs = NULL;
 
@@ -396,7 +396,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	sctp_adaptation_ind_param_t aiparam;
 	sctp_supported_ext_param_t ext_param;
 	int num_ext = 0;
-	__u8 extensions[3];
+	__u8 extensions[4];
 	struct sctp_paramhdr *auth_chunks = NULL,
 			*auth_hmacs = NULL,
 			*auth_random = NULL;
-- 
2.1.0
