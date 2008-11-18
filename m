From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/3] igb: simplify swap in clean_rx_irq if using
	packet split
Date: Mon, 17 Nov 2008 18:05:31 -0800
Message-ID: <20081118020531.10912.66635.stgit@gitlost.lost>
References: <20081118020510.10912.94106.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:46714
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751918AbYKRCF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 21:05:57 -0500
In-Reply-To: <20081118020510.10912.94106.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This update replaces the xchg calls that were added with a pair of
assignments as there is no need for the xchg calls and they were found to
cause issues on some architectures.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 89ffc07..c298ae8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3921,8 +3921,10 @@ send_up:
 		next_buffer = &rx_ring->buffer_info[i];
 
 		if (!(staterr & E1000_RXD_STAT_EOP)) {
-			buffer_info->skb = xchg(&next_buffer->skb, skb);
-			buffer_info->dma = xchg(&next_buffer->dma, 0);
+			buffer_info->skb = next_buffer->skb;
+			buffer_info->dma = next_buffer->dma;
+			next_buffer->skb = skb;
+			next_buffer->dma = 0;
 			goto next_desc;
 		}
 

