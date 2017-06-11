From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/9] Mellanox mlx5 updates 2017-06-11
Date: Sun, 11 Jun 2017 17:55:44 +0300
Message-ID: <20170611145553.14180-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46658 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751963AbdFKO4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 10:56:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides updates to mlx5 header rewrite feature, from Or Gerlitz.
and three more small updates From Maor and Eran.

For more details please see below.

Please pull and let me know if there's any problem.
*This series doesn't introduce any conflict with the ongoing net
pull request.

Thanks,
Saeed.

---

The following changes since commit 50dffe7fad6c156c2928e45c19ff7b86eb951f4c:

  Merge branch 'mlx4-drivers-version-update' (2017-06-07 15:33:02 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-06-11

for you to fetch changes up to 46e9d0b61e27a3a9286002311f349f0c33dcb18f:

  net/mlx5e: Fill advertised and supported port data from Hardware info (2017-06-08 14:12:00 +0300)

----------------------------------------------------------------
mlx5-updates-2017-06-11

This series provides updates to mlx5 header rewrite feature, from Or Gerlitz.
and three more small updates From maor and eran.

-------
Or says:

Packets belonging to flows which are different by matching may still need
to go through the same header re-writes (e.g set the current routing hop
MACs and issue TTL decrement).  To minimize the number of modify header
IDs, we add a cache for header re-write IDs which is keyed by the binary
chain of modify header actions.

The caching is supported for both eswitch and NIC use-cases, where the
actual conversion of the code to use caching comes in separate patches,
one per use-case.

Using a per field mask field, the TC pedit action supports modifying
partial fields. The last patch enables offloading that.
-------

>From Maor, update flow table commands layout to the latest HW spec.
>From Eran, ethtool connector type reporting updates.

Thanks,
Saeed.

----------------------------------------------------------------
Eran Ben Elisha (2):
      net/mlx5e: Add support for reading connector type from PTYS
      net/mlx5e: Fill advertised and supported port data from Hardware info

Maor Gottlieb (1):
      net/mlx5: Update flow table commands layout

Or Gerlitz (6):
      net/mlx5e: Remove limitation of single NIC offloaded TC action per rule
      net/mlx5e: Use short attribute form when adding/deleting offloaded TC flows
      net/mlx5e: Add cache for HW modify header IDs
      net/mlx5e: Use modify header ID cache for offloaded TC E-Switch flows
      net/mlx5e: Use modify header ID cache for offloaded TC NIC flows
      net/mlx5e: Support header re-write of partial fields in TC pedit offload

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   2 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 112 ++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 203 +++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  32 ++--
 include/linux/mlx5/mlx5_ifc.h                      |  53 +++---
 include/linux/mlx5/port.h                          |  13 ++
 8 files changed, 322 insertions(+), 95 deletions(-)
