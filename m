From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/8] igb: resolve warning of unused adapter struct
Date: Fri, 13 Mar 2009 23:40:58 -0700
Message-ID: <20090314064058.4052.11753.stgit@lost.foo-projects.org>
References: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:41771
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751090AbZCNGrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 02:47:03 -0400
In-Reply-To: <20090314064020.4052.46249.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

If DCA is undefined then the adapter struct becomes unnecessary.  To
resolve this issue the DCA calls can simply make a call to the adapter
struct through the rx_ring adapter struct member.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 28b22c3..d83d30e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4164,18 +4164,17 @@ static inline void igb_rx_irq_enable(struct igb_ring *rx_ring)
 static int igb_poll(struct napi_struct *napi, int budget)
 {
 	struct igb_ring *rx_ring = container_of(napi, struct igb_ring, napi);
-	struct igb_adapter *adapter = rx_ring->adapter;
 	int work_done = 0;
 
 #ifdef CONFIG_IGB_DCA
-	if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+	if (rx_ring->adapter->flags & IGB_FLAG_DCA_ENABLED)
 		igb_update_rx_dca(rx_ring);
 #endif
 	igb_clean_rx_irq_adv(rx_ring, &work_done, budget);
 
 	if (rx_ring->buddy) {
 #ifdef CONFIG_IGB_DCA
-		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
+		if (rx_ring->adapter->flags & IGB_FLAG_DCA_ENABLED)
 			igb_update_tx_dca(rx_ring->buddy);
 #endif
 		if (!igb_clean_tx_irq(rx_ring->buddy))

