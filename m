From: David Daney <david.daney@cavium.com>
Subject: [PATCH RFC 1/3] arm64: Gate inclusion of asm/sysreg.h by
 __EMITTING_BPF__
Date: Thu, 15 Jun 2017 15:35:41 -0700
Message-ID: <20170615223543.22867-2-david.daney@cavium.com>
References: <20170615223543.22867-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
 Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
 ralf@linux-mips.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170615223543.22867-1-david.daney@cavium.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Compilation to eBPF chokes on the inline asm in asm/sysreg.h, so don't
include it when compiling to a BPF target.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/arm64/include/asm/sysreg.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/include/asm/sysreg.h b/arch/arm64/include/asm/sysreg.h
index 15c142ce991c..faa8f853e369 100644
--- a/arch/arm64/include/asm/sysreg.h
+++ b/arch/arm64/include/asm/sysreg.h
@@ -20,6 +20,8 @@
 #ifndef __ASM_SYSREG_H
 #define __ASM_SYSREG_H
 
+#ifndef __EMITTING_BPF__
+
 #include <linux/stringify.h>
 
 /*
@@ -502,5 +504,5 @@ static inline void config_sctlr_el1(u32 clear, u32 set)
 }
 
 #endif
-
+#endif  /* __EMITTING_BPF__ */
 #endif	/* __ASM_SYSREG_H */
-- 
2.11.0
