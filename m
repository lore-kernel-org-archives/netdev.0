From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 00/17] Misc MIPS/BPF fixes for 3.16
Date: Mon, 23 Jun 2014 10:38:43 +0100
Message-ID: <1403516340-22997-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Alexei Starovoitov" <ast@plumgrid.com>, <netdev@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:3128 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaFWJjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 05:39:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here are some fixes for MIPS/BPF for 3.16. These fixes make
the bpf testsuite *almost* happy with only 2 tests (LD_IND_LL,
LD_IND_NET) failing at the moment. Since fixing the remaining tests
is not so trivial, it would be nice to have these fixes in 3.16 for now.

The patches are based on the upstream-sfr/mips-for-linux-next tree
because they depend on https://patchwork.linux-mips.org/patch/7099/

Markos Chandras (17):
  MIPS: uasm: Add s3s1s2 instruction builder
  MIPS: uasm: Add slt uasm instruction
  MIPS: mm: uasm: Fix lh micro-assembler instruction
  MIPS: bpf: Use the LO register to get division's quotient
  MIPS: bpf: Return error code if the offset is a negative number
  MIPS: bpf: Use 'andi' instead of 'and' for the VLAN cases
  MIPS: bpf: Add SEEN_SKB to flags when looking for the PKT_TYPE
  MIPS: bpf: Fix branch conditional for BPF_J{GT/GE} cases
  MIPS: bpf: Use correct mask for VLAN_TAG case
  MIPS: bpf: Fix return values for VLAN_TAG_PRESENT case
  MIPS: bpf: Use pr_debug instead of pr_warn for unhandled opcodes
  MIPS: bpf: Fix is_range() semantics
  MIPS: bpf: Drop update_on_xread and always initialize the X register
  MIPS: bpf: Prevent kernel fall over for >=32bit shifts
  MIPS: bpf: Fix PKT_TYPE case for big-endian cores
  MIPS: bpf: Use 32 or 64-bit load instruction to load an address to
    register
  MIPS: bpf: Fix stack space allocation for BPF memwords on MIPS64

 arch/mips/include/asm/uasm.h      |   4 ++
 arch/mips/include/uapi/asm/inst.h |   1 +
 arch/mips/mm/uasm-micromips.c     |   1 +
 arch/mips/mm/uasm-mips.c          |   3 +-
 arch/mips/mm/uasm.c               |  10 +++-
 arch/mips/net/bpf_jit.c           | 115 ++++++++++++++++++++++++--------------
 6 files changed, 90 insertions(+), 44 deletions(-)

-- 
2.0.0
