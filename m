From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] fm10k: Reduce buffer size when pages are larger than 4K
Date: Thu,  2 Oct 2014 03:16:26 -0700
Message-ID: <1412244994-23636-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44069 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbaJBKQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Oct 2014 06:16:39 -0400
In-Reply-To: <1412244994-23636-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change reduces the buffer size to 2K for all page sizes.  The basic
idea is that since most frames only have a 1500 MTU supporting a buffer
size larger than this is somewhat wasteful.  As such I have reduced the
size to 2K for all page sizes which will allow for more uses per page.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 0565827..42eb434 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -47,13 +47,9 @@
 #define FM10K_DEFAULT_TX_WORK	 256
 
 #define FM10K_RXBUFFER_256	  256
-#define FM10K_RXBUFFER_16384	16384
 #define FM10K_RX_HDR_LEN	FM10K_RXBUFFER_256
-#if PAGE_SIZE <= FM10K_RXBUFFER_16384
-#define FM10K_RX_BUFSZ		(PAGE_SIZE / 2)
-#else
-#define FM10K_RX_BUFSZ		FM10K_RXBUFFER_16384
-#endif
+#define FM10K_RXBUFFER_2048	 2048
+#define FM10K_RX_BUFSZ		FM10K_RXBUFFER_2048
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define FM10K_RX_BUFFER_WRITE	16	/* Must be power of 2 */
-- 
1.9.3
