From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 4/8] drivers: irda: fix sign bug
Date: Thu, 15 Jul 2010 22:45:29 +0400
Message-ID: <1279219530-12454-1-git-send-email-segooon@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:44479 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934127Ab0GOSp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:45:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

platform_get_irq_byname() can return negative results, it is not seen to
unsigned irq. Make it signed.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 drivers/net/irda/sh_sir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 5c5f99d..00b38bc 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -709,7 +709,7 @@ static int __devinit sh_sir_probe(struct platform_device *pdev)
 	struct sh_sir_self *self;
 	struct resource *res;
 	char clk_name[8];
-	unsigned int irq;
+	int irq;
 	int err = -ENOMEM;
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.7.0.4

