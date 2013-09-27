From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 5/7] be2net: Fix to allow VLAN configuration on VF
 interfaces.
Date: Fri, 27 Sep 2013 15:18:28 -0500
Message-ID: <20130927201828.GA4582@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29055 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3I0USb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:18:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now the VF interfaces have privilege to add VLANs.
Allow VLANs to be configured on these interfaces.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2962d2f..9c25607 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1055,10 +1055,6 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
-	if (!lancer_chip(adapter) && !be_physfn(adapter)) {
-		status = -EINVAL;
-		goto ret;
-	}
 
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
@@ -1081,11 +1077,6 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	struct be_adapter *adapter = netdev_priv(netdev);
 	int status = 0;
 
-	if (!lancer_chip(adapter) && !be_physfn(adapter)) {
-		status = -EINVAL;
-		goto ret;
-	}
-
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
 		goto ret;
-- 
1.8.1.2
