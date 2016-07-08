From: Colin King <colin.king@canonical.com>
Subject: [PATCH] bnxt_en: initialize rc to zero to avoid returning garbage
Date: Fri,  8 Jul 2016 16:42:48 +0100
Message-ID: <1467992568-1990-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Rob Swindell <rob.swindell@broadcom.com>,
	Satish Baddipadige <sbaddipa@broadcom.com>,
	Ajit Khaparde <ajit.khaparde@broadcom.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

rc is not initialized so it can contain garbage if it is not
set by the call to bnxt_read_sfp_module_eeprom_info. Ensure
garbage is not returned by initializing rc to 0.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 0f7dd86..64466f5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1684,7 +1684,7 @@ static int bnxt_get_module_eeprom(struct net_device *dev,
 {
 	struct bnxt *bp = netdev_priv(dev);
 	u16  start = eeprom->offset, length = eeprom->len;
-	int rc;
+	int rc = 0;
 
 	memset(data, 0, eeprom->len);
 
-- 
2.8.1
