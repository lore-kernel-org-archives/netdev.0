From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 00/10] Mellanox driver updates 2013-06-25
Date: Tue, 25 Jun 2013 12:09:28 +0300
Message-ID: <1372151378-21468-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52094 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751976Ab3FYJK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 05:10:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch set contains some small fixes to mlx4_core and mlx4_en.

Amir is OOO and he passed the stick to me on this series.

The patches were applied and tested on commit d3c5f47ee2 "net: Restore 
unintentional reverts." plus Eric's patch "mlx4: allow order-0 memory 
allocations in RX path" from http://patchwork.ozlabs.org/patch/253575/ 
that I just acknowledged.

Changes from V0:
- dropped patch 1/11 as this is handled by Eric's change
- addressed feedback on patch 6/10: Add prints when TX timeout occurs
  - en_info => en_warn
  - Use single line for warning message
  - Update change log

Thanks,

Or.

Dotan Barak (4):
  net/mlx4_en: Fix resource leak in error flow
  net/mlx4_en: Remove an unnecessary test
  net/mlx4_core: Replace sscanf() with kstrtoint()
  net/mlx4_core: Add warning in case of command timeouts

Eugenia Emantayev (3):
  net/mlx4_en: Move register_netdev() to the end of initialization function
  net/mlx4_en: Change log level from error to debug for vlan related messages
  net/mlx4_en: Fix a race between napi poll function and RX ring cleanup

Jack Morgenstein (2):
  net/mlx4_en: Do not query stats when device port is down
  net/mlx4_core: Fail device init if num_vfs is negative

Yevgeny Petrilin (1):
  net/mlx4_en: Add prints when TX timeout occurs

 drivers/net/ethernet/mellanox/mlx4/cmd.c       |    6 ++++
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c |    3 --
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   33 ++++++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/main.c      |   11 ++++++--
 5 files changed, 37 insertions(+), 18 deletions(-)
