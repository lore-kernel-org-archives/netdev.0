From: David Daney <david.daney@cavium.com>
Subject: [PATCH 3/4] bpf: Add MIPS support to samples/bpf.
Date: Tue, 13 Jun 2017 16:49:37 -0700
Message-ID: <20170613234938.4823-4-david.daney@cavium.com>
References: <20170613234938.4823-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613234938.4823-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Daney <david.daney@cavium.com>
---
 samples/bpf/bpf_helpers.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/samples/bpf/bpf_helpers.h b/samples/bpf/bpf_helpers.h
index 9a9c95f..76526da 100644
--- a/samples/bpf/bpf_helpers.h
+++ b/samples/bpf/bpf_helpers.h
@@ -135,6 +135,19 @@ static int (*bpf_skb_change_head)(void *, int len, int flags) =
 #define PT_REGS_SP(x) ((x)->sp)
 #define PT_REGS_IP(x) ((x)->pc)
 
+#elif defined(__mips__)
+
+#define PT_REGS_PARM1(x) ((x)->regs[4])
+#define PT_REGS_PARM2(x) ((x)->regs[5])
+#define PT_REGS_PARM3(x) ((x)->regs[6])
+#define PT_REGS_PARM4(x) ((x)->regs[7])
+#define PT_REGS_PARM5(x) ((x)->regs[8])
+#define PT_REGS_RET(x) ((x)->regs[31])
+#define PT_REGS_FP(x) ((x)->regs[30]) /* Works only with CONFIG_FRAME_POINTER */
+#define PT_REGS_RC(x) ((x)->regs[1])
+#define PT_REGS_SP(x) ((x)->regs[29])
+#define PT_REGS_IP(x) ((x)->cp0_epc)
+
 #elif defined(__powerpc__)
 
 #define PT_REGS_PARM1(x) ((x)->gpr[3])
-- 
2.9.4
