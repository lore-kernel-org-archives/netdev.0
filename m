From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 4/7] sctp: remove macros sctp_write_[un]_lock
Date: Tue, 21 Jan 2014 15:44:09 +0800
Message-ID: <1390290252-16080-5-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:23169 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaAUHtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:49:23 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined write_[un]lock to sctp_write_[un]lock for user space
friendly code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h |  2 --
 net/sctp/input.c        | 16 ++++++++--------
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 4f77e98..73dcc0c 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -171,8 +171,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  */
 
 /* spin lock wrappers. */
-#define sctp_write_lock(lock)   write_lock(lock)
-#define sctp_write_unlock(lock) write_unlock(lock)
 #define sctp_read_lock(lock)    read_lock(lock)
 #define sctp_read_unlock(lock)  read_unlock(lock)
 
diff --git a/net/sctp/input.c b/net/sctp/input.c
index e22b326..94f7f440 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -718,9 +718,9 @@ static void __sctp_hash_endpoint(struct sctp_endpoint *ep)
 	epb->hashent = sctp_ep_hashfn(net, epb->bind_addr.port);
 	head = &sctp_ep_hashtable[epb->hashent];
 
-	sctp_write_lock(&head->lock);
+	write_lock(&head->lock);
 	hlist_add_head(&epb->node, &head->chain);
-	sctp_write_unlock(&head->lock);
+	write_unlock(&head->lock);
 }
 
 /* Add an endpoint to the hash. Local BH-safe. */
@@ -744,9 +744,9 @@ static void __sctp_unhash_endpoint(struct sctp_endpoint *ep)
 
 	head = &sctp_ep_hashtable[epb->hashent];
 
-	sctp_write_lock(&head->lock);
+	write_lock(&head->lock);
 	hlist_del_init(&epb->node);
-	sctp_write_unlock(&head->lock);
+	write_unlock(&head->lock);
 }
 
 /* Remove endpoint from the hash.  Local BH-safe. */
@@ -798,9 +798,9 @@ static void __sctp_hash_established(struct sctp_association *asoc)
 
 	head = &sctp_assoc_hashtable[epb->hashent];
 
-	sctp_write_lock(&head->lock);
+	write_lock(&head->lock);
 	hlist_add_head(&epb->node, &head->chain);
-	sctp_write_unlock(&head->lock);
+	write_unlock(&head->lock);
 }
 
 /* Add an association to the hash. Local BH-safe. */
@@ -828,9 +828,9 @@ static void __sctp_unhash_established(struct sctp_association *asoc)
 
 	head = &sctp_assoc_hashtable[epb->hashent];
 
-	sctp_write_lock(&head->lock);
+	write_lock(&head->lock);
 	hlist_del_init(&epb->node);
-	sctp_write_unlock(&head->lock);
+	write_unlock(&head->lock);
 }
 
 /* Remove association from the hash table.  Local BH-safe. */
-- 
1.7.12
