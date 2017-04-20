From: Myungho Jung <mhjungk@gmail.com>
Subject: [PATCH v2] net: core: Prevent from dereferencing null pointer when
Date: Thu, 20 Apr 2017 16:59:20 -0700
Message-ID: <1492732760-25081-1-git-send-email-mhjungk@gmail.com>
Cc: netdev@vger.kernel.org
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:33514 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947407AbdDTX7W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 19:59:22 -0400
Received: by mail-io0-f195.google.com with SMTP id k87so22449644ioi.0
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 16:59:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added NULL check to make __dev_kfree_skb_irq consistent with kfree
family of functions.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=195289

Signed-off-by: Myungho Jung <mhjungk@gmail.com>
---
Changes in v2:
 - Correct category in subject

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
