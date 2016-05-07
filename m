From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] pxa168_eth: mdiobus_scan() doesn't return NULL anymore
Date: Sat, 07 May 2016 22:53:40 +0300
Message-ID: <3730936.r1jNy7SQee@wasted.cogentembedded.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35586 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbcEGTxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2016 15:53:45 -0400
Received: by mail-lf0-f45.google.com with SMTP id j8so163531629lfd.2
        for <netdev@vger.kernel.org>; Sat, 07 May 2016 12:53:44 -0700 (PDT)
Received: from wasted.cogentembedded.com ([31.173.81.110])
        by smtp.gmail.com with ESMTPSA id j2sm3734903lfb.13.2016.05.07.12.53.41
        for <netdev@vger.kernel.org>
        (version=TLSv1/SSLv3 cipher=OTHER);
        Sat, 07 May 2016 12:53:42 -0700 (PDT)
In-Reply-To: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that mdiobus_scan() doesn't return NULL on failure anymore, this driver
no  longer needs to check for it...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo.

 drivers/net/ethernet/marvell/pxa168_eth.c |    2 --
 1 file changed, 2 deletions(-)

Index: net-next/drivers/net/ethernet/marvell/pxa168_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/marvell/pxa168_eth.c
+++ net-next/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -981,8 +981,6 @@ static int pxa168_init_phy(struct net_de
 	pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
 	if (IS_ERR(pep->phy))
 		return PTR_ERR(pep->phy);
-	if (!pep->phy)
-		return -ENODEV;
 
 	err = phy_connect_direct(dev, pep->phy, pxa168_eth_adjust_link,
 				 pep->phy_intf);
