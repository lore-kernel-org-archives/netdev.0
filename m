From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 3/8] drivers: irda: fix sign bug
Date: Thu, 15 Jul 2010 22:44:54 +0400
Message-ID: <1279219494-12408-1-git-send-email-segooon@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44479 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934118Ab0GOSp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:45:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

platform_get_irq_byname() can return negative results, it is not seen to
unsigned irq. Make it signed.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/irda/sh_irda.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 9a828b0..edd5666 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -749,7 +749,7 @@ static int __devinit sh_irda_probe(struct platform_device *pdev)
 	struct sh_irda_self *self;
 	struct resource *res;
 	char clk_name[8];
-	unsigned int irq;
+	int irq;
 	int err = -ENOMEM;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.7.0.4

