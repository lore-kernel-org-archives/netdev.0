From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 0/3] bpf_perf_event_output helper
Date: Tue, 20 Oct 2015 20:02:32 -0700
Message-ID: <1445396556-4854-1-git-send-email-ast@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Over the last year there were multiple attempts to let eBPF programs
output data into perf events by He Kuang and Wangnan.
The last one was:
https://lkml.org/lkml/2015/7/20/736
It was almost perfect with exception that all bpf programs would sent
data into one global perf_event.
This patch set takes different approach by letting user space
open independent PERF_COUNT_SW_BPF_OUTPUT events, so that program
output won't collide.

Wangnan is working on corresponding perf patches.

Alexei Starovoitov (3):
  perf: pad raw data samples automatically
  bpf: introduce bpf_perf_event_output() helper
  samples: bpf: add bpf_perf_event_output example

 include/uapi/linux/bpf.h        |   11 +++
 include/uapi/linux/perf_event.h |    1 +
 kernel/bpf/arraymap.c           |    2 +
 kernel/bpf/verifier.c           |    3 +-
 kernel/events/core.c            |   15 ++-
 kernel/trace/bpf_trace.c        |   46 +++++++++
 samples/bpf/Makefile            |    7 ++
 samples/bpf/bpf_helpers.h       |    2 +
 samples/bpf/trace_output_kern.c |   31 +++++++
 samples/bpf/trace_output_user.c |  196 +++++++++++++++++++++++++++++++++++++++
 10 files changed, 308 insertions(+), 6 deletions(-)
 create mode 100644 samples/bpf/trace_output_kern.c
 create mode 100644 samples/bpf/trace_output_user.c

-- 
1.7.9.5
