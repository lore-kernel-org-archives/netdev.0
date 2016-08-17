From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net] net: bgmac: fix reversed check for MII registration error
Date: Wed, 17 Aug 2016 15:37:14 +0200
Message-ID: <1471441051-2130-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
	Arnd Bergmann <arnd@arndb.de>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Mason <jon.mason@broadcom.com>,
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

It was failing on successful registration returning meaningless errors.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
Fixes: 55954f3bfdac ("net: ethernet: bgmac: move BCMA MDIO Phy code into a separate file")
---
This fix is intendent for net repository (4.8 release).
---
 drivers/net/ethernet/broadcom/bgmac-bcma.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac-bcma.c b/drivers/net/ethernet/broadcom/bgmac-bcma.c
index 9a9745c4..625235d 100644
--- a/drivers/net/ethernet/broadcom/bgmac-bcma.c
+++ b/drivers/net/ethernet/broadcom/bgmac-bcma.c
@@ -159,7 +159,7 @@ static int bgmac_probe(struct bcma_device *core)
 
 	if (!bgmac_is_bcm4707_family(core)) {
 		mii_bus = bcma_mdio_mii_register(core, bgmac->phyaddr);
-		if (!IS_ERR(mii_bus)) {
+		if (IS_ERR(mii_bus)) {
 			err = PTR_ERR(mii_bus);
 			goto err;
 		}
-- 
1.8.4.5
