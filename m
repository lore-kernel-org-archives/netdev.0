From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 0/6] perf, bpf: add support for bpf in sw/hw perf_events
Date: Wed, 31 Aug 2016 14:50:37 -0700
Message-ID: <1472680243-1326608-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Peter, Dave,

this patch set is a follow up to the discussion:
https://lkml.kernel.org/r/20160804142853.GO6862%20()%20twins%20!%20programming%20!%20kicks-ass%20!%20net
It turned out to be simpler than what we discussed.

Patches 1-3 is bpf-side prep for the main patch 4
that adds bpf program as an overflow_handler to sw and hw perf_events.
Peter, please review.

Patches 5 and 6 are examples from myself and Brendan.

v1-v2: fixed issues spotted by Peter and Daniel.

Thanks!

Alexei Starovoitov (5):
  bpf: support 8-byte metafield access
  bpf: introduce BPF_PROG_TYPE_PERF_EVENT program type
  bpf: perf_event progs should only use preallocated maps
  perf, bpf: add perf events core support for BPF_PROG_TYPE_PERF_EVENT
    programs
  samples/bpf: add perf_event+bpf example

Brendan Gregg (1):
  samples/bpf: add sampleip example

 include/linux/bpf.h                 |   4 +
 include/linux/perf_event.h          |   7 ++
 include/uapi/linux/Kbuild           |   1 +
 include/uapi/linux/bpf.h            |   1 +
 include/uapi/linux/bpf_perf_event.h |  18 +++
 kernel/bpf/verifier.c               |  31 +++++-
 kernel/events/core.c                |  85 +++++++++++++-
 kernel/trace/bpf_trace.c            |  60 ++++++++++
 samples/bpf/Makefile                |   8 ++
 samples/bpf/bpf_helpers.h           |   2 +
 samples/bpf/bpf_load.c              |   7 +-
 samples/bpf/sampleip_kern.c         |  38 +++++++
 samples/bpf/sampleip_user.c         | 196 +++++++++++++++++++++++++++++++++
 samples/bpf/trace_event_kern.c      |  65 +++++++++++
 samples/bpf/trace_event_user.c      | 213 ++++++++++++++++++++++++++++++++++++
 15 files changed, 730 insertions(+), 6 deletions(-)
 create mode 100644 include/uapi/linux/bpf_perf_event.h
 create mode 100644 samples/bpf/sampleip_kern.c
 create mode 100644 samples/bpf/sampleip_user.c
 create mode 100644 samples/bpf/trace_event_kern.c
 create mode 100644 samples/bpf/trace_event_user.c

-- 
2.8.0
