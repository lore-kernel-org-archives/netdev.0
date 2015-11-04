From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] bpf: add mod default A and X test cases
Date: Wed,  4 Nov 2015 11:36:37 -0800
Message-ID: <1446665797-21400-1-git-send-email-yang.shi@linaro.org>
Cc: zlim.lnx@gmail.com, xi.wang@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When running "mod X" operation, if X is 0 the filter has to be halt.
Add new test cases to cover A = A mod X if X is 0, and A = A mod 1.

CC: Xi Wang <xi.wang@gmail.com>
CC: Zi Shen Lim <zlim.lnx@gmail.com>
Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 lib/test_bpf.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index d137739..10cd186 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -5056,6 +5056,36 @@ static struct bpf_test tests[] = {
 		{ {0x1, 0x0 } },
 	},
 	{
+		"MOD default X",
+		.u.insns = {
+			/*
+			 * A = 0x42
+			 * A = A mod X ; this halt the filter execution if X is 0
+			 * ret 0x42
+			 */
+			BPF_STMT(BPF_LD | BPF_IMM, 0x42),
+			BPF_STMT(BPF_ALU | BPF_MOD | BPF_X, 0),
+			BPF_STMT(BPF_RET | BPF_K, 0x42),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
+		"MOD default A",
+		.u.insns = {
+			/*
+			 * A = A mod 1
+			 * ret A
+			 */
+			BPF_STMT(BPF_ALU | BPF_MOD | BPF_K, 0x1),
+			BPF_STMT(BPF_RET | BPF_A, 0x0),
+		},
+		CLASSIC | FLAG_NO_DATA,
+		{},
+		{ {0x1, 0x0 } },
+	},
+	{
 		"JMP EQ default A",
 		.u.insns = {
 			/*
-- 
2.0.2
