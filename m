From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 0/6] BPF metadata for direct access
Date: Mon, 25 Sep 2017 02:25:49 +0200
Message-ID: <cover.1506297988.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
        peter.waskiewicz.jr@intel.com, jakub.kicinski@netronome.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37211 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932966AbdIYA1G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 20:27:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work enables generic transfer of metadata from XDP into skb,
meaning the packet has a flexible and programmable room for meta
data, which can later be used by BPF to set various skb members
when passing up the stack. For details, please see second patch.
Support has been implemented and tested with two drivers, and
should be straight forward to add to other drivers as well which
properly support head adjustment already.

Thanks!

Daniel Borkmann (6):
  bpf: rename bpf_compute_data_end into bpf_compute_data_pointers
  bpf: add meta pointer for direct access
  bpf: update bpf.h uapi header for tools
  bpf: improve selftests and add tests for meta pointer
  bpf, nfp: add meta data support
  bpf, ixgbe: add meta data support

 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c      |   1 +
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |   1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |  29 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   1 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  39 ++--
 drivers/net/ethernet/qlogic/qede/qede_fp.c         |   1 +
 drivers/net/tun.c                                  |   1 +
 drivers/net/virtio_net.c                           |   2 +
 include/linux/bpf.h                                |   1 +
 include/linux/filter.h                             |  30 ++-
 include/linux/skbuff.h                             |  68 +++++-
 include/uapi/linux/bpf.h                           |  13 +-
 kernel/bpf/sockmap.c                               |   4 +-
 kernel/bpf/verifier.c                              | 114 +++++++---
 net/bpf/test_run.c                                 |   3 +-
 net/core/dev.c                                     |  31 ++-
 net/core/filter.c                                  |  91 +++++++-
 net/core/lwt_bpf.c                                 |   2 +-
 net/core/skbuff.c                                  |   2 +
 net/sched/act_bpf.c                                |   4 +-
 net/sched/cls_bpf.c                                |   4 +-
 tools/include/uapi/linux/bpf.h                     |  45 ++--
 tools/testing/selftests/bpf/Makefile               |  21 +-
 tools/testing/selftests/bpf/bpf_helpers.h          |   2 +
 tools/testing/selftests/bpf/test_verifier.c        | 247 +++++++++++++++++++++
 tools/testing/selftests/bpf/test_xdp_meta.c        |  53 +++++
 tools/testing/selftests/bpf/test_xdp_meta.sh       |  51 +++++
 29 files changed, 759 insertions(+), 104 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_xdp_meta.c
 create mode 100755 tools/testing/selftests/bpf/test_xdp_meta.sh

-- 
1.9.3
