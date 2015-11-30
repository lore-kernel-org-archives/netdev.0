From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 01/13] net: thunderx: Force to load octeon-mdio before bgx driver.
Date: Mon, 30 Nov 2015 23:48:57 +0530
Message-ID: <1448907549-5296-2-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33937 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbbK3SRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 13:17:23 -0500
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>

Signed-off-by: Thanneeru Srinivasulu <tsrinivasulu@caviumnetworks.com>
Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c |    3 +++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 180aa9f..1fb72dd 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -1009,6 +1009,9 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct bgx *bgx = NULL;
 	u8 lmac;
 
+	/*Load octeon mdio driver*/
+	octeon_mdiobus_force_mod_depencency();
+
 	bgx = devm_kzalloc(dev, sizeof(*bgx), GFP_KERNEL);
 	if (!bgx)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index 07b7ec6..89a02fa 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -182,6 +182,7 @@ enum MCAST_MODE {
 #define BCAST_ACCEPT	1
 #define CAM_ACCEPT	1
 
+void octeon_mdiobus_force_mod_depencency(void);
 void bgx_add_dmac_addr(u64 dmac, int node, int bgx_idx, int lmac);
 unsigned bgx_get_map(int node);
 int bgx_get_lmac_count(int node, int bgx);
-- 
1.7.1
