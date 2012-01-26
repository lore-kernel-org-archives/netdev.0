From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] e1000e: always set transmit descriptor control registers the same
Date: Wed, 25 Jan 2012 23:21:51 -0800
Message-ID: <1327562515-29664-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17059 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637Ab2AZHWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 02:22:01 -0500
In-Reply-To: <1327562515-29664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The hardware erratum workaround where the TXDCTL register must be the same
setting for both queues should always be done.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index ffe4583..6081dee 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2817,9 +2817,9 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		 */
 		txdctl |= E1000_TXDCTL_DMA_BURST_ENABLE;
 		ew32(TXDCTL(0), txdctl);
-		/* erratum work around: set txdctl the same for both queues */
-		ew32(TXDCTL(1), txdctl);
 	}
+	/* erratum work around: set txdctl the same for both queues */
+	ew32(TXDCTL(1), er32(TXDCTL(0)));
 
 	/* Program the Transmit Control Register */
 	tctl = er32(TCTL);
-- 
1.7.7.6
