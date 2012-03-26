From: Phil Sutter <phil.sutter@viprinet.com>
Subject: [PATCHv2 1/2] wimax: i2400m - prevent a possible kernel bug due to missing fw_name string
Date: Mon, 26 Mar 2012 21:01:30 +0200
Message-ID: <1332788491-21530-1-git-send-email-phil.sutter@viprinet.com>
References: <1332773830.3500.88.camel@deadeye>
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.vipri.net ([89.207.250.15]:42376 "EHLO zimbra.vipri.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933090Ab2CZTBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2012 15:01:42 -0400
In-Reply-To: <1332773830.3500.88.camel@deadeye>
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
index 63e4b70..1d76ae8 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -597,7 +597,8 @@ static void i2400m_get_drvinfo(struct net_device *net_dev,
 	struct i2400m *i2400m = net_dev_to_i2400m(net_dev);
 
 	strncpy(info->driver, KBUILD_MODNAME, sizeof(info->driver) - 1);
-	strncpy(info->fw_version, i2400m->fw_name, sizeof(info->fw_version) - 1);
+	strncpy(info->fw_version,
+	        i2400m->fw_name ? : "", sizeof(info->fw_version) - 1);
 	if (net_dev->dev.parent)
 		strncpy(info->bus_info, dev_name(net_dev->dev.parent),
 			sizeof(info->bus_info) - 1);
-- 
1.7.3.4
