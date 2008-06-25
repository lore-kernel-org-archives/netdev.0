From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 3/3] e1000e: fix EEH recovery during reset on PPC
Date: Tue, 24 Jun 2008 17:01:29 -0700
Message-ID: <20080625000120.16592.89100.stgit@localhost.localdomain>
References: <20080625000036.16592.6621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, pl@us.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26978 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbYFYABi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 20:01:38 -0400
In-Reply-To: <20080625000036.16592.6621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEH is not recovering in a reasonable amount of time on PPC during
e1000e_down().

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000e/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index ccb8ca2..0320925 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2535,7 +2535,8 @@ void e1000e_down(struct e1000_adapter *adapter)
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 
-	e1000e_reset(adapter);
+	if (!pci_channel_offline(adapter->pdev))
+		e1000e_reset(adapter);
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
 

