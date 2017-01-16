From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/3] mlx4 core fixes
Date: Mon, 16 Jan 2017 18:31:36 +0200
Message-ID: <1484584299-3950-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36309 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751253AbdAPQcA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:32:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains bug fixes from Jack to the mlx4 Core driver.

Patch 1 solves a race in the flow of CQ free.
Patch 2 moves some qp context flags update to the correct qp transition.
Patch 3 eliminates warnings from the path of SRQ_LIMIT that flood the message log,
and keeps them only in the path of SRQ_CATAS_ERROR.

Series generated against net commit:
1a717fcf8bbe Merge tag 'mac80211-for-davem-2017-01-13' of git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211

Thanks,
Tariq.

Jack Morgenstein (3):
  net/mlx4_core: Fix racy CQ (Completion Queue) free
  net/mlx4_core: Fix when to save some qp context flags for dynamic VST
    to VGT transitions
  net/mlx4_core: Eliminate warning messages for SRQ_LIMIT under SRIOV

 drivers/net/ethernet/mellanox/mlx4/cq.c            | 38 ++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/eq.c            | 23 ++++++++-----
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  5 +--
 3 files changed, 37 insertions(+), 29 deletions(-)

-- 
1.8.3.1
