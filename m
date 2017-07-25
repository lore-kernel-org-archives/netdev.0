From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH] lib: test_rhashtable: Fix KASAN warning
Date: Tue, 25 Jul 2017 13:36:21 +0200
Message-ID: <20170725113621.1425-1-phil@nwl.cc>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43367 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750980AbdGYLgd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 07:36:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I forgot one spot when introducing struct test_obj_val.

Fixes: e859afe1ee0c5 ("lib: test_rhashtable: fix for large entry counts")
Reported by: kernel test robot <fengguang.wu@intel.com>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 lib/test_rhashtable.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 16949d219291a..0ffca990a8337 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -223,7 +223,9 @@ static s64 __init test_rhashtable(struct rhashtable *ht)
 
 	pr_info("  Deleting %d keys\n", entries);
 	for (i = 0; i < entries; i++) {
-		u32 key = i * 2;
+		struct test_obj_val key = {
+			.id = i * 2,
+		};
 
 		if (array[i].value.id != TEST_INSERT_FAIL) {
 			obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
-- 
2.13.1
