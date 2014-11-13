From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/7] mlx4: Flexible (asymmetric) allocation of EQs and MSI-X vectors
Date: Thu, 13 Nov 2014 14:45:26 +0200
Message-ID: <1415882733-3084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46575 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932692AbaKMMpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 07:45:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Matan Barak is built as follows:

The 1st two patches fix small bugs w.r.t firmware spec. Next
are two patches which do more re-factoring of the init/fini flow
and a patch that adds support for the QUERY_FUNC firmware command,
these are all pre-steps for the major patch of the series. In this
patch (#6) we change the order of talking/querying the firmware
and enabling SRIOV. This allows to remote worst-case assumption
w.r.t the number of available MSI-X vectors and EQs per function.

The last patch easily enjoys this ordering change, to enable
supports > 64 VFs over a firmware that allows for that.

Or.


Matan Barak (7):
  net/mlx4_core: Fix wrong reading of reserved_eqs
  net/mlx4_core: Use correct variable type for mlx4_slave_cap
  net/mlx4_core: Refactor mlx4_cmd_init and mlx4_cmd_cleanup
  net/mlx4_core: Refactor mlx4_load_one
  net/mlx4_core: Add QUERY_FUNC firmware command
  net/mlx4_core: Flexible (asymmetric) allocation of EQs and MSI-X vectors for PF/VFs
  net/mlx4_core: Support more than 64 VFs

 drivers/infiniband/hw/mlx4/main.c            |    3 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c     |   76 ++++---
 drivers/net/ethernet/mellanox/mlx4/eq.c      |    8 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c      |  113 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h      |   15 ++-
 drivers/net/ethernet/mellanox/mlx4/main.c    |  307 +++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/mlx4.h    |   11 +-
 drivers/net/ethernet/mellanox/mlx4/profile.c |   19 +-
 include/linux/mlx4/device.h                  |    7 +-
 9 files changed, 440 insertions(+), 119 deletions(-)
