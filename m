From: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Subject: [PATCH v2 net-next 3/8] be2net: Fix be_vlan_rem_vid() to check vlan id being removed
Date: Wed,  3 Feb 2016 09:49:18 +0530
Message-ID: <1454473163-18781-4-git-send-email-sriharsha.basavapatna@broadcom.com>
References: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:52531 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755589AbcBCEVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 23:21:14 -0500
In-Reply-To: <1454473163-18781-1-git-send-email-sriharsha.basavapatna@broadcom.com>
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
