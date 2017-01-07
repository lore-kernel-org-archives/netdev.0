From: yuan linyu <cugyly@163.com>
Subject: [PATCH] net: change init_inodecache() return void
Date: Sat,  7 Jan 2017 17:18:31 +0800
Message-ID: <1483780711-5759-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:58522 "EHLO m12-16.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932214AbdAGJTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 7 Jan 2017 04:19:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

sock_init() call it but not check it's return value,
so change it to void return and add an internal BUG_ON() check.

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/socket.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index c65bb92..3ef02e9 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -287,7 +287,7 @@ static void init_once(void *foo)
 	inode_init_once(&ei->vfs_inode);
 }
 
-static int init_inodecache(void)
+static void init_inodecache(void)
 {
 	sock_inode_cachep = kmem_cache_create("sock_inode_cache",
 					      sizeof(struct socket_alloc),
@@ -296,9 +296,7 @@ static int init_inodecache(void)
 					       SLAB_RECLAIM_ACCOUNT |
 					       SLAB_MEM_SPREAD | SLAB_ACCOUNT),
 					      init_once);
-	if (sock_inode_cachep == NULL)
-		return -ENOMEM;
-	return 0;
+	BUG_ON(sock_inode_cachep == NULL);
 }
 
 static const struct super_operations sockfs_ops = {
-- 
2.7.4
