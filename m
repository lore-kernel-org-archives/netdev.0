From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v4 net-next 0/3] bpf: Add BPF support to all perf_event
Date: Fri, 2 Jun 2017 21:03:51 -0700
Message-ID: <20170603040354.3580555-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v3->v4: one more tweak to reject unsupported events at map
update time as Peter suggested

v2->v3: more refactoring to address Peter's feedback.
Now all perf_events are attachable and readable

v1->v2: address Peter's feedback. Refactor patch 1 to allow attaching
bpf programs to all event types and reading counters from all of them as well
patch 2 - more tests
patch 3 - address Dave's feedback and document bpf_perf_event_read()
and bpf_perf_event_output() properly

Alexei Starovoitov (1):
  perf, bpf: Add BPF support to all perf_event types

Teng Qin (2):
  samples/bpf: add tests for more perf event types
  bpf: update perf event helper functions documentation

 include/linux/perf_event.h     |   7 +-
 include/uapi/linux/bpf.h       |  11 ++-
 kernel/bpf/arraymap.c          |  28 ++-----
 kernel/events/core.c           |  47 ++++++-----
 kernel/trace/bpf_trace.c       |  21 ++---
 samples/bpf/bpf_helpers.h      |   3 +-
 samples/bpf/trace_event_user.c |  73 ++++++++++++++---
 samples/bpf/tracex6_kern.c     |  28 +++++--
 samples/bpf/tracex6_user.c     | 180 ++++++++++++++++++++++++++++++++---------
 tools/include/uapi/linux/bpf.h |  11 ++-
 10 files changed, 290 insertions(+), 119 deletions(-)

-- 
2.9.3
