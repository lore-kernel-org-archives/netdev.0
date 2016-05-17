From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: thunderx: avoid null pointer dereference
Date: Tue, 17 May 2016 21:40:38 +0200
Message-ID: <1463514038-9008-1-git-send-email-xypron.glpk@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
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

In function bgx_lmac_handler only use a member of
lmac after checking it is not null.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index d20539a..3ed2198 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -274,12 +274,14 @@ static void bgx_sgmii_change_link_state(struct lmac *lmac)
 static void bgx_lmac_handler(struct net_device *netdev)
 {
 	struct lmac *lmac = container_of(netdev, struct lmac, netdev);
-	struct phy_device *phydev = lmac->phydev;
+	struct phy_device *phydev;
 	int link_changed = 0;
 
 	if (!lmac)
 		return;
 
+	phydev = lmac->phydev;
+
 	if (!phydev->link && lmac->last_link)
 		link_changed = -1;
 
-- 
2.1.4
