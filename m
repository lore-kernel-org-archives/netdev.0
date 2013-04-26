From: Xi Wang <xi.wang@gmail.com>
Subject: [RFC PATCH net-next 0/6] seccomp filter JIT
Date: Fri, 26 Apr 2013 03:51:40 -0400
Message-ID: <1366962706-24204-1-git-send-email-xi.wang@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xi Wang <xi.wang@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Eric Dumazet <edumazet@google.com>,
	Will Drewry <wad@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset brings JIT support to seccomp filters for x86_64 and ARM.
It is against the net-next tree.

The current BPF JIT interface only accepts sk_filter, not seccomp_filter.
Patch 1/6 refactors the interface to make it more general.

With the refactored interface, patches 2/6 and 3/6 implement the seccomp
BPF_S_ANC_SECCOMP_LD_W instruction in x86 & ARM JIT.

Status:

* x86_64 & ARM: JIT tested with seccomp examples.

* powerpc [4/6]: no seccomp change - compile checked.

* sparc [5/6] & s390 [6/6]: no seccomp change - untested.

Sorry I have no sparc or s390 build environment here.  Can someone help
check 5/6 and 6/6?  Thanks.

Xi Wang (6):
  filter: refactor BPF JIT for seccomp filters
  x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W instruction
  ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W instruction
  PPC: net: bpf_jit_comp: refactor the BPF JIT interface
  sparc: bpf_jit_comp: refactor the BPF JIT interface
  s390/bpf,jit: refactor the BPF JIT interface

 arch/arm/net/bpf_jit_32.c       | 64 +++++++++++++++++++++++++----------------
 arch/powerpc/net/bpf_jit_comp.c | 36 +++++++++++------------
 arch/s390/net/bpf_jit_comp.c    | 31 ++++++++++----------
 arch/sparc/net/bpf_jit_comp.c   | 22 +++++++-------
 arch/x86/net/bpf_jit_comp.c     | 38 ++++++++++++++++--------
 include/linux/filter.h          | 16 +++++++----
 kernel/seccomp.c                |  6 +++-
 net/core/filter.c               |  6 ++--
 8 files changed, 127 insertions(+), 92 deletions(-)

-- 
1.8.1.2
