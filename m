From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] tokenring: Read buffer overflow
Date: Sun, 26 Jul 2009 00:38:33 +0200
Message-ID: <4A6B8969.1080903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:58582 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbZGYWf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 18:35:59 -0400
Received: by ewy26 with SMTP id 26so2451788ewy.37
        for <netdev@vger.kernel.org>; Sat, 25 Jul 2009 15:35:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

io[i] is read before the bounds check on i, order should be reversed

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 9d89611..08a6c41 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -1912,7 +1912,7 @@ static int __init ibmtr_init(void)
 
 	find_turbo_adapters(io);
 
-	for (i = 0; io[i] && (i < IBMTR_MAX_ADAPTERS); i++) {
+	for (i = 0; i < IBMTR_MAX_ADAPTERS && io[i]; i++) {
 		struct net_device *dev;
 		irq[i] = 0;
 		mem[i] = 0;
