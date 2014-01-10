From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] sctp: make sctp_addto_chunk_fixed local
Date: Thu, 9 Jan 2014 22:31:11 -0800
Message-ID: <20140109223111.71e55286@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:40561 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbaAJGbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 01:31:14 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so4318055pad.26
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 22:31:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 include/net/sctp/structs.h |    1 -
 net/sctp/sm_make_chunk.c   |    6 ++++--
 2 files changed, 4 insertions(+), 3 deletions(-)

--- a/include/net/sctp/structs.h	2014-01-09 22:29:51.871663405 -0800
+++ b/include/net/sctp/structs.h	2014-01-09 22:29:58.323581984 -0800
@@ -649,7 +649,6 @@ int sctp_user_addto_chunk(struct sctp_ch
 			  struct iovec *data);
 void sctp_chunk_free(struct sctp_chunk *);
 void  *sctp_addto_chunk(struct sctp_chunk *, int len, const void *data);
-void  *sctp_addto_chunk_fixed(struct sctp_chunk *, int len, const void *data);
 struct sctp_chunk *sctp_chunkify(struct sk_buff *,
 				 const struct sctp_association *,
 				 struct sock *);
--- a/net/sctp/sm_make_chunk.c	2014-01-09 22:29:51.871663405 -0800
+++ b/net/sctp/sm_make_chunk.c	2014-01-09 22:29:58.323581984 -0800
@@ -78,6 +78,8 @@ static int sctp_process_param(struct sct
 			      gfp_t gfp);
 static void *sctp_addto_param(struct sctp_chunk *chunk, int len,
 			      const void *data);
+static void  *sctp_addto_chunk_fixed(struct sctp_chunk *, int len,
+				     const void *data);
 
 /* Control chunk destructor */
 static void sctp_control_release_owner(struct sk_buff *skb)
@@ -1475,8 +1477,8 @@ void *sctp_addto_chunk(struct sctp_chunk
 /* Append bytes to the end of a chunk. Returns NULL if there isn't sufficient
  * space in the chunk
  */
-void *sctp_addto_chunk_fixed(struct sctp_chunk *chunk,
-			     int len, const void *data)
+static void *sctp_addto_chunk_fixed(struct sctp_chunk *chunk,
+				    int len, const void *data)
 {
 	if (skb_tailroom(chunk->skb) >= len)
 		return sctp_addto_chunk(chunk, len, data);
