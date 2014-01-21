From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 1/7] sctp: remove macros sctp_spin_[un]lock_irqrestore
Date: Tue, 21 Jan 2014 15:44:06 +0800
Message-ID: <1390290252-16080-2-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:29299 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbaAUHul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:50:41 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined spin_[un]lock_irqstore to sctp_spin_[un]lock_irqrestore for user
space friendly code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 610a8c8..b180a8f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -171,9 +171,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  */
 
 /* spin lock wrappers. */
-#define sctp_spin_lock_irqsave(lock, flags) spin_lock_irqsave(lock, flags)
-#define sctp_spin_unlock_irqrestore(lock, flags)  \
-       spin_unlock_irqrestore(lock, flags)
 #define sctp_local_bh_disable() local_bh_disable()
 #define sctp_local_bh_enable()  local_bh_enable()
 #define sctp_spin_lock(lock)    spin_lock(lock)
@@ -353,13 +350,13 @@ static inline void sctp_skb_list_tail(struct sk_buff_head *list,
 {
 	unsigned long flags;
 
-	sctp_spin_lock_irqsave(&head->lock, flags);
+	spin_lock_irqsave(&head->lock, flags);
 	sctp_spin_lock(&list->lock);
 
 	skb_queue_splice_tail_init(list, head);
 
 	sctp_spin_unlock(&list->lock);
-	sctp_spin_unlock_irqrestore(&head->lock, flags);
+	spin_unlock_irqrestore(&head->lock, flags);
 }
 
 /**
-- 
1.7.12
