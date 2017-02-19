From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 2/7] nfp: report manufacturing info on load
Date: Sun, 19 Feb 2017 11:58:09 -0800
Message-ID: <20170219195814.40471-3-jakub.kicinski@netronome.com>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        kubakici@wp.pl, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34826 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751167AbdBST6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 14:58:22 -0500
Received: by mail-pg0-f45.google.com with SMTP id b129so9787078pgc.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 11:58:21 -0800 (PST)
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report card manufacturing information when driver loads.  These
identify the version of the board and its subcomponents.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index ca2c464c15df..8cda6b0e7e32 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -322,6 +322,13 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		goto err_disable_msix;
 	}
 
+	dev_info(&pdev->dev, "Assembly: %s%s%s-%s CPLD: %s\n",
+		 nfp_hwinfo_lookup(pf->cpp, "assembly.vendor"),
+		 nfp_hwinfo_lookup(pf->cpp, "assembly.partno"),
+		 nfp_hwinfo_lookup(pf->cpp, "assembly.serial"),
+		 nfp_hwinfo_lookup(pf->cpp, "assembly.revision"),
+		 nfp_hwinfo_lookup(pf->cpp, "cpld.version"));
+
 	err = nfp_nsp_init(pdev, pf);
 	if (err)
 		goto err_cpp_free;
-- 
2.11.0
