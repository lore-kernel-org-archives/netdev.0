From: domen@coderock.org
Subject: [patch 1/5] ebtables.c - vfree() checking cleanups
Date: Sun, 06 Mar 2005 23:21:07 +0100
Message-ID: <20050306222108.782C61EC90@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, jlamanna@gmail.com
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



ebtables.c vfree() checking cleanups.

Signed-off by: James Lamanna <jlamanna@gmail.com>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/net/bridge/netfilter/ebtables.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff -puN net/bridge/netfilter/ebtables.c~vfree-net_bridge_netfilter_ebtables net/bridge/netfilter/ebtables.c
--- kj/net/bridge/netfilter/ebtables.c~vfree-net_bridge_netfilter_ebtables	2005-03-05 16:10:40.000000000 +0100
+++ kj-domen/net/bridge/netfilter/ebtables.c	2005-03-05 16:10:40.000000000 +0100
@@ -858,8 +858,7 @@ static int translate_table(struct ebt_re
 		if (repl->valid_hooks & (1 << i))
 			if (check_chainloops(newinfo->hook_entry[i],
 			   cl_s, udc_cnt, i, newinfo->entries)) {
-				if (cl_s)
-					vfree(cl_s);
+				vfree(cl_s);
 				return -EINVAL;
 			}
 
@@ -882,8 +881,7 @@ static int translate_table(struct ebt_re
 		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
 		   ebt_cleanup_entry, &i);
 	}
-	if (cl_s)
-		vfree(cl_s);
+	vfree(cl_s);
 	return ret;
 }
 
@@ -1029,8 +1027,7 @@ static int do_replace(void __user *user,
 	}
 	vfree(table);
 
-	if (counterstmp)
-		vfree(counterstmp);
+	vfree(counterstmp);
 	return ret;
 
 free_unlock:
@@ -1039,8 +1036,7 @@ free_iterate:
 	EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
 	   ebt_cleanup_entry, NULL);
 free_counterstmp:
-	if (counterstmp)
-		vfree(counterstmp);
+	vfree(counterstmp);
 	/* can be initialized in translate_table() */
 	if (newinfo->chainstack) {
 		for (i = 0; i < NR_CPUS; i++)
@@ -1048,11 +1044,9 @@ free_counterstmp:
 		vfree(newinfo->chainstack);
 	}
 free_entries:
-	if (newinfo->entries)
-		vfree(newinfo->entries);
+	vfree(newinfo->entries);
 free_newinfo:
-	if (newinfo)
-		vfree(newinfo);
+	vfree(newinfo);
 	return ret;
 }
 
@@ -1212,8 +1206,7 @@ void ebt_unregister_table(struct ebt_tab
 	down(&ebt_mutex);
 	LIST_DELETE(&ebt_tables, table);
 	up(&ebt_mutex);
-	if (table->private->entries)
-		vfree(table->private->entries);
+	vfree(table->private->entries);
 	if (table->private->chainstack) {
 		for (i = 0; i < NR_CPUS; i++)
 			vfree(table->private->chainstack[i]);
_
