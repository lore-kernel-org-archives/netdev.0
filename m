From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm] Documentation: add networking driver's mapping error
 handling to DMA-API-HOWTO
Date: Sun, 9 May 2010 13:00:49 +0900
Message-ID: <20100509130439D.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:55498 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759Ab0EIEBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 May 2010 00:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think that it's a good idea to add what drivers should to do exactly
in the DMA mapping failure case.

Seems some networking drivers call dev_kfree_skb() and return
NETDEV_TX_OK, however, some return NETDEV_TX_BUSY without freeing the
skb. (and many don't even check the failure, which we need to fix).

What networking drivers are supposed to do in the case?

=
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH -mm] Documentation: add networking driver's mapping error handling to DMA-API-HOWTO

Adds the concrete DMA mapping error handling for Networking drivers on
the transmit path.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 Documentation/DMA-API-HOWTO.txt |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/Documentation/DMA-API-HOWTO.txt b/Documentation/DMA-API-HOWTO.txt
index 52618ab..8c3235c 100644
--- a/Documentation/DMA-API-HOWTO.txt
+++ b/Documentation/DMA-API-HOWTO.txt
@@ -740,6 +740,11 @@ failure can be determined by:
 		 */
 	}
 
+Networking drivers must call dev_kfree_skb to free the socket buffer
+and return NETDEV_TX_OK if the DMA mapping fails on the transmit hook
+(ndo_start_xmit). This means that the socket buffer is just dropped in
+the failure case.
+
 			   Closing
 
 This document, and the API itself, would not be in it's current
-- 
1.6.5

