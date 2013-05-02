From: Xi Wang <xi.wang@gmail.com>
Subject: [PATCH v3 -next 0/2] seccomp filter JIT for x86
Date: Thu,  2 May 2013 18:28:55 -0400
Message-ID: <1367533737-17196-1-git-send-email-xi.wang@gmail.com>
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
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset is rebased against linux-next, on top of the seccomp JIT
interface from Nicolas Schichan:

  00afda30 "bpf: add comments explaining the schedule_work() operation"
  c2cf3192 "ARM: net: bpf_jit: add support for jitted seccomp filters."
  8ef6cd9d "ARM: net: bpf_jit: make code generation less dependent on
            struct sk_filter."
  747416f4 "seccomp: add generic code for jitted seccomp filters."

Patch 1/2 implements JIT by calling seccomp_bpf_load().  It introduces
SEEN_SKBREF, as suggested by Eric Dumazet, to make ensure that seccomp
filters don't use skb (%rdi).

Patch 2/2 eliminates the call to seccomp_bpf_load() and instead emits
instructions directly.  It doesn't have to emit prologue/epilogue either.

Both patches have been tested using vsftpd, openssh, and the seccomp
filter examples.

My main worry about 2/2 is that it's way harder to maintain compared
to 1/2.  I'm posting it here for completeness, but I'd suggest to consider
patch 1/2 only for now.

Xi Wang (2):
  x86: bpf_jit_comp: support BPF_S_ANC_SECCOMP_LD_W
  x86: bpf_jit_comp: optimize BPF_S_ANC_SECCOMP_LD_W

 arch/x86/Kconfig            |   1 +
 arch/x86/net/bpf_jit_comp.c | 220 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 198 insertions(+), 23 deletions(-)

-- 
1.8.1.2
