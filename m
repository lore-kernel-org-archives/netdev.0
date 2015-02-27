From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: stmmac: Use setup_timer and mod_timer
Date: Sat, 28 Feb 2015 00:12:34 +0530
Message-ID: <20150227184234.GA20338@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use timer API functions setup_timer and mod_timer instead
of structure assignments as they are standard way to set
the timer and to update the expire field of an active timer
respectively.

This is done using Coccinelle and semantic patch used for
this is as follows:

// <smpl>
@@
expression x,y,z,a,b;
@@

-init_timer (&x);
+setup_timer (&x, y, z);
+mod_timer (&a, b);
-x.function = y;
-x.data = z;
-x.expires = b;
-add_timer(&a);
// </smpl>

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 55e89b3..a0ea84f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -310,11 +310,11 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
 		spin_lock_irqsave(&priv->lock, flags);
 		if (!priv->eee_active) {
 			priv->eee_active = 1;
-			init_timer(&priv->eee_ctrl_timer);
-			priv->eee_ctrl_timer.function = stmmac_eee_ctrl_timer;
-			priv->eee_ctrl_timer.data = (unsigned long)priv;
-			priv->eee_ctrl_timer.expires = STMMAC_LPI_T(eee_timer);
-			add_timer(&priv->eee_ctrl_timer);
+			setup_timer(&priv->eee_ctrl_timer,
+				    stmmac_eee_ctrl_timer,
+				    (unsigned long)priv);
+			mod_timer(&priv->eee_ctrl_timer,
+				  STMMAC_LPI_T(eee_timer));
 
 			priv->hw->mac->set_eee_timer(priv->hw,
 						     STMMAC_DEFAULT_LIT_LS,
-- 
1.9.1
