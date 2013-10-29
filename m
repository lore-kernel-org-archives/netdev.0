From: Luka Perkov <luka@openwrt.org>
Subject: [PATCH] net: mvneta: drop redundant mac address check
Date: Tue, 29 Oct 2013 02:29:21 +0100
Message-ID: <1383010161-25854-1-git-send-email-luka@openwrt.org>
Cc: thomas.petazzoni@free-electrons.com, Luka Perkov <luka@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:35792 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757171Ab3J2B3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Oct 2013 21:29:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking if MAC address is valid using is_valid_ether_addr() is already done in
of_get_mac_address().

Signed-off-by: Luka Perkov <luka@openwrt.org>
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
1.8.4.1
