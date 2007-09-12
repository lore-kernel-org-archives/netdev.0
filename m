From: dlezcano@fr.ibm.com
Subject: [net-2.6.24][NETNS][patch 1/3] fix export symbols
Date: Wed, 12 Sep 2007 14:38:12 +0200
Message-ID: <20070912124414.640551634@mai.toulouse-stg.fr.ibm.com>
References: <20070912123811.075269132@mai.toulouse-stg.fr.ibm.com>
Cc: ebiederm@xmission.com, containers@lists.osdl.org,
	netdev@vger.kernel.org, Mark Nelson <markn@au1.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:32787 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968040AbXILMqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 08:46:22 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l8CCkEbH266358
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 12:46:14 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8CCkEdG2654418
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 13:46:14 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8CCk7wg018395
	for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 13:46:08 +0100
Content-Disposition: inline; filename=net-fix-export-symbol.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Lezcano <dlezcano@fr.ibm.com>

Add the appropriate EXPORT_SYMBOLS for proc_net_create,
proc_net_fops_create and proc_net_remove to fix errors when
compiling allmodconfig

Signed-off-by: Mark Nelson <markn@au1.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/proc/proc_net.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: net-2.6.24/fs/proc/proc_net.c
===================================================================
--- net-2.6.24.orig/fs/proc/proc_net.c
+++ net-2.6.24/fs/proc/proc_net.c
@@ -31,6 +31,7 @@
 {
 	return create_proc_info_entry(name,mode, net->proc_net, get_info);
 }
+EXPORT_SYMBOL_GPL(proc_net_create);
 
 struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops)
@@ -42,12 +43,13 @@
 		res->proc_fops = fops;
 	return res;
 }
+EXPORT_SYMBOL_GPL(proc_net_fops_create);
 
 void proc_net_remove(struct net *net, const char *name)
 {
 	remove_proc_entry(name, net->proc_net);
 }
-
+EXPORT_SYMBOL_GPL(proc_net_remove);
 
 static struct proc_dir_entry *proc_net_shadow;
 

-- 
