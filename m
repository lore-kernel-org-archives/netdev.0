From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 7/7] be2net: Fix to display the VLAN priority for a VF
Date: Fri, 27 Sep 2013 15:18:56 -0500
Message-ID: <20130927201856.GA4616@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:29061 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab3I0US7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:18:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VLAN priority is not being displayed for a VF currently when user executes
"ip link show" command. This patch fixes it.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ad593ca..2c38cc4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1201,8 +1201,8 @@ static int be_get_vf_config(struct net_device *netdev, int vf,
 
 	vi->vf = vf;
 	vi->tx_rate = vf_cfg->tx_rate;
-	vi->vlan = vf_cfg->vlan_tag;
-	vi->qos = 0;
+	vi->vlan = vf_cfg->vlan_tag & VLAN_VID_MASK;
+	vi->qos = vf_cfg->vlan_tag >> VLAN_PRIO_SHIFT;
 	memcpy(&vi->mac, vf_cfg->mac_addr, ETH_ALEN);
 
 	return 0;
-- 
1.8.1.2
