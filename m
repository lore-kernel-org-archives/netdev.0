From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] netdev: enc28j60: use IRQF_TRIGGER_FALLING for IRQ by default
Date: Tue, 26 May 2009 06:16:47 -0400
Message-ID: <1243333007-25645-1-git-send-email-vapier@gentoo.org>
Cc: Michael Hennerich <michael.hennerich@analog.com>,
	Bryan Wu <cooloney@kernel.org>,
	Baruch Siach <baruch@tkos.co.il>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:35088 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106AbZEZKQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 06:16:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

Rather than have the default IRQ flags not be usable, use the logical
settings which match the hardware.  Since the part is /INT, it makes sense
to have it default to a falling trigger.  If a board truly needs something
different, it still can tweak the defaults in its own board file.

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
Signed-off-by: Bryan Wu <cooloney@kernel.org>
CC: Baruch Siach <baruch@tkos.co.il>
---
 drivers/net/enc28j60.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 36cb6e9..fbe2012 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1562,7 +1562,7 @@ static int __devinit enc28j60_probe(struct spi_device *spi)
 	/* Board setup must set the relevant edge trigger type;
 	 * level triggers won't currently work.
 	 */
-	ret = request_irq(spi->irq, enc28j60_irq, 0, DRV_NAME, priv);
+	ret = request_irq(spi->irq, enc28j60_irq, IRQF_TRIGGER_FALLING, DRV_NAME, priv);
 	if (ret < 0) {
 		if (netif_msg_probe(priv))
 			dev_err(&spi->dev, DRV_NAME ": request irq %d failed "
-- 
1.6.3.1

