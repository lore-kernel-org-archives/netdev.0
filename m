From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: Fix displaying supported speeds for BE2
Date: Tue, 6 Aug 2013 09:27:18 +0530
Message-ID: <1375761441-22343-5-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38627 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754132Ab3HFDyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:54:53 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

The BE2 FW GET_PHY_DETAILS cmd does not return fixed speeds supported.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index bef25b7..53541a9 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2454,6 +2454,12 @@ int be_cmd_get_phy_info(struct be_adapter *adapter)
 			le16_to_cpu(resp_phy_info->fixed_speeds_supported);
 		adapter->phy.misc_params =
 			le32_to_cpu(resp_phy_info->misc_params);
+
+		if (BE2_chip(adapter)) {
+			adapter->phy.fixed_speeds_supported =
+				BE_SUPPORTED_SPEED_10GBPS |
+				BE_SUPPORTED_SPEED_1GBPS;
+		}
 	}
 	pci_free_consistent(adapter->pdev, cmd.size,
 				cmd.va, cmd.dma);
-- 
1.7.1
