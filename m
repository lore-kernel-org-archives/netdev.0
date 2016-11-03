From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/6] Mellanox 100G mlx5 fixes 2016-11-04
Date: Fri,  4 Nov 2016 01:48:41 +0200
Message-ID: <1478216927-31328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37668 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933334AbcKCXuN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 19:50:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains six hot fixes of the mlx5 core and mlx5e driver.

Huy fixed an invalid pointer dereference on initialization flow for when
the selected mlx5 load profile is out of range.

Or provided three eswitch offloads related fixes
 - Prevent changing NS of a VF representor. 
 - Handle matching on vlan priority for offloaded TC rules
 - Set the actions for offloaded rules properly

On my part I here addressed the error flow related issues in
mlx5e_open_channel reported by Jesper just this week.

Thanks,
Saeed.

Huy Nguyen (1):
  net/mlx5: Fix invalid pointer reference when prof_sel parameter is
    invalid

Or Gerlitz (3):
  net/mlx5e: Disallow changing name-space for VF representors
  net/mlx5e: Handle matching on vlan priority for offloaded TC rules
  net/mlx5: E-Switch, Set the actions for offloaded rules properly

Saeed Mahameed (2):
  net/mlx5e: Fix XDP error path of mlx5e_open_channel()
  net/mlx5e: Re-arrange XDP SQ/CQ creation

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 31 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  5 +++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  5 ++--
 5 files changed, 26 insertions(+), 20 deletions(-)

-- 
2.7.4
