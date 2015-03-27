From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 2/4] net/macb: add comment in macb_probe_queues
Date: Fri, 27 Mar 2015 16:34:10 +0100
Message-ID: <7ea2f13b538a039c66323f798720ead7507e8cb2.1427469791.git.nicolas.ferre@atmel.com>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>,
	<punnaia@xilinx.com>, Nicolas Ferre <nicolas.ferre@atmel.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427469791.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As we access the MID register directly, we need to tell why
we don't use the macb_is_gem() dedicated function.

Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index b710768172d9..bc3eab95022f 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2161,9 +2161,13 @@ static void macb_probe_queues(void __iomem *mem,
 	*queue_mask = 0x1;
 	*num_queues = 1;
 
-	/* is it macb or gem ? */
+	/* is it macb or gem ?
+	 *
+	 * We need to read directly from the hardware here because
+	 * we are early in the probe process and don't have the
+	 * MACB_CAPS_MACB_IS_GEM flag positioned
+	 */
 	mid = readl_relaxed(mem + MACB_MID);
-
 	if (MACB_BFEXT(IDNUM, mid) < 0x2)
 		return;
 
-- 
2.1.3
