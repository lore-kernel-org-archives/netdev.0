From: Guo-Fu Tseng <cooldavid@cooldavid.org>
Subject: [PATCH net-2.6 2/7] jme: Fix unmatched tasklet_{enable|disable} pair
Date: Mon, 6 Jul 2009 22:37:52 +0800
Message-ID: <20090706145548.A3A8510777@cooldavid.org>
Cc: "netdev" <netdev@vger.kernel.org>,
	"Ethan Hsiao" <ethanhsiao@jmicron.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:39380 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752940AbZGFOzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 10:55:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix faulty tasklet function usage.

Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/jme.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index abf82cd..8de3940 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -1566,6 +1566,7 @@ jme_open(struct net_device *netdev)
 	jme_clear_pm(jme);
 	JME_NAPI_ENABLE(jme);
 
+	tasklet_enable(&jme->linkch_task);
 	tasklet_enable(&jme->txclean_task);
 	tasklet_hi_enable(&jme->rxclean_task);
 	tasklet_hi_enable(&jme->rxempty_task);
@@ -1647,10 +1648,10 @@ jme_close(struct net_device *netdev)
 
 	JME_NAPI_DISABLE(jme);
 
-	tasklet_kill(&jme->linkch_task);
-	tasklet_kill(&jme->txclean_task);
-	tasklet_kill(&jme->rxclean_task);
-	tasklet_kill(&jme->rxempty_task);
+	tasklet_disable(&jme->linkch_task);
+	tasklet_disable(&jme->txclean_task);
+	tasklet_disable(&jme->rxclean_task);
+	tasklet_disable(&jme->rxempty_task);
 
 	jme_reset_ghc_speed(jme);
 	jme_disable_rx_engine(jme);
@@ -2768,6 +2769,7 @@ jme_init_one(struct pci_dev *pdev,
 	tasklet_init(&jme->rxempty_task,
 		     &jme_rx_empty_tasklet,
 		     (unsigned long) jme);
+	tasklet_disable_nosync(&jme->linkch_task);
 	tasklet_disable_nosync(&jme->txclean_task);
 	tasklet_disable_nosync(&jme->rxclean_task);
 	tasklet_disable_nosync(&jme->rxempty_task);
-- 
1.6.0.6

