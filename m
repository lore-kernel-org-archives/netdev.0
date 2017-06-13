From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 0/5] MIPS: Implement eBPF JIT.
Date: Tue, 13 Jun 2017 15:28:42 -0700
Message-ID: <20170613222847.7122-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes in v2:

  - Squash a couple of the uasm cleanups.

  - Make insn_table_MM const (suggested by Matt Redfearn)

  - Put the eBPF in its own source file (should fix build
    warnings/errors on 32-bit kernel builds).

  - Use bpf_jit_binary_alloc() (suggested by Daniel Borkmann)

  - Implement tail calls.

  - Fix system call tracing to extract arguments for
    kprobe/__seccomp_filter() tracing (perhaps not really part the the
    JIT, but necessary to have fun with the samples/bpf programs).

Most things in samples/bpf work, still working on the incantations to
build tools/testing/selftests/bpf/ ... 


>From v1:

The first three patches improve MIPS uasm in preparation for use by
the JIT.  Then the eBPF JIT implementation.

I am CCing netdev@ and the BPF maintainers for their comments, but
would expect Ralf to merge via the MIPS tree if and when it all looks
good.


David Daney (5):
  MIPS: Optimize uasm insn lookup.
  MIPS: Correctly define DBSHFL type instruction opcodes.
  MIPS: Add some instructions to uasm.
  MIPS: Add support for eBPF JIT.
  MIPS: Give __secure_computing() access to syscall arguments.

 arch/mips/Kconfig                 |   12 +-
 arch/mips/include/asm/uasm.h      |   30 +
 arch/mips/include/uapi/asm/inst.h |    9 +-
 arch/mips/kernel/ptrace.c         |   22 +-
 arch/mips/mm/uasm-micromips.c     |  188 ++--
 arch/mips/mm/uasm-mips.c          |  238 ++---
 arch/mips/mm/uasm.c               |   61 +-
 arch/mips/net/Makefile            |    3 +-
 arch/mips/net/ebpf_jit.c          | 1949 +++++++++++++++++++++++++++++++++++++
 9 files changed, 2285 insertions(+), 227 deletions(-)
 create mode 100644 arch/mips/net/ebpf_jit.c

-- 
2.9.4
