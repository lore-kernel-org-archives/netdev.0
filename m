From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] iucv: fix build error on !SMP
Date: Mon, 03 Mar 2008 14:16:11 +0100
Message-ID: <20080303131924.416374000@linux.vnet.ibm.com>
References: <20080303131610.405835000@linux.vnet.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Josef Jeff Sipek <jeffpc@josefsipek.net>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:15947 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752544AbYCCNTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:19:30 -0500
Content-Disposition: inline; filename=717-iucv-nonsmp.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>
From: Josef 'Jeff' Sipek <jeffpc@josefsipek.net>

Since a5fbb6d1064be885d2a6b82f625186753cf74848
"KVM: fix !SMP build error" smp_call_function isn't a define anymore
that folds into nothing but a define that calls up_smp_call_function
with all parameters. Hence we cannot #ifdef out the unused code
anymore...
This seems to be the preferred method, so do this for s390 as well.

net/iucv/iucv.c: In function 'iucv_cleanup_queue':
net/iucv/iucv.c:657: error: '__iucv_cleanup_queue' undeclared

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Josef 'Jeff' Sipek <jeffpc@josefsipek.net>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 net/iucv/iucv.c |    2 --
 1 file changed, 2 deletions(-)

diff -urpN linux-2.6/net/iucv/iucv.c linux-2.6-patched/net/iucv/iucv.c
--- linux-2.6/net/iucv/iucv.c	2008-03-03 12:40:25.000000000 +0100
+++ linux-2.6-patched/net/iucv/iucv.c	2008-03-03 12:40:56.000000000 +0100
@@ -621,7 +621,6 @@ static int iucv_sever_pathid(u16 pathid,
 	return iucv_call_b2f0(IUCV_SEVER, parm);
 }
 
-#ifdef CONFIG_SMP
 /**
  * __iucv_cleanup_queue
  * @dummy: unused dummy argument
@@ -632,7 +631,6 @@ static int iucv_sever_pathid(u16 pathid,
 static void __iucv_cleanup_queue(void *dummy)
 {
 }
-#endif
 
 /**
  * iucv_cleanup_queue

-- 
