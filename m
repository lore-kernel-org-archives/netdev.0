From: David Daney <david.daney@cavium.com>
Subject: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 14:21:39 -0700
Message-ID: <20170314212144.29988-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>,
        David Daney <david.daney@cavium.com>
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes from v1:

  - Use unsigned access for SKF_AD_HATYPE

  - Added three more patches for other problems found.


Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
identified some failures and unimplemented features.

With this patch set we get:

     test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]

Both big and little endian tested.

We still lack eBPF support, but this is better than nothing.

David Daney (5):
  MIPS: uasm:  Add support for LHU.
  MIPS: BPF: Add JIT support for SKF_AD_HATYPE.
  MIPS: BPF: Use unsigned access for unsigned SKB fields.
  MIPS: BPF: Quit clobbering callee saved registers in JIT code.
  MIPS: BPF: Fix multiple problems in JIT skb access helpers.

 arch/mips/include/asm/uasm.h |  1 +
 arch/mips/mm/uasm-mips.c     |  1 +
 arch/mips/mm/uasm.c          |  3 ++-
 arch/mips/net/bpf_jit.c      | 41 +++++++++++++++++++++++++++++++----------
 arch/mips/net/bpf_jit_asm.S  | 23 ++++++++++++-----------
 5 files changed, 47 insertions(+), 22 deletions(-)

-- 
2.9.3
