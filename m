From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] libbpf: use map_flags when creating maps
Date: Wed, 27 Sep 2017 10:04:58 -0400
Message-ID: <20170927140458.44337-1-kraigatgoog@gmail.com>
Cc: Chonggang Li <chonggangli@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:45690 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753142AbdI0OFB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 10:05:01 -0400
Received: by mail-qk0-f182.google.com with SMTP id r141so13378397qke.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 07:05:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This extends struct bpf_map_def to include a flags field.  Note that
this has the potential to break the validation logic in
bpf_object__validate_maps and bpf_object__init_maps as they use
sizeof(struct bpf_map_def) as a minimal allowable size of a map section.
Any bpf program compiled with a smaller struct bpf_map_def will fail this
check.

I don't believe this will be an issue in practice as both compile-time
definitions of struct bpf_map_def (in samples/bpf/bpf_load.h and
tools/testing/selftests/bpf/bpf_helpers.h) have always been larger
than this newly updated version in libbpf.h.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 tools/lib/bpf/libbpf.c | 2 +-
 tools/lib/bpf/libbpf.h | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/lib/bpf/libbpf.c b/tools/lib/bpf/libbpf.c
index 35f6dfcdc565..6bea85f260a3 100644
--- a/tools/lib/bpf/libbpf.c
+++ b/tools/lib/bpf/libbpf.c
@@ -874,7 +874,7 @@ bpf_object__create_maps(struct bpf_object *obj)
 				      def->key_size,
 				      def->value_size,
 				      def->max_entries,
-				      0);
+				      def->map_flags);
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
