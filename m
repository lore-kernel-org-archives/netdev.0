From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] NFC: nci/data.c: quiet sparse noise about plain integer as NULL pointer
Date: Thu, 26 Apr 2012 10:31:16 -0700
Message-ID: <201204261031.16737.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<lauro.venancio@openbossa.org>, <aloisio.almeida@openbossa.org>,
	<sameo@linux.intel.com>, <davem@davemloft.net>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pointers should be cleared with NULL, not 0.

Quiets a couple sparse warnings of the type:

warning: Using plain integer as NULL pointer

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>
Cc: Aloisio Almeida Jr <aloisio.almeida@openbossa.org>
Cc: Samuel Ortiz <sameo@linux.intel.com>
Cc: "David S. Miller" <davem@davemloft.net>

---

diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index a0bc326..76c48c5 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -49,7 +49,7 @@ void nci_data_exchange_complete(struct nci_dev *ndev, struct sk_buff *skb,
 
 	if (cb) {
 		ndev->data_exchange_cb = NULL;
-		ndev->data_exchange_cb_context = 0;
+		ndev->data_exchange_cb_context = NULL;
 
 		/* forward skb to nfc core */
 		cb(cb_context, skb, err);
@@ -200,10 +200,10 @@ static void nci_add_rx_data_frag(struct nci_dev *ndev,
 			pr_err("error adding room for accumulated rx data\n");
 
 			kfree_skb(skb);
-			skb = 0;
+			skb = NULL;
 
 			kfree_skb(ndev->rx_data_reassembly);
-			ndev->rx_data_reassembly = 0;
+			ndev->rx_data_reassembly = NULL;
 
 			err = -ENOMEM;
 			goto exit;
@@ -216,7 +216,7 @@ static void nci_add_rx_data_frag(struct nci_dev *ndev,
 
 		/* third, free old reassembly */
 		kfree_skb(ndev->rx_data_reassembly);
-		ndev->rx_data_reassembly = 0;
+		ndev->rx_data_reassembly = NULL;
 	}
 
 	if (pbf == NCI_PBF_CONT) {
