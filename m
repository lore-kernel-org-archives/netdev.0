From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 5/5] net: filter: add test case for jump with holes and ret x variants
Date: Fri, 23 May 2014 18:44:01 +0200
Message-ID: <1400863441-3711-6-git-send-email-dborkman@redhat.com>
References: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63058 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879AbaEWQoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 12:44:14 -0400
In-Reply-To: <1400863441-3711-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds three more test cases:

 1) long jumps with holes of unreachable code
 2) ret x
 3) ldx + ret x

All three tests are for classical BPF and to make sure that
any changes will not break some exotic behaviour that exists
probably since decades. The last two tests are expected to
fail by the BPF checker already, as in classic BPF only K
or A are allowed to be returned. Thus, there are now 52 test
cases for BPF.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c | 94 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 94 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index da34e33..af677cb 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -1391,6 +1391,100 @@ static struct bpf_test tests[] = {
 		{ },
 		{ }
 	},
+	{
+		"JUMPS + HOLES",
+		.u.insns = {
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JGE, 0, 13, 15),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x90c2894d, 3, 4),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x90c2894d, 1, 2),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JGE, 0, 14, 15),
+			BPF_JUMP(BPF_JMP | BPF_JGE, 0, 13, 14),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x2ac28349, 2, 3),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x2ac28349, 1, 2),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JGE, 0, 14, 15),
+			BPF_JUMP(BPF_JMP | BPF_JGE, 0, 13, 14),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x90d2ff41, 2, 3),
+			BPF_JUMP(BPF_JMP | BPF_JEQ, 0x90d2ff41, 1, 2),
+			BPF_STMT(BPF_LD | BPF_H | BPF_ABS, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0),
+			BPF_STMT(BPF_RET | BPF_A, 0),
+		},
+		CLASSIC,
+		{ 0x00, 0x1b, 0x21, 0x3c, 0x9d, 0xf8, 0x90, 0xe2,
+		  0xba, 0x0a, 0x56, 0xb4, 0x08, 0x00, 0x45, 0x00,
+		  0x00, 0x28, 0x00, 0x00, 0x20, 0x00, 0x40, 0x11,
+		  0x00, 0x00, 0xc0, 0xa8, 0x33, 0x01, 0xc0, 0xa8,
+		  0x33, 0x02, 0xbb, 0xb6, 0xa9, 0xfa, 0x00, 0x14,
+		  0x00, 0x00, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc,
+		  0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc, 0xcc },
+		{ { 88, 0x001b } }
+	},
+	{
+		"check: RET X",
+		.u.insns = {
+			BPF_STMT(BPF_RET | BPF_X, 0),
+		},
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
+		{ },
+		{ },
+	},
+	{
+		"check: LDX + RET X",
+		.u.insns = {
+			BPF_STMT(BPF_LDX | BPF_IMM, 42),
+			BPF_STMT(BPF_RET | BPF_X, 0),
+		},
+		CLASSIC | FLAG_NO_DATA | FLAG_EXPECTED_FAIL,
+		{ },
+		{ },
+	},
 };
 
 static struct net_device dev;
-- 
1.7.11.7
