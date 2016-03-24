From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: add missing map_flags to bpf_map_show_fdinfo
Date: Fri, 25 Mar 2016 00:30:25 +0100
Message-ID: <5da67066a9739eb443b2e89e58ea4d356d70459c.1458861762.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37893 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbcCXXac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 19:30:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add map_flags attribute to bpf_map_show_fdinfo(), so that tools like
tc can check for them when loading objects from a pinned entry, e.g.
if user intent wrt allocation (BPF_F_NO_PREALLOC) is different to the
pinned object, it can bail out. Follow-up to 6c9059817432 ("bpf:
pre-allocate hash map elements"), so that tc can still support this
with v4.6.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2a2efe1..adc5e4b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -137,11 +137,13 @@ static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
 		   "map_type:\t%u\n"
 		   "key_size:\t%u\n"
 		   "value_size:\t%u\n"
-		   "max_entries:\t%u\n",
+		   "max_entries:\t%u\n"
+		   "map_flags:\t%#x\n",
 		   map->map_type,
 		   map->key_size,
 		   map->value_size,
-		   map->max_entries);
+		   map->max_entries,
+		   map->map_flags);
 }
 #endif
 
-- 
1.9.3
