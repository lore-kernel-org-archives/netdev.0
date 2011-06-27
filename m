From: Jon Mason <mason@myri.com>
Subject: [PATCH 6/9] myri10ge: remove unnecessary read of PCI_CAP_ID_EXP
Date: Mon, 27 Jun 2011 10:05:05 -0500
Message-ID: <1309187108-12715-6-git-send-email-mason@myri.com>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45826 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047Ab1F0PFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:39 -0400
Received: by mail-pz0-f46.google.com with SMTP id 9so3015778pzk.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:39 -0700 (PDT)
In-Reply-To: <1309187108-12715-1-git-send-email-mason@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PCIE capability offset is saved during PCI bus walking.  It will
remove an unnecessary search in the PCI configuration space if this
value is referenced instead of reacquiring it.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 83cbf2c..851365c 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1081,7 +1081,7 @@ static int myri10ge_toggle_relaxed(struct pci_dev *pdev, int on)
 	int ret, cap, err;
 	u16 ctl;
 
-	cap = pci_find_capability(pdev, PCI_CAP_ID_EXP);
+	cap = pci_pcie_cap(pdev);
 	if (!cap)
 		return 0;
 
@@ -3191,7 +3191,7 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 {
 	struct pci_dev *bridge = mgp->pdev->bus->self;
 	struct device *dev = &mgp->pdev->dev;
-	unsigned cap;
+	int cap;
 	unsigned err_cap;
 	u16 val;
 	u8 ext_type;
@@ -3201,7 +3201,7 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 		return;
 
 	/* check that the bridge is a root port */
-	cap = pci_find_capability(bridge, PCI_CAP_ID_EXP);
+	cap = pci_pcie_cap(bridge);
 	pci_read_config_word(bridge, cap + PCI_CAP_FLAGS, &val);
 	ext_type = (val & PCI_EXP_FLAGS_TYPE) >> 4;
 	if (ext_type != PCI_EXP_TYPE_ROOT_PORT) {
@@ -3219,8 +3219,7 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 						" to force ECRC\n");
 					return;
 				}
-				cap =
-				    pci_find_capability(bridge, PCI_CAP_ID_EXP);
+				cap = pci_pcie_cap(bridge);
 				pci_read_config_word(bridge,
 						     cap + PCI_CAP_FLAGS, &val);
 				ext_type = (val & PCI_EXP_FLAGS_TYPE) >> 4;
@@ -3341,7 +3340,7 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 		int link_width, exp_cap;
 		u16 lnk;
 
-		exp_cap = pci_find_capability(mgp->pdev, PCI_CAP_ID_EXP);
+		exp_cap = pci_pcie_cap(mgp->pdev);
 		pci_read_config_word(mgp->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
 		link_width = (lnk >> 4) & 0x3f;
 
-- 
1.7.5.4

