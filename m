From: swalter@lexmark.com
Subject: [PATCH] dev_alloc_skb: avoid using GFP_ATOMIC
Date: Tue, 29 Sep 2009 12:43:13 -0400
Message-ID: <1254242593-2279-1-git-send-email-swalter@lexmark.com>
Cc: swalter <swalter@swalter-d630 (none) >,
	Steven Walter <swalter@lexmark.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod8og107.obsmtp.com ([64.18.3.94]:60994 "HELO
	exprod8og107.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752884AbZI2Qtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 12:49:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: swalter <swalter@swalter-d630.(none)>


Signed-off-by: Steven Walter <swalter@lpdev.prtdev.lexmark.com>
---
 net/core/skbuff.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 9e0597d..58ec625 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -306,7 +306,11 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
 	 * There is more code here than it seems:
 	 * __dev_alloc_skb is an inline
 	 */
-	return __dev_alloc_skb(length, GFP_ATOMIC);
+	if (in_interrupt()  ||  in_atomic()  ||  irqs_disabled()) {
+		return __dev_alloc_skb(length, GFP_ATOMIC);
+	} else {
+		return __dev_alloc_skb(length, GFP_KERNEL);
+	}
 }
 EXPORT_SYMBOL(dev_alloc_skb);
 
-- 
1.6.2.3.g5bbe6

