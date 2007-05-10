From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH] spidernet: remove unnecessary accesses to phy
Date: Thu, 10 May 2007 12:18:48 -0500
Message-ID: <20070510171848.GD4452@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:59462 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321AbXEJRSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 13:18:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l4AHIoxj012317
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:18:50 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4AHIoVY531456
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:18:50 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4AHIn4N032216
	for <netdev@vger.kernel.org>; Thu, 10 May 2007 13:18:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Jeff, please apply for 2.6.22; This is a purely janitorial patch.

(I will have additonal patches for the spidernet in a few days;
I'm still debugging a rather nasty hang.)

--linas


From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>

This patch removes unnecessary accesses to phy registers.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

Index: linux-2.6.21-rc7-mm2/drivers/net/spider_net.c
===================================================================
--- linux-2.6.21-rc7-mm2.orig/drivers/net/spider_net.c	2007-05-09 14:19:29.000000000 -0500
+++ linux-2.6.21-rc7-mm2/drivers/net/spider_net.c	2007-05-09 14:20:28.000000000 -0500
@@ -175,12 +175,10 @@ spider_net_setup_aneg(struct spider_net_
 {
 	struct mii_phy *phy = &card->phy;
 	u32 advertise = 0;
-	u16 bmcr, bmsr, stat1000, estat;
+	u16 bmsr, estat;
 
-	bmcr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMCR);
-	bmsr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
-	stat1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_STAT1000);
-	estat    = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
+	bmsr  = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+	estat = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
 
 	if (bmsr & BMSR_10HALF)
 		advertise |= ADVERTISED_10baseT_Half;
