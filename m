From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/15] networking drivers refcount_t conversions
Date: Fri, 20 Oct 2017 10:23:34 +0300
Message-ID: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Note: these are the last patches related to networking that perform
conversion of refcounters from atomic_t to refcount_t.
In contrast to the core network refcounter conversions that
were merged earlier, these are much more straightforward ones.

This series, for various networking drivers, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The patches are fully independent and can be cherry-picked separately.
Patches are based on top of net-next.
If there are no objections to the patches, please merge them via respective trees

Elena Reshetova (15):
  drivers, net, ethernet: convert clip_entry.refcnt from atomic_t to
    refcount_t
  drivers, net, ethernet: convert mtk_eth.dma_refcnt from atomic_t to
    refcount_t
  drivers, net, mlx4: convert mlx4_cq.refcount from atomic_t to
    refcount_t
  drivers, net, mlx4: convert mlx4_qp.refcount from atomic_t to
    refcount_t
  drivers, net, mlx4: convert mlx4_srq.refcount from atomic_t to
    refcount_t
  drivers, net, mlx5: convert mlx5_cq.refcount from atomic_t to
    refcount_t
  drivers, net, mlx5: convert fs_node.refcount from atomic_t to
    refcount_t
  drivers, net, hamradio: convert sixpack.refcnt from atomic_t to
    refcount_t
  drivers, net: convert masces_rx_sa.refcnt from atomic_t to refcount_t
  drivers, net: convert masces_rx_sc.refcnt from atomic_t to refcount_t
  drivers, net: convert masces_tx_sa.refcnt from atomic_t to refcount_t
  drivers, net, ppp: convert asyncppp.refcnt from atomic_t to refcount_t
  drivers, net, ppp: convert ppp_file.refcnt from atomic_t to refcount_t
  drivers, net, ppp: convert syncppp.refcnt from atomic_t to refcount_t
  drivers, connector: convert cn_callback_entry.refcnt from atomic_t to
    refcount_t

 drivers/connector/cn_queue.c                      |  4 ++--
 drivers/connector/connector.c                     |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c     | 13 +++++------
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h     |  4 +++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c       |  8 ++++---
 drivers/net/ethernet/mediatek/mtk_eth_soc.h       |  4 +++-
 drivers/net/ethernet/mellanox/mlx4/cq.c           |  8 +++----
 drivers/net/ethernet/mellanox/mlx4/qp.c           |  8 +++----
 drivers/net/ethernet/mellanox/mlx4/srq.c          |  8 +++----
 drivers/net/ethernet/mellanox/mlx5/core/cq.c      | 16 ++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 28 +++++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h |  3 ++-
 drivers/net/hamradio/6pack.c                      | 12 +++++-----
 drivers/net/macsec.c                              | 25 ++++++++++----------
 drivers/net/ppp/ppp_async.c                       | 10 ++++----
 drivers/net/ppp/ppp_generic.c                     | 21 +++++++++--------
 drivers/net/ppp/ppp_synctty.c                     | 11 +++++----
 include/linux/connector.h                         |  4 ++--
 include/linux/mlx4/device.h                       |  8 +++----
 include/linux/mlx5/cq.h                           |  4 ++--
 20 files changed, 105 insertions(+), 96 deletions(-)

-- 
2.7.4
