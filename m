From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] fix ipvs printk parameter types
Date: Wed, 27 Aug 2003 22:02:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827220212.7ccf6ddf.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linuxvirtualserver.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,
Please apply.

patch_name:	ipvs_sizes.patch
patch_version:	2003-08-27.18:16:43
author:		Randy.Dunlap <rddunlap@osdl.org>
description:	ipvs: fix gcc warnings of mismatched printk parameter types;
product:	Linux
product_versions: 260-test4
maintainer:	Wensong Zhang <wensong@linuxvirtualserver.org> (?)
diffstat:	=
 net/ipv4/ipvs/ip_vs_conn.c  |    2 +-
 net/ipv4/ipvs/ip_vs_dh.c    |    4 ++--
 net/ipv4/ipvs/ip_vs_lblc.c  |    4 ++--
 net/ipv4/ipvs/ip_vs_lblcr.c |    4 ++--
 net/ipv4/ipvs/ip_vs_sh.c    |    4 ++--
 net/ipv4/ipvs/ip_vs_sync.c  |    2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff -Naur ./net/ipv4/ipvs/ip_vs_conn.c~ipvssize ./net/ipv4/ipvs/ip_vs_conn.c
--- ./net/ipv4/ipvs/ip_vs_conn.c~ipvssize	Fri Aug 22 16:59:44 2003
+++ ./net/ipv4/ipvs/ip_vs_conn.c	Wed Aug 27 10:02:37 2003
@@ -837,7 +837,7 @@
 		   "(size=%d, memory=%ldKbytes)\n",
 		   IP_VS_CONN_TAB_SIZE,
 		   (long)(IP_VS_CONN_TAB_SIZE*sizeof(struct list_head))/1024);
-	IP_VS_DBG(0, "Each connection entry needs %d bytes at least\n",
+	IP_VS_DBG(0, "Each connection entry needs %Zd bytes at least\n",
 		  sizeof(struct ip_vs_conn));
 
 	for (idx = 0; idx < IP_VS_CONN_TAB_SIZE; idx++) {
diff -Naur ./net/ipv4/ipvs/ip_vs_lblc.c~ipvssize ./net/ipv4/ipvs/ip_vs_lblc.c
--- ./net/ipv4/ipvs/ip_vs_lblc.c~ipvssize	Fri Aug 22 16:59:37 2003
+++ ./net/ipv4/ipvs/ip_vs_lblc.c	Wed Aug 27 10:18:35 2003
@@ -396,7 +396,7 @@
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
-	IP_VS_DBG(6, "LBLC hash table (memory=%dbytes) allocated for "
+	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_lblc_table));
 
@@ -436,7 +436,7 @@
 
 	/* release the table itself */
 	kfree(svc->sched_data);
-	IP_VS_DBG(6, "LBLC hash table (memory=%dbytes) released\n",
+	IP_VS_DBG(6, "LBLC hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_lblc_table));
 
 	return 0;
diff -Naur ./net/ipv4/ipvs/ip_vs_lblcr.c~ipvssize ./net/ipv4/ipvs/ip_vs_lblcr.c
--- ./net/ipv4/ipvs/ip_vs_lblcr.c~ipvssize	Fri Aug 22 16:58:50 2003
+++ ./net/ipv4/ipvs/ip_vs_lblcr.c	Wed Aug 27 10:19:24 2003
@@ -649,7 +649,7 @@
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
-	IP_VS_DBG(6, "LBLCR hash table (memory=%dbytes) allocated for "
+	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_lblcr_table));
 
@@ -692,7 +692,7 @@
 
 	/* release the table itself */
 	kfree(svc->sched_data);
-	IP_VS_DBG(6, "LBLCR hash table (memory=%dbytes) released\n",
+	IP_VS_DBG(6, "LBLCR hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_lblcr_table));
 
 	return 0;
diff -Naur ./net/ipv4/ipvs/ip_vs_sh.c~ipvssize ./net/ipv4/ipvs/ip_vs_sh.c
--- ./net/ipv4/ipvs/ip_vs_sh.c~ipvssize	Fri Aug 22 16:58:07 2003
+++ ./net/ipv4/ipvs/ip_vs_sh.c	Wed Aug 27 10:30:04 2003
@@ -144,7 +144,7 @@
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
-	IP_VS_DBG(6, "SH hash table (memory=%dbytes) allocated for "
+	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE);
 
@@ -164,7 +164,7 @@
 
 	/* release the table itself */
 	kfree(svc->sched_data);
-	IP_VS_DBG(6, "SH hash table (memory=%dbytes) released\n",
+	IP_VS_DBG(6, "SH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_sh_bucket)*IP_VS_SH_TAB_SIZE);
 
 	return 0;
diff -Naur ./net/ipv4/ipvs/ip_vs_sync.c~ipvssize ./net/ipv4/ipvs/ip_vs_sync.c
--- ./net/ipv4/ipvs/ip_vs_sync.c~ipvssize	Fri Aug 22 16:50:52 2003
+++ ./net/ipv4/ipvs/ip_vs_sync.c	Wed Aug 27 12:14:47 2003
@@ -851,7 +851,7 @@
 		return -EEXIST;
 
 	IP_VS_DBG(7, "%s: pid %d\n", __FUNCTION__, current->pid);
-	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %d bytes\n",
+	IP_VS_DBG(7, "Each ip_vs_sync_conn entry need %Zd bytes\n",
 		  sizeof(struct ip_vs_sync_conn));
 
 	ip_vs_sync_state |= state;
diff -Naur ./net/ipv4/ipvs/ip_vs_dh.c~ipvssize ./net/ipv4/ipvs/ip_vs_dh.c
--- ./net/ipv4/ipvs/ip_vs_dh.c~ipvssize	Wed Aug 27 12:18:00 2003
+++ ./net/ipv4/ipvs/ip_vs_dh.c	Wed Aug 27 12:18:31 2003
@@ -147,7 +147,7 @@
 		return -ENOMEM;
 	}
 	svc->sched_data = tbl;
-	IP_VS_DBG(6, "DH hash table (memory=%dbytes) allocated for "
+	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) allocated for "
 		  "current service\n",
 		  sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE);
 
@@ -167,7 +167,7 @@
 
 	/* release the table itself */
 	kfree(svc->sched_data);
-	IP_VS_DBG(6, "DH hash table (memory=%dbytes) released\n",
+	IP_VS_DBG(6, "DH hash table (memory=%Zdbytes) released\n",
 		  sizeof(struct ip_vs_dh_bucket)*IP_VS_DH_TAB_SIZE);
 
 	return 0;


--
~Randy
