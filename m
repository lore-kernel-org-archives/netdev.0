From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 5/8] tipc: simplify link_print by divorcing it from using tipc_printf
Date: Thu, 12 Jul 2012 12:39:58 -0400
Message-ID: <1342111201-9426-6-git-send-email-paul.gortmaker@windriver.com>
References: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43557 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161337Ab2GLQka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:30 -0400
In-Reply-To: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To pave the way for a pending cleanup of tipc_printf, and
removal of struct print_buf entirely, we make that task simpler
by converting link_print to issue its messages with standard
printk infrastructure.  [Original idea separated from a larger
patch from Erik Hugne <erik.hugne@ericsson.com>]

Cc: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b389ab9..bf4cc41 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -3008,26 +3008,16 @@ u32 tipc_link_get_max_pkt(u32 dest, u32 selector)
 
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
-	char print_area[256];
-	struct print_buf pb;
-	struct print_buf *buf = &pb;
-
-	tipc_printbuf_init(buf, print_area, sizeof(print_area));
-
-	tipc_printf(buf, str);
-	tipc_printf(buf, "Link %x<%s>:",
-		    l_ptr->addr, l_ptr->b_ptr->name);
+	pr_info("TIPC: %s Link %x<%s>:", str, l_ptr->addr, l_ptr->b_ptr->name);
 
 	if (link_working_unknown(l_ptr))
-		tipc_printf(buf, ":WU");
+		pr_cont(":WU\n");
 	else if (link_reset_reset(l_ptr))
-		tipc_printf(buf, ":RR");
+		pr_cont(":RR\n");
 	else if (link_reset_unknown(l_ptr))
-		tipc_printf(buf, ":RU");
+		pr_cont(":RU\n");
 	else if (link_working_working(l_ptr))
-		tipc_printf(buf, ":WW");
-	tipc_printf(buf, "\n");
-
-	tipc_printbuf_validate(buf);
-	pr_info("TIPC: %s", print_area);
+		pr_cont(":WW\n");
+	else
+		pr_cont("\n");
 }
-- 
1.7.9.7
