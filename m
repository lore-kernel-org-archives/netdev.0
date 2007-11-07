From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 2/2] move unneeded data to initdata section
Date: Wed, 7 Nov 2007 15:01:00 +0300
Message-ID: <20071107120100.GA10185@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org, containers@lists.osdl.org,
	netdev@vger.kernel.org, clg@fr.ibm.com, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-mipt-nat.sw.ru ([195.214.233.10]:58325 "EHLO iris"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753105AbXKGL52 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 06:57:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch reverts Eric's commit 2b008b0a8e96b726c603c5e1a5a7a509b5f61e35

It diets .text & .data section of the kernel if CONFIG_NET_NS is not set.
This is safe after list operations cleanup.

Signed-of-by: Denis V. Lunev <den@openvz.org>

--- ./drivers/net/loopback.c.reversed	2007-10-30 14:45:07.000000000 +0300
+++ ./drivers/net/loopback.c	2007-11-01 17:30:55.000000000 +0300
@@ -284,7 +284,7 @@ static __net_exit void loopback_net_exit
 	unregister_netdev(dev);
 }
 
-static struct pernet_operations loopback_net_ops = {
+static struct pernet_operations __net_initdata loopback_net_ops = {
        .init = loopback_net_init,
        .exit = loopback_net_exit,
 };
--- ./fs/proc/proc_net.c.reversed	2007-10-30 14:45:07.000000000 +0300
+++ ./fs/proc/proc_net.c	2007-11-01 17:30:57.000000000 +0300
@@ -185,7 +185,7 @@ static __net_exit void proc_net_ns_exit(
 	kfree(net->proc_net_root);
 }
 
-static struct pernet_operations proc_net_ns_ops = {
+static struct pernet_operations __net_initdata proc_net_ns_ops = {
 	.init = proc_net_ns_init,
 	.exit = proc_net_ns_exit,
 };
--- ./include/net/net_namespace.h.reversed	2007-10-30 14:45:07.000000000 +0300
+++ ./include/net/net_namespace.h	2007-11-01 17:30:58.000000000 +0300
@@ -102,9 +102,11 @@ static inline void release_net(struct ne
 #ifdef CONFIG_NET_NS
 #define __net_init
 #define __net_exit
+#define __net_initdata
 #else
 #define __net_init	__init
 #define __net_exit	__exit_refok
+#define __net_initdata	__initdata
 #endif
 
 struct pernet_operations {
--- ./net/core/dev.c.reversed	2007-10-30 14:45:08.000000000 +0300
+++ ./net/core/dev.c	2007-11-01 17:30:58.000000000 +0300
@@ -2676,7 +2676,7 @@ static void __net_exit dev_proc_net_exit
 	proc_net_remove(net, "dev");
 }
 
-static struct pernet_operations dev_proc_ops = {
+static struct pernet_operations __net_initdata dev_proc_ops = {
 	.init = dev_proc_net_init,
 	.exit = dev_proc_net_exit,
 };
@@ -4336,7 +4336,7 @@ static void __net_exit netdev_exit(struc
 	kfree(net->dev_index_head);
 }
 
-static struct pernet_operations  netdev_net_ops = {
+static struct pernet_operations __net_initdata netdev_net_ops = {
 	.init = netdev_init,
 	.exit = netdev_exit,
 };
@@ -4367,7 +4367,7 @@ static void __net_exit default_device_ex
 	rtnl_unlock();
 }
 
-static struct pernet_operations  default_device_ops = {
+static struct pernet_operations __net_initdata default_device_ops = {
 	.exit = default_device_exit,
 };
 
--- ./net/core/dev_mcast.c.reversed	2007-10-30 14:45:08.000000000 +0300
+++ ./net/core/dev_mcast.c	2007-11-01 17:31:00.000000000 +0300
@@ -285,7 +285,7 @@ static void __net_exit dev_mc_net_exit(s
 	proc_net_remove(net, "dev_mcast");
 }
 
-static struct pernet_operations dev_mc_net_ops = {
+static struct pernet_operations __net_initdata dev_mc_net_ops = {
 	.init = dev_mc_net_init,
 	.exit = dev_mc_net_exit,
 };
--- ./net/netlink/af_netlink.c.reversed	2007-10-30 14:45:08.000000000 +0300
+++ ./net/netlink/af_netlink.c	2007-11-01 17:31:01.000000000 +0300
@@ -1888,7 +1888,7 @@ static void __net_exit netlink_net_exit(
 #endif
 }
 
-static struct pernet_operations netlink_net_ops = {
+static struct pernet_operations __net_initdata netlink_net_ops = {
 	.init = netlink_net_init,
 	.exit = netlink_net_exit,
 };
