From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH] sh_eth: fix branch prediction in sh_eth_interrupt()
Date: Fri, 30 Dec 2016 00:07:38 +0300
Message-ID: <2810883.6xQhqSTVDe@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: ben.hutchings@codethink.co.uk
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33922 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750921AbcL2VHm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 16:07:42 -0500
Received: by mail-lf0-f50.google.com with SMTP id y21so227340990lfa.1
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 13:07:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IIUC, likely()/unlikely() should apply to the whole *if* statement's
expression, not a part of it  -- fix such expression in  sh_eth_interrupt()
accordingly...

Fixes: 283e38db65e7 ("sh_eth: Fix serialisation of interrupt disable with interrupt & NAPI handlers")
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
The patch is against DaveM's 'net-next.git' repo; I'm not sure if it should
be  targeted to the 'net.git' repo instead...

 drivers/net/ethernet/renesas/sh_eth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1656,7 +1656,7 @@ static irqreturn_t sh_eth_interrupt(int
 	else
 		goto out;
 
-	if (!likely(mdp->irq_enabled)) {
+	if (unlikely(!mdp->irq_enabled)) {
 		sh_eth_write(ndev, 0, EESIPR);
 		goto out;
 	}
