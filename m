From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 1/1] [NETDEV] smc91x driver: Fix bug - Print warning only in interrupt mode.
Date: Wed, 26 Mar 2008 18:12:46 -0700
Message-ID: <1206580366-22966-1-git-send-email-cooloney@kernel.org>
Cc: Sonic Zhang <sonic.zhang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758764AbYCZKNA@vger.kernel.org>
In-Reply-To: <>
References: <>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sonic Zhang <sonic.zhang@analog.com>

http://blackfin.uclinux.org/gf/project/uclinux-dist/tracker/?action=TrackerItemEdit&tracker_item_id=3956

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/smc91x.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 4020e9e..63a54e2 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	SMC_SET_INT_MASK(mask);
 	spin_unlock(&lp->lock);
 
+#ifndef CONFIG_NET_POLL_CONTROLLER
 	if (timeout == MAX_IRQ_LOOPS)
 		PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
 		       dev->name, mask);
+#endif
 	DBG(3, "%s: Interrupt done (%d loops)\n",
 	       dev->name, MAX_IRQ_LOOPS - timeout);
 
-- 
1.5.4.3
