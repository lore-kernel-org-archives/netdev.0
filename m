From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/6]: [CASSINI]: Fix two obvious NAPI bugs.
Date: Fri, 04 Jan 2008 00:34:51 -0800 (PST)
Message-ID: <20080104.003451.188427384.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46604
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752977AbYADIqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:46:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Fix two obvious NAPI bugs.

1) close should do napi_disable() not napi_enable
2) remove unused local var 'todo'

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 92821ae..c3220e4 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2586,7 +2586,7 @@ static int cas_poll(struct napi_struct *napi, int budget)
 {
 	struct cas *cp = container_of(napi, struct cas, napi);
 	struct net_device *dev = cp->dev;
-	int i, enable_intr, todo, credits;
+	int i, enable_intr, credits;
 	u32 status = readl(cp->regs + REG_INTR_STATUS);
 	unsigned long flags;
 
@@ -4350,7 +4350,7 @@ static int cas_close(struct net_device *dev)
 	struct cas *cp = netdev_priv(dev);
 
 #ifdef USE_NAPI
-	napi_enable(&cp->napi);
+	napi_disable(&cp->napi);
 #endif
 	/* Make sure we don't get distracted by suspend/resume */
 	mutex_lock(&cp->pm_mutex);
-- 
1.5.4.rc2.17.g257f

