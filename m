From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 16/17] net: skb_array additions for unlocked consumer
Date: Tue, 02 May 2017 08:41:11 -0700
Message-ID: <20170502154111.9304.78051.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34412 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750732AbdEBPlX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:41:23 -0400
Received: by mail-pg0-f67.google.com with SMTP id t7so23051227pgt.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:41:23 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/skb_array.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index 33f1f0c..b28db83 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -117,6 +117,11 @@ static inline struct sk_buff *skb_array_consume_bh(struct skb_array *a)
 	return ptr_ring_consume_bh(&a->ring);
 }
 
+static inline struct sk_buff *__skb_array_consume(struct skb_array *a)
+{
+	return __ptr_ring_consume(&a->ring);
+}
+
 static inline int __skb_array_len_with_tag(struct sk_buff *skb)
 {
 	if (likely(skb)) {
