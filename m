From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 00/16] Networking drivers refcount conversions
Date: Tue, 28 Mar 2017 11:56:27 +0300
Message-ID: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, matanb@mellanox.com, paulus@samba.org,
 Elena Reshetova <elena.reshetova@intel.com>, nbd@openwrt.org,
 linux-rdma@vger.kernel.org, saeedm@mellanox.com, ganeshgr@chelsio.com,
 keescook@chromium.org, j@w1.fi, ajk@comnets.uni-bremen.de, leonro@mellanox.com,
 matthias.bgg@gmail.com, linux-hams@vger.kernel.org, kvalo@codeaurora.org,
 blogic@openwrt.org, linux-arm-kernel@lists.infradead.org,
 linux-ppp@vger.kernel.org, yishaih@mellanox.com,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This series, for various different networking drivers, replaces atomic_t reference
counters with the new refcount_t type and API (see include/linux/refcount.h).
By doing this we prevent intentional or accidental
underflows or overflows that can led to use-after-free vulnerabilities.

The below patches are fully independent and can be cherry-picked separately.
Since we convert all kernel subsystems in the same fashion, resulting
in about 300 patches, we have to group them for sending at least in some
fashion to be manageable. Please excuse the long cc list.

If there are no objections to these patches, please take them
through the relevant trees.

Elena Reshetova (16):
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
  drivers, net, intersil: convert hostap_cmd_queue.usecnt from atomic_t
    to refcount_t
  drivers, net, intersil: convert request_context.refcount from atomic_t
    to refcount_t

 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c      | 13 ++++++-----
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h      |  4 +++-
 drivers/net/ethernet/mediatek/mtk_eth_soc.c        |  8 ++++---
 drivers/net/ethernet/mediatek/mtk_eth_soc.h        |  4 +++-
 drivers/net/ethernet/mellanox/mlx4/cq.c            |  8 +++----
 drivers/net/ethernet/mellanox/mlx4/qp.c            |  8 +++----
 drivers/net/ethernet/mellanox/mlx4/srq.c           |  8 +++----
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       | 16 +++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 24 ++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  3 ++-
 drivers/net/hamradio/6pack.c                       | 12 +++++------
 drivers/net/macsec.c                               | 25 +++++++++++-----------
 drivers/net/ppp/ppp_async.c                        | 10 ++++-----
 drivers/net/ppp/ppp_generic.c                      | 17 ++++++++-------
 drivers/net/ppp/ppp_synctty.c                      | 11 +++++-----
 drivers/net/wireless/intersil/hostap/hostap_hw.c   | 12 +++++------
 drivers/net/wireless/intersil/hostap/hostap_wlan.h |  3 ++-
 .../net/wireless/intersil/orinoco/orinoco_usb.c    | 15 +++++++------
 include/linux/mlx4/device.h                        |  8 +++----
 include/linux/mlx5/cq.h                            |  4 ++--
 20 files changed, 112 insertions(+), 101 deletions(-)

-- 
2.7.4
