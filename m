From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Subject: [PATCH] fix a race at the end of NAPI
Date: Tue, 08 Jun 2010 14:48:39 +0800
Message-ID: <1275979719.1927.4.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [61.172.199.14] ([61.172.199.14]:63811 "EHLO
	LC-SHMAIL-01.SHANGHAI.LEADCORETECH.COM" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752935Ab0FHHAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 03:00:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


fix a race at the end of NAPI complete processing. it had better do __napi_complete() 
first before re-enable interrupt.

Signed-off-by: Figo.zhang <figo1802@gmail.com>
--- 
 drivers/net/8139cp.c  |    2 +-
 drivers/net/8139too.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
old mode 100644
new mode 100755
index 9c14975..284a5f4
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -598,8 +598,8 @@ rx_next:
 			goto rx_status_loop;
 
 		spin_lock_irqsave(&cp->lock, flags);
-		cpw16_f(IntrMask, cp_intr_mask);
 		__napi_complete(napi);
+		cpw16_f(IntrMask, cp_intr_mask);
 		spin_unlock_irqrestore(&cp->lock, flags);
 	}
 
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
old mode 100644
new mode 100755
index 4ba7293..a7bca8c
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -2088,8 +2088,8 @@ static int rtl8139_poll(struct napi_struct *napi, int budget)
 		 * again when we think we are done.
 		 */
 		spin_lock_irqsave(&tp->lock, flags);
-		RTL_W16_F(IntrMask, rtl8139_intr_mask);
 		__napi_complete(napi);
+		RTL_W16_F(IntrMask, rtl8139_intr_mask);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
 	spin_unlock(&tp->rx_lock);


