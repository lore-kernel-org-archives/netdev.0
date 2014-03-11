From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 6/7] be2net: Fix vlans_added counter
Date: Tue, 11 Mar 2014 18:53:08 +0530
Message-ID: <1394544189-20277-7-git-send-email-sathya.perla@emulex.com>
References: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:35592 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbaCKNUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:20:15 -0400
In-Reply-To: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

When a VLAN is added by user, adapter->vlans_added is incremented.
But if the VLAN is already programmed in HW, driver ends up
incrementing the counter wrongly.

Increment the counter only if VLAN is not already programmed in the HW.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index fc44bb3..4173693 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1138,7 +1138,10 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
-		goto ret;
+		return status;
+
+	if (adapter->vlan_tag[vid])
+		return status;
 
 	adapter->vlan_tag[vid] = 1;
 	adapter->vlans_added++;
@@ -1148,7 +1151,7 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 		adapter->vlans_added--;
 		adapter->vlan_tag[vid] = 0;
 	}
-ret:
+
 	return status;
 }
 
-- 
1.7.1
