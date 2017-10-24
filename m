From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/wireless: atmel: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 02:28:52 -0700
Message-ID: <20171024092852.GA47097@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Kelley <simon@thekelleys.org.uk>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Simon Kelley <simon@thekelleys.org.uk>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/atmel/atmel.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/atmel/atmel.c b/drivers/net/wireless/atmel/atmel.c
index e816d53c2c05..c9dd5e44c9c6 100644
--- a/drivers/net/wireless/atmel/atmel.c
+++ b/drivers/net/wireless/atmel/atmel.c
@@ -586,7 +586,7 @@ static int atmel_validate_channel(struct atmel_private *priv, int channel);
 static void atmel_management_frame(struct atmel_private *priv,
 				   struct ieee80211_hdr *header,
 				   u16 frame_len, u8 rssi);
-static void atmel_management_timer(u_long a);
+static void atmel_management_timer(struct timer_list *t);
 static void atmel_send_command(struct atmel_private *priv, int command,
 			       void *cmd, int cmd_size);
 static int atmel_send_command_wait(struct atmel_private *priv, int command,
@@ -1579,8 +1579,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	priv->default_beacon_period = priv->beacon_period = 100;
 	priv->listen_interval = 1;
 
-	setup_timer(&priv->management_timer, atmel_management_timer,
-		    (unsigned long)dev);
+	timer_setup(&priv->management_timer, atmel_management_timer, 0);
 	spin_lock_init(&priv->irqlock);
 	spin_lock_init(&priv->timerlock);
 
@@ -3434,10 +3433,9 @@ static void atmel_management_frame(struct atmel_private *priv,
 }
 
 /* run when timer expires */
-static void atmel_management_timer(u_long a)
+static void atmel_management_timer(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *) a;
-	struct atmel_private *priv = netdev_priv(dev);
+	struct atmel_private *priv = from_timer(priv, t, management_timer);
 	unsigned long flags;
 
 	/* Check if the card has been yanked. */
-- 
2.7.4


-- 
Kees Cook
Pixel Security
