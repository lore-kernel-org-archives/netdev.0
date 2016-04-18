From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 2/7] fm10k: protect fm10k_open in fm10k_io_resume with rtnl_lock
Date: Mon, 18 Apr 2016 21:19:43 +0200
Message-ID: <1461007188-1603-3-git-send-email-hannes@stressinduktion.org>
References: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:55889 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbcDRTUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:20:01 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0568A20EF7
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:20:01 -0400 (EDT)
In-Reply-To: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fm10k_open requires rtnl_lock to be held.

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index f0992950e228eb..04304d9a633935 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -2362,8 +2362,10 @@ static void fm10k_io_resume(struct pci_dev *pdev)
 	/* reset clock */
 	fm10k_ts_reset(interface);
 
+	rtnl_lock();
 	if (netif_running(netdev))
 		err = fm10k_open(netdev);
+	rtnl_unlock();
 
 	/* final check of hardware state before registering the interface */
 	err = err ? : fm10k_hw_ready(interface);
-- 
2.5.5
