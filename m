From: "Figo.zhang" <figo1802@gmail.com>
Subject: [PATCH] fix a race in ks8695_poll
Date: Sat, 06 Mar 2010 10:36:02 +0800
Message-ID: <1267842962.2669.2.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Yegor Yefremov <yegorslists@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:56466 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440Ab0CFCgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 21:36:09 -0500
Received: by gyd10 with SMTP id 10so127558gyd.19
        for <netdev@vger.kernel.org>; Fri, 05 Mar 2010 18:36:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix a race at the end of NAPI processing in ks8695_poll() function.

Signed-off-by:Figo.zhang <figo1802@gmail.com>
--- 
drivers/net/arm/ks8695net.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/arm/ks8695net.c b/drivers/net/arm/ks8695net.c
index be256b3..ecd5819 100644
--- a/drivers/net/arm/ks8695net.c
+++ b/drivers/net/arm/ks8695net.c
@@ -576,9 +576,9 @@ static int ks8695_poll(struct napi_struct *napi, int budget)
 	if (work_done < budget) {
 		unsigned long flags;
 		spin_lock_irqsave(&ksp->rx_lock, flags);
+		__napi_complete(napi);
 		/*enable rx interrupt*/
 		writel(isr | mask_bit, KS8695_IRQ_VA + KS8695_INTEN);
-		__napi_complete(napi);
 		spin_unlock_irqrestore(&ksp->rx_lock, flags);
 	}
 	return work_done;


