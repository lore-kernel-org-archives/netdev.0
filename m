From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 5/8] fm10k: add rtnl lock protection in fm10k_io_resume
Date: Thu,  7 Jan 2016 00:39:28 +0100
Message-ID: <1452123571-19140-6-git-send-email-hannes@stressinduktion.org>
References: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38506 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515AbcAFXjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 18:39:48 -0500
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id CC26C20971
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 18:39:47 -0500 (EST)
In-Reply-To: <1452123571-19140-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4eb7a6fa6b0ddc..846d9b731c8c14 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2350,8 +2350,10 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reset clock */
 	fm10k_ts_reset(interface);
 
+	rtnl_lock();
 	if (netif_running(netdev))
 		err = fm10k_open(netdev);
+	rtnl_lock();
 
 	/* final check of hardware state before registering the interface */
 	err = err ? : fm10k_hw_ready(interface);
-- 
2.5.0
