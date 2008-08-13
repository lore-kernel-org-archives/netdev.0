From: Jean-Christophe Dubois <jcd@tribudubois.net>
Subject: [PATCH] remove unnecessary variable in xfrm_output_resume()
Date: Wed, 13 Aug 2008 07:48:01 +0200
Message-ID: <200808130748.02368.jcd@tribudubois.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g19.free.fr ([212.27.42.27]:58544 "EHLO smtp1-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486AbYHMFsF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 01:48:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small fix removing an unnecessary intermediate variable.

Signed-off-by: Jean-Christophe DUBOIS  <jcd@tribudubois.net>
---

diff -Naur linux-2.6.26.2.org/net/xfrm/xfrm_output.c linux-2.6.26.2/net/xfrm/xfrm_output.c
--- linux-2.6.26.2.org/net/xfrm/xfrm_output.c   2008-08-12 00:37:29.000000000 +0200
+++ linux-2.6.26.2/net/xfrm/xfrm_output.c       2008-08-12 00:40:40.000000000 +0200
@@ -112,16 +112,13 @@
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
        while (likely((err = xfrm_output_one(skb, err)) == 0)) {
-               struct xfrm_state *x;
-
                nf_reset(skb);

                err = skb->dst->ops->local_out(skb);
                if (unlikely(err != 1))
                        goto out;

-               x = skb->dst->xfrm;
-               if (!x)
+               if (!skb->dst->xfrm)
                        return dst_output(skb);

                err = nf_hook(skb->dst->ops->family,
