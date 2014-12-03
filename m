From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH v2 5/6] myri10ge: use eth_skb_pad helper
Date: Wed, 03 Dec 2014 08:17:58 -0800
Message-ID: <20141203161758.9223.85476.stgit@ahduyck-vm-fedora20>
References: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hyong-Youb Kim <hykim@myri.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753266AbaLCQSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 11:18:02 -0500
In-Reply-To: <20141203161440.9223.39633.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update myri10ge to use eth_skb_pad helper.  This also corrects a minor
issue as the driver was updating length without updating the tail pointer.

Cc: Hyong-Youb Kim <hykim@myri.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 9e7e3f1..af09905 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -2913,16 +2913,11 @@ again:
 		flags |= MXGEFW_FLAGS_SMALL;
 
 		/* pad frames to at least ETH_ZLEN bytes */
-		if (unlikely(skb->len < ETH_ZLEN)) {
-			if (skb_padto(skb, ETH_ZLEN)) {
-				/* The packet is gone, so we must
-				 * return 0 */
-				ss->stats.tx_dropped += 1;
-				return NETDEV_TX_OK;
-			}
-			/* adjust the len to account for the zero pad
-			 * so that the nic can know how long it is */
-			skb->len = ETH_ZLEN;
+		if (eth_skb_pad(skb)) {
+			/* The packet is gone, so we must
+			 * return 0 */
+			ss->stats.tx_dropped += 1;
+			return NETDEV_TX_OK;
 		}
 	}
 
