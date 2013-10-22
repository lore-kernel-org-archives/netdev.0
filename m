From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 13/15] net: stmmac: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:20:25 +0900
Message-ID: <001301cecede$07f4ac20$17de0460$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Giuseppe Cavallaro' <peppe.cavallaro@st.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:42311 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab3JVEU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:20:26 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV1002ERYPZNKL0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:20:25 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 023b7c2..644d80e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -138,7 +138,6 @@ static void stmmac_pci_remove(struct pci_dev *pdev)
 
 	stmmac_dvr_remove(ndev);
 
-	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, priv->ioaddr);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
1.7.10.4
