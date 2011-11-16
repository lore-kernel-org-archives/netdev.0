From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 4/5] be2net: Fix VLAN promiscous mode for Lancer
Date: Wed, 16 Nov 2011 17:33:32 +0530
Message-ID: <ff5d6b1f-d275-4529-9889-0d93a9092fdb@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:45661 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756422Ab1KPMEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 07:04:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To enable VLAN promiscous mode, the HW interface should be created
with VLAN promiscous capability in Lancer. Add this capability during
creation of the HW interface.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index c982b51..93869d4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2600,7 +2600,8 @@ static int be_setup(struct be_adapter *adapter)
 	en_flags = BE_IF_FLAGS_UNTAGGED | BE_IF_FLAGS_BROADCAST |
 			BE_IF_FLAGS_MULTICAST | BE_IF_FLAGS_PASS_L3L4_ERRORS;
 	cap_flags = en_flags | BE_IF_FLAGS_MCAST_PROMISCUOUS |
-			BE_IF_FLAGS_PROMISCUOUS;
+			BE_IF_FLAGS_VLAN_PROMISCUOUS | BE_IF_FLAGS_PROMISCUOUS;
+
 	if (adapter->function_caps & BE_FUNCTION_CAPS_RSS) {
 		cap_flags |= BE_IF_FLAGS_RSS;
 		en_flags |= BE_IF_FLAGS_RSS;
-- 
1.6.0.2
