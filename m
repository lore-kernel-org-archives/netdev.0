From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/2] bpf: add search pruning optimization and tests
Date: Mon, 29 Sep 2014 18:50:00 -0700
Message-ID: <1412041802-24858-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

patch #1 commit log explains why eBPF verifier has to examine some
instructions multiple times and describes the search pruning optimization
that improves verification speed for branchy programs and allows more
complex programs to be verified successfully.
This patch completes the core verifier logic.

patch #2 adds more verifier tests related to branches and search pruning

I'm still working on Andy's 'bitmask for stack slots' suggestion. It will be
done on top of this patch.

The current verifier algorithm is brute force depth first search with
state pruning. If anyone can come up with another algorithm that demonstrates
better results, we'll replace the algorithm without affecting user space.

Note verifier doesn't guarantee that all possible valid programs are accepted.
Overly complex programs may still be rejected.
Verifier improvements/optimizations will guarantee that if a program
was passing verification in the past, it will still be passing.

Alexei Starovoitov (2):
  bpf: add search pruning optimization to verifier
  bpf: add tests to verifier testsuite

 kernel/bpf/verifier.c       |  146 +++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/test_verifier.c |  130 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 276 insertions(+)

-- 
1.7.9.5
