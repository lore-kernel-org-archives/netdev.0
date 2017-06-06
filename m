From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 14/16] nfp: allow non-equal distribution of IRQs
Date: Mon,  5 Jun 2017 17:01:55 -0700
Message-ID: <20170606000157.17556-15-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33305 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdFFAC2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:28 -0400
Received: by mail-pf0-f182.google.com with SMTP id 83so32352971pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:27 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thus far the code assumed all vNICs will request similar number of IRQs.
This will be no longer true with control vNICs (where 1 IRQ will suffice).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 98a99b199674..362dca38223b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -420,7 +420,8 @@ static int nfp_net_pf_alloc_irqs(struct nfp_pf *pf)
 	list_for_each_entry(nn, &pf->vnics, vnic_list) {
 		unsigned int n;
 
-		n = DIV_ROUND_UP(irqs_left, vnics_left);
+		n = min(NFP_NET_NON_Q_VECTORS + nn->dp.num_r_vecs,
+			DIV_ROUND_UP(irqs_left, vnics_left));
 		nfp_net_irqs_assign(nn, &pf->irq_entries[num_irqs - irqs_left],
 				    n);
 		irqs_left -= n;
-- 
2.11.0
