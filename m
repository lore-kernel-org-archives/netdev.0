From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 2/4] be2net: do not remove vids from driver table if be_vid_config() fails.
Date: Fri, 22 Jul 2016 06:55:44 -0400
Message-ID: <1469184946-26309-3-git-send-email-sathya.perla@broadcom.com>
References: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:20969 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753824AbcGVK4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 06:56:06 -0400
In-Reply-To: <1469184946-26309-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver currently removes a new vid from the adapter->vids[] array if
be_vid_config() returns an error, which occurs when there is an error in
HW/FW. This is wrong. After the HW/FW error is recovered from, we need the
complete vids[] array to re-program the vlan list.

Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2782299..27fc1f0 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1463,13 +1463,7 @@ static int be_vlan_add_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	set_bit(vid, adapter->vids);
 	adapter->vlans_added++;
 
-	status = be_vid_config(adapter);
-	if (status) {
-		adapter->vlans_added--;
-		clear_bit(vid, adapter->vids);
-	}
-
-	return status;
+	return be_vid_config(adapter);
 }
 
 static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
-- 
2.4.1
