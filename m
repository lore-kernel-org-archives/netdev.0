From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH REPOST 2/10] bonding: Convert delay value from s16 to int
Date: Fri, 22 Sep 2006 21:52:51 -0700
Message-ID: <200609230452.k8N4qpZt027924@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:11726 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750972AbWIWEwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2006 00:52:53 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8N4qqfp031061
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:52:52 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8N4qqwL253218
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:52:52 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8N4qqK2030621
	for <netdev@vger.kernel.org>; Sat, 23 Sep 2006 00:52:52 -0400
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The value of "downdelay/miimon" and "updelay/miimon" are stored in
slave->delay. The type of downdelay, updelay, and miimon are all int.
However, slave->delay is type short, and it is not possible to store the
value of "downdelay/miimon" or "updelay/miimon" in some cases. (For example,
miimon=1 downdelay=32768)

The attached patch fixes this problem.

Signed-off-by: Kenzo Iwami <k-iwami@cj.jp.nec.com>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 0bdfe2c..17caafe 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -149,7 +149,7 @@ struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct slave *next;
 	struct slave *prev;
-	s16    delay;
+	int    delay;
 	u32    jiffies;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     state;   /* one of BOND_STATE_XXXX */
