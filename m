From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] tulip: Read buffer overflow
Date: Sun, 02 Aug 2009 08:26:52 +0200
Message-ID: <4A7531AC.4090400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: grundler@parisc-linux.org, kyle@mcmartin.ca,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f214.google.com ([209.85.219.214]:65494 "EHLO
	mail-ew0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbZHBGXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:23:42 -0400
Received: by ewy10 with SMTP id 10so2353783ewy.37
        for <netdev@vger.kernel.org>; Sat, 01 Aug 2009 23:23:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check whether index is within bounds before testing the element.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/tulip/de4x5.c b/drivers/net/tulip/de4x5.c
index eb72d2e..acfdccd 100644
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -5059,7 +5059,7 @@ mii_get_phy(struct net_device *dev)
 	if ((id == 0) || (id == 65535)) continue;  /* Valid ID? */
 	for (j=0; j<limit; j++) {                  /* Search PHY table */
 	    if (id != phy_info[j].id) continue;    /* ID match? */
-	    for (k=0; lp->phy[k].id && (k < DE4X5_MAX_PHY); k++);
+	    for (k=0; k < DE4X5_MAX_PHY && lp->phy[k].id; k++);
 	    if (k < DE4X5_MAX_PHY) {
 		memcpy((char *)&lp->phy[k],
 		       (char *)&phy_info[j], sizeof(struct phy_table));
@@ -5072,7 +5072,7 @@ mii_get_phy(struct net_device *dev)
 	    break;
 	}
 	if ((j == limit) && (i < DE4X5_MAX_MII)) {
-	    for (k=0; lp->phy[k].id && (k < DE4X5_MAX_PHY); k++);
+	    for (k=0; k < DE4X5_MAX_PHY && lp->phy[k].id; k++);
 	    lp->phy[k].addr = i;
 	    lp->phy[k].id = id;
 	    lp->phy[k].spd.reg = GENERIC_REG;      /* ANLPA register         */
@@ -5091,7 +5091,7 @@ mii_get_phy(struct net_device *dev)
   purgatory:
     lp->active = 0;
     if (lp->phy[0].id) {                           /* Reset the PHY devices */
-	for (k=0; lp->phy[k].id && (k < DE4X5_MAX_PHY); k++) { /*For each PHY*/
+	for (k=0; k < DE4X5_MAX_PHY && lp->phy[k].id; k++) { /*For each PHY*/
 	    mii_wr(MII_CR_RST, MII_CR, lp->phy[k].addr, DE4X5_MII);
 	    while (mii_rd(MII_CR, lp->phy[k].addr, DE4X5_MII) & MII_CR_RST);
 
