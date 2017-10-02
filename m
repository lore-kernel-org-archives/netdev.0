From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v2 2/2] libbpf: use map_flags when creating maps
Date: Mon,  2 Oct 2017 12:41:29 -0400
Message-ID: <20171002164129.47986-3-kraigatgoog@gmail.com>
References: <20171002164129.47986-1-kraigatgoog@gmail.com>
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:49067 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751746AbdJBQlf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 12:41:35 -0400
Received: by mail-qk0-f177.google.com with SMTP id d67so2377819qkg.5
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 09:41:35 -0700 (PDT)
In-Reply-To: <20171002164129.47986-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This is required to use BPF_MAP_TYPE_LPM_TRIE or any other map type
which requires flags.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 tools/lib/bpf/libbpf.c | 2 +-
 tools/lib/bpf/libbpf.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 28b300868ad7..5996e7565cc8 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -968,7 +968,7 @@ bpf_object__create_maps(struct bpf_object *obj)
 					   def->key_size,
 					   def->value_size,
 					   def->max_entries,
-					   0);
+					   def->map_flags);
 		if (*pfd < 0) {
 			size_t j;
 			int err = *pfd;
diff --git a/tools/lib/bpf/libbpf.h b/tools/lib/bpf/libbpf.h
index 7959086eb9c9..6e20003109e0 100644
--- a/tools/lib/bpf/libbpf.h
+++ b/tools/lib/bpf/libbpf.h
@@ -207,6 +207,7 @@ struct bpf_map_def {
 	unsigned int key_size;
 	unsigned int value_size;
 	unsigned int max_entries;
+	unsigned int map_flags;
 };
 
 /*
-- 
2.14.2.822.g60be5d43e6-goog
