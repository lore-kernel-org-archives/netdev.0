From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/4] [PKT_SCHED] Fix numeric comparison in meta ematch
Date: Fri, 03 Jun 2005 23:12:45 +0200
Message-ID: <20050603211315.972265000@axs>
References: <20050603211241.593114000@axs>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Content-Disposition: inline; filename=meta_compare_fix
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch is brought to you by the department of applied stupidity.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: ematch/net/sched/em_meta.c
===================================================================
--- ematch.orig/net/sched/em_meta.c
+++ ematch/net/sched/em_meta.c
@@ -639,9 +639,9 @@ static int meta_int_compare(struct meta_
 	/* Let gcc optimize it, the unlikely is not really based on
 	 * some numbers but jump free code for mismatches seems
 	 * more logical. */
-	if (unlikely(a == b))
+	if (unlikely(a->value == b->value))
 		return 0;
-	else if (a < b)
+	else if (a->value < b->value)
 		return -1;
 	else
 		return 1;
