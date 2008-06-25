From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/3] igb: fix EEH recovery during reset on PPC
Date: Tue, 24 Jun 2008 17:01:15 -0700
Message-ID: <20080625000103.16592.30534.stgit@localhost.localdomain>
References: <20080625000036.16592.6621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pl@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53376 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752714AbYFYAB0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 20:01:26 -0400
In-Reply-To: <20080625000036.16592.6621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEH is not recovering in a reasonable amount of time on PPC during
igb_down().

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/igb/igb_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7b6b780..6f1ad53 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -718,7 +718,8 @@ void igb_down(struct igb_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
-	igb_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		igb_reset(adapter);
 	igb_clean_all_tx_rings(adapter);
 	igb_clean_all_rx_rings(adapter);
 }

