From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V4 4/5] samples/bpf: allow make to be run from
 samples/bpf/ directory
Date: Thu, 28 Apr 2016 14:21:09 +0200
Message-ID: <20160428122109.16807.59535.stgit@firesoul>
References: <20160428121949.16807.84828.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753105AbcD1MVK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 08:21:10 -0400
In-Reply-To: <20160428121949.16807.84828.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not intuitive that 'make' must be run from the top level
directory with argument "samples/bpf/" to compile these eBPF samples.

Introduce a kbuild make file trick that allow make to be run from the
"samples/bpf/" directory itself.  It basically change to the top level
directory and call "make samples/bpf/" with the "/" slash after the
directory name.

Also add a clean target that only cleans this directory, by taking
advantage of the kbuild external module setting M=$PWD.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile   |    8 ++++++++
 samples/bpf/README.rst |    3 +++
 2 files changed, 11 insertions(+)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 45859c99f573..dd63521832d8 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -85,6 +85,14 @@ HOSTLOADLIBES_test_overhead += -lelf -lrt
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc
 LLC ?= llc
 
+# Trick to allow make to be run from this directory
+all:
+	$(MAKE) -C ../../ $$PWD/
+
+clean:
+	$(MAKE) -C ../../ M=$$PWD clean
+	@rm -f *~
+
 # Verify LLVM compiler is available and bpf target is supported
 .PHONY: verify_cmd_llc verify_target_bpf
 
diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index 993d280184fa..0da069ffa434 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -36,6 +36,9 @@ top level directory::
 
 Do notice the "/" slash after the directory name.
 
+It is also possible to call make from this directory.  This will just
+hide the the invocation of make as above with the appended "/".
+
 Manually compiling LLVM with 'bpf' support
 ------------------------------------------
 
