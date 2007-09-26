From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [5/6] pasemi_mac: flags as passed to spin_*_irqsave()
	should be unsigned long
Date: Wed, 26 Sep 2007 16:23:59 -0500
Message-ID: <20070926212359.GE24168@lixom.net>
References: <20070926212200.GA24168@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:49458 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761164AbXIZVUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 17:20:50 -0400
Content-Disposition: inline
In-Reply-To: <20070926212200.GA24168@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: flags as passed to spin_*_irqsave() should be unsigned long.

Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
Signed-off-by: Olof Johansson <olof@lixom.net>

---
Found trying to build a -rt kernel, which has a BUILD_BUG_ON(), in this
caswe.

 drivers/net/pasemi_mac.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -557,7 +557,7 @@ static int pasemi_mac_clean_tx(struct pa
 	struct pas_dma_xct_descr *dp;
 	unsigned int start, count, limit;
 	unsigned int total_count;
-	int flags;
+	unsigned long flags;
 	struct sk_buff *skbs[32];
 	dma_addr_t dmas[32];
 
@@ -978,7 +978,7 @@ static int pasemi_mac_start_tx(struct sk
 	struct pas_dma_xct_descr *dp;
 	u64 dflags, mactx, ptr;
 	dma_addr_t map;
-	int flags;
+	unsigned long flags;
 
 	dflags = XCT_MACTX_O | XCT_MACTX_ST | XCT_MACTX_SS | XCT_MACTX_CRC_PAD;
 
