From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: mv643xx_eth: Use setup_timer
Date: Mon, 1 Jun 2015 09:36:02 +0530
Message-ID: <20150601040602.GA3767@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e, func, da;
@@

-init_timer (&e);
+setup_timer (&e, func, da);
-e.data = da;
-e.function = func;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 1c75829..d52639b 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -3125,9 +3125,8 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	mib_counters_clear(mp);
 
-	init_timer(&mp->mib_counters_timer);
-	mp->mib_counters_timer.data = (unsigned long)mp;
-	mp->mib_counters_timer.function = mib_counters_timer_wrapper;
+	setup_timer(&mp->mib_counters_timer, mib_counters_timer_wrapper,
+		    (unsigned long)mp);
 	mp->mib_counters_timer.expires = jiffies + 30 * HZ;
 
 	spin_lock_init(&mp->mib_counters_lock);
@@ -3136,9 +3135,7 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	netif_napi_add(dev, &mp->napi, mv643xx_eth_poll, NAPI_POLL_WEIGHT);
 
-	init_timer(&mp->rx_oom);
-	mp->rx_oom.data = (unsigned long)mp;
-	mp->rx_oom.function = oom_timer_wrapper;
+	setup_timer(&mp->rx_oom, oom_timer_wrapper, (unsigned long)mp);
 
 
 	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
-- 
1.9.1
