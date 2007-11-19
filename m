From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch 21/22] NET: DM9000: Update retry count whilst identifying chip
Date: Mon, 19 Nov 2007 20:39:31 +0000
Message-ID: <20071119204016.313770872@fluff.org>
References: <20071119203910.687238131@fluff.org>
Cc: vince@simtec.co.uk, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:61653 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751621AbXKSVOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 16:14:11 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-id-retry.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reading the ID register does not always return the correct ID
from the device, so we retry several times to see if we get
a correct value.

These failures seem to be excaserbated by the speed of the
access to the chip (possibly time between issuing the address
and then the data cycle).

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.23-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.23-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.23-quilt3/drivers/net/dm9000.c
@@ -652,7 +652,7 @@ dm9000_probe(struct platform_device *pde
 	dm9000_reset(db);
 
 	/* try two times, DM9000 sometimes gets the first read wrong */
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < 8; i++) {
 		id_val  = ior(db, DM9000_VIDL);
 		id_val |= (u32)ior(db, DM9000_VIDH) << 8;
 		id_val |= (u32)ior(db, DM9000_PIDL) << 16;

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
