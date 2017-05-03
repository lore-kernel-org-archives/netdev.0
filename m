From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] test_bpf: Use ULL suffix for 64-bit constants
Date: Wed,  3 May 2017 13:31:04 +0200
Message-ID: <1493811064-24542-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, --cc@ramsan.of.borg,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit:

    lib/test_bpf.c:4772: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4772: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4773: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4773: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4787: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4787: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4801: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4801: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4802: warning: integer constant is too large for ‘unsigned long’ type
    lib/test_bpf.c:4802: warning: integer constant is too large for ‘unsigned long’ type

On 32-bit systems, "long" is only 32-bit.
Replace the "UL" suffix by "ULL" to fix this.

Fixes: 85f68fe898320575 ("bpf, arm64: implement jiting of BPF_XADD")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 lib/test_bpf.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/test_bpf.c b/lib/test_bpf.c
index a0f66280ea502e63..889bc31785bee579 100644
--- a/lib/test_bpf.c
+++ b/lib/test_bpf.c
@@ -4769,8 +4769,8 @@ static struct bpf_test tests[] = {
 			BPF_LD_IMM64(R1, 3),
 			BPF_LD_IMM64(R2, 2),
 			BPF_JMP_REG(BPF_JGE, R1, R2, 2),
-			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
-			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeUL),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeULL),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -4784,7 +4784,7 @@ static struct bpf_test tests[] = {
 			BPF_LD_IMM64(R1, 3),
 			BPF_LD_IMM64(R2, 2),
 			BPF_JMP_REG(BPF_JGE, R1, R2, 0),
-			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
@@ -4798,8 +4798,8 @@ static struct bpf_test tests[] = {
 			BPF_LD_IMM64(R1, 3),
 			BPF_LD_IMM64(R2, 2),
 			BPF_JMP_REG(BPF_JGE, R1, R2, 4),
-			BPF_LD_IMM64(R0, 0xffffffffffffffffUL),
-			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeUL),
+			BPF_LD_IMM64(R0, 0xffffffffffffffffULL),
+			BPF_LD_IMM64(R0, 0xeeeeeeeeeeeeeeeeULL),
 			BPF_EXIT_INSN(),
 		},
 		INTERNAL,
-- 
2.7.4
