From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH v4 7/7] dpaa_eth: check allocation result
Date: Sun, 27 Aug 2017 16:13:43 +0300
Message-ID: <1503839623-3906-8-git-send-email-madalin.bucur@nxp.com>
References: <1503839623-3906-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0081.outbound.protection.outlook.com ([104.47.38.81]:42368
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751504AbdH0NN7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 09:13:59 -0400
In-Reply-To: <1503839623-3906-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 73ca8d7..4225806 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -2561,6 +2561,9 @@ static struct dpaa_bp *dpaa_bp_alloc(struct device *dev)
 
 	dpaa_bp->bpid = FSL_DPAA_BPID_INV;
 	dpaa_bp->percpu_count = devm_alloc_percpu(dev, *dpaa_bp->percpu_count);
+	if (!dpaa_bp->percpu_count)
+		return ERR_PTR(-ENOMEM);
+
 	dpaa_bp->config_count = FSL_DPAA_ETH_MAX_BUF_COUNT;
 
 	dpaa_bp->seed_cb = dpaa_bp_seed;
-- 
2.1.0
