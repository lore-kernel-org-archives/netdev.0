From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] stmmac: don't return zero on failure path in stmmac_pci_probe()
Date: Sat,  2 Feb 2013 02:09:19 +0400
Message-ID: <1359756559-20211-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If stmmac_dvr_probe() fails in stmmac_pci_probe(), it breaks off initialization,
deallocates all resources, but returns zero.
The patch adds -ENODEV as return value in this case.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 064eaac..19b3a25 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -102,6 +102,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
 	if (!priv) {
 		pr_err("%s: main driver probe failed", __func__);
+		ret = -ENODEV;
 		goto err_out;
 	}
 	priv->dev->irq = pdev->irq;
-- 
1.7.9.5
