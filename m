From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] e1000e: remove workaround for e1000 hardware
Date: Wed, 18 Feb 2009 01:24:51 -0800
Message-ID: <20090218092451.21312.80460.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:56892
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751372AbZBRJZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:25:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

During the move of support for PCIe devices from e1000 to e1000e, this workaround necessary only for older non-PCIe devices was mistakenly copied into e1000e.  Remove it.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 04e007d..1b5a0c8 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3831,11 +3831,6 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
 
-		/* Workaround for premature desc write-backs
-		 * in TSO mode.  Append 4-byte sentinel desc */
-		if (mss && !nr_frags && size == len && size > 8)
-			size -= 4;
-
 		buffer_info->length = size;
 		/* set time_stamp *before* dma to help avoid a possible race */
 		buffer_info->time_stamp = jiffies;
@@ -3869,10 +3864,6 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		while (len) {
 			buffer_info = &tx_ring->buffer_info[i];
 			size = min(len, max_per_txd);
-			/* Workaround for premature desc write-backs
-			 * in TSO mode.  Append 4-byte sentinel desc */
-			if (mss && f == (nr_frags-1) && size == len && size > 8)
-				size -= 4;
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;

