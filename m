From: frank.blaschka@de.ibm.com
Subject: [patch 6/7] [PATCH] s390: Fix wrong size in memcmp (netiucv)
Date: Tue, 01 Feb 2011 09:16:53 +0100
Message-ID: <20110201081724.039221197@de.ibm.com>
References: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Weil <weil@mail.berlios.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([194.196.100.164]:35785 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab1BAISh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:18:37 -0500
Content-Disposition: inline; filename=609-netiucv-memcmp-size.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Weil <weil@mail.berlios.de>

This error was reported by cppcheck:
drivers/s390/net/netiucv.c:568: error: Using sizeof for array given
as function argument returns the size of pointer.

sizeof(ipuser) did not result in 16 (as many programmers would have
expected) but sizeof(u8 *), so it is 4 or 8, too small here.

Signed-off-by: Stefan Weil <weil@mail.berlios.de>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/netiucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
--- a/drivers/s390/net/netiucv.c
+++ b/drivers/s390/net/netiucv.c
@@ -565,7 +565,7 @@ static int netiucv_callback_connreq(stru
 	struct iucv_event ev;
 	int rc;
 
-	if (memcmp(iucvMagic, ipuser, sizeof(ipuser)))
+	if (memcmp(iucvMagic, ipuser, 16))
 		/* ipuser must match iucvMagic. */
 		return -EINVAL;
 	rc = -EINVAL;

