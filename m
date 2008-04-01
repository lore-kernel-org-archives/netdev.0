From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/3] iucv: get rid of in_atomic() use.
Date: Tue, 01 Apr 2008 15:45:23 +0200
Message-ID: <20080401135709.170734000@linux.vnet.ibm.com>
References: <20080401134521.169525000@linux.vnet.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:39744 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146AbYDAN5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 09:57:11 -0400
Content-Disposition: inline; filename=722-iucv-inatomic.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

This BUG_ON is not needed, since all (debug) checks are also done
in smp_call_function() which gets called by this function.

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |    1 -
 1 file changed, 1 deletion(-)

Index: net-2.6.26-uschi/net/iucv/iucv.c
===================================================================
--- net-2.6.26-uschi.orig/net/iucv/iucv.c
+++ net-2.6.26-uschi/net/iucv/iucv.c
@@ -795,7 +795,6 @@ int iucv_path_connect(struct iucv_path *
 	union iucv_param *parm;
 	int rc;
 
-	BUG_ON(in_atomic());
 	spin_lock_bh(&iucv_table_lock);
 	iucv_cleanup_queue();
 	parm = iucv_param[smp_processor_id()];

-- 
