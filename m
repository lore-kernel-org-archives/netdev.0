From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: bpf_event_entry_gen's alloc needs to be in atomic context
Date: Sat, 16 Jul 2016 01:15:55 +0200
Message-ID: <3a4cacd7ebd8b246325c48b46d25d67669428198.1468624006.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:32773 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbcGOXQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:16:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Should have been obvious, only called from bpf() syscall via map_update_elem()
that calls bpf_fd_array_map_update_elem() under RCU read lock and thus this
must also be in GFP_ATOMIC, of course.

Fixes: 3b1efb196eee ("bpf, maps: flush own entries on perf map release")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Sorry for missing this typo, sigh.

 kernel/bpf/arraymap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index db1a743..633a650 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -430,7 +430,7 @@ static struct bpf_event_entry *bpf_event_entry_gen(struct file *perf_file,
 {
 	struct bpf_event_entry *ee;
 
-	ee = kzalloc(sizeof(*ee), GFP_KERNEL);
+	ee = kzalloc(sizeof(*ee), GFP_ATOMIC);
 	if (ee) {
 		ee->event = perf_file->private_data;
 		ee->perf_file = perf_file;
-- 
1.9.3
