From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 3/5] be2net: fix FW default for VF tx-rate
Date: Wed, 29 Aug 2012 12:07:42 +0530
Message-ID: <654e44b9-e923-4fe2-b211-b8ac3d4d5232@exht1.ad.emulex.com>
References: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46267 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671Ab2H2G4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:56:54 -0400
In-Reply-To: <1346222264-20819-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

BE3 FW initializes VF tx-rate to 100Mbps. Fix this to 10Gbps.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index def2f66..1494f2fc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2645,8 +2645,8 @@ static int be_vf_setup(struct be_adapter *adapter)
 	}
 
 	for_all_vfs(adapter, vf_cfg, vf) {
-		status = be_cmd_link_status_query(adapter, NULL, &lnk_speed,
-						  NULL, vf + 1);
+		lnk_speed = 1000;
+		status = be_cmd_set_qos(adapter, lnk_speed, vf + 1);
 		if (status)
 			goto err;
 		vf_cfg->tx_rate = lnk_speed * 10;
-- 
1.7.4
