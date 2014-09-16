From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/8] of: mdio: honor flags passed to of_phy_connect
Date: Tue, 16 Sep 2014 16:52:57 -0700
Message-ID: <1410911584-1559-2-git-send-email-f.fainelli@gmail.com>
References: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:63768 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbaIPXxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 19:53:54 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so828695pab.18
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 16:53:53 -0700 (PDT)
In-Reply-To: <1410911584-1559-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach,
connect, connect_direct}") removed the flags argument to the PHY library
calls to: phy_{attach,connect,connect_direct}.

Most Device Tree aware drivers call of_phy_connect() with the flag
argument set to 0, but some of them might want to set a different value
there in order for the PHY driver to key a specific behavior based on
the phy_device::phy_flags value.

Allow such drivers to set custom phy_flags as part of the
of_phy_connect() call since of_phy_connect() does start the PHY state
machine, it will call into the PHY driver config_init() callback which
is usually where a specific phy_flags value is important.

Fixes: f9a8f83b04e0 ("net: phy: remove flags argument from phy_{attach, connect, connect_direct}")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/of/of_mdio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
index 401b2453da45..a85d80012993 100644
--- a/drivers/of/of_mdio.c
+++ b/drivers/of/of_mdio.c
@@ -224,6 +224,8 @@ struct phy_device *of_phy_connect(struct net_device *dev,
 	if (!phy)
 		return NULL;
 
+	phy->dev_flags = flags;
+
 	return phy_connect_direct(dev, phy, hndlr, iface) ? NULL : phy;
 }
 EXPORT_SYMBOL(of_phy_connect);
-- 
1.9.1
