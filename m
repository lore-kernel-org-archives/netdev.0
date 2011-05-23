From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/5] netlabel: Remove prefetches from list handlers.
Date: Sun, 22 May 2011 20:57:37 -0400 (EDT)
Message-ID: <20110522.205737.917738676784529169.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab1EWA5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:57:38 -0400
Received: from localhost (cpe-66-108-115-211.nyc.res.rr.com [66.108.115.211])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4N0vbGH005544
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Sun, 22 May 2011 17:57:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/netlabel/netlabel_addrlist.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netlabel/netlabel_addrlist.h b/net/netlabel/netlabel_addrlist.h
index 1c1c093..2b9644e 100644
--- a/net/netlabel/netlabel_addrlist.h
+++ b/net/netlabel/netlabel_addrlist.h
@@ -96,12 +96,12 @@ static inline struct netlbl_af4list *__af4list_valid_rcu(struct list_head *s,
 
 #define netlbl_af4list_foreach(iter, head)				\
 	for (iter = __af4list_valid((head)->next, head);		\
-	     prefetch(iter->list.next), &iter->list != (head);		\
+	     &iter->list != (head);					\
 	     iter = __af4list_valid(iter->list.next, head))
 
 #define netlbl_af4list_foreach_rcu(iter, head)				\
 	for (iter = __af4list_valid_rcu((head)->next, head);		\
-	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     &iter->list != (head);					\
 	     iter = __af4list_valid_rcu(iter->list.next, head))
 
 #define netlbl_af4list_foreach_safe(iter, tmp, head)			\
@@ -163,12 +163,12 @@ static inline struct netlbl_af6list *__af6list_valid_rcu(struct list_head *s,
 
 #define netlbl_af6list_foreach(iter, head)				\
 	for (iter = __af6list_valid((head)->next, head);		\
-	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     &iter->list != (head);					\
 	     iter = __af6list_valid(iter->list.next, head))
 
 #define netlbl_af6list_foreach_rcu(iter, head)				\
 	for (iter = __af6list_valid_rcu((head)->next, head);		\
-	     prefetch(iter->list.next),	&iter->list != (head);		\
+	     &iter->list != (head);					\
 	     iter = __af6list_valid_rcu(iter->list.next, head))
 
 #define netlbl_af6list_foreach_safe(iter, tmp, head)			\
-- 
1.7.4.4

