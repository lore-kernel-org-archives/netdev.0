From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 2/5] samples/bpf: Makefile verify LLVM compiler
 avail and bpf target is supported
Date: Tue, 26 Apr 2016 18:27:16 +0200
Message-ID: <20160426162716.22962.36473.stgit@firesoul>
References: <20160426162650.22962.20516.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbcDZQ1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 12:27:18 -0400
In-Reply-To: <20160426162650.22962.20516.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make compiling samples/bpf more user friendly, by detecting if LLVM
compiler tool 'llc' is available, and also detect if the 'bpf' target
is available in this version of LLVM.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/Makefile |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 5bae9536f100..45859c99f573 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -85,6 +85,24 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
 LLC ?= llc
 
+# Verify LLVM compiler is available and bpf target is supported
+.PHONY: verify_cmd_llc verify_target_bpf
+
+verify_cmd_llc:
+	@if ! (which "${LLC}" > /dev/null 2>&1); then \
+		echo "*** ERROR: Cannot find LLVM tool 'llc' (${LLC})" ;\
+		exit 1; \
+	else true; fi
+
+verify_target_bpf: verify_cmd_llc
+	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
+		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
+		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\
+		exit 2; \
+	else true; fi
+
+$(src)/*.c: verify_target_bpf
+
 # asm/sysreg.h - inline assembly used by it is incompatible with llvm.
 # But, there is no easy way to fix it, so just exclude it since it is
 # useless for BPF samples.
