From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: [PATCH 17/29] LMC: don't wait in lmc_trace().
Date: Sat, 31 Jul 2010 17:05:40 +0200
Message-ID: <1280588752-9340-17-git-send-email-khc@pm.waw.pl>
References: <m3fwyzzpjf.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45257 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756573Ab0GaPGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jul 2010 11:06:24 -0400
In-Reply-To: <m3fwyzzpjf.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>

Signed-off-by: Krzysztof Ha=C5=82asa <khc@pm.waw.pl>
---
 drivers/net/wan/lmc/var.h |   13 ++-----------
 1 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wan/lmc/var.h b/drivers/net/wan/lmc/var.h
index f5b233c..38f61cb 100644
--- a/drivers/net/wan/lmc/var.h
+++ b/drivers/net/wan/lmc/var.h
@@ -434,19 +434,10 @@ extern struct media lmc_hssi_media;
 static inline void lmc_trace(struct net_device *dev, char *msg)
 {
 #ifdef LMC_TRACE
-	unsigned long j =3D jiffies + 3; /* Wait for 50 ms */
-
-	if (in_interrupt()) {
+	if (in_interrupt())
 		printk(KERN_DEBUG "%s: * %s\n", dev->name, msg);
-#if 0
-		while (time_before(jiffies, j + 10))
-			;
-#endif
-	} else {
+	else
 		printk(KERN_DEBUG "%s: %s\n", dev->name, msg);
-		while (time_before(jiffies, j))
-			schedule();
-	}
 #endif
 }
=20
--=20
1.7.1.1

