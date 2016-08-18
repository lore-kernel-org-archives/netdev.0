From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/10] Mellanox 100G mlx5 fixes 2016-08-16
Date: Thu, 18 Aug 2016 21:09:01 +0300
Message-ID: <1471543751-24164-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41786 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754832AbcHSBnF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 21:43:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series includes some bug fixes for mlx5e driver.

>From Saeed and Tariq, Optimize MTU change to not reset when it is not required.

>From Paul, Command interface message length check to speedup firmware 
command preparation.

>From Mohamad, Save pci state when pci error is detected.

>From Amir, Flow counters "lastuse" update fix.

>From Hadar, Use correct flow dissector key on flower offloading.
Plus a small optimization for switchdev hardware id query.

>From Or, three patches to address some E-Switch offloads issues. 

For -stable of 4.6.y and 4.7.y:
    net/mlx5e: Use correct flow dissector key on flower offloading
    net/mlx5: Fix pci error recovery flow
    net/mlx5: Added missing check of msg length in verifying its signature

Thanks,
Saeed.

Amir Vadai (1):
  net/mlx5: Update last-use statistics for flow rules

Hadar Hen Zion (2):
  net/mlx5e: Use correct flow dissector key on flower offloading
  net/mlx5e: Retrieve the switchdev id from the firmware only once

Mohamad Haj Yahia (1):
  net/mlx5: Fix pci error recovery flow

Or Gerlitz (3):
  net/mlx5: E-Switch, Return the correct devlink e-switch mode
  net/mlx5: E-Switch, Set the send-to-vport rules in the correct table
  net/mlx5: E-Switch, Avoid ACLs in the offloads mode

Paul Blakey (1):
  net/mlx5: Added missing check of msg length in verifying its signature

Saeed Mahameed (1):
  net/mlx5e: Set port MTU on netdev creation rather on open

Tariq Toukan (1):
  net/mlx5e: Optimization for MTU change

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 85 ++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 21 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 16 ++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  1 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 26 +++++--
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 11 ++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 59 ++++++++-------
 9 files changed, 141 insertions(+), 85 deletions(-)

-- 
2.7.4
