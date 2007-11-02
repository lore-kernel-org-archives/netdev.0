From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NET: Remove unneeded type cast in skb_truesize_check()
Date: Fri, 02 Nov 2007 15:14:26 -0400
Message-ID: <20071102191426.30464.7490.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:38212 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753282AbXKBTXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 15:23:20 -0400
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id lA2JEVTV000653
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 12:14:32 -0700
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id lA2JEQRH030480
	for <netdev@vger.kernel.org>; Fri, 2 Nov 2007 15:14:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The (int) type cast in skb_truesize_check() is unneeded: without it, all
the variable types in the conditional expression are unsigned integers.  As
it stands, the type cast causes a comparison between a signed and an
unsigned integer, which can produce unexpected results.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/skbuff.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 94e4991..7965216 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -387,7 +387,7 @@ extern void	      skb_truesize_bug(struct sk_buff *skb);
 
 static inline void skb_truesize_check(struct sk_buff *skb)
 {
-	if (unlikely((int)skb->truesize < sizeof(struct sk_buff) + skb->len))
+	if (unlikely(skb->truesize < sizeof(struct sk_buff) + skb->len))
 		skb_truesize_bug(skb);
 }
 

