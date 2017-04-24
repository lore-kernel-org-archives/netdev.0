From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next 1/3] samples/bpf: add -Wno-unknown-warning-option to clang
Date: Mon, 24 Apr 2017 15:31:06 +0200
Message-ID: <20170424133108.31595-2-alexander@alemayhu.com>
References: <20170424133108.31595-1-alexander@alemayhu.com>
Cc: Alexander Alemayhu <alexander@alemayhu.com>, daniel@iogearbox.net,
        ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36268 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1171142AbdDXNbT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:31:19 -0400
Received: by mail-lf0-f51.google.com with SMTP id c80so73788687lfh.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 06:31:18 -0700 (PDT)
In-Reply-To: <20170424133108.31595-1-alexander@alemayhu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was initially going to remove '-Wno-address-of-packed-member' because I
thought it was not supposed to be there but Daniel suggested using
'-Wno-unknown-warning-option'. 

This silences several warnings similiar to the one below

warning: unknown warning option '-Wno-address-of-packed-member' [-Wunknown-warning-option]
1 warning generated.
clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.3.1/include -I./arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I./include
 -I./arch/x86/include/uapi -I./include/uapi -I./include/generated/uapi -include ./include/linux/kconfig.h  \
        -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
        -Wno-compare-distinct-pointer-types \
        -Wno-gnu-variable-sized-type-not-at-end \
        -Wno-address-of-packed-member -Wno-tautological-compare \
        -O2 -emit-llvm -c samples/bpf/xdp_tx_iptunnel_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/xdp_tx_iptunnel_kern.o

$ clang --version

 clang version 3.9.1 (tags/RELEASE_391/final)
 Target: x86_64-unknown-linux-gnu
 Thread model: posix
 InstalledDir: /usr/bin

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 samples/bpf/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index d42b495b0992..6c7468eb3684 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -189,4 +189,5 @@ $(obj)/%.o: $(src)/%.c
 		-Wno-compare-distinct-pointer-types \
 		-Wno-gnu-variable-sized-type-not-at-end \
 		-Wno-address-of-packed-member -Wno-tautological-compare \
+		-Wno-unknown-warning-option \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
-- 
2.9.3
