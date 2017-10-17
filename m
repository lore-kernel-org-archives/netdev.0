From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 0/3] Fix for BPF devmap percpu allocation splat
Date: Tue, 17 Oct 2017 16:55:51 +0200
Message-ID: <cover.1508251210.git.daniel@iogearbox.net>
Cc: tj@kernel.org, ast@kernel.org, john.fastabend@gmail.com,
        mark.rutland@arm.com, richard@nod.at, sp3485@columbia.edu,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The set fixes a splat in devmap percpu allocation when we alloc
the flush bitmap. Patch 1 is a prerequisite for the fix in patch 2,
patch 1 is rather small, so if this could be routed via -net, for
example, with Tejun's Ack that would be good. Patch 3 gets rid of
remaining PCPU_MIN_UNIT_SIZE checks, which are percpu allocator
internals and should not be used.

Thanks!

Daniel Borkmann (3):
  mm, percpu: add support for __GFP_NOWARN flag
  bpf: fix splat for illegal devmap percpu allocation
  bpf: do not test for PCPU_MIN_UNIT_SIZE before percpu allocations

 kernel/bpf/arraymap.c |  2 +-
 kernel/bpf/devmap.c   |  5 +++--
 kernel/bpf/hashtab.c  |  4 ----
 mm/percpu.c           | 15 ++++++++++-----
 4 files changed, 14 insertions(+), 12 deletions(-)

-- 
1.9.3
