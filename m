From: akpm@osdl.org
Subject: [patch 1/1] err1-28: rose_route locking fix
Date: Fri, 02 Jul 2004 01:11:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200407020812.i628CFG17588@mail.osdl.org>
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Fix deadlock in rose_del_loopback_node().  Found by the Stanford locking
checker.

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/rose/rose_route.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/rose/rose_route.c~err1-28-rose_route-locking-fix net/rose/rose_route.c
--- 25/net/rose/rose_route.c~err1-28-rose_route-locking-fix	2004-07-02 01:09:27.377403248 -0700
+++ 25-akpm/net/rose/rose_route.c	2004-07-02 01:09:33.617454616 -0700
@@ -206,7 +206,6 @@ static void rose_remove_node(struct rose
 {
 	struct rose_node *s;
 
-	spin_lock_bh(&rose_node_list_lock);
 	if ((s = rose_node_list) == rose_node) {
 		rose_node_list = rose_node->next;
 		kfree(rose_node);
_
