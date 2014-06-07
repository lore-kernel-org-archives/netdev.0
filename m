From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] net: filter: fix nlattr and nlattr_nest BPF tests
Date: Fri,  6 Jun 2014 17:48:20 -0700
Message-ID: <1402102100-30215-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <dborkman@redhat.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:50011 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350AbaFGAsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 20:48:31 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so3066648pdj.20
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 17:48:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- 'struct nlattr' must be 2 byte aligned
- provide big-endian input data for nlattr/nlattr_nest tests

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
tested on x64, qemu-arm32 and qemu-sparc64

 lib/test_bpf.c |   34 +++++++++++++++++++++-------------
 1 file changed, 21 insertions(+), 13 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index ea60ad8d5242..c579e0f58818 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -385,7 +385,7 @@ static struct bpf_test tests[] = {
 	{
 		"LD_NLATTR",
 		.u.insns = {
-			BPF_STMT(BPF_LDX | BPF_IMM, 1),
+			BPF_STMT(BPF_LDX | BPF_IMM, 2),
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_LDX | BPF_IMM, 3),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
@@ -393,42 +393,50 @@ static struct bpf_test tests[] = {
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
 		CLASSIC,
-		{ 0xff, 4, 0, 2, 0, 4, 0, 3, 0 },
-		{ { 4, 0 }, { 20, 5 } },
+#ifdef __BIG_ENDIAN
+		{ 0xff, 0xff, 0, 4, 0, 2, 0, 4, 0, 3 },
+#else
+		{ 0xff, 0xff, 4, 0, 2, 0, 4, 0, 3, 0 },
+#endif
+		{ { 4, 0 }, { 20, 6 } },
 	},
 	{
 		"LD_NLATTR_NEST",
 		.u.insns = {
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LDX | BPF_IMM, 3),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
-			BPF_STMT(BPF_LD | BPF_IMM, 1),
+			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_NLATTR_NEST),
 			BPF_STMT(BPF_RET | BPF_A, 0)
 		},
 		CLASSIC,
-		{ 0xff, 12, 0, 1, 0, 4, 0, 2, 0, 4, 0, 3, 0 },
-		{ { 4, 0 }, { 20, 9 } },
+#ifdef __BIG_ENDIAN
+		{ 0xff, 0xff, 0, 12, 0, 1, 0, 4, 0, 2, 0, 4, 0, 3 },
+#else
+		{ 0xff, 0xff, 12, 0, 1, 0, 4, 0, 2, 0, 4, 0, 3, 0 },
+#endif
+		{ { 4, 0 }, { 20, 10 } },
 	},
 	{
 		"LD_PAYLOAD_OFF",
-- 
1.7.9.5
