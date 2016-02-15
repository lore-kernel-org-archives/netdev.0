From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 3/3] sctp: remove the unused sctp_datamsg_free()
Date: Mon, 15 Feb 2016 14:28:05 +0800
Message-ID: <7ded1964e2535be98181989b498a839e2f807fcf.1455517541.git.lucien.xin@gmail.com>
References: <cover.1455517541.git.lucien.xin@gmail.com>
 <c805e4a1994f53947351e8d4dd79609fd206e807.1455517541.git.lucien.xin@gmail.com>
 <4e75be65afef4ccacca08e83316a8fbe811d5b1f.1455517541.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34387 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbcBOG2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 01:28:23 -0500
In-Reply-To: <4e75be65afef4ccacca08e83316a8fbe811d5b1f.1455517541.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1455517541.git.lucien.xin@gmail.com>
References: <cover.1455517541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 8b570dc9f7b6 ("sctp: only drop the reference on the datamsg
after sending a msg") used sctp_datamsg_put in sctp_sendmsg, instead of
sctp_datamsg_free, this function has no use in sctp.

So we will remove it.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  1 -
 net/sctp/chunk.c           | 13 -------------
 2 files changed, 14 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 205630b..d05b566 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -535,7 +535,6 @@ struct sctp_datamsg {
 struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *,
 					    struct sctp_sndrcvinfo *,
 					    struct iov_iter *);
-void sctp_datamsg_free(struct sctp_datamsg *);
 void sctp_datamsg_put(struct sctp_datamsg *);
 void sctp_chunk_fail(struct sctp_chunk *, int error);
 int sctp_chunk_abandoned(struct sctp_chunk *);
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a338091..3aa4307 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -70,19 +70,6 @@ static struct sctp_datamsg *sctp_datamsg_new(gfp_t gfp)
 	return msg;
 }
 
-void sctp_datamsg_free(struct sctp_datamsg *msg)
-{
-	struct sctp_chunk *chunk;
-
-	/* This doesn't have to be a _safe vairant because
-	 * sctp_chunk_free() only drops the refs.
-	 */
-	list_for_each_entry(chunk, &msg->chunks, frag_list)
-		sctp_chunk_free(chunk);
-
-	sctp_datamsg_put(msg);
-}
-
 /* Final destructruction of datamsg memory. */
 static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 {
-- 
2.1.0
