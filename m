From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: tundra: Convert timers to use timer_setup()
Date: Mon, 30 Oct 2017 14:05:41 -0700
Message-ID: <20171030210541.GA37640@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Philippe Reynes <tremyfr@gmail.com>,
        "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Philippe Reynes <tremyfr@gmail.com>
Cc: "yuval.shaia@oracle.com" <yuval.shaia@oracle.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/tundra/tsi108_eth.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/tundra/tsi108_eth.c b/drivers/net/ethernet/tundra/tsi108_eth.c
index c2d15d9c0c33..0624b71ab5d4 100644
--- a/drivers/net/ethernet/tundra/tsi108_eth.c
+++ b/drivers/net/ethernet/tundra/tsi108_eth.c
@@ -164,7 +164,7 @@ static struct platform_driver tsi_eth_driver = {
 	},
 };
 
-static void tsi108_timed_checker(unsigned long dev_ptr);
+static void tsi108_timed_checker(struct timer_list *t);
 
 #ifdef DEBUG
 static void dump_eth_one(struct net_device *dev)
@@ -1370,7 +1370,7 @@ static int tsi108_open(struct net_device *dev)
 
 	napi_enable(&data->napi);
 
-	setup_timer(&data->timer, tsi108_timed_checker, (unsigned long)dev);
+	timer_setup(&data->timer, tsi108_timed_checker, 0);
 	mod_timer(&data->timer, jiffies + 1);
 
 	tsi108_restart_rx(data, dev);
@@ -1666,10 +1666,10 @@ tsi108_init_one(struct platform_device *pdev)
  * Thus, we have to do it using a timer.
  */
 
-static void tsi108_timed_checker(unsigned long dev_ptr)
+static void tsi108_timed_checker(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)dev_ptr;
-	struct tsi108_prv_data *data = netdev_priv(dev);
+	struct tsi108_prv_data *data = from_timer(data, t, timer);
+	struct net_device *dev = data->dev;
 
 	tsi108_check_phy(dev);
 	tsi108_check_rxring(dev);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
