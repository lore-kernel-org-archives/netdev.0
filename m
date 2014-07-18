From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 00/14] arm64: eBPF JIT compiler
Date: Fri, 18 Jul 2014 11:28:06 -0700
Message-ID: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series implements eBPF JIT compiler for arm64.
Please see [14/14] for change log.

Patches [1-13/14] implement code generation functions.
Patch [14/14] implements the actual eBPF JIT compiler.

Many thanks to everyone who's reviewed the code from
RFCv1->RFCv3, especially Alexei for BPF bits, and Will
for ARM64 codegen bits :)

BTW, I'm happy to maintain arch/arm64/net (i.e. arm64 BPF bits).
Should I add a patch updating MAINTAINERS as Patch 15?

This series requires a patch that exports a function
from net/core (resulting from RFCv1 discussion). This patch
has been merged into net-next @ 9f12fbe603f7
("net: filter: move load_pointer() into filter.h").

This series applies against net-next and is tested working
with lib/test_bpf on ARMv8 Foundation Model.

-----
The following changes since commit da388973d4a15e71cada1219d625b5393c90e5ae:

  iw_cxgb4: fix for 64-bit integer division (2014-07-17 16:52:08 -0700)

are available in the git repository at:

  https://github.com/zlim/linux.git arm64/bpf

for you to fetch changes up to eef34dcb8bb9a3712091e0cdea4a1c3a6e42912a:

  arm64: eBPF JIT compiler (2014-07-18 11:06:28 -0700)

----------------------------------------------------------------
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

 Documentation/networking/filter.txt |   2 +-
 arch/arm64/Kconfig                  |   1 +
 arch/arm64/Makefile                 |   1 +
 arch/arm64/include/asm/insn.h       | 249 +++++++++++++
 arch/arm64/kernel/insn.c            | 646 +++++++++++++++++++++++++++++++++-
 arch/arm64/net/Makefile             |   4 +
 arch/arm64/net/bpf_jit.h            | 169 +++++++++
 arch/arm64/net/bpf_jit_comp.c       | 677 ++++++++++++++++++++++++++++++++++++
 8 files changed, 1741 insertions(+), 8 deletions(-)
 create mode 100644 arch/arm64/net/Makefile
 create mode 100644 arch/arm64/net/bpf_jit.h
 create mode 100644 arch/arm64/net/bpf_jit_comp.c

-- 
1.9.1
