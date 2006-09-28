From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [Patch] check dev_alloc_skb() return value in s2io.c
Date: Thu, 28 Sep 2006 15:16:26 +0200
Message-ID: <1159449386.8136.6.camel@alice>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.20]:10374 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751795AbWI1NQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 09:16:28 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

coverity spotted two dev_alloc_skb() calls,
where we use the return value without checking it
for NULL. This patch simply adds the check, including
the debug message that is used in all other dev_alloc_skb()
calls.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.18-git8/drivers/net/s2io.c.orig	2006-09-28 01:25:36.000000000 +0200
+++ linux-2.6.18-git8/drivers/net/s2io.c	2006-09-28 01:26:32.000000000 +0200
@@ -5989,6 +5989,12 @@ static int set_rxd_buffer_pointer(nic_t 
 			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1;
 		} else {
 			*skb = dev_alloc_skb(size);
+			if (!*skb) {
+				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
+					failed\n ", dev->name);
+					return -ENOMEM;
+			}
+
 			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
@@ -6011,6 +6017,11 @@ static int set_rxd_buffer_pointer(nic_t 
 			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2;
 		} else {
 			*skb = dev_alloc_skb(size);
+			if (!*skb) {
+				DBG_PRINT(ERR_DBG, "%s: dev_alloc_skb \
+					failed\n ", dev->name);
+				return -ENOMEM;
+			}
 
 			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0 =
 				pci_map_single(sp->pdev, ba->ba_0, BUF0_LEN,


