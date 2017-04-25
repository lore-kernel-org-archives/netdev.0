From: Myungho Jung <mhjungk@gmail.com>
Subject: [PATCH v3] net: core: Prevent from dereferencing null pointer when releasing SKB
Date: Tue, 25 Apr 2017 11:58:15 -0700
Message-ID: <1493146695-5387-1-git-send-email-mhjungk@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36689 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1953664AbdDYS6R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 14:58:17 -0400
Received: by mail-pf0-f196.google.com with SMTP id v14so10952965pfd.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 11:58:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added NULL check to make __dev_kfree_skb_irq consistent with kfree
family of functions.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289

Signed-off-by: Myungho Jung <mhjungk@gmail.com>
---
Changes in v2:
 - Correct category in subject
Changes in v3:
 - Fix typo in subject

 net/core/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7869ae3..22be2a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2450,6 +2450,9 @@ void __dev_kfree_skb_irq(struct sk_buff *skb, enum skb_free_reason reason)
 {
 	unsigned long flags;
 
+	if (unlikely(!skb))
+		return;
+
 	if (likely(atomic_read(&skb->users) == 1)) {
 		smp_rmb();
 		atomic_set(&skb->users, 0);
-- 
2.7.4
