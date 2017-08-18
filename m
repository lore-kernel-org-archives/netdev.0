From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/12] nfp: fix copy paste in names and messages regarding vNICs
Date: Fri, 18 Aug 2017 15:48:21 -0700
Message-ID: <20170818224822.8409-12-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36636 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751801AbdHRWtd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:33 -0400
Received: by mail-pg0-f45.google.com with SMTP id i12so72538149pgr.3
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:33 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Data and control vNICs currently use the same area name and
error message.  This could lead to confusion.  Make sure
the error message says "ctrl" in case of control and the
data area is called "nfp.bar0".

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index d5e2361f0e86..acdad6f20251 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -388,7 +388,7 @@ nfp_net_pf_app_init(struct nfp_pf *pf, u8 __iomem *qc_bar, unsigned int stride)
 					NFP_PF_CSR_SLICE_SIZE,
 					&pf->ctrl_vnic_bar);
 	if (IS_ERR(ctrl_bar)) {
-		nfp_err(pf->cpp, "Failed to find data vNIC memory symbol\n");
+		nfp_err(pf->cpp, "Failed to find ctrl vNIC memory symbol\n");
 		err = PTR_ERR(ctrl_bar);
 		goto err_app_clean;
 	}
@@ -504,7 +504,7 @@ static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 	int err;
 
 	min_size = pf->max_data_vnics * NFP_PF_CSR_SLICE_SIZE;
-	mem = nfp_net_pf_map_rtsym(pf, "net.ctrl", "_pf%d_net_bar0",
+	mem = nfp_net_pf_map_rtsym(pf, "net.bar0", "_pf%d_net_bar0",
 				   min_size, &pf->data_vnic_bar);
 	if (IS_ERR(mem)) {
 		nfp_err(pf->cpp, "Failed to find data vNIC memory symbol\n");
-- 
2.11.0
