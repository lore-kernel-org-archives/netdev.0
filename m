From: Viresh Kumar <viresh.kumar@st.com>
Subject: [PATCH] stmmac: fix kernel crash when device probed for SPEAr with DT
Date: Tue, 17 Apr 2012 14:54:00 +0530
Message-ID: <91ea900ce78bb2054d83e0575c16ac70f3f11511.1334654597.git.viresh.kumar@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <spear-devel@list.st.com>, <viresh.linux@gmail.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>,
	Viresh Kumar <viresh.kumar@st.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:33352 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932070Ab2DQJi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 05:38:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

plat->dma_cfg is never allocated memory and is tried to be filled when we boot
it for SPEAr SoCs with DT. And so get a kernel crash.

Fix it by allocating memory for dma_cfg.

Signed-off-by: Viresh Kumar <viresh.kumar@st.com>
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 12bd221..f124f60 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -110,6 +110,14 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 			goto out_unmap;
 		}
 
+		plat_dat->dma_cfg = devm_kzalloc(&pdev->dev,
+				sizeof(*plat_dat->dma_cfg), GFP_KERNEL);
+		if (!plat_dat->dma_cfg) {
+			pr_err("%s: ERROR: no memory for dma_cfg", __func__);
+			ret = -ENOMEM;
+			goto out_unmap;
+		}
+
 		ret = stmmac_probe_config_dt(pdev, plat_dat, &mac);
 		if (ret) {
 			pr_err("%s: main dt probe failed", __func__);
-- 
1.7.9
