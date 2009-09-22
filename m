From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Shutdown iSCSI ring during uio_close.
Date: Mon, 21 Sep 2009 18:39:37 -0700
Message-ID: <1253583577-8027-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	"Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3282 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbZIVBbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2009 21:31:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iSCSI ring should be shutdown during uio_close instead of uio_open
for proper operations.  This fixes the problem of the ring getting
stuck intermittently.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index d45eacb..211c8e9 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -85,8 +85,6 @@ static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 
 	cp->uio_dev = iminor(inode);
 
-	cnic_shutdown_bnx2_rx_ring(dev);
-
 	cnic_init_bnx2_tx_ring(dev);
 	cnic_init_bnx2_rx_ring(dev);
 
@@ -98,6 +96,8 @@ static int cnic_uio_close(struct uio_info *uinfo, struct inode *inode)
 	struct cnic_dev *dev = uinfo->priv;
 	struct cnic_local *cp = dev->cnic_priv;
 
+	cnic_shutdown_bnx2_rx_ring(dev);
+
 	cp->uio_dev = -1;
 	return 0;
 }
-- 
1.6.4.GIT


