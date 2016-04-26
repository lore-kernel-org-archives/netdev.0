From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V2 4/5] samples/bpf: allow make to be run from
 samples/bpf/ directory
Date: Tue, 26 Apr 2016 18:27:27 +0200
Message-ID: <20160426162727.22962.51631.stgit@firesoul>
References: <20160426162650.22962.20516.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kbuild@vger.kernel.org, bblanco@plumgrid.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	naveen.n.rao@linux.vnet.ibm.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com
To: netdev@vger.kernel.org
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20160426162650.22962.20516.stgit@firesoul>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is not intuitive that 'make' must be run from the top level
directory with argument "samples/bpf/" to compile these eBPF samples.

Introduce a kbuild make file trick that allow make to be run from the
"samples/bpf/" directory itself.  It basically change to the top level
directory and call "make samples/bpf/" with the "/" slash after the
directory name.

Also add a clean target that only cleans this directory, by taking
advantage of the kbuild external module setting M=$PWD.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
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
index c7ccf553af0d..1ec4b08a7b40 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -47,6 +47,9 @@ For compiling goto kernel top level build directory and run make like::
 
 Do notice the "/" slash after the directory name.
 
+It is also possible to call make from this directory.  This will just
+hide the the invocation of make as above with the appended "/".
+
 Manually compiling LLVM with 'bpf' support
 ------------------------------------------
 

