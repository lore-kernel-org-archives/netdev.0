From: Laurent Navet <laurent.navet@gmail.com>
Subject: [PATCH] mvneta: remove double validation of mac address
Date: Tue, 29 Oct 2013 22:25:06 +0100
Message-ID: <1383081906-12342-1-git-send-email-laurent.navet@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Laurent Navet <laurent.navet@gmail.com>
To: thomas.petazzoni@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mac address validity is already checked in of_get_mac_address().
No need to do it twice.

Signed-off-by: Laurent Navet <laurent.navet@gmail.com>
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
1.8.4.rc3
