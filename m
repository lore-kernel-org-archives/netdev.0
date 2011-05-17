From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-2.6] net: use hlist_del_rcu() in dev_change_name()
Date: Tue, 17 May 2011 18:21:00 +0200
Message-ID: <1305649260.2850.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34274 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755643Ab1EQQVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 12:21:04 -0400
Received: by wwa36 with SMTP id 36so739162wwa.1
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 09:21:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using plain hlist_del() in dev_change_name() is wrong since a
concurrent reader can crash trying to dereference LIST_POISON1.

Bug introduced in commit 72c9528bab94 (net: Introduce
dev_get_by_name_rcu())

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Stable candidate, for 2.6.33+

 net/core/dev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b624fe4..30a4078 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1007,7 +1007,7 @@ rollback:
 	}
 
 	write_lock_bh(&dev_base_lock);
-	hlist_del(&dev->name_hlist);
+	hlist_del_rcu(&dev->name_hlist);
 	write_unlock_bh(&dev_base_lock);
 
 	synchronize_rcu();


