From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH net-next 3/8] be2net: Fix be_vlan_rem_vid() to check vlan id being removed
Date: Tue,  2 Feb 2016 15:50:30 +0530
Message-ID: <1454408435-11575-4-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:63466 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754116AbcBBKj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 05:39:29 -0500
In-Reply-To: <1454408435-11575-1-git-send-email-sriharsha.basavapatna@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver decrements its vlan count without checking if it is really
present in its list. This results in an invalid vlan count and impacts
subsequent vlan add/rem ops. The function be_vlan_rem_vid() should be
updated to fix this.

Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f99de36..09e6f2c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1463,6 +1463,9 @@ static int be_vlan_rem_vid(struct net_device *netdev, __be16 proto, u16 vid)
 	if (lancer_chip(adapter) && vid == 0)
 		return 0;
 
+	if (!test_bit(vid, adapter->vids))
+		return 0;
+
 	clear_bit(vid, adapter->vids);
 	adapter->vlans_added--;
 
-- 
2.3.0.rc2
