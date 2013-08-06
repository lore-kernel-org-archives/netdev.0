From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 3/3] net: core: fix wrong linkage for ptype_base and ptype_all symbols
Date: Tue,  6 Aug 2013 01:32:51 -0600
Message-ID: <1375774371-831-3-git-send-email-sakiwit@gmail.com>
References: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:47444 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754953Ab3HFHfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 03:35:05 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so368242pad.33
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 00:35:04 -0700 (PDT)
In-Reply-To: <1375774371-831-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 900ff8c6 ("net: move procfs code to net/core/net-procfs.c"),
it changed the correct linkage of ptype_base and ptype_all symbols to
the wrong one in net/core/dev.c, yet failed to change to the correct
linkage of those two in net/core/net-procfs.c.

Fix the wrong linkage by setting static specifier to both sets of the
symbols so that they could have coherent internal linkage by themselves
to avoid interference with each other.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 net/core/dev.c        | 4 ++--
 net/core/net-procfs.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index dfd9f5d..d85e5e1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -142,8 +142,8 @@
 
 static DEFINE_SPINLOCK(ptype_lock);
 static DEFINE_SPINLOCK(offload_lock);
-struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
-struct list_head ptype_all __read_mostly;	/* Taps */
+static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
+static struct list_head ptype_all __read_mostly;	/* Taps */
 static struct list_head offload_base __read_mostly;
 
 /*
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
index 2bf8329..e57cd63 100644
--- a/net/core/net-procfs.c
+++ b/net/core/net-procfs.c
@@ -9,8 +9,8 @@
 #define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
 #define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
 
-extern struct list_head ptype_all __read_mostly;
-extern struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
+static struct list_head ptype_all __read_mostly;
+static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
 
 static inline struct net_device *dev_from_same_bucket(struct seq_file *seq, loff_t *pos)
 {
