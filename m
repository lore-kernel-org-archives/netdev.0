From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/6] BPF cleanups and misc updates
Date: Sat, 26 Nov 2016 01:28:03 +0100
Message-ID: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42840 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds couple of cleanups in first few patches,
exposes owner_prog_type for array maps as well as mlocked mem
for maps in fdinfo, allows for mount permissions in fs and
fixes various outstanding issues in selftests and samples.

Thanks!

Daniel Borkmann (6):
  bpf: drop unnecessary context cast from BPF_PROG_RUN
  bpf: drop useless bpf_fd member from cls/act
  bpf: reuse dev_is_mac_header_xmit for redirect
  bpf: add owner_prog_type and accounted mem to array map's fdinfo
  bpf: allow for mount options to specify permissions
  bpf: fix multiple issues in selftest suite and samples

 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  2 +-
 include/linux/filter.h                             |  6 +--
 include/linux/if_arp.h                             | 16 +++++++
 kernel/bpf/inode.c                                 | 54 +++++++++++++++++++++-
 kernel/bpf/syscall.c                               | 17 ++++++-
 kernel/events/core.c                               |  2 +-
 kernel/seccomp.c                                   |  2 +-
 net/core/filter.c                                  | 14 ++----
 net/sched/act_bpf.c                                |  7 ---
 net/sched/act_mirred.c                             | 15 +-----
 net/sched/cls_bpf.c                                |  9 +---
 samples/bpf/Makefile                               |  1 +
 samples/bpf/test_lru_dist.c                        |  5 +-
 samples/bpf/tracex2_user.c                         |  4 +-
 samples/bpf/tracex3_user.c                         |  6 ++-
 samples/bpf/xdp1_user.c                            |  4 +-
 tools/testing/selftests/bpf/bpf_util.h             | 38 +++++++++++++++
 tools/testing/selftests/bpf/test_lru_map.c         |  8 +++-
 tools/testing/selftests/bpf/test_maps.c            |  7 +--
 tools/testing/selftests/bpf/test_verifier.c        |  2 +-
 20 files changed, 160 insertions(+), 59 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/bpf_util.h

-- 
1.9.3
