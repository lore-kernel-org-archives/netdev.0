From: Ben Dooks <ben-linux@fluff.org>
Subject: [patch v3 09/12] DM9000: Add missing msleep() in EEPROM wait code.
Date: Tue, 24 Jun 2008 22:16:05 +0100
Message-ID: <20080624211905.828139680@fluff.org.uk>
References: <20080624211556.566149406@fluff.org.uk>
Cc: jeff@garzik.org, laurentp@cse-semaphore.com,
	Ben Dooks <ben-linux@fluff.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:64001 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753877AbYFXVTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 17:19:07 -0400
Content-Disposition: inline; filename=simtec/simtec-drivers-net-dm9000-eeprom-delay.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The msleep() call in the code that checks for the
EEPROM controller's busy status was missing.

Signed-off-by: Ben Dooks <ben-linux@fluff.org>

Index: linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c
===================================================================
--- linux-2.6.26-rc6-quilt1.orig/drivers/net/dm9000.c	2008-06-16 00:07:15.000000000 +0100
+++ linux-2.6.26-rc6-quilt1/drivers/net/dm9000.c	2008-06-16 00:07:44.000000000 +0100
@@ -343,6 +343,8 @@ static int dm9000_wait_eeprom(board_info
 		if ((status & EPCR_ERRE) == 0)
 			break;
 
+		msleep(1);
+
 		if (timeout-- < 0) {
 			dev_dbg(db->dev, "timeout waiting EEPROM\n");
 			break;

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
