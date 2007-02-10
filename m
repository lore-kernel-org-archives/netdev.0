From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] zd1211rw: Readd zd_addr_t cast
Date: Sat, 10 Feb 2007 01:27:18 +0000 (GMT)
Message-ID: <20070210012718.3B6E87B409F@zog.reactivated.net>
Cc: netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtaout01-winn.ispmail.ntl.com ([81.103.221.47]:26924 "EHLO
	mtaout01-winn.ispmail.ntl.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752593AbXBJB1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 20:27:13 -0500
Cc: linux-wireless@vger.kernel.org
Cc: kune@deine-taler.de
Cc: rpjday@mindspring.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert P.J. Day's recent commit ("getting rid of all casts of k[cmz]alloc()
calls") introduced a sparse warning for zd1211rw, related to our type-checking
of addresses.

	zd_chip.c:116:15: warning: implicit cast to nocast type

This patch readds the type cast, it is correct.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
===================================================================
--- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
+++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -113,7 +113,7 @@ int zd_ioread32v_locked(struct zd_chip *
 
 	/* Allocate a single memory block for values and addresses. */
 	count16 = 2*count;
-	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
+	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
 		                   GFP_NOFS);
 	if (!a16) {
 		dev_dbg_f(zd_chip_dev(chip),
