From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 2/2] xen: netfront: support the ethtool drvinfo hook.
Date: Thu, 19 Aug 2010 10:27:50 +0100
Message-ID: <1282210070-7745-2-git-send-email-ian.campbell@citrix.com>
References: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49482 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab0HSJ1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 05:27:55 -0400
In-Reply-To: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Causes "ethtool -i" to report something useful:
	# ethtool -i eth0
	driver: xen-netfront
	version:
	firmware-version:
	bus-info: vif-0

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>
---
 drivers/net/xen-netfront.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 788a9bc..4484929 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1630,8 +1630,17 @@ static void netback_changed(struct xenbus_device *dev,
 	}
 }
 
+static void xennet_get_drvinfo(struct net_device *dev,
+			       struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "xen-netfront");
+	strcpy(info->bus_info, dev_name(dev->dev.parent));
+}
+
 static const struct ethtool_ops xennet_ethtool_ops =
 {
+	.get_drvinfo = xennet_get_drvinfo,
+
 	.set_tx_csum = ethtool_op_set_tx_csum,
 	.set_sg = xennet_set_sg,
 	.set_tso = xennet_set_tso,
-- 
1.5.6.5

