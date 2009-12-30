From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] net: Test off by one in sh_eth_reset()
Date: Wed, 30 Dec 2009 12:43:45 +0100
Message-ID: <4B3B3CF1.6060107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:46882 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbZL3Lkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 06:40:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no break occurred, cnt reaches 0 after the loop.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 drivers/net/sh_eth.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index ca62850..7402b85 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -110,7 +110,7 @@ static void sh_eth_reset(struct net_device *ndev)
 		mdelay(1);
 		cnt--;
 	}
-	if (cnt < 0)
+	if (cnt == 0)
 		printk(KERN_ERR "Device reset fail\n");
 
 	/* Table Init */
