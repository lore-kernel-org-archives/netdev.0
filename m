From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] ixgbe/ixgbevf: use napi_schedule_irqoff()
Date: Mon, 23 Nov 2015 11:36:11 -0800
Message-ID: <1448307376-20063-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44986 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754796AbbKWTgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:25 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>

The ixgbe_intr and ixgbe/ixgbevf_msix_clean_rings functions run from hard
interrupt context or with interrupts already disabled in netpoll.

They can use napi_schedule_irqoff() instead of napi_schedule()

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 4fa94a3..c95042e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2754,7 +2754,7 @@ static irqreturn_t ixgbe_msix_clean_rings(int irq, void *data)
 	/* EIAM disabled interrupts (on this vector) for us */
 
 	if (q_vector->rx.ring || q_vector->tx.ring)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
@@ -2948,7 +2948,7 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 		ixgbe_ptp_check_pps_event(adapter, eicr);
 
 	/* would disable interrupts here but EIAM disabled it */
-	napi_schedule(&q_vector->napi);
+	napi_schedule_irqoff(&q_vector->napi);
 
 	/*
 	 * re-enable link(maybe) and non-queue interrupts, no flush.
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index e678178..1b15f95 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1288,7 +1288,7 @@ static irqreturn_t ixgbevf_msix_clean_rings(int irq, void *data)
 
 	/* EIAM disabled interrupts (on this vector) for us */
 	if (q_vector->rx.ring || q_vector->tx.ring)
-		napi_schedule(&q_vector->napi);
+		napi_schedule_irqoff(&q_vector->napi);
 
 	return IRQ_HANDLED;
 }
-- 
2.5.0
