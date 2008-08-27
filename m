From: Kevin Lo <kevlo@kevlo.org>
Subject: [PATCH] 8139too: use netdev_alloc_skb
Date: Wed, 27 Aug 2008 11:35:13 +0800
Message-ID: <1219808113.7135.13.camel@nsl>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-d5yxhrZNCqvulzpY5qpR"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kevlo.org ([220.128.136.52]:53608 "EHLO ns.kevlo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbYH0EI1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 00:08:27 -0400
Received: from [127.0.0.1] (ns.kevlo.org [220.128.136.52])
	by ns.kevlo.org (8.14.3/8.14.3) with ESMTP id m7R3ZaWE005602
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 11:35:41 +0800 (CST)
	(envelope-from kevlo@kevlo.org)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-d5yxhrZNCqvulzpY5qpR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi,

This patch uses netdev_alloc_skb. This sets skb->dev and allows 
arch specific allocation. Also cleanup the alignment code.

Tested on x86_64.

Signed-off-by:	Kevin Lo <kevlo@kevlo.org>

--=-d5yxhrZNCqvulzpY5qpR
Content-Disposition: attachment; filename=patch-8139too
Content-Type: text/x-patch; name=patch-8139too; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- linux-2.6.27-rc4/drivers/net/8139too.c.orig	2008-08-26 16:52:59.000000000 +0800
+++ linux-2.6.27-rc4/drivers/net/8139too.c	2008-08-27 09:38:36.000000000 +0800
@@ -2009,9 +2009,9 @@ no_early_rx:
 		/* Malloc up new buffer, compatible with net-2e. */
 		/* Omit the four octet CRC from the length. */
 
-		skb = dev_alloc_skb (pkt_size + 2);
+		skb = netdev_alloc_skb(dev, pkt_size + NET_IP_ALIGN);
 		if (likely(skb)) {
-			skb_reserve (skb, 2);	/* 16 byte align the IP fields. */
+			skb_reserve (skb, NET_IP_ALIGN);	/* 16 byte align the IP fields. */
 #if RX_BUF_IDX == 3
 			wrap_copy(skb, rx_ring, ring_offset+4, pkt_size);
 #else

--=-d5yxhrZNCqvulzpY5qpR--

