From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/net: korina: Convert timers to use timer_setup()
Date: Thu, 26 Oct 2017 22:55:13 -0700
Message-ID: <20171027055513.GA115294@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roman Yeryomin <leroi.lists@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
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
Cc: Roman Yeryomin <leroi.lists@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/korina.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/korina.c b/drivers/net/ethernet/korina.c
index 7cecd9dbc111..ae195f8adff5 100644
--- a/drivers/net/ethernet/korina.c
+++ b/drivers/net/ethernet/korina.c
@@ -653,10 +653,10 @@ static void korina_check_media(struct net_device *dev, unsigned int init_media)
 						&lp->eth_regs->ethmac2);
 }
 
-static void korina_poll_media(unsigned long data)
+static void korina_poll_media(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) data;
-	struct korina_private *lp = netdev_priv(dev);
+	struct korina_private *lp = from_timer(lp, t, media_check_timer);
+	struct net_device *dev = lp->dev;
 
 	korina_check_media(dev, 0);
 	mod_timer(&lp->media_check_timer, jiffies + HZ);
@@ -1103,7 +1103,7 @@ static int korina_probe(struct platform_device *pdev)
 			": cannot register net device: %d\n", rc);
 		goto probe_err_register;
 	}
-	setup_timer(&lp->media_check_timer, korina_poll_media, (unsigned long) dev);
+	timer_setup(&lp->media_check_timer, korina_poll_media, 0);
 
 	INIT_WORK(&lp->restart_task, korina_restart_task);
 
-- 
2.7.4


-- 
Kees Cook
Pixel Security
