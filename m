From: Phil Oester <kernel@linuxace.com>
Subject: [PATCH] vlan: Match underlying dev carrier on vlan add
Date: Tue, 17 Aug 2010 21:45:08 -0700
Message-ID: <20100818044508.GA23361@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UugvWAfsgieZRqgk"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:34635 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740Ab0HREpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 00:45:13 -0400
Received: by pvg2 with SMTP id 2so51372pvg.19
        for <netdev@vger.kernel.org>; Tue, 17 Aug 2010 21:45:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

When adding a new vlan, if the underlying interface has no carrier,
then the newly added vlan interface should also have no carrier.
At present, this is not true - the newly added vlan is added with
carrier up.  Fix by checking state of real device.

Signed-off-by: Phil Oester <kernel@linuxace.com>



--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-vlandev

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3d59c9b..3bccdd1 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -510,7 +510,8 @@ static int vlan_dev_open(struct net_device *dev)
 	if (vlan->flags & VLAN_FLAG_GVRP)
 		vlan_gvrp_request_join(dev);
 
-	netif_carrier_on(dev);
+	if (netif_carrier_ok(real_dev))
+		netif_carrier_on(dev);
 	return 0;
 
 clear_allmulti:

--UugvWAfsgieZRqgk--
