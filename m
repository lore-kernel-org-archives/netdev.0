From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCHv2 net 2/3] samples/bpf: Use llc in PATH, rather than a hardcoded value
Date: Mon,  4 Apr 2016 22:31:33 +0530
Message-ID: <000e23c21f475e7106c74a83eb6226c4cb8d4a14.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: Alexei Starovoitov <ast@fb.com>,
	"David S . Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ananth N Mavinakayanahalli <ananth@in.ibm.com>,
	Michael Ellerman <mpe@ellerman.id.au>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
References: <5ab5eec91d2d0bc7f221d714ef84afac83b2604b.1459789086.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While at it, remove the generation of .s files and fix some typos in the
related comment.

Cc: Alexei Starovoitov <ast@fb.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Ananth N Mavinakayanahalli <ananth@in.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
v2: removed generation of .s files

 samples/bpf/Makefile | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 502c9fc..b820cc9 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -76,16 +76,10 @@ HOSTLOADLIBES_offwaketime += -lelf
 HOSTLOADLIBES_spintest += -lelf
 HOSTLOADLIBES_map_perf_test += -lelf -lrt
 
-# point this to your LLVM backend with bpf support
-LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
-
-# asm/sysreg.h inline assmbly used by it is incompatible with llvm.
-# But, ehere is not easy way to fix it, so just exclude it since it is
+# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
+# But, there is no easy way to fix it, so just exclude it since it is
 # useless for BPF samples.
 $(obj)/%.o: $(src)/%.c
 	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
 		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
-		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
-	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
-		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
-		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=asm -o $@.s
+		-O2 -emit-llvm -c $< -o -| llc -march=bpf -filetype=obj -o $@
-- 
2.7.4
