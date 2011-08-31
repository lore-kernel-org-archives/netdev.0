From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 04/14] macvtap: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:46:56 +0100
Message-ID: <1314787626-12273-4-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753954Ab1HaKrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:12 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/macvtap.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index ab96c31..7c3f84a 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -503,10 +503,10 @@ static int zerocopy_sg_from_iovec(struct sk_buff *skb, const struct iovec *from,
 		skb->truesize += len;
 		atomic_add(len, &skb->sk->sk_wmem_alloc);
 		while (len) {
-			f = &skb_shinfo(skb)->frags[i];
-			f->page = page[i];
-			f->page_offset = base & ~PAGE_MASK;
-			f->size = min_t(int, len, PAGE_SIZE - f->page_offset);
+			__skb_fill_page_desc(
+				skb, i, page[i],
+				base & ~PAGE_MASK,
+				min_t(int, len, PAGE_SIZE - f->page_offset));
 			skb_shinfo(skb)->nr_frags++;
 			/* increase sk_wmem_alloc */
 			base += f->size;
-- 
1.7.2.5
