From: frank.blaschka@de.ibm.com
Subject: [patch 6/6] [PATCH] s390: Fix possibly wrong size in strncmp (smsgiucv)
Date: Wed, 02 Feb 2011 17:04:36 +0100
Message-ID: <20110202160530.841230797@de.ibm.com>
References: <20110202160430.554090958@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Weil <weil@mail.berlios.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:55044 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754532Ab1BBQFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:05:35 -0500
Content-Disposition: inline; filename=610-smsgiucv-strncmp-size.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Weil <weil@mail.berlios.de>

This error was reported by cppcheck:
drivers/s390/net/smsgiucv.c:63: error: Using sizeof for array given as
function argument returns the size of pointer.

Although there is no runtime problem as long as sizeof(u8 *) == 8,
this misleading code should get fixed.

Signed-off-by: Stefan Weil <weil@mail.berlios.de>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/smsgiucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
--- a/drivers/s390/net/smsgiucv.c
+++ b/drivers/s390/net/smsgiucv.c
@@ -60,7 +60,7 @@ static struct iucv_handler smsg_handler
 static int smsg_path_pending(struct iucv_path *path, u8 ipvmid[8],
 			     u8 ipuser[16])
 {
-	if (strncmp(ipvmid, "*MSG    ", sizeof(ipvmid)) != 0)
+	if (strncmp(ipvmid, "*MSG    ", 8) != 0)
 		return -EINVAL;
 	/* Path pending from *MSG. */
 	return iucv_path_accept(path, &smsg_handler, "SMSGIUCV        ", NULL);

