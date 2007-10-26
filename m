From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH] 2.6.24-rc1 remove architecture warning compiling fealnx on ia64
Date: Fri, 26 Oct 2007 14:04:06 -0700 (PDT)
Message-ID: <200710262104.OAA14012@tardy.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=X-roman8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:44423 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754940AbXJZVEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 17:04:09 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel12.hp.com (Postfix) with ESMTP id BBD9B35E41
	for <netdev@vger.kernel.org>; Fri, 26 Oct 2007 14:04:07 -0700 (PDT)
Received: (from raj@localhost)
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) id OAA14012
	for netdev@vger.kernel.org; Fri, 26 Oct 2007 14:04:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The likelihood of one of these being used on an ia64 box is epsilon
but it would still be nice to get rid of the warning:

 #warning Processor architecture undefined! 

when compiling on same. So, pick some likely similar architectures
and follow those leads. Compile tested only.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---
diff -r 35e54d4beaad drivers/net/fealnx.c
--- a/drivers/net/fealnx.c	Wed Oct 24 05:06:40 2007 +0000
+++ b/drivers/net/fealnx.c	Fri Oct 26 06:12:00 2007 -0700
@@ -866,7 +866,7 @@ static int netdev_open(struct net_device
 //   np->bcrvalue=0x04 | 0x0x38;  /* big-endian, 256 burst length */
 	np->bcrvalue = 0x04 | 0x10;	/* big-endian, tx 8 burst length */
 	np->crvalue = 0xe00;	/* rx 128 burst length */
-#elif defined(__alpha__) || defined(__x86_64__)
+#elif defined(__alpha__) || defined(__x86_64__) || defined(__ia64__)
 // 89/9/1 modify,
 //   np->bcrvalue=0x38;           /* little-endian, 256 burst length */
 	np->bcrvalue = 0x10;	/* little-endian, 8 burst length */
