From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH v3 2/4] net: mvneta: Try to get named core clock first
Date: Wed, 20 Jan 2016 19:27:23 +0800
Message-ID: <1453289245-2061-3-git-send-email-jszhang@marvell.com>
References: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, devicetree@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1453289245-2061-1-git-send-email-jszhang@marvell.com>
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

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides one clk for the mac core, and one
clk for the AXI bus logic.

To support for more than one clock, we'll need to distinguish between
the clock by name. Change clock probing to first try to get "core"
clock before falling back to unnamed clock.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 8e85a53..736a9ec 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3605,7 +3605,9 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp->indir[0] = rxq_def;
 
-	pp->clk = devm_clk_get(&pdev->dev, NULL);
+	pp->clk = devm_clk_get(&pdev->dev, "core");
+	if (IS_ERR(pp->clk))
+		pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
 		err = PTR_ERR(pp->clk);
 		goto err_put_phy_node;
-- 
2.7.0.rc3
