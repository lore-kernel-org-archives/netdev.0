From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix detection of cut-thru firmware mode
Date: Wed, 17 Jun 2009 20:27:24 -0700
Message-ID: <1245295645-22573-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:36933 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755366AbZFRD1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2009 23:27:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the detection of cut-thru mode of the hardware (direct dma
to host) to mode configured in SRE (ingress block) rather than
onboard memory control.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hdr.h |    1 +
 drivers/net/netxen/netxen_nic_hw.c  |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 7f0ddbf..3cc0478 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -355,6 +355,7 @@ enum {
 #define NETXEN_HW_CRB_HUB_AGT_ADR_LPC	\
 	((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_LPC_CRB_AGT_ADR)
 
+#define NETXEN_SRE_MISC			(NETXEN_CRB_SRE + 0x0002c)
 #define NETXEN_SRE_INT_STATUS		(NETXEN_CRB_SRE + 0x00034)
 #define NETXEN_SRE_PBI_ACTIVE_STATUS	(NETXEN_CRB_SRE + 0x01014)
 #define NETXEN_SRE_L1RE_CTL		(NETXEN_CRB_SRE + 0x03000)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 42ffb82..9702509 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2041,8 +2041,8 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
 			fw_major, fw_minor, fw_build);
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		i = NXRD32(adapter, NETXEN_MIU_MN_CONTROL);
-		adapter->ahw.cut_through = (i & 0x4) ? 1 : 0;
+		i = NXRD32(adapter, NETXEN_SRE_MISC);
+		adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
 		dev_info(&pdev->dev, "firmware running in %s mode\n",
 		adapter->ahw.cut_through ? "cut-through" : "legacy");
 	}
-- 
1.6.0.2

