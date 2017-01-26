From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 0/4] mlx5: Create build configuration options
Date: Thu, 26 Jan 2017 15:32:37 -0800
Message-ID: <20170126233241.2268449-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <saeedm@mellanox.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33203 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752436AbdAZXnn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:43:43 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v0QNJ4qZ003610
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:50 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 287mtts7bt-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2017 15:32:50 -0800
Received: from facebook.com (2401:db00:11:d008:face:0:1d:0)     by
 mx-out.facebook.com (10.222.219.45) with ESMTP id
 bef8c014e41f11e6a6ee24be05904660-233d6a50 for <netdev@vger.kernel.org>;        Thu,
 26 Jan 2017 15:32:48 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset creates configuration options for sriov, vxlan, eswitch,
and tc features in the mlx5 driver. The purpose of this is to allow not
building these features. These features are optional advanced features
that are not required for a core Ethernet driver. A user can disable
these features which resuces the amount of code in the driver. Disabling
these features (and DCB) reduces the size of mlx5_core.o by about 16%.
This is also can reduce the complexity of backport and rebases since
user would no longer need to worry about dependencies with the rest of
the kernel that features which might not be of any interest to a user
may bring in.

Tested: Build and ran the driver with all features enabled (the default)
and with none enabled (including DCB). Did not see any issues. I did
not explicity test operation of ayy of features in the list.


Tom Herbert (4):
  mlx5: Make building eswitch configurable
  mlx5: Make building SR-IOV configurable
  mlx5: Make building tc hardware offload configurable
  mlx5: Make building vxlan hardware offload configurable

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  35 ++++++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |  16 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 129 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c   |  39 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/eq.c      |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c     |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  32 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c   |   6 +-
 8 files changed, 205 insertions(+), 58 deletions(-)

-- 
2.9.3
