From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: [PATCH 3/3] FS_ENET: phydev pointer may be dereferenced without NULL check
Date: Wed, 21 Jun 2006 20:10:04 +0400
Message-ID: <20060621161004.4860.68193.stgit@vitb.ru.mvista.com>
References: <20060621160950.4860.92979.stgit@vitb.ru.mvista.com>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:63156 "EHLO
	vitb.dev.rtsoft.ru") by vger.kernel.org with ESMTP id S1750772AbWFUQLE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 12:11:04 -0400
To: Jeff Garzik <jeff@garzik.org>
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-embedded@ozlabs.org
In-Reply-To: <20060621160950.4860.92979.stgit@vitb.ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


When interface is down, phy is "disconnected" from the bus and phydev is NULL.
But ethtool may try to get/set phy regs even at that time, which results in
NULL pointer dereference and OOPS hereby.

Signed-off-by: Vitaly Bordug <vbordug@ru.mvista.com>
---

 drivers/net/fs_enet/fs_enet-main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 302ecaa..e475e22 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -882,12 +882,16 @@ static void fs_get_regs(struct net_devic
 static int fs_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+	if (!fep->phydev)
+		return -EINVAL;
 	return phy_ethtool_gset(fep->phydev, cmd);
 }
 
 static int fs_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
+	if (!fep->phydev)
+		return -EINVAL;
 	phy_ethtool_sset(fep->phydev, cmd);
 	return 0;
 }

