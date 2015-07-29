From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 11/11] net: thunderx: Fix for crash while BGX teardown
Date: Wed, 29 Jul 2015 16:49:46 +0300
Message-ID: <1438177787-20940-12-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>,
 Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
 David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
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

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

Cortina phy does not have kernel driver and we don't attach
device with phy layer for intefaces like XFI, XLAUI etc,
Hence check for interface type before calling disconnect.

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 633ec05..b961a89 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -673,7 +673,10 @@ static void bgx_lmac_disable(struct bgx *bgx, u8 lmacid)
 	bgx_reg_write(bgx, lmacid, BGX_CMRX_CFG, cmrx_cfg);
 	bgx_flush_dmac_addrs(bgx, lmacid);
 
-	if (lmac->phydev)
+	if ((bgx->lmac_type != BGX_MODE_XFI) &&
+	    (bgx->lmac_type != BGX_MODE_XLAUI) &&
+	    (bgx->lmac_type != BGX_MODE_40G_KR) &&
+	    (bgx->lmac_type != BGX_MODE_10G_KR) && lmac->phydev)
 		phy_disconnect(lmac->phydev);
 
 	lmac->phydev = NULL;
-- 
2.4.6
