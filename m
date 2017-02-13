From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] net: qcom/emac: fix a sizeof() typo
Date: Mon, 13 Feb 2017 14:00:22 +0300
Message-ID: <20170213110021.GA17205@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We had intended to say "sizeof(u32)" but the "u" is missing.
Fortunately, sizeof(32) is also 4, so the original code still works.

Fixes: c4e7beea2192 ("net: qcom/emac: add ethtool support for reading hardware registers")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
index 0d9945fb79be..bbe24639aa5a 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
@@ -227,7 +227,7 @@ static void emac_get_regs(struct net_device *netdev,
 
 static int emac_get_regs_len(struct net_device *netdev)
 {
-	return EMAC_MAX_REG_SIZE * sizeof(32);
+	return EMAC_MAX_REG_SIZE * sizeof(u32);
 }
 
 static const struct ethtool_ops emac_ethtool_ops = {
