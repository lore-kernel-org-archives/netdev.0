From: Vlad Lungu <vlad.lungu@windriver.com>
Subject: [PATCH] stmmac: priv->lock can be used uninitialized
Date: Tue, 30 Nov 2010 10:52:52 +0200
Message-ID: <9345448e435110e2bdff65bb4322060a6f1f6b63.1291106902.git.vlad.lungu@windriver.com>
Cc: peppe.cavallaro@st.com, davem@davemloft.net,
	Vlad Lungu <vlad.lungu@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:46107 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab0K3Kw7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 05:52:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To reproduce: if connman (http://connman.net/) is started,
inserting the stmmac module triggers a "BUG: spinlock bad magic on CPU#0".

Registering the device in stmmac_probe() sends a notification to connman
which brings the interface up before the lock is initialized.

Signed-off-by: Vlad Lungu <vlad.lungu@windriver.com>
---
 drivers/net/stmmac/stmmac_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 730a6fd..e960501 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1516,6 +1516,8 @@ static int stmmac_probe(struct net_device *dev)
 		pr_warning("\tno valid MAC address;"
 			"please, use ifconfig or nwhwconfig!\n");
 
+	spin_lock_init(&priv->lock);
+
 	ret = register_netdev(dev);
 	if (ret) {
 		pr_err("%s: ERROR %i registering the device\n",
@@ -1527,8 +1529,6 @@ static int stmmac_probe(struct net_device *dev)
 	    dev->name, (dev->features & NETIF_F_SG) ? "on" : "off",
 	    (dev->features & NETIF_F_HW_CSUM) ? "on" : "off");
 
-	spin_lock_init(&priv->lock);
-
 	return ret;
 }
 
-- 
1.6.0.2

