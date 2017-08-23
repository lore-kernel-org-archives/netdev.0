From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v2 net-next 0/5] bpf: verifier fixes
Date: Wed, 23 Aug 2017 15:07:20 +0100
Message-ID: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Fix a couple of bugs introduced in my recent verifier patches.
Patch #2 does slightly increase the insn count on bpf_lxc.o, but only by
 about a hundred insns (i.e. 0.2%).

v2: added test for write-marks bug (patch #1); reworded comment on
 propagate_liveness() for clarity.

Alexei Starovoitov (1):
  selftests/bpf: add a test for a pruning bug in the verifier

Edward Cree (4):
  selftests/bpf: add a test for a bug in liveness-based pruning
  bpf/verifier: when pruning a branch, ignore its write marks
  bpf/verifier: remove varlen_map_value_access flag
  bpf/verifier: document liveness analysis

 include/linux/bpf_verifier.h                | 14 +++++-
 kernel/bpf/verifier.c                       | 78 +++++++++++++++++------------
 tools/testing/selftests/bpf/test_verifier.c | 44 ++++++++++++++++
 3 files changed, 103 insertions(+), 33 deletions(-)
