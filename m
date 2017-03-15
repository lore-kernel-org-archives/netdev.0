From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [net-next PATCH 0/2] Add support for passing more information in
 mqprio offload
Date: Wed, 15 Mar 2017 10:39:12 -0700
Message-ID: <20170315172929.16349.95037.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: thomas.lendacky@amd.com, bkenward@solarflare.com,
        amritha.nambiar@intel.com, madalin.bucur@nxp.com, w-kwok2@ti.com,
        saeedm@mellanox.com, ariel.elior@cavium.com, m-karicheri2@ti.com,
        jeffrey.t.kirsher@intel.com, Yuval.Mintz@cavium.com,
        ecree@solarflare.com, michael.chan@broadcom.com,
        tariqt@mellanox.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34352 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752149AbdCORkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 13:40:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id b5so2989781pgg.1
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 10:39:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series lays the groundwork for future work to allow us to make
full use of the mqprio options when offloading them to hardware.

Currently when we specify the hardware offload for mqprio the queue
configuration is completely ignored and the hardware is only notified of
the total number of traffic classes.  The problem is this leads to multiple
issues, one specific issue being you can pass the queue configuration you
want and it is totally ignored by the hardware.

What I am planning to do is add support for "hw" values in the
configuration greater than 1.  So for example we might have one mode of
mqprio offload that uses 1 and only offloads the TC counts like we
currently do.  Then we might look at adding an option 2 which would factor
in the TCs and the queue count information. This way we can select between
the type of offload we actually want and existing drivers that don't
support this can just fall back to their legacy configuration.

---

Alexander Duyck (1):
      mqprio: Change handling of hw u8 to allow for multiple hardware offload modes

Amritha Nambiar (1):
      mqprio: Modify mqprio to pass user parameters via ndo_setup_tc.


 drivers/net/ethernet/amd/xgbe/xgbe-drv.c          |    3 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |    5 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |    4 ++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c    |   16 +++++----
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c   |    4 ++
 drivers/net/ethernet/intel/i40e/i40e_main.c       |    7 +++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    4 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |    4 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    4 ++
 drivers/net/ethernet/sfc/falcon/tx.c              |    4 ++
 drivers/net/ethernet/sfc/tx.c                     |    4 ++
 drivers/net/ethernet/ti/netcp_core.c              |   12 ++++--
 include/linux/netdevice.h                         |    2 +
 include/uapi/linux/pkt_sched.h                    |    8 ++++
 net/sched/sch_mqprio.c                            |   39 +++++++++++++--------
 15 files changed, 84 insertions(+), 36 deletions(-)
