From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] test_bpf: fix sparse warnings
Date: Wed, 13 May 2015 20:40:39 -0700
Message-ID: <1431574839-7099-1-git-send-email-ast@plumgrid.com>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:32958 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933744AbbENDks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:40:48 -0400
Received: by pdbnk13 with SMTP id nk13so71443840pdb.0
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 20:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>

Fix several sparse warnings like:
lib/test_bpf.c:1824:25: sparse: constant 4294967295 is so big it is long
lib/test_bpf.c:1878:25: sparse: constant 0x0000ffffffff0000 is so big it is long

Fixes: cffc642d93f9 ("test_bpf: add 173 new testcases for eBPF")
Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 lib/test_bpf.c |  122 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 61 insertions(+), 61 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index 66358b21acce..aaa0a40a7eb3 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -2008,13 +2008,13 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_MOV_X: dst = 4294967295",
 		.u.insns_int = {
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295U),
 			BPF_ALU32_REG(BPF_MOV, R0, R1),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	{
 		"ALU64_MOV_X: dst = 2",
@@ -2030,13 +2030,13 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_MOV_X: dst = 4294967295",
 		.u.insns_int = {
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295U),
 			BPF_ALU64_REG(BPF_MOV, R0, R1),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	/* BPF_ALU | BPF_MOV | BPF_K */
 	{
@@ -2052,18 +2052,18 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_MOV_K: dst = 4294967295",
 		.u.insns_int = {
-			BPF_ALU32_IMM(BPF_MOV, R0, 4294967295),
+			BPF_ALU32_IMM(BPF_MOV, R0, 4294967295U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	{
 		"ALU_MOV_K: 0x0000ffffffff0000 = 0x00000000ffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0x00000000ffffffff),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0x00000000ffffffffLL),
 			BPF_ALU32_IMM(BPF_MOV, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2098,7 +2098,7 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_OR_K: dst = 0x0",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
 			BPF_LD_IMM64(R3, 0x0),
 			BPF_ALU64_IMM(BPF_MOV, R2, 0x0),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
@@ -2114,8 +2114,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_MOV_K: dst = -1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_MOV, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2144,13 +2144,13 @@ static struct bpf_test tests[] = {
 		"ALU_ADD_X: 1 + 4294967294 = 4294967295",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 1),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294U),
 			BPF_ALU32_REG(BPF_ADD, R0, R1),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	{
 		"ALU64_ADD_X: 1 + 2 = 3",
@@ -2168,13 +2168,13 @@ static struct bpf_test tests[] = {
 		"ALU64_ADD_X: 1 + 4294967294 = 4294967295",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 1),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294U),
 			BPF_ALU64_REG(BPF_ADD, R0, R1),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	/* BPF_ALU | BPF_ADD | BPF_K */
 	{
@@ -2203,12 +2203,12 @@ static struct bpf_test tests[] = {
 		"ALU_ADD_K: 1 + 4294967294 = 4294967295",
 		.u.insns_int = {
 			BPF_LD_IMM64(R0, 1),
-			BPF_ALU32_IMM(BPF_ADD, R0, 4294967294),
+			BPF_ALU32_IMM(BPF_ADD, R0, 4294967294U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
 		{ },
-		{ { 0, 4294967295 } },
+		{ { 0, 4294967295U } },
 	},
 	{
 		"ALU_ADD_K: 0 + (-1) = 0x00000000ffffffff",
@@ -2290,7 +2290,7 @@ static struct bpf_test tests[] = {
 		"ALU64_ADD_K: 0 + (-1) = 0xffffffffffffffff",
 		.u.insns_int = {
 			BPF_LD_IMM64(R2, 0x0),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_ADD, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2318,8 +2318,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_SUB_X: 4294967295 - 4294967294 = 1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294U),
 			BPF_ALU32_REG(BPF_SUB, R0, R1),
 			BPF_EXIT_INSN(),
 		},
@@ -2342,8 +2342,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_SUB_X: 4294967295 - 4294967294 = 1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967294U),
 			BPF_ALU64_REG(BPF_SUB, R0, R1),
 			BPF_EXIT_INSN(),
 		},
@@ -2377,8 +2377,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_SUB_K: 4294967295 - 4294967294 = 1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_SUB, R0, 4294967294),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_SUB, R0, 4294967294U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -2410,8 +2410,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_SUB_K: 4294967294 - 4294967295 = -1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967294),
-			BPF_ALU64_IMM(BPF_SUB, R0, 4294967295),
+			BPF_LD_IMM64(R0, 4294967294U),
+			BPF_ALU64_IMM(BPF_SUB, R0, 4294967295U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -2588,7 +2588,7 @@ static struct bpf_test tests[] = {
 		"ALU64_MUL_K: 1 * (-1) = 0xffffffffffffffff",
 		.u.insns_int = {
 			BPF_LD_IMM64(R2, 0x1),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_MUL, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2616,8 +2616,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_DIV_X: 4294967295 / 4294967295 = 1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967295U),
 			BPF_ALU32_REG(BPF_DIV, R0, R1),
 			BPF_EXIT_INSN(),
 		},
@@ -2652,9 +2652,9 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_DIV_X: 0xffffffffffffffff / (-1) = 0x0000000000000001",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
-			BPF_LD_IMM64(R4, 0xffffffffffffffffUL),
-			BPF_LD_IMM64(R3, 0x0000000000000001UL),
+			BPF_LD_IMM64(R2, 0xffffffffffffffffLL),
+			BPF_LD_IMM64(R4, 0xffffffffffffffffLL),
+			BPF_LD_IMM64(R3, 0x0000000000000001LL),
 			BPF_ALU64_REG(BPF_DIV, R2, R4),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2692,8 +2692,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_DIV_K: 4294967295 / 4294967295 = 1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_DIV, R0, 4294967295),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_DIV, R0, 4294967295U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -2703,7 +2703,7 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_DIV_K: 0xffffffffffffffff / (-1) = 0x1",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R2, 0xffffffffffffffffLL),
 			BPF_LD_IMM64(R3, 0x1UL),
 			BPF_ALU32_IMM(BPF_DIV, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
@@ -2752,8 +2752,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_DIV_K: 0xffffffffffffffff / (-1) = 0x0000000000000001",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0xffffffffffffffffUL),
-			BPF_LD_IMM64(R3, 0x0000000000000001UL),
+			BPF_LD_IMM64(R2, 0xffffffffffffffffLL),
+			BPF_LD_IMM64(R3, 0x0000000000000001LL),
 			BPF_ALU64_IMM(BPF_DIV, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2781,8 +2781,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_MOD_X: 4294967295 % 4294967293 = 2",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_MOV, R1, 4294967293),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_MOV, R1, 4294967293U),
 			BPF_ALU32_REG(BPF_MOD, R0, R1),
 			BPF_EXIT_INSN(),
 		},
@@ -2840,8 +2840,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU_MOD_K: 4294967295 % 4294967293 = 2",
 		.u.insns_int = {
-			BPF_LD_IMM64(R0, 4294967295),
-			BPF_ALU32_IMM(BPF_MOD, R0, 4294967293),
+			BPF_LD_IMM64(R0, 4294967295U),
+			BPF_ALU32_IMM(BPF_MOD, R0, 4294967293U),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -2978,8 +2978,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_AND_K: 0x0000ffffffff0000 & 0x0 = 0x0000ffff00000000",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0x0000000000000000),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0x0000000000000000LL),
 			BPF_ALU64_IMM(BPF_AND, R2, 0x0),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -2994,8 +2994,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_AND_K: 0x0000ffffffff0000 & -1 = 0x0000ffffffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000LL),
 			BPF_ALU64_IMM(BPF_AND, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3010,8 +3010,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_AND_K: 0xffffffffffffffff & -1 = 0xffffffffffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0xffffffffffffffff),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0xffffffffffffffffLL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_AND, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3120,8 +3120,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_OR_K: 0x0000ffffffff0000 | 0x0 = 0x0000ffff00000000",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000LL),
 			BPF_ALU64_IMM(BPF_OR, R2, 0x0),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3136,8 +3136,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_OR_K: 0x0000ffffffff0000 | -1 = 0xffffffffffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_OR, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3152,8 +3152,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_OR_K: 0x000000000000000 | -1 = 0xffffffffffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000000000000000),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0x0000000000000000LL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_OR, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3262,8 +3262,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_XOR_K: 0x0000ffffffff0000 ^ 0x0 = 0x0000ffffffff0000",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0x0000ffffffff0000),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0x0000ffffffff0000LL),
 			BPF_ALU64_IMM(BPF_XOR, R2, 0x0),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3278,8 +3278,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_XOR_K: 0x0000ffffffff0000 ^ -1 = 0xffff00000000ffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000ffffffff0000),
-			BPF_LD_IMM64(R3, 0xffff00000000ffff),
+			BPF_LD_IMM64(R2, 0x0000ffffffff0000LL),
+			BPF_LD_IMM64(R3, 0xffff00000000ffffLL),
 			BPF_ALU64_IMM(BPF_XOR, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3294,8 +3294,8 @@ static struct bpf_test tests[] = {
 	{
 		"ALU64_XOR_K: 0x000000000000000 ^ -1 = 0xffffffffffffffff",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0x0000000000000000),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0x0000000000000000LL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ALU64_IMM(BPF_XOR, R2, 0xffffffff),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
 			BPF_MOV32_IMM(R0, 2),
@@ -3760,8 +3760,8 @@ static struct bpf_test tests[] = {
 	{
 		"ST_MEM_DW: Store/Load double word: max negative 2",
 		.u.insns_int = {
-			BPF_LD_IMM64(R2, 0xffff00000000ffff),
-			BPF_LD_IMM64(R3, 0xffffffffffffffff),
+			BPF_LD_IMM64(R2, 0xffff00000000ffffLL),
+			BPF_LD_IMM64(R3, 0xffffffffffffffffLL),
 			BPF_ST_MEM(BPF_DW, R10, -40, 0xffffffff),
 			BPF_LDX_MEM(BPF_DW, R2, R10, -40),
 			BPF_JMP_REG(BPF_JEQ, R2, R3, 2),
-- 
1.7.9.5
