From: mjr@cs.wisc.edu
Subject: [PATCH] Fix missing mutex_lock/unlock
Date: Thu, 12 Apr 2012 10:26:36 -0500
Message-ID: <1334244396-6978-1-git-send-email-mjr@cs.wisc.edu>
Cc: sboyd@codeaurora.org, ben@simtec.co.uk, netdev@vger.kernel.org,
	Matt Renzelmann <mjr@cs.wisc.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:46964 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934343Ab2DLP3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2012 11:29:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Renzelmann <mjr@cs.wisc.edu>

All calls to ks8851_rdreg* and ks8851_wrreg* should be protected
with the driver's lock mutex.  A spurious interrupt may otherwise cause a
crash.

Signed-off-by: Matt Renzelmann <mjr@cs.wisc.edu>
---
Hello,

I'm new to the kernel development process so I hope I've not screwed
this up with this extra text.  We found a potential issue using a new
driver testing tool called SymDrive.  It looks legitimate to me, so
I'm reporting it.  We hope to make this tool available in the future.
Please let me know if I should modify the patch or re-send without
this commentary.  Thanks in advance for your patience.

 drivers/net/ethernet/micrel/ks8851.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ks8851.c b/drivers/net/ethernet/micrel/ks8851.c
index c722aa6..fa2001a 100644
--- a/drivers/net/ethernet/micrel/ks8851.c
+++ b/drivers/net/ethernet/micrel/ks8851.c
@@ -1515,11 +1515,15 @@ static int __devinit ks8851_probe(struct spi_device *spi)
 		goto err_netdev;
 	}
 
+	mutex_lock(&ks->lock);
+
 	netdev_info(ndev, "revision %d, MAC %pM, IRQ %d, %s EEPROM\n",
 		    CIDER_REV_GET(ks8851_rdreg16(ks, KS_CIDER)),
 		    ndev->dev_addr, ndev->irq,
 		    ks->rc_ccr & CCR_EEPROM ? "has" : "no");
 
+	mutex_unlock(&ks->lock);
+
 	return 0;
 
 
-- 
1.7.5.4
