From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/5] ixgbe: Typecase '1' for 64 bit shift
Date: Thu, 07 May 2009 13:40:15 -0700
Message-ID: <20090507204015.19886.92292.stgit@localhost.localdomain>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:49260 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761256AbZEGUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:40:33 -0400
In-Reply-To: <20090507203854.19886.54737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nelson, Shannon <shannon.nelson@intel.com>

Make sure we don't get any sign-extend issues when we shift a 1
into bit 31.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4a316e9..efb175b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1307,7 +1307,7 @@ static inline void map_vector_to_rxq(struct ixgbe_adapter *a, int v_idx,
 
 	set_bit(r_idx, q_vector->rxr_idx);
 	q_vector->rxr_count++;
-	a->rx_ring[r_idx].v_idx = 1 << v_idx;
+	a->rx_ring[r_idx].v_idx = (u64)1 << v_idx;
 }
 
 static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
@@ -1317,7 +1317,7 @@ static inline void map_vector_to_txq(struct ixgbe_adapter *a, int v_idx,
 
 	set_bit(t_idx, q_vector->txr_idx);
 	q_vector->txr_count++;
-	a->tx_ring[t_idx].v_idx = 1 << v_idx;
+	a->tx_ring[t_idx].v_idx = (u64)1 << v_idx;
 }
 
 /**
@@ -4057,7 +4057,7 @@ static void ixgbe_watchdog(unsigned long data)
 		int i;
 
 		for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++)
-			eics |= (1 << i);
+			eics |= ((u64)1 << i);
 
 		/* Cause software interrupt to ensure rx rings are cleaned */
 		switch (hw->mac.type) {

