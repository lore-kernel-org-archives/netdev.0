From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 3/6] rhashtable-test: Get rid of ptr in test_obj structure
Date: Thu, 30 Apr 2015 22:37:42 +0000
Message-ID: <1430433465-6066-4-git-send-email-tgraf@suug.ch>
References: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35309 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbbD3Wh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 18:37:59 -0400
Received: by pdbqd1 with SMTP id qd1so74268971pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 15:37:59 -0700 (PDT)
In-Reply-To: <1430433465-6066-1-git-send-email-tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This only blows up the size of the test structure for no gain
in test coverage. Reduces size of test_obj from 24 to 16 bytes.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index e3d31bf..d6d6719 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -22,7 +22,6 @@
 #include <linux/slab.h>
 
 
-#define TEST_PTR	((void *) 0xdeadbeef)
 #define MAX_ENTRIES	1000000
 
 static int entries = 50000;
@@ -46,7 +45,6 @@ module_param(size, int, 0);
 MODULE_PARM_DESC(size, "Initial size hint of table (default: 8)");
 
 struct test_obj {
-	void			*ptr;
 	int			value;
 	struct rhash_head	node;
 };
@@ -78,9 +76,9 @@ static int __init test_rht_lookup(struct rhashtable *ht)
 				key);
 			return -EEXIST;
 		} else if (expected && obj) {
-			if (obj->ptr != TEST_PTR || obj->value != i) {
-				pr_warn("Test failed: Lookup value mismatch %p!=%p, %u!=%u\n",
-					obj->ptr, TEST_PTR, obj->value, i);
+			if (obj->value != i) {
+				pr_warn("Test failed: Lookup value mismatch %u!=%u\n",
+					obj->value, i);
 				return -EINVAL;
 			}
 		}
@@ -153,7 +151,6 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 			goto error;
 		}
 
-		obj->ptr = TEST_PTR;
 		obj->value = i * 2;
 
 		err = rhashtable_insert_fast(ht, &obj->node, test_rht_params);
-- 
1.9.3
