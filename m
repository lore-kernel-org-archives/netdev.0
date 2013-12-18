From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next] lib: hash: follow-up fixups for arch hash
Date: Wed, 18 Dec 2013 16:05:48 +0100
Message-ID: <1387379148-19281-1-git-send-email-ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31945 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754789Ab3LRPFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 10:05:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the include file to pull in __read_mostly on some
architectures e.g. ppc and also fixes up signatures in generic
asm.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 include/asm-generic/hash.h | 4 ++--
 lib/hash.c                 | 1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
index 05cb342..b631284 100644
--- a/include/asm-generic/hash.h
+++ b/include/asm-generic/hash.h
@@ -1,8 +1,8 @@
 #ifndef __ASM_GENERIC_HASH_H
 #define __ASM_GENERIC_HASH_H
 
-struct arch_hash_ops;
-static inline void setup_arch_fast_hash(struct arch_hash_ops *ops)
+struct fast_hash_ops;
+static inline void setup_arch_fast_hash(struct fast_hash_ops *ops)
 {
 }
 
diff --git a/lib/hash.c b/lib/hash.c
index b89f06a..fea973f 100644
--- a/lib/hash.c
+++ b/lib/hash.c
@@ -12,6 +12,7 @@
 
 #include <linux/jhash.h>
 #include <linux/hash.h>
+#include <linux/cache.h>
 
 static struct fast_hash_ops arch_hash_ops __read_mostly = {
 	.hash  = jhash,
-- 
1.8.3.1
