From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 3/3] rhashtable: allow to unload test module
Date: Fri, 20 Feb 2015 00:53:39 +0100
Message-ID: <c0c78ef9a196812dc8a2922bb2a957a04c6dbfb6.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Cc: tgraf@suug.ch, johunt@akamai.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59405 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbbBSXxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 18:53:53 -0500
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
In-Reply-To: <cover.1424389682.git.daniel@iogearbox.net>
References: <cover.1424389682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no good reason why to disallow unloading of the rhashtable
test case module.

Commit 9d6dbe1bbaf8 moved the code from a boot test into a stand-alone
module, but only converted the subsys_initcall() handler into a
module_init() function without a related exit handler, and thus
preventing the test module from unloading.

Fixes: 9d6dbe1bbaf8 ("rhashtable: Make selftest modular")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 lib/test_rhashtable.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 1dfeba7..9c5fcce 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -222,6 +222,11 @@ static int __init test_rht_init(void)
 	return err;
 }
 
+static void __exit test_rht_exit(void)
+{
+}
+
 module_init(test_rht_init);
+module_exit(test_rht_exit);
 
 MODULE_LICENSE("GPL v2");
-- 
1.9.3
