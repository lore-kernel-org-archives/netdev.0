From: Marcus Meissner <meissner@suse.de>
Subject: [PATCH] use correct array index. (array is just 6 bytes long)
Date: Thu, 16 Aug 2007 16:06:07 +0200
Message-ID: <20070816140607.GA26206@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-tr@linuxtr.net, mikep@linuxtr.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:36449 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759256AbXHPOGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 10:06:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcus Meissner <meissner@suse.de>

Use correct array index (goes from 0-6 instead of 10-16).

Signed-Off-By: Marcus Meissner <meissner@suse.de>
---
 drivers/net/tokenring/3c359.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 9f1b6ab..5e2437e 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -763,7 +763,7 @@ static int xl_open_hw(struct net_device
 	if (xl_priv->xl_laa[0]) {  /* If using a LAA address */
 		for (i=10;i<16;i++) { 
 			writel( (MEM_BYTE_WRITE | 0xD0000 | xl_priv->srb) + i, xl_mmio + MMIO_MAC_ACCESS_CMD) ; 
-			writeb(xl_priv->xl_laa[i],xl_mmio + MMIO_MACDATA) ; 
+			writeb(xl_priv->xl_laa[i-10],xl_mmio + MMIO_MACDATA) ;
 		}
 		memcpy(dev->dev_addr,xl_priv->xl_laa,dev->addr_len) ; 
 	} else { /* Regular hardware address */ 
-- 
1.4.3.4
