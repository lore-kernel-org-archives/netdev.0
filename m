From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 11/36] ixgbe,rcu: convert call_rcu(ring_free_rcu) to kfree_rcu()
Date: Fri, 18 Mar 2011 11:57:21 +0800
Message-ID: <4D82D821.1070101@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@elte.hu>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51855 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S932131Ab1CRDzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 23:55:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The rcu callback ring_free_rcu() just calls a kfree(),
so we use kfree_rcu() instead of the call_rcu(ring_free_rcu).

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 30f9ccf..3e7fff5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5003,11 +5003,6 @@ err_set_interrupt:
 	return err;
 }
 
-static void ring_free_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct ixgbe_ring, rcu));
-}
-
 /**
  * ixgbe_clear_interrupt_scheme - Clear the current interrupt scheme settings
  * @adapter: board private structure to clear interrupt scheme on
@@ -5029,7 +5024,7 @@ void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter)
 		/* ixgbe_get_stats64() might access this ring, we must wait
 		 * a grace period before freeing it.
 		 */
-		call_rcu(&ring->rcu, ring_free_rcu);
+		kfree_rcu(ring, rcu);
 		adapter->rx_ring[i] = NULL;
 	}
 
-- 
1.7.4
