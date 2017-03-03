From: sunil.kovvuri@gmail.com
Subject: [PATCH 2/4] net: thunderx: Fix LMAC mode debug prints for QSGMII mode
Date: Fri,  3 Mar 2017 16:17:48 +0530
Message-ID: <1488538070-12549-3-git-send-email-sunil.kovvuri@gmail.com>
References: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

When BGX/LMACs are in QSGMII mode, for some LMACs, mode info is
not being printed. This patch will fix that. With changes already
done to not do any sort of serdes 2 lane mapping config calculation
in kernel driver, we can get rid of this logic.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 4c8e8cf..9b8a53e 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -1011,12 +1011,6 @@ static void bgx_print_qlm_mode(struct bgx *bgx, u8 lmacid)
 			dev_info(dev, "%s: 40G_KR4\n", (char *)str);
 		break;
 	case BGX_MODE_QSGMII:
-		if ((lmacid == 0) &&
-		    (bgx_get_lane2sds_cfg(bgx, lmac) != lmacid))
-			return;
-		if ((lmacid == 2) &&
-		    (bgx_get_lane2sds_cfg(bgx, lmac) == lmacid))
-			return;
 		dev_info(dev, "%s: QSGMII\n", (char *)str);
 		break;
 	case BGX_MODE_RGMII:
-- 
2.7.4
