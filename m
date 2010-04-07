From: Peter Korsgaard <peter.korsgaard@barco.com>
Subject: [PATCH] macb: allow reception of large (>1518 bytes) frames
Date: Wed,  7 Apr 2010 16:59:49 +0200
Message-ID: <1270652389-5364-1-git-send-email-peter.korsgaard@barco.com>
Cc: Peter Korsgaard <peter.korsgaard@barco.com>
To: davem@davemloft.net, haavard.skinnemoen@atmel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable BIG bit in the network configuration register, so the MAC doesn't
reject big frames (E.G. when vlans are used).

Signed-off-by: Peter Korsgaard <peter.korsgaard@barco.com>
---
 drivers/net/macb.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index c8a18a6..4dde9db 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -793,6 +793,7 @@ static void macb_init_hw(struct macb *bp)
 	config = macb_readl(bp, NCFGR) & MACB_BF(CLK, -1L);
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
+	config |= MACB_BIT(BIG);		/* Receive oversized frames */
 	if (bp->dev->flags & IFF_PROMISC)
 		config |= MACB_BIT(CAF);	/* Copy All Frames */
 	if (!(bp->dev->flags & IFF_BROADCAST))
-- 
1.7.0
