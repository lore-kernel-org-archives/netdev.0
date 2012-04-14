From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/6] e100: enable transmit time stamping.
Date: Sat, 14 Apr 2012 02:16:27 -0700
Message-ID: <1334394991-5839-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:45040 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752948Ab2DNJQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 05:16:35 -0400
In-Reply-To: <1334394991-5839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>

This patch enables software (and phy device) transmit time stamping.
Tested on an old PIII laptop with built in NIC.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e100.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index e4d4c17..ada720b 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -1759,6 +1759,7 @@ static void e100_xmit_prepare(struct nic *nic, struct cb *cb,
 		skb->data, skb->len, PCI_DMA_TODEVICE));
 	/* check for mapping failure? */
 	cb->u.tcb.tbd.size = cpu_to_le16(skb->len);
+	skb_tx_timestamp(skb);
 }
 
 static netdev_tx_t e100_xmit_frame(struct sk_buff *skb,
-- 
1.7.7.6
