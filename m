From: gfree.wind@vip.163.com
Subject: [PATCH net-next v2] net: Remove useless function skb_header_release
Date: Fri, 22 Sep 2017 10:25:22 +0800
Message-ID: <1506047122-71116-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m181-177.vip.163.com ([123.58.177.181]:56311 "EHLO
        m181-177.vip.163.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdIVCZn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 22:25:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <gfree.wind@vip.163.com>

There is no one which would invokes the function skb_header_release.
So just remove it now.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 v2: Correct some comments, per Joe
 v1: initial version

 drivers/net/usb/asix_common.c   |  2 +-
 include/linux/skbuff.h          | 19 -------------------
 net/batman-adv/soft-interface.c |  2 +-
 3 files changed, 2 insertions(+), 21 deletions(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 522d290..f4d7362 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -245,7 +245,7 @@ struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
 	 * - We are allowed to put 4 bytes at tail if skb_cloned()
 	 *   is false (and if we have 4 bytes of tailroom)
 	 *
-	 * TCP packets for example are cloned, but skb_header_release()
+	 * TCP packets for example are cloned, but __skb_header_release()
 	 * was called in tcp stack, allowing us to use headroom for our needs.
 	 */
 	if (!skb_header_cloned(skb) &&
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4928288..f9db553 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1457,27 +1457,8 @@ static inline int skb_header_unclone(struct sk_buff *skb, gfp_t pri)
 }
 
 /**
- *	skb_header_release - release reference to header
- *	@skb: buffer to operate on
- *
- *	Drop a reference to the header part of the buffer.  This is done
- *	by acquiring a payload reference.  You must not read from the header
- *	part of skb->data after this.
- *	Note : Check if you can use __skb_header_release() instead.
- */
-static inline void skb_header_release(struct sk_buff *skb)
-{
-	BUG_ON(skb->nohdr);
-	skb->nohdr = 1;
-	atomic_add(1 << SKB_DATAREF_SHIFT, &skb_shinfo(skb)->dataref);
-}
-
-/**
  *	__skb_header_release - release reference to header
  *	@skb: buffer to operate on
- *
- *	Variant of skb_header_release() assuming skb is private to caller.
- *	We can avoid one atomic operation.
  */
 static inline void __skb_header_release(struct sk_buff *skb)
 {
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 10f7edf..c2c9867 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -69,7 +69,7 @@ int batadv_skb_head_push(struct sk_buff *skb, unsigned int len)
 	int result;
 
 	/* TODO: We must check if we can release all references to non-payload
-	 * data using skb_header_release in our skbs to allow skb_cow_header to
+	 * data using __skb_header_release in our skbs to allow skb_cow_header to
 	 * work optimally. This means that those skbs are not allowed to read
 	 * or write any data which is before the current position of skb->data
 	 * after that call and thus allow other skbs with the same data buffer
-- 
1.9.1
