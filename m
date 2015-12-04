From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] fm10k: change default Tx ITR to 25usec
Date: Thu,  3 Dec 2015 16:29:52 -0800
Message-ID: <1449188994-64940-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22000 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754408AbbLDA37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:59 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The current default ITR for Tx is overly restrictive. Using a simple
netperf TCP_STREAM test, we top out at about 10Gb/s for a single thread
when running using 1500 byte frames. By reducing the ITR value to 25usec
(up to 40K interrupts a second from 10K), we are able to achieve 36Gb/s
for a single thread TCP stream test.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 115033f..fa26e20 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -171,11 +171,12 @@ struct fm10k_ring_container {
 #define FM10K_ITR_MAX		0x0FFF	/* maximum value for ITR */
 #define FM10K_ITR_10K		100	/* 100us */
 #define FM10K_ITR_20K		50	/* 50us */
+#define FM10K_ITR_40K		25	/* 25us */
 #define FM10K_ITR_ADAPTIVE	0x8000	/* adaptive interrupt moderation flag */
 
 #define ITR_IS_ADAPTIVE(itr) (!!(itr & FM10K_ITR_ADAPTIVE))
 
-#define FM10K_TX_ITR_DEFAULT	FM10K_ITR_10K
+#define FM10K_TX_ITR_DEFAULT	FM10K_ITR_40K
 #define FM10K_RX_ITR_DEFAULT	FM10K_ITR_20K
 #define FM10K_ITR_ENABLE	(FM10K_ITR_AUTOMASK | FM10K_ITR_MASK_CLEAR)
 
-- 
2.5.0
