From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 0/3] BPF event output helper improvements
Date: Thu, 14 Jul 2016 18:08:02 +0200
Message-ID: <cover.1468511632.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set adds improvements to the BPF event output helper to
support non-linear data sampling, here specifically, for skb
context. For details please see individual patches. The set
is based against net-next tree.

v1 -> v2:
  - Integrated and adapted Peter's diff into patch 1, updated
    the remaining ones accordingly. Thanks Peter!

Thanks a lot!

Daniel Borkmann (3):
  perf, events: add non-linear data support for raw records
  bpf, perf: split bpf_perf_event_output
  bpf: avoid stack copy and use skb ctx for event output

 arch/s390/kernel/perf_cpum_sf.c |  9 ++++--
 arch/x86/events/amd/ibs.c       |  8 +++--
 include/linux/bpf.h             |  7 ++++-
 include/linux/perf_event.h      | 20 ++++++++++++-
 include/uapi/linux/bpf.h        |  2 ++
 kernel/bpf/core.c               |  6 ++--
 kernel/events/core.c            | 66 ++++++++++++++++++++++++++++-------------
 kernel/events/internal.h        | 16 +++++++---
 kernel/trace/bpf_trace.c        | 66 +++++++++++++++++++++++------------------
 net/core/filter.c               | 43 ++++++++++++++++++++++++++-
 10 files changed, 180 insertions(+), 63 deletions(-)

-- 
1.9.3
