From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] TG3: &&/|| confusion
Date: Sun, 15 Feb 2009 23:17:56 +0100
Message-ID: <49989494.6010804@gmail.com>
References: <4992AD3A.7000301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:38285 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752691AbZBOWR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 17:17:56 -0500
Received: by ewy14 with SMTP id 14so1687547ewy.13
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2009 14:17:54 -0800 (PST)
In-Reply-To: <4992AD3A.7000301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

phyid Can't be both TG3_PHY_OUI_1 and TG3_PHY_OUI_2 and TG3_PHY_OUI_3.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
// vi drivers/net/tg3.h +2698
#define TG3_PHY_OUI_1                   0x00206000
#define TG3_PHY_OUI_2                   0x0143bc00
#define TG3_PHY_OUI_3                   0x03625c00

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4595962..b080f94 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -2237,8 +2237,8 @@ static int tg3_set_power_state(struct tg3 *tp, pci_power_t state)
 			phyid = phydev->drv->phy_id & phydev->drv->phy_id_mask;
 			if (phyid != TG3_PHY_ID_BCMAC131) {
 				phyid &= TG3_PHY_OUI_MASK;
-				if (phyid == TG3_PHY_OUI_1 &&
-				    phyid == TG3_PHY_OUI_2 &&
+				if (phyid == TG3_PHY_OUI_1 ||
+				    phyid == TG3_PHY_OUI_2 ||
 				    phyid == TG3_PHY_OUI_3)
 					do_low_power = true;
 			}
