From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH net-next] net: bgmac: make it clear when setting interface type to RMII
Date: Wed, 17 Aug 2016 23:11:52 +0200
Message-ID: <1471468315-20574-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jon Mason <jon.mason@broadcom.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Philippe Reynes <tremyfr@gmail.com>,
	linux-kernel@vger.kernel.org (open list)
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

It doesn't really change anything as BGMAC_CHIPCTL_1_IF_TYPE_RMII is
equal to 0. It make code a bit clener, so far when reading it one could
think we forgot to set a proper mode. It also keeps this mode code in
sync with other ones.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/ethernet/broadcom/bgmac.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 63ef7235..6ea0e5f 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -932,7 +932,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			et_swtype <<= 4;
 			sw_type = et_swtype;
 		} else if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_EPHYRMII) {
-			sw_type = BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
+			sw_type = BGMAC_CHIPCTL_1_IF_TYPE_RMII |
+				  BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
 		} else if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_RGMII) {
 			sw_type = BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
 				  BGMAC_CHIPCTL_1_SW_TYPE_RGMII;
-- 
1.8.4.5
