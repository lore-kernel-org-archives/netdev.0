From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next] bnx2x: fix a power state test
Date: Sun, 2 Jun 2013 12:02:26 +0300
Message-ID: <1370163746-30745-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3935 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302Ab3FBJCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jun 2013 05:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If PCIe supports PM capabilities, bnx2x will always claim eeprom is accessible
as PCI_D0 is zero.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 263950c..04a2ad5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1391,7 +1391,8 @@ static bool bnx2x_is_nvm_accessible(struct bnx2x *bp)
 		rc = pci_read_config_word(bp->pdev,
 					  bp->pm_cap + PCI_PM_CTRL, &pm);
 
-	if ((rc && !netif_running(dev)) || (!rc && ((pm & PCI_D0) != PCI_D0)))
+	if ((rc && !netif_running(dev)) ||
+	    (!rc && ((pm & PCI_PM_CTRL_STATE_MASK) != PCI_D0)))
 		return false;
 
 	return true;
-- 
1.8.1.227.g44fe835
