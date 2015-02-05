From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/6] rhashtable: Wait for RCU readers after final unzip work
Date: Thu,  5 Feb 2015 02:03:33 +0100
Message-ID: <57434f22bee01ecfec77d3ce318c6b2ee0dea542.1423097592.git.tgraf@suug.ch>
References: <cover.1423097592.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:41058 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756238AbbBEBDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:03:45 -0500
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
In-Reply-To: <cover.1423097592.git.tgraf@suug.ch>
References: <cover.1423097592.git.tgraf@suug.ch>
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
index cea4244..fd1033d 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -392,6 +392,8 @@ int rhashtable_expand(struct rhashtable *ht)
 		}
 	}
 
+	synchronize_rcu();
+
 	bucket_table_free(old_tbl);
 	return 0;
 }
-- 
1.9.3
