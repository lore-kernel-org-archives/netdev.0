From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 7/9] net: r6040: Utilize napi_complete_done()
Date: Mon,  4 Jul 2016 14:36:07 -0700
Message-ID: <1467668169-31547-8-git-send-email-f.fainelli@gmail.com>
References: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:35728 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932582AbcGDVgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 17:36:20 -0400
Received: by mail-oi0-f67.google.com with SMTP id d132so24947745oig.2
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 14:36:20 -0700 (PDT)
In-Reply-To: <1467668169-31547-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We maintain how much work we did in NAPI context, so provide that with
napi_complete_done().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 13ff80088268..c0256b865ff9 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -648,7 +648,7 @@ static int r6040_poll(struct napi_struct *napi, int budget)
 	work_done = r6040_rx(dev, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		/* Enable RX/TX interrupt */
 		iowrite16(ioread16(ioaddr + MIER) | RX_INTS | TX_INTS,
 			  ioaddr + MIER);
-- 
2.7.4
