From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.26] ucc_geth: Fix sneaky merge conflict regarding bus_id
Date: Wed, 23 Apr 2008 16:56:17 -0500
Message-ID: <1208987777-17502-1-git-send-email-afleming@freescale.com>
Cc: bunk@kernel.org, netdev@vger.kernel.org,
	Andy Fleming <afleming@freescale.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:36076 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbYDWV4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 17:56:21 -0400
Received: from az33smr01.freescale.net (az33smr01.freescale.net [10.64.34.199])
	by az33egw02.freescale.net (8.12.11/az33egw02) with ESMTP id m3NLuINJ018435
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 14:56:18 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by az33smr01.freescale.net (8.13.1/8.13.0) with ESMTP id m3NLuHu8024562
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 16:56:17 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch that changed mdio_bus to a string didn't conflict strongly enough
with the patch that added fixed PHY support to UCC.  Gather it back into
the fold.

Fixes this error:
...
 CC      drivers/net/ucc_geth.o
 'ucc_geth_probe':
 /home/bunk/linux/kernel-2.6/git/linux-2.6/drivers/net/ucc_geth.c:3935: error:
 incompatible types in assignment
 make[3]: *** [drivers/net/ucc_geth.o] Error 1

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/ucc_geth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 2f11254..281ce3d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3932,7 +3932,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
 	fixed_link = of_get_property(np, "fixed-link", NULL);
 	if (fixed_link) {
-		ug_info->mdio_bus = 0;
+		snprintf(ug_info->mdio_bus, MII_BUS_ID_SIZE, "0");
 		ug_info->phy_address = fixed_link[0];
 		phy = NULL;
 	} else {
-- 
1.5.4.GIT

