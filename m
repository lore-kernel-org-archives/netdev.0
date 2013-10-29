From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH v2] mvneta: drop redundant mac address check
Date: Wed, 30 Oct 2013 00:10:01 +0100
Message-ID: <1383088201-25136-1-git-send-email-luka@openwrt.org>
Cc: Luka Perkov <luka@openwrt.org>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:33298 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751606Ab3J2XKg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 19:10:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address().

Signed-off-by: Luka Perkov <luka@openwrt.org>
Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
CC: David Miller <davem@davemloft.net>
---
v1->v2:

 * cosmetic commit message fix based on comment from David Miller
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e35bac7..7d99e695 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2811,7 +2811,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	}
 
 	dt_mac_addr = of_get_mac_address(dn);
-	if (dt_mac_addr && is_valid_ether_addr(dt_mac_addr)) {
+	if (dt_mac_addr) {
 		mac_from = "device tree";
 		memcpy(dev->dev_addr, dt_mac_addr, ETH_ALEN);
 	} else {
-- 
1.8.4.2
