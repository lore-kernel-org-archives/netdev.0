From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 18/18] igb: update tx DMA mapping error handling
Date: Wed, 17 Feb 2010 03:06:16 -0800
Message-ID: <20100217110614.17723.84160.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:34190
	"EHLO qmta04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752609Ab0BQLGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:06:33 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This updates the tx DMA mapping error handling code to
resemble e1000e/ixgbe.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index ab7c5e9..f588e49 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3647,14 +3647,12 @@ dma_error:
 	buffer_info->length = 0;
 	buffer_info->next_to_watch = 0;
 	buffer_info->mapped_as_page = false;
-	count--;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
-	while (count >= 0) {
-		count--;
+	while (count--) {
+		if (i == 0)
+			i = tx_ring->count;
 		i--;
-		if (i < 0)
-			i += tx_ring->count;
 		buffer_info = &tx_ring->buffer_info[i];
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}

