From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/14] tg3: Disable TSS also during tg3_close()
Date: Mon, 2 Aug 2010 14:25:56 -0700
Message-ID: <1280784368-4226-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3033 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755462Ab0HBV0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 17:26:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TSS flag needs to be turned off during tg3_close().  If the device
fails to allocate more than one MSI-X vector the next time the device is
brought up, transmits will fail.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 98ca0d2..12a2dd7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -8864,7 +8864,7 @@ static void tg3_ints_fini(struct tg3 *tp)
 	else if (tp->tg3_flags2 & TG3_FLG2_USING_MSI)
 		pci_disable_msi(tp->pdev);
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI_OR_MSIX;
-	tp->tg3_flags3 &= ~TG3_FLG3_ENABLE_RSS;
+	tp->tg3_flags3 &= ~(TG3_FLG3_ENABLE_RSS | TG3_FLG3_ENABLE_TSS);
 }
 
 static int tg3_open(struct net_device *dev)
-- 
1.7.1


