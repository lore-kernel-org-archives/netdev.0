From: Joe Stringer <joe@ovn.org>
Subject: [PATCH net-next 3/3] tools lib bpf: Sync bpf_map_def with tc
Date: Mon, 31 Oct 2016 11:39:17 -0700
Message-ID: <20161031183917.9938-4-joe@ovn.org>
References: <20161031183917.9938-1-joe@ovn.org>
Cc: wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:43726 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945569AbcJaSq4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:46:56 -0400
Received: from relay2-d.mail.gandi.net (relay2-d.mail.gandi.net [217.70.183.194])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 0A93847B84F
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 19:39:39 +0100 (CET)
In-Reply-To: <20161031183917.9938-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TC uses a slightly different map layout in its ELFs. Update libbpf to
use the same definition so that ELFs may be built using libbpf and
loaded using tc.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
 tools/lib/bpf/libbpf.h | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index dd7a513efb10..ea70c2744f8c 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -181,10 +181,13 @@ bool bpf_program__is_kprobe(struct bpf_program *prog);
  * and will be treated as an error due to -Werror.
  */
 struct bpf_map_def {
-	unsigned int type;
-	unsigned int key_size;
-	unsigned int value_size;
-	unsigned int max_entries;
+	uint32_t type;
+	uint32_t key_size;
+	uint32_t value_size;
+	uint32_t max_entries;
+	uint32_t flags;
+	uint32_t id;
+	uint32_t pinning;
 };
 
 /*
-- 
2.9.3
