From: Hideo AOKI <haoki@redhat.com>
Subject: [RFC PATCH] [NET] [1/2] revert audit_expand()
Date: Tue, 25 Mar 2008 14:41:40 -0400
Message-ID: <47E94764.6050901@redhat.com>
References: <47E946C8.6020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41510 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758964AbYCYSti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 14:49:38 -0400
In-Reply-To: <47E946C8.6020006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch reverts commit 406a1d868001423c85a3165288e566e65f424fe6
to apply bug fix of the root cause to kernel.

I leave the fix of pskb_expand_head() call in the commit. Changing
2nd argument from skb_headroom(skb) to 0 is correct, because
audit_expand() should expand only tail room as its definition.

Signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 audit.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff -pruN net-2.6/kernel/audit.c net-2.6-mod-p1/kernel/audit.c
--- net-2.6/kernel/audit.c	2008-03-24 09:58:26.000000000 -0400
+++ net-2.6-mod-p1/kernel/audit.c	2008-03-24 14:22:18.000000000 -0400
@@ -1117,17 +1117,13 @@ struct audit_buffer *audit_log_start(str
 static inline int audit_expand(struct audit_buffer *ab, int extra)
 {
 	struct sk_buff *skb = ab->skb;
-	int oldtail = skb_tailroom(skb);
 	int ret = pskb_expand_head(skb, 0, extra, ab->gfp_mask);
-	int newtail = skb_tailroom(skb);
 
 	if (ret < 0) {
 		audit_log_lost("out of memory in audit_expand");
 		return 0;
 	}
-
-	skb->truesize += newtail - oldtail;
-	return newtail;
+	return skb_tailroom(skb);
 }
 
 /*
-- 
Hitachi Computer Products (America) Inc.


