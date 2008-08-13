From: Jean-Christophe Dubois <jcd@tribudubois.net>
Subject: [PATCH] remove unnecessary variable in xfrm_output_resume() 2nd try
Date: Wed, 13 Aug 2008 20:52:55 +0200
Message-ID: <200808132052.55983.jcd@tribudubois.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix1-g20.free.fr ([212.27.60.42]:60160 "EHLO
	postfix1-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbYHMSyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 14:54:01 -0400
Received: from smtp7-g19.free.fr (smtp7-g19.free.fr [212.27.42.64])
	by postfix1-g20.free.fr (Postfix) with ESMTP id 64C76295076E
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 20:54:00 +0200 (CEST)
Received: from smtp7-g19.free.fr (localhost [127.0.0.1])
	by smtp7-g19.free.fr (Postfix) with ESMTP id CD681B0229
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 20:52:58 +0200 (CEST)
Received: from lancelot.dubois.etowns.net (lns-bzn-51f-81-56-146-209.adsl.proxad.net [81.56.146.209])
	by smtp7-g19.free.fr (Postfix) with ESMTP id B224FB0243
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 20:52:57 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small fix removing an unnecessary intermediate variable.

Signed-off-by: Jean-Christophe DUBOIS  <jcd@tribudubois.net>
---

diff -Naur linux-2.6.26.2.org/net/xfrm/xfrm_output.c linux-2.6.26.2/net/xfrm/xfrm_output.c
--- linux-2.6.26.2.org/net/xfrm/xfrm_output.c	2008-08-12 00:37:29.000000000 +0200
+++ linux-2.6.26.2/net/xfrm/xfrm_output.c	2008-08-12 00:40:40.000000000 +0200
@@ -112,16 +112,13 @@
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
-		struct xfrm_state *x;
-
 		nf_reset(skb);
 
 		err = skb->dst->ops->local_out(skb);
 		if (unlikely(err != 1))
 			goto out;
 
-		x = skb->dst->xfrm;
-		if (!x)
+		if (!skb->dst->xfrm)
 			return dst_output(skb);
 
 		err = nf_hook(skb->dst->ops->family,
