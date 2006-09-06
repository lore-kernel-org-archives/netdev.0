From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] skge: heck for PCI hotplug during IRQ
Date: Wed, 6 Sep 2006 11:06:10 -0700
Message-ID: <20060906110610.0aba36a0@localhost.localdomain>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
	<20060901225449.239532256@zqx3.pdx.osdl.net>
	<44FEE6F1.7010701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23719 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751467AbWIFSK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:10:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44FEE6F1.7010701@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Check if IRQ came from hardware fault (hotplug).

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 drivers/net/skge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

7e83b6245b11158875757ab346ca6d0954ecb95e
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 3f1b72e..fba8b74 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -2884,7 +2884,7 @@ static irqreturn_t skge_intr(int irq, vo
 	spin_lock(&hw->hw_lock);
 	/* Reading this register masks IRQ */
 	status = skge_read32(hw, B0_SP_ISRC);
-	if (status == 0)
+	if (status == 0 || status == ~0)
 		goto out;
 
 	handled = 1;
-- 
1.2.4

