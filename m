From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: hippi: Convert timers to use timer_setup()
Date: Wed, 25 Oct 2017 03:51:29 -0700
Message-ID: <20171025105129.GA146547@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jes Sorensen <jes@trained-monkey.org>, linux-hippi@sunsite.dk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jes Sorensen <jes@trained-monkey.org>
Cc: linux-hippi@sunsite.dk
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/hippi/rrunner.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 76cc140774a2..8483f03d5a41 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1146,10 +1146,10 @@ static inline void rr_raz_rx(struct rr_private *rrpriv,
 	}
 }
 
-static void rr_timer(unsigned long data)
+static void rr_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)data;
-	struct rr_private *rrpriv = netdev_priv(dev);
+	struct rr_private *rrpriv = from_timer(rrpriv, t, timer);
+	struct net_device *dev = pci_get_drvdata(rrpriv->pci_dev);
 	struct rr_regs __iomem *regs = rrpriv->regs;
 	unsigned long flags;
 
@@ -1229,7 +1229,7 @@ static int rr_open(struct net_device *dev)
 
 	/* Set the timer to switch to check for link beat and perhaps switch
 	   to an alternate media type. */
-	setup_timer(&rrpriv->timer, rr_timer, (unsigned long)dev);
+	timer_setup(&rrpriv->timer, rr_timer, 0);
 	rrpriv->timer.expires = RUN_AT(5*HZ);           /* 5 sec. watchdog */
 	add_timer(&rrpriv->timer);
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
