From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net patch 2/2] bnx2x: Correct the ndo_poll_controller call
Date: Mon, 27 Aug 2012 16:26:20 +0300
Message-ID: <1346073980-30901-3-git-send-email-meravs@broadcom.com>
References: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2382 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab2H0KS0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2012 06:18:26 -0400
In-Reply-To: <1346073980-30901-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch correct poll_bnx2x (ndo_poll_controller call) which was not
functioning well with MSI-X.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index f6d6baf..ce03456 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11244,10 +11244,12 @@ static int bnx2x_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 static void poll_bnx2x(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	int i;

-	disable_irq(bp->pdev->irq);
-	bnx2x_interrupt(bp->pdev->irq, dev);
-	enable_irq(bp->pdev->irq);
+	for_each_eth_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		napi_schedule(&bnx2x_fp(bp, fp->index, napi));
+	}
 }
 #endif

--
1.7.10---
