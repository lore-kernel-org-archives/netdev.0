From: akpm@osdl.org
Subject: [patch 5/5] drivers cris: return on NULL dev_alloc_skb()
Date: Wed, 08 Nov 2006 19:49:15 -0800
Message-ID: <200611090349.kA93nFUE003603@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, rientjes@cs.washington.edu,
	starvik@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:37550 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965728AbWKIDtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 22:49:49 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Rientjes <rientjes@cs.washington.edu>

If the next descriptor array entry cannot be allocated by dev_alloc_skb(),
return immediately so it is not dereferenced later.  We cannot register the
device with a partial descriptor list.

Cc: Mikael Starvik <starvik@axis.com>
Signed-off-by: David Rientjes <rientjes@cs.washington.edu>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/cris/eth_v10.c |    2 ++
 1 file changed, 2 insertions(+)

diff -puN drivers/net/cris/eth_v10.c~drivers-cris-return-on-null-dev_alloc_skb drivers/net/cris/eth_v10.c
--- a/drivers/net/cris/eth_v10.c~drivers-cris-return-on-null-dev_alloc_skb
+++ a/drivers/net/cris/eth_v10.c
@@ -509,6 +509,8 @@ etrax_ethernet_init(void)
 		 * does not share cacheline with any other data (to avoid cache bug)
 		 */
 		RxDescList[i].skb = dev_alloc_skb(MAX_MEDIA_DATA_SIZE + 2 * L1_CACHE_BYTES);
+		if (!RxDescList[i].skb)
+			return -ENOMEM;
 		RxDescList[i].descr.ctrl   = 0;
 		RxDescList[i].descr.sw_len = MAX_MEDIA_DATA_SIZE;
 		RxDescList[i].descr.next   = virt_to_phys(&RxDescList[i + 1]);
_
