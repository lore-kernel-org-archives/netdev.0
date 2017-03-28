From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/12] Mellanox mlx5 offloading of TC pedit (header re-write) action
Date: Wed, 29 Mar 2017 02:27:01 +0300
Message-ID: <20170328232713.29894-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42826 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932396AbdC1X2B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 19:28:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following changes from Or Gerlitz provide mlx5 offloading support of
TC pedit (header re-write) action.

For more information please see below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit cc628c9680c212d9dbf68785fbf5d454ccb2313e:

  Merge tag 'mlx5e-failsafe' of git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux (2017-03-27 21:16:03 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5e-pedit

for you to fetch changes up to d7e75a325cb2d2b72e7ac9a185abc1cd59bc9922:

  net/mlx5e: Add offloading of E-Switch TC pedit (header re-write) actions (2017-03-28 15:34:10 +0300)

----------------------------------------------------------------
mlx5e-pedit 2017-03-28

Or Gerlitz says:

This series adds support for offloading modifications of packet headers using
ConnectX-5 HW header re-write as an action applied during packet steering.

The offloaded SW mechanism is TC's pedit action. The offloading is
supported for E-Switch steering of VF traffic in the SRIOV
switchdev mode and for NIC (non eswitch) RX.

One use-case for this offload on virtual networks, is when the hypervisor
implements flow based router such as Open-Stack's DVR, where L2 headers
of guest packets re-written with routers' MAC addresses and the IP TTL
is decremented.

Another use case (which can be applied in parallel with routing) is
stateless NAT where guest L3/L4 headers are re-written.

The series is built as follows: the 1st six patches are preperations which
don't yet add new functionality, patches 7-8 add the FW APIs (data-structures
and commands) for header re-write, and patch nine allows offloading driver
to access pedit keys.

The 10th patch is somehow the core of the series, where we translate from
the pedit way to represent set of header modification elements to the FW
API for that same matter.

Once a set of HW modification is established, we register it with the FW
and get a modify header ID. When this ID is used with an action during
packet steering, the HW applies the header modification on the packet.

Patches 11 and 12 implement the above logic as an offload for pedit action
for the NIC and E-Switch use-cases.

I'd like to thanks Elijah Shakkour <elijahs@mellanox.com> for implementing
and helping me testing this functionality on HW simulator, before it could
be done with FW.

- Or.

----------------------------------------------------------------
Or Gerlitz (12):
      net/mlx5e: Add prefix for e-switch offloaded TC flow attributes
      net/mlx5e: Add NIC attributes for offloaded TC flows
      net/mlx5e: Add intermediate struct for TC flow parsing attributes
      net/mlx5e: Properly deal with resource cleanup when adding TC flow fails
      net/mlx5: Add helper to initialize a flow steering actions struct instance
      net/mlx5: Reorder few command cases to reflect their natural order
      net/mlx5: Introduce modify header structures, commands and steering action definitions
      net/mlx5: Introduce alloc/dealloc modify header context commands
      net/sched: Add accessor functions to pedit keys for offloading drivers
      net/mlx5e: Add parsing of TC pedit actions to HW format
      net/mlx5e: Add offloading of NIC TC pedit (header re-write) actions
      net/mlx5e: Add offloading of E-Switch TC pedit (header re-write) actions

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  28 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  18 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 473 ++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   5 +-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  28 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  67 +++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   1 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   5 +
 include/linux/mlx5/fs.h                            |   6 +-
 include/linux/mlx5/mlx5_ifc.h                      | 113 ++++-
 include/net/tc_act/tc_pedit.h                      |  45 ++
 13 files changed, 698 insertions(+), 106 deletions(-)
