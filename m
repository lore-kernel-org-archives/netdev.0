From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/8] Mellanox mlx5 updates 2017-01-31
Date: Tue, 31 Jan 2017 22:58:35 +0200
Message-ID: <20170131205843.23235-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60061 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751240AbdAaVFo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 16:05:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This pull request includes two new features and two small fixes for net-next,
Details are bleow.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 624374a56419c2d6d428c862f32cc1b20519095d:

  Merge branch 'bgmac-phy-init' (2017-01-31 13:44:50 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-01-31

for you to fetch changes up to 4abee9190fcac371116aa73c2e0f86c6b72f8fe3:

  net/mlx5e: Bring back bfreg uar map dedicated pointer (2017-01-31 21:34:10 +0200)

----------------------------------------------------------------
mlx5-updates-2017-01-31

This series includes some updates to mlx5 core and ethernet driver.

We got one patch from Or to fix some static checker warnings.

2nd and 3rd patches from Dan came to add the support for 128B cache line
in the HCA, which will configures the hardware to use 128B alignment only
on systems with 128B cache lines, otherwise it will be kept as the current
default of 64B.

>From me four patches to support no inline copy on TX on ConnectX-5 and
later HCAs.  Starting with two small infrastructure changes and
refactoring patches followed by two patches to add the actual support for
both xmit ndo and XDP xmit routines.
Last patch is a simple fix to return a mistakenly removed pointer from the
SQ structure, which was remove in previous submission of mlx5 4K UAR.

Saeed.

----------------------------------------------------------------
Daniel Jurgens (2):
      net/mlx5: Configure cache line size for start and end padding
      net/mlx5e: Lower bound MPWRQ stride by HCA cacheline

Or Gerlitz (1):
      net/mlx5: Fixed static checker warnings

Saeed Mahameed (5):
      net/mlx5: TX WQE update
      net/mlx5e: Calc vlan_tag_present only once on xmit
      net/mlx5e: Tx, no inline copy on ConnectX-5
      net/mlx5e: XDP Tx, no inline copy on ConnectX-5
      net/mlx5e: Bring back bfreg uar map dedicated pointer

 drivers/infiniband/hw/mlx5/qp.c                   |  6 +--
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 17 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 21 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 20 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  8 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 47 +++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  6 +++
 include/linux/mlx5/device.h                       |  3 +-
 include/linux/mlx5/mlx5_ifc.h                     |  9 +++--
 include/linux/mlx5/qp.h                           | 16 +++++++-
 10 files changed, 99 insertions(+), 54 deletions(-)
