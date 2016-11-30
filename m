From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] net: atarilance: use %8ph for printing hex string
Date: Wed, 30 Nov 2016 23:02:54 +0100
Message-ID: <1480543375-28904-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Felipe Balbi <felipe.balbi@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f173.google.com ([209.85.210.173]:35030 "EHLO
        mail-wj0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752437AbcK3WDJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 17:03:09 -0500
Received: by mail-wj0-f173.google.com with SMTP id v7so188087854wjy.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:03:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is already using the %pM printf extension; might as well also use
%ph to make the code smaller.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/amd/atarilance.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index d2bc8e5dcd23..d208a0532811 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -1013,13 +1013,9 @@ static int lance_rx( struct net_device *dev )
 					u_char *data = PKTBUF_ADDR(head);
 
 					printk(KERN_DEBUG "%s: RX pkt type 0x%04x from %pM to %pM "
-						   "data %02x %02x %02x %02x %02x %02x %02x %02x "
-						   "len %d\n",
+						   "data %8ph len %d\n",
 						   dev->name, ((u_short *)data)[6],
-						   &data[6], data,
-						   data[15], data[16], data[17], data[18],
-						   data[19], data[20], data[21], data[22],
-						   pkt_len);
+						   &data[6], data, &data[15], pkt_len);
 				}
 
 				skb_reserve( skb, 2 );	/* 16 byte align */
-- 
2.1.4
