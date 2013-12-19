From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Thu, 19 Dec 2013 14:09:14 -0500 (EST)
Message-ID: <20131219.140914.1059872546032993195.davem@davemloft.net>
References: <20131219115710.598bdf6314b4784703a07100@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, ffusco@redhat.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131219115710.598bdf6314b4784703a07100@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 19 Dec 2013 11:57:10 +1100

> Caused by commit 71ae8aac3e19 ("lib: introduce arch optimized hash
> library").  Read Rule 1 in Documentation/SubmitChecklist :-(  Hint:
> __read_mostly is defined in linux/cache.h ...
> 
> I have used the net-next tree from next-20131217 again today.

Sorry for this breaking in two different ways two days in a row :-/

I hope with the following commit everything is good now:

====================
>From 237217546d44fe06c16b8895eecaef22f18ba5ee Mon Sep 17 00:00:00 2001
From: Francesco Fusco <ffusco@redhat.com>
Date: Wed, 18 Dec 2013 16:05:48 +0100
Subject: [PATCH] lib: hash: follow-up fixups for arch hash

This patch adds the include file to pull in __read_mostly on some
architectures e.g. ppc and also fixes up signatures in generic
asm.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Francesco Fusco <ffusco@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
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
1.7.11.7
