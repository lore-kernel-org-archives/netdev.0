From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH] atm: [br2684] allow routed mode operation again
Date: Fri, 04 Dec 2009 15:55:50 -0500
Message-ID: <200912042055.nB4Kto8M008310@cmf.nrl.navy.mil>
Cc: mfuentes@agenciaefe.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:34903 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932425AbZLDUzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 15:55:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>

atm: [br2684] allow routed mode operation again

in routed mode, we don't have a hardware address so netdev_ops doesnt
need to validate our hardware address via .ndo_validate_addr

Reported-by: Manuel Fuentes <mfuentes@agenciaefe.com>
Signed-off-by: Manuel Fuentes <mfuentes@agenciaefe.com>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 26a646d..c9230c3 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -554,6 +554,12 @@ static const struct net_device_ops br2684_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 };
 
+static const struct net_device_ops br2684_netdev_ops_routed = {
+	.ndo_start_xmit 	= br2684_start_xmit,
+	.ndo_set_mac_address	= br2684_mac_addr,
+	.ndo_change_mtu		= eth_change_mtu
+};
+
 static void br2684_setup(struct net_device *netdev)
 {
 	struct br2684_dev *brdev = BRPRIV(netdev);
@@ -569,11 +575,10 @@ static void br2684_setup(struct net_device *netdev)
 static void br2684_setup_routed(struct net_device *netdev)
 {
 	struct br2684_dev *brdev = BRPRIV(netdev);
-	brdev->net_dev = netdev;
 
+	brdev->net_dev = netdev;
 	netdev->hard_header_len = 0;
-
-	netdev->netdev_ops = &br2684_netdev_ops;
+	netdev->netdev_ops = &br2684_netdev_ops_routed;
 	netdev->addr_len = 0;
 	netdev->mtu = 1500;
 	netdev->type = ARPHRD_PPP;
