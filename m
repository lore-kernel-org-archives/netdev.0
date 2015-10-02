From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] ebpf: include perf_event only where really needed
Date: Fri,  2 Oct 2015 18:42:00 +0200
Message-ID: <1e7712d4d7b8638ad96ca74436fe96508ce89dfa.1443802548.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Kaixu Xia <xiakaixu@huawei.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47941 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbbJBQmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 12:42:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ea317b267e9d ("bpf: Add new bpf map type to store the pointer
to struct perf_event") added perf_event.h to the main eBPF header, so
it gets included for all users. perf_event.h is actually only needed
from array map side, so lets sanitize this a bit.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Kaixu Xia <xiakaixu@huawei.com>
---
 [ Did couple of tests, but lets see if Fengguang's build bot agrees
   with me eventually. ;) P.s., the feature of pulling patches from
   patchwork is awesome! ]

 include/linux/bpf.h   | 1 -
 kernel/bpf/arraymap.c | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index f57d7fe..c915a6b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -10,7 +10,6 @@
 #include <uapi/linux/bpf.h>
 #include <linux/workqueue.h>
 #include <linux/file.h>
-#include <linux/perf_event.h>
 
 struct bpf_map;
 
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index 29ace10..2fecc4a 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -15,6 +15,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/filter.h>
+#include <linux/perf_event.h>
 
 /* Called from syscall */
 static struct bpf_map *array_map_alloc(union bpf_attr *attr)
-- 
1.9.3
