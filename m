From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: nuvoton: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:51:58 -0700
Message-ID: <20171025105158.GA146575@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wan ZongShun <mcuos.com@gmail.com>,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Wan ZongShun <mcuos.com@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/nuvoton/w90p910_ether.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index 4a67c55aa9f1..052b3d2c07a1 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -253,10 +253,10 @@ static void update_linkspeed(struct net_device *dev)
 	netif_carrier_on(dev);
 }
 
-static void w90p910_check_link(unsigned long dev_id)
+static void w90p910_check_link(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct w90p910_ether *ether = netdev_priv(dev);
+	struct w90p910_ether *ether = from_timer(ether, t, check_timer);
+	struct net_device *dev = ether->mii.dev;
 
 	update_linkspeed(dev);
 	mod_timer(&ether->check_timer, jiffies + msecs_to_jiffies(1000));
@@ -957,8 +957,7 @@ static int w90p910_ether_setup(struct net_device *dev)
 	ether->mii.mdio_read = w90p910_mdio_read;
 	ether->mii.mdio_write = w90p910_mdio_write;
 
-	setup_timer(&ether->check_timer, w90p910_check_link,
-						(unsigned long)dev);
+	timer_setup(&ether->check_timer, w90p910_check_link, 0);
 
 	return 0;
 }
-- 
2.7.4


-- 
Kees Cook
Pixel Security
