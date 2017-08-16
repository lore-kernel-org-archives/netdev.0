From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 09/10] bpf: selftests: add tests for new __sk_buff
 members
Date: Tue, 15 Aug 2017 22:33:56 -0700
Message-ID: <20170816053355.15445.70088.stgit@john-Precision-Tower-5810>
References: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, john.fastabend@gmail.com,
        tom@herbertland.com
To: davem@davemloft.net, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33512 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751159AbdHPFeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 01:34:16 -0400
Received: by mail-pf0-f194.google.com with SMTP id c65so426957pfl.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 22:34:15 -0700 (PDT)
In-Reply-To: <20170816052338.15445.83732.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds tests to access new __sk_buff members from sk skb program
type.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_verifier.c |  152 +++++++++++++++++++++++++++
 1 file changed, 152 insertions(+)

diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 1b76712..c03542c 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -967,6 +967,158 @@ struct test_val {
 		.result = REJECT,
 	},
 	{
+		"invalid access __sk_buff family",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, family)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff remote_ip4",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip4)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff local_ip4",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip4)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff remote_ip6",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip6)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff local_ip6",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip6)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff remote_port",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_port)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"invalid access __sk_buff remote_port",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_port)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"valid access __sk_buff family",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, family)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff remote_ip4",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip4)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff local_ip4",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip4)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff remote_ip6",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip6[0])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip6[1])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip6[2])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_ip6[3])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff local_ip6",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip6[0])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip6[1])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip6[2])),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_ip6[3])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff remote_port",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, remote_port)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
+		"valid access __sk_buff remote_port",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, local_port)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SK_SKB,
+	},
+	{
 		"check skb->mark is not writeable by sockets",
 		.insns = {
 			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
