From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 2/2] net: dsa: remove phy_disconnect from error path
Date: Thu, 11 Feb 2016 11:44:49 +0100
Message-ID: <1455187489-30771-2-git-send-email-s.hauer@pengutronix.de>
References: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:57850 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbcBKKpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:45:02 -0500
In-Reply-To: <1455187489-30771-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy has not been initialized, disconnecting it in the error
path results in a NULL pointer exception. Drop the phy_disconnect
from the error path.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 net/dsa/slave.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 40b9ca7..91e3b2f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1194,7 +1194,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	if (ret) {
 		netdev_err(master, "error %d registering interface %s\n",
 			   ret, slave_dev->name);
-		phy_disconnect(p->phy);
 		ds->ports[port] = NULL;
 		free_netdev(slave_dev);
 		return ret;
-- 
2.7.0.rc3
