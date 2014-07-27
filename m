From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/3] crash_dump: Make is_kdump_kernel() accessible from modules
Date: Sun, 27 Jul 2014 17:59:14 +0300
Message-ID: <1406473156-4077-2-git-send-email-amirv@mellanox.com>
References: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45043 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751471AbaG0O7e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jul 2014 10:59:34 -0400
In-Reply-To: <1406473156-4077-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to make is_kdump_kernel() accessible from modules, need to
make elfcorehdr_addr exported.
This was rejected in the past [1] because reset_devices was prefered in
that context (reseting the device in kdump kernel), but now there are
some network drivers that need to reduce memory usage when loaded from
a kdump kernel.  And in that context, is_kdump_kernel() suits better.

[1] - https://lkml.org/lkml/2011/1/27/341

CC: Vivek Goyal <vgoyal@redhat.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 kernel/crash_dump.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/crash_dump.c b/kernel/crash_dump.c
index c766ee5..b64e238 100644
--- a/kernel/crash_dump.c
+++ b/kernel/crash_dump.c
@@ -18,6 +18,7 @@ unsigned long saved_max_pfn;
  * it under CONFIG_CRASH_DUMP and not CONFIG_PROC_VMCORE.
  */
 unsigned long long elfcorehdr_addr = ELFCORE_ADDR_MAX;
+EXPORT_SYMBOL_GPL(elfcorehdr_addr);
 
 /*
  * stores the size of elf header of crash image
-- 
1.8.3.4
