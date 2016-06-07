From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 0/6] eBPF JIT for PPC64
Date: Tue,  7 Jun 2016 19:02:17 +0530
Message-ID: <cover.1465304785.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Matt Evans" <matt@ozlabs.org>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"Paul Mackerras" <paulus@samba.org>,
	"Alexei Starovoitov" <ast@fb.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>,
	"Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, mpe@ellerman.id.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement extended BPF JIT for ppc64. We retain the classic BPF JIT for
ppc32 and move ppc64 BE/LE to use the new JIT. Classic BPF filters will
be converted to extended BPF (see convert_filter()) and JIT'ed with the
new compiler.

Most of the existing macros are retained and fixed/enhanced where
appropriate. Patches 1-4 are geared towards this.

Patch 5 breaks out the classic BPF JIT specifics into a separate
bpf_jit32.h header file, while retaining all the generic instruction
macros in bpf_jit.h.

Patch 6 implements eBPF JIT for ppc64.

Since the RFC patchset [1], powerpc JIT has now gained support for skb
access helpers and now passes all tests in test_bpf.ko. Review comments
on the RFC patches have been addressed (use of an ABI macro [2] and use
of bpf_jit_binary_alloc()), along with a few other generic fixes and
updates.

Prominent TODOs:
 - implement BPF tail calls
 - support for BPF constant blinding

Please note that patch [2] is a pre-requisite for this patchset, and is
not yet upstream.


- Naveen

[1] http://thread.gmane.org/gmane.linux.kernel/2188694
[2] http://thread.gmane.org/gmane.linux.ports.ppc.embedded/96514


Naveen N. Rao (6):
  ppc: bpf/jit: Fix/enhance 32-bit Load Immediate implementation
  ppc: bpf/jit: Optimize 64-bit Immediate loads
  ppc: bpf/jit: Introduce rotate immediate instructions
  ppc: bpf/jit: A few cleanups
  ppc: bpf/jit: Isolate classic BPF JIT specifics into a separate header
  ppc: ebpf/jit: Implement JIT compiler for extended BPF

 arch/powerpc/Kconfig                  |   3 +-
 arch/powerpc/include/asm/asm-compat.h |   2 +
 arch/powerpc/include/asm/ppc-opcode.h |  22 +-
 arch/powerpc/net/Makefile             |   4 +
 arch/powerpc/net/bpf_jit.h            | 235 ++++-----
 arch/powerpc/net/bpf_jit32.h          | 139 +++++
 arch/powerpc/net/bpf_jit64.h          | 102 ++++
 arch/powerpc/net/bpf_jit_asm.S        |   2 +-
 arch/powerpc/net/bpf_jit_asm64.S      | 180 +++++++
 arch/powerpc/net/bpf_jit_comp.c       |  10 +-
 arch/powerpc/net/bpf_jit_comp64.c     | 956 ++++++++++++++++++++++++++++++++++
 11 files changed, 1504 insertions(+), 151 deletions(-)
 create mode 100644 arch/powerpc/net/bpf_jit32.h
 create mode 100644 arch/powerpc/net/bpf_jit64.h
 create mode 100644 arch/powerpc/net/bpf_jit_asm64.S
 create mode 100644 arch/powerpc/net/bpf_jit_comp64.c

-- 
2.8.2
