From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2] Net: DSA: Fix checking for get_phy_flags function
Date: Sun, 19 Oct 2014 16:41:47 +0200
Message-ID: <1413729707-1682-1-git-send-email-andrew@lunn.ch>
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40545 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbaJSOmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Oct 2014 10:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for the presence or not of the optional switch function
get_phy_flags() called the function, rather than checked to see if it
is a NULL pointer. This causes a derefernce of a NULL pointer on all
switch chips except the sf2, the only switch to implement this call.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Fixes: 6819563e646a ("net: dsa: allow switch drivers to specify phy_device::dev_flags")
Cc: Florian Fainelli <f.fainelli@gmail.com>
---

v2: Don't truncate the Fixes subject.


 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 9d3b12b4e03c..fbcba4bc4e08 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -596,7 +596,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	netif_carrier_off(slave_dev);
 
 	if (p->phy != NULL) {
-		if (ds->drv->get_phy_flags(ds, port))
+		if (ds->drv->get_phy_flags)
 			p->phy->dev_flags |= ds->drv->get_phy_flags(ds, port);
 
 		phy_attach(slave_dev, dev_name(&p->phy->dev),
-- 
2.1.1
