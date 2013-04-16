From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/9] net: sctp: sctp_outq: consolidate chars into bitfield
Date: Tue, 16 Apr 2013 23:07:13 +0200
Message-ID: <1366146438-8815-5-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40825 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965351Ab3DPVHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:31 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_outq structure members fast_rtx, cork and empty are all
of type char. Consolidate them into a single __u8 bitfield since
they either carry 0 or 1. Have the rest 5 bits for future flags.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 73fd5de..3de5985 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1051,14 +1051,9 @@ struct sctp_outq {
 	/* How many unackd bytes do we have in-flight?	*/
 	__u32 outstanding_bytes;
 
-	/* Are we doing fast-rtx on this queue */
-	char fast_rtx;
-
-	/* Corked? */
-	char cork;
-
-	/* Is this structure empty?  */
-	char empty;
+	__u8 fast_rtx:1,	/* Are we doing fast-rtx on this queue */
+	     cork:1,		/* Corked? */
+	     empty:1;		/* Is this structure empty?  */
 };
 
 void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
-- 
1.7.11.7
