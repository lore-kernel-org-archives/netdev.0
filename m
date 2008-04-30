From: Bernard Pidoux <bpidoux@free.fr>
Subject: [PATCH] Wrong list_lock argument in rose_node seqops
Date: Wed, 30 Apr 2008 22:08:56 +0200
Message-ID: <200804302208.56925.bpidoux@free.fr>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-hams" <linux-hams@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:41503 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757301AbYD3UJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 16:09:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rose_node_start() as well as in rose_node_stop()
__acquires() and spin_lock_bh() were wrongly passing
rose_neigh_list_lock instead of rose_node_list_lock arguments.

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
 net/rose/rose_route.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 5053a53..bd59387 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -1066,12 +1066,12 @@ out:
 #ifdef CONFIG_PROC_FS
 
 static void *rose_node_start(struct seq_file *seq, loff_t *pos)
-	__acquires(rose_neigh_list_lock)
+	__acquires(rose_node_list_lock)
 {
 	struct rose_node *rose_node;
 	int i = 1;
 
-	spin_lock_bh(&rose_neigh_list_lock);
+	spin_lock_bh(&rose_node_list_lock);
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
@@ -1090,9 +1090,9 @@ static void *rose_node_next(struct seq_file *seq, void *v, loff_t *pos)
 }
 
 static void rose_node_stop(struct seq_file *seq, void *v)
-	__releases(rose_neigh_list_lock)
+	__releases(rose_node_list_lock)
 {
-	spin_unlock_bh(&rose_neigh_list_lock);
+	spin_unlock_bh(&rose_node_list_lock);
 }
 
 static int rose_node_show(struct seq_file *seq, void *v)
-- 
1.5.5

