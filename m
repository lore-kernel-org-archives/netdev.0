From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/7] bonding: Convert delay value from s16 to int
Date: Fri, 01 Sep 2006 15:08:24 -0700
Message-ID: <200609012208.k81M8OZt005444@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:4810 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751059AbWIAWI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:08:26 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k81M8PEn003230
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:08:25 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k81M8PCP267252
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:08:25 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k81M8PFp017069
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:08:25 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Kenzo Iwami <k-iwami@cj.jp.nec.com>

The value of "downdelay/miimon" and "updelay/miimon" are stored in
slave->delay. The type of downdelay, updelay, and miimon are all int.
However, slave->delay is type short, and it is not possible to store the
value of "downdelay/miimon" or "updelay/miimon" in some cases. (For example,
miimon=1 downdelay=32768)

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>


diff -urpN linux-2.6.17/drivers/net/bonding/bonding.h
linux-2.6.17_fix/drivers/net/bonding/bonding.h
--- linux-2.6.17/drivers/net/bonding/bonding.h	2006-06-18 10:49:35.000000000 +0900
+++ linux-2.6.17_fix/drivers/net/bonding/bonding.h	2006-06-19 16:52:43.000000000
+0900
@@ -149,7 +149,7 @@ struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct slave *next;
 	struct slave *prev;
-	s16    delay;
+	int    delay;
 	u32    jiffies;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */

-- 
VGER BF report: H 0.391544
