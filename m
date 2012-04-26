From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: [PATCH] NFC: nci/ntf.c: quiet sparse noise about plain integer as NULL pointer
Date: Thu, 26 Apr 2012 10:59:28 -0700
Message-ID: <201204261059.28568.hartleys@visionengravers.com>
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

diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index 99e1632..cb26461 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -497,7 +497,7 @@ static void nci_rf_deactivate_ntf_packet(struct nci_dev *ndev,
 	/* drop partial rx data packet */
 	if (ndev->rx_data_reassembly) {
 		kfree_skb(ndev->rx_data_reassembly);
-		ndev->rx_data_reassembly = 0;
+		ndev->rx_data_reassembly = NULL;
 	}
 
 	/* complete the data exchange transaction, if exists */
