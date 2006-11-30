From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 2.6.18] declance: Fix RX ownership handover
Date: Thu, 30 Nov 2006 13:06:15 +0000 (GMT)
Message-ID: <Pine.LNX.4.64N.0611301257300.1757@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:19726 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP id S936287AbWK3NGT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 08:06:19 -0500
To: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 The change for PMAD support introduced a bug, where the ownership of RX 
descriptors was given back to the LANCE in the wrong way.  Occasional 
lockups would happen as a result.  This is a fix for this problem.

Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
---
 Tested with the onboard LANCE of a DECstation 5000/133.

 Please apply.

  Maciej

patch-mips-2.6.18-20060920-pmax-lance-rx-fix-0
diff -up --recursive --new-file linux-mips-2.6.18-20060920.macro/drivers/net/declance.c linux-mips-2.6.18-20060920/drivers/net/declance.c
--- linux-mips-2.6.18-20060920.macro/drivers/net/declance.c	2006-11-23 02:55:34.000000000 +0000
+++ linux-mips-2.6.18-20060920/drivers/net/declance.c	2006-11-30 02:26:34.000000000 +0000
@@ -628,7 +628,6 @@ static int lance_rx(struct net_device *d
 		/* Return the packet to the pool */
 		*rds_ptr(rd, mblength, lp->type) = 0;
 		*rds_ptr(rd, length, lp->type) = -RX_BUFF_SIZE | 0xf000;
-		*rds_ptr(rd, rmd1, lp->type) = LE_R1_OWN;
 		*rds_ptr(rd, rmd1, lp->type) =
 			((lp->rx_buf_ptr_lnc[entry] >> 16) & 0xff) | LE_R1_OWN;
 		lp->rx_new = (entry + 1) & RX_RING_MOD_MASK;
