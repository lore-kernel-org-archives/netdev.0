From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv5 perf/core 0/5] Reuse libbpf from samples/bpf
Date: Fri, 16 Dec 2016 10:32:54 -0800
Message-ID: <20161216183259.14840-1-joe@ovn.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        wangnan0@huawei.com, ast@fb.com, daniel@iogearbox.net
To: acme@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update tools/lib/bpf to provide the remaining bpf wrapper pieces needed by the
samples/bpf/ code, then get rid of all of the duplicate BPF libraries in
samples/bpf/libbpf.[ch].

---
v5: Fixed prog_size vs. instruction count API difference in bpf_load_program()

REBASE: Rebased v3 that was applied to perf/core.
        Resolved merge conflict with net-next.
        New patch shifts bpf_prog_{attach,detach}() to libbpf.
        Drop unnecessary build targets
        Drop extra unneeded log buffers

v3: Add ack for first patch.
    Split out second patch from v2 into separate changes for remaining diff.
    Add patches to switch samples/bpf over to using tools/lib/.

(Was "libbpf: Synchronize implementations")
v2: Don't shift non-bpf code into libbpf.
    Drop the patch to synchronize ELF definitions with tc.

v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
    First post.

Joe Stringer (5):
  samples/bpf: Make samples more libbpf-centric
  samples/bpf: Switch over to libbpf
  tools lib bpf: Add bpf_prog_{attach,detach}
  samples/bpf: Remove perf_event_open() declaration
  samples/bpf: Move open_raw_sock to separate header

 samples/bpf/Makefile                              |  70 +++++----
 samples/bpf/README.rst                            |   4 +-
 samples/bpf/bpf_load.c                            |  21 ++-
 samples/bpf/bpf_load.h                            |   3 +
 samples/bpf/fds_example.c                         |  11 +-
 samples/bpf/lathist_user.c                        |   2 +-
 samples/bpf/libbpf.c                              | 176 ----------------------
 samples/bpf/libbpf.h                              |  28 +---
 samples/bpf/lwt_len_hist_user.c                   |   6 +-
 samples/bpf/offwaketime_user.c                    |   8 +-
 samples/bpf/sampleip_user.c                       |   7 +-
 samples/bpf/sock_example.c                        |  14 +-
 samples/bpf/sock_example.h                        |  35 +++++
 samples/bpf/sockex1_user.c                        |   7 +-
 samples/bpf/sockex2_user.c                        |   5 +-
 samples/bpf/sockex3_user.c                        |   5 +-
 samples/bpf/spintest_user.c                       |   8 +-
 samples/bpf/tc_l2_redirect_user.c                 |   4 +-
 samples/bpf/test_cgrp2_array_pin.c                |   4 +-
 samples/bpf/test_cgrp2_attach.c                   |  12 +-
 samples/bpf/test_cgrp2_attach2.c                  |   8 +-
 samples/bpf/test_cgrp2_sock.c                     |   7 +-
 samples/bpf/test_current_task_under_cgroup_user.c |   8 +-
 samples/bpf/test_lru_dist.c                       |  32 ++--
 samples/bpf/test_probe_write_user_user.c          |   2 +-
 samples/bpf/trace_event_user.c                    |  23 +--
 samples/bpf/trace_output_user.c                   |   5 +-
 samples/bpf/tracex2_user.c                        |  10 +-
 samples/bpf/tracex3_user.c                        |   4 +-
 samples/bpf/tracex4_user.c                        |   4 +-
 samples/bpf/tracex6_user.c                        |   5 +-
 samples/bpf/xdp1_user.c                           |   2 +-
 samples/bpf/xdp_tx_iptunnel_user.c                |   6 +-
 tools/lib/bpf/bpf.c                               |  21 +++
 tools/lib/bpf/bpf.h                               |   3 +
 35 files changed, 238 insertions(+), 332 deletions(-)
 delete mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/sock_example.h

-- 
2.10.2
