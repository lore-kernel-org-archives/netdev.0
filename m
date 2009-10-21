From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Make queue pairs on single MSI-X
	interrupts
Date: Tue, 20 Oct 2009 19:27:34 -0700
Message-ID: <20091021022733.32449.73506.stgit@localhost.localdomain>
References: <20091021022626.32449.73883.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:47977
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753060AbZJUCaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 22:30:35 -0400
In-Reply-To: <20091021022626.32449.73883.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch pairs similar-numbered Rx and Tx queues onto a single
MSI-X vector.  For example, Tx queue 0 and Rx queue 0's interrupt
with be ethX-RxTx-0.  This allows for more efficient cleanup, since
fewer interrupts will be firing during device operation.  It also
helps with a cleaner CPU affinity for IRQ affinity.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d2280c3..00b6829 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3579,10 +3579,10 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	 * It's easy to be greedy for MSI-X vectors, but it really
 	 * doesn't do us much good if we have a lot more vectors
 	 * than CPU's.  So let's be conservative and only ask for
-	 * (roughly) twice the number of vectors as there are CPU's.
+	 * (roughly) the same number of vectors as there are CPU's.
 	 */
 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
-	               (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
+	               (int)num_online_cpus()) + NON_Q_VECTORS;
 
 	/*
 	 * At the same time, hardware can only support a maximum of

