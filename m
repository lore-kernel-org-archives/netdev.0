From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/23] igb: use packet buffer sizes from RXPBS
	register
Date: Wed, 28 Oct 2009 02:46:38 -0700
Message-ID: <20091028094637.13156.68551.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:52508
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751339AbZJ1JuV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:50:21 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the configuration for 82576 so that it uses the actual
value of the 82576 rx packet buffer size instead of just assuming the
value.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.h |    2 ++
 drivers/net/igb/e1000_regs.h  |    2 ++
 drivers/net/igb/igb_main.c    |    3 ++-
 3 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index cbe4757..b3808ca 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -228,6 +228,8 @@ struct e1000_adv_tx_context_desc {
 
 #define ALL_QUEUES   0xFFFF
 
+/* RX packet buffer size defines */
+#define E1000_RXPBS_SIZE_MASK_82576  0x0000007F
 void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
 void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 24f2c24..934e03b 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -102,7 +102,9 @@
 #define E1000_ETQF(_n)  (0x05CB0 + (4 * (_n))) /* EType Queue Fltr */
 
 #define E1000_RQDPC(_n) (0x0C030 + ((_n) * 0x40))
+
 /* Split and Replication RX Control - RW */
+#define E1000_RXPBS    0x02404  /* Rx Packet Buffer Size - RW */
 /*
  * Convenience macros
  *
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 7e628ba..2ed2694 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1215,7 +1215,8 @@ void igb_reset(struct igb_adapter *adapter)
 	 */
 	switch (mac->type) {
 	case e1000_82576:
-		pba = E1000_PBA_64K;
+		pba = rd32(E1000_RXPBS);
+		pba &= E1000_RXPBS_SIZE_MASK_82576;
 		break;
 	case e1000_82575:
 	default:

