From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 3/4] samples/bpf: add a README file to get users
 started
Date: Tue, 26 Apr 2016 13:09:27 +0200
Message-ID: <20160426110927.20716.89620.stgit@firesoul>
References: <20160426110828.20716.13392.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: bblanco@plumgrid.com, borkmann@iogearbox.net,
	alexei.starovoitov@gmail.com, linux-kbuild@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752568AbcDZLJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 07:09:34 -0400
In-Reply-To: <20160426110828.20716.13392.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Getting started with using examples in samples/bpf/ is not
straightforward.  There are several dependencies, and specific
versions of these dependencies.

Just compiling the example tool is also slightly obscure, e.g. one
need to call make like:

 make samples/bpf/

Do notice the "/" slash after the directory name.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 samples/bpf/README.rst |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 67 insertions(+)
 create mode 100644 samples/bpf/README.rst

diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
new file mode 100644
index 000000000000..3e1ac05d8e7c
--- /dev/null
+++ b/samples/bpf/README.rst
@@ -0,0 +1,67 @@
+eBPF sample programs
+====================
+
+This kernel samples/bpf directory contains a mini eBPF library, test
+stubs, verifier test-suite and examples for using eBPF.
+
+Build dependencies
+==================
+
+Compiling requires having installed:
+ * clang
+ * llvm >= version 3.7.0
+
+Note that LLVM's tool 'llc' must support target 'bpf', list with command::
+
+ $ llc --version
+ LLVM (http://llvm.org/):
+  LLVM version 3.x.y
+  [...]
+  Host CPU: xxx
+
+  Registered Targets:
+    [...]
+    bpf        - BPF (host endian)
+    bpfeb      - BPF (big endian)
+    bpfel      - BPF (little endian)
+    [...]
+
+Kernel headers
+--------------
+
+There are usually dependencies to header files of the current kernel.
+To avoid installing devel kernel headers system wide, as a normal
+user, simply call::
+
+ make headers_install
+
+This will creates a local "usr/include" directory in the git/build top
+level directory, that the make system automatically pickup first.
+
+Compiling
+=========
+
+For compiling goto kernel top level build directory and run make like::
+
+ make samples/bpf/
+
+Do notice the "/" slash after the directory name.
+
+Manually compiling LLVM with 'bpf' support
+------------------------------------------
+
+In some LLVM versions the BPF target were marked experimental.  To
+compile LLVM manually and enable BPF target run (build dependencies
+are cmake and gcc-c++)::
+
+ $ git clone http://llvm.org/git/llvm.git
+ $ cd llvm
+ $ mkdir build; cd build
+ $ cmake .. -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=BPF
+ $ make
+
+It is also possible to point make to the newly compile 'llc' command
+via redefining LLC on the make command line::
+
+ make samples/bpf/ LLC=~/git/llvm/build/bin/llc
+
