From: Matthias Ludwig <mludwig@ultratronik.de>
Subject: [PATCH] smsc911x: fix calculation of res_size for ioremap
Date: Wed,  6 May 2009 14:45:56 +0200
Message-ID: <1241613956-7940-1-git-send-email-mludwig@ultratronik.de>
Cc: steve.glendinning@smsc.com,
	Matthias Ludwig <mludwig@ultratronik.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ultratronik.de ([82.100.224.114]:57985 "EHLO
	build.ultratronik.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752567AbZEFNUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 09:20:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix size of remaped iomem, which is 1 byte to small
(e.g. mappes only 0xff bytes instead of 0x100)

Signed-off-by: Matthias Ludwig <mludwig@ultratronik.de>
---
 drivers/net/smsc911x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
index eb7db03..1a44be0 100644
--- a/drivers/net/smsc911x.c
+++ b/drivers/net/smsc911x.c
@@ -1963,7 +1963,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 		retval = -ENODEV;
 		goto out_0;
 	}
-	res_size = res->end - res->start;
+	res_size = res->end - res->start + 1;
 
 	irq_res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
 	if (!irq_res) {
-- 
1.6.3.rc4.29.g8146

