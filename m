From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 29/45] bna: Add Sub-System Device ID Info
Date: Mon, 18 Jul 2011 01:22:49 -0700
Message-ID: <1310977385-5268-19-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37813 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754469Ab1GRIYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:30 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - 1860 has CNA personality with SSID 22 for PCI functions.
 - Preserve the same SSID numbering so that FCoE drivers claim adapters with
   no-asic block (default personality).

Can we get this out?

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |   10 ++++++++++
 drivers/net/bna/bfa_ioc.c  |    3 ++-
 drivers/net/bna/bfa_ioc.h  |    1 +
 3 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index e7dd91f..3e5d096 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -261,4 +261,14 @@ enum {
 #define bfa_asic_id_ctc(device)			\
 	(bfa_asic_id_ct(device) || bfa_asic_id_ct2(device))
 
+/**
+ * PCI sub-system device and vendor ID information
+ */
+enum {
+	BFA_PCI_FCOE_SSDEVICE_ID	= 0x14,
+	BFA_PCI_CT2_SSID_FCoE		= 0x22,
+	BFA_PCI_CT2_SSID_ETH		= 0x23,
+	BFA_PCI_CT2_SSID_FC		= 0x24,
+};
+
 #endif /* __BFA_DEFS_H__ */
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 2130b5a..78cdc2b 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1987,7 +1987,8 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 
 	case BFA_PCI_DEVICE_ID_CT2:
 		ioc->asic_gen = BFI_ASIC_GEN_CT2;
-		if (clscode == BFI_PCIFN_CLASS_FC) {
+		if (clscode == BFI_PCIFN_CLASS_FC &&
+			pcidev->ssid == BFA_PCI_CT2_SSID_FC) {
 			ioc->asic_mode  = BFI_ASIC_MODE_FC16;
 			ioc->fcmode = true;
 		} else {
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index a9f24e2..0f7dba1 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -35,6 +35,7 @@ struct bfa_pcidev {
 	int	pci_slot;
 	u8	pci_func;
 	u16	device_id;
+	u16	ssid;
 	void	__iomem *pci_bar_kva;
 };
 
-- 
1.7.1

