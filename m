From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/2] mlx4 bug fixes for 4.9
Date: Sun, 27 Nov 2016 19:20:50 +0200
Message-ID: <1480267252-26146-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34725 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751532AbcK0RVN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 12:21:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset includes 2 bug fixes:
* In patch 1 we revert the commit that avoids invoking unregister_netdev
in shutdown flow, as it introduces netdev presence issues where
it can be accessed unsafely by ndo operations during the flow.
* Patch 2 is a simple fix for a variable uninitialization issue.

Series generated against net commit:
6998cc6ec237 tipc: resolve connection flow control compatibility problem

Thanks,
Tariq.

Jack Morgenstein (1):
  net/mlx4: Fix uninitialized fields in rule when adding promiscuous
    mode to device managed flow steering

Tariq Toukan (1):
  Revert "net/mlx4_en: Avoid unregister_netdev at shutdown flow"

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 17 ++---------------
 drivers/net/ethernet/mellanox/mlx4/main.c      |  5 +----
 drivers/net/ethernet/mellanox/mlx4/mcg.c       |  7 ++++++-
 include/linux/mlx4/device.h                    |  1 -
 4 files changed, 9 insertions(+), 21 deletions(-)

-- 
1.8.3.1
