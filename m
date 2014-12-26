From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 25/27] mwifiex: tdls: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:58 +0100
Message-ID: <1419604558-29743-28-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.function = f;
-t.data = d;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/mwifiex/tdls.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/mwifiex/tdls.c
index 22884b4..5a64681 100644
--- a/drivers/net/wireless/mwifiex/tdls.c
+++ b/drivers/net/wireless/mwifiex/tdls.c
@@ -1367,9 +1367,8 @@ void mwifiex_check_auto_tdls(unsigned long context)
 
 void mwifiex_setup_auto_tdls_timer(struct mwifiex_private *priv)
 {
-	init_timer(&priv->auto_tdls_timer);
-	priv->auto_tdls_timer.function = mwifiex_check_auto_tdls;
-	priv->auto_tdls_timer.data = (unsigned long)priv;
+	setup_timer(&priv->auto_tdls_timer, mwifiex_check_auto_tdls,
+		    (unsigned long)priv);
 	priv->auto_tdls_timer_active = true;
 	mod_timer(&priv->auto_tdls_timer,
 		  jiffies + msecs_to_jiffies(MWIFIEX_TIMER_10S));
