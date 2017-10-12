From: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
Subject: [PATCH] Add -target to clang switch while cross compiling.
Date: Thu, 12 Oct 2017 16:45:15 -0700
Message-ID: <1507851915-24591-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
References: <1507841157-10487-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: daniel@iogearbox.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
To: ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507841157-10487-1-git-send-email-abhijit.ayarekar@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update to llvm excludes assembly instructions.
llvm git revision is below

commit 2865ab6996164e7854d55c9e21c065fad7c26569
Author: Yonghong Song <yhs@fb.com>
Date:   Mon Sep 18 23:29:36 2017 +0000

    bpf: add inline-asm support

    Signed-off-by: Yonghong Song <yhs@fb.com>
    Acked-by: Alexei Starovoitov <ast@kernel.org>

    git-svn-id: https://llvm.org/svn/llvm-project/llvm/trunk@313593 91177308-0d34-0410-b5e6-96231b3b80d8

__ASM_SYSREG_H define is not required for native compile.
-target switch includes appropriate target specific files
while cross compiling

Tested on x86 and arm64.

Signed-off-by: Abhijit Ayarekar <abhijit.ayarekar@caviumnetworks.com>
---
 samples/bpf/Makefile | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index ebc2ad6..81f9fcd 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -180,6 +180,7 @@ CLANG ?= clang
 # Detect that we're cross compiling and use the cross compiler
 ifdef CROSS_COMPILE
 HOSTCC = $(CROSS_COMPILE)gcc
+CLANG_ARCH_ARGS = -target $(ARCH)
 endif
 
 # Trick to allow make to be run from this directory
@@ -229,9 +230,9 @@ $(obj)/tracex5_kern.o: $(obj)/syscall_nrs.h
 $(obj)/%.o: $(src)/%.c
 	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
 		-I$(srctree)/tools/testing/selftests/bpf/ \
-		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
 		-D__TARGET_ARCH_$(ARCH) -Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
-		-Wno-unknown-warning-option \
+		-Wno-unknown-warning-option $(CLANG_ARCH_ARGS) \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
-- 
2.7.4
