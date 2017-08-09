From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/9] Add BPF_J{LT,LE,SLT,SLE} instructions
Date: Wed,  9 Aug 2017 12:23:52 +0200
Message-ID: <cover.1502272924.git.daniel@iogearbox.net>
Cc: ast@fb.com, holzheu@linux.vnet.ibm.com,
        naveen.n.rao@linux.vnet.ibm.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58265 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752882AbdHIKYW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 06:24:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set adds BPF_J{LT,LE,SLT,SLE} instructions to the BPF
insn set, interpreter, JIT hardening code and all JITs are
also updated to support the new instructions. Basic idea is
to reduce register pressure by avoiding BPF_J{GT,GE,SGT,SGE}
rewrites. Removing the workaround for the rewrites in LLVM,
this can result in shorter BPF programs, less stack usage
and less verification complexity. First patch provides some
more details on rationale. The LLVM patch [1] will be
integrated to LLVM upstream later in a backwards compatible
manner.

Thanks a lot!

  [1] https://github.com/borkmann/llvm/tree/bpf-insns

Daniel Borkmann (9):
  bpf: add BPF_J{LT,LE,SLT,SLE} instructions
  bpf, x86: implement jiting of BPF_J{LT,LE,SLT,SLE}
  bpf, arm64: implement jiting of BPF_J{LT,LE,SLT,SLE}
  bpf, sparc64: implement jiting of BPF_J{LT,LE,SLT,SLE}
  bpf, s390x: implement jiting of BPF_J{LT,LE,SLT,SLE}
  bpf, ppc64: implement jiting of BPF_J{LT,LE,SLT,SLE}
  bpf, nfp: implement jiting of BPF_J{LT,LE}
  bpf: enable BPF_J{LT,LE,SLT,SLE} opcodes in verifier
  bpf: add test cases for new BPF_J{LT,LE,SLT,SLE} instructions

 Documentation/networking/filter.txt          |   4 +
 arch/arm64/net/bpf_jit.h                     |   4 +
 arch/arm64/net/bpf_jit_comp.c                |  20 ++
 arch/powerpc/net/bpf_jit.h                   |   1 +
 arch/powerpc/net/bpf_jit_comp64.c            |  20 ++
 arch/s390/net/bpf_jit_comp.c                 |  24 ++
 arch/sparc/net/bpf_jit_comp_64.c             |  34 +++
 arch/x86/net/bpf_jit_comp.c                  |  26 ++
 drivers/net/ethernet/netronome/nfp/bpf/jit.c |  24 ++
 include/uapi/linux/bpf.h                     |   5 +
 kernel/bpf/core.c                            |  60 +++++
 kernel/bpf/verifier.c                        |  62 ++++-
 lib/test_bpf.c                               | 364 +++++++++++++++++++++++++++
 net/core/filter.c                            |  21 +-
 tools/include/uapi/linux/bpf.h               |   5 +
 tools/testing/selftests/bpf/test_verifier.c  | 313 +++++++++++++++++++++++
 16 files changed, 979 insertions(+), 8 deletions(-)

-- 
1.9.3
