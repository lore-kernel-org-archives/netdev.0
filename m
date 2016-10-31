From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/14] nfp: create separate define for max number of vectors
Date: Mon, 31 Oct 2016 20:43:18 +0000
Message-ID: <1477946602-19644-11-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38397 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030447AbcJaUoI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:08 -0400
Received: by mail-wm0-f41.google.com with SMTP id n67so251680728wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:08 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently using define for max TX rings to allocate IRQ
vectors.  It's OK since the max number of rings for TX and RX
are currently the same, but lets make the code nicer by taking
max of the two.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 9ca066b29f07..55a497c02237 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -87,6 +87,9 @@
 /* Queue/Ring definitions */
 #define NFP_NET_MAX_TX_RINGS	64	/* Max. # of Tx rings per device */
 #define NFP_NET_MAX_RX_RINGS	64	/* Max. # of Rx rings per device */
+#define NFP_NET_MAX_R_VECS	(NFP_NET_MAX_TX_RINGS > NFP_NET_MAX_RX_RINGS ? \
+				 NFP_NET_MAX_TX_RINGS : NFP_NET_MAX_RX_RINGS)
+#define NFP_NET_MAX_IRQS	(NFP_NET_NON_Q_VECTORS + NFP_NET_MAX_R_VECS)
 
 #define NFP_NET_MIN_TX_DESCS	256	/* Min. # of Tx descs per ring */
 #define NFP_NET_MIN_RX_DESCS	256	/* Min. # of Rx descs per ring */
@@ -539,9 +542,8 @@ struct nfp_net {
 
 	u8 num_irqs;
 	u8 num_r_vecs;
-	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_TX_RINGS];
-	struct msix_entry irq_entries[NFP_NET_NON_Q_VECTORS +
-				      NFP_NET_MAX_TX_RINGS];
+	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_R_VECS];
+	struct msix_entry irq_entries[NFP_NET_MAX_IRQS];
 
 	irq_handler_t lsc_handler;
 	char lsc_name[IFNAMSIZ + 8];
-- 
1.9.1
