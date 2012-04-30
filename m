From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] igbvf: fix the bug when initializing the igbvf
Date: Mon, 30 Apr 2012 16:16:32 -0700
Message-ID: <1335827794-26992-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shan Wei <shanwei88@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Samuel Liao <samuelliao@tencent.com>,
	Shan Wei <davidshan@tencent.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48974 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756932Ab2D3XQg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Apr 2012 19:16:36 -0400
In-Reply-To: <1335827794-26992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei88@gmail.com>

Maybe it's a typo, but it cause that igbvf can't be initialized successfully.
Set perm_addr value using valid dev_addr, although which is equal to hw.mac.addr.

Signed-off-by: Samuel Liao <samuelliao@tencent.com>
Signed-off-by: Shan Wei <davidshan@tencent.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index d61ca2a..8ec74b0 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -2731,14 +2731,14 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 			netdev->addr_len);
 	}
 
-	if (!is_valid_ether_addr(netdev->perm_addr)) {
+	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
 		        netdev->dev_addr);
 		err = -EIO;
 		goto err_hw_init;
 	}
 
-	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
 
 	setup_timer(&adapter->watchdog_timer, &igbvf_watchdog,
 	            (unsigned long) adapter);
-- 
1.7.7.6
