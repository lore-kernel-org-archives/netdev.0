From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/3] nfp: drop support for old firmware ABIs
Date: Wed,  7 Sep 2016 19:45:36 +0100
Message-ID: <1473273937-9230-3-git-send-email-jakub.kicinski@netronome.com>
References: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36047 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756637AbcIGSqV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 14:46:21 -0400
Received: by mail-wm0-f52.google.com with SMTP id b187so130732915wme.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 11:46:20 -0700 (PDT)
In-Reply-To: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be more strict about FW versions.  Drop support for old
transitional revisions which were never used in production.
Dropping support for FW ABI version 0.0.0.0 is particularly
useful because 0 could just be uninitialized memory.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 6f22b0e12ac7..f7062cb648e1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -133,7 +133,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	}
 
 	nfp_net_get_fw_version(&fw_ver, ctrl_bar);
-	if (fw_ver.class != NFP_NET_CFG_VERSION_CLASS_GENERIC) {
+	if (fw_ver.resv || fw_ver.class != NFP_NET_CFG_VERSION_CLASS_GENERIC) {
 		dev_err(&pdev->dev, "Unknown Firmware ABI %d.%d.%d.%d\n",
 			fw_ver.resv, fw_ver.class, fw_ver.major, fw_ver.minor);
 		err = -EINVAL;
@@ -141,9 +141,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	}
 
 	/* Determine stride */
-	if (nfp_net_fw_ver_eq(&fw_ver, 0, 0, 0, 0) ||
-	    nfp_net_fw_ver_eq(&fw_ver, 0, 0, 0, 1) ||
-	    nfp_net_fw_ver_eq(&fw_ver, 0, 0, 0x12, 0x48)) {
+	if (nfp_net_fw_ver_eq(&fw_ver, 0, 0, 0, 1)) {
 		stride = 2;
 		tx_bar_no = NFP_NET_Q0_BAR;
 		rx_bar_no = NFP_NET_Q1_BAR;
-- 
1.9.1
