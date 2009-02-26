From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 6/7] I/OAT: list usage cleanup
Date: Thu, 26 Feb 2009 11:05:30 +0100
Message-ID: <20090226100525.3615.38859.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19569 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754948AbZBZKON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:14:13 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Sesterhenn <snakebyte@gmx.de>

Trivial cleanup, list_del(); list_add_tail() is equivalent
to list_move_tail(). Semantic patch for coccinelle can be
found at www.cccmz.de/~snakebyte/list_move_tail.spatch

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioat_dma.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/dma/ioat_dma.c b/drivers/dma/ioat_dma.c
index fc9b845..ae8c0ce 100644
--- a/drivers/dma/ioat_dma.c
+++ b/drivers/dma/ioat_dma.c
@@ -1171,9 +1171,8 @@ #endif
 				 * up if the client is done with the descriptor
 				 */
 				if (async_tx_test_ack(&desc->async_tx)) {
-					list_del(&desc->node);
-					list_add_tail(&desc->node,
-						      &ioat_chan->free_desc);
+					list_move_tail(&desc->node,
+						       &ioat_chan->free_desc);
 				} else
 					desc->async_tx.cookie = 0;
 			} else {

