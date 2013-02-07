From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 2/2] net: sctp: sctp_auth_key_put: use kzfree instead of kfree
Date: Thu,  7 Feb 2013 11:55:37 +0100
Message-ID: <8c764d916f21d56402a5b9a915ea31d927898da0.1360231701.git.dborkman@redhat.com>
References: <cover.1360231701.git.dborkman@redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758089Ab3BGKzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2013 05:55:43 -0500
In-Reply-To: <cover.1360231701.git.dborkman@redhat.com>
In-Reply-To: <cover.1360231701.git.dborkman@redhat.com>
References: <cover.1360231701.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For sensitive data like keying material, it is common practice to zero
out keys before returning the memory back to the allocator. Thus, use
kzfree instead of kfree.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/auth.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 55f1b06..69fcd6d 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -71,7 +71,7 @@ void sctp_auth_key_put(struct sctp_auth_bytes *key)
 		return;
 
 	if (atomic_dec_and_test(&key->refcnt)) {
-		kfree(key);
+		kzfree(key);
 		SCTP_DBG_OBJCNT_DEC(keys);
 	}
 }
-- 
1.7.11.7
