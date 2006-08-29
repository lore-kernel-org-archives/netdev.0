From: paul.moore@hp.com
Subject: [PATCH 6/6] NetLabel: add some missing #includes to various header files
Date: Tue, 29 Aug 2006 10:42:57 -0400
Message-ID: <20060829144447.363702000@hp.com>
References: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:46470 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S965013AbWH2Oot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:49 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-header_includes
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add some missing include files to the NetLabel related header files.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/cipso_ipv4.h                    |    2 ++
 include/net/netlabel.h                      |    1 +
 net/netlabel/netlabel_domainhash.h          |    4 ++++
 net/netlabel/netlabel_user.h                |    5 +++--
 security/selinux/include/selinux_netlabel.h |    9 +++++++++
 5 files changed, 19 insertions(+), 2 deletions(-)

Index: net-2.6.19/include/net/cipso_ipv4.h
===================================================================
--- net-2.6.19.orig/include/net/cipso_ipv4.h
+++ net-2.6.19/include/net/cipso_ipv4.h
@@ -37,6 +37,8 @@
 #include <linux/types.h>
 #include <linux/rcupdate.h>
 #include <linux/list.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
 #include <net/netlabel.h>
 
 /* known doi values */
Index: net-2.6.19/include/net/netlabel.h
===================================================================
--- net-2.6.19.orig/include/net/netlabel.h
+++ net-2.6.19/include/net/netlabel.h
@@ -31,6 +31,7 @@
 #define _NETLABEL_H
 
 #include <linux/types.h>
+#include <linux/net.h>
 #include <linux/skbuff.h>
 #include <net/netlink.h>
 
Index: net-2.6.19/net/netlabel/netlabel_domainhash.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_domainhash.h
+++ net-2.6.19/net/netlabel/netlabel_domainhash.h
@@ -32,6 +32,10 @@
 #ifndef _NETLABEL_DOMAINHASH_H
 #define _NETLABEL_DOMAINHASH_H
 
+#include <linux/types.h>
+#include <linux/rcupdate.h>
+#include <linux/list.h>
+
 /* Domain hash table size */
 /* XXX - currently this number is an uneducated guess */
 #define NETLBL_DOMHSH_BITSIZE       7
Index: net-2.6.19/net/netlabel/netlabel_user.h
===================================================================
--- net-2.6.19.orig/net/netlabel/netlabel_user.h
+++ net-2.6.19/net/netlabel/netlabel_user.h
@@ -31,11 +31,12 @@
 #ifndef _NETLABEL_USER_H
 #define _NETLABEL_USER_H
 
+#include <linux/types.h>
 #include <linux/skbuff.h>
 #include <linux/capability.h>
-#include <linux/genetlink.h>
-#include <net/netlabel.h>
+#include <net/netlink.h>
 #include <net/genetlink.h>
+#include <net/netlabel.h>
 
 /* NetLabel NETLINK helper functions */
 
Index: net-2.6.19/security/selinux/include/selinux_netlabel.h
===================================================================
--- net-2.6.19.orig/security/selinux/include/selinux_netlabel.h
+++ net-2.6.19/security/selinux/include/selinux_netlabel.h
@@ -27,6 +27,15 @@
 #ifndef _SELINUX_NETLABEL_H_
 #define _SELINUX_NETLABEL_H_
 
+#include <linux/types.h>
+#include <linux/fs.h>
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#include "avc.h"
+#include "objsec.h"
+
 #ifdef CONFIG_NETLABEL
 void selinux_netlbl_cache_invalidate(void);
 int selinux_netlbl_socket_post_create(struct socket *sock,

--
paul moore
linux security @ hp
