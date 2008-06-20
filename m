From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: [PATCH] Prevent from potential dead lock for inet_listen_lock
Date: Fri, 20 Jun 2008 17:08:20 +0800
Message-ID: <485B7384.1090204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62629 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbYFTJK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2008 05:10:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hashinfo->lhash_lock might be acquired by write_lock() in softirq, 
so using read_lock() here isn't safe, just substitudes by read_lock_bh().

Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
---
 include/net/inet_hashtables.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
index 97dc35a..2818c8a 100644
--- a/include/net/inet_hashtables.h
+++ b/include/net/inet_hashtables.h
@@ -254,9 +254,9 @@ extern void inet_listen_wlock(struct inet_hashinfo *hashinfo);
 static inline void inet_listen_lock(struct inet_hashinfo *hashinfo)
 {
 	/* read_lock synchronizes to candidates to writers */
-	read_lock(&hashinfo->lhash_lock);
+	read_lock_bh(&hashinfo->lhash_lock);
 	atomic_inc(&hashinfo->lhash_users);
-	read_unlock(&hashinfo->lhash_lock);
+	read_unlock_bh(&hashinfo->lhash_lock);
 }
 
 static inline void inet_listen_unlock(struct inet_hashinfo *hashinfo)
-- 
1.5.3



