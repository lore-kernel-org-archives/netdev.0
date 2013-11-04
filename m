From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 2/3] lib: crc32: conditionally resched when running testcases
Date: Mon,  4 Nov 2013 17:10:26 +0100
Message-ID: <31ff96d855409458e419b75e864b81d5405ce480.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1867 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753590Ab3KDQKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 11:10:34 -0500
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
In-Reply-To: <cover.1383580331.git.dborkman@redhat.com>
References: <cover.1383580331.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fengguang reports that when crc32 selftests are running on startup, on
some e.g. 32bit systems, we can get a CPU stall like "INFO: rcu_sched
self-detected stall on CPU { 0} (t=2101 jiffies g=4294967081 c=4294967080
q=41)". As this is not intended, add a cond_resched() at the end of a
test case to fix it. Introduced by efba721f63 ("lib: crc32: add test cases
for crc32{, c}_combine routines").

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 lib/crc32.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/lib/crc32.c b/lib/crc32.c
index 69dd124..3a1dfa8 100644
--- a/lib/crc32.c
+++ b/lib/crc32.c
@@ -29,6 +29,7 @@
 #include <linux/crc32.h>
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/sched.h>
 #include "crc32defs.h"
 
 #if CRC_LE_BITS > 8
@@ -1054,6 +1055,7 @@ static int __init crc32c_combine_test(void)
 			      crc_full == test[i].crc32c_le))
 				errors++;
 			runs++;
+			cond_resched();
 		}
 	}
 
@@ -1147,6 +1149,7 @@ static int __init crc32_combine_test(void)
 			      crc_full == test[i].crc_le))
 				errors++;
 			runs++;
+			cond_resched();
 		}
 	}
 
-- 
1.8.3.1
