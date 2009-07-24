From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] fealnx: Write outside array bounds
Date: Fri, 24 Jul 2009 13:49:22 +0200
Message-ID: <4A699FC2.2080407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:42024 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877AbZGXLq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 07:46:57 -0400
Received: by ewy26 with SMTP id 26so1669790ewy.37
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2009 04:46:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phy_idx is checked to be < 4, but np->phys[] is 2 elements long

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
Or should the number of elements be increased?

diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 48385c4..100badd 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -584,7 +584,7 @@ static int __devinit fealnx_init_one(struct pci_dev *pdev,
 	if (np->flags == HAS_MII_XCVR) {
 		int phy, phy_idx = 0;
 
-		for (phy = 1; phy < 32 && phy_idx < 4; phy++) {
+		for (phy = 1; phy < 32 && phy_idx < 2; phy++) {
 			int mii_status = mdio_read(dev, phy, 1);
 
 			if (mii_status != 0xffff && mii_status != 0x0000) {
