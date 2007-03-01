From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2/3] bonding: only receive ARPs for us
Date: Wed, 28 Feb 2007 17:03:27 -0800
Message-ID: <200703010103.l2113R22030799@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:53456 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932876AbXCABDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Feb 2007 20:03:41 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2113cTQ011063
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:03:38 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l2113TYY268226
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:03:29 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l2113TnY015944
	for <netdev@vger.kernel.org>; Wed, 28 Feb 2007 20:03:29 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	The ARP validation code only needs ARPs for the bonding device.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1f263ac..7ec6121 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3427,7 +3427,7 @@ void bond_register_arp(struct bonding *b
 		return;
 
 	pt->type = htons(ETH_P_ARP);
-	pt->dev = NULL; /*bond->dev;XXX*/
+	pt->dev = bond->dev;
 	pt->func = bond_arp_rcv;
 	dev_add_pack(pt);
 }
