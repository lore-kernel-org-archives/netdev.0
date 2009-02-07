From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 24/26] igb: fix two minor items found during code
	review
Date: Sat, 07 Feb 2009 01:22:52 -0800
Message-ID: <20090207092252.15697.63031.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:44875
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752545AbZBGJXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:23:12 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch addresses two minor items I found while cleaning up the igb
driver for our sourceforge version.

The first clears the context index if we don't flag that we need it.

The second item is that eims_other should be used instead of bit defines
when setting all of the EICS bits prior to reset.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 88f135f..6713840 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2771,6 +2771,8 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		if (adapter->flags & IGB_FLAG_NEED_CTX_IDX)
 			context_desc->mss_l4len_idx =
 				cpu_to_le32(tx_ring->queue_index << 4);
+		else
+			context_desc->mss_l4len_idx = 0;
 
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
@@ -3040,8 +3042,8 @@ static void igb_tx_timeout(struct net_device *netdev)
 	/* Do the reset outside of interrupt context */
 	adapter->tx_timeout_count++;
 	schedule_work(&adapter->reset_task);
-	wr32(E1000_EICS, adapter->eims_enable_mask &
-		~(E1000_EIMS_TCP_TIMER | E1000_EIMS_OTHER));
+	wr32(E1000_EICS,
+	     (adapter->eims_enable_mask & ~adapter->eims_other));
 }
 
 static void igb_reset_task(struct work_struct *work)

