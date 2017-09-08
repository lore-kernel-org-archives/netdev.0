From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH 3/3] bpf: devmap, use cond_resched instead of cpu_relax
Date: Fri, 08 Sep 2017 14:01:10 -0700
Message-ID: <150490447017.11590.17727368565733920857.stgit@john-XPS-13-9360>
References: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
        daniel@iogearbox.net, ast@fb.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:37990 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932400AbdIHVBX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:01:23 -0400
Received: by mail-pf0-f196.google.com with SMTP id q76so1924447pfq.5
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:01:23 -0700 (PDT)
In-Reply-To: <150490397545.11590.1409723973253492363.stgit@john-XPS-13-9360>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be a bit more friendly about waiting for flush bits to complete.
Replace the cpu_relax() with a cond_resched().

Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 kernel/bpf/devmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index ecf9f99..959c9a0 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -159,7 +159,7 @@ static void dev_map_free(struct bpf_map *map)
 		unsigned long *bitmap = per_cpu_ptr(dtab->flush_needed, cpu);
 
 		while (!bitmap_empty(bitmap, dtab->map.max_entries))
-			cpu_relax();
+			cond_resched();
 	}
 
 	for (i = 0; i < dtab->map.max_entries; i++) {
