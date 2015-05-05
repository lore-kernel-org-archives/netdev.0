From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] rhashtable-test: Fix 64bit division
Date: Tue,  5 May 2015 02:27:02 +0200
Message-ID: <ce3dfbe753021ac49b34560aabe874d6f8fdc63e.1430785419.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:37469 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEEA1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:27:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A 64bit division went in unnoticed. Use do_div() to accomodate
non 64bit architectures.

Reported-by: kbuild test robot
Fixes: 1aa661f5c3df ("rhashtable-test: Measure time to insert, remove & traverse entries")
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 lib/test_rhashtable.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index 6893e57..c90777e 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -229,7 +229,8 @@ static int __init test_rht_init(void)
 		total_time += time;
 	}
 
-	pr_info("Average test time: %llu\n", total_time / runs);
+	do_div(total_time, runs);
+	pr_info("Average test time: %llu\n", total_time);
 
 	return 0;
 }
-- 
2.3.5
