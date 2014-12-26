From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 7/27] cw1200: main: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:38 +0100
Message-ID: <1419604558-29743-8-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>
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
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/cw1200/main.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/cw1200/main.c b/drivers/net/wireless/cw1200/main.c
index 3e78cc3..fa965ee 100644
--- a/drivers/net/wireless/cw1200/main.c
+++ b/drivers/net/wireless/cw1200/main.c
@@ -374,9 +374,8 @@ static struct ieee80211_hw *cw1200_init_common(const u8 *macaddr,
 	INIT_WORK(&priv->update_filtering_work, cw1200_update_filtering_work);
 	INIT_WORK(&priv->set_beacon_wakeup_period_work,
 		  cw1200_set_beacon_wakeup_period_work);
-	init_timer(&priv->mcast_timeout);
-	priv->mcast_timeout.data = (unsigned long)priv;
-	priv->mcast_timeout.function = cw1200_mcast_timeout;
+	setup_timer(&priv->mcast_timeout, cw1200_mcast_timeout,
+		    (unsigned long)priv);
 
 	if (cw1200_queue_stats_init(&priv->tx_queue_stats,
 				    CW1200_LINK_ID_MAX,
