From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/15] fm10k: use napi_schedule_irqoff()
Date: Wed, 25 Nov 2015 10:21:05 -0800
Message-ID: <1448475679-57194-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:36304 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750964AbbKYSVW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Nov 2015 13:21:22 -0500
In-Reply-To: <1448475679-57194-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The fm10k_msix_clean_rings function runs from hard interrupt context or
with interrupts already disabled in netpoll.

It can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 74be792..5fbffba 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -846,7 +846,7 @@ static irqreturn_t fm10k_msix_clean_rings(int __always_unused irq, void *data)
 	struct fm10k_q_vector *q_vector = data;
 
 	if (q_vector->rx.count || q_vector->tx.count)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.5.0
