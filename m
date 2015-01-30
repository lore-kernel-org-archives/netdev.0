From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/6] rhashtable: Wait for RCU readers after final unzip work
Date: Fri, 30 Jan 2015 01:20:40 +0100
Message-ID: <0e0f3cbeea3fbec2810e2d8955c1d83b5a695122.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:53212 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758835AbbA3AUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 19:20:53 -0500
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
In-Reply-To: <cover.1422576760.git.tgraf@suug.ch>
References: <cover.1422576760.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to wait for all RCU readers to complete after the last bit of
unzipping has been completed. Otherwise the old table is freed up
prematurely.

Fixes: 7e1e77636e36 ("lib: Resizable, Scalable, Concurrent Hash Table")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/rhashtable.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 17eeabc..85ec36b 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -391,6 +391,8 @@ int rhashtable_expand(struct rhashtable *ht)
 		}
 	}
 
+	synchronize_rcu();
+
 	bucket_table_free(old_tbl);
 	return 0;
 }
-- 
1.9.3
