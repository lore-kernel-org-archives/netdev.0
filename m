From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH] bpf: samples: exclude asm/sysreg.h for arm64
Date: Thu, 12 Nov 2015 14:07:46 -0800
Message-ID: <1447366066-2203-1-git-send-email-yang.shi@linaro.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, yang.shi@linaro.org
To: ast@kernel.org, daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 338d4f49d6f7114a017d294ccf7374df4f998edc
("arm64: kernel: Add support for Privileged Access Never") includes sysreg.h
into futex.h and uaccess.h. But, the inline assembly used by asm/sysreg.h is
incompatible with llvm so it will cause BPF samples build failure for ARM64.
Since sysreg.h is useless for BPF samples, just exclude it from Makefile via
defining __ASM_SYSREG_H.

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 samples/bpf/Makefile | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 79b4596..edd638b 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -67,10 +67,13 @@ HOSTLOADLIBES_lathist += -lelf
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
 
+# asm/sysreg.h inline assmbly used by it is incompatible with llvm.
+# But, ehere is not easy way to fix it, so just exclude it since it is
+# useless for BPF samples.
 $(obj)/%.o: $(src)/%.c
 	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
-		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
 	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
-		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
-- 
2.0.2
