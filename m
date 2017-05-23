From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/8] Mellanox, mlx5 fixes 2017-05-23
Date: Tue, 23 May 2017 17:16:02 +0300
Message-ID: <20170523141610.27833-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44671 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S937226AbdEWOQd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 10:16:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some fixes for the mlx5 driver and one small patch that
adds csum actions accessors in include/net/tc_act/tc_csum.h needed by some of
mlx5 fixes patches.

Details are below.

Please pull and let me know if there's any problem.

Note: This series doesn't introduce any merge conflict with the ongoing mlx5
for-next submission.

For -stable kernels >= 4.7:
("net/mlx5: Avoid using pending command interface slots")
("net/mlx5: Tolerate irq_set_affinity_hint() failures")

Thanks,
Saeed.

--

The following changes since commit fadd2ce5a3680fb265694f573cbfb8bcb7d6c9d5:

  Merge tag 'pstore-v4.12-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/kees/linux (2017-05-22 19:31:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-05-23

for you to fetch changes up to b665d98edc9ab295169be2fc5bb4e89a46de0a1a:

  net/mlx5: Tolerate irq_set_affinity_hint() failures (2017-05-23 16:23:32 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-05-23

Some TC offloads fixes from Or Gerlitz.
>From Erez, mlx5 IPoIB RX fix to improve GRO.
>From Mohamad, Command interface fix to improve mitigation against FW
commands timeouts.
>From Tariq, Driver load Tolerance against affinity settings failures.

Thanks,
Saeed.

----------------------------------------------------------------
Erez Shitrit (1):
      net/mlx5e: IPoIB, handle RX packet correctly

Mohamad Haj Yahia (1):
      net/mlx5: Avoid using pending command interface slots

Or Gerlitz (5):
      net/mlx5e: Use the correct delete call on offloaded TC encap entry detach
      net/sched: act_csum: Add accessors for offloading drivers
      net/mlx5e: Allow TC csum offload if applied together with pedit action
      net/mlx5e: Properly enforce disallowing of partial field re-write offload
      net/mlx5e: Fix warnings around parsing of TC pedit actions

Tariq Toukan (1):
      net/mlx5: Tolerate irq_set_affinity_hint() failures

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c    | 41 ++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c  |  8 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c  | 60 ++++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/eq.c     |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/health.c |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c   | 15 ++----
 include/linux/mlx5/driver.h                      |  7 ++-
 include/net/tc_act/tc_csum.h                     | 15 ++++++
 8 files changed, 120 insertions(+), 30 deletions(-)
