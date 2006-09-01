From: Kirill Korotaev <dev@openvz.org>
Subject: [PATCH] neigh_table_clear() doesn't free stats
Date: Fri, 01 Sep 2006 12:28:56 +0400
Message-ID: <44F7EF48.6090608@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:56443 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751271AbWIAI0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 04:26:02 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, devel@openvz.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

neigh_table_clear() doesn't free tbl->stats.
Found by Alexey Kuznetsov. Though Alexey considers this
leak minor for mainstream, I still believe that cleanup
code should not forget to free some of the resources :)

At least, this is critical for OpenVZ with virtualized
neighbour tables.

Signed-Off-By: Kirill Korotaev <dev@openvz.org>


diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 89b7904..a45bd21 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1429,6 +1429,9 @@ int neigh_table_clear(struct neigh_table
 	kfree(tbl->phash_buckets);
 	tbl->phash_buckets = NULL;
 
+	free_percpu(tbl->stats);
+	tbl->stats = NULL;
+
 	return 0;
 }
 
