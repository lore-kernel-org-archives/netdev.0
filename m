From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 26/27] mwifiex: 11n_rxreorder: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:57 +0100
Message-ID: <1419604558-29743-27-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Avinash Patil <patila@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
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
 drivers/net/wireless/mwifiex/11n_rxreorder.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index d73fda3..f33dc81 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -391,10 +391,8 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
 	new_node->timer_context.priv = priv;
 	new_node->timer_context.timer_is_set = false;
 
-	init_timer(&new_node->timer_context.timer);
-	new_node->timer_context.timer.function = mwifiex_flush_data;
-	new_node->timer_context.timer.data =
-			(unsigned long) &new_node->timer_context;
+	setup_timer(&new_node->timer_context.timer, mwifiex_flush_data,
+		    (unsigned long)&new_node->timer_context);
 
 	for (i = 0; i < win_size; ++i)
 		new_node->rx_reorder_ptr[i] = NULL;

