From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] pxa168_eth: fix mdiobus_scan() error check
Date: Sat, 30 Apr 2016 23:35:11 +0300
Message-ID: <6024241.YxM8l6DPJo@wasted.cogentembedded.com>
References: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: arnd@arndb.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:35844 "EHLO
	mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750775AbcD3UfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 16:35:15 -0400
Received: by mail-lf0-f49.google.com with SMTP id u64so151698591lff.3
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 13:35:14 -0700 (PDT)
In-Reply-To: <19240252.825Vlx6L0H@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since mdiobus_scan() returns either an error code or NULL on error, the
driver should check  for both,  not only for NULL, otherwise a crash is
imminent...

Reported-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net.git' repo.

 drivers/net/ethernet/marvell/pxa168_eth.c |    2 ++
 1 file changed, 2 insertions(+)

Index: net/drivers/net/ethernet/marvell/pxa168_eth.c
===================================================================
--- net.orig/drivers/net/ethernet/marvell/pxa168_eth.c
+++ net/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -979,6 +979,8 @@ static int pxa168_init_phy(struct net_de
 		return 0;
 
 	pep->phy = mdiobus_scan(pep->smi_bus, pep->phy_addr);
+	if (IS_ERR(pep->phy))
+		return PTR_ERR(pep->phy);
 	if (!pep->phy)
 		return -ENODEV;
 
