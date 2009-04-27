From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH 2/2] gianfar: irq_of_parse_and_map() error unnoticed
Date: Mon, 27 Apr 2009 13:05:30 +0200
Message-ID: <49F5917A.3060909@gmail.com>
References: <49F0649C.8030908@gmail.com> <20090427.031116.43598009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:45810 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553AbZD0LFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 07:05:31 -0400
Received: by ey-out-2122.google.com with SMTP id 9so542049eyd.37
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 04:05:30 -0700 (PDT)
In-Reply-To: <20090427.031116.43598009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

priv->interruptTransmit, -Receive and -Error are unsigned, so the error path
wasn't taken when irq_of_parse_and_map() returned an incorrect irq.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com> 
---
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index b2c4967..55c2ce8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -203,9 +203,9 @@ static int gfar_of_init(struct net_device *dev)
 
 		priv->interruptError = irq_of_parse_and_map(np, 2);
 
-		if (priv->interruptTransmit < 0 ||
-				priv->interruptReceive < 0 ||
-				priv->interruptError < 0) {
+		if (priv->interruptTransmit == NO_IRQ ||
+				priv->interruptReceive == NO_IRQ ||
+				priv->interruptError == NO_IRQ) {
 			err = -EINVAL;
 			goto err_out;
 		}
