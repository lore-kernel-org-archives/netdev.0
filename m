From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 6/9] net: sctp: sctp_transport: remove unused variable
Date: Tue, 16 Apr 2013 23:07:15 +0200
Message-ID: <1366146438-8815-7-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965377Ab3DPVHh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:37 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_transport's member 'malloced' is set to 1, never evaluated
and the structure is kfreed anyway. So just remove it.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h | 5 +----
 net/sctp/transport.c       | 1 -
 2 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 3de5985..945e952 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -779,10 +779,7 @@ struct sctp_transport {
 		hb_sent:1,
 
 		/* Is the Path MTU update pending on this tranport */
-		pmtu_pending:1,
-
-		/* Is this structure kfree()able? */
-		malloced:1;
+		pmtu_pending:1;
 
 	/* Has this transport moved the ctsn since we last sacked */
 	__u32 sack_generation;
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index fafd2a4..098f1d5f 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -123,7 +123,6 @@ struct sctp_transport *sctp_transport_new(struct net *net,
 	if (!sctp_transport_init(net, transport, addr, gfp))
 		goto fail_init;
 
-	transport->malloced = 1;
 	SCTP_DBG_OBJCNT_INC(transport);
 
 	return transport;
-- 
1.7.11.7
