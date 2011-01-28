From: Stefan Weil <weil@mail.berlios.de>
Subject: [PATCH] enc28j60: Fix reading of transmit status vector
Date: Fri, 28 Jan 2011 23:25:19 +0100
Message-ID: <1296253519-7580-1-git-send-email-weil@mail.berlios.de>
Cc: Stefan Weil <weil@mail.berlios.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:60807 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752272Ab1A1WZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:25:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This error was reported by cppcheck:
drivers/net/enc28j60.c:815: error: Using sizeof for array given as function argument returns the size of pointer.

The original code reads 4 or 8 bytes instead of TSV_SIZE (= 100) bytes.
I just fixed the code, but did not run any tests.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Jiri Pirko <jpirko@redhat.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Stefan Weil <weil@mail.berlios.de>
---
 drivers/net/enc28j60.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 112c5aa..907b05a 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -812,7 +812,7 @@ static void enc28j60_read_tsv(struct enc28j60_net *priv, u8 tsv[TSV_SIZE])
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": reading TSV at addr:0x%04x\n",
 			 endptr + 1);
-	enc28j60_mem_read(priv, endptr + 1, sizeof(tsv), tsv);
+	enc28j60_mem_read(priv, endptr + 1, TSV_SIZE, tsv);
 }
 
 static void enc28j60_dump_tsv(struct enc28j60_net *priv, const char *msg,
-- 
1.7.2.3

