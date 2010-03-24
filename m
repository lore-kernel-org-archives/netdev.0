From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: cleanup maximum number of tx queues
Date: Wed, 24 Mar 2010 13:01:45 -0700
Message-ID: <20100324200144.6384.17291.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:56270
	"EHLO qmta10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753992Ab0CXUCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:02:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

In the last patch I missed an unecessary min_t comparison.
This patch removes it, the path allocates at most
72 tx queues for 82599 and 24 for 82598 there is no need
for this check.

Additionally this sets MAX_[TX|RX]_QUEUES to 72.  Which is
used as the size for the tx/rx_ring arrays. There is no
reason to have more tx_rings/rx_rings then num_tx_queues.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    7 +++++--
 drivers/net/ixgbe/ixgbe_main.c |    1 -
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 19e94ee..79c35ae 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -204,14 +204,17 @@ enum ixgbe_ring_f_enum {
 #define IXGBE_MAX_FDIR_INDICES 64
 #ifdef IXGBE_FCOE
 #define IXGBE_MAX_FCOE_INDICES  8
+#define MAX_RX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDICES)
+#define MAX_TX_QUEUES (IXGBE_MAX_FDIR_INDICES + IXGBE_MAX_FCOE_INDICES)
+#else
+#define MAX_RX_QUEUES IXGBE_MAX_FDIR_INDICES
+#define MAX_TX_QUEUES IXGBE_MAX_FDIR_INDICES
 #endif /* IXGBE_FCOE */
 struct ixgbe_ring_feature {
 	int indices;
 	int mask;
 } ____cacheline_internodealigned_in_smp;
 
-#define MAX_RX_QUEUES 128
-#define MAX_TX_QUEUES 128
 
 #define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
                               ? 8 : 1)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 315622f..a9147e5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6041,7 +6041,6 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	indices += min_t(unsigned int, num_possible_cpus(),
 			 IXGBE_MAX_FCOE_INDICES);
 #endif
-	indices = min_t(unsigned int, indices, MAX_TX_QUEUES);
 	netdev = alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indices);
 	if (!netdev) {
 		err = -ENOMEM;

