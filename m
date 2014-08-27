From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCHv2 00/14] arm64: eBPF JIT compiler
Date: Tue, 26 Aug 2014 21:15:16 -0700
Message-ID: <1409112930-25677-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Chema Gonzalez <chema@google.com>,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Will, Catalin,

This is a respin of series implementing eBPF JIT compiler for arm64,
on top of 3.17-rc2. The v1 series [1] missed the previous merge window.

Patches [1-13/14] implement code generation functions. Unchanged from v1.

Patch [14/14] implements the actual eBPF JIT compiler. Updated from v1:
straightforward fixups due to changes from net.
Please see [14/14] for detailed change log.

This series is applies cleanly against 3.17-rc2 and is tested working
with lib/test_bpf on ARMv8 Foundation Model.

Will had previously reported that v1 series works on Juno platform.
Since v2 only involves straightforward renaming in [14/14], I don't
anticipate any regressions.

Thanks,
z

[1] https://lkml.org/lkml/2014/7/18/683

--------
The following changes since commit 52addcf9d6669fa439387610bc65c92fa0980cef:

  Linux 3.17-rc2 (2014-08-25 15:36:20 -0700)

are available in the git repository at:

  https://github.com/zlim/linux.git tags/arm64/bpf-v2

for you to fetch changes up to 2f4a4b8df4ba1cbd24957fb1a8371d30b1976174:

  arm64: eBPF JIT compiler (2014-08-26 19:04:43 -0700)

----------------------------------------------------------------
 Documentation/networking/filter.txt |   6 +-
 arch/arm64/Kconfig                  |   1 +
 arch/arm64/Makefile                 |   1 +
 arch/arm64/include/asm/insn.h       | 249 +++++++++++++
 arch/arm64/kernel/insn.c            | 646 +++++++++++++++++++++++++++++++++-
 arch/arm64/net/Makefile             |   4 +
 arch/arm64/net/bpf_jit.h            | 169 +++++++++
 arch/arm64/net/bpf_jit_comp.c       | 677 ++++++++++++++++++++++++++++++++++++
 8 files changed, 1743 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm64/net/Makefile
 create mode 100644 arch/arm64/net/bpf_jit.h
 create mode 100644 arch/arm64/net/bpf_jit_comp.c

Zi Shen Lim (14):
  arm64: introduce aarch64_insn_gen_comp_branch_imm()
  arm64: introduce aarch64_insn_gen_branch_reg()
  arm64: introduce aarch64_insn_gen_cond_branch_imm()
  arm64: introduce aarch64_insn_gen_load_store_reg()
  arm64: introduce aarch64_insn_gen_load_store_pair()
  arm64: introduce aarch64_insn_gen_add_sub_imm()
  arm64: introduce aarch64_insn_gen_bitfield()
  arm64: introduce aarch64_insn_gen_movewide()
  arm64: introduce aarch64_insn_gen_add_sub_shifted_reg()
  arm64: introduce aarch64_insn_gen_data1()
  arm64: introduce aarch64_insn_gen_data2()
  arm64: introduce aarch64_insn_gen_data3()
  arm64: introduce aarch64_insn_gen_logical_shifted_reg()
  arm64: eBPF JIT compiler

 Documentation/networking/filter.txt |   6 +-
 arch/arm64/Kconfig                  |   1 +
 arch/arm64/Makefile                 |   1 +
 arch/arm64/include/asm/insn.h       | 249 +++++++++++++
 arch/arm64/kernel/insn.c            | 646 +++++++++++++++++++++++++++++++++-
 arch/arm64/net/Makefile             |   4 +
 arch/arm64/net/bpf_jit.h            | 169 +++++++++
 arch/arm64/net/bpf_jit_comp.c       | 677 ++++++++++++++++++++++++++++++++++++
 8 files changed, 1743 insertions(+), 10 deletions(-)
 create mode 100644 arch/arm64/net/Makefile
 create mode 100644 arch/arm64/net/bpf_jit.h
 create mode 100644 arch/arm64/net/bpf_jit_comp.c

-- 
1.9.1
