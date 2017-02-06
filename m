From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next V2 0/6] Mellanox mlx5 updates 2017-01-31
Date: Tue,  7 Feb 2017 01:38:23 +0200
Message-ID: <20170206233829.29716-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52051 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751690AbdBFXjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 18:39:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This pull request includes two new mlx5 features and two small fixes for net-next,
Details are bleow.

Please pull and let me know if there's any problem.

Sorry for the delay on addressing the comments.
v1->v2:
	- Addressed the comments on the static checker fix patch
	- Squash cacheline patches (it is more correct they come as one).
	- Dropped "net/mlx5e: Calc vlan_tag_present only once on xmit" 
          as it doesn't seem to give any added value.

Thanks,
Saeed.

---

The following changes since commit bd092ad1463ca0990581fa992e12a9b0ed295d25:

  Merge branch 'remove-__napi_complete_done' (2017-02-05 16:11:59 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-01-31

for you to fetch changes up to 8ca967ab67671f07ac7daef4f854559bc66799a3:

  net/mlx5e: Bring back bfreg uar map dedicated pointer (2017-02-06 18:20:18 +0200)

----------------------------------------------------------------
mlx5-updates-2017-01-31

This series includes some updates to mlx5 core and ethernet driver.

We got one patch from Or to fix some static checker warnings.

2nd patche from Dan came to add the support for 128B cache line
in the HCA, which will configures the hardware to use 128B alignment only
on systems with 128B cache lines, otherwise it will be kept as the current
default of 64B.

>From me three patches to support no inline copy on TX on ConnectX-5 and
later HCAs.  Starting with two small infrastructure changes and
refactoring patches followed by two patches to add the actual support for
both xmit ndo and XDP xmit routines.
Last patch is a simple fix to return a mistakenly removed pointer from the
SQ structure, which was remove in previous submission of mlx5 4K UAR.

Saeed.

----------------------------------------------------------------
Daniel Jurgens (1):
      net/mlx5: Configure cache line size for start and end padding

Or Gerlitz (1):
      net/mlx5: Fix static checker warnings

Saeed Mahameed (4):
      net/mlx5: TX WQE update
      net/mlx5e: Tx, no inline copy on ConnectX-5
      net/mlx5e: XDP Tx, no inline copy on ConnectX-5
      net/mlx5e: Bring back bfreg uar map dedicated pointer

 drivers/infiniband/hw/mlx5/qp.c                   |  6 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 17 ++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 21 ++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 20 +++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 30 +++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  6 +++++
 include/linux/mlx5/device.h                       |  3 ++-
 include/linux/mlx5/mlx5_ifc.h                     |  9 ++++---
 include/linux/mlx5/qp.h                           | 16 ++++++++++--
 9 files changed, 85 insertions(+), 43 deletions(-)
