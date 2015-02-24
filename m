From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 1/8] NFC: NCI: Allow connection close with dev down
Date: Tue, 24 Feb 2015 12:01:45 +0200
Message-ID: <1424772112-27399-2-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

By calling __nci_request instead of nci_request allows the driver to use
the function while initializing the device (setup stage)

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 net/nfc/nci/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 9575a18..c4dd5d8 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -558,7 +558,7 @@ static void nci_core_conn_close_req(struct nci_dev *ndev, unsigned long opt)
 
 int nci_core_conn_close(struct nci_dev *ndev, u8 conn_id)
 {
-	return nci_request(ndev, nci_core_conn_close_req, conn_id,
+	return __nci_request(ndev, nci_core_conn_close_req, conn_id,
 				msecs_to_jiffies(NCI_CMD_TIMEOUT));
 }
 EXPORT_SYMBOL(nci_core_conn_close);
-- 
1.9.1
