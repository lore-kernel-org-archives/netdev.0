From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] fm10k: don't use BIT() macro where the value isn't a bitmask
Date: Wed, 29 Jun 2016 14:32:48 -0700
Message-ID: <1467235982-55437-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3817 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728AbcF2VdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:06 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The FM10K_MAX_DATA_PER_TXD is really just using a bitshift as a power of
2 operation in an efficient manner. We shouldn't represent this as a BIT()
because that obscures the intention of the operation.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index fcf106e..e98b86b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -406,7 +406,7 @@ static inline u16 fm10k_desc_unused(struct fm10k_ring *ring)
 	 (&(((union fm10k_rx_desc *)((R)->desc))[i]))
 
 #define FM10K_MAX_TXD_PWR	14
-#define FM10K_MAX_DATA_PER_TXD	BIT(FM10K_MAX_TXD_PWR)
+#define FM10K_MAX_DATA_PER_TXD	(1u << FM10K_MAX_TXD_PWR)
 
 /* Tx Descriptors needed, worst case */
 #define TXD_USE_COUNT(S)	DIV_ROUND_UP((S), FM10K_MAX_DATA_PER_TXD)
-- 
2.5.5
