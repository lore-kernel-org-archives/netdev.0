From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] tipc: avoid double lock 'spin_lock:&seq->lock'
Date: Tue, 9 Dec 2014 15:17:56 +0800
Message-ID: <1418109476-2006-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <dan.carpenter@oracle.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39964 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751645AbaLIHSW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 02:18:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit fb9962f3cefe ("tipc: ensure all name sequences are properly
protected with its lock") involves below errors:

net/tipc/name_table.c:980 tipc_purge_publications() error: double lock 'spin_lock:&seq->lock'

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/name_table.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index aafa684c..c8df022 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -979,7 +979,7 @@ static void tipc_purge_publications(struct name_seq *seq)
 	}
 	hlist_del_init_rcu(&seq->ns_list);
 	kfree(seq->sseqs);
-	spin_lock_bh(&seq->lock);
+	spin_unlock_bh(&seq->lock);
 
 	kfree_rcu(seq, rcu);
 }
-- 
1.7.9.5
