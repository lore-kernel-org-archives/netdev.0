From: Quentin Lambert <lambert.quentin@gmail.com>
Subject: [PATCH 1/2] jme: replace calls to redundant function
Date: Fri, 12 Dec 2014 13:35:52 +0100
Message-ID: <20141212123552.GA12787@sloth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Guo-Fu Tseng <cooldavid@cooldavid.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Calls to tasklet_hi_enable are replaced by calls to
tasklet_enable since the 2 functions are redundant.

Signed-off-by: Quentin Lambert <lambert.quentin@gmail.com>
Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
---
 drivers/net/ethernet/jme.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 4a1be34..44ce7d8 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -1364,8 +1364,8 @@ err_out_free_rx_resources:
 	jme_free_rx_resources(jme);
 out_enable_tasklet:
 	tasklet_enable(&jme->txclean_task);
-	tasklet_hi_enable(&jme->rxclean_task);
-	tasklet_hi_enable(&jme->rxempty_task);
+	tasklet_enable(&jme->rxclean_task);
+	tasklet_enable(&jme->rxempty_task);
 out:
 	atomic_inc(&jme->link_changing);
 }
@@ -2408,8 +2408,8 @@ static inline void jme_resume_rx(struct jme_adapter *jme)
 	if (test_bit(JME_FLAG_POLL, &jme->flags)) {
 		JME_NAPI_ENABLE(jme);
 	} else {
-		tasklet_hi_enable(&jme->rxclean_task);
-		tasklet_hi_enable(&jme->rxempty_task);
+		tasklet_enable(&jme->rxclean_task);
+		tasklet_enable(&jme->rxempty_task);
 	}
 	dpi->cur		= PCC_P1;
 	dpi->attempt		= PCC_P1;
@@ -3290,8 +3290,8 @@ jme_suspend(struct device *dev)
 	}
 
 	tasklet_enable(&jme->txclean_task);
-	tasklet_hi_enable(&jme->rxclean_task);
-	tasklet_hi_enable(&jme->rxempty_task);
+	tasklet_enable(&jme->rxclean_task);
+	tasklet_enable(&jme->rxempty_task);
 
 	jme_powersave_phy(jme);
 
-- 
1.9.1
