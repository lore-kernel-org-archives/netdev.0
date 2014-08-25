From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 1/3] crash_dump: Make is_kdump_kernel() accessible from modules
Date: Mon, 25 Aug 2014 16:06:52 +0300
Message-ID: <1408972014-13319-2-git-send-email-amirv@mellanox.com>
References: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Vivek Goyal <vgoyal@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:36985 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932146AbaHYNHr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2014 09:07:47 -0400
In-Reply-To: <1408972014-13319-1-git-send-email-amirv@mellanox.com>
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
