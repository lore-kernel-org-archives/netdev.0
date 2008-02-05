From: Ben Dooks <ben-linux@fluff.org>
Subject: [PATCH 23/24 for-2.6.25] DM9000: Update retry count whilst identifying chip
Date: Tue, 05 Feb 2008 00:02:22 +0000
Message-ID: <20080205000819.127448205@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk>
Cc: jeff@garzik.org, akpm@linux-foundation.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com, Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:58744 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758855AbYBEAIZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:08:25 -0500
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-id-retry.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading the ID register does not always return the correct ID
from the device, so we retry several times to see if we get
a correct value.

These failures seem to be excaserbated by the speed of the
access to the chip (possibly time between issuing the address
and then the data cycle).

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.24-quilt3/drivers/net/dm9000.c
===================================================================
--- linux-2.6.24-quilt3.orig/drivers/net/dm9000.c
+++ linux-2.6.24-quilt3/drivers/net/dm9000.c
@@ -643,7 +643,7 @@ dm9000_probe(struct platform_device *pde
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
