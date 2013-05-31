From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] bnx2x: fix a power state test
Date: Fri, 31 May 2013 13:07:19 +0300
Message-ID: <20130531075840.GA28370@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20712 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab3EaKHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 06:07:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PCI_D0 is zero so the original test is never true.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I don't have the hardware to test this, and I'm not positive on it.
Buyer beware!

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 263950c..a9a1609 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1391,7 +1391,7 @@ static bool bnx2x_is_nvm_accessible(struct bnx2x *bp)
 		rc = pci_read_config_word(bp->pdev,
 					  bp->pm_cap + PCI_PM_CTRL, &pm);
 
-	if ((rc && !netif_running(dev)) || (!rc && ((pm & PCI_D0) != PCI_D0)))
+	if ((rc && !netif_running(dev)) || (!rc && pm != PCI_D0))
 		return false;
 
 	return true;
