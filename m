From: Joe Stringer <joe@ovn.org>
Subject: [PATCHv3 perf/core 0/7] Reuse libbpf from samples/bpf
Date: Thu,  8 Dec 2016 18:46:13 -0800
Message-ID: <20161209024620.31660-1-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Was "libbpf: Synchronize implementations")

Update tools/lib/bpf to provide the remaining bpf wrapper pieces needed by the
samples/bpf/ code, then get rid of all of the duplicate BPF libraries in
samples/bpf/libbpf.[ch].

---
v3: Add ack for first patch.
    Split out second patch from v2 into separate changes for remaining diff.
    Add patches to switch samples/bpf over to using tools/lib/.
v2: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
    Don't shift non-bpf code into libbpf.
    Drop the patch to synchronize ELF definitions with tc.
v1: https://www.mail-archive.com/netdev@vger.kernel.org/msg135088.html
    First post.

Joe Stringer (7):
  tools lib bpf: Sync {tools,}/include/uapi/linux/bpf.h
  tools lib bpf: use __u32 from linux/types.h
  tools lib bpf: Add flags to bpf_create_map()
  samples/bpf: Make samples more libbpf-centric
  samples/bpf: Switch over to libbpf
  samples/bpf: Remove perf_event_open() declaration
  samples/bpf: Move open_raw_sock to separate header

 samples/bpf/Makefile                              |  61 +++++----
 samples/bpf/README.rst                            |   4 +-
 samples/bpf/bpf_load.c                            |  20 ++-
 samples/bpf/fds_example.c                         |  10 +-
 samples/bpf/lathist_user.c                        |   3 +-
 samples/bpf/libbpf.c                              | 155 ----------------------
 samples/bpf/libbpf.h                              |  25 +---
 samples/bpf/map_perf_test_user.c                  |   1 +
 samples/bpf/offwaketime_user.c                    |  10 +-
 samples/bpf/sampleip_user.c                       |   8 +-
 samples/bpf/sock_example.c                        |  11 +-
 samples/bpf/sock_example.h                        |  35 +++++
 samples/bpf/sockex1_user.c                        |   9 +-
 samples/bpf/sockex2_user.c                        |   7 +-
 samples/bpf/sockex3_user.c                        |   7 +-
 samples/bpf/spintest_user.c                       |  10 +-
 samples/bpf/tc_l2_redirect_user.c                 |   4 +-
 samples/bpf/test_cgrp2_array_pin.c                |   4 +-
 samples/bpf/test_current_task_under_cgroup_user.c |  10 +-
 samples/bpf/test_maps.c                           | 142 ++++++++++----------
 samples/bpf/test_overhead_user.c                  |   2 +
 samples/bpf/test_probe_write_user_user.c          |   4 +-
 samples/bpf/test_verifier.c                       |   8 +-
 samples/bpf/trace_event_user.c                    |  24 ++--
 samples/bpf/trace_output_user.c                   |   6 +-
 samples/bpf/tracex1_user.c                        |   2 +
 samples/bpf/tracex2_user.c                        |  12 +-
 samples/bpf/tracex3_user.c                        |   6 +-
 samples/bpf/tracex4_user.c                        |   6 +-
 samples/bpf/tracex5_user.c                        |   2 +
 samples/bpf/tracex6_user.c                        |   7 +-
 samples/bpf/xdp1_user.c                           |   4 +-
 tools/include/uapi/linux/bpf.h                    |  51 +++++++
 tools/lib/bpf/Makefile                            |   2 +
 tools/lib/bpf/bpf.c                               |   7 +-
 tools/lib/bpf/bpf.h                               |   6 +-
 tools/lib/bpf/libbpf.c                            |   3 +-
 37 files changed, 332 insertions(+), 356 deletions(-)
 delete mode 100644 samples/bpf/libbpf.c
 create mode 100644 samples/bpf/sock_example.h

-- 
2.10.2
