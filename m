From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC net-next PATCH 0/5] XDP driver feature API and handling change
 to xdp_buff
Date: Thu, 18 May 2017 17:41:27 +0200
Message-ID: <149512205297.14733.15729847433404265933.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
        netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37540 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755016AbdERPlb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 11:41:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I would like some comments on introducing a feature API between XDP
drives and XDP/BPF core.  The primary issue is when extending struct
xdp_buff, today, drivers not implementing this feature can access
uninitilized memory, using bpf-helper associated with the feature.

---

Jesper Dangaard Brouer (5):
      samples/bpf: xdp_tx_iptunnel make use of map_data[]
      mlx5: fix bug reading rss_hash_type from CQE
      net: introduce XDP driver features interface
      net: new XDP feature for reading HW rxhash from drivers
      mlx5: add XDP rxhash feature for driver mlx5


 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   98 ++++++++++++++-------
 include/linux/filter.h                            |   31 ++++++-
 include/linux/mlx5/device.h                       |   10 ++
 include/linux/netdev_features.h                   |   34 +++++++
 include/linux/netdevice.h                         |    1 
 include/uapi/linux/bpf.h                          |   56 ++++++++++++
 kernel/bpf/verifier.c                             |    3 +
 net/core/dev.c                                    |   48 ++++++++++
 net/core/ethtool.c                                |    2 
 net/core/filter.c                                 |   73 ++++++++++++++++
 samples/bpf/bpf_helpers.h                         |    2 
 samples/bpf/xdp_tx_iptunnel_common.h              |    2 
 samples/bpf/xdp_tx_iptunnel_kern.c                |    2 
 samples/bpf/xdp_tx_iptunnel_user.c                |   14 ++-
 tools/include/uapi/linux/bpf.h                    |   10 ++
 16 files changed, 345 insertions(+), 44 deletions(-)
