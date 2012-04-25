From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] e1000e: MSI interrupt test failed, using legacy interrupt
Date: Tue, 24 Apr 2012 22:55:13 -0700
Message-ID: <1335333314-6814-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Prasanna S Panchamukhi <ppanchamukhi@riverbed.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63052 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758908Ab2DYFzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 01:55:17 -0400
In-Reply-To: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasanna S Panchamukhi <ppanchamukhi@riverbed.com>

Following logs where seen on Systems with multiple NICs,
while using MSI interrupts as shown below:

Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0d.0: lan0_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: wan0_1: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.notice kernel: 0000:40:0d.0: lan0_1: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:32 (none) user.warn kernel: 0000:40:0e.0: wan4_0: MSI interrupt
test failed, using legacy interrupt.
Feb 16 15:09:32 (none) user.notice kernel: 0000:00:0e.0: wan1_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0e.0: lan1_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: wan2_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:00:0f.0: lan2_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: wan3_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:33 (none) user.notice kernel: 0000:40:0a.0: lan3_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0e.0: lan4_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: wan5_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX
Feb 16 15:09:34 (none) user.notice kernel: 0000:40:0f.0: lan5_0: NIC Link is Up
1000 Mbps Full Duplex, Flow Control: RX/TX

This patch fixes this problem by increasing the msleep from 50 to 100.

Signed-off-by: Prasanna S Panchamukhi <ppanchamukhi@riverbed.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 19ab215..9520a6a 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3799,7 +3799,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 	/* fire an unusual interrupt on the test handler */
 	ew32(ICS, E1000_ICS_RXSEQ);
 	e1e_flush();
-	msleep(50);
+	msleep(100);
 
 	e1000_irq_disable(adapter);
 
-- 
1.7.7.6
