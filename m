From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next] samples/bpf: fix in-source build of samples with clang
Date: Mon, 11 May 2015 21:25:51 -0700
Message-ID: <1431404751-18298-1-git-send-email-ast@plumgrid.com>
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36754 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbELE0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 00:26:00 -0400
Received: by pdea3 with SMTP id a3so168639855pde.3
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 21:26:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brenden Blanco <bblanco@plumgrid.com>

in-source build of 'make samples/bpf/' was incorrectly
using default compiler instead of invoking clang/llvm.
out-of-source build was ok.

Fixes: a80857822b0c ("samples: bpf: trivial eBPF program in C")
Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
It's a minor fix and not strictly necessary for stable.

 samples/bpf/Makefile |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 76e3458a5419..8fdbd73429dd 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -44,7 +44,7 @@ HOSTLOADLIBES_tracex4 += -lelf -lrt
 # point this to your LLVM backend with bpf support
 LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
 
-%.o: %.c
+$(obj)/%.o: $(src)/%.c
 	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
 		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
-- 
1.7.9.5
