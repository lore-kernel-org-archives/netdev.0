From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: usb: pegasus: use new api ethtool_{get|set}_link_ksettings
Date: Fri, 17 Mar 2017 23:34:04 +0100
Message-ID: <1489790044-11867-1-git-send-email-tremyfr@gmail.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Philippe Reynes <tremyfr@gmail.com>
To: petkan@nucleusys.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34146 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751179AbdCQWeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 18:34:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

As I don't have the hardware, I'd be very pleased if
someone may test this patch.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/usb/pegasus.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 3667448..321e059 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -953,20 +953,22 @@ static inline void pegasus_reset_wol(struct net_device *dev)
 }
 
 static int
-pegasus_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+pegasus_get_link_ksettings(struct net_device *dev,
+			   struct ethtool_link_ksettings *ecmd)
 {
 	pegasus_t *pegasus;
 
 	pegasus = netdev_priv(dev);
-	mii_ethtool_gset(&pegasus->mii, ecmd);
+	mii_ethtool_get_link_ksettings(&pegasus->mii, ecmd);
 	return 0;
 }
 
 static int
-pegasus_set_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
+pegasus_set_link_ksettings(struct net_device *dev,
+			   const struct ethtool_link_ksettings *ecmd)
 {
 	pegasus_t *pegasus = netdev_priv(dev);
-	return mii_ethtool_sset(&pegasus->mii, ecmd);
+	return mii_ethtool_set_link_ksettings(&pegasus->mii, ecmd);
 }
 
 static int pegasus_nway_reset(struct net_device *dev)
@@ -995,14 +997,14 @@ static void pegasus_set_msglevel(struct net_device *dev, u32 v)
 
 static const struct ethtool_ops ops = {
 	.get_drvinfo = pegasus_get_drvinfo,
-	.get_settings = pegasus_get_settings,
-	.set_settings = pegasus_set_settings,
 	.nway_reset = pegasus_nway_reset,
 	.get_link = pegasus_get_link,
 	.get_msglevel = pegasus_get_msglevel,
 	.set_msglevel = pegasus_set_msglevel,
 	.get_wol = pegasus_get_wol,
 	.set_wol = pegasus_set_wol,
+	.get_link_ksettings = pegasus_get_link_ksettings,
+	.set_link_ksettings = pegasus_set_link_ksettings,
 };
 
 static int pegasus_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
-- 
1.7.4.4
