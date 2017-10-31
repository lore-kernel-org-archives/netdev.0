From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/14] Mellanox, mlx5e stats groups
Date: Tue, 31 Oct 2017 15:06:33 -0700
Message-ID: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56476 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751603AbdJaWHz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:07:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following series from Kamal introduces a refactoring and redesign for mlx5
ethtool counters handling, for more information please see tag log below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit aa2bc739ef4a181a7589eb009be96a870cc1788f:

  net: filter: remove unused variable and fix warning (2017-10-31 09:18:04 +0900)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-10-31

for you to fetch changes up to 1fe850062c9ee15a3bea1ae90aef386a492a1c5e:

  net/mlx5e: Switch channels counters to use stats group API (2017-10-31 14:20:48 -0700)

----------------------------------------------------------------
mlx5-updates-2017-10-31 mlx5e stats groups

This series from Kamal introduces an important refactoring for mlx5e stats
handling, which groups the stats into generic groups structure which allows
to control the behavior and stats reporting per group in a modular way.

In the first patch Kamal introduces a new data type "mlx5e_stats_grp" This change
defines a new API to create a group of stats and simplifies the way of handling them.
This struct will define the following behavior per group:
    - get_num_stats() - return the number of counters in the group.
    - fill_strings() - fill counters strings within the group.
    - fill_stats() - fill counters values within the group.

All other patches will be straight forward refactoring per stats group,
where Kamal will move each mlx5e stats group to use the new API.

The idea is to have better flexibility and modularity to add new counters,
all ethtool logic was rendered generic and loops through the generic stats groups and
calls the groups callbacks to figure out how and what to report back to user space.

Introducing new file en_stats.c to hold all the new stat groups logic and implementation.
Static structures (counters descriptors) moved from en_stats.h to en_stats.c which reduces
the mlx5_core binary footprint, originally reported and addressed by Stephen Hemminger:
("mlx5: fix space waste from ethtool descriptions") which was waived due to this re-design.

Thanks,
Saeed.

----------------------------------------------------------------
Kamal Heib (14):
      net/mlx5e: Introduce stats group API
      net/mlx5e: Switch Q counters to use the stats group API
      net/mlx5e: Switch vport counters to use the stats group API
      net/mlx5e: Switch IEEE 802.3 counters to use stats group API
      net/mlx5e: Switch RFC 2863 counters to use stats group API
      net/mlx5e: Switch RFC 2819 counters to use stats group API
      net/mlx5e: Switch physical statistical counters to use stats group API
      net/mlx5e: Switch ethernet extended counters to use stats group API
      net/mlx5e: Switch pcie counters to use stats group API
      net/mlx5e: Switch per prio traffic counters to use stats group API
      net/mlx5e: Switch per prio pfc counters to use stats group API
      net/mlx5e: Switch pme counters to use stats group API
      net/mlx5e: Switch ipsec counters to use stats group API
      net/mlx5e: Switch channels counters to use stats group API

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 256 +-----
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 895 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h | 287 +------
 4 files changed, 914 insertions(+), 526 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
