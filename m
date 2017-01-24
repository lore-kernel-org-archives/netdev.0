From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/12] Mellanox mlx5 updates 2017-01-24
Date: Tue, 24 Jan 2017 22:16:40 +0200
Message-ID: <20170124201652.2920-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54287 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751086AbdAXURf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 15:17:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This pull request includes one new feature to support offloading IPv6
tunnels in switchdev mode, in addition to some small mlx5 updates.
Details are down bleow.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 4548b683b78137f8eadeb312b94e20bb0d4a7141:

  Introduce a sysctl that modifies the value of PROT_SOCK. (2017-01-24 12:10:51 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-01-24

for you to fetch changes up to 5eb0249b4352c813f0a3c31b967f6cb4b9869a50:

  net/mlx5e: CQE compression control code reuse (2017-01-24 21:14:08 +0200)

----------------------------------------------------------------
mlx5-updates-2017-24-01

The first seven patches from Or Gerlitz in this series further enhances
the mlx5 SRIOV switchdev mode to support offloading IPv6 tunnels using the
TC tunnel key set (encap) and unset (decap) actions.

Or Gerlitz says:
========================
As part of doing this change, few cleanups are done in the IPv4 code,
later we move to use the full tunnel key info provided to the driver as
the key for our internal hashing which is used to identify cases where
the same tunnel is used for encapsulating multiple flows. As done in the
IPv4 case, the control path for offloading IPv6 tunnels uses route/neigh
lookups and construction of the IPv6 tunnel headers on the encap path and
matching on the outer hears in the decap path.

The last patch of the series enlarges the HW FDB size for the switchdev mode,
so it has now room to contain offloaded flows as many as min(max number
of HW flow counters supported, max HW table size supported).
========================

Next to Or's series you can find several patches handling several topics.

>From Mohamad, add support for SRIOV VF min rate guarantee by using the
TSAR BW share weights mechanism.

>From Or, Two patches to enable Eth VFs to query their min-inline value for
user-space.
for that we move a mlx5 low level min inline helper function from mlx5
ethernet driver into the core driver and then use it in mlx5_ib to expose
the inline mode to rdma applications through libmlx5.

>From Kamal Heib, Reduce memory consumption on kdump kernel.

>From Shaker Daibes, code reuse in CQE compression control logic

Thanks,
Saeed.

----------------------------------------------------------------
Kamal Heib (1):
      net/mlx5e: Reduce memory consumption on kdump kernel

Mohamad Haj Yahia (1):
      net/mlx5: Add support for setting VF min rate

Or Gerlitz (9):
      net/mlx5: Use exact encap header size for the FW input buffer
      net/mlx5e: Add TC offloads matching on IPv6 encapsulation headers
      net/mlx5e: TC ipv4 tunnel encap offload cosmetic changes
      net/mlx5e: Use the full tunnel key info for encapsulation offload house-keeping
      net/mlx5e: Maximize ip tunnel key usage on the TC offloading path
      net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels
      net/mlx5: E-Switch, Enlarge the FDB size for the switchdev mode
      net/mlx5: Push min-inline mode resolution helper into the core
      IB/mlx5: Enable Eth VFs to query their min-inline value for user-space

Shaker Daibes (1):
      net/mlx5e: CQE compression control code reuse

 drivers/infiniband/hw/mlx5/main.c                  |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   7 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  17 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  44 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 242 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  97 ++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  20 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  17 ++
 include/linux/mlx5/mlx5_ifc.h                      |   4 +-
 include/linux/mlx5/vport.h                         |   1 +
 include/uapi/rdma/mlx5-abi.h                       |  14 +-
 15 files changed, 389 insertions(+), 120 deletions(-)
