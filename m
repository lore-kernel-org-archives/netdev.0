From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] nfp: fix error return code in nfp_net_netdev_open()
Date: Thu, 15 Sep 2016 03:45:07 +0000
Message-ID: <1473911107-8427-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, oss-drivers@netronome.com,
        netdev@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        Rolf Neugebauer <rolf.neugebauer@netronome.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36793 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751516AbcIODpO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 23:45:14 -0400
Received: by mail-pf0-f194.google.com with SMTP id n24so1626345pfb.3
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 20:45:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return a negative error code from the error handling
case instead of 0, as done elsewhere in this function.

Fixes: 73725d9dfd99 ("nfp: allocate ring SW structs dynamically")
Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 252e492..39dadfc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2044,12 +2044,16 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 
 	nn->rx_rings = kcalloc(nn->num_rx_rings, sizeof(*nn->rx_rings),
 			       GFP_KERNEL);
-	if (!nn->rx_rings)
+	if (!nn->rx_rings) {
+		err = -ENOMEM;
 		goto err_free_lsc;
+	}
 	nn->tx_rings = kcalloc(nn->num_tx_rings, sizeof(*nn->tx_rings),
 			       GFP_KERNEL);
-	if (!nn->tx_rings)
+	if (!nn->tx_rings) {
+		err = -ENOMEM;
 		goto err_free_rx_rings;
+	}
 
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		err = nfp_net_prepare_vector(nn, &nn->r_vecs[r], r);
