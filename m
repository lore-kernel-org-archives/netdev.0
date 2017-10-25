From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: 3com/3c515: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:51:03 -0700
Message-ID: <20171025105103.GA146494@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Johannes Berg <johannes.berg@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/3com/3c515.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index c5987f518cb2..b648e3f95c01 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -367,7 +367,7 @@ static struct net_device *corkscrew_scan(int unit);
 static int corkscrew_setup(struct net_device *dev, int ioaddr,
 			    struct pnp_dev *idev, int card_number);
 static int corkscrew_open(struct net_device *dev);
-static void corkscrew_timer(unsigned long arg);
+static void corkscrew_timer(struct timer_list *t);
 static netdev_tx_t corkscrew_start_xmit(struct sk_buff *skb,
 					struct net_device *dev);
 static int corkscrew_rx(struct net_device *dev);
@@ -627,7 +627,7 @@ static int corkscrew_setup(struct net_device *dev, int ioaddr,
 
 	spin_lock_init(&vp->lock);
 
-	setup_timer(&vp->timer, corkscrew_timer, (unsigned long) dev);
+	timer_setup(&vp->timer, corkscrew_timer, 0);
 
 	/* Read the station address from the EEPROM. */
 	EL3WINDOW(0);
@@ -869,11 +869,11 @@ static int corkscrew_open(struct net_device *dev)
 	return 0;
 }
 
-static void corkscrew_timer(unsigned long data)
+static void corkscrew_timer(struct timer_list *t)
 {
 #ifdef AUTOMEDIA
-	struct net_device *dev = (struct net_device *) data;
-	struct corkscrew_private *vp = netdev_priv(dev);
+	struct corkscrew_private *vp = from_timer(vp, t, timer);
+	struct net_device *dev = vp->our_dev;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	int ok = 0;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
