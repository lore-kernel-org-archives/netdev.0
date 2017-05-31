From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/9] nfp: move BPF offload code into app
Date: Wed, 31 May 2017 08:06:42 -0700
Message-ID: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36170 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaPLr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:47 -0400
Received: by mail-pg0-f53.google.com with SMTP id x64so9281444pgd.3
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series moves the eBPF offload code out of netdev/vNIC handling and
starts building the nfp_app.  Port init is moved into the apps as well
because various apps associate vNICs, representors with ports differently.

First patch adds a helper for updating tc stats which has been waiting 
in my tree to be included in any moderately related series.

Next series will bring communicating with FW using control messages,
then representors, BPF maps, tc flower... :)

Jakub Kicinski (9):
  sched: add helper for updating statistics on all actions
  nfp: add missing fall through statements
  nfp: turn reading PCIe RTsym parameters into a helper
  nfp: move port init to apps
  nfp: report app name in ethtool -i
  nfp: move eBPF offload files to BPF app directory
  nfp: move bpf offload code to the BPF app
  nfp: move basic eBPF stats to app-specific code
  nfp: fix memory leak on FW load error

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  10 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |  10 +-
 drivers/net/ethernet/netronome/nfp/Makefile        |  11 +-
 .../netronome/nfp/{nfp_bpf_jit.c => bpf/jit.c}     |   4 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c      | 160 +++++++++++++++++++++
 .../netronome/nfp/{nfp_bpf.h => bpf/main.h}        |  23 +++
 .../nfp/{nfp_net_offload.c => bpf/offload.c}       |  61 ++++----
 .../nfp/{nfp_bpf_verifier.c => bpf/verifier.c}     |   2 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  21 ++-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       | 120 +++++++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |  86 +++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_asm.h       |   2 +-
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   6 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  16 +--
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  71 ++-------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |   5 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  86 ++++++-----
 drivers/net/ethernet/netronome/nfp/nic/main.c      |  58 ++++++++
 include/net/pkt_cls.h                              |  19 +++
 20 files changed, 600 insertions(+), 172 deletions(-)
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf_jit.c => bpf/jit.c} (99%)
 create mode 100644 drivers/net/ethernet/netronome/nfp/bpf/main.c
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf.h => bpf/main.h} (88%)
 rename drivers/net/ethernet/netronome/nfp/{nfp_net_offload.c => bpf/offload.c} (85%)
 rename drivers/net/ethernet/netronome/nfp/{nfp_bpf_verifier.c => bpf/verifier.c} (99%)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nic/main.c

-- 
2.11.0
