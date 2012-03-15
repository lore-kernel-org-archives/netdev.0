From: Philipp Zabel <philipp.zabel@gmail.com>
Subject: [PATCH] net/irda: add clk_prepare/clk_unprepare to pxaficp_ir
Date: Thu, 15 Mar 2012 19:19:29 +0100
Message-ID: <1331835569.14662.11.camel@flow>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@marvell.com>,
	Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48716 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408Ab2COSTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2012 14:19:32 -0400
Received: by eekc41 with SMTP id c41so1827781eek.19
        for <netdev@vger.kernel.org>; Thu, 15 Mar 2012 11:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds clk_prepare/clk_unprepare calls to the pxaficp_ir
driver by using the helper functions clk_prepare_enable and
clk_disable_unprepare.

Signed-off-by: Philipp Zabel <philipp.zabel@gmail.com>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@marvell.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/pxaficp_ir.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 81d5275..ff16daf 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -128,20 +128,20 @@ struct pxa_irda {
 static inline void pxa_irda_disable_clk(struct pxa_irda *si)
 {
 	if (si->cur_clk)
-		clk_disable(si->cur_clk);
+		clk_disable_unprepare(si->cur_clk);
 	si->cur_clk = NULL;
 }
 
 static inline void pxa_irda_enable_firclk(struct pxa_irda *si)
 {
 	si->cur_clk = si->fir_clk;
-	clk_enable(si->fir_clk);
+	clk_prepare_enable(si->fir_clk);
 }
 
 static inline void pxa_irda_enable_sirclk(struct pxa_irda *si)
 {
 	si->cur_clk = si->sir_clk;
-	clk_enable(si->sir_clk);
+	clk_prepare_enable(si->sir_clk);
 }
 
 
-- 
1.7.9.1
