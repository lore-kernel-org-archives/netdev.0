From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 5/8] NFC: NCI: Don't call setup if previous NCI request failed
Date: Tue, 24 Feb 2015 12:01:49 +0200
Message-ID: <1424772112-27399-6-git-send-email-robert.dolca@intel.com>
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

If the previous nci_request (NCI reset) failed the setup function
was being called anyway. It shouldn't be called if the reset failed.

The result of the setup function is taken into consideration. If it
fails the init should fail.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 net/nfc/nci/core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 1a449ac..d2e7adf 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -365,8 +365,8 @@ static int nci_open_device(struct nci_dev *ndev)
 	rc = __nci_request(ndev, nci_reset_req, 0,
 			   msecs_to_jiffies(NCI_RESET_TIMEOUT));
 
-	if (ndev->ops->setup)
-		ndev->ops->setup(ndev);
+	if (!rc && ndev->ops->setup)
+		rc = ndev->ops->setup(ndev);
 
 	if (!rc) {
 		rc = __nci_request(ndev, nci_init_req, 0,
-- 
1.9.1
