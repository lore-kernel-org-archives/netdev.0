From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 13/13] ixgbe: use different context for tso and
	offload
Date: Tue, 26 Aug 2008 04:27:30 -0700
Message-ID: <20080826112730.15787.11063.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:39276 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756337AbYHZL1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:27:30 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099820rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:27:30 -0700 (PDT)
In-Reply-To: <20080826112656.15787.38277.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Change TSO offloads to use a different context than VLAN insertion
and Tx checksumming.  Hardware has separate registers internally for
storing these so use them.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 28d3321..198b9d9 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3126,6 +3126,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		mss_l4len_idx |=
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
+		/* use index 1 for TSO */
+		mss_l4len_idx |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
 
 		tx_buffer_info->time_stamp = jiffies;
@@ -3198,6 +3200,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
+		/* use index zero for tx checksum offload */
 		context_desc->mss_l4len_idx = 0;
 
 		tx_buffer_info->time_stamp = jiffies;
@@ -3306,6 +3309,8 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;
 
+		/* use index 1 context for tso */
+		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;

