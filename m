From: David Daney <david.daney@cavium.com>
Subject: [PATCH 0/3] MIPS,bpf: Improvements for MIPS eBPF JIT
Date: Fri, 18 Aug 2017 16:40:30 -0700
Message-ID: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are several improvements and bug fixes for the MIPS eBPF JIT.

The main change is the addition of support for JLT, JLE, JSLT and JSLE
ops, that were recently added.

Also fix WARN output when used with preemptable kernel, and a small
cleanup/optimization in the use of BPF_OP(insn->code).

I suggest that the whole thing go via the BPF/net-next path as there
are dependencies on code that is not yet merged to Linus' tree.

Still pending are changes to reduce stack usage when the verifier can
determine the maximum stack size.

David Daney (3):
  MIPS,bpf: Fix using smp_processor_id() in preemptible splat.
  MIPS,bpf: Implement JLT, JLE, JSLT and JSLE ops in the eBPF JIT.
  MIPS,bpf: Cache value of BPF_OP(insn->code) in eBPF JIT.

 arch/mips/net/ebpf_jit.c | 162 ++++++++++++++++++++++++++++++-----------------
 1 file changed, 103 insertions(+), 59 deletions(-)

-- 
2.9.5
