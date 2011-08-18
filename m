From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Storing the 'vid' got by the grp5 event instead of storing the vlan_tag
Date: Thu, 18 Aug 2011 22:10:42 +0530
Message-ID: <fda860a7-48ac-4ce1-a55e-f24f16aa2cae@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:7111 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752123Ab1HRLNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2011 07:13:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    3 +--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 4278595..bec039d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -140,7 +140,7 @@ static void be_async_grp5_pvid_state_process(struct be_adapter *adapter,
 		struct be_async_event_grp5_pvid_state *evt)
 {
 	if (evt->enabled)
-		adapter->pvid = le16_to_cpu(evt->tag);
+		adapter->pvid = le16_to_cpu(evt->tag) & VLAN_VID_MASK;
 	else
 		adapter->pvid = 0;
 }
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 7c98d8e..cbc10c9 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1277,8 +1277,7 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 		if (!lancer_chip(adapter))
 			rxcp->vlan_tag = swab16(rxcp->vlan_tag);
 
-		if (((adapter->pvid & VLAN_VID_MASK) ==
-		     (rxcp->vlan_tag & VLAN_VID_MASK)) &&
+		if (adapter->pvid == (rxcp->vlan_tag & VLAN_VID_MASK) &&
 		    !adapter->vlan_tag[rxcp->vlan_tag])
 			rxcp->vlanf = 0;
 	}
-- 
1.5.6.1

