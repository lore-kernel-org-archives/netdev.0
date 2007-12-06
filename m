From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2.6.25] Remove ip_fib_local_table and ip_fib_main_table
	defines
Date: Thu, 6 Dec 2007 17:58:25 +0300
Message-ID: <20071206145825.GA22435@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:52630 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751351AbXLFO5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2007 09:57:21 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@xmission.com>

There are only 2 users and it doesn't hurt to call fib_get_table
instead, and it makes it easier to make the fib network namespace
aware.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/ip_fib.h |    3 ---
 net/ipv4/fib_hash.c  |    5 +++--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index ed514bf..690fb4d 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -191,9 +191,6 @@ extern void __init fib4_rules_init(void);
 extern u32 fib_rules_tclass(struct fib_result *res);
 #endif
 
-#define ip_fib_local_table fib_get_table(RT_TABLE_LOCAL)
-#define ip_fib_main_table fib_get_table(RT_TABLE_MAIN)
-
 extern int fib_lookup(struct flowi *flp, struct fib_result *res);
 
 extern struct fib_table *fib_new_table(u32 id);
diff --git a/net/ipv4/fib_hash.c b/net/ipv4/fib_hash.c
index 9d0cee2..30ff657 100644
--- a/net/ipv4/fib_hash.c
+++ b/net/ipv4/fib_hash.c
@@ -810,7 +810,8 @@ struct fib_iter_state {
 static struct fib_alias *fib_get_first(struct seq_file *seq)
 {
 	struct fib_iter_state *iter = seq->private;
-	struct fn_hash *table = (struct fn_hash *) ip_fib_main_table->tb_data;
+	struct fib_table *main_table = fib_get_table(RT_TABLE_MAIN);
+	struct fn_hash *table = (struct fn_hash *)main_table->tb_data;
 
 	iter->bucket    = 0;
 	iter->hash_head = NULL;
@@ -949,7 +950,7 @@ static void *fib_seq_start(struct seq_file *seq, loff_t *pos)
 	void *v = NULL;
 
 	read_lock(&fib_hash_lock);
-	if (ip_fib_main_table)
+	if (fib_get_table(RT_TABLE_MAIN))
 		v = *pos ? fib_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
 	return v;
 }
-- 
1.5.3.rc5

