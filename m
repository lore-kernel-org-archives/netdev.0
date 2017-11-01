From: Roman Gushchin <guro@fb.com>
Subject: [PATCH net-next 0/4] eBPF-based device cgroup controller
Date: Wed, 1 Nov 2017 11:20:33 -0400
Message-ID: <20171101152037.3288-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, Roman Gushchin <guro@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset introduces an eBPF-based device controller for cgroup v2.

Patch (1) is a preparational work required to share some code with
  the existing device controller implementation.
Patch (2) is the main patch, which introduces a new bpf prog type
  and all necessary infrastructure.
Patch (3) moves cgroup_helpers.c/h to use them by patch (4).
Patch (4) implements an example of eBPF program which controls access
  to device files and corresponding userspace test.

Roman Gushchin (4):
  device_cgroup: prepare code for bpf-based device controller
  bpf, cgroup: implement eBPF-based device controller for cgroup v2
  bpf: move cgroup_helpers from samples/bpf/ to
    tools/testing/selftesting/bpf/
  selftests/bpf: add a test for device cgroup controller

 include/linux/bpf-cgroup.h                         | 15 ++++
 include/linux/bpf_types.h                          |  3 +
 include/linux/device_cgroup.h                      | 67 +++++++++++++++-
 include/uapi/linux/bpf.h                           | 15 ++++
 kernel/bpf/cgroup.c                                | 67 ++++++++++++++++
 kernel/bpf/syscall.c                               |  7 ++
 kernel/bpf/verifier.c                              |  1 +
 samples/bpf/Makefile                               |  5 +-
 security/device_cgroup.c                           | 47 +----------
 tools/include/uapi/linux/bpf.h                     | 15 ++++
 tools/testing/selftests/bpf/Makefile               |  6 +-
 .../testing/selftests}/bpf/cgroup_helpers.c        |  0
 .../testing/selftests}/bpf/cgroup_helpers.h        |  0
 tools/testing/selftests/bpf/dev_cgroup.c           | 60 ++++++++++++++
 tools/testing/selftests/bpf/test_dev_cgroup.c      | 93 ++++++++++++++++++++++
 15 files changed, 347 insertions(+), 54 deletions(-)
 rename {samples => tools/testing/selftests}/bpf/cgroup_helpers.c (100%)
 rename {samples => tools/testing/selftests}/bpf/cgroup_helpers.h (100%)
 create mode 100644 tools/testing/selftests/bpf/dev_cgroup.c
 create mode 100644 tools/testing/selftests/bpf/test_dev_cgroup.c

-- 
2.13.6
