From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Increase 5906 firmware poll time.
Date: Tue, 14 Nov 2006 14:42:23 -0800
Message-ID: <1163544143.4954.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3845 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S966392AbWKNVtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 16:49:50 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Increase 5906 firmware poll time.
From: Gary Zambrano <zambrano@broadcom.com>

Newer 5906 bootcode needs about 7ms to finish resetting so the poll
firmware loop was changed to maximum 20ms.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8f059b7..d4b211c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4728,10 +4728,11 @@ static int tg3_poll_fw(struct tg3 *tp)
 	u32 val;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
-		for (i = 0; i < 400; i++) {
+		/* Wait up to 20ms for init done. */
+		for (i = 0; i < 200; i++) {
 			if (tr32(VCPU_STATUS) & VCPU_STATUS_INIT_DONE)
 				return 0;
-			udelay(10);
+			udelay(100);
 		}
 		return -ENODEV;
 	}


