From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net, lib: kill arch_fast_hash library bits
Date: Wed, 10 Dec 2014 16:33:12 +0100
Message-ID: <1418225592-29322-4-git-send-email-dborkman@redhat.com>
References: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, tgraf@suug.ch, hannes@stressinduktion.org,
	Francesco Fusco <fusco@ntop.org>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37429 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757954AbaLJPeZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 10:34:25 -0500
In-Reply-To: <1418225592-29322-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As there are now no remaining users of arch_fast_hash(), lets kill
it entirely.

This basically reverts commit 71ae8aac3e19 ("lib: introduce arch
optimized hash library") and follow-up work, that is f.e., commit
237217546d44 ("lib: hash: follow-up fixups for arch hash"),
commit e3fec2f74f7f ("lib: Add missing arch generic-y entries for
asm-generic/hash.h") and last but not least commit 6a02652df511
("perf tools: Fix include for non x86 architectures").

Cc: Francesco Fusco <fusco@ntop.org>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 arch/alpha/include/asm/Kbuild      |  1 -
 arch/arc/include/asm/Kbuild        |  1 -
 arch/arm/include/asm/Kbuild        |  1 -
 arch/arm64/include/asm/Kbuild      |  1 -
 arch/avr32/include/asm/Kbuild      |  1 -
 arch/blackfin/include/asm/Kbuild   |  1 -
 arch/c6x/include/asm/Kbuild        |  1 -
 arch/cris/include/asm/Kbuild       |  1 -
 arch/frv/include/asm/Kbuild        |  1 -
 arch/hexagon/include/asm/Kbuild    |  1 -
 arch/ia64/include/asm/Kbuild       |  1 -
 arch/m32r/include/asm/Kbuild       |  1 -
 arch/m68k/include/asm/Kbuild       |  1 -
 arch/metag/include/asm/Kbuild      |  1 -
 arch/microblaze/include/asm/Kbuild |  1 -
 arch/mips/include/asm/Kbuild       |  1 -
 arch/mn10300/include/asm/Kbuild    |  1 -
 arch/openrisc/include/asm/Kbuild   |  1 -
 arch/parisc/include/asm/Kbuild     |  1 -
 arch/powerpc/include/asm/Kbuild    |  1 -
 arch/s390/include/asm/Kbuild       |  1 -
 arch/score/include/asm/Kbuild      |  1 -
 arch/sh/include/asm/Kbuild         |  1 -
 arch/sparc/include/asm/Kbuild      |  1 -
 arch/tile/include/asm/Kbuild       |  1 -
 arch/um/include/asm/Kbuild         |  1 -
 arch/unicore32/include/asm/Kbuild  |  1 -
 arch/x86/include/asm/hash.h        |  7 ---
 arch/x86/lib/Makefile              |  2 +-
 arch/x86/lib/hash.c                | 92 --------------------------------------
 arch/xtensa/include/asm/Kbuild     |  1 -
 include/asm-generic/hash.h         |  9 ----
 include/linux/hash.h               | 35 ---------------
 lib/Makefile                       |  2 +-
 lib/hash.c                         | 39 ----------------
 tools/perf/util/include/asm/hash.h |  6 ---
 36 files changed, 2 insertions(+), 218 deletions(-)
 delete mode 100644 arch/x86/include/asm/hash.h
 delete mode 100644 arch/x86/lib/hash.c
 delete mode 100644 include/asm-generic/hash.h
 delete mode 100644 lib/hash.c
 delete mode 100644 tools/perf/util/include/asm/hash.h

diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
index 25b4972..76aeb8f 100644
--- a/arch/alpha/include/asm/Kbuild
+++ b/arch/alpha/include/asm/Kbuild
@@ -3,7 +3,6 @@
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index b8fffc1..be0c39e 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -12,7 +12,6 @@ generic-y += fb.h
 generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 70cd84e..fe74c0d 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -7,7 +7,6 @@ generic-y += current.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
 generic-y += irq_regs.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index dc770bd..6b61091 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -14,7 +14,6 @@ generic-y += early_ioremap.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += ftrace.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/avr32/include/asm/Kbuild b/arch/avr32/include/asm/Kbuild
index 2a71b1c..528d70d 100644
--- a/arch/avr32/include/asm/Kbuild
+++ b/arch/avr32/include/asm/Kbuild
@@ -7,7 +7,6 @@ generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
 generic-y += futex.h
-generic-y += hash.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += local.h
diff --git a/arch/blackfin/include/asm/Kbuild b/arch/blackfin/include/asm/Kbuild
index 46ed6bb..4bd3c3c 100644
--- a/arch/blackfin/include/asm/Kbuild
+++ b/arch/blackfin/include/asm/Kbuild
@@ -10,7 +10,6 @@ generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += fb.h
 generic-y += futex.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
diff --git a/arch/c6x/include/asm/Kbuild b/arch/c6x/include/asm/Kbuild
index e77e0c1..2de7339 100644
--- a/arch/c6x/include/asm/Kbuild
+++ b/arch/c6x/include/asm/Kbuild
@@ -15,7 +15,6 @@ generic-y += exec.h
 generic-y += fb.h
 generic-y += fcntl.h
 generic-y += futex.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += io.h
 generic-y += ioctl.h
diff --git a/arch/cris/include/asm/Kbuild b/arch/cris/include/asm/Kbuild
index 2ca489e..d5f1248 100644
--- a/arch/cris/include/asm/Kbuild
+++ b/arch/cris/include/asm/Kbuild
@@ -7,7 +7,6 @@ generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += linkage.h
diff --git a/arch/frv/include/asm/Kbuild b/arch/frv/include/asm/Kbuild
index 3caf05c..e3f81b5 100644
--- a/arch/frv/include/asm/Kbuild
+++ b/arch/frv/include/asm/Kbuild
@@ -2,7 +2,6 @@
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 5f234a5..c7a99f8 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -16,7 +16,6 @@ generic-y += fb.h
 generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/ia64/include/asm/Kbuild b/arch/ia64/include/asm/Kbuild
index 747320b..9b41b4b 100644
--- a/arch/ia64/include/asm/Kbuild
+++ b/arch/ia64/include/asm/Kbuild
@@ -1,7 +1,6 @@
 
 generic-y += clkdev.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += kvm_para.h
 generic-y += mcs_spinlock.h
diff --git a/arch/m32r/include/asm/Kbuild b/arch/m32r/include/asm/Kbuild
index 3796801..2edc793 100644
--- a/arch/m32r/include/asm/Kbuild
+++ b/arch/m32r/include/asm/Kbuild
@@ -2,7 +2,6 @@
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += module.h
diff --git a/arch/m68k/include/asm/Kbuild b/arch/m68k/include/asm/Kbuild
index dbaf9f3..9b6c691 100644
--- a/arch/m68k/include/asm/Kbuild
+++ b/arch/m68k/include/asm/Kbuild
@@ -6,7 +6,6 @@ generic-y += device.h
 generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
diff --git a/arch/metag/include/asm/Kbuild b/arch/metag/include/asm/Kbuild
index 7b8111c..0bf5d52 100644
--- a/arch/metag/include/asm/Kbuild
+++ b/arch/metag/include/asm/Kbuild
@@ -13,7 +13,6 @@ generic-y += fb.h
 generic-y += fcntl.h
 generic-y += futex.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/microblaze/include/asm/Kbuild b/arch/microblaze/include/asm/Kbuild
index 448143b..ab564a6 100644
--- a/arch/microblaze/include/asm/Kbuild
+++ b/arch/microblaze/include/asm/Kbuild
@@ -4,7 +4,6 @@ generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += device.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/mips/include/asm/Kbuild b/arch/mips/include/asm/Kbuild
index 72e1cf1..200efea 100644
--- a/arch/mips/include/asm/Kbuild
+++ b/arch/mips/include/asm/Kbuild
@@ -3,7 +3,6 @@ generic-y += cputime.h
 generic-y += current.h
 generic-y += dma-contiguous.h
 generic-y += emergency-restart.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
diff --git a/arch/mn10300/include/asm/Kbuild b/arch/mn10300/include/asm/Kbuild
index 54a062c..f892d9d 100644
--- a/arch/mn10300/include/asm/Kbuild
+++ b/arch/mn10300/include/asm/Kbuild
@@ -3,7 +3,6 @@ generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += cputime.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/openrisc/include/asm/Kbuild b/arch/openrisc/include/asm/Kbuild
index 89b61d7..91f1f36 100644
--- a/arch/openrisc/include/asm/Kbuild
+++ b/arch/openrisc/include/asm/Kbuild
@@ -25,7 +25,6 @@ generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += futex.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/parisc/include/asm/Kbuild b/arch/parisc/include/asm/Kbuild
index ffb024b..8686237 100644
--- a/arch/parisc/include/asm/Kbuild
+++ b/arch/parisc/include/asm/Kbuild
@@ -7,7 +7,6 @@ generic-y += device.h
 generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 31e8f59..382b28e 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -1,6 +1,5 @@
 
 generic-y += clkdev.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/s390/include/asm/Kbuild b/arch/s390/include/asm/Kbuild
index 773f866..c631f98 100644
--- a/arch/s390/include/asm/Kbuild
+++ b/arch/s390/include/asm/Kbuild
@@ -1,7 +1,6 @@
 
 
 generic-y += clkdev.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/score/include/asm/Kbuild b/arch/score/include/asm/Kbuild
index 46461c1..83ed116 100644
--- a/arch/score/include/asm/Kbuild
+++ b/arch/score/include/asm/Kbuild
@@ -5,7 +5,6 @@ header-y +=
 generic-y += barrier.h
 generic-y += clkdev.h
 generic-y += cputime.h
-generic-y += hash.h
 generic-y += irq_work.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 5a6c9ac..654ebb6 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -8,7 +8,6 @@ generic-y += emergency-restart.h
 generic-y += errno.h
 generic-y += exec.h
 generic-y += fcntl.h
-generic-y += hash.h
 generic-y += ioctl.h
 generic-y += ipcbuf.h
 generic-y += irq_regs.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index f5f94ce..94f36e7 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -6,7 +6,6 @@ generic-y += cputime.h
 generic-y += div64.h
 generic-y += emergency-restart.h
 generic-y += exec.h
-generic-y += hash.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
 generic-y += linkage.h
diff --git a/arch/tile/include/asm/Kbuild b/arch/tile/include/asm/Kbuild
index e6462b8..b4c488b 100644
--- a/arch/tile/include/asm/Kbuild
+++ b/arch/tile/include/asm/Kbuild
@@ -11,7 +11,6 @@ generic-y += errno.h
 generic-y += exec.h
 generic-y += fb.h
 generic-y += fcntl.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/um/include/asm/Kbuild b/arch/um/include/asm/Kbuild
index 244b12c..9176fa1 100644
--- a/arch/um/include/asm/Kbuild
+++ b/arch/um/include/asm/Kbuild
@@ -10,7 +10,6 @@ generic-y += exec.h
 generic-y += ftrace.h
 generic-y += futex.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += io.h
 generic-y += irq_regs.h
diff --git a/arch/unicore32/include/asm/Kbuild b/arch/unicore32/include/asm/Kbuild
index 5a2bb53..3e0c19d 100644
--- a/arch/unicore32/include/asm/Kbuild
+++ b/arch/unicore32/include/asm/Kbuild
@@ -16,7 +16,6 @@ generic-y += fcntl.h
 generic-y += ftrace.h
 generic-y += futex.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += hw_irq.h
 generic-y += ioctl.h
 generic-y += ioctls.h
diff --git a/arch/x86/include/asm/hash.h b/arch/x86/include/asm/hash.h
deleted file mode 100644
index e8c58f8..0000000
--- a/arch/x86/include/asm/hash.h
+++ /dev/null
@@ -1,7 +0,0 @@
-#ifndef _ASM_X86_HASH_H
-#define _ASM_X86_HASH_H
-
-struct fast_hash_ops;
-extern void setup_arch_fast_hash(struct fast_hash_ops *ops);
-
-#endif /* _ASM_X86_HASH_H */
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index db92793..1530afb 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -23,7 +23,7 @@ lib-y += memcpy_$(BITS).o
 lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
 
-obj-y += msr.o msr-reg.o msr-reg-export.o hash.o
+obj-y += msr.o msr-reg.o msr-reg-export.o
 
 ifeq ($(CONFIG_X86_32),y)
         obj-y += atomic64_32.o
diff --git a/arch/x86/lib/hash.c b/arch/x86/lib/hash.c
deleted file mode 100644
index ff4fa51..0000000
--- a/arch/x86/lib/hash.c
+++ /dev/null
@@ -1,92 +0,0 @@
-/*
- * Some portions derived from code covered by the following notice:
- *
- * Copyright (c) 2010-2013 Intel Corporation. All rights reserved.
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- *
- *   * Redistributions of source code must retain the above copyright
- *     notice, this list of conditions and the following disclaimer.
- *   * Redistributions in binary form must reproduce the above copyright
- *     notice, this list of conditions and the following disclaimer in
- *     the documentation and/or other materials provided with the
- *     distribution.
- *   * Neither the name of Intel Corporation nor the names of its
- *     contributors may be used to endorse or promote products derived
- *     from this software without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
- * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
- * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
- * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
- * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
- * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
- * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
- * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#include <linux/hash.h>
-#include <linux/init.h>
-
-#include <asm/processor.h>
-#include <asm/cpufeature.h>
-#include <asm/hash.h>
-
-static inline u32 crc32_u32(u32 crc, u32 val)
-{
-#ifdef CONFIG_AS_CRC32
-	asm ("crc32l %1,%0\n" : "+r" (crc) : "rm" (val));
-#else
-	asm (".byte 0xf2, 0x0f, 0x38, 0xf1, 0xc1" : "+a" (crc) : "c" (val));
-#endif
-	return crc;
-}
-
-static u32 intel_crc4_2_hash(const void *data, u32 len, u32 seed)
-{
-	const u32 *p32 = (const u32 *) data;
-	u32 i, tmp = 0;
-
-	for (i = 0; i < len / 4; i++)
-		seed = crc32_u32(seed, *p32++);
-
-	switch (len & 3) {
-	case 3:
-		tmp |= *((const u8 *) p32 + 2) << 16;
-		/* fallthrough */
-	case 2:
-		tmp |= *((const u8 *) p32 + 1) << 8;
-		/* fallthrough */
-	case 1:
-		tmp |= *((const u8 *) p32);
-		seed = crc32_u32(seed, tmp);
-		break;
-	}
-
-	return seed;
-}
-
-static u32 intel_crc4_2_hash2(const u32 *data, u32 len, u32 seed)
-{
-	const u32 *p32 = (const u32 *) data;
-	u32 i;
-
-	for (i = 0; i < len; i++)
-		seed = crc32_u32(seed, *p32++);
-
-	return seed;
-}
-
-void __init setup_arch_fast_hash(struct fast_hash_ops *ops)
-{
-	if (cpu_has_xmm4_2) {
-		ops->hash  = intel_crc4_2_hash;
-		ops->hash2 = intel_crc4_2_hash2;
-	}
-}
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index 105d389..86a9ab2 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -9,7 +9,6 @@ generic-y += errno.h
 generic-y += exec.h
 generic-y += fcntl.h
 generic-y += hardirq.h
-generic-y += hash.h
 generic-y += ioctl.h
 generic-y += irq_regs.h
 generic-y += irq_work.h
diff --git a/include/asm-generic/hash.h b/include/asm-generic/hash.h
deleted file mode 100644
index b631284..0000000
--- a/include/asm-generic/hash.h
+++ /dev/null
@@ -1,9 +0,0 @@
-#ifndef __ASM_GENERIC_HASH_H
-#define __ASM_GENERIC_HASH_H
-
-struct fast_hash_ops;
-static inline void setup_arch_fast_hash(struct fast_hash_ops *ops)
-{
-}
-
-#endif /* __ASM_GENERIC_HASH_H */
diff --git a/include/linux/hash.h b/include/linux/hash.h
index d0494c3..1afde47 100644
--- a/include/linux/hash.h
+++ b/include/linux/hash.h
@@ -15,7 +15,6 @@
  */
 
 #include <asm/types.h>
-#include <asm/hash.h>
 #include <linux/compiler.h>
 
 /* 2^31 + 2^29 - 2^25 + 2^22 - 2^19 - 2^16 + 1 */
@@ -84,38 +83,4 @@ static inline u32 hash32_ptr(const void *ptr)
 	return (u32)val;
 }
 
-struct fast_hash_ops {
-	u32 (*hash)(const void *data, u32 len, u32 seed);
-	u32 (*hash2)(const u32 *data, u32 len, u32 seed);
-};
-
-/**
- *	arch_fast_hash - Caclulates a hash over a given buffer that can have
- *			 arbitrary size. This function will eventually use an
- *			 architecture-optimized hashing implementation if
- *			 available, and trades off distribution for speed.
- *
- *	@data: buffer to hash
- *	@len: length of buffer in bytes
- *	@seed: start seed
- *
- *	Returns 32bit hash.
- */
-extern u32 arch_fast_hash(const void *data, u32 len, u32 seed);
-
-/**
- *	arch_fast_hash2 - Caclulates a hash over a given buffer that has a
- *			  size that is of a multiple of 32bit words. This
- *			  function will eventually use an architecture-
- *			  optimized hashing implementation if available,
- *			  and trades off distribution for speed.
- *
- *	@data: buffer to hash (must be 32bit padded)
- *	@len: number of 32bit words
- *	@seed: start seed
- *
- *	Returns 32bit hash.
- */
-extern u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed);
-
 #endif /* _LINUX_HASH_H */
diff --git a/lib/Makefile b/lib/Makefile
index 0211d2b..4b9baa4 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -26,7 +26,7 @@ obj-y += bcd.o div64.o sort.o parser.o halfmd4.o debug_locks.o random32.o \
 	 bust_spinlocks.o hexdump.o kasprintf.o bitmap.o scatterlist.o \
 	 gcd.o lcm.o list_sort.o uuid.o flex_array.o iovec.o clz_ctz.o \
 	 bsearch.o find_last_bit.o find_next_bit.o llist.o memweight.o kfifo.o \
-	 percpu-refcount.o percpu_ida.o hash.o rhashtable.o reciprocal_div.o
+	 percpu-refcount.o percpu_ida.o rhashtable.o reciprocal_div.o
 obj-y += string_helpers.o
 obj-$(CONFIG_TEST_STRING_HELPERS) += test-string_helpers.o
 obj-y += kstrtox.o
diff --git a/lib/hash.c b/lib/hash.c
deleted file mode 100644
index fea973f..0000000
--- a/lib/hash.c
+++ /dev/null
@@ -1,39 +0,0 @@
-/* General purpose hashing library
- *
- * That's a start of a kernel hashing library, which can be extended
- * with further algorithms in future. arch_fast_hash{2,}() will
- * eventually resolve to an architecture optimized implementation.
- *
- * Copyright 2013 Francesco Fusco <ffusco@redhat.com>
- * Copyright 2013 Daniel Borkmann <dborkman@redhat.com>
- * Copyright 2013 Thomas Graf <tgraf@redhat.com>
- * Licensed under the GNU General Public License, version 2.0 (GPLv2)
- */
-
-#include <linux/jhash.h>
-#include <linux/hash.h>
-#include <linux/cache.h>
-
-static struct fast_hash_ops arch_hash_ops __read_mostly = {
-	.hash  = jhash,
-	.hash2 = jhash2,
-};
-
-u32 arch_fast_hash(const void *data, u32 len, u32 seed)
-{
-	return arch_hash_ops.hash(data, len, seed);
-}
-EXPORT_SYMBOL_GPL(arch_fast_hash);
-
-u32 arch_fast_hash2(const u32 *data, u32 len, u32 seed)
-{
-	return arch_hash_ops.hash2(data, len, seed);
-}
-EXPORT_SYMBOL_GPL(arch_fast_hash2);
-
-static int __init hashlib_init(void)
-{
-	setup_arch_fast_hash(&arch_hash_ops);
-	return 0;
-}
-early_initcall(hashlib_init);
diff --git a/tools/perf/util/include/asm/hash.h b/tools/perf/util/include/asm/hash.h
deleted file mode 100644
index d82b170b..0000000
--- a/tools/perf/util/include/asm/hash.h
+++ /dev/null
@@ -1,6 +0,0 @@
-#ifndef __ASM_GENERIC_HASH_H
-#define __ASM_GENERIC_HASH_H
-
-/* Stub */
-
-#endif /* __ASM_GENERIC_HASH_H */
-- 
1.7.11.7
