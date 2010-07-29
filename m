From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-next 1/4] be2net: fix to correctly know if driver needs
 to run for a VF or a PF
Date: Thu, 29 Jul 2010 21:45:32 +0530
Message-ID: <20100729161522.GA15448@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:17144 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754543Ab0G2QPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jul 2010 12:15:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move be_check_sriov_fn_type to appropriate place to correctly determine
if the be2net driver needs to work as a VF driver or a PF driver.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index d5b097d..e72b482 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1717,10 +1717,11 @@ static void be_msix_enable(struct be_adapter *adapter)
 
 static void be_sriov_enable(struct be_adapter *adapter)
 {
-#ifdef CONFIG_PCI_IOV
-	int status;
 	be_check_sriov_fn_type(adapter);
+#ifdef CONFIG_PCI_IOV
 	if (be_physfn(adapter) && num_vfs) {
+		int status;
+
 		status = pci_enable_sriov(adapter->pdev, num_vfs);
 		adapter->sriov_enabled = status ? false : true;
 	}
-- 
1.7.0.4

