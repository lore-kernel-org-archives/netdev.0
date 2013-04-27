From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v2 net-next 0/3] seccomp filter JIT
Date: Fri, 26 Apr 2013 22:17:24 -0400
Message-ID: <1367029047-14830-1-git-send-email-xi.wang@gmail.com>
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Will Drewry <wad@chromium.org>,
	Eric Dumazet <edumazet@google.com>,
	Russell King <linux@arm.linux.org.uk>,
	David Laight <david.laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Xi Wang <xi.wang@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch refactors bpf_jit_compile()/bpf_jit_free() to provide
a unified interface for both packet and seccomp filters.

The next two patches implement JIT for seccomp filters on x86 and ARM,
respectively.

Thanks to Heiko Carstens for testing the build on s390 and Eric Dumazet
for the comments on x86 JIT.

Changes:
  make better patch splitting
  remove arch at jit time in x86
  add more comments in x86

Xi Wang (3):
  filter: refactor BPF JIT for seccomp filters
  x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W instruction
  ARM: net: bpf_jit_32: support BPF_S_ANC_SECCOMP_LD_W instruction

 arch/arm/net/bpf_jit_32.c       | 64 +++++++++++++++++++++++++----------------
 arch/powerpc/net/bpf_jit_comp.c | 36 +++++++++++------------
 arch/s390/net/bpf_jit_comp.c    | 31 ++++++++++----------
 arch/sparc/net/bpf_jit_comp.c   | 22 +++++++-------
 arch/x86/net/bpf_jit_comp.c     | 32 ++++++++++++++-------
 include/linux/filter.h          | 16 +++++++----
 kernel/seccomp.c                |  6 +++-
 net/core/filter.c               |  6 ++--
 8 files changed, 122 insertions(+), 91 deletions(-)

-- 
1.8.1.2
