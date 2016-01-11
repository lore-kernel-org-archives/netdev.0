From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v5 05/10] fm10k: add rtnl lock protection in fm10k_io_resume
Date: Mon, 11 Jan 2016 13:17:26 +0100
Message-ID: <1452514651-15445-6-git-send-email-hannes@stressinduktion.org>
References: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48018 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932831AbcAKMRp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 07:17:45 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 8472720915
	for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 07:17:44 -0500 (EST)
In-Reply-To: <1452514651-15445-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4eb7a6fa6b0ddc..7dd55067d8912e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2350,8 +2350,10 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reset clock */
 	fm10k_ts_reset(interface);
 
+	rtnl_lock();
 	if (netif_running(netdev))
 		err = fm10k_open(netdev);
+	rtnl_unlock();
 
 	/* final check of hardware state before registering the interface */
 	err = err ? : fm10k_hw_ready(interface);
-- 
2.5.0
