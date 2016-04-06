From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 1/2] sctp: compress bit-wide flags to a bitfield on sctp_sock
Date: Wed,  6 Apr 2016 14:53:12 -0300
Message-ID: <69a5ce012d9978ce73aade0004c5937964c54d61.1459952558.git.marcelo.leitner@gmail.com>
References: <cover.1459952558.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43715 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbcDFRxb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 13:53:31 -0400
In-Reply-To: <cover.1459952558.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It wastes space and gets worse as we add new flags, so convert bit-wide
flags to a bitfield.

Currently it already saves 4 bytes in sctp_sock, which are left as holes
in it for now. The whole struct needs packing, which should be done in
another patch.

Note that do_auto_asconf cannot be merged, as explained in the comment
before it.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/structs.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 6df1ce7a411c548bda4163840a90578b6e1b4cfe..1a6a626904bba4223b7921bbb4be41c2550271a7 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -210,14 +210,14 @@ struct sctp_sock {
 	int user_frag;
 
 	__u32 autoclose;
-	__u8 nodelay;
-	__u8 disable_fragments;
-	__u8 v4mapped;
-	__u8 frag_interleave;
 	__u32 adaptation_ind;
 	__u32 pd_point;
-	__u8 recvrcvinfo;
-	__u8 recvnxtinfo;
+	__u16	nodelay:1,
+		disable_fragments:1,
+		v4mapped:1,
+		frag_interleave:1,
+		recvrcvinfo:1,
+		recvnxtinfo:1;
 
 	atomic_t pd_mode;
 	/* Receive to here while partial delivery is in effect. */
-- 
2.5.0
