From: Markos Chandras <markos.chandras@imgtec.com>
Subject: [PATCH 0/6] MIPS/BPF fixes for 4.3
Date: Thu, 4 Jun 2015 11:56:10 +0100
Message-ID: <1433415376-20952-1-git-send-email-markos.chandras@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
	<netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Hannes Frederic Sowa" <hannes@stressinduktion.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailapp01.imgtec.com ([195.59.15.196]:47743 "EHLO
	mailapp01.imgtec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbFDK41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 06:56:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Here are some fixes for MIPS/BPF. The first 5 patches do some cleanup
and lay the groundwork for the final one which introduces assembly helpers
for MIPS and MIPS64. The goal is to speed up certain operations that do
not need to go through the common C functions. This also makes the test_bpf
testsuite happy with all 60 tests passing. This is based in 4.1-rc6.

The patchset is also available in my git tree.

https://github.com/hwoarang/linux/tree/4.3-bpf

The last patch also contains performance results along with the relevant
scripts and data used for the analysis.

Markos Chandras (6):
  MIPS: net: BPF: Free up some callee-saved registers
  MIPS: net: BPF: Replace RSIZE with SZREG
  MIPS: net: BPF: Fix stack pointer allocation
  MIPS: net: BPF: Move register definition to the BPF header
  MIPS: net: BPF: Use BPF register names to describe the ABI
  MIPS: net: BPF: Introduce BPF ASM helpers

 arch/mips/net/Makefile      |   2 +-
 arch/mips/net/bpf_jit.c     | 268 ++++++++++++--------------------------------
 arch/mips/net/bpf_jit.h     |  42 ++++++-
 arch/mips/net/bpf_jit_asm.S | 238 +++++++++++++++++++++++++++++++++++++++
 4 files changed, 350 insertions(+), 200 deletions(-)
 create mode 100644 arch/mips/net/bpf_jit_asm.S

-- 
2.4.2
