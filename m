From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 4/4] vrf: ndo_add|del_slave drop unnecessary checks
Date: Wed, 19 Aug 2015 06:27:10 +0300
Message-ID: <1439954830-24947-5-git-send-email-razor@blackwall.org>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:35665 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbHSPAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:00:51 -0400
Received: by wicne3 with SMTP id ne3so123078835wic.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:00:50 -0700 (PDT)
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When ndo_add|del_slave ops are used, they're taken from the respective
master device's netdev ops, so if the master device is a VRF only then
the VRF ops will get called thus no need to check the type of the
master.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 4825c65c62fd..dbeffe789185 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -393,8 +393,7 @@ out_fail:
 
 static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (!netif_is_vrf(dev) || netif_is_vrf(port_dev) ||
-	    vrf_is_slave(port_dev))
+	if (netif_is_vrf(port_dev) || vrf_is_slave(port_dev))
 		return -EINVAL;
 
 	return do_vrf_add_slave(dev, port_dev);
@@ -431,9 +430,6 @@ static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 
 static int vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	if (!netif_is_vrf(dev))
-		return -EINVAL;
-
 	return do_vrf_del_slave(dev, port_dev);
 }
 
-- 
2.4.3
