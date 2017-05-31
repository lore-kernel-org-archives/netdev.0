From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 9/9] nfp: fix memory leak on FW load error
Date: Wed, 31 May 2017 08:06:51 -0700
Message-ID: <20170531150651.16873-10-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:35530 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaPMA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:12:00 -0400
Received: by mail-pf0-f182.google.com with SMTP id n23so11963224pfb.2
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:12:00 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free management FW info when app FW load failed.

Fixes: eefbde7e1002 ("nfp: add hwmon support")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 68cd34d5a9fb..0c2e64d217b5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -279,6 +279,7 @@ static int nfp_nsp_init(struct pci_dev *pdev, struct nfp_pf *pf)
 
 	err = nfp_fw_load(pdev, pf, nsp);
 	if (err < 0) {
+		kfree(pf->nspi);
 		kfree(pf->eth_tbl);
 		dev_err(&pdev->dev, "Failed to load FW\n");
 		goto exit_close_nsp;
-- 
2.11.0
