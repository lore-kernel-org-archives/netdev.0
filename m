From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V2 0/8] Mellanox driver update 2014-05-12
Date: Wed, 14 May 2014 12:15:09 +0300
Message-ID: <1400058917-26313-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, saeedm@mellanox.com,
	eyalpe@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51159 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752075AbaENJPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 05:15:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduce some small bug fixes:

Eyal fixed some compilation and syntactic checkers warnings. Ido fixed a
coruption in user priority mapping when changing number of channels. Shani 
fixed some other problems when modifying MAC address. Yuval fixed a problem 
when changing IRQ affinity during high traffic - IRQ changes got effective 
only after the first pause in traffic.

This patchset was tested and applied over commit 93dccc5: "mdio_bus: fix
devm_mdiobus_alloc_size export"

Changes from V1:
- applied feedback from Dave to use true/false and not 0/1 in patch 1/9 
- removed the patch from Noa which adddressed a bug in flow steering table 
  when using a bond device, as the fix might need to be in the bonding driver,
  this is now dicussed in the netdev thread "bonding directly changes 
  underlying device address"

Changes from V0:
- Patch 1/9 - net/mlx4_core: Enforce irq affinity changes immediatly
  - Moved the new members to a hot cache line as Eric suggested

Thanks,

Amir and Or

Eyal Perry (4):
  net/mlx4_core: Fix smatch error - possible access to a null variable
  net/mlx4_core: Removed unnecessary bit operation condition
  net/mlx4_en: Using positive error value for unsigned
  net/mlx4_core: Fix inaccurate return value of mlx4_flow_attach()

Ido Shamay (1):
  net/mlx4_en: User prio mapping gets corrupted when changing number of
    channels

Shani Michaelli (2):
  net/mlx4_en: Fix errors in MAC address changing when port is down
  net/mlx4_en: Protect MAC address modification with the state_lock
    mutex

Yuval Atias (1):
  net/mlx4_core: Enforce irq affinity changes immediatly

 drivers/net/ethernet/mellanox/mlx4/cmd.c        |   14 +++++
 drivers/net/ethernet/mellanox/mlx4/cq.c         |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |   12 ++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   11 +++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |    6 ++
 drivers/net/ethernet/mellanox/mlx4/eq.c         |   62 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c       |    9 ++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c        |    2 +-
 include/linux/mlx4/device.h                     |    3 +
 10 files changed, 110 insertions(+), 15 deletions(-)
