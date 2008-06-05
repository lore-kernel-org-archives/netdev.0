From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/3] iucv: fix section mismatch warning.
Date: Thu, 05 Jun 2008 11:08:38 +0200
Message-ID: <20080605091436.838486000@linux.vnet.ibm.com>
References: <20080605090837.212105000@linux.vnet.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:39130 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbYFEJPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 05:15:21 -0400
Content-Disposition: inline; filename=605-iucv-sections.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

WARNING: net/iucv/built-in.o(.exit.text+0x9c): Section mismatch in
reference from the function iucv_exit() to the variable
.cpuinit.data:iucv_cpu_notifier

This warning is caused by a reference from unregister_hotcpu_notifier()
from an exit function to a cpuinitdata annotated data structurre.
This is a false positive warning since for the non CPU_HOTPLUG case
unregister_hotcpu_notifier() is a nop.
Use __refdata instead of __cpuinitdata to get rid of the warning.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-2.6-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/iucv.c
+++ net-2.6-uschi/net/iucv/iucv.c
@@ -598,7 +598,7 @@ static int __cpuinit iucv_cpu_notify(str
 	return NOTIFY_OK;
 }
 
-static struct notifier_block __cpuinitdata iucv_cpu_notifier = {
+static struct notifier_block __refdata iucv_cpu_notifier = {
 	.notifier_call = iucv_cpu_notify,
 };
 

-- 
