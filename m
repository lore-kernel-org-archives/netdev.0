From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] ucc_geth: use of_get_mac_address()
Date: Wed, 21 Feb 2007 14:40:12 -0600
Message-ID: <11720904121560-git-send-email-timur@freescale.com>
Cc: Timur Tabi <timur@freescale.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw01.freescale.net ([192.88.165.102]:63019 "EHLO
	de01egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbXBUUkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Feb 2007 15:40:25 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update ucc_geth_probe() to use function of_get_mac_address() to obtain the MAC
address.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ucc_geth.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index a2fc2bb..885e73d 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -4199,9 +4199,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	ugeth->ug_info = ug_info;
 	ugeth->dev = dev;
 
-	mac_addr = get_property(np, "mac-address", NULL);
-	if (mac_addr == NULL)
-		mac_addr = get_property(np, "local-mac-address", NULL);
+	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
 		memcpy(dev->dev_addr, mac_addr, 6);
 
-- 
1.5.0

