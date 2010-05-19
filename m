From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/7] ixgbe: fix ixgbe_tx_is_paused logic
Date: Tue, 18 May 2010 19:00:10 -0700
Message-ID: <20100519020010.18654.48130.stgit@localhost.localdomain>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta15.emeryville.ca.mail.comcast.net ([76.96.27.228]:60255
	"EHLO qmta15.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752859Ab0ESCAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:11 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

The TFCS bits show the current XON state.  Meaning that the
device is paused if these bits are 0.  This fixes the logic
to work as it was intended.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f0f7329..d80bb1a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -625,16 +625,16 @@ static void ixgbe_unmap_and_free_tx_resource(struct ixgbe_adapter *adapter,
 }
 
 /**
- * ixgbe_tx_is_paused - check if the tx ring is paused
+ * ixgbe_tx_xon_state - check the tx ring xon state
  * @adapter: the ixgbe adapter
  * @tx_ring: the corresponding tx_ring
  *
  * If not in DCB mode, checks TFCS.TXOFF, otherwise, find out the
  * corresponding TC of this tx_ring when checking TFCS.
  *
- * Returns : true if paused
+ * Returns : true if in xon state (currently not paused)
  */
-static inline bool ixgbe_tx_is_paused(struct ixgbe_adapter *adapter,
+static inline bool ixgbe_tx_xon_state(struct ixgbe_adapter *adapter,
                                       struct ixgbe_ring *tx_ring)
 {
 	u32 txoff = IXGBE_TFCS_TXOFF;
@@ -690,7 +690,7 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	adapter->detect_tx_hung = false;
 	if (tx_ring->tx_buffer_info[eop].time_stamp &&
 	    time_after(jiffies, tx_ring->tx_buffer_info[eop].time_stamp + HZ) &&
-	    !ixgbe_tx_is_paused(adapter, tx_ring)) {
+	    ixgbe_tx_xon_state(adapter, tx_ring)) {
 		/* detected Tx unit hang */
 		union ixgbe_adv_tx_desc *tx_desc;
 		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);

