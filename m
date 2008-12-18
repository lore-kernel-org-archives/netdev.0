From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 3/3] NIU: Implement discard counters, optimize
Date: Thu, 18 Dec 2008 14:58:26 +0100
Message-ID: <1229608706.16904.31.camel@localhost.localdomain>
References: <1229608331.16904.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, hawk@comx.dk
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:32986 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbYLRN62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 08:58:28 -0500
In-Reply-To: <1229608331.16904.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Optimize the lightly loaded case, by only syncronizing discards stats
when qlen > 10 indicate potential for drops.

Notice Robert Olsson might disagree with this patch.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 drivers/net/niu.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 9f6a98f..7746230 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -3620,7 +3620,9 @@ static int niu_rx_work(struct niu *np, struct rx_ring_info *rp, int budget)
 
 	nw64(RX_DMA_CTL_STAT(rp->rx_channel), stat);
 
-	niu_sync_rx_discard_stats(np, rp, 0x7FFF);
+	/* Only sync discards stats when qlen indicate potential for drops */
+	if (qlen > 10)
+		niu_sync_rx_discard_stats(np, rp, 0x7FFF);
 
 	return work_done;
 }


