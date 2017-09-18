From: Duan Jiong <djduanjiong@gmail.com>
Subject: [PATCH net-next] net: remove useless comments in dst.c
Date: Mon, 18 Sep 2017 14:00:23 +0800
Message-ID: <CALttK1QuA3tSdfSUPoYtoQV5reJdsVOicLX_9iN1TkwY6De6HQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: weiwan@google.com
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:32978 "EHLO
        mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdIRGAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 02:00:25 -0400
Received: by mail-lf0-f66.google.com with SMTP id y15so3948730lfd.0
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2017 23:00:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dst gc related code has been removed in commit
5b7c9a8ff828, so those comments are no longer
useful.

Signed-off-by: Duan Jiong <jduan@fiberhome.com>
---
 net/core/dst.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index a6c47da..a710d39 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -25,23 +25,6 @@
 #include <net/dst.h>
 #include <net/dst_metadata.h>

-/*
- * Theory of operations:
- * 1) We use a list, protected by a spinlock, to add
- *    new entries from both BH and non-BH context.
- * 2) In order to keep spinlock held for a small delay,
- *    we use a second list where are stored long lived
- *    entries, that are handled by the garbage collect thread
- *    fired by a workqueue.
- * 3) This list is guarded by a mutex,
- *    so that the gc_task and dst_dev_event() can be synchronized.
- */
-
-/*
- * We want to keep lock & list close together
- * to dirty as few cache lines as possible in __dst_free().
- * As this is not a very strong hint, we dont force an alignment on SMP.
- */
 int dst_discard_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
  kfree_skb(skb);
-- 
2.9.3
