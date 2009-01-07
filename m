From: Bryan Wu <cooloney@kernel.org>
Subject: [PATCH 2/2] netdev: bfin_mac: enable VLAN support in Blackfin MAC driver
Date: Thu,  8 Jan 2009 00:14:39 +0800
Message-ID: <1231344879-26069-3-git-send-email-cooloney@kernel.org>
References: <1231344879-26069-1-git-send-email-cooloney@kernel.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Graf Yang <graf.yang@analog.com>,
	Bryan Wu <cooloney@kernel.org>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:13011 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755043AbZAGQOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 11:14:04 -0500
In-Reply-To: <1231344879-26069-1-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Graf Yang <graf.yang@analog.com>

Fill EMAC_VLAN1 with 0x8100 to admit 1522 long bytes frames. EMAC_VLAN2
seems need not use for now.

Signed-off-by: Graf Yang <graf.yang@analog.com>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
---
 drivers/net/bfin_mac.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 78e31aa..15d7e62 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -517,6 +517,14 @@ void setup_system_regs(struct net_device *dev)
 
 	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#define VLAN_ETHER_TYPE 0x8100
+	/* The legal length of the frame is increased to 1522 bytes */
+	bfin_write_EMAC_VLAN1(VLAN_ETHER_TYPE);
+	/* The legal length of the frame is increased to 1538 bytes */
+	/*bfin_write_EMAC_VLAN2(VLAN_ETHER_TYPE);*/
+#endif
+
 	/* Initialize the TX DMA channel registers */
 	bfin_write_DMA2_X_COUNT(0);
 	bfin_write_DMA2_X_MODIFY(4);
-- 
1.5.6

