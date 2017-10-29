From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mkiss: remove redundant assignment of len to ax->mtu
Date: Sun, 29 Oct 2017 13:30:25 +0000
Message-ID: <20171029133025.6665-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
        Thomas Osterried <thomas@osterried.de>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Johannes Berg <johannes.berg@intel.com>,
        Ralf Baechle <ralf@linux-mips.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:59949 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751269AbdJ2Naf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 09:30:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Variable len is being assigned a value that is never read,
hence the assignment is redundant and can be removed. Cleans
up clang warning:

drivers/net/hamradio/mkiss.c:443:3: warning: Value stored to
'len' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/hamradio/mkiss.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index 54bf8e6e4a09..c180b480f8ef 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -440,7 +440,6 @@ static void ax_encaps(struct net_device *dev, unsigned char *icp, int len)
 		ax_changedmtu(ax);
 
 	if (len > ax->mtu) {		/* Sigh, shouldn't occur BUT ... */
-		len = ax->mtu;
 		printk(KERN_ERR "mkiss: %s: truncating oversized transmit packet!\n", ax->dev->name);
 		dev->stats.tx_dropped++;
 		netif_start_queue(dev);
-- 
2.14.1
