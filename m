From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 5/7] ixgbe: ixgbe_fwd_ring_down needs to be static
Date: Sat, 30 Nov 2013 01:20:19 -0800
Message-ID: <1385803221-3752-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:56959 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988Ab3K3JU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Nov 2013 04:20:27 -0500
In-Reply-To: <1385803221-3752-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

When compiling with -Wstrict-prototypes gcc catches a static
I missed.

./ixgbe_main.c:4254: warning: no previous prototype for 'ixgbe_fwd_ring_down'

Reported-by: Phillip Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0c55079..ad9d670 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4251,8 +4251,8 @@ static void ixgbe_disable_fwd_ring(struct ixgbe_fwd_adapter *vadapter,
 	rx_ring->l2_accel_priv = NULL;
 }
 
-int ixgbe_fwd_ring_down(struct net_device *vdev,
-			struct ixgbe_fwd_adapter *accel)
+static int ixgbe_fwd_ring_down(struct net_device *vdev,
+			       struct ixgbe_fwd_adapter *accel)
 {
 	struct ixgbe_adapter *adapter = accel->real_adapter;
 	unsigned int rxbase = accel->rx_base_queue;
-- 
1.8.3.1
