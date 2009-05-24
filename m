From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: drop myri10ge_lro module parameter
Date: Sun, 24 May 2009 17:27:51 +0200
Message-ID: <4A196777.9050700@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1970 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753363AbZEXP1c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 11:27:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop the myri10ge_lro module parameter now that we have ethtool
to enable/disable LRO in the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index d317011..675f677 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -327,10 +327,6 @@ static int myri10ge_debug = -1;	/* defaults above */
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
-static int myri10ge_lro = 1;
-module_param(myri10ge_lro, int, S_IRUGO);
-MODULE_PARM_DESC(myri10ge_lro, "Enable large receive offload");
-
 static int myri10ge_lro_max_pkts = MYRI10GE_LRO_MAX_PKTS;
 module_param(myri10ge_lro_max_pkts, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_lro_max_pkts,
@@ -3918,8 +3914,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	if (dac_enabled)
 		netdev->features |= NETIF_F_HIGHDMA;
-	if (myri10ge_lro)
-		netdev->features |= NETIF_F_LRO;
+	netdev->features |= NETIF_F_LRO;
 
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
-- 
1.6.2.4



