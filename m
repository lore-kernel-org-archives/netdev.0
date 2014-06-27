From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/4] be2net: re-enable vlan filtering mode asap
Date: Fri, 27 Jun 2014 17:13:21 +0530
Message-ID: <1403869401-6545-5-git-send-email-sathya.perla@emulex.com>
References: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:36260 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753490AbaF0Lk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 07:40:57 -0400
In-Reply-To: <1403869401-6545-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

While adding vlans, when the HW limit of vlan filters is reached, the
driver enables vlan promiscuous mode.
Similarily, while removing vlans, the driver must re-enable HW filtering
as soon as the number of vlan filters is within the HW limit.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 5ac9d13..3cf490b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1176,15 +1176,12 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 
 	/* Packets with VID 0 are always received by Lancer by default */
 	if (lancer_chip(adapter) && vid == 0)
-		goto ret;
+		return status;
 
 	clear_bit(vid, adapter->vids);
+	adapter->vlans_added--;
+
 	status = be_vid_config(adapter);
-	if (!status)
-		adapter->vlans_added--;
-	else
-		set_bit(vid, adapter->vids);
-ret:
 	return status;
 }
 
-- 
1.7.1
