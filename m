From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next 3/8] bpf: Allow cgroup sock filters to use get_current_uid_gid helper
Date: Tue, 22 Aug 2017 17:20:16 -0700
Message-ID: <1503447621-27997-4-git-send-email-dsahern@gmail.com>
References: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:38012 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbdHWAUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 20:20:31 -0400
Received: by mail-pf0-f195.google.com with SMTP id h75so197416pfh.5
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 17:20:31 -0700 (PDT)
In-Reply-To: <1503447621-27997-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow BPF programs run on sock create to use the get_current_uid_gid
helper.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/core/filter.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 7ee75a40ff03..6d3f693021f9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3139,6 +3139,17 @@ bpf_base_func_proto(enum bpf_func_id func_id)
 }
 
 static const struct bpf_func_proto *
+sock_filter_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_get_current_uid_gid:
+		return &bpf_get_current_uid_gid_proto;
+	default:
+		return bpf_base_func_proto(func_id);
+	}
+}
+
+static const struct bpf_func_proto *
 sk_filter_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -4227,7 +4238,7 @@ const struct bpf_verifier_ops lwt_xmit_prog_ops = {
 };
 
 const struct bpf_verifier_ops cg_sock_prog_ops = {
-	.get_func_proto		= bpf_base_func_proto,
+	.get_func_proto		= sock_filter_func_proto,
 	.is_valid_access	= sock_filter_is_valid_access,
 	.convert_ctx_access	= sock_filter_convert_ctx_access,
 };
-- 
2.1.4
