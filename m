From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 7/8] bpf: remove cg_skb_func_proto and use sk_filter_func_proto directly
Date: Sun, 11 Jun 2017 00:50:46 +0200
Message-ID: <6910cbd17b1d10b161a9de2911f8eb8bf0861c54.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57840 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751795AbdFJWvA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 18:51:00 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since cg_skb_func_proto() doesn't do anything else than just calling
into sk_filter_func_proto(), remove it and set sk_filter_func_proto()
directly for .get_func_proto callback.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 946f758..4867391 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2775,12 +2775,6 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 }
 
 static const struct bpf_func_proto *
-cg_skb_func_proto(enum bpf_func_id func_id)
-{
-	return sk_filter_func_proto(func_id);
-}
-
-static const struct bpf_func_proto *
 lwt_inout_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -3344,7 +3338,7 @@ static u32 xdp_convert_ctx_access(enum bpf_access_type type,
 };
 
 const struct bpf_verifier_ops cg_skb_prog_ops = {
-	.get_func_proto		= cg_skb_func_proto,
+	.get_func_proto		= sk_filter_func_proto,
 	.is_valid_access	= sk_filter_is_valid_access,
 	.convert_ctx_access	= bpf_convert_ctx_access,
 	.test_run		= bpf_prog_test_run_skb,
-- 
1.9.3
