From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCH 1/2] wimax: i2400m - prevent a possible kernel bug due to missing fw_name string
Date: Mon, 26 Mar 2012 13:23:55 +0200
Message-ID: <1332761036-8913-1-git-send-email-phil.sutter@viprinet.com>
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:35033 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932254Ab2CZLcE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 07:32:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This happened on a machine with a custom hotplug script calling nameif,
probably due to slow firmware loading. At the time nameif uses ethtool
to gather interface information, i2400m->fw_name is zero and so a null
pointer dereference occurs from within i2400m_get_drvinfo().

Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
---
 drivers/net/wimax/i2400m/netdev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 64a1106..020bd8d 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -607,7 +607,8 @@ static void i2400m_get_drvinfo(struct net_device *net_dev,
 	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 
 	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
-	strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
+	strncpy(info->fw_version,
+	        i2400m->fw_name ? : "N/A", sizeof(info->fw_version) - 1);
 	if (net_dev->dev.parent)
 		strncpy(info->bus_info, dev_name(net_dev->dev.parent),
 			sizeof(info->bus_info) - 1);
-- 
1.7.3.4
