From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 11/11]: PKT_SCHED: Use new header architecture
Date: Wed, 27 Oct 2004 00:29:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026222925.GL12289@postel.suug.ch>
References: <20041026222148.GA12289@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026222148.GA12289@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Thomas Graf <tgraf@suug.ch>

diff -Nru linux-2.6.10-rc1-bk1.orig/include/net/tc_act/tc_gact.h linux-2.6.10-rc1-bk1/include/net/tc_act/tc_gact.h
--- linux-2.6.10-rc1-bk1.orig/include/net/tc_act/tc_gact.h	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/tc_act/tc_gact.h	2004-10-25 20:07:54.000000000 +0200
@@ -1,7 +1,7 @@
 #ifndef __NET_TC_GACT_H
 #define __NET_TC_GACT_H
 
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
 
 struct tcf_gact
 {
diff -Nru linux-2.6.10-rc1-bk1.orig/include/net/tc_act/tc_mirred.h linux-2.6.10-rc1-bk1/include/net/tc_act/tc_mirred.h
--- linux-2.6.10-rc1-bk1.orig/include/net/tc_act/tc_mirred.h	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/include/net/tc_act/tc_mirred.h	2004-10-25 20:07:54.000000000 +0200
@@ -1,7 +1,7 @@
 #ifndef __NET_TC_MIR_H
 #define __NET_TC_MIR_H
 
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
 
 struct tcf_mirred
 {
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/act_api.c linux-2.6.10-rc1-bk1/net/sched/act_api.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/act_api.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/act_api.c	2004-10-25 20:07:54.000000000 +0200
@@ -31,7 +31,8 @@
 #include <linux/init.h>
 #include <linux/kmod.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/sch_generic.h>
+#include <net/act_api.h>
 
 #if 1 /* control */
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_api.c	2004-10-26 23:42:10.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_api.c	2004-10-26 23:55:48.000000000 +0200
@@ -36,6 +36,7 @@
 #include <linux/kmod.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
+#include <net/pkt_cls.h>
 
 #if 0 /* control */
 #define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_fw.c linux-2.6.10-rc1-bk1/net/sched/cls_fw.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_fw.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_fw.c	2004-10-25 20:07:54.000000000 +0200
@@ -43,7 +43,8 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 
 struct fw_head
 {
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_route.c linux-2.6.10-rc1-bk1/net/sched/cls_route.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_route.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_route.c	2004-10-25 20:07:54.000000000 +0200
@@ -33,7 +33,8 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 
 /*
    1. For now we assume that route tags < 256.
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_rsvp.c linux-2.6.10-rc1-bk1/net/sched/cls_rsvp.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_rsvp.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_rsvp.c	2004-10-25 20:07:54.000000000 +0200
@@ -32,7 +32,8 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 
 #define RSVP_DST_LEN	1
 #define RSVP_ID		"rsvp"
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_rsvp6.c linux-2.6.10-rc1-bk1/net/sched/cls_rsvp6.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_rsvp6.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_rsvp6.c	2004-10-25 20:07:54.000000000 +0200
@@ -33,7 +33,8 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 
 #define RSVP_DST_LEN	4
 #define RSVP_ID		"rsvp6"
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_tcindex.c linux-2.6.10-rc1-bk1/net/sched/cls_tcindex.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_tcindex.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_tcindex.c	2004-10-26 13:55:46.000000000 +0200
@@ -12,7 +12,8 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <net/ip.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 #include <net/route.h>
 
 
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/cls_u32.c linux-2.6.10-rc1-bk1/net/sched/cls_u32.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/cls_u32.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/cls_u32.c	2004-10-25 20:07:54.000000000 +0200
@@ -54,7 +54,8 @@
 #include <net/route.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
+#include <net/pkt_cls.h>
 
 
 struct tc_u_knode
diff -Nru linux-2.6.10-rc1-bk1.orig/net/sched/police.c linux-2.6.10-rc1-bk1/net/sched/police.c
--- linux-2.6.10-rc1-bk1.orig/net/sched/police.c	2004-10-26 14:51:02.000000000 +0200
+++ linux-2.6.10-rc1-bk1/net/sched/police.c	2004-10-25 20:07:54.000000000 +0200
@@ -31,7 +31,7 @@
 #include <linux/rtnetlink.h>
 #include <linux/init.h>
 #include <net/sock.h>
-#include <net/pkt_sched.h>
+#include <net/act_api.h>
 
 #define L2T(p,L)   ((p)->R_tab->data[(L)>>(p)->R_tab->rate.cell_log])
 #define L2T_P(p,L) ((p)->P_tab->data[(L)>>(p)->P_tab->rate.cell_log])
