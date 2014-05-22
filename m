From: akpm@linux-foundation.org
Subject: [patch 1/1] lib/test_bpf.c: don't use gcc union shortcut
Date: Thu, 22 May 2014 10:16:46 -0700
Message-ID: <20140522171646.843C831C19E@corp2gmr1-1.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, ast@plumgrid.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:40584 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaEVRQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 13:16:47 -0400
Received: by mail-ob0-f202.google.com with SMTP id wm4so775268obc.3
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 10:16:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Subject: lib/test_bpf.c: don't use gcc union shortcut

Older gcc's (mine is gcc-4.4.4) make a mess of this.

lib/test_bpf.c:74: error: unknown field 'insns' specified in initializer
lib/test_bpf.c:75: warning: missing braces around initializer
lib/test_bpf.c:75: warning: (near initialization for 'tests[0].<anonymous>.insns[0]')
lib/test_bpf.c:76: error: extra brace group at end of initializer
lib/test_bpf.c:76: error: (near initialization for 'tests[0].<anonymous>')
lib/test_bpf.c:76: warning: excess elements in union initializer
lib/test_bpf.c:76: warning: (near initialization for 'tests[0].<anonymous>')
lib/test_bpf.c:77: error: extra brace group at end of initializer

Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 lib/test_bpf.c |  104 +++++++++++++++++++++++------------------------
 1 file changed, 52 insertions(+), 52 deletions(-)

diff -puN lib/test_bpf.c~lib-test_bpfc-dont-use-gcc-union-shortcut lib/test_bpf.c
--- a/lib/test_bpf.c~lib-test_bpfc-dont-use-gcc-union-shortcut
+++ a/lib/test_bpf.c
@@ -54,7 +54,7 @@ struct bpf_test {
 	union {
 		struct sock_filter insns[MAX_INSNS];
 		struct sock_filter_int insns_int[MAX_INSNS];
-	};
+	} u;
 	enum {
 		NO_DATA,
 		EXPECTED_FAIL,
@@ -71,7 +71,7 @@ struct bpf_test {
 static struct bpf_test tests[] = {
 	{
 		"TAX",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 1),
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
 			BPF_STMT(BPF_LD | BPF_IMM, 2),
@@ -90,7 +90,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"TXA",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
@@ -102,7 +102,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"ADD_SUB_MUL_K",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 1),
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_K, 2),
 			BPF_STMT(BPF_LDX | BPF_IMM, 3),
@@ -117,7 +117,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"DIV_KX",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 8),
 			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 2),
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
@@ -135,7 +135,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"AND_OR_LSH_K",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 0xff),
 			BPF_STMT(BPF_ALU | BPF_AND | BPF_K, 0xf0),
 			BPF_STMT(BPF_ALU | BPF_LSH | BPF_K, 27),
@@ -151,7 +151,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_IND",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_LD | BPF_H | BPF_IND, MAX_K),
 			BPF_STMT(BPF_RET | BPF_K, 1)
@@ -162,7 +162,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_ABS",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS, 1000),
 			BPF_STMT(BPF_RET | BPF_K, 1)
 		},
@@ -172,7 +172,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_ABS_LL",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, SKF_LL_OFF),
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, SKF_LL_OFF + 1),
@@ -185,7 +185,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_IND_LL",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, SKF_LL_OFF - 1),
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
@@ -199,7 +199,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_ABS_NET",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, SKF_NET_OFF),
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, SKF_NET_OFF + 1),
@@ -212,7 +212,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_IND_NET",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, SKF_NET_OFF - 15),
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_ALU | BPF_ADD | BPF_X, 0),
@@ -226,7 +226,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_PKTTYPE",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_PKTTYPE),
 			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, SKB_TYPE, 1, 0),
@@ -247,7 +247,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_MARK",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_MARK),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -258,7 +258,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_RXHASH",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_RXHASH),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -269,7 +269,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_QUEUE",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_QUEUE),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -280,7 +280,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_PROTOCOL",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 1),
 			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_K, 20, 1, 0),
 			BPF_STMT(BPF_RET | BPF_K, 0),
@@ -299,7 +299,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_VLAN_TAG",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_VLAN_TAG),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -313,7 +313,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_VLAN_TAG_PRESENT",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_VLAN_TAG_PRESENT),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -327,7 +327,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_IFINDEX",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_IFINDEX),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -338,7 +338,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_HATYPE",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_HATYPE),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -349,7 +349,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_CPU",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_CPU),
 			BPF_STMT(BPF_MISC | BPF_TAX, 0),
@@ -364,7 +364,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_NLATTR",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_IMM, 1),
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_LDX | BPF_IMM, 3),
@@ -378,7 +378,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_NLATTR_NEST",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 1),
 			BPF_STMT(BPF_LDX | BPF_IMM, 3),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
@@ -412,7 +412,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_PAYLOAD_OFF",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
 				 SKF_AD_OFF + SKF_AD_PAY_OFFSET),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
@@ -439,7 +439,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"LD_ANC_XOR",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 10),
 			BPF_STMT(BPF_LDX | BPF_IMM, 300),
 			BPF_STMT(BPF_LD | BPF_W | BPF_ABS,
@@ -452,7 +452,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"SPILL_FILL",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_LD | BPF_IMM, 2),
 			BPF_STMT(BPF_ALU | BPF_RSH, 1),
@@ -474,7 +474,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"JEQ",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 2),
 			BPF_JUMP(BPF_JMP | BPF_JEQ | BPF_X, 0, 0, 1),
@@ -487,7 +487,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"JGT",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_LD | BPF_B | BPF_ABS, 2),
 			BPF_JUMP(BPF_JMP | BPF_JGT | BPF_X, 0, 0, 1),
@@ -500,7 +500,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"JGE",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LDX | BPF_LEN, 0),
 			BPF_STMT(BPF_LD | BPF_B | BPF_IND, MAX_K),
 			BPF_JUMP(BPF_JMP | BPF_JGE | BPF_K, 1, 1, 0),
@@ -519,7 +519,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"JSET",
-		.insns = {
+		.u.insns = {
 			BPF_JUMP(BPF_JMP | BPF_JA, 0, 0, 0),
 			BPF_JUMP(BPF_JMP | BPF_JA, 1, 1, 1),
 			BPF_JUMP(BPF_JMP | BPF_JA, 0, 0, 0),
@@ -551,7 +551,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"tcpdump port 22",
-		.insns = {
+		.u.insns = {
 			{ 0x28,  0,  0, 0x0000000c },
 			{ 0x15,  0,  8, 0x000086dd },
 			{ 0x30,  0,  0, 0x00000014 },
@@ -596,7 +596,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"tcpdump complex",
-		.insns = {
+		.u.insns = {
 			/* tcpdump -nei eth0 'tcp port 22 and (((ip[2:2] -
 			 * ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0) and
 			 * (len > 115 or len < 30000000000)' -d
@@ -649,7 +649,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"RET_A",
-		.insns = {
+		.u.insns = {
 			/* check that unitialized X and A contain zeros */
 			BPF_STMT(BPF_MISC | BPF_TXA, 0),
 			BPF_STMT(BPF_RET | BPF_A, 0)
@@ -660,7 +660,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: ADD trivial",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R1, 1),
 			BPF_ALU64_IMM(BPF_ADD, R1, 2),
 			BPF_ALU64_IMM(BPF_MOV, R2, 3),
@@ -676,7 +676,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: MUL_X",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R0, -1),
 			BPF_ALU64_IMM(BPF_MOV, R1, -1),
 			BPF_ALU64_IMM(BPF_MOV, R2, 3),
@@ -692,7 +692,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: MUL_X2",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, -1),
 			BPF_ALU32_IMM(BPF_MOV, R1, -1),
 			BPF_ALU32_IMM(BPF_MOV, R2, 3),
@@ -709,7 +709,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: MUL32_X",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, -1),
 			BPF_ALU64_IMM(BPF_MOV, R1, -1),
 			BPF_ALU32_IMM(BPF_MOV, R2, 3),
@@ -730,7 +730,7 @@ static struct bpf_test tests[] = {
 		 * different asm code.
 		 */
 		"INT: ADD 64-bit",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 0),
 			BPF_ALU64_IMM(BPF_MOV, R1, 1),
 			BPF_ALU64_IMM(BPF_MOV, R2, 2),
@@ -888,7 +888,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: ADD 32-bit",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU32_IMM(BPF_MOV, R0, 20),
 			BPF_ALU32_IMM(BPF_MOV, R1, 1),
 			BPF_ALU32_IMM(BPF_MOV, R2, 2),
@@ -1034,7 +1034,7 @@ static struct bpf_test tests[] = {
 	},
 	{	/* Mainly checking JIT here. */
 		"INT: SUB",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 0),
 			BPF_ALU64_IMM(BPF_MOV, R1, 1),
 			BPF_ALU64_IMM(BPF_MOV, R2, 2),
@@ -1167,7 +1167,7 @@ static struct bpf_test tests[] = {
 	},
 	{	/* Mainly checking JIT here. */
 		"INT: XOR",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_REG(BPF_SUB, R0, R0),
 			BPF_ALU64_REG(BPF_XOR, R1, R1),
 			BPF_JMP_REG(BPF_JEQ, R0, R1, 1),
@@ -1233,7 +1233,7 @@ static struct bpf_test tests[] = {
 	},
 	{	/* Mainly checking JIT here. */
 		"INT: MUL",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 11),
 			BPF_ALU64_IMM(BPF_MOV, R1, 1),
 			BPF_ALU64_IMM(BPF_MOV, R2, 2),
@@ -1295,7 +1295,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: ALU MIX",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_IMM(BPF_MOV, R0, 11),
 			BPF_ALU64_IMM(BPF_ADD, R0, -1),
 			BPF_ALU64_IMM(BPF_MOV, R2, 2),
@@ -1315,7 +1315,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: DIV + ABS",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_REG(BPF_MOV, R6, R1),
 			BPF_LD_ABS(BPF_B, 3),
 			BPF_ALU64_IMM(BPF_MOV, R2, 2),
@@ -1332,7 +1332,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"INT: DIV by zero",
-		.insns_int = {
+		.u.insns_int = {
 			BPF_ALU64_REG(BPF_MOV, R6, R1),
 			BPF_ALU64_IMM(BPF_MOV, R7, 0),
 			BPF_LD_ABS(BPF_B, 3),
@@ -1345,7 +1345,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"check: missing ret",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_LD | BPF_IMM, 1),
 		},
 		EXPECTED_FAIL,
@@ -1354,7 +1354,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"check: div_k_0",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_ALU | BPF_DIV | BPF_K, 0),
 			BPF_STMT(BPF_RET | BPF_K, 0)
 		},
@@ -1364,7 +1364,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"check: unknown insn",
-		.insns = {
+		.u.insns = {
 			/* seccomp insn, rejected in socket filter */
 			BPF_STMT(BPF_LDX | BPF_W | BPF_ABS, 0),
 			BPF_STMT(BPF_RET | BPF_K, 0)
@@ -1375,7 +1375,7 @@ static struct bpf_test tests[] = {
 	},
 	{
 		"check: out of range spill/fill",
-		.insns = {
+		.u.insns = {
 			BPF_STMT(BPF_STX, 16),
 			BPF_STMT(BPF_RET | BPF_K, 0)
 		},
@@ -1478,7 +1478,7 @@ static __init int test_bpf(void)
 	for (i = 0; i < ARRAY_SIZE(tests); i++) {
 		pr_info("#%d %s ", i, tests[i].descr);
 
-		fprog.filter = tests[i].insns;
+		fprog.filter = tests[i].u.insns;
 		fprog.len = get_length(fprog.filter);
 
 		if (tests[i].data_type == SKB_INT) {
@@ -1486,7 +1486,7 @@ static __init int test_bpf(void)
 			if (!fp_ext)
 				return -ENOMEM;
 			fp = fp_ext;
-			memcpy(fp_ext->insns, tests[i].insns_int,
+			memcpy(fp_ext->insns, tests[i].u.insns_int,
 			       fprog.len * 8);
 			fp->len = fprog.len;
 			sk_filter_select_runtime(fp);
_
