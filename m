From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 07/14] Fix intel/ixgbe
Date: Tue, 19 Jun 2012 18:14:01 +0300
Message-ID: <1340118848-30978-8-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3913 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:33 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index af1a531..21e4513 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -802,7 +802,8 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * The default is to use pairs of vectors.
 	 */
 	v_budget = max(adapter->num_rx_queues, adapter->num_tx_queues);
-	v_budget = min_t(int, v_budget, num_online_cpus());
+	v_budget = min_t(int, v_budget, min_t(int, num_online_cpus(),
+					      DEFAULT_MAX_NUM_RSS_QUEUES));
 	v_budget += NON_Q_VECTORS;
 
 	/*
-- 
1.7.9.rc2
