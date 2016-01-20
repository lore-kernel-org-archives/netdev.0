From: Jisheng Zhang <jszhang@marvell.com>
Subject: [PATCH 2/4] net: mvneta: Try to get named core clock first
Date: Wed, 20 Jan 2016 16:06:21 +0800
Message-ID: <1453277183-5412-3-git-send-email-jszhang@marvell.com>
References: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <sebastian.hesselbarth@gmail.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Jisheng Zhang <jszhang@marvell.com>
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
	<mw@semihalf.com>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:12643 "EHLO
	mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933745AbcATIKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 03:10:49 -0500
In-Reply-To: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides "core" clk for the mac core, and "axi"
clk for the AXI bus logic.

To support for more than one clock, we'll need to distinguish between
the clock by name. Change clock probing to first try to get "core"
clock before falling back to unnamed clock.

Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 79e0c7d..aca0a73 100644
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
